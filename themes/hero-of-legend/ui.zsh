# ------------------------------------------------------------------------------
# Hero of Legend - UI Components & Box Renderer
# ------------------------------------------------------------------------------
# Quantum Capsule: ui.zsh
# Single Responsibility: HUD formatters, color gradients & box layout engine.
# ------------------------------------------------------------------------------

function HeroUI() {
    setopt local_options extended_glob
    local component="$1"; shift
    case "$component" in
        # Usage: HeroUI rupee
        rupee)
            local -i amount=$(HeroState wallet get)
            local color=$(HeroUI _threshold_color $amount 1000:yellow 500:242 300:red 100:blue 0:green)
            printf "%s%sˣ%03d%s" "$color" "${hero_icons[rupee]}" "$amount" "%f"
            ;;

        # Usage: HeroUI timer [day_number]
        timer)
            local -i day_number=${1:-1}
            local -i now=${EPOCHSECONDS:-$(date +%s)}
            local h m s
            strftime -s h "%H" $now 2>/dev/null || h="00"
            strftime -s m "%M" $now 2>/dev/null || m="00"
            strftime -s s "%S" $now 2>/dev/null || s="00"
            local -i elapsed=$(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
            local -i total_seconds=$(( 86400 - elapsed ))
            
            # If past the 3-day window, time is up
            if (( day_number > 3 )); then
                total_seconds=0
            fi

            local -i hours=$(( total_seconds / 3600 ))
            local -i minutes=$(( (total_seconds % 3600) / 60 ))
            local -i seconds=$(( total_seconds % 60 ))
            
            # Smooth dynamic gradients per time component
            printf "%s%02d%s:%s%02d%s:%s%02d%s" \
                "$(HeroUI _tcolor $hours 23)" $hours "%f" \
                "$(HeroUI _tcolor $minutes 59)" $minutes "%f" \
                "$(HeroUI _tcolor $seconds 59)" $seconds "%f"
            ;;

        # Usage: HeroUI day [day_number] [color]
        day)
            local -i day_number=${1:-1}
            local suffix="th"
            case "$day_number" in
                1) suffix="st" ;;
                2) suffix="nd" ;;
                3) suffix="rd" ;;
            esac
            
            local color="$2"
            if [[ -z "$color" ]]; then
                color=$(HeroUI _threshold_color $day_number 4:red 3:blue 0:white)
            fi
            echo -n " ${color}${day_number}${suffix}%f "
            ;;

        # Internal: Dynamic Gradient Color
        _tcolor)
            local -i value=${1:-0}
            local -i maximum=${2:-100}
            (( value > maximum )) && value=$maximum
            (( value < 0 )) && value=0
            local -i percent=$(( (value * 100) / maximum ))
            if (( percent >= 50 )); then
                # Green to Yellow
                printf '%%F{#%02x%02x00}' $(( 255 * (100 - percent) / 50 )) 255
            else
                # Yellow to Red
                printf '%%F{#%02x%02x00}' 255 $(( 255 * percent / 50 ))
            fi
            ;;

        # Internal: Threshold Color Picker
        # Usage: HeroUI _threshold_color VALUE threshold:color threshold:color ...
        _threshold_color)
            local -i value=${1:-0}; shift
            local result="%F{242}"
            for spec in "$@"; do
                local -i threshold="${spec%%:*}"
                local color="${spec#*:}"
                if (( value >= threshold )); then
                    result="%F{$color}"
                    break
                fi
            done
            echo "$result"
            ;;

        # Usage: HeroUI legend "ColorCode" "Label" "Line1" "Line2" ...
        # Dynamically sizes box to fit content perfectly
        legend)
            local color="%F{${1:-82}}"
            local label=" ${2:-HERO} "
            shift 2
            local -a lines=("$@")
            
            # Find maximum line width
            local -i max_content_width=${#label}
            for l in "${lines[@]}"; do
                [[ -z "$l" ]] && continue
                local -i lw=$(heroVisualWidth "$l")
                (( lw > max_content_width )) && max_content_width=$lw
            done
            
            local -i w=$(( max_content_width + 4 ))
            local -i label_len=${#label}
            local -i dash_count=$(( w - 2 - label_len ))
            (( dash_count < 0 )) && dash_count=0
            
            print -P "${color}╔═${label}$(printf '═%.0s' {1..$dash_count})╗%f"
            for line in "${lines[@]}"; do
                [[ -z "$line" ]] && continue
                local -i line_w=$(heroVisualWidth "$line")
                local -i pad=$(( w - 2 - line_w ))
                (( pad < 0 )) && pad=0
                print -P "${color}║%f ${line}${(l:pad:: :):-} ${color}║%f"
            done
            print -P "${color}╚$(printf '═%.0s' {1..$w})╝%f"
            ;;

        # Usage: HeroUI category_icons "category_name" "items_per_row"
        category_icons)
            local cat_name="$1"
            local -i items_per_row=${2:-5}
            local cat_data="${hero_categories[$cat_name]}"
            [[ -z "$cat_data" ]] && return
            
            local icon title color array_name menu_label
            IFS='|' read -r icon title color array_name menu_label <<< "$cat_data"
            
            local -a items=("${(@P)array_name}")
            local row=""
            local -i count=0
            
            for item in "${items[@]}"; do
                local item_icon="$(HeroInventory get "$item" icon)"
                local item_btn="$(HeroInventory get "$item" button)"
                local btn_padded="$(printf '%-2s' "$item_btn")"
                row+="${item_icon}${btn_padded}  "
                (( count++ ))
                if (( count % items_per_row == 0 )); then
                    echo "${row%%  }"
                    row=""
                fi
            done
            [[ -n "$row" ]] && echo "${row%%  }"
            ;;

        # Usage: HeroUI box "Title" "Line1" "Line2" ... --color red
        box)
            local title="$1"; shift
            local color="%F{red}"
            local -a lines=()
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --color) color="%F{$2}"; shift 2 ;;
                    *) lines+=("$1"); shift ;;
                esac
            done
            
            local -i max_len=30
            for l in "${lines[@]}"; do
                local -i lw=$(heroVisualWidth "$l")
                (( lw > max_len )) && max_len=$lw
            done
            
            local horizontal_bar=$(printf '─%.0s' {1..$max_len})
            echo "${color}┌─ ${title} ${horizontal_bar}${color}%f"
            for l in "${lines[@]}"; do
                echo "${color}│ %F{242}${l}%f"
            done
            echo "${color}└$(printf '─%.0s' {1..$((max_len + 4))})%f"
            ;;

        bombs)
            local count=$(HeroUI _cap "${HERO_CACHE_TR:-0}")
            if (( HERO_CACHE_TR > 20 )); then
                echo "%F{red}🧨ˣ${count}%f"
            else
                echo "%F{242}${hero_icons[bomb]}ˣ${count}%f"
            fi
            ;;

        arrows)
            echo "%F{242}${hero_icons[bow]}ˣ$(HeroUI _cap "${HERO_CACHE_DL:-0}")%f"
            ;;

        keys)
            local key_icon=$(HeroInventory get key icon)
            echo "%F{242}${key_icon}ˣ$(HeroUI _cap "${HERO_CACHE_KY:-0}")%f"
            ;;

        _cap)
            local count=$(heroDigitsOnly "$1")
            [[ -z "$count" ]] && count=0
            if (( 10#${count} > 999 )); then
                echo "999"
            else
                printf "%02d" $(( 10#${count} ))
            fi
            ;;

        location)
            local suffix=""
            [[ ! -w . ]] && suffix=" 🔒"
            echo "$(print -P "%~")${suffix}"
            ;;

        compass)
            local -i is_in_repo=${1:-0}
            local room_stats="%F{240}┤%F{242}${hero_icons[pot]}${HERO_CACHE_POT} ${hero_icons[ladder]}${HERO_CACHE_LADDER}%F{240}├%f"
            
            if (( is_in_repo )); then
                local branch_part="%F{green}${HERO_GIT_REF}%f"
                local sync_part=""
                (( HERO_GIT_AHEAD > 0 )) && sync_part+="%F{242}⬆${HERO_GIT_AHEAD}%f"
                (( HERO_GIT_BEHIND > 0 )) && sync_part+="%F{242}⬇${HERO_GIT_BEHIND}%f"
                
                if [[ -n "$sync_part" ]]; then
                    echo "${branch_part} ${sync_part} ${room_stats}"
                else
                    echo "${branch_part} ${room_stats}"
                fi
            else
                local dir_name="%F{green}%1~%f"
                echo "${dir_name} ${room_stats}"
            fi
            ;;

        equipped)
            local output=""
            local slot_val
            for slot_val in $(HeroState slots iterate); do
                if [[ -n "$slot_val" ]]; then
                    output+="$(HeroInventory get "$slot_val" icon)$(HeroInventory get "$slot_val" button) "
                fi
            done
            print -rn -- "$output"
            ;;

        equipment_stack)
            local mode="$1"
            local border_color="%F{240}"
            local text_color="%F{green}"
            local reset_color="%f"
            
            local top_content=""
            local bot_content=""
            local -a slot_items=("${(@f)$(HeroState slots list_lines)}")
            local -i equipped_count=0
            
            for slot_val in "${slot_items[@]}"; do
                [[ -z "$slot_val" ]] && continue
                
                local item_icon=$(HeroInventory get "$slot_val" icon)
                local item_btn=$(HeroInventory get "$slot_val" button)
                
                if (( equipped_count > 0 )); then
                    top_content+=" "
                    bot_content+=" "
                fi
                
                bot_content+="${item_icon}"
                top_content+="${text_color}$(printf '%-2s' "$item_btn")${reset_color}"
                (( equipped_count++ ))
            done

            if [[ "$mode" == "raw" ]]; then
                echo "$top_content"
                echo "$bot_content"
                return
            fi
            
            print -r -- "${border_color}┌${reset_color}${top_content}${border_color}┐${reset_color}"
            print -r -- "${border_color}└${reset_color}${bot_content}${border_color}┘${reset_color}"
            ;;

        # ═══════════════════════════════════════════════════════════════════════
        # Unified Pixel-Perfect HUD Box Renderer
        # ═══════════════════════════════════════════════════════════════════════
        box_render)
            local hud_top_row="${1%% #}"
            local hud_bot_row="${2%% #}"
            local npc_message="${3%% #}"
            local equip_icons="$4"
            local equip_keys="$5"
            local prompt_content="${6%% #}"
            
            local BORDER="%F{240}"
            local RESET="%f"
            
            # Line 3: Equipment Icons + Optional Companion Dialogue
            local line3_content=""
            if [[ -n "${equip_icons// /}" ]]; then
                line3_content="${equip_icons}${BORDER} ┬ ${RESET}"
            fi
            if [[ -n "${npc_message// /}" ]]; then
                line3_content+="${npc_message}"
            fi
            
            # Accurate Visual Column Widths
            local -i width1=$(heroVisualWidth "$hud_top_row")
            local -i width2=$(heroVisualWidth "$hud_bot_row")
            local -i width3=$(heroVisualWidth "$line3_content")
            
            # Reach from left edge (each prefix "┌ ", "│ ", "├ " is 2 columns)
            local -i reach1=$(( 2 + width1 ))
            local -i reach2=$(( 2 + width2 ))
            local -i reach3=$(( 2 + width3 ))
            
            local -i max_reach=$reach1
            (( reach2 > max_reach )) && max_reach=$reach2
            (( reach3 > max_reach )) && max_reach=$reach3
            
            # Exact paddings to right border
            local -i pad1=$(( max_reach - reach1 ))
            local -i pad2=$(( max_reach - reach2 ))
            local -i pad3=$(( max_reach - reach3 ))
            (( pad1 < 0 )) && pad1=0
            (( pad2 < 0 )) && pad2=0
            (( pad3 < 0 )) && pad3=0
            
            # Line 1: Top stats header row
            print -r -- "${BORDER}┌ ${RESET}${hud_top_row}${BORDER}${(l:pad1+1::─:):-}┐${RESET}"
            
            # Line 2: Values row
            print -r -- "${BORDER}│ ${RESET}${hud_bot_row}${(l:pad2+1:: :):-}${BORDER}│${RESET}"
            
            # Line 3: Equipment icons + NPC dialogue
            print -r -- "${BORDER}├ ${RESET}${line3_content}${BORDER}${(l:pad3+1::─:):-}┘${RESET}"
            
            # Line 4: Equipment keys + Realm interaction prompt
            if [[ -n "${equip_keys// /}" ]]; then
                print -rn -- "${BORDER}└ ${RESET}${equip_keys}${BORDER} ┘${RESET}${prompt_content}"
            else
                print -rn -- "${BORDER}└${RESET}${prompt_content}"
            fi
            ;;
    esac
}
