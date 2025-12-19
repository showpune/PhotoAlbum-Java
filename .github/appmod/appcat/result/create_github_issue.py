#!/usr/bin/env python3
"""
Script to create a GitHub issue with assessment results.
Can be run manually with: python create_github_issue.py
"""

import json
import os
import sys
import urllib.request
import urllib.error

def read_summary():
    """Read the assessment summary file."""
    summary_path = os.path.join(os.path.dirname(__file__), 'summary.md')
    try:
        with open(summary_path, 'r') as f:
            return f.read()
    except FileNotFoundError:
        print(f"❌ Error: summary.md not found at {summary_path}")
        sys.exit(1)

def create_issue(token, repo, title, body):
    """Create a GitHub issue using the GitHub API."""
    url = f'https://api.github.com/repos/{repo}/issues'
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
        'User-Agent': 'Python-Assessment-Script'
    }
    
    data = json.dumps({
        'title': title,
        'body': body,
        'labels': ['assessment', 'modernization', 'migration']
    }).encode('utf-8')
    
    req = urllib.request.Request(url, data=data, headers=headers, method='POST')
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        raise Exception(f"HTTP {e.code}: {error_body}")

def main():
    """Main function to create the GitHub issue."""
    # Configuration
    repo = 'showpune/PhotoAlbum-Java'
    title = 'App Modernization Assessment Results'
    
    # Try to find a GitHub token
    token = (
        os.environ.get('GH_TOKEN') or 
        os.environ.get('GITHUB_TOKEN') or
        os.environ.get('INPUT_GITHUB_TOKEN')
    )
    
    # Read assessment summary
    body = read_summary()
    
    print("=" * 70)
    print("GitHub Issue Creation - Assessment Results")
    print("=" * 70)
    print(f"\n📊 Repository: {repo}")
    print(f"📝 Title: {title}")
    print(f"📄 Body Length: {len(body)} characters")
    
    if not token:
        print("\n⚠️  No GitHub token found in environment variables")
        print("\nThe following environment variables were checked:")
        print("  - GH_TOKEN")
        print("  - GITHUB_TOKEN")
        print("  - INPUT_GITHUB_TOKEN")
        print("\n📋 Issue content is ready but cannot be created without authentication.")
        print("\n💡 To create the issue, use one of these methods:")
        print("\n1. Using GitHub CLI:")
        print("   gh issue create --repo showpune/PhotoAlbum-Java \\")
        print("     --title 'App Modernization Assessment Results' \\")
        print("     --body-file summary.md \\")
        print("     --label assessment,modernization,migration")
        print("\n2. Set a token and run this script:")
        print("   export GH_TOKEN=your_token_here")
        print(f"   python {os.path.basename(__file__)}")
        print("\n3. Create manually at:")
        print(f"   https://github.com/{repo}/issues/new")
        print("\n" + "=" * 70)
        return 0
    
    # Try to create the issue
    print("\n🔄 Creating GitHub issue...")
    try:
        result = create_issue(token, repo, title, body)
        print("\n✅ Issue created successfully!")
        print(f"\n🔗 Issue URL: {result['html_url']}")
        print(f"📌 Issue Number: #{result['number']}")
        print(f"📅 Created At: {result['created_at']}")
        print("\n" + "=" * 70)
        return 0
    except Exception as e:
        print(f"\n❌ Failed to create issue: {e}")
        print("\nPlease create the issue manually or check your token permissions.")
        print("\n" + "=" * 70)
        return 1

if __name__ == '__main__':
    sys.exit(main())
