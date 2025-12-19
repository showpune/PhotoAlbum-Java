#!/bin/bash
# Script to create GitHub issue with assessment results
# Usage: GH_TOKEN=<your-token> ./create-issue.sh

REPO="showpune/PhotoAlbum-Java"
TITLE="App Modernization Assessment Results"
BODY_FILE=".github/appmod/appcat/result/summary.md"

if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable is not set"
    echo "Please set it with: export GH_TOKEN=<your-github-token>"
    exit 1
fi

if [ ! -f "$BODY_FILE" ]; then
    echo "Error: $BODY_FILE not found"
    exit 1
fi

# Read the body content
BODY=$(cat "$BODY_FILE")

# Create JSON payload
JSON_PAYLOAD=$(jq -n \
    --arg title "$TITLE" \
    --arg body "$BODY" \
    '{title: $title, body: $body}')

# Create the issue using GitHub API
RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/issues" \
    -d "$JSON_PAYLOAD")

# Check if issue was created successfully
ISSUE_NUMBER=$(echo "$RESPONSE" | jq -r '.number')
ISSUE_URL=$(echo "$RESPONSE" | jq -r '.html_url')

if [ "$ISSUE_NUMBER" != "null" ]; then
    echo "✅ Issue created successfully!"
    echo "Issue #$ISSUE_NUMBER: $ISSUE_URL"
else
    echo "❌ Failed to create issue"
    echo "Response: $RESPONSE"
    exit 1
fi
