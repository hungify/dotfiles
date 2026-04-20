export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
export EDITOR="${EDITOR:-zed --wait}"
export VISUAL="${VISUAL:-$EDITOR}"

for dir in \
  /opt/homebrew/bin \
  /opt/homebrew/sbin \
  /usr/local/bin \
  /usr/local/sbin \
  "$PNPM_HOME" \
  "/usr/local/opt/openjdk@17/bin" \
  "/opt/homebrew/opt/mysql-client/bin" \
  "$HOME/Library/Python/3.9/bin" \
  "$ANDROID_HOME/tools" \
  "$ANDROID_HOME/tools/bin" \
  "$ANDROID_HOME/platform-tools" \
  "$ANDROID_HOME/emulator" \
  "$ANDROID_HOME/cmdline-tools/latest/bin"
do
  [[ -d "$dir" ]] && extra_path+=("$dir")
done
