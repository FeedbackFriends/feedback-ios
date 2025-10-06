#!/bin/sh
set -euo pipefail

# This script is responsible for uploading debug symbols and source context for Sentry.
if [[ "${CI_XCODE:-false}" != "true" ]]; then
  echo "Not running in Xcode Cloud, skipping Sentry dSYM upload."
  exit 0
fi

if ! command -v sentry-cli >/dev/null 2>&1; then
  echo "sentry-cli not found, installing..."
  curl -sL https://sentry.io/get-cli/ | bash
fi

if which sentry-cli >/dev/null; then
  ERROR=$(sentry-cli debug-files upload --include-sources "$DWARF_DSYM_FOLDER_PATH" 2>&1 >/dev/null)
  if [ ! $? -eq 0 ]; then
    echo "warning: sentry-cli - $ERROR"
  fi
else
  echo "warning: sentry-cli not installed, download from https://github.com/getsentry/sentry-cli/releases"
fi
