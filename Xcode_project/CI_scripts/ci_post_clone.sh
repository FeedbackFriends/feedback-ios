#!/bin/sh
set -euo pipefail

# Xcode Cloud environment setup
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

# Require key env vars (will fail fast with a clear message if missing)
: "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"
: "${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is required}"
: "${CI_BRANCH:=main}"

# Get version from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" \
  "$CI_PRIMARY_REPOSITORY_PATH/Xcode_project/App/InfoPlist/Info.plist")

# Read build number from env
BUILD="${CI_BUILD_NUMBER}"

TAG="${VERSION}(${BUILD})"

echo "Creating tag: $TAG"

cd "$CI_PRIMARY_REPOSITORY_PATH"

# Configure git (Xcode Cloud checkouts are detached)
git config user.email "ci@xcodecloud.apple.com"
git config user.name "XcodeCloud"

# Make sure tags/branch context are present
git fetch --tags origin || true

# If we're on a detached HEAD, create a local branch for clarity
if [ "$(git rev-parse --abbrev-ref HEAD)" = "HEAD" ]; then
  git checkout -B "$CI_BRANCH"
fi

# Create or update the tag to the current commit
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists locally; updating to current commit."
  git tag -f "$TAG"
else
  git tag "$TAG"
fi

# Push the tag (force in case we updated it)
git push --force origin "$TAG"

echo "✅ Successfully pushed tag $TAG"
