#!/bin/sh
set -euo pipefail

mkdir -p "$CI_PRIMARY_REPOSITORY_PATH/App/Config"

# Get version + build number from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" \
  "$CI_PRIMARY_REPOSITORY_PATH/Xcode_project/App/InfoPlist/Info.plist")

BUILD=$(CI_BUILD_NUMBER)

TAG="${VERSION}(${BUILD})"

echo "Creating tag: $TAG"

cd "$CI_PRIMARY_REPOSITORY_PATH"

# Configure git (Xcode Cloud checkouts are detached and may lack user info)
git config user.email "ci@xcodecloud.apple.com"
git config user.name "XcodeCloud"

# Create tag and push
git tag "$TAG"
git push origin "$TAG"

echo "✅ Successfully pushed tag $TAG"
