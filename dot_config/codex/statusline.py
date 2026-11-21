"""Display model, mode, Git/PR status, context bar, and quotas in the Codex footer."""

import json
import math
import os
import subprocess
import sys
import threading
import time
from functools import lru_cache
from pathlib import Path


SERVER = "compact-statusline"
URI = f"ui://{SERVER}/footer"
BAR_WIDTH = 12
RESET_ABOVE_USED_PCT = 60.0

# Dark Tokyo Night palette (synchronized with Antigravity statusline.sh)
MODEL_COLOR = "#bb9af7"      # Purple
META_COLOR = "#a9b1d6"       # Foreground / Meta / Labels / CWD / PR
TRACK_COLOR = "#414868"      # Dim empty bar track (▱)
BRANCH_COLOR = "#73daca"     # Teal
DIRTY_COLOR = "#ff8b52"      # Orange (*, REBASE, MERGING)
CONTEXT_COLOR = "#7aa2f7"    # Blue (Context < 70%)
ASK_COLOR = "#7dcfff"        # Cyan (Ask for approval)
OK_COLOR = "#9ece6a"         # Green (Approve for me, Quota used < 70%, +added)
WARN_COLOR = "#e0af68"       # Yellow (Read Only, Fast, Context >= 60%, Quota used >= 70%)
CRIT_COLOR = "#f7768e"       # Red (Full Access, Context >= 85%, Quota used >= 90%, −removed)
SEPARATOR_COLOR = "#565f89"  # Dim divider ( | )

TOOL = {
    "name": "statusline",
    "title": "Compact status line",
    "description": "Show the model, mode, workspace, Git/PR status, context bar, and quota usage.",
    "inputSchema": {"type": "object", "properties": {}},
    "_meta": {
        "openai/ui": {"entrypoints": [{"type": "statusline", "resourceUri": URI}]}
    },
}

_GIT_CACHE = {}
_GIT_LOCK = threading.Lock()
_GIT_TTL_SEC = 2.0
_GIT_FIRST_WAIT_SEC = 0.15
_GIT_TIMEOUT = object()

_PR_CACHE = {}
_PR_LOCK = threading.Lock()
_PR_TTL_SEC = 30.0
_PR_TIMEOUT = object()

_CACHE_MAX_ENTRIES = 32


def _prune_cache(cache):
    if len(cache) > _CACHE_MAX_ENTRIES:
        oldest_key = min(cache, key=lambda k: cache[k][0])
        cache.pop(oldest_key, None)


def label(value, width):
    value = "".join(char for char in str(value) if char.isprintable()).strip()
    return value if len(value) <= width else value[: width - 1] + "…"


def text(value, color=None, **props):
    node_props = {k: v for k, v in props.items() if v is not None}
    if color is not None:
        node_props["color"] = color
    node = {"type": "text", "children": [value]}
    if node_props:
        node["props"] = node_props
    return node


def separator():
    return text(" | ", SEPARATOR_COLOR)


def shorten_path(cwd, depth=2):
    if not cwd:
        return ""
    home = str(Path.home())
    if cwd == home:
        p = "~"
    elif cwd.startswith(home + "/"):
        p = "~" + cwd[len(home) :]
    else:
        p = cwd

    if p.startswith("~/"):
        parts = [seg for seg in p[2:].split("/") if seg]
        if len(parts) <= depth:
            return p
        return "~/…/" + "/".join(parts[-depth:])
    if p.startswith("/"):
        parts = [seg for seg in p[1:].split("/") if seg]
        if len(parts) <= depth:
            return p
        return "/…/" + "/".join(parts[-depth:])
    return p


