#!/bin/bash

# Bootstrap script for externpro setup
# This script sets up the minimum requirements for a developer to run cmake successfully
# before the xpInit workflow is ever run.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos";;
        Linux*)     echo "linux";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Function to create or switch to xpro branch
ensure_xpro_branch() {
    local current_branch=$(git branch --show-current 2>/dev/null || echo "")

    if [ "$current_branch" = "xpro" ]; then
        print_info "Already on xpro branch"
        return 0
    fi

    # Check if xpro branch exists
    if git show-ref --verify --quiet refs/heads/xpro; then
        print_info "Switching to existing xpro branch"
        git checkout xpro
    else
        print_info "Creating new xpro branch"
        git checkout -b xpro
    fi

    if [ $? -eq 0 ]; then
        print_success "Now on xpro branch"
    else
        print_error "Failed to switch to xpro branch"
        exit 1
    fi
}

# Function to get externpro version
get_externpro_version() {
    local devcontainer_dir="$1"

    if [ -f "$devcontainer_dir/.git" ] || [ -d "$devcontainer_dir/.git" ]; then
        cd "$devcontainer_dir"
        local version=$(git describe --tags 2>/dev/null || echo "unknown")
        cd - >/dev/null
        echo "$version"
    else
        echo "unknown"
    fi
}

# Function to get repository name from git remote
get_repo_name() {
    local repo_root="$1"
    cd "$repo_root"
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")

    # Extract repo name from various git URL formats
    # https://github.com/user/repo.git -> user/repo
    # git@github.com:user/repo.git -> user/repo
    # https://github.com/user/repo -> user/repo
    if [[ "$remote_url" =~ github\.com[/:]([^/]+/[^/]+)(\.git)?$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "unknown/repo"
    fi
    cd - >/dev/null
}

# Function to check if XPRO_TOKEN is configured
check_xpro_token() {
    local repo_root="$1"
    local repo_name=$(get_repo_name "$repo_root")

    print_info "Checking XPRO_TOKEN configuration..."

    # Try to check if the secret exists via GitHub CLI (if available)
    if command -v gh >/dev/null 2>&1; then
        if gh secret list --repo "$repo_name" 2>/dev/null | grep -q "XPRO_TOKEN"; then
            print_success "XPRO_TOKEN is configured in repository secrets"
            return 0
        fi
    fi

    # If we can't check via CLI, provide setup instructions
    print_warning "XPRO_TOKEN may not be configured yet"
    print_info "XPRO_TOKEN is required for xpInit workflow to work properly"

    # Provide the pre-filled PAT template URL
    local pat_url="https://github.com/settings/personal-access-tokens/new?name=EXTERNPRO_GITHUB_TOKEN&description=Used%20by%20externpro%20GitHub%20Actions%20for%20automation%20when%20pushing%20commits%2Ftags%20or%20creating%2Fupdating%20PRs%20(may%20include%20workflow%20file%20updates).&contents=write&pull_requests=write&workflows=write"

    echo
    print_info "To set up XPRO_TOKEN:"
    print_info "  1. Create a fine-grained PAT using this pre-filled link:"
    print_info "     $pat_url"
    print_info "  2. Add the PAT as a repository secret named 'XPRO_TOKEN':"
    print_info "     - Go to: https://github.com/$repo_name/settings/secrets/actions"
    print_info "     - Click 'New repository secret'"
    print_info "     - Name: XPRO_TOKEN"
    print_info "     - Secret: [paste the PAT value]"
    echo

    # Ask if user wants to open the PAT creation URL
    read -p "Do you want to open the PAT creation URL in your browser? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Try to open URL based on platform
        case "$(uname -s)" in
            Darwin*)    open "$pat_url" ;;
            Linux*)
                if command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "$pat_url"
                else
                    print_info "Please open the URL manually: $pat_url"
                fi
                ;;
            CYGWIN*|MINGW*|MSYS*)
                start "$pat_url"
                ;;
            *)
                print_info "Please open the URL manually: $pat_url"
                ;;
        esac
    fi

    return 1
}

