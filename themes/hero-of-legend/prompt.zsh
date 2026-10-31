# ------------------------------------------------------------------------------
# Hero of Legend - Prompt Engine & Lifecycle Hooks
# ------------------------------------------------------------------------------
# Quantum Capsule: prompt.zsh
# Single Responsibility: precmd/preexec hooks, prompt composition & timer loop.
# ------------------------------------------------------------------------------

typeset -g HERO_TIMER_TICK=0
typeset -g HERO_PROMPT_CACHED_BASE=""

# Set by preexec only when a command line is actually executed. An empty
# <Enter> skips preexec, so it must not replay the last exit status into the game.
typeset -gi HERO_CMD_RAN=0
typeset -g HERO_LAST_CMD=""

# Per-command HUD segments, rebuilt once per prompt (not on timer ticks).
typeset -gA HERO_SEG

function _hero_preexec() {
    HERO_CMD_RAN=1
    HERO_LAST_CMD="${${(f)1}[1]}"
}

# ── Heavy work: once per prompt (git, filesystem, game rules, NPC) ────────────
function _hero_refresh_state() {
    local -i exit_status=$1
    local -i ran=$HERO_CMD_RAN
    HERO_CMD_RAN=0
    
    local last_command="${HERO_LAST_CMD##[[:space:]]#}"
    (( ran )) || last_command=""
    
    # Update companion dialogue
    HeroNPC set_context $exit_status $ran
    HERO_CACHED_NPC_MSG=$(HeroNPC fetch)
    unset HEY_LISTEN HOL_NPC HERO_NPC_ARGS HERO_NPC_SESSION_FIRST_RUN
    
    # Process adventure rules only when a command actually ran
    HERO_CACHED_BATTLE_LOG=""
    if (( ran )); then
        HeroGame process $exit_status "$last_command" "$HERO_CACHED_NPC_MSG"
    fi
    HeroState cycle check
    _hero_load_pad
    HeroStatus refresh
    
    # Invalidate file-count cache immediately if last command touched trash or downloads
    if [[ "$last_command" =~ '^(sudo[[:space:]]+)?(b|b\+|b-|bomb|a|a!|a\+|CL)([[:space:]]|$)' ]]; then
        HERO_CACHE_TS=0
    fi
    HeroCache refresh
    
    # Pre-render every segment that doesn't change between commands
    local repo_status=$(HeroStatus environment) # tri_top|tri_bot|icon|text
    local tri_top tri_bot area_icon area_text
    IFS='|' read -r tri_top tri_bot area_icon area_text <<< "$repo_status"
    
    HERO_SEG[tri_top]="$tri_top"
    HERO_SEG[tri_bot]="$tri_bot"
    HERO_SEG[area_icon]="$area_icon"
    HERO_SEG[area_text]="$area_text"
    HERO_SEG[bombs]="$(HeroUI bombs)"
    HERO_SEG[rupee]="$(HeroUI rupee)"
    HERO_SEG[room_stats]="$(HeroUI room_stats)"
    HERO_SEG[hearts]="$(HeroStatus hearts)"
    HERO_SEG[arrows]="$(HeroUI arrows)"
    HERO_SEG[keys]="$(HeroUI keys)"
    HERO_SEG[location]="${hero_areas[map]} %F{cyan}$(HeroUI location)%f"
    
    # Companion dialogue
    local npc_key="" npc_msg="$HERO_CACHED_NPC_MSG"
    if [[ "$HERO_CACHED_NPC_MSG" == *"|"* ]]; then
        IFS='|' read -r npc_key npc_msg <<< "$HERO_CACHED_NPC_MSG"
    fi
    local npc_icon="${HERO_NPC_ICONS[navi]:-🧚}"
    if [[ -n "$npc_key" && -n "${HERO_NPC_ICONS[$npc_key]}" ]]; then
        npc_icon="${HERO_NPC_ICONS[$npc_key]}"
    fi
    HERO_SEG[npc]=""
    if [[ -n "${npc_msg// /}" ]]; then
        HERO_SEG[npc]="$npc_icon %F{242}$npc_msg %f"
    fi
    
    # Dual-line equipment stack
    local -a equipment_raw=("${(@f)$(HeroUI equipment_stack raw)}")
    HERO_SEG[equip_keys]="${equipment_raw[1]}"
    HERO_SEG[equip_icons]="${equipment_raw[2]}"
    
    # Interaction & prompt line
    local sword_sp=" "
    (( HERO_PAD == 1 )) && sword_sp="  "
    HERO_SEG[interaction]=" ${hero_areas[compass]} $(HeroUI compass $HERO_GIT_IN_REPO) %F{green}${hero_icons[sword]}${sword_sp}ƶ %f"
}

