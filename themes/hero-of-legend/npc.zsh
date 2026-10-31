# ------------------------------------------------------------------------------
# Hero of Legend - NPC Companion Service
# ------------------------------------------------------------------------------
# Quantum Capsule: npc.zsh
# Single Responsibility: Companion dialogue bridge ("Hey Listen!") & context.
# ------------------------------------------------------------------------------

typeset -g HERO_CACHED_NPC_MSG=""
typeset -g hero_last_histcmd=0
typeset -g HERO_NPC_SESSION_FIRST_RUN=1

function HeroNPC() {
    local action="$1"; shift
    case "$action" in
        # Usage: HeroNPC set_context exitStatus [commandRan]
        # commandRan defaults to a HISTCMD comparison for external callers.
        set_context)
            local -i exit_status=${1:-0}
            local -i command_ran
            if [[ -n "$2" ]]; then
                command_ran=$2
            else
                command_ran=$(( HISTCMD != hero_last_histcmd ))
            fi
            if (( ! command_ran )); then
                # Empty <Enter>: $? is stale from the previous command
                export HERO_NPC_ARGS="--refresh"
            elif (( exit_status != 0 )); then
                export HERO_NPC_ARGS="--error"
            fi
            export hero_last_histcmd=$HISTCMD
            ;;

        # Usage: HeroNPC fetch
        fetch)
            local msg=""
            if typeset -f hero_npc_get_message >/dev/null 2>&1; then
                local ctx="${HEY_LISTEN:-$HERO_NPC_ARGS}"
                
                # Context priority hierarchy
                if [[ -n "$HEY_LISTEN" ]]; then
                    if [[ -n "$HOL_NPC" ]]; then
                        ctx="${HOL_NPC}|${HEY_LISTEN}"
                    else
                        ctx="$HEY_LISTEN"
                    fi
                elif [[ "$HERO_NPC_SESSION_FIRST_RUN" == "1" ]]; then
                    ctx="--first-run"
                elif [[ "$HERO_NPC_ARGS" == "--refresh" ]]; then
                    ctx="--refresh"
                else
                    ctx=""
                fi
                msg=$(hero_npc_get_message "$ctx" 2>/dev/null)
            fi
            
            # Clean up context in shell
            unset HEY_LISTEN HOL_NPC HERO_NPC_ARGS
            
            if [[ "$HERO_HIDE_NAVI" != "1" && -n "$msg" ]]; then
                echo "$msg"
            fi
            ;;

        # Usage: HeroNPC banner "Message" width
        banner)
            local message="$1"
            local width="$2"
            local npc_bin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/hero-npc"
            if [[ "$message" != "--refresh" && -x "$npc_bin" ]]; then
                "$npc_bin" --width "$width" "$message"
            fi
            ;;
    esac
}