# Function to check and guide on default branch setup
check_default_branch() {
    local repo_root="$1"
    local repo_name=$(get_repo_name "$repo_root")

    print_info "Checking default branch configuration..."

    # Try to get the default branch from GitHub API
    local default_branch=""
    if command -v gh >/dev/null 2>&1; then
        default_branch=$(gh api "repos/$repo_name" --jq '.default_branch' 2>/dev/null || echo "")
    fi

    # If we can't get the default branch via API, assume it's not xpro
    if [ -z "$default_branch" ]; then
        print_warning "Could not determine default branch from GitHub"
        default_branch="master"  # Assume master as fallback
    fi

    if [ "$default_branch" = "xpro" ]; then
        print_success "Default branch is already set to 'xpro'"
        return 0
    fi

    # Default branch is not xpro, provide instructions
    print_warning "Default branch is currently '$default_branch', should be 'xpro'"
    echo
    print_info "Before running the xpInit workflow, you must set 'xpro' as the default branch:"
    echo
    print_info "  1. Go to repository settings:"
    print_info "     https://github.com/$repo_name/settings"
    echo
    print_info "  2. In the 'Default branch' section:"
    print_info "     - Click on button with tooltip 'Switch to another branch'"
    print_info "     - Select 'xpro' from the dropdown"
    print_info "     - Confirm the change"
    echo
    print_info "  3. Verify the change:"
    print_info "     - The default branch should now show 'xpro'"
    print_info "     - The repository URL should show the xpro branch by default"
    echo

    # Ask if user wants to open the repository settings
    read -p "Do you want to open the repository settings in your browser? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        local settings_url="https://github.com/$repo_name/settings"
        # Try to open URL based on platform
        case "$(uname -s)" in
            Darwin*)    open "$settings_url" ;;
            Linux*)
                if command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "$settings_url"
                else
                    print_info "Please open the URL manually: $settings_url"
                fi
                ;;
            CYGWIN*|MINGW*|MSYS*)
                start "$settings_url"
                ;;
            *)
                print_info "Please open the URL manually: $settings_url"
                ;;
        esac
    fi

    return 1
}

