# ------------------------------------------------------------------------------
# Hero of Legend - Cache & Filesystem Metrics
# ------------------------------------------------------------------------------
# Quantum Capsule: cache.zsh
# Single Responsibility: Throttled file counts and native glob room metrics.
# ------------------------------------------------------------------------------

typeset -g HERO_CACHE_TS=0
typeset -g HERO_CACHE_TR=0
typeset -g HERO_CACHE_DL=0
typeset -g HERO_CACHE_KY=0
typeset -g HERO_CACHE_POT=0
typeset -g HERO_CACHE_LADDER=0

function HeroCache() {
    local op="$1"
    case "$op" in
        refresh)
            local -i now=${EPOCHSECONDS:-$(date +%s)}
            
            # 1. Heavy File Counts (Throttled to every 60s)
            if (( now - HERO_CACHE_TS > 60 )); then
                # Trash Count (Linux XDG or macOS ~/.Trash)
                local trash_dir="${XDG_DATA_HOME:-$HOME/.local/share}/Trash/files"
                [[ ! -d "$trash_dir" && -d "$HOME/.Trash" ]] && trash_dir="$HOME/.Trash"
                [[ ! -d "$trash_dir" && -d "${XDG_DATA_HOME:-$HOME/.local/share}/Trash" ]] && trash_dir="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
                [[ ! -d "$trash_dir" && -d "${TMPDIR:-/tmp}/Trash-$USER" ]] && trash_dir="${TMPDIR:-/tmp}/Trash-$USER"
                
                if [[ -d "$trash_dir" ]]; then
                    local -a trash_files
                    trash_files=($trash_dir/*(N))
                    HERO_CACHE_TR=${#trash_files}
                else
                    HERO_CACHE_TR=0
                fi
                
                # Downloads Count (non-directories)
                if [[ -d "$HOME/Downloads" ]]; then
                    local -a dl_files
                    dl_files=($HOME/Downloads/*(N^/))
                    HERO_CACHE_DL=${#dl_files}
                else
                    HERO_CACHE_DL=0
                fi
                
                HERO_CACHE_TS=$now
            fi
            
            # 2. Directory Depth (Keys) - Pure string length of slashes
            if [[ "$PWD" == "/" ]]; then
                HERO_CACHE_KY=0
            else
                local slashes="${PWD//[^\/]/}"
                HERO_CACHE_KY=${#slashes}
            fi
            
            # 3. Room Stats (Pots = files, Ladders = directories in current folder)
            # Pure native Zsh globbing: *(N^/) matches non-directory files, *(N/) matches directories
            local -a current_pots=(*(N^/))
            local -a current_ladders=(*(N/))
            HERO_CACHE_POT=${#current_pots}
            HERO_CACHE_LADDER=${#current_ladders}
            ;;
    esac
}
