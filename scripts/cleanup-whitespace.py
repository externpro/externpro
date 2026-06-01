#!/usr/bin/env python3
"""
cleanup-whitespace.py - Remove trailing whitespace from files
Usage: python3 scripts/cleanup-whitespace.py [file1] [file2] ...

If no files specified, cleans all modified files in git status.
"""

import sys
import os
import subprocess
import re
from pathlib import Path

def clean_whitespace_in_file(filepath):
    """Remove trailing whitespace from a file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        # Remove trailing whitespace from each line
        cleaned_lines = [line.rstrip() + '\n' if line.endswith('\n') else line.rstrip()
                         for line in lines]

        # Check if any changes were made
        if lines != cleaned_lines:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(cleaned_lines)
            print(f"✅ Cleaned: {filepath}")
            return True
        else:
            print(f"✓ Already clean: {filepath}")
            return False

    except Exception as e:
        print(f"❌ Error cleaning {filepath}: {e}")
        return False

def get_git_modified_files():
    """Get list of modified files from git status"""
    try:
        result = subprocess.run(
            ['git', 'status', '--porcelain'],
            capture_output=True,
            text=True,
            check=True
        )

        files = []
        for line in result.stdout.strip().split('\n'):
            if line and line.strip():
                # Parse git status output
                status = line[:2]
                filepath = line[3:]

                # Only process modified (M), added (A), or renamed (R) files
                if status[0] in 'MAR' or status[1] in 'MAR':
                    if os.path.isfile(filepath):
                        files.append(filepath)

        return files
    except subprocess.CalledProcessError as e:
        print(f"❌ Error getting git status: {e}")
        return []

def main():
    # Get files to clean
    if len(sys.argv) > 1:
        files = sys.argv[1:]
    else:
        print("🔍 Getting modified files from git status...")
        files = get_git_modified_files()

    if not files:
        print("📝 No files to clean. Specify files as arguments or check git status.")
        return

    print(f"🧹 Cleaning {len(files)} file(s)...")

    # Clean each file
    cleaned_count = 0
    for filepath in files:
        if clean_whitespace_in_file(filepath):
            cleaned_count += 1

    print(f"\n✨ Done! Cleaned {cleaned_count} of {len(files)} file(s)")

if __name__ == '__main__':
    main()