def _git_run(cwd, *args, timeout=1.0):
    try:
        result = subprocess.run(
            ["/usr/bin/git", "--no-optional-locks", *args],
            cwd=cwd,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            errors="replace",
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return ("timeout", "")
    except OSError:
        return ("err", "")
    return ("ok", result.stdout) if result.returncode == 0 else ("err", "")


def _refresh_pr_async(cwd, branch):
    key = (cwd, branch)
    env = os.environ.copy()
    env["PATH"] = f"/opt/homebrew/bin:/usr/local/bin:{env.get('PATH', '')}"
    pr_data = None
    try:
        res = subprocess.run(
            ["gh", "pr", "view", "--json", "number,state,url"],
            cwd=cwd,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=2.5,
        )
        if res.returncode == 0 and res.stdout.strip():
            raw = json.loads(res.stdout)
            num = raw.get("number")
            state = str(raw.get("state") or "").lower()
            url = str(raw.get("url") or "").strip()
            if num:
                pr_data = {
                    "number": num,
                    "state": state,
                    "url": url if url.startswith(("http://", "https://")) else "",
                }
    except subprocess.TimeoutExpired:
        pr_data = _PR_TIMEOUT
    except Exception:
        pr_data = None

    with _PR_LOCK:
        prev = _PR_CACHE.get(key)
        data = prev[1] if (pr_data is _PR_TIMEOUT and prev is not None) else (None if pr_data is _PR_TIMEOUT else pr_data)
        _PR_CACHE[key] = (time.monotonic(), data, False)
        _prune_cache(_PR_CACHE)


def get_cached_pr(cwd, branch):
    if not cwd or not branch:
        return None
    key = (cwd, branch)
    now = time.monotonic()
    with _PR_LOCK:
        entry = _PR_CACHE.get(key)
        if entry is None:
            _PR_CACHE[key] = (now, None, True)
            _prune_cache(_PR_CACHE)
            threading.Thread(
                target=_refresh_pr_async, args=(cwd, branch), daemon=True
            ).start()
            return None
        ts, data, inflight = entry
        if not inflight and (now - ts >= _PR_TTL_SEC):
            _PR_CACHE[key] = (ts, data, True)
            threading.Thread(
                target=_refresh_pr_async, args=(cwd, branch), daemon=True
            ).start()
        return data


def _resolve_git_path(cwd, raw_path):
    if not raw_path:
        return None
    return Path(raw_path) if os.path.isabs(raw_path) else (Path(cwd) / raw_path)


def _collect_git_details(cwd):
    status, out = _git_run(cwd, "status", "--porcelain=v2", "--branch", "-uno")
    if status == "timeout":
        return _GIT_TIMEOUT
    if status != "ok":
        return None

    oid = ""
    branch = ""
    upstream = ""
    ahead, behind = 0, 0
    dirty = False

    for line in out.splitlines():
        if line.startswith("# branch.oid "):
            oid = line[13:].strip()
        elif line.startswith("# branch.head "):
            branch = line[14:].strip()
        elif line.startswith("# branch.upstream "):
            upstream = line[18:].strip()
        elif line.startswith("# branch.ab "):
            parts = line[12:].split()
            if len(parts) >= 2:
                try:
                    ahead = max(0, int(parts[0]))
                    behind = abs(int(parts[1]))
                except ValueError:
                    pass
        elif line and not line.startswith("#"):
            dirty = True

    if branch == "(detached)":
        branch = oid[:7] if oid and oid != "(initial)" else ""
    if not branch:
        return None

    git_dir = None
    common_dir = None
    rp_status, rp_out = _git_run(cwd, "rev-parse", "--git-dir", "--git-common-dir")
    if rp_status == "ok":
        rp_lines = [ln.strip() for ln in rp_out.splitlines() if ln.strip()]
        if len(rp_lines) >= 1:
            git_dir = _resolve_git_path(cwd, rp_lines[0])
        if len(rp_lines) >= 2:
            common_dir = _resolve_git_path(cwd, rp_lines[1])
        else:
            common_dir = git_dir

    worktree = ""
    op = ""
    if git_dir:
        git_dir_str = str(git_dir).replace("\\", "/")
        if "/worktrees/" in git_dir_str:
            worktree = git_dir_str.split("/worktrees/", 1)[1].split("/", 1)[0]
        if (git_dir / "rebase-merge").is_dir() or (git_dir / "rebase-apply").is_dir():
            op = "REBASE"
        elif (git_dir / "MERGE_HEAD").is_file():
            op = "MERGING"
        elif (git_dir / "CHERRY_PICK_HEAD").is_file():
            op = "CHERRY-PICKING"
        elif (git_dir / "BISECT_LOG").is_file():
            op = "BISECTING"

    has_remote = bool(upstream)
    if not has_remote and common_dir:
        try:
            cfg = (common_dir / "config").read_text(encoding="utf-8", errors="replace")
            has_remote = "[remote " in cfg
        except OSError:
            pass

    added, removed = 0, 0
    if dirty and oid != "(initial)":
        diff_status, numstat = _git_run(cwd, "diff", "HEAD", "--numstat")
        if diff_status == "ok" and numstat:
            for line in numstat.splitlines():
                cols = line.split("\t")
                if len(cols) >= 2:
                    if cols[0].isdigit():
                        added += int(cols[0])
                    if cols[1].isdigit():
                        removed += int(cols[1])

    return {
        "branch": label(branch, 28),
        "raw_branch": branch,
        "dirty": dirty,
        "op": op,
        "ahead": ahead,
        "behind": behind,
        "worktree": worktree,
        "added": added,
        "removed": removed,
        "has_remote": has_remote,
    }


def _refresh_git_async(cwd, ready_event=None):
    try:
        result = _collect_git_details(cwd)
    except Exception:
        result = _GIT_TIMEOUT
    try:
        with _GIT_LOCK:
            prev = _GIT_CACHE.get(cwd)
            if result is _GIT_TIMEOUT:
                data = prev[1] if prev is not None else None
            else:
                data = result
            _GIT_CACHE[cwd] = (time.monotonic(), data, False, None)
            _prune_cache(_GIT_CACHE)
    finally:
        if ready_event is not None:
            ready_event.set()


def get_cached_git(cwd):
    if not cwd:
        return None
    now = time.monotonic()
    wait_event = None
    with _GIT_LOCK:
        entry = _GIT_CACHE.get(cwd)
        if entry is None:
            wait_event = threading.Event()
            _GIT_CACHE[cwd] = (0.0, None, True, wait_event)
            _prune_cache(_GIT_CACHE)
            threading.Thread(
                target=_refresh_git_async, args=(cwd, wait_event), daemon=True
            ).start()
        else:
            ts, data, inflight, _ = entry
            if not inflight and (now - ts >= _GIT_TTL_SEC):
                _GIT_CACHE[cwd] = (ts, data, True, None)
                threading.Thread(
                    target=_refresh_git_async, args=(cwd,), daemon=True
                ).start()
            return data

    wait_event.wait(_GIT_FIRST_WAIT_SEC)
    with _GIT_LOCK:
        entry = _GIT_CACHE.get(cwd)
        return entry[1] if entry is not None else None


def percentage(value):
    if isinstance(value, (int, float)) and math.isfinite(value):
        return min(100.0, max(0.0, float(value)))
    return None


def token_count(count):
    if count is None or not isinstance(count, (int, float)) or count < 0:
        return "0"
    # 220K, 1M, 1.5M (no trailing .0)
    for divisor, suffix in ((1_000_000, "M"), (1_000, "K")):
        if count >= divisor * (0.9995 if suffix == "M" else 1):
            value = round(count / divisor, 1 if suffix == "M" else None)
            return f"{value:g}{suffix}"
    return str(round(count))


def fmt_reset(seconds):
    if seconds is None or not isinstance(seconds, (int, float)) or seconds <= 0:
        return ""
    total_minutes = int(seconds // 60)
    days = total_minutes // 1440
    hours = (total_minutes % 1440) // 60
    minutes = total_minutes % 60
    if days > 0:
        return f"{days}d{hours}h" if hours else f"{days}d"
    if hours > 0:
        return f"{hours}h{minutes}m" if minutes else f"{hours}h"
    return f"{max(1, minutes)}m"


def context_color_for(pct):
    pct = pct or 0.0
    if pct >= 85.0:
        return CRIT_COLOR
    if pct >= 60.0:
        return WARN_COLOR
    return CONTEXT_COLOR


def pr_state_color(state):
    return {
        "open": OK_COLOR,
        "approved": OK_COLOR,
        "changes_requested": WARN_COLOR,
        "closed": CRIT_COLOR,
        "merged": MODEL_COLOR,
    }.get(str(state).lower(), META_COLOR)


def quota_color_for(used_pct):
    if used_pct >= 90.0:
        return CRIT_COLOR
    if used_pct >= 70.0:
        return WARN_COLOR
    return OK_COLOR


@lru_cache(maxsize=1)
def _load_models_window_map(_mtime_ns):
    cache_path = Path.home() / ".codex" / "models_cache.json"
    mapping = {}
    try:
        raw = json.loads(cache_path.read_text(encoding="utf-8"))
        for item in raw.get("models") or []:
            cw = item.get("context_window")
            if isinstance(cw, (int, float)) and cw > 0:
                eff_pct = item.get("effective_context_window_percent")
                if isinstance(eff_pct, (int, float)) and 0 < eff_pct <= 100:
                    eff_cw = int(round(cw * eff_pct / 100.0))
                else:
                    eff_cw = int(cw)
                for key in (item.get("slug"), item.get("id"), item.get("display_name")):
                    if key:
                        mapping[str(key).strip().lower()] = eff_cw
    except Exception:
        pass
    return mapping


def fallback_window_size(model):
    if not isinstance(model, dict):
        return None
    cache_path = Path.home() / ".codex" / "models_cache.json"
    try:
        mtime_ns = cache_path.stat().st_mtime_ns
    except OSError:
        mtime_ns = 0
    mapping = _load_models_window_map(mtime_ns)
    for key in (model.get("id"), model.get("display_name")):
        if key:
            found = mapping.get(str(key).strip().lower())
            if found:
                return found
    return None


def context_widget(context, model=None):
    window = context.get("context_window_size") or fallback_window_size(model)
    used = context.get("used_tokens")
    percent = percentage(context.get("used_percentage"))
    if percent is None and used is not None and window:
        percent = percentage(100.0 * used / window)
    if used is None and percent is not None and window:
        used = round(percent * window / 100.0)
    if used is None:
        used = 0
    if percent is None:
        percent = 0.0

    pct_val = percent
    filled = round(pct_val * BAR_WIDTH / 100.0)
    empty = BAR_WIDTH - filled
    col = context_color_for(pct_val)

    pct_str = f"{pct_val:.0f}%"
    detail = f"{token_count(used)}/{token_count(window)} ({pct_str})" if window else pct_str

    children = [text("Context: ", META_COLOR)]
    if filled > 0:
        children.append(text("▰" * filled, col))
    if empty > 0:
        children.append(text("▱" * empty, TRACK_COLOR))
    children.append(text(f" {detail}", col))
    return {"type": "text", "children": children}


def quota_widgets(account):
    rate_limits = account.get("rate_limits") or []
    codex = next(
        (item for item in rate_limits if item.get("limit_id") == "codex"),
        rate_limits[0] if rate_limits else {},
    )
    windows_by_duration = {}
    for key in ("primary_limit", "secondary_limit"):
        window = codex.get(key)
        if isinstance(window, dict) and window.get("window_minutes"):
            windows_by_duration[window["window_minutes"]] = window

    now = time.time()
    for name, duration in (("5h", 300), ("wk", 10_080)):
        window = windows_by_duration.get(duration)
        if not window:
            continue
        used = percentage(window.get("used_percent"))
        if used is None:
            continue
        col = quota_color_for(used)
        parts = [text(f"{name}: ", META_COLOR), text(f"{used:.0f}%", col)]
        resets_at = window.get("resets_at")
        if (
            used >= RESET_ABOVE_USED_PCT
            and isinstance(resets_at, (int, float))
            and resets_at > now
        ):
            rst = fmt_reset(resets_at - now)
            if rst:
                parts.append(text(f" ({rst})", col))
        yield {"type": "text", "children": parts}


def permission_badge(state):
    """Map Codex thread.permissions + thread.approval to the 4 /permissions presets."""
    thread = state.get("thread") or {}
    perms = thread.get("permissions") or state.get("permissions") or state.get("sandbox") or {}
    approval = thread.get("approval") or state.get("approval") or {}

    perm_type = str(perms.get("type") or "").strip().lower()
    perm_name = str(perms.get("display_name") or "").strip().lower()
    profile_id = str(perms.get("profile_id") or "").strip().lower()
    policy = str(approval.get("policy") or "").strip().lower()
    reviewer = str(approval.get("reviewer") or "").strip().lower()

    if (
        perm_type in ("disabled", "danger-full-access")
        or "no sandbox" in perm_name
        or "full access" in perm_name
        or profile_id in ("danger-full-access", "full-access")
        or policy == "never"
    ):
        return ("full-access", CRIT_COLOR)
    if (
        perm_type == "read-only"
        or "read only" in perm_name
        or "read-only" in perm_name
        or profile_id == "read-only"
    ):
        return ("read-only", WARN_COLOR)
    if reviewer == "auto-review":
        return ("auto-approve", OK_COLOR)
    if policy == "on-request":
        return ("ask", ASK_COLOR)
    if policy:
        return (policy, WARN_COLOR)
    if perm_name:
        return (label(perm_name, 16), WARN_COLOR)
    return None


def render(state):
    """Return the 2-row UI tree matching the Antigravity statusline style."""
    thread = state.get("thread") or {}
    model = thread.get("model") or {}
    name = label(model.get("display_name") or model.get("id") or "Codex", 28)
    if effort := model.get("reasoning_level"):
        effort_label = label(effort, 12).capitalize()
        if f"({effort_label.lower()})" not in name.lower():
            name += f" ({effort_label})"

    row1 = [text(name, MODEL_COLOR)]

    # Fast / Ultrafast service tier (ignore Normal / Standard / Default)
    tier_raw = (
        model.get("service_tier_display_name") or model.get("service_tier") or ""
    )
    tier = str(tier_raw).strip().lower()
    if tier and tier not in ("normal", "default", "standard", "none"):
        row1.extend([separator(), text(tier, WARN_COLOR)])

    # Model permissions preset (/permissions)
    perm = permission_badge(state)
    if perm:
        row1.extend([separator(), text(perm[0], perm[1])])

    cwd = (thread.get("workspace") or {}).get("cwd")
    if cwd:
        row1.extend([separator(), text(shorten_path(cwd, depth=2), META_COLOR)])
        git = get_cached_git(cwd)
        if git:
            git_children = [text(git["branch"], BRANCH_COLOR)]
            if git["dirty"]:
                git_children.append(text("*", DIRTY_COLOR))
            if git["op"]:
                git_children.append(text(f" {git['op']}", DIRTY_COLOR))
            sync_parts = []
            if git["ahead"] > 0:
                sync_parts.append(f"⇡{git['ahead']}")
            if git["behind"] > 0:
                sync_parts.append(f"⇣{git['behind']}")
            if sync_parts:
                git_children.append(text(" " + " ".join(sync_parts), BRANCH_COLOR))
            row1.extend([separator(), {"type": "text", "children": git_children}])

            if git["worktree"]:
                row1.extend([
                    separator(),
                    {"type": "text", "children": [text("wt: ", META_COLOR), text(git["worktree"], BRANCH_COLOR)]},
                ])

            if git["added"] > 0 or git["removed"] > 0:
                diff_children = []
                if git["added"] > 0:
                    diff_children.append(text(f"+{git['added']}", OK_COLOR))
                if git["removed"] > 0:
                    if diff_children:
                        diff_children.append(text(" ", META_COLOR))
                    diff_children.append(text(f"−{git['removed']}", CRIT_COLOR))
                row1.extend([separator(), {"type": "text", "children": diff_children}])

            pr = get_cached_pr(cwd, git["raw_branch"]) if git.get("has_remote") else None
            if pr:
                pr_label = f"PR #{pr['number']}"
                pr_node = (
                    {
                        "type": "link",
                        "props": {"href": pr["url"]},
                        "children": [text(pr_label, META_COLOR)],
                    }
                    if pr.get("url")
                    else text(pr_label, META_COLOR)
                )
                pr_children = [pr_node]
                if pr.get("state"):
                    pr_children.append(text(f" ({pr['state']})", pr_state_color(pr["state"])))
                row1.extend([separator(), {"type": "text", "children": pr_children}])

    context = (thread.get("usage") or {}).get("context") or {}
    row2 = [context_widget(context, model)]
    for q_widget in quota_widgets(state.get("account") or {}):
        row2.extend([separator(), q_widget])

    return {"type": "text", "children": [*row1, "\n", *row2]}


def respond(method, params):
    if method == "initialize":
        return {
            "protocolVersion": "2025-06-18",
            "capabilities": {"tools": {}, "resources": {}},
            "serverInfo": {"name": SERVER, "version": "1.0"},
        }
    if method == "ping":
        return {}
    if method == "tools/list":
        return {"tools": [TOOL]}
    if method == "tools/call":
        if params.get("name") != TOOL["name"]:
            raise ValueError("Unknown tool name")
        return {
            "content": [{"type": "text", "text": f"The statusline resource is {URI}."}]
        }
    if method == "resources/list":
        return {
            "resources": [
                {"name": "footer", "uri": URI, "mimeType": "application/json"}
            ]
        }
    if method == "resources/templates/list":
        return {"resourceTemplates": []}
    if method == "resources/read":
        if params.get("uri") != URI:
            raise ValueError("Unknown resource URI")
        state = params.get("_meta", {}).get("com.openai/codex-statusline-state", {})
        return {
            "contents": [
                {
                    "uri": URI,
                    "mimeType": "application/json",
                    "text": json.dumps(render(state), ensure_ascii=False),
                }
            ]
        }
    raise KeyError(method)


def install(codex):
    """Register and select the provider through Codex's atomic config writer."""
    values = {
        "features.tui_extensions_statusline": True,
        "mcp_servers." + SERVER: {
            "command": "/usr/bin/python3",
            "args": ["-u", str(Path(__file__).absolute())],
        },
        "tui.status_line_provider": {"server": SERVER, "tool": TOOL["name"]},
    }
    edits = [
        {"keyPath": key, "value": value, "mergeStrategy": "replace"}
        for key, value in values.items()
    ]
    with subprocess.Popen(
        [codex, "app-server", "--listen", "stdio://"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True,
    ) as server:
        timeout = threading.Timer(20, server.kill)
        timeout.start()

        def request(method, params=None, request_id=None):
            message = {"jsonrpc": "2.0", "method": method}
            if params is not None:
                message["params"] = params
            if request_id is not None:
                message["id"] = request_id
            server.stdin.write(json.dumps(message) + "\n")
            server.stdin.flush()
            if request_id is None:
                return
            for line in server.stdout:
                reply = json.loads(line)
                if reply.get("id") == request_id:
                    if error := reply.get("error"):
                        raise SystemExit(f"Codex {method}: {error['message']}")
                    return
            raise SystemExit(f"Codex exited or timed out during {method}")

        try:
            request("initialize", {"clientInfo": {"name": "dotfiles", "version": "1.0"}}, 1)
            request("initialized")
            request("config/batchWrite", {"edits": edits}, 2)
        finally:
            timeout.cancel()
            server.terminate()


def main():
    for line in sys.stdin.buffer:
        reply = {"jsonrpc": "2.0", "id": None}
        try:
            request = json.loads(line)
            if not isinstance(request, dict) or not isinstance(
                request.get("method"), str
            ):
                reply["error"] = {"code": -32600, "message": "Invalid request"}
            elif "id" not in request:
                continue
            else:
                reply["id"] = request["id"]
                reply["result"] = respond(request["method"], request.get("params", {}))
        except json.JSONDecodeError:
            reply["error"] = {"code": -32700, "message": "Parse error"}
        except KeyError:
            reply["error"] = {"code": -32601, "message": "Method not found"}
        except (TypeError, ValueError, AttributeError):
            reply["error"] = {"code": -32602, "message": "Invalid parameters"}
        print(json.dumps(reply), flush=True)


if __name__ == "__main__":
    if sys.argv[1:2] == ["--install"]:
        install(sys.argv[2] if len(sys.argv) > 2 else "codex")
    else:
        main()
