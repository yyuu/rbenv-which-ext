if ! command -v expand_path >/dev/null 2>&1; then
  expand_path() {
    if [ ! -d "$1" ]; then
      return 1
    fi

    local cwd="$(pwd)"
    cd "$1"
    pwd
    cd "$cwd"
  }
fi

if ! command -v remove_from_path >/dev/null 2>&1; then
  remove_from_path() {
    local path_to_remove="$(expand_path "$1")"
    local result=""

    if [ -z "$path_to_remove" ]; then
      echo "${PATH}"
      return
    fi

    local paths
    IFS=: paths=($PATH)

    for path in "${paths[@]}"; do
      path="$(expand_path "$path" || true)"
      if [ -n "$path" ] && [ "$path" != "$path_to_remove" ]; then
        result="${result}${path}:"
      fi
    done

    echo "${result%:}"
  }
fi

lookup_from_path() {
  local command_to_lookup="$1"
  local original_path="${PATH}"
  PATH="$(remove_from_path "${RBENV_ROOT}/shims")"
  local result="$(command -v "$command_to_lookup" || true)"
  PATH="${original_path}"
  echo $result
}

# If the "$RBENV_COMMAND_PATH" does not exist,
if [ -n "$RBENV_COMMAND" ] && [ ! -x "$RBENV_COMMAND_PATH" ]; then
  RBENV_COMMAND_PATH="$(lookup_from_path "$RBENV_COMMAND" || true)"
fi
