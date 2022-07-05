#!/bin/bash
#
# Date: July 5, 2021
# Author: Steve Stonebraker
# Title: pre-commit
# Purpose: write list of all files in the repository to "file-list.txt" in the root of the repository
#
# Place this file at .git/hooks/pre-commit in your repository
# It will print a list of all files to root of your repistory on every commit
#

DIR_REPO_BASE=$(git rev-parse --git-dir| sed "s|/.git$||g")
OUTPUT_FILE="${DIR_REPO_BASE}/file-list.txt"
REPO_NAME=$(basename "${DIR_REPO_BASE}")

find "${DIR_REPO_BASE}" -type f -print | grep -v "\.git" | sed "s|.*/${REPO_NAME}/||"  > "${OUTPUT_FILE}"