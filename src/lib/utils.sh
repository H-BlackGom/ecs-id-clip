#!/bin/bash

# Function to check for required command-line tools
check_prerequisites() {
  local missing_tools=()
  for tool in "$@"; do
    if ! command -v "$tool" &> /dev/null; then
      missing_tools+=("$tool")
    fi
  done

  if [ ${#missing_tools[@]} -gt 0 ]; then
    echo "Error: The following required tools are not installed or not in your PATH:" >&2
    for tool in "${missing_tools[@]}"; do
      echo " - $tool" >&2
    done
    exit 1
  fi
}

# Function to copy text to the clipboard, supporting macOS and Linux
copy_to_clipboard() {
  local text_to_copy="$1"
  if [[ -z "$text_to_copy" ]]; then
    return 1
  fi

  if [[ "$(uname)" == "Darwin" ]]; then
    echo -n "$text_to_copy" | pbcopy
  elif command -v xclip &> /dev/null; then
    echo -n "$text_to_copy" | xclip -selection clipboard
  elif command -v xsel &> /dev/null; then
    echo -n "$text_to_copy" | xsel --clipboard --input
  else
    echo "Error: Could not find a clipboard tool (pbcopy, xclip, or xsel)." >&2
    return 1
  fi
}