# Function to find the best remote for pushing
find_best_remote() {
    local origin_url=$(git remote get-url origin 2>/dev/null)
    if [ -z "$origin_url" ]; then
        echo "origin"
        return 0
    fi

    # Extract the repo path from origin URL
    local repo_path
    if [[ "$origin_url" =~ https://github\.com/(.*)\.git$ ]]; then
        repo_path="${BASH_REMATCH[1]}"
    elif [[ "$origin_url" =~ https://github\.com/(.*)$ ]]; then
        repo_path="${BASH_REMATCH[1]}"
    elif [[ "$origin_url" =~ git@github\.com:(.*)\.git$ ]]; then
        repo_path="${BASH_REMATCH[1]}"
    elif [[ "$origin_url" =~ git@github\.com:(.*)$ ]]; then
        repo_path="${BASH_REMATCH[1]}"
    else
        echo "origin"
        return 0
    fi

    # Look for git protocol remotes pointing to the same repo
    local best_remote="origin"
    local git_protocol_remote=""

    while IFS= read -r line; do
        local remote_name=$(echo "$line" | awk '{print $1}')
        local remote_url=$(echo "$line" | awk '{print $2}')

        # Skip origin and remotes without push access
        if [ "$remote_name" = "origin" ] || ! echo "$line" | grep -q "(push)"; then
            continue
        fi

        # Check if this remote points to the same repo using git protocol
        if [[ "$remote_url" =~ git@github\.com:${repo_path}(\.git)?$ ]]; then
            git_protocol_remote="$remote_name"
            break
        fi
    done < <(git remote -v)

    # Prefer git protocol remote if found and accessible
    if [ -n "$git_protocol_remote" ]; then
        if git ls-remote --exit-code "$git_protocol_remote" >/dev/null 2>&1; then
            best_remote="$git_protocol_remote"
        fi
    fi

    echo "$best_remote"
}

# Function to verify commits and push xpro branch
push_xpro_branch() {
    local repo_root="$1"

    # First, check if the current working tree has the required files
    local has_devcontainer=false
    local has_bootstrap_files=false

    if [ -d "$repo_root/.devcontainer" ]; then
        has_devcontainer=true
    fi

    if [ -f "$repo_root/.github/workflows/xpinit.yml" ]; then
        has_bootstrap_files=true
    fi

    if [ "$has_devcontainer" = false ]; then
        print_warning "externpro submodule not found in working tree"
        print_info "Skipping push - add externpro as submodule first"
        return 0
    fi

    # Search the entire xpro branch history for required commits
    local has_externpro_commit=false
    local has_bootstrap_commit=false

    # Find the merge base with main to limit our search to xpro-specific commits
    local main_branch="main"
    local merge_base

    # Try to find main branch (could be master, main, etc.)
    for branch in main master develop; do
        if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
            main_branch="$branch"
            break
        fi
    done

    # Get the merge base between current branch and main
    merge_base=$(git merge-base "origin/$main_branch" HEAD 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$merge_base" ]; then
        # Fallback: just search all commits on current branch
        merge_base=$(git rev-list --max-parents=0 HEAD 2>/dev/null)
    fi

    if [ -n "$merge_base" ]; then
        print_info "Checking xpro branch history for required commits..."

        # Get all commits from merge base to HEAD (exclusive of merge base)
        local xpro_commits=$(git rev-list --reverse "$merge_base"..HEAD 2>/dev/null)

        if [ -z "$xpro_commits" ]; then
            print_warning "No commits found on xpro branch"
            print_info "Skipping push - manual verification needed"
            return 0
        fi

        for commit_hash in $xpro_commits; do
            # Check if commit contains .devcontainer submodule
            if git ls-tree "$commit_hash" | grep -q "\.devcontainer"; then
                has_externpro_commit=true
            fi

            # Check if commit contains bootstrap files (check multiple indicators)
            local bootstrap_file_count=0

            # Check for GitHub workflow
            if git ls-tree "$commit_hash" | grep -q "\.github/workflows/xpinit.yml"; then
                ((bootstrap_file_count++))
            fi

            # Check for CMakePresets files
            if git ls-tree "$commit_hash" | grep -q "CMakePresets.json"; then
                ((bootstrap_file_count++))
            fi

            if git ls-tree "$commit_hash" | grep -q "CMakePresetsBase.json"; then
                ((bootstrap_file_count++))
            fi

            # If we found at least 2 bootstrap files, consider it a bootstrap commit
            if [ "$bootstrap_file_count" -ge 2 ]; then
                has_bootstrap_commit=true
            fi
        done
    else
        print_warning "Could not determine branch history range"
        print_info "Skipping push - manual verification needed"
        return 0
    fi

    if [ "$has_externpro_commit" = false ]; then
        print_warning "No externpro submodule commit found in xpro branch history"
        print_info "Searched $(echo "$xpro_commits" | wc -l) commits"
        print_info "Skipping push - manual verification needed"
        return 0
    fi

    if [ "$has_bootstrap_commit" = false ]; then
        print_info "Bootstrap setup commit not found in xpro branch history"
        print_info "  This is normal if bootstrap files were added manually"
        print_info "  Current working tree has bootstrap files: $has_bootstrap_files"
    else
        print_success "Bootstrap setup commit found in xpro branch history"
    fi

    # Find the best remote for pushing
    local best_remote=$(find_best_remote)
    print_info "Using remote '$best_remote' for push"

    # Check if the chosen remote is accessible and has push access
    if ! git ls-remote --exit-code "$best_remote" >/dev/null 2>&1; then
        print_warning "Remote '$best_remote' is not accessible"
        print_info "Skipping push - check network connectivity"
        return 0
    fi

    # Try to push to test write access (dry run)
    if ! git push --dry-run "$best_remote" xpro >/dev/null 2>&1; then
        print_warning "No push access to remote '$best_remote'"
        print_info "Skipping push - check repository permissions"
        return 0
    fi

    # Push the branch
    print_info "Pushing xpro branch to remote $best_remote..."
    if git push -u "$best_remote" xpro; then
        print_success "xpro branch pushed successfully to $best_remote"

        # Set up upstream tracking if not already set
        if ! git rev-parse --verify --symbolic-full-name @{u} >/dev/null 2>&1; then
            git branch --set-upstream-to="$best_remote/xpro" xpro
            print_success "Upstream tracking set for xpro branch"
        fi
    else
        print_warning "Failed to push xpro branch"
        print_info "You may need to push manually: git push -u $best_remote xpro"
    fi
}

# Function to commit externpro submodule
commit_externpro_submodule() {
    local repo_root="$1"
    local devcontainer_dir="$repo_root/.devcontainer"

    # Check if externpro submodule needs to be committed
    local needs_commit=false

    # Check if .devcontainer exists as a submodule but is not yet committed
    if [ -d "$devcontainer_dir" ]; then
        # Check if .devcontainer is tracked as a submodule in the current commit
        if ! git ls-tree HEAD | grep -q "\.devcontainer"; then
            needs_commit=true
            print_info "externpro submodule detected but not yet committed"
        else
            print_info "externpro submodule already committed"
        fi
    else
        print_warning "externpro submodule not found at: $devcontainer_dir"
        return 1
    fi

    if [ "$needs_commit" = false ]; then
        return 0
    fi

    # Stage the submodule files
    git add .devcontainer .gitmodules

    # Check if staging was successful
    if ! git diff --cached --quiet .devcontainer .gitmodules; then
        local externpro_version=$(get_externpro_version "$devcontainer_dir")
        print_info "Committing externpro submodule (version: $externpro_version)..."

        # Explicitly commit only the submodule files
        git commit -m "externpro $externpro_version" .devcontainer .gitmodules

        if [ $? -eq 0 ]; then
            print_success "externpro submodule committed successfully"
            return 0
        else
            print_error "Failed to commit externpro submodule"
            return 1
        fi
    else
        print_warning "No changes to stage for submodule"
        return 1
    fi
}

# Function to commit bootstrap changes
commit_bootstrap_changes() {
    local repo_root="$1"

    # Explicitly stage only the files we created
    local files_to_commit=(
        ".github/workflows/xpinit.yml"
        "CMakePresets.json"
        "CMakePresetsBase.json"
    )

    local files_to_add=()

    # Check which of our target files actually exist and need to be committed
    for file in "${files_to_commit[@]}"; do
        if [ -f "$repo_root/$file" ]; then
            files_to_add+=("$file")
        fi
    done

    if [ ${#files_to_add[@]} -gt 0 ]; then
        # Check if any of these files actually have changes
        local has_changes=false
        for file in "${files_to_add[@]}"; do
            if [ -f "$repo_root/$file" ] && ! git diff --quiet "$repo_root/$file"; then
                has_changes=true
                break
            fi
        done

        if [ "$has_changes" = true ]; then
            print_info "Staging bootstrap files..."
            git add "${files_to_add[@]}"

            print_info "Committing bootstrap changes..."
            git commit -m "Add externpro bootstrap setup

- Add xpinit.yml workflow to .github/workflows
- Add CMakePresets.json and CMakePresetsBase.json to root"

            if [ $? -eq 0 ]; then
                print_success "Bootstrap changes committed successfully"
            else
                print_warning "Commit failed"
            fi
        else
            print_info "No bootstrap changes to commit"
        fi
    else
        print_info "No bootstrap files to commit"
    fi
}

# Function to create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        print_info "Creating directory: $1"
        mkdir -p "$1"
    fi
}

# Function to copy file with commit confirmation
copy_with_commit_confirmation() {
    local src="$1"
    local dst="$2"

    if [ -f "$dst" ]; then
        # Check if files are identical
        if cmp -s "$src" "$dst"; then
            # Files are identical, no action needed
            return 0
        fi

        # Check if the file is tracked by git
        if git ls-files --error-unmatch "$dst" >/dev/null 2>&1; then
            # File is tracked - original is in git history
            print_warning "Target file exists: $dst"
            print_info "Copying: $src -> $dst"
            cp "$src" "$dst"

            print_info "The existing file has been overwritten, but the original is preserved in git history."
            read -p "Proceed with commit? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_warning "User chose not to proceed. Script exiting."
                print_info "Review the changes with 'git diff $dst' and run the script again when ready to continue."
                exit 1
            fi
        else
            # File is untracked - just overwrite without confirmation
            print_info "Overwriting untracked file: $dst"
            cp "$src" "$dst"
        fi
    else
        print_info "Copying: $src -> $dst"
        cp "$src" "$dst"
    fi

    return 0
}

# Main script
main() {
    print_info "Starting externpro bootstrap script..."

    local platform=$(detect_platform)
    print_info "Detected platform: $platform"

    # Check if we're in a git repository
    check_git_repo

    # Get the repository root directory
    local repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    print_info "Repository root: $repo_root"

    # Ensure we're on the xpro branch FIRST
    ensure_xpro_branch

    # ALWAYS check if externpro submodule needs to be committed
    # This ensures the two-commit strategy works regardless of when submodule was added
    commit_externpro_submodule "$repo_root"

    # Check if we're in the right directory structure
    local devcontainer_dir="$repo_root/.devcontainer"
    if [ ! -d "$devcontainer_dir" ]; then
        print_error ".devcontainer directory not found at: $devcontainer_dir"
        print_info "Please ensure externpro is added as a submodule:"
        print_info "  git submodule add https://github.com/externpro/externpro .devcontainer"
        exit 1
    fi

    # Copy xpinit.yml to .github/workflows
    print_info "Verifying GitHub workflows..."
    local workflows_dir="$repo_root/.github/workflows"
    ensure_dir "$workflows_dir"

    local xpinit_src="$devcontainer_dir/.github/wf-templates/xpinit.yml"
    local xpinit_dst="$workflows_dir/xpinit.yml"

    if [ -f "$xpinit_src" ]; then
        if copy_with_commit_confirmation "$xpinit_src" "$xpinit_dst"; then
            print_success "GitHub workflow xpinit.yml verified"
        fi
    else
        print_error "xpinit.yml template not found at: $xpinit_src"
        exit 1
    fi

    # Copy CMakePresets files to repo root
    print_info "Verifying CMake presets..."
    local presets_src_dir="$devcontainer_dir/cmake/presets"

    if [ ! -d "$presets_src_dir" ]; then
        print_error "CMake presets directory not found at: $presets_src_dir"
        exit 1
    fi

    # Copy CMakePresets.json and CMakePresetsBase.json
    local preset_files=("CMakePresets.json" "CMakePresetsBase.json")
    local copied_count=0

    for preset_file in "${preset_files[@]}"; do
        local src="$presets_src_dir/$preset_file"
        local dst="$repo_root/$preset_file"

        if [ -f "$src" ]; then
            if copy_with_commit_confirmation "$src" "$dst"; then
                ((copied_count++))
            fi
        else
            print_warning "Preset file not found: $src"
        fi
    done

    if [ $copied_count -gt 0 ]; then
        print_success "CMake presets verified"
    else
        print_warning "No CMake preset files were copied"
        print_info "Bootstrap setup cannot continue without CMake preset files."
        exit 1
    fi

    # Verify setup
    print_info "Verifying setup..."

    # Check if cmake can be run
    if command -v cmake >/dev/null 2>&1; then
        print_success "cmake found in PATH"

        # Try to run cmake --preset to test the presets
        cd "$repo_root"
        if cmake --list-presets >/dev/null 2>&1; then
            print_success "CMake presets are working correctly"
        else
            print_warning "CMake presets may have issues. Run 'cmake --list-presets' to check."
        fi
    else
        print_warning "cmake not found in PATH. Please install cmake."
    fi

    # Commit bootstrap changes
    commit_bootstrap_changes "$repo_root"

    # Check XPRO_TOKEN configuration
    check_xpro_token "$repo_root"

    # Push xpro branch if remote is accessible
    push_xpro_branch "$repo_root"

    # Check and guide on default branch setup
    check_default_branch "$repo_root"

    # Final summary
    echo
    print_success "Bootstrap script completed successfully!"
    echo
    print_info "Next steps:"
    print_info "  1. List available cmake presets:"
    print_info "     cmake --list-presets"
    print_info "  2. Configure with cmake:"
    print_info "     cmake --preset=<platform>"
    print_info "  3. Run cmake workflow and fix any issues:"
    print_info "     cmake --workflow --preset=<platform>"
    print_info "     (commit and push any changes)"
    print_info "  4. With XPRO_TOKEN successfully configured, run xpInit workflow when ready:"
    local repo_name=$(get_repo_name "$repo_root")
    print_info "     https://github.com/$repo_name/actions/workflows/xpinit.yml"
    echo
    print_info "For more information, see the externpro documentation: https://github.com/externpro/externpro/#documentation"
}

# Run main function
main "$@"
