#!/bin/bash

# Function to present a list to the user for selection using fzf
select_from_list() {
  local input_list="$1"
  if [[ -z "$input_list" ]]; then
    return 1
  fi
  echo -e "$input_list" | fzf
}
