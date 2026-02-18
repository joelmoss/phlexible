#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Block edits to lock files and generated gemfiles
if [[ "$FILE_PATH" == *.lock ]] || [[ "$FILE_PATH" == */gemfiles/*.gemfile ]]; then
  echo "Do not edit lock files or generated Appraisal gemfiles directly." >&2
  exit 2
fi

exit 0
