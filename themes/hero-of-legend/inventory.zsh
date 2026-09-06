# ------------------------------------------------------------------------------
# Hero of Legend - Inventory Management Service
# ------------------------------------------------------------------------------
# Quantum Capsule: inventory.zsh
# Single Responsibility: Item registration, slot equipping & Charm Gum menus.
# ------------------------------------------------------------------------------

typeset -gA hero_icons
typeset -gA hero_buttons
typeset -gA hero_inventory
typeset -gA hero_desc
typeset -g HERO_MENU_SOUND_PID=""

function HeroInventory() {
    local action="$1"; shift
    case "$action" in
        # Usage: HeroInventory init
        init)
            local -a registry_keys=(${(k)hero_registry})
            local key val icon btn name desc clean_btn cmd_part
            for key in "${registry_keys[@]}"; do
                val="${hero_registry[$key]}"
                IFS='|' read -r icon btn name desc <<< "$val"
                HeroInventory register "$key" "$icon" "$btn" "$name" "$desc"
                
                # Safe Auto-Aliasing: Only alias if button is valid, non-empty, and command exists
                local clean_btn=$(heroTrim "$btn")
                local cmd_part="${desc%%:*}"
                if [[ -n "$clean_btn" && -n "$cmd_part" && "$clean_btn" != "?" && "$clean_btn" != "c" && "$clean_btn" != "o" && "$clean_btn" != "st" && "$clean_btn" != "z+" ]]; then
                    if ! alias "$clean_btn" >/dev/null 2>&1; then
                        alias "$clean_btn"="$cmd_part" 2>/dev/null
                    fi
                fi
            done
            ;;

        # Usage: HeroInventory register key icon btn name desc
        register)
            local key="$1" icon="$2" btn="$3" name="$4" desc="$5"
            [[ -n "$icon" ]] && hero_icons[$key]="$icon"
            [[ -n "$btn" ]]  && hero_buttons[$key]="$btn"
            [[ -n "$name" ]] && hero_inventory[$key]="$name"
            [[ -n "$desc" ]] && hero_desc[$key]="$desc"
            ;;

        # Usage: HeroInventory get itemKey property [default]
        get)
            local item_key="$1" property="$2" default="$3"
            case "$property" in
                icon)
                    local icon="${hero_icons[$item_key]:-${default:-❓}}"
                    if [[ "$item_key" == "key" || "$item_key" == "ladder" || "$item_key" == "sword" || "$item_key" == "shield" ]]; then
                        local -i pad=$(HeroState heart_pad get 2>/dev/null || echo 1)
                        (( pad == 1 )) && icon="${icon} "
                    fi
                    echo "$icon"
                    ;;
                button) echo "${hero_buttons[$item_key]:-${default:-?}}" ;;
                name)   echo "${hero_inventory[$item_key]:-${default:-Unknown}}" ;;
                desc)   echo "${hero_desc[$item_key]:-${default:-}}" ;;
            esac
            ;;

        # Usage: HeroInventory open
        open)
            local bin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin"
            if (( $(HeroState sound get) == 1 )) && [[ -x "$bin_dir/hero-song-of-time" ]]; then
                HeroInventory _stop_sound
                "$bin_dir/hero-song-of-time" storms >/dev/null 2>&1 &
                HERO_MENU_SOUND_PID=$!
            fi
            if command -v gum >/dev/null 2>&1; then
                HeroInventory _equip_with_gum
            else
                HeroInventory _equip_native
            fi
            HeroInventory _stop_sound
            ;;

        _stop_sound)
            if [[ -n "$HERO_MENU_SOUND_PID" ]]; then
                kill -TERM "$HERO_MENU_SOUND_PID" 2>/dev/null
                HERO_MENU_SOUND_PID=""
            fi
            ;;

        # ═══════════════════════════════════════════════════════════════════════
        # CHARM GUM INTERACTIVE EXPERIENCE
        # ═══════════════════════════════════════════════════════════════════════
        _equip_with_gum)
            clear
            
            local s1="⬛" s2="⬛" s3="⬛" s4="⬛"
            local slot1=$(HeroState slots get 1); [[ -n "$slot1" ]] && s1="$(HeroInventory get "$slot1" icon)"
            local slot2=$(HeroState slots get 2); [[ -n "$slot2" ]] && s2="$(HeroInventory get "$slot2" icon)"
            local slot3=$(HeroState slots get 3); [[ -n "$slot3" ]] && s3="$(HeroInventory get "$slot3" icon)"
            local slot4=$(HeroState slots get 4); [[ -n "$slot4" ]] && s4="$(HeroInventory get "$slot4" icon)"
            
            echo ""
            HeroUI legend "82" "BACKPACK" "Equipped:  $s1   $s2   $s3   $s4"
            echo ""
            
            local -i sound_state=$(HeroState sound get)
            local -i vol_level=$(HeroState sound volume)
            local sound_label="🔊  Audio & Volume Settings (${vol_level}% - ON)"
            if (( sound_state == 0 )); then
                sound_label="🔇  Audio & Volume Settings (${vol_level}% - OFF)"
            fi

            local main_choice
            main_choice=$(gum choose \
                --header "What would you like to do?" \
                --header.foreground 213 \
                --cursor.foreground 82 \
                --selected.foreground 82 \
                --height 9 \
                "🗡️  Equip Item" \
                "🔄  Swap Slots" \
                "🗑️  Unequip Slot" \
                "📜  View All Items" \
                "$sound_label" \
                "❌  Exit Chamber (Esc)")
            
            if [[ -z "$main_choice" ]]; then
                HeroInventory _stop_sound
                return
            fi
            
            case "$main_choice" in
                "🗡️  Equip Item")
                    HeroInventory _equip_item_flow
                    ;;
                "🔄  Swap Slots")
                    HeroInventory _swap_slots_flow
                    ;;
                "🗑️  Unequip Slot")
                    HeroInventory _unequip_slot_flow
                    ;;
                "📜  View All Items")
                    HeroInventory _view_all_items
                    HeroInventory _equip_with_gum
                    ;;
                *"Audio & Volume Settings"*|"$sound_label")
                    HeroInventory _stop_sound
                    HeroState sound interactive
                    HeroInventory _equip_with_gum
                    ;;
                *"Esc"*|*"Exit Chamber"*)
                    HeroInventory _stop_sound
                    gum style --foreground 245 --italic "  Safe travels, Hero!"
                    return
                    ;;
            esac
            ;;

        _equip_item_flow)
            clear
            
            # Active slots display
            local -a s=("⬛  " "⬛  " "⬛  " "⬛  ")
            local -i i
            local k
            for i in 1 2 3 4; do
                k=$(HeroState slots get $i)
                if [[ -n "$k" ]]; then
                    s[$i]="$(HeroInventory get "$k" icon)$(printf '%-2s' "$(HeroInventory get "$k" button)")"
                fi
            done

            local -i wl=36
            local -i wr=36
            
            _hero_box_line() {
                local content="$1" color="$2" width="$3"
                local -i cw=$(heroVisualWidth "$content")
                local -i pad=$(( width - 4 - cw ))
                (( pad < 0 )) && pad=0
                local pad_spaces="${(l:pad:: :):-}"
                local left_border="%F{$color}║%f "
                local right_border=" %F{$color}║%f"
                echo "${(%)left_border}${content}${pad_spaces}${(%)right_border}"
            }
            
            _hero_box_header() {
                local cat_id="$1" width="$2" type="$3" title_override="$4"
                local cat_data="${hero_categories[$cat_id]}"
                local h_icon h_title h_color h_array_name h_menu_label
                if [[ -n "$cat_data" ]]; then
                    IFS='|' read -r h_icon h_title h_color h_array_name h_menu_label <<< "$cat_data"
                else
                    h_icon="❓" h_title="$cat_id" h_color="240"
                fi
                [[ -n "$title_override" ]] && h_title="$title_override"
                
                local char="─" start="╓" end="╖" mid="─"
                case "$type" in
                    top)    start="╓" end="╖" mid="─" ;;
                    mid)    start="╟" end="╢" mid="─" ;;
                    double) start="╠" end="╣" mid="═"; char="═" ;;
                esac
                
                local -i tw=$(heroVisualWidth "$h_title")
                local -i dash_count=$(( width - 5 - tw ))
                (( dash_count < 0 )) && dash_count=0
                local dashes=$(printf "${char}%.0s" {1..$dash_count})
                local line="%F{$h_color}${start}${mid} ${h_title} ${dashes}${end}%f"
                echo "${(%)line}"
            }

            _hero_box_bottom() {
                local color="$1" width="$2"
                local -i dash_count=$(( width - 2 ))
                local dashes=$(printf '─%.0s' {1..$dash_count})
                local line="%F{$color}╙${dashes}╜%f"
                echo "${(%)line}"
            }

            _render_hud_column() {
                local side_arr_name="$1" width="$2" out_arr_name="$3" out_clr_name="$4"
                local -a side_arr=("${(@P)side_arr_name}")
                local last_clr="240" idx=1
                local -a lines=()
                local cID l
                
                for cID in "${side_arr[@]}"; do
                    if [[ "$cID" == "equipped" ]]; then
                        local l_data="${hero_categories[legend]:-🛡️|Legend|220|hero_cat_legend|Legend}"
                        local e_clr="${${${l_data#*|*}#*|*}%%|*}"
                        local h_type="mid"; (( idx == 1 )) && h_type="top"
                        lines+=("$(_hero_box_header legend "$width" "$h_type" "Equipped")")
                        lines+=("$(_hero_box_line "${s[1]}  ${s[2]}  ${s[3]}  ${s[4]}" "$e_clr" "$width")")
                        last_clr="$e_clr"
                        (( idx++ ))
                        continue
                    fi
                    
                    local m_data="${hero_categories[$cID]}"
                    [[ -z "$m_data" ]] && continue
                    
                    local m_clr="${${${m_data#*|*}#*|*}%%|*}"
                    local h_type="mid"; (( idx == 1 )) && h_type="top"
                    [[ "$cID" == "do" ]] && h_type="double"
                    
                    lines+=("$(_hero_box_header "$cID" "$width" "$h_type")")
                    local c_icons="$(HeroUI category_icons "$cID" 5)"
                    while IFS= read -r l; do
                        [[ -n "$l" ]] && lines+=("$(_hero_box_line "$l" "$m_clr" "$width")")
                    done <<< "$c_icons"
                    last_clr="$m_clr"
                    (( idx++ ))
                done
                
                eval "${out_arr_name}=(\"\${lines[@]}\")"
                eval "${out_clr_name}=\"\$last_clr\""
            }

            local -a left_lines right_lines
            local left_clr right_clr
            _render_hud_column hero_menu_left "$wl" left_lines left_clr
            _render_hud_column hero_menu_right "$wr" right_lines right_clr

            local -i max_content=${#left_lines[@]}
            (( ${#right_lines[@]} > max_content )) && max_content=${#right_lines[@]}

            while (( ${#left_lines[@]} < max_content )); do
                left_lines+=("$(_hero_box_line "" "$left_clr" "$wl")")
            done
            while (( ${#right_lines[@]} < max_content )); do
                right_lines+=("$(_hero_box_line "" "$right_clr" "$wr")")
            done

            left_lines+=("$(_hero_box_bottom "$left_clr" "$wl")")
            right_lines+=("$(_hero_box_bottom "$right_clr" "$wr")")

            echo ""
            local -i row_idx
            for ((row_idx=1; row_idx<=${#left_lines[@]}; row_idx++)); do
                echo "${left_lines[row_idx]}  ${right_lines[row_idx]}"
            done
            echo ""

            # Category Selection
            local -a menu_options
            local -a all_cats=("${hero_menu_left[@]}" "${hero_menu_right[@]}")
            local cID m_data m_icon m_title m_clr m_arr m_label
            for cID in "${all_cats[@]}"; do
                [[ "$cID" == "equipped" ]] && continue
                m_data="${hero_categories[$cID]}"
                [[ -z "$m_data" ]] && continue
                
                IFS='|' read -r m_icon m_title m_clr m_arr m_label <<< "$m_data"
                [[ -z "$m_label" ]] && m_label="$m_title"
                menu_options+=("$m_icon  $m_label")
            done
            menu_options+=("🔎  Search All Items" "⬅️  Back (Esc)")

            local category
            category=$(printf '%s\n' "${menu_options[@]}" | gum choose \
                --header "Choose a category:" \
                --header.foreground 245 \
                --cursor.foreground 214 \
                --selected.foreground 214 \
                --height 10)
            
            [[ -z "$category" || "$category" == *"Back"* || "$category" == *"Esc"* ]] && { HeroInventory _equip_with_gum; return; }
            
            local -a item_list
            if [[ "$category" == "🔎  Search All Items" ]]; then
                item_list=(${(k)hero_registry})
            else
                local cat_id cat_data icon title clr arr
                for cat_id in ${(k)hero_categories}; do
                    cat_data="${hero_categories[$cat_id]}"
                    if [[ "$cat_data" == *"${category#*  }"* ]]; then
                        IFS='|' read -r icon title clr arr m_label <<< "$cat_data"
                        item_list=("${(@P)arr}")
                        break
                    fi
                done
            fi
            
            clear
            gum style \
                --foreground 214 --border-foreground 240 \
                --border rounded --align center \
                --width 50 --margin "1 2" --padding "0 2" \
                "🎯  SELECT ITEM TO EQUIP"
            echo ""
            
            local -a display_items
            local item_key item_icon item_name item_btn
            for item_key in "${item_list[@]}"; do
                item_icon=$(HeroInventory get "$item_key" icon)
                item_name=$(HeroInventory get "$item_key" name)
                item_btn=$(HeroInventory get "$item_key" button)
                display_items+=("$item_icon  $item_name [$item_btn]")
            done
            display_items+=("⬅️   Back to Categories (Esc)")
            
            local selected_display
            if [[ "$category" == "🔎  Search All Items" ]]; then
                selected_display=$(printf '%s\n' "${display_items[@]}" | gum filter \
                    --header "Type to search:" \
                    --header.foreground 245 \
                    --indicator.foreground 82 \
                    --match.foreground 214 \
                    --height 15 \
                    --placeholder "🔍 Search items...")
            else
                selected_display=$(printf '%s\n' "${display_items[@]}" | gum choose \
                    --header "Select an item:" \
                    --header.foreground 245 \
                    --cursor.foreground 82 \
                    --selected.foreground 82 \
                    --height 12)
            fi
            
            [[ -z "$selected_display" || "$selected_display" == *"Back"* || "$selected_display" == *"Esc"* ]] && { HeroInventory _equip_item_flow; return; }
            
            local selected_item="" item_key icon name btn
            for item_key in "${item_list[@]}"; do
                icon=$(HeroInventory get "$item_key" icon)
                name=$(HeroInventory get "$item_key" name)
                btn=$(HeroInventory get "$item_key" button)
                if [[ "$selected_display" == "$icon  $name [$btn]"* || "$selected_display" == "$icon"* ]]; then
                    selected_item="$item_key"
                    break
                fi
            done
            
            [[ -z "$selected_item" ]] && { HeroInventory _equip_with_gum; return; }
            
            # Special case: Master Sword is always equipped
            if [[ "$selected_item" == "sword" ]]; then
                clear
                gum style \
                    --foreground 220 --border-foreground 220 \
                    --border double --align center \
                    --width 55 --margin "2" --padding "2 4" \
                    "🗡️  THE MASTER SWORD  🗡️" \
                    "" \
                    "This legendary blade is already equipped!" \
                    "" \
                    "Look to your prompt - the Master Sword" \
                    "is always at your side, ready for action." \
                    "" \
                    "Press 'z' to clear the screen."
                echo ""
                gum style --foreground 245 --italic "  Press any key to continue..."
                read -k 1
                HeroInventory _equip_with_gum
                return
            fi
            
            # Item Preview & Slot Selection
            clear
            local sel_icon=$(HeroInventory get "$selected_item" icon)
            local sel_name=$(HeroInventory get "$selected_item" name)
            local sel_btn=$(HeroInventory get "$selected_item" button)
            local sel_desc_full=$(HeroInventory get "$selected_item" desc)
            local sel_cmd="${sel_desc_full%%:*}"
            local sel_fun_desc="${sel_desc_full#*:}"
            [[ "$sel_fun_desc" == "$sel_desc_full" ]] && sel_fun_desc=""
            
            gum style \
                --foreground 82 --border-foreground 99 \
                --border rounded --align center \
                --width 55 --margin "1 2" --padding "1 2" \
                "$sel_icon $sel_name [$sel_btn]" \
                "" \
                "${sel_fun_desc:-No description}" \
                "" \
                "Runs: $sel_cmd"
            echo ""
            
            local -a slot_choices
            local -i slot_num
            local current_item cur_icon cur_name
            for slot_num in 1 2 3 4; do
                current_item=$(HeroState slots get $slot_num)
                if [[ -n "$current_item" ]]; then
                    cur_icon=$(HeroInventory get "$current_item" icon)
                    cur_name=$(HeroInventory get "$current_item" name)
                    slot_choices+=("Slot $slot_num: $cur_icon $cur_name (will replace)")
                else
                    slot_choices+=("Slot $slot_num: ⬜ Empty")
                fi
            done
            slot_choices+=("⬅️  Cancel (Esc)")
            
            local slot_choice
            slot_choice=$(printf '%s\n' "${slot_choices[@]}" | gum choose \
                --header "Select destination slot:" \
                --header.foreground 245 \
                --cursor.foreground 214 \
                --selected.foreground 214 \
                --height 8)
            
            [[ -z "$slot_choice" || "$slot_choice" == *"Cancel"* || "$slot_choice" == *"Esc"* ]] && { HeroInventory _equip_with_gum; return; }
            
            local target_slot="${slot_choice:5:1}"
            local existing_item=$(HeroState slots get $target_slot)
            local confirm_msg="Equip $sel_icon $sel_name to Slot $target_slot?"
            [[ -n "$existing_item" ]] && confirm_msg="Replace $(HeroInventory get "$existing_item" icon) $(HeroInventory get "$existing_item" name) with $sel_icon $sel_name?"
            
            echo ""
            if gum confirm "$confirm_msg" --affirmative "⚔️ Equip!" --negative "Cancel (Esc)"; then
                gum spin --spinner dot --title "⚡ Channeling ancient power..." -- sleep 0.6
                HeroState slots persist "$target_slot" "$selected_item"
                
                clear
                gum style \
                    --foreground 82 --border-foreground 82 \
                    --border double --align center \
                    --width 50 --margin "2" --padding "2 4" \
                    "✨ EQUIPMENT UPGRADED! ✨" \
                    "" \
                    "$sel_icon $sel_name" \
                    "equipped to Slot $target_slot"
                sleep 1.2
            fi
            
            HeroInventory _equip_with_gum
            ;;

        _swap_slots_flow)
            clear
            gum style \
                --foreground 81 --border-foreground 240 \
                --border rounded --align center \
                --width 50 --margin "1 2" --padding "0 2" \
                "🔄  SWAP EQUIPMENT SLOTS"
            echo ""
            
            local -a slot_displays
            local -i slot_num
            for slot_num in 1 2 3 4; do
                local item_key=$(HeroState slots get $slot_num)
                if [[ -n "$item_key" ]]; then
                    slot_displays+=("Slot $slot_num: $(HeroInventory get "$item_key" icon) $(HeroInventory get "$item_key" name)")
                else
                    slot_displays+=("Slot $slot_num: ⬜ Empty")
                fi
            done
            slot_displays+=("⬅️  Cancel (Esc)")
            
            local first_slot
            first_slot=$(printf '%s\n' "${slot_displays[@]}" | gum choose \
                --header "Select FIRST slot to swap:" \
                --header.foreground 245 \
                --cursor.foreground 81 \
                --selected.foreground 81 \
                --height 8)
            
            [[ -z "$first_slot" || "$first_slot" == *"Cancel"* || "$first_slot" == *"Esc"* ]] && { HeroInventory _equip_with_gum; return; }
            
            local second_slot
            second_slot=$(printf '%s\n' "${slot_displays[@]}" | gum choose \
                --header "Select SECOND slot to swap with:" \
                --header.foreground 245 \
                --cursor.foreground 214 \
                --selected.foreground 214 \
                --height 8)
            
            [[ -z "$second_slot" || "$second_slot" == *"Cancel"* || "$second_slot" == *"Esc"* ]] && { HeroInventory _equip_with_gum; return; }
            
            local slot1="${first_slot:5:1}"
            local slot2="${second_slot:5:1}"
            
            if [[ "$slot1" == "$slot2" ]]; then
                gum style --foreground 208 "  ⚠️  Cannot swap a slot with itself!"
                sleep 1
                HeroInventory _swap_slots_flow
                return
            fi
            
            local item1=$(HeroState slots get $slot1)
            local item2=$(HeroState slots get $slot2)
            
            gum spin --spinner dot --title "🔄 Swapping equipment..." -- sleep 0.4
            HeroState slots persist "$slot1" "$item2"
            HeroState slots persist "$slot2" "$item1"
            
            gum style \
                --foreground 82 --border-foreground 82 \
                --border rounded --align center \
                --width 50 --margin "1 2" --padding "1 2" \
                "✅ Slots swapped successfully!"
            sleep 1
            HeroInventory _equip_with_gum
            ;;

        _unequip_slot_flow)
            clear
            gum style \
                --foreground 203 --border-foreground 240 \
                --border rounded --align center \
                --width 50 --margin "1 2" --padding "0 2" \
                "🗑️  UNEQUIP A SLOT"
            echo ""
            
            local -a slot_displays
            local -i slot_num has_equipped=0
            for slot_num in 1 2 3 4; do
                local item_key=$(HeroState slots get $slot_num)
                if [[ -n "$item_key" ]]; then
                    slot_displays+=("Slot $slot_num: $(HeroInventory get "$item_key" icon) $(HeroInventory get "$item_key" name)")
                    has_equipped=1
                fi
            done
            
            if (( !has_equipped )); then
                gum style --foreground 245 --italic "  All slots are already empty."
                sleep 1.2
                HeroInventory _equip_with_gum
                return
            fi
            
            slot_displays+=("⬅️  Cancel (Esc)")
            
            local slot_choice
            slot_choice=$(printf '%s\n' "${slot_displays[@]}" | gum choose \
                --header "Select slot to clear:" \
                --header.foreground 245 \
                --cursor.foreground 203 \
                --selected.foreground 203 \
                --height 8)
            
            [[ -z "$slot_choice" || "$slot_choice" == *"Cancel"* || "$slot_choice" == *"Esc"* ]] && { HeroInventory _equip_with_gum; return; }
            
            local target_slot="${slot_choice:5:1}"
            local item_to_remove=$(HeroState slots get $target_slot)
            local remove_icon=$(HeroInventory get "$item_to_remove" icon)
            local remove_name=$(HeroInventory get "$item_to_remove" name)
            
            echo ""
            if gum confirm "Remove $remove_icon $remove_name from Slot $target_slot?" --affirmative "🗑️ Remove" --negative "Cancel (Esc)"; then
                gum spin --spinner dot --title "Unequipping..." -- sleep 0.4
                HeroState slots persist "$target_slot" ""
                gum style --foreground 82 "  ✅ Slot $target_slot is now empty."
                sleep 0.8
            fi
            
            HeroInventory _equip_with_gum
            ;;

        _view_all_items)
            clear
            local content=""
            content+="╔══════════════════════════════════════════════════════════════╗\n"
            content+="║              📜  HERO'S ITEM COMPENDIUM  📜                  ║\n"
            content+="╚══════════════════════════════════════════════════════════════╝\n\n"
            
            content+="┌─ 🏹 COMBAT & ARROWS ─────────────────────────────────────────┐\n"
            for item_key in bow firearrow lightarrow icearrow bomb sword shield; do
                local icon=$(HeroInventory get "$item_key" icon)
                local name=$(HeroInventory get "$item_key" name)
                local btn=$(HeroInventory get "$item_key" button)
                local desc=$(HeroInventory get "$item_key" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="┌─ 🧰 GIT TOOLS ────────────────────────────────────────────────┐\n"
            for item_key in hammer bean scroll mirror bottle boomerang magnet mushroom hookshot; do
                local icon=$(HeroInventory get "$item_key" icon)
                local name=$(HeroInventory get "$item_key" name)
                local btn=$(HeroInventory get "$item_key" button)
                local desc=$(HeroInventory get "$item_key" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="┌─ 🎒 UTILITIES ─────────────────────────────────────────────────┐\n"
            for item_key in lantern book flute trumpet marker key ring ocarina chest; do
                local icon=$(HeroInventory get "$item_key" icon)
                local name=$(HeroInventory get "$item_key" name)
                local btn=$(HeroInventory get "$item_key" button)
                local desc=$(HeroInventory get "$item_key" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="┌─ 🧭 EQUIPMENT & GEAR ──────────────────────────────────────────┐\n"
            for item_key in boots glove feather cape net flippers crystal shovel; do
                local icon=$(HeroInventory get "$item_key" icon)
                local name=$(HeroInventory get "$item_key" name)
                local btn=$(HeroInventory get "$item_key" button)
                local desc=$(HeroInventory get "$item_key" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            content+="                 Press 'q' or 'Esc' to exit the compendium\n"
            
            echo -e "$content" | gum pager
            ;;

        # ═══════════════════════════════════════════════════════════════════════
        # NATIVE ZSH TEXTUAL FALLBACK (Non-Gum environments)
        # ═══════════════════════════════════════════════════════════════════════
        _equip_native)
            clear
            print -P "%F{82}═══ HERO'S BACKPACK (Native Mode) ═══%f"
            print -P "Equipped:"
            for i in 1 2 3 4; do
                local k=$(HeroState slots get $i)
                if [[ -n "$k" ]]; then
                    print -P "  Slot $i: $(HeroInventory get "$k" icon) $(HeroInventory get "$k" name) [$(HeroInventory get "$k" button)]"
                else
                    print -P "  Slot $i: ⬜ Empty"
                fi
            done
            print -P "\nCommands:"
            print -P "  HeroState slots persist <1-4> <item_key>"
            print -P "  Example: HeroState slots persist 1 bow"
            print -P "\nPress any key to return..."
            read -k 1
            ;;
    esac
}
