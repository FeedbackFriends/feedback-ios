#!/bin/sh
mkdir -p "$CI_WORKSPACE/App/Config"
echo "SENTRY_DSN_URL = ${SENTRY_DSN_URL}" > "$CI_WORKSPACE/Configs/secrets.xcconfig"
echo "API_BASE_URL = ${API_BASE_URL}" >> "$CI_WORKSPACE/Configs/secrets.xcconfig"
