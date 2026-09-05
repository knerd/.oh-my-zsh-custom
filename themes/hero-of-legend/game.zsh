# ------------------------------------------------------------------------------
# Hero of Legend - Adventure Mechanics & Game Loop
# ------------------------------------------------------------------------------
# Quantum Capsule: game.zsh
# Single Responsibility: Exit status tracking, villain theft & battle logs.
# ------------------------------------------------------------------------------

typeset -g HERO_CACHED_BATTLE_LOG=""

function HeroGame() {
    local action="$1"; shift
    case "$action" in
        # Usage: HeroGame process exitStatus lastCommand companionMsg
        process)
            local -i exit_status=${1:-0}
            local last_command="$2"
            local companion_msg="$3"
            
            # ── Stage 1: Atomic Concept Declarations ──────────────────
            local -i is_command_failure=$(( exit_status != 0 ))
            
            # ── Stage 2 & 3: Clean Conditionals & Actions ─────────────
            if (( is_command_failure )); then
                HeroGame _notify_theft
                HeroGame _log_failure "$last_command" "$companion_msg"
                HeroState wallet adjust -10
            else
                HeroState wallet adjust 1
            fi
            ;;

        _notify_theft)
            if command -v notify-send >/dev/null 2>&1; then
                notify-send -u normal -t 3000 " MISS!" "Villain stole 10 Rupees!" 2>/dev/null
            fi
            ;;

        _log_failure)
            local cmd_name="$1"
            local comp_data="$2"
            local comp_text="${comp_data#*|}"
            local villain_icon="${HERO_NPC_ICONS[villain]:-🦹}"
            
            local -a entries=(
                "%F{white}$USER%f casts %F{green}${cmd_name}%f..."
                "%F{yellow}➤%f %F{red}It had no effect!%f"
                "${villain_icon} %F{magenta}\"Mwuahaha!\"%f (10 ${hero_icons[rupee]} were stolen!)"
            )
            
            if [[ -n "$comp_text" && "$comp_data" == *"|"* ]]; then
                entries+=("%F{yellow}➤%f $comp_text")
            fi
            
            HERO_CACHED_BATTLE_LOG=$(HeroUI box "⚔️ BATTLE LOG" "${entries[@]}" --color red)
            HERO_CACHED_BATTLE_LOG+=$'\n'
            ;;
    esac
}
