# ------------------------------------------------------------------------------
# Hero of Legend - Prompt Engine & Lifecycle Hooks
# ------------------------------------------------------------------------------
# Quantum Capsule: prompt.zsh
# Single Responsibility: precmd prompt composition & zero-overhead timer loop.
# ------------------------------------------------------------------------------

typeset -g HERO_TIMER_TICK=0
typeset -g HERO_PROMPT_CACHED_BASE=""

function precmd() {
    local -i exit_status=$?
    
    # ── Stage 1: Atomic Concept Declarations ──────────────────────
    local -i is_timer_tick=$HERO_TIMER_TICK
    local -i has_first_run=${HERO_NPC_SESSION_FIRST_RUN:-0}
    
    # ── Stage 2: Unified Decision & State Branching ───────────────
    if (( ! is_timer_tick )); then
        # Extract last command safely without subshells
        local last_command="${${(f)"$(fc -ln -1 2>/dev/null)"}##[[:space:]]#}"
        
        # Update companion dialogue
        HeroNPC set_context $exit_status
        HERO_CACHED_NPC_MSG=$(HeroNPC fetch)
        unset HEY_LISTEN HOL_NPC HERO_NPC_ARGS HERO_NPC_SESSION_FIRST_RUN
        
        # Process adventure rules, moon cycle, git status & metrics
        HERO_CACHED_BATTLE_LOG=""
        HeroGame process $exit_status "$last_command" "$HERO_CACHED_NPC_MSG"
        HeroState cycle check
        HeroStatus refresh
        
        # Invalidate file-count cache immediately if last command touched trash or downloads
        if [[ "$last_command" =~ '^(b|bomb|sudo[[:space:]]+b|sudo[[:space:]]+bomb|a|a!|a\+|CL)' ]]; then
            HERO_CACHE_TS=0
        fi
        HeroCache refresh
    fi
    
    # ── Stage 3: Prompt Construction & Formatting ─────────────────
    local companion_msg="$HERO_CACHED_NPC_MSG"
    local battle_log="$HERO_CACHED_BATTLE_LOG"
    
    local -i day=$(HeroState cycle day)
    local repo_status=$(HeroStatus environment) # tri_top|tri_bot|icon|text
    
    # Unpack environment status
    local tri_top tri_bot area_icon area_text
    IFS='|' read -r tri_top tri_bot area_icon area_text <<< "$repo_status"
    
    # Calculate gradient color for countdown headers based on 3-day cycle
    local -i now=${EPOCHSECONDS:-$(date +%s)}
    local h m s
    strftime -s h "%H" $now 2>/dev/null || h="00"
    strftime -s m "%M" $now 2>/dev/null || m="00"
    strftime -s s "%S" $now 2>/dev/null || s="00"
    local -i elapsed=$(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
    local -i seconds_left=$(( (86400 - elapsed) + ((3 - day) * 86400) ))
    local time_color=$(HeroUI _tcolor $seconds_left 259200)

    # Line 1 (Top Header Row)
    local -a row_top=(
        "$tri_top"
        "%F{red}-LIFE-%f"
        "${time_color}-DAY-%f"
        "${time_color}--TIME--%f"
        "┬"
        "$(HeroUI bombs)"
        "$(HeroUI rupee)"
        "┬"
        "$area_icon"
        "$area_text"
        "$(HeroUI room_stats)"
    )
    
    # Line 2 (Values Row)
    local -a row_bot=(
        "$tri_bot"
        "$(HeroStatus hearts)"
        "$(HeroUI day $day $time_color)"
        "$(HeroUI timer $day)"
        "└"
        "$(HeroUI arrows)"
        "$(HeroUI keys)"
        "┘"
        "${hero_areas[map]} %F{cyan}$(HeroUI location)%f"
    )
    
    # Process Companion Dialogue
    local npc_key="" npc_msg="$companion_msg"
    if [[ "$companion_msg" == *"|"* ]]; then
        IFS='|' read -r npc_key npc_msg <<< "$companion_msg"
    fi
    
    local npc_icon="${HERO_NPC_ICONS[navi]:-🧚}"
    if [[ -n "$npc_key" && -n "${HERO_NPC_ICONS[$npc_key]}" ]]; then
        npc_icon="${HERO_NPC_ICONS[$npc_key]}"
    fi
    
    local row_end_content=""
    if [[ -n "${npc_msg// /}" ]]; then
        row_end_content="$npc_icon %F{242}$npc_msg %f"
    fi
    
    # Assemble Dual-Line Equipment Stack
    local -a equipment_raw=("${(@f)$(HeroUI equipment_stack raw)}")
    local equipment_keys="${equipment_raw[1]}"
    local equipment_icons="${equipment_raw[2]}"
    
    # Build Interaction & Prompt Line
    local -i pad=$(HeroState heart_pad get 2>/dev/null || echo 1)
    local sword_sp=" "
    (( pad == 1 )) && sword_sp="  "
    local interaction_content=" ${hero_areas[compass]} $(HeroUI compass $HERO_GIT_IN_REPO) %F{green}${hero_icons[sword]}${sword_sp}ƶ %f"
    local cursor=$'%{\e[5 q%}'
    
    local box_output
    box_output=$(HeroUI box_render \
        "${(j: :)row_top}" \
        "${(j: :)row_bot}" \
        "$row_end_content" \
        "$equipment_icons" \
        "$equipment_keys" \
        "$interaction_content")

    # Set Final Prompt
    PROMPT="${battle_log}
${box_output}${cursor}%f"
}

# ------------------------------------------------------------------------------
# High-Performance Timer Engine (Hardware / Tick Discipline)
# ------------------------------------------------------------------------------
if [[ "${HERO_ENABLE_TICK:-1}" != "0" ]]; then
    TMOUT=1
    
    TRAPALRM() {
        # Flag timer tick so precmd skips heavy operations (git, filesystem, I/O)
        HERO_TIMER_TICK=1
        { precmd; zle reset-prompt; } 2>/dev/null
        HERO_TIMER_TICK=0
    }
fi
