# ------------------------------------------------------------------------------
# Hero of Legend - Status & Environment Service
# ------------------------------------------------------------------------------
# Quantum Capsule: status.zsh
# Single Responsibility: Git status tracking, health hearts & realm context.
# ------------------------------------------------------------------------------

# Git Cache Globals
typeset -g HERO_GIT_IN_REPO=0
typeset -g HERO_GIT_REF=""
typeset -g HERO_GIT_DIRTY=0
typeset -g HERO_GIT_AHEAD=0
typeset -g HERO_GIT_BEHIND=0
typeset -g HERO_GIT_REPO_NAME=""

function HeroStatus() {
    local action="$1"; shift
    case "$action" in
        # Usage: HeroStatus refresh
        refresh)
            HERO_GIT_IN_REPO=0
            HERO_GIT_REF=""
            HERO_GIT_DIRTY=0
            HERO_GIT_AHEAD=0
            HERO_GIT_BEHIND=0
            HERO_GIT_REPO_NAME=""
            
            local toplevel
            if toplevel=$(command git rev-parse --show-toplevel 2>/dev/null) && [[ -n "$toplevel" ]]; then
                HERO_GIT_IN_REPO=1
                
                # Repo name: from origin URL, falling back to the toplevel dir name.
                # Resolved once per command so the 1s timer tick never spawns git.
                local remote_url
                remote_url=$(command git config --get remote.origin.url 2>/dev/null)
                if [[ -n "$remote_url" ]]; then
                    local clean_url="${remote_url%.git}"
                    HERO_GIT_REPO_NAME="${clean_url##*[/:]}"
                fi
                [[ -z "$HERO_GIT_REPO_NAME" ]] && HERO_GIT_REPO_NAME="${toplevel:t}"
                
                HERO_GIT_REF=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
                
                # Check for dirty working tree or index
                if ! git diff-index --quiet --cached HEAD -- 2>/dev/null || ! git diff-files --quiet 2>/dev/null; then
                    HERO_GIT_DIRTY=1
                fi
                
                # Check Ahead/Behind sync with upstream
                local sync_counts
                sync_counts=$(git rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null)
                if [[ -n "$sync_counts" ]]; then
                    read -r HERO_GIT_BEHIND HERO_GIT_AHEAD <<< "$sync_counts"
                fi
            fi
            ;;

        # Usage: HeroStatus check (returns 1 if in git repo, 0 otherwise)
        check)
            echo "$HERO_GIT_IN_REPO"
            ;;

        # Usage: HeroStatus environment
        # Returns: tri_top|tri_bot|area_icon|area_name
        environment)
            if (( HERO_GIT_IN_REPO )); then
                echo "${tri_top_git}|${tri_bot_git}|${hero_areas[dungeon]}|%F{white}${HERO_GIT_REPO_NAME}%f"
            else
                echo "${tri_top_norm}|${tri_bot_norm}|${hero_areas[castle]}|%F{240}%m%f"
            fi
            ;;

        # Usage: HeroStatus hearts
        hearts)
            local -i pad=${HERO_PAD:-1}
            local heart_full="❤️"
            (( pad == 1 )) && heart_full="❤️ "
            local heart_empty="🖤"
            if (( HERO_GIT_IN_REPO )); then
                if (( HERO_GIT_DIRTY )); then
                    echo "${heart_full}${heart_full}${heart_empty}"
                else
                    echo "${heart_full}${heart_full}${heart_full}"
                fi
            else
                echo "${heart_full}${heart_empty}${heart_empty}"
            fi
            ;;
    esac
}
