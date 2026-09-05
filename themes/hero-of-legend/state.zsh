# ------------------------------------------------------------------------------
# Hero of Legend - State Management Service
# ------------------------------------------------------------------------------
# Quantum Capsule: state.zsh
# Single Responsibility: Wallet, Majora 3-day cycle & slot persistence.
# ------------------------------------------------------------------------------

# Global Slots Cache
typeset -gx HERO_SLOT_1=""
typeset -gx HERO_SLOT_2=""
typeset -gx HERO_SLOT_3=""
typeset -gx HERO_SLOT_4=""

# Internal helper to get midnight timestamp for today
function _hero_get_today_midnight() {
    local -i now=${EPOCHSECONDS:-$(date +%s)}
    local h m s
    strftime -s h "%H" $now 2>/dev/null || h="00"
    strftime -s m "%M" $now 2>/dev/null || m="00"
    strftime -s s "%S" $now 2>/dev/null || s="00"
    local -i elapsed=$(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
    echo $(( now - elapsed ))
}

function HeroState() {
    local service="$1"; shift
    case "$service" in
        # Usage: HeroState wallet [get|set|adjust] [value]
        wallet)
            local op="$1"; shift
            case "$op" in
                get)
                    if [[ -f "$hero_wallet_file" ]]; then
                        local raw_val
                        raw_val="$(<"$hero_wallet_file")"
                        echo "${raw_val:-0}"
                    else
                        echo "0"
                    fi
                    ;;
                set)
                    local -i new_balance=${1:-0}
                    (( new_balance < 0 )) && new_balance=0
                    echo "$new_balance" >| "$hero_wallet_file" 2>/dev/null
                    ;;
                adjust)
                    local -i diff=${1:-0}
                    local -i current=$(HeroState wallet get)
                    HeroState wallet set $(( current + diff ))
                    ;;
            esac
            ;;

        # Usage: HeroState cycle [day|reset|check]
        cycle)
            local op="$1"; shift
            case "$op" in
                day)
                    local -i midnight=$(_hero_get_today_midnight)
                    if [[ ! -f "$hero_cycle_file" ]]; then
                        echo "$midnight" >| "$hero_cycle_file" 2>/dev/null
                    fi
                    
                    local -i start_ts=0
                    if [[ -f "$hero_cycle_file" ]]; then
                        start_ts=$(<"$hero_cycle_file")
                    fi
                    
                    if (( start_ts <= 0 || start_ts > midnight )); then
                        start_ts=$midnight
                        echo "$start_ts" >| "$hero_cycle_file" 2>/dev/null
                    fi
                    
                    echo $(( ((midnight - start_ts) / 86400) + 1 ))
                    ;;
                reset)
                    print -P "%F{cyan}🎼 Playing the Song of Time...%f"
                    if [[ -x "$ZSH_CUSTOM/bin/hero-song-of-time" ]]; then
                        "$ZSH_CUSTOM/bin/hero-song-of-time"
                    else
                        printf "\a"; sleep 0.2; printf "\a"; sleep 0.2; printf "\a"
                    fi
                    local -i midnight=$(_hero_get_today_midnight)
                    echo "$midnight" >| "$hero_cycle_file" 2>/dev/null
                    print -P "%F{green}You have returned to the dawn of the First Day.%f"
                    ;;
                check)
                    local -i current_day=$(HeroState cycle day)
                    if (( current_day > 3 )); then
                        print -P "\n%F{red}🌑 The Moon has crashed. You've met with a terrible fate, haven't you?%f"
                        print -P "%F{yellow}Play the Song of Time (st) to return to the Dawn of the First Day.%f\n"
                    fi
                    ;;
            esac
            ;;

        # Usage: HeroState slots [init|persist|get|list_lines|iterate|status]
        slots)
            local op="$1"; shift
            case "$op" in
                init)
                    HERO_SLOT_1="" HERO_SLOT_2="" HERO_SLOT_3="" HERO_SLOT_4=""
                    if [[ -f "$hero_slots_file" ]]; then
                        source "$hero_slots_file" 2>/dev/null
                    else
                        # Default starting gear: backpack in Slot 1
                        HERO_SLOT_1="backpack"
                        printf '%s\n' \
                            "HERO_SLOT_1=\"${HERO_SLOT_1}\"" \
                            "HERO_SLOT_2=\"${HERO_SLOT_2}\"" \
                            "HERO_SLOT_3=\"${HERO_SLOT_3}\"" \
                            "HERO_SLOT_4=\"${HERO_SLOT_4}\"" \
                            >| "$hero_slots_file" 2>/dev/null
                    fi
                    export HERO_SLOT_1 HERO_SLOT_2 HERO_SLOT_3 HERO_SLOT_4
                    ;;
                persist)
                    local slot_number="$1"
                    local item_key="$2"
                    case "$slot_number" in
                        1) HERO_SLOT_1="$item_key" ;;
                        2) HERO_SLOT_2="$item_key" ;;
                        3) HERO_SLOT_3="$item_key" ;;
                        4) HERO_SLOT_4="$item_key" ;;
                    esac
                    
                    printf '%s\n' \
                        "HERO_SLOT_1=\"${HERO_SLOT_1}\"" \
                        "HERO_SLOT_2=\"${HERO_SLOT_2}\"" \
                        "HERO_SLOT_3=\"${HERO_SLOT_3}\"" \
                        "HERO_SLOT_4=\"${HERO_SLOT_4}\"" \
                        >| "$hero_slots_file" 2>/dev/null
                    ;;
                get)
                    # CRITICAL FIX: Bind argument to local variable slotNum
                    local slotNum="$1"
                    case "$slotNum" in
                        1) echo "$HERO_SLOT_1" ;;
                        2) echo "$HERO_SLOT_2" ;;
                        3) echo "$HERO_SLOT_3" ;;
                        4) echo "$HERO_SLOT_4" ;;
                        *) echo "" ;;
                    esac
                    ;;
                list_lines)
                    print -l "$HERO_SLOT_1" "$HERO_SLOT_2" "$HERO_SLOT_3" "$HERO_SLOT_4"
                    ;;
                iterate)
                    echo "$HERO_SLOT_1 $HERO_SLOT_2 $HERO_SLOT_3 $HERO_SLOT_4"
                    ;;
                status)
                    local item_key="$1"
                    if [[ -n "$item_key" && -n "${hero_icons[$item_key]}" ]]; then
                        echo "${hero_icons[$item_key]} ${hero_buttons[$item_key]}"
                    else
                        echo "Empty"
                    fi
                    ;;
            esac
            ;;
    esac
}
