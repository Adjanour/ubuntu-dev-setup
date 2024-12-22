#!/bin/bash

WORK_DIR=~/work
BACKUP_DIR=~/backup/work-repos

mkdir -p "$BACKUP_DIR"

find "$WORK_DIR" -type d | while read repo; do
    REPO_DIR=$(realpath "$repo")
    cd "$REPO_DIR" || continue

    if [ -d ".git" ]; then
        REPO_NAME=$(basename "$REPO_DIR")
    else
        echo "$REPO_DIR is not a git repository. Initializing..."
        git init
        git add .
        git commit -m "Initial commit"
        REPO_NAME=$(basename "$REPO_DIR")
    fi

    if gh repo view adjanour/"$REPO_NAME" &>/dev/null; then
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        REPO_NAME="${REPO_NAME}_${TIMESTAMP}"
        echo "Repository already exists. Renaming to $REPO_NAME..."
    fi

    echo "Creating GitHub repository $REPO_NAME..."
    gh repo create adjanour/"$REPO_NAME" --public --source=. --remote=origin --push

    cd "$BACKUP_DIR" || exit
done

echo "Backup process completed."
