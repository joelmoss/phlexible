#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Only lint Ruby files
if [[ "$FILE_PATH" != *.rb ]]; then
  exit 0
fi

RESULT=$(bundle exec rubocop -P --fail-level C --force-exclusion "$FILE_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "$RESULT" >&2
  exit 2
fi

exit 0
