#!/bin/sh
#
# NAME: find-repos.sh
#
# AUTH: JLONG
#
# DATE: 2025-04-15
#
# EXEC: find-repos.sh example.com
#
# This script searches for public repositories containing the target domain
# across GitHub and other code hosting platforms.
#
# Outputs to ~/recon/<domain>/repos.txt
#

DOM=$1
DOM_DIR=~/recon/$DOM
REPOS_FILE=$DOM_DIR/repos.txt

[[ ! -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} does not exist.\n";exit 1; }

# Initialize output file
echo "Repository search results for $DOM" > $REPOS_FILE
echo "=================================" >> $REPOS_FILE

# Search GitHub using gh cli (requires gh auth)
echo "\nSearching GitHub repositories..." >> $REPOS_FILE
gh search repos --json fullName,description,url -q ".[] | \"[\(.fullName)] - \(.description)\n\(.url)\"" "$DOM" | anew $REPOS_FILE 2>/dev/null

# Use git-hound for finding secrets (if installed)
if command -v git-hound &> /dev/null; then
    echo "\nSearching for exposed secrets in repositories..." >> $REPOS_FILE
    echo "$DOM" | git-hound --config-file ~/.githound/config.yml | anew $REPOS_FILE 2>/dev/null
fi

# Use trufflehog for scanning found repositories (if installed and Docker running)
if command -v trufflehog &> /dev/null; then
    # Check if Docker is running
    if docker info &> /dev/null; then
        echo "\nScanning repositories for sensitive data..." >> $REPOS_FILE
        grep "http" $REPOS_FILE | while read -r repo; do
            if [[ $repo == *"http"* ]]; then
                trufflehog git $repo --only-verified | anew $REPOS_FILE 2>/dev/null
            fi
        done
    else
        echo "\nSkipping trufflehog scan - Docker daemon is not running" >> $REPOS_FILE
    fi
fi

echo "Results saved to $REPOS_FILE"
exit 0
