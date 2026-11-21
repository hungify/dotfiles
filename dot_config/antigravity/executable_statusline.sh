#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

INPUT="$(cat)"
[[ -z "${INPUT//[[:space:]]/}" ]] && exit 0

# Dark Tokyo Night truecolor palette
RESET=$'\x1b[0m'
SEP=" "$'\x1b[2m|\x1b[0m'" "
C_MODEL=$'\x1b[38;2;187;154;247m' # #bb9af7 (Purple)
C_META=$'\x1b[38;2;169;177;214m'  # #a9b1d6 (Foreground/Meta)
C_TRACK=$'\x1b[38;2;65;72;104m'   # #414868 (Dim empty bar track)
C_GIT=$'\x1b[38;2;115;218;202m'   # #73daca (Teal)
C_DIRTY=$'\x1b[38;2;255;139;82m'  # #ff8b52 (Orange)
C_CTX=$'\x1b[38;2;122;162;247m'   # #7aa2f7 (Blue)
C_ASK=$'\x1b[38;2;125;207;255m'   # #7dcfff (Cyan)
C_OK=$'\x1b[38;2;158;206;106m'    # #9ece6a (Green)
C_WARN=$'\x1b[38;2;224;175;104m'  # #e0af68 (Yellow)
C_CRIT=$'\x1b[38;2;247;118;142m'  # #f7768e (Red)

NOW_EPOCH="$(date +%s)"