# ── Light work: every prompt AND every 1s tick. Must stay subshell-free. ──────
function _hero_render_prompt() {
    local REPLY
    _hero_cycle_day
    local -i day=$REPLY
    
    # Calculate gradient color for countdown headers based on 3-day cycle
    local -i now=${EPOCHSECONDS:-$(date +%s)}
    local h m s
    strftime -s h "%H" $now 2>/dev/null || h="00"
    strftime -s m "%M" $now 2>/dev/null || m="00"
    strftime -s s "%S" $now 2>/dev/null || s="00"
    local -i elapsed=$(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
    local -i seconds_left=$(( (86400 - elapsed) + ((3 - day) * 86400) ))
    _hero_tcolor $seconds_left 259200
    local time_color=$REPLY
    
    local suffix="th"
    case "$day" in
        1) suffix="st" ;;
        2) suffix="nd" ;;
        3) suffix="rd" ;;
    esac
    local day_seg=" ${time_color}${day}${suffix}%f "
    
    _hero_timer $day
    local timer_seg=$REPLY

    # Line 1 (Top Header Row)
    local -a row_top=(
        "${HERO_SEG[tri_top]}"
        "%F{red}-LIFE-%f"
        "${time_color}-DAY-%f"
        "${time_color}--TIME--%f"
        "┬"
        "${HERO_SEG[bombs]}"
        "${HERO_SEG[rupee]}"
        "┬"
        "${HERO_SEG[area_icon]}"
        "${HERO_SEG[area_text]}"
        "${HERO_SEG[room_stats]}"
    )
    
    # Line 2 (Values Row)
    local -a row_bot=(
        "${HERO_SEG[tri_bot]}"
        "${HERO_SEG[hearts]}"
        "$day_seg"
        "$timer_seg"
        "└"
        "${HERO_SEG[arrows]}"
        "${HERO_SEG[keys]}"
        "┘"
        "${HERO_SEG[location]}"
    )
    
    local cursor=$'%{\e[5 q%}'
    
    _hero_box_render \
        "${(j: :)row_top}" \
        "${(j: :)row_bot}" \
        "${HERO_SEG[npc]}" \
        "${HERO_SEG[equip_icons]}" \
        "${HERO_SEG[equip_keys]}" \
        "${HERO_SEG[interaction]}"

    # Set Final Prompt
    PROMPT="${HERO_CACHED_BATTLE_LOG}
${REPLY}${cursor}%f"
}

function _hero_precmd() {
    local -i exit_status=$?
    if (( ! HERO_TIMER_TICK )); then
        _hero_refresh_state $exit_status
    fi
    _hero_render_prompt
}

# ── Hook registration (coexists with other plugins' precmd/preexec hooks) ─────
autoload -Uz add-zsh-hook
# Older versions of this theme defined a bare precmd(); drop it on re-source so it
# doesn't run alongside the hook.
zmodload -F zsh/parameter p:functions_source 2>/dev/null
if (( $+functions[precmd] )) && [[ "${functions_source[precmd]}" == *hero-of-legend* ]]; then
    unfunction precmd
fi
add-zsh-hook precmd _hero_precmd
add-zsh-hook preexec _hero_preexec

# ------------------------------------------------------------------------------
# High-Performance Timer Engine (Hardware / Tick Discipline)
# ------------------------------------------------------------------------------
if [[ "${HERO_ENABLE_TICK:-1}" != "0" ]]; then
    TMOUT=1
    
    TRAPALRM() {
        # Flag timer tick so the prompt skips heavy operations (git, filesystem, I/O)
        HERO_TIMER_TICK=1
        { _hero_precmd; zle reset-prompt; } 2>/dev/null
        HERO_TIMER_TICK=0
    }
fi
