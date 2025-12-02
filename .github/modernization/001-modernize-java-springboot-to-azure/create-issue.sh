#!/bin/bash
# Script to create a GitHub issue for tracking the modernization work
# This script requires GitHub CLI (gh) to be installed and authenticated

set -e

REPO="showpune/PhotoAlbum-Java"
TITLE="Java Application Modernization - Azure Migration Assessment"
ISSUE_BODY_FILE="../../appmod/MODERNIZATION_ISSUE_REPORT.md"

echo "Creating GitHub issue for modernization tracking..."
echo "Repository: $REPO"
echo "Title: $TITLE"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI."
    echo "Please run: gh auth login"
    exit 1
fi

# Check if issue body file exists
if [ ! -f "$ISSUE_BODY_FILE" ]; then
    echo "Error: Issue body file not found: $ISSUE_BODY_FILE"
    exit 1
fi

# Create the issue
echo "Creating issue..."
ISSUE_URL=$(gh issue create \
    --repo "$REPO" \
    --title "$TITLE" \
    --body-file "$ISSUE_BODY_FILE" \
    --label "enhancement,modernization,azure")

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully created GitHub issue!"
    echo "Issue URL: $ISSUE_URL"
    echo ""
    echo "Next steps:"
    echo "1. Review the issue at: $ISSUE_URL"
    echo "2. Review the modernization plan at: .github/modernization/001-modernize-java-springboot-to-azure/plan.md"
    echo "3. Execute the plan using: /appmod-kit.run-plan"
else
    echo ""
    echo "❌ Failed to create GitHub issue."
    echo "Please create it manually by copying the content from:"
    echo "$ISSUE_BODY_FILE"
    exit 1
fi
