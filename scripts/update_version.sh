#!/bin/bash
# Version Update Script
# Usage: ./scripts/update_version.sh <new_version> [build_number]
# Example: ./scripts/update_version.sh 1.1.0 2

set -e

if [ -z "$1" ]; then
  echo "Error: Version number required"
  echo "Usage: ./scripts/update_version.sh <version> [build_number]"
  echo "Example: ./scripts/update_version.sh 1.1.0 2"
  exit 1
fi

NEW_VERSION=$1
BUILD_NUMBER=${2:-1}

echo "Updating app version to ${NEW_VERSION}+${BUILD_NUMBER}..."

# Update pubspec.yaml
sed -i "s/^version: .*/version: ${NEW_VERSION}+${BUILD_NUMBER}/" pubspec.yaml
echo "✓ Updated pubspec.yaml"

# Update lib/utils/constants.dart
sed -i "s/const String appVersion = '.*';/const String appVersion = '${NEW_VERSION}';/" lib/utils/constants.dart
sed -i "s/const int appBuildNumber = .*/const int appBuildNumber = ${BUILD_NUMBER};/" lib/utils/constants.dart
echo "✓ Updated lib/utils/constants.dart"

echo ""
echo "Version update complete!"
echo "Version: ${NEW_VERSION}"
echo "Build Number: ${BUILD_NUMBER}"
echo ""
echo "Don't forget to:"
echo "1. Commit the version changes"
echo "2. Tag the release: git tag -a v${NEW_VERSION} -m 'Release ${NEW_VERSION}'"
echo "3. Push with tags: git push origin main --tags"