# Single-pass jq extraction & formatting
{
  IFS= read -r MODEL
  IFS= read -r MODE_TEXT
  IFS= read -r MODE_KEY
  IFS= read -r VIM_MODE
  IFS= read -r TASKS_TEXT
  IFS= read -r RAW_CWD
  IFS= read -r CWD_TEXT
  IFS= read -r BRANCH
  IFS= read -r DIRTY
  IFS= read -r HAS_CTX
  IFS= read -r CTX_LEVEL
  IFS= read -r CTX_FILLED
  IFS= read -r CTX_EMPTY
  IFS= read -r CTX_INFO
  IFS= read -r HAS_5H
  IFS= read -r FH_LEVEL
  IFS= read -r FH_PCT
  IFS= read -r FH_RESET
  IFS= read -r HAS_WK
  IFS= read -r WK_LEVEL
  IFS= read -r WK_PCT
  IFS= read -r WK_RESET
  IFS= read -r HAS_ARGON
  IFS= read -r ARGON_LEVEL
  IFS= read -r ARGON_PCT
  IFS= read -r ARGON_RESET
} < <(jq -r --arg home "$HOME" --argjson now "$NOW_EPOCH" '
  def fmt_pct: (. | round | tostring) + "%";

  # 220K, 1M, 1.5M (no trailing .0)
  def fmt_tokens:
    if . >= 999500 then (((. / 100000) | round) / 10 | tostring) + "M"
    elif . >= 1000 then ((. / 1000) | round | tostring) + "K"
    else (. | round | tostring) end;

  def fmt_reset:
    if . <= 0 then "now"
    else
      ((. / 60) | floor) as $m |
      (($m / 1440) | floor) as $d |
      ((($m % 1440) / 60) | floor) as $h |
      ($m % 60) as $min |
      if $d > 0 then "\($d)d\(if $h > 0 then "\($h)h" else "" end)"
      elif $h > 0 then "\($h)h\(if $min > 0 then "\($min)m" else "" end)"
      else "\([1, $min] | max)m" end
    end;

  def shorten_path($depth):
    if . == "" then ""
    else
      (if . == $home then "~"
       elif startswith($home + "/") then "~" + .[(($home | length)):]
       else . end) as $p |
      if ($p | startswith("~/")) then
        ($p[2:] | split("/") | map(select(length > 0))) as $parts |
        if ($parts | length) <= $depth then $p
        else "~/…/" + ($parts[-$depth:] | join("/")) end
      elif ($p | startswith("/")) then
        ($p[1:] | split("/") | map(select(length > 0))) as $parts |
        if ($parts | length) <= $depth then $p
        else "/…/" + ($parts[-$depth:] | join("/")) end
      else $p end
    end;

  def parse_quota($q):
    if ($q | type) != "object" or ($q.remaining_fraction == null) or ($q.disabled == true) then
      ["false", "ok", "", ""]
    else
      (100 - ([0, ([100, (($q.remaining_fraction | tonumber) * 100)] | min)] | max)) as $used |
      (if ($q.reset_in_seconds // 0) > 0 then ($q.reset_in_seconds | tonumber)
       elif ($q.reset_time // "") != "" then (([$q.reset_time | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601 - $now, 0] | max) // 0)
       else 0 end) as $sec |
      (if $used >= 90 then "crit" elif $used >= 70 then "warn" else "ok" end) as $lvl |
      ($used | fmt_pct) as $pct |
      (if $sec > 0 and $used >= 60 then ($sec | fmt_reset) else "" end) as $rst |
      ["true", $lvl, $pct, $rst]
    end;

  ((.model.display_name // .model.id // "") | tostring) as $model |
  ($model | ascii_downcase) as $model_lc |
  ($model_lc | startswith("gemini") | not) as $is_3p |
  ($model_lc | contains("argon")) as $is_argon |

  $model,
  ((.cycle_mode // "") | if . == "" then "default" else . end),
  ((.cycle_mode // "") | if . == "" then "default" else ascii_downcase end),
  ((.vim.mode // "") | tostring),
  (
    ([.subagents[]? | select(.status == "running")] | length) as $sa |
    ((.task_count // 0) | floor) as $tc |
    [
      (if $sa > 0 then "\($sa) \(if $sa == 1 then "subagent" else "subagents" end)" else empty end),
      (if $tc > 0 then "\($tc) \(if $tc == 1 then "task" else "tasks" end)" else empty end)
    ] | join(", ")
  ),
  ((.cwd // .workspace.current_dir // "") | tostring),
  (((.cwd // .workspace.current_dir // "") | tostring) | shorten_path(2)),
  ((.vcs.branch // "") | tostring),
  (if .vcs.dirty == true then "true" else "false" end),
  (if (.context_window | type) == "object" then "true" else "false" end),
  (
    if (.context_window | type) == "object" then
      (.context_window.context_window_size // 0) as $size |
      (.context_window.current_usage // {}) as $cu |
      (($cu.input_tokens // 0) + ($cu.cache_creation_input_tokens // 0) + ($cu.cache_read_input_tokens // 0)) as $cu_sum |
      (if .context_window.used_percentage != null then (.context_window.used_percentage | tonumber)
       elif .context_window.remaining_percentage != null then (100 - (.context_window.remaining_percentage | tonumber))
       elif $size > 0 then (($cu_sum * 100) / $size)
       else 0 end) as $pct |
      ([0, ([100, $pct] | min)] | max) as $clamped |
      (if $size > 0 then (($clamped * $size / 100) | round) else $cu_sum end) as $used |
      (($clamped * 12 / 100) | round) as $filled |
      (if $clamped >= 85 then "crit"
       elif $clamped >= 60 then "warn"
       else "ok" end),
      ("▰" * $filled),
      ("▱" * (12 - $filled)),
      (if $size > 0 then ($used | fmt_tokens) + "/" + ($size | fmt_tokens) + " (" + ($clamped | fmt_pct) + ")" else ($clamped | fmt_pct) end)
    else
      "ok", "", "", ""
    end
  ),
  (parse_quota(if $is_3p and (.quota["3p-5h"] != null) then .quota["3p-5h"] else .quota["gemini-5h"] end)[]),
  (parse_quota(if $is_3p and (.quota["3p-weekly"] != null) then .quota["3p-weekly"] else .quota["gemini-weekly"] end)[]),
  (if $is_argon then parse_quota(.quota["gemini-argon-wtu-weekly"])[] else "false", "ok", "", "" end)
' <<< "$INPUT")

# Row 1 assembly
# PR: "PR #N" stays meta (clickable), "(state)" colored by meaning
render_pr() {
  local t="$1" link state col
  if [[ "$t" =~ ^(.*)\ \(([a-z_]+)\)$ ]]; then
    link="${BASH_REMATCH[1]}"; state="${BASH_REMATCH[2]}"
  else
    link="$t"; state=""
  fi
  case "$state" in
    open|approved)     col="$C_OK" ;;
    changes_requested) col="$C_WARN" ;;
    closed)            col="$C_CRIT" ;;
    merged)            col="$C_MODEL" ;;
    *)                 col="$C_META" ;;
  esac
  printf '%s' "${C_META}${link}${RESET}"
  [[ -n "$state" ]] && printf '%s' " ${col}(${state})${RESET}"
  return 0
}

ROW1_PARTS=()

if [[ -n "$MODEL" ]]; then
  ROW1_PARTS+=("${C_MODEL}${MODEL}${RESET}")
fi

if [[ -n "$MODE_TEXT" ]]; then
  case "$MODE_KEY" in
    auto)                             C_MODE="$C_OK" ;;
    default)                          C_MODE="$C_ASK" ;;
    accept-edits)                     C_MODE="$C_CTX" ;;
    plan)                             C_MODE="$C_WARN" ;;
    turbo|always-proceed|yolo|bypass*) C_MODE="$C_CRIT" ;;
    *)                                C_MODE="$C_WARN" ;;
  esac
  ROW1_PARTS+=("${C_MODE}${MODE_TEXT}${RESET}")
fi

# Detect Tool Permission override (--dangerously-skip-permissions or settings.json toolPermission)
TOOL_PERM=""
PARENT_ARGS="$(ps -o args= -p "$PPID" 2>/dev/null || true)"
GPPID="$(ps -o ppid= -p "$PPID" 2>/dev/null | tr -d '[:space:]' || true)"
GPARENT_ARGS=""
if [[ -n "$GPPID" && "$GPPID" =~ ^[0-9]+$ ]]; then
  GPARENT_ARGS="$(ps -o args= -p "$GPPID" 2>/dev/null || true)"
fi
if [[ "$PARENT_ARGS" == *"--dangerously-skip-permissions"* || "$GPARENT_ARGS" == *"--dangerously-skip-permissions"* ]]; then
  TOOL_PERM="always-proceed"
else
  AGY_SETTINGS="${HOME}/.gemini/antigravity-cli/settings.json"
  if [[ -f "$AGY_SETTINGS" ]] && grep -q '"toolPermission"' "$AGY_SETTINGS" 2>/dev/null; then
    TOOL_PERM="$(jq -r '.toolPermission // ""' "$AGY_SETTINGS" 2>/dev/null || true)"
  fi
fi

case "$TOOL_PERM" in
  always-proceed)
    ROW1_PARTS+=("${C_CRIT}turbo${RESET}")
    ;;
  strict)
    ROW1_PARTS+=("${C_WARN}strict${RESET}")
    ;;
  proceed-in-sandbox)
    if [[ "$MODE_KEY" != "auto" ]]; then
      ROW1_PARTS+=("${C_CTX}proceed-in-sandbox${RESET}")
    fi
    ;;
  request-review)
    if [[ "$MODE_KEY" != "auto" ]]; then
      ROW1_PARTS+=("${C_ASK}request-review${RESET}")
    fi
    ;;
esac

if [[ -n "$CWD_TEXT" ]]; then
  ROW1_PARTS+=("${C_META}${CWD_TEXT}${RESET}")
fi

# Bounded command runner + stale-while-revalidate Git cache (3s TTL per CWD)
run_with_timeout() {
  local sec="$1"; shift
  perl -e 'alarm shift; exec @ARGV' "$sec" "$@"
}

hash16() {
  local h
  if [[ -x /sbin/md5 ]]; then
    h="$(/sbin/md5 -qs "$1")"
  else
    h="$(printf '%s' "$1" | shasum -a 256)"
  fi
  printf '%s' "${h:0:16}"
}

refresh_git_cache() {
  local cwd="$1" cache_file="$2" tmp_file="${2}.$$.tmp"
  local porcelain rc=0 oid="" head="" upstream="" branch="" dirty="false"
  local op="" sync="" wt="" added="0" removed="0" has_remote="false"
  local git_dir="" common_dir="" line ab ahead_raw behind_raw ahead behind

  porcelain="$(run_with_timeout 3 git --no-optional-locks -C "$cwd" status --porcelain=v2 --branch -uno 2>/dev/null)" || rc=$?
  if (( rc == 142 )); then
    return 0
  fi
  if (( rc != 0 )) || [[ -z "$porcelain" ]]; then
    printf '0\n\nfalse\n\n\n\n0\n0\nfalse\n' > "$tmp_file" && mv -f "$tmp_file" "$cache_file"
    return 0
  fi

  while IFS= read -r line; do
    case "$line" in
      "# branch.oid "*)      oid="${line#\# branch.oid }" ;;
      "# branch.head "*)     head="${line#\# branch.head }" ;;
      "# branch.upstream "*) upstream="${line#\# branch.upstream }" ;;
      "# branch.ab "*)
        ab="${line#\# branch.ab }"
        read -r ahead_raw behind_raw <<< "$ab"
        ahead="${ahead_raw#+}"
        behind="${behind_raw#-}"
        local sync_parts=()
        (( ${ahead:-0} > 0 )) && sync_parts+=("⇡${ahead}")
        (( ${behind:-0} > 0 )) && sync_parts+=("⇣${behind}")
        (( ${#sync_parts[@]} > 0 )) && sync=" ${sync_parts[*]}"
        ;;
      "#"*|"") ;;
      *) dirty="true" ;;
    esac
  done <<< "$porcelain"

  if [[ "$head" == "(detached)" ]]; then
    [[ -n "$oid" && "$oid" != "(initial)" ]] && branch="${oid:0:7}"
  elif [[ -n "$head" ]]; then
    branch="$head"
  fi

  if [[ -z "$branch" ]]; then
    printf '0\n\nfalse\n\n\n\n0\n0\nfalse\n' > "$tmp_file" && mv -f "$tmp_file" "$cache_file"
    return 0
  fi

  {
    IFS= read -r git_dir || true
    IFS= read -r common_dir || true
  } < <(run_with_timeout 2 git --no-optional-locks -C "$cwd" rev-parse --git-dir --git-common-dir 2>/dev/null || true)

  if [[ -n "$git_dir" ]]; then
    [[ "$git_dir" != /* ]] && git_dir="$cwd/$git_dir"
    if [[ "$git_dir" == *"/worktrees/"* ]]; then
      wt="${git_dir##*/worktrees/}"
      wt="${wt%%/*}"
    fi
    if [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]; then
      op=" REBASE"
    elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
      op=" MERGING"
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
      op=" CHERRY-PICKING"
    elif [[ -f "$git_dir/BISECT_LOG" ]]; then
      op=" BISECTING"
    fi
  fi

  if [[ -n "$upstream" ]]; then
    has_remote="true"
  else
    [[ -z "$common_dir" ]] && common_dir="$git_dir"
    [[ -n "$common_dir" && "$common_dir" != /* ]] && common_dir="$cwd/$common_dir"
    if [[ -n "$common_dir" && -f "$common_dir/config" ]] && grep -q '^\[remote ' "$common_dir/config" 2>/dev/null; then
      has_remote="true"
    fi
  fi

  if [[ "$dirty" == "true" && "$oid" != "(initial)" ]]; then
    read -r added removed < <(
      (run_with_timeout 2 git --no-optional-locks -C "$cwd" diff HEAD --numstat 2>/dev/null || true) |
        awk '{ if ($1 ~ /^[0-9]+$/) a += $1; if ($2 ~ /^[0-9]+$/) r += $2 } END { printf "%d %d\n", a, r }'
    )
  fi

  printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
    "1" "$branch" "$dirty" "$op" "$sync" "$wt" "${added:-0}" "${removed:-0}" "$has_remote" \
    > "$tmp_file" && mv -f "$tmp_file" "$cache_file"
}

# Git & Worktree & Operation & Diff & PR
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/antigravity-statusline"
RAW_BRANCH="$BRANCH"
GIT_WORKTREE=""
GIT_CHANGES=""
GIT_SYNC=""
GIT_OP=""
GIT_HAS_REMOTE="false"
if [[ -n "$RAW_CWD" && -d "$RAW_CWD" ]]; then
  mkdir -p "$CACHE_DIR"
  GIT_CACHE_FILE="$CACHE_DIR/git-$(hash16 "$RAW_CWD")"
  NEED_GIT_REFRESH="false"
  COLD_GIT="false"
  if [[ -f "$GIT_CACHE_FILE" ]]; then
    GIT_MTIME="$(stat -f %m "$GIT_CACHE_FILE" 2>/dev/null || echo 0)"
    if (( NOW_EPOCH - GIT_MTIME >= 3 )); then
      NEED_GIT_REFRESH="true"
    fi
  else
    NEED_GIT_REFRESH="true"
    COLD_GIT="true"
  fi
  if [[ "$NEED_GIT_REFRESH" == "true" ]]; then
    touch "$GIT_CACHE_FILE"
    ( refresh_git_cache "$RAW_CWD" "$GIT_CACHE_FILE" ) </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null || true
    if [[ "$COLD_GIT" == "true" ]]; then
      for _ in 1 2 3 4 5 6 7 8; do
        [[ -s "$GIT_CACHE_FILE" ]] && break
        sleep 0.025
      done
    fi
  fi
  if [[ -s "$GIT_CACHE_FILE" ]]; then
    IS_GIT="0"
    CACHED_BRANCH=""
    CACHED_DIRTY="false"
    CACHED_OP=""
    CACHED_SYNC=""
    CACHED_WT=""
    ADDED="0"
    REMOVED="0"
    CACHED_REMOTE="false"
    {
      IFS= read -r IS_GIT || true
      IFS= read -r CACHED_BRANCH || true
      IFS= read -r CACHED_DIRTY || true
      IFS= read -r CACHED_OP || true
      IFS= read -r CACHED_SYNC || true
      IFS= read -r CACHED_WT || true
      IFS= read -r ADDED || true
      IFS= read -r REMOVED || true
      IFS= read -r CACHED_REMOTE || true
    } < "$GIT_CACHE_FILE"
    if [[ "$IS_GIT" == "1" && -n "$CACHED_BRANCH" ]]; then
      [[ -z "$BRANCH" ]] && BRANCH="$CACHED_BRANCH"
      RAW_BRANCH="$CACHED_BRANCH"
      [[ "$CACHED_DIRTY" == "true" ]] && DIRTY="true"
      GIT_OP="$CACHED_OP"
      GIT_SYNC="$CACHED_SYNC"
      GIT_WORKTREE="$CACHED_WT"
      GIT_HAS_REMOTE="$CACHED_REMOTE"
      CHANGE_PARTS=()
      (( ${ADDED:-0} > 0 )) && CHANGE_PARTS+=("${C_OK}+${ADDED}")
      (( ${REMOVED:-0} > 0 )) && CHANGE_PARTS+=("${C_CRIT}−${REMOVED}")
      if (( ${#CHANGE_PARTS[@]} > 0 )); then
        IFS=' ' eval 'GIT_CHANGES="${C_GIT}${CHANGE_PARTS[*]}${RESET}"'
      fi
    fi
  fi
fi

if [[ -n "$BRANCH" ]]; then
  if (( ${#BRANCH} > 28 )); then
    BRANCH="${BRANCH:0:27}…"
  fi
  DIRTY_MARK=""
  [[ "$DIRTY" == "true" ]] && DIRTY_MARK="${C_DIRTY}*"
  OP_MARK=""
  [[ -n "$GIT_OP" ]] && OP_MARK="${C_DIRTY}${GIT_OP}"
  SYNC_MARK=""
  [[ -n "$GIT_SYNC" ]] && SYNC_MARK="${C_GIT}${GIT_SYNC}"
  ROW1_PARTS+=("${C_GIT}${BRANCH}${DIRTY_MARK}${OP_MARK}${SYNC_MARK}${RESET}")
fi

if [[ -n "$GIT_WORKTREE" ]]; then
  ROW1_PARTS+=("${C_META}wt: ${C_GIT}${GIT_WORKTREE}${RESET}")
fi

if [[ -n "$GIT_CHANGES" ]]; then
  ROW1_PARTS+=("$GIT_CHANGES")
fi

# Non-blocking (stale-while-revalidate) GitHub PR check (30s TTL per CWD+branch)
if [[ "$GIT_HAS_REMOTE" == "true" && -n "$RAW_BRANCH" && -n "$RAW_CWD" && -d "$RAW_CWD" ]] && command -v gh >/dev/null 2>&1; then
  mkdir -p "$CACHE_DIR"
  CWD_HASH="$(hash16 "${RAW_CWD}:${RAW_BRANCH}")"
  CACHE_FILE="$CACHE_DIR/pr-${CWD_HASH}"
  PR_TEXT=""
  NEED_REFRESH="false"
  if [[ -f "$CACHE_FILE" ]]; then
    PR_TEXT="$(cat "$CACHE_FILE" 2>/dev/null || true)"
    FILE_MTIME="$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)"
    if (( NOW_EPOCH - FILE_MTIME >= 30 )); then
      NEED_REFRESH="true"
    fi
  else
    NEED_REFRESH="true"
  fi
  if [[ "$NEED_REFRESH" == "true" ]]; then
    # Touch first to prevent 300ms refresh stampedes while gh is in flight
    touch "$CACHE_FILE"
    (
      TMP_FILE="${CACHE_FILE}.$$.tmp"
      if NEW_PR="$(cd "$RAW_CWD" && run_with_timeout 3 gh pr view --json number,state,url --jq '"\u001b]8;;\(.url)\u001b\\PR #\(.number)\u001b]8;;\u001b\\ (\(.state | ascii_downcase))"' 2>&1)"; then
        printf '%s' "$NEW_PR" > "$TMP_FILE" && mv -f "$TMP_FILE" "$CACHE_FILE"
      elif [[ "$NEW_PR" == *"no pull requests found"* ]]; then
        : > "$TMP_FILE" && mv -f "$TMP_FILE" "$CACHE_FILE"
      fi
    ) </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null || true
  fi
  if [[ -n "$PR_TEXT" ]]; then
    ROW1_PARTS+=("$(render_pr "$PR_TEXT")")
  fi
fi

# Transient / dynamic state at the far right so CWD & branch never jump horizontally
if [[ -n "$TASKS_TEXT" ]]; then
  ROW1_PARTS+=("${C_META}${TASKS_TEXT}${RESET}")
fi

if [[ -n "$VIM_MODE" ]]; then
  ROW1_PARTS+=("${C_META}${VIM_MODE}${RESET}")
fi

# Row 2 assembly
ROW2_PARTS=()

if [[ "$HAS_CTX" == "true" ]]; then
  case "$CTX_LEVEL" in
    crit) C_CUR_CTX="$C_CRIT" ;;
    warn) C_CUR_CTX="$C_WARN" ;;
    *)    C_CUR_CTX="$C_CTX" ;;
  esac
  ROW2_PARTS+=("${C_META}Context: ${C_CUR_CTX}${CTX_FILLED}${C_TRACK}${CTX_EMPTY}${RESET} ${C_CUR_CTX}${CTX_INFO}${RESET}")
fi

if [[ "$HAS_5H" == "true" ]]; then
  case "$FH_LEVEL" in
    crit) C_CUR_FH="$C_CRIT" ;;
    warn) C_CUR_FH="$C_WARN" ;;
    *)    C_CUR_FH="$C_OK" ;;
  esac
  FH_RST_STR=""
  [[ -n "$FH_RESET" ]] && FH_RST_STR=" (${FH_RESET})"
  ROW2_PARTS+=("${C_META}5h: ${C_CUR_FH}${FH_PCT}${FH_RST_STR}${RESET}")
fi

if [[ "$HAS_WK" == "true" ]]; then
  case "$WK_LEVEL" in
    crit) C_CUR_WK="$C_CRIT" ;;
    warn) C_CUR_WK="$C_WARN" ;;
    *)    C_CUR_WK="$C_OK" ;;
  esac
  WK_RST_STR=""
  [[ -n "$WK_RESET" ]] && WK_RST_STR=" (${WK_RESET})"
  ROW2_PARTS+=("${C_META}wk: ${C_CUR_WK}${WK_PCT}${WK_RST_STR}${RESET}")
fi

if [[ "$HAS_ARGON" == "true" ]]; then
  case "$ARGON_LEVEL" in
    crit) C_CUR_AR="$C_CRIT" ;;
    warn) C_CUR_AR="$C_WARN" ;;
    *)    C_CUR_AR="$C_OK" ;;
  esac
  AR_RST_STR=""
  [[ -n "$ARGON_RESET" ]] && AR_RST_STR=" (${ARGON_RESET})"
  ROW2_PARTS+=("${C_META}argon: ${C_CUR_AR}${ARGON_PCT}${AR_RST_STR}${RESET}")
fi

join_by_sep() {
  local out=""
  local i
  for (( i = 0; i < $#; i++ )); do
    local idx=$(( i + 1 ))
    if (( i > 0 )); then
      out+="$SEP"
    fi
    out+="${!idx}"
  done
  printf '%s' "$out"
}

if (( ${#ROW1_PARTS[@]} > 0 )); then
  join_by_sep "${ROW1_PARTS[@]}"
  printf '\n'
fi

if (( ${#ROW2_PARTS[@]} > 0 )); then
  join_by_sep "${ROW2_PARTS[@]}"
  printf '%s' "$RESET"
fi
