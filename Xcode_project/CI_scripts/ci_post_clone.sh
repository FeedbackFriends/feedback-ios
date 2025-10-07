#!/bin/sh
set -euo pipefail

# Xcode Cloud environment setup
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

# Require key env vars (will fail fast with a clear message if missing)
: "${GITHUB_WRITE_PAT:?GITHUB_WRITE_PAT secret is required for pushing tags}"
: "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"
: "${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is required}"
: "${CI_BRANCH:=main}"

# Set up GitHub authentication FIRST
git remote set-url origin "https://${GITHUB_WRITE_PAT}@github.com/FeedbackFriends/feedback-ios.git"

# Try multiple possible paths for Info.plist
INFO_PLIST_PATHS=(
  "$CI_PRIMARY_REPOSITORY_PATH/Xcode_project/App/InfoPlist/Info.plist"
  "$CI_PRIMARY_REPOSITORY_PATH/App/InfoPlist/Info.plist"
  "$CI_PRIMARY_REPOSITORY_PATH/Info.plist"
  "$CI_PRIMARY_REPOSITORY_PATH/Xcode_project/App/Info.plist"
)

VERSION=""
for plist_path in "${INFO_PLIST_PATHS[@]}"; do
  if [ -f "$plist_path" ]; then
    echo "Found Info.plist at: $plist_path"
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$plist_path" 2>/dev/null || echo "")
    if [ -n "$VERSION" ]; then
      echo "Successfully extracted version: $VERSION"
      break
    else
      echo "Failed to extract version from: $plist_path"
    fi
  else
    echo "Info.plist not found at: $plist_path"
  fi
done

# Fallback to project file if Info.plist approach fails
if [ -z "$VERSION" ]; then
  echo "Trying to extract version from project file..."
  VERSION=$(grep -o 'MARKETING_VERSION = [^;]*' "$CI_PRIMARY_REPOSITORY_PATH/Xcode_project/Feedback.xcodeproj/project.pbxproj" | head -1 | sed 's/MARKETING_VERSION = //' | tr -d ' ')
  if [ -n "$VERSION" ]; then
    echo "Successfully extracted version from project file: $VERSION"
  fi
fi

# Final fallback
if [ -z "$VERSION" ]; then
  echo "ERROR: Could not extract version from any source"
  exit 1
fi

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
