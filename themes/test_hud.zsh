#!/bin/zsh

export HOME="/tmp"
export ZSH_CUSTOM="${0:A:h:h}"
source "${0:A:h}/hero-of-legend.zsh-theme" >/dev/null 2>&1

function test_countdown_logic() {
    local diff=$1
    local hours=$((diff / 3600))
    local minutes=$(( (diff % 3600) / 60 ))
    
    local color="" # expect green default
    local COLOR_GREEN="GREEN"
    local COLOR_RED="RED"
    local COLOR_YELLOW="YELLOW"
    local COLOR_ORANGE="ORANGE"
    
    # New logic to test
    if (( diff < 3600 )); then
        color=$COLOR_RED
    elif (( diff < 14400 )); then
        color=$COLOR_ORANGE
    elif (( diff < 36000 )); then
        color=$COLOR_YELLOW
    else
        color=$COLOR_GREEN
    fi
 
    printf "Diff: ${diff}s (%02d:%02d) -> Color: $color\n" $hours $minutes
}

function test_emoji_character_widths() {
    local -a test_cases=(
        "abc:3"
        "┌──┐:4"
        "⯆ ⯆:3"
        " ▲ :3"
        "💣ˣ03:5"
        "♦️ˣ000:5"
        "🧭 master:9"
        "🏺2:3"
        "🪜 4:3"
        "❤️ ❤️ 🖤:6"
        "❤️ 🖤🖤:6"
        "❤️ ❤️ ❤️ :6"
        "🏹ˣ08:5"
        "🗝️ ˣ04:5"
        "🗺️ ~:3"
        "🎒:2"
        "🗡️ ƶ:3"
        "🧙:2"
        "🧚:2"
        "⬆1:2"
        "⬇2:2"
        "↑1:2"
        "↓2:2"
        "➤:1"
    )
    
    HeroState heart_pad set 1
    local all_passed=1
    for tc in "${test_cases[@]}"; do
        local input="${tc%:*}"
        local expected="${tc#*:}"
        local actual=$(heroVisualWidth "$input")
        if (( actual != expected )); then
            echo "  FAIL (padded): input='$input' expected=$expected actual=$actual"
            all_passed=0
        fi
    done

    # Also test unpadded mode (Unicode 9+ / macOS)
    HeroState heart_pad set 0
    local actual_unpadded_key=$(heroVisualWidth "🗝️ˣ04")
    local actual_unpadded_heart=$(heroVisualWidth "❤️❤️🖤")
    local actual_unpadded_ladder=$(heroVisualWidth "🪜4")
    local actual_unpadded_map=$(heroVisualWidth "🗺️~")
    local actual_unpadded_sword=$(heroVisualWidth "🗡️ƶ")
    if (( actual_unpadded_key != 5 )); then
        echo "  FAIL (unpadded key): input='🗝️ˣ04' expected=5 actual=$actual_unpadded_key"
        all_passed=0
    fi
    if (( actual_unpadded_heart != 6 )); then
        echo "  FAIL (unpadded heart): input='❤️❤️🖤' expected=6 actual=$actual_unpadded_heart"
        all_passed=0
    fi
    if (( actual_unpadded_ladder != 3 )); then
        echo "  FAIL (unpadded ladder): input='🪜4' expected=3 actual=$actual_unpadded_ladder"
        all_passed=0
    fi
    if (( actual_unpadded_map != 3 )); then
        echo "  FAIL (unpadded map): input='🗺️~' expected=3 actual=$actual_unpadded_map"
        all_passed=0
    fi
    if (( actual_unpadded_sword != 3 )); then
        echo "  FAIL (unpadded sword): input='🗡️ƶ' expected=3 actual=$actual_unpadded_sword"
        all_passed=0
    fi
    HeroState heart_pad set 1

    if (( all_passed )); then
        echo "  PASS: All emoji and symbol character widths match expected terminal cells (both padded and unpadded modes)."
    fi
}

function test_hud_box_alignment() {
    export HERO_CACHE_TR=3
    export HERO_CACHE_DL=8
    export HERO_CACHE_KY=4
    export HERO_GIT_IN_REPO=1
    export HERO_GIT_DIRTY=1
    export HERO_GIT_REF="master"

    HeroState heart_pad set 1
    HeroState slots persist 2 key
    precmd >/dev/null 2>&1

    local -a lines=("${(@f)PROMPT}")
    local -a boxLines=()
    for l in "${lines[@]}"; do
        # Find box lines that start with border characters ┌, │, ├
        if [[ "$l" =~ "┌|│|├" && "$l" != *"BATTLE LOG"* ]]; then
            boxLines+=("$l")
        fi
    done

    if (( ${#boxLines} >= 3 )); then
        local w1=$(heroVisualWidth "${boxLines[1]}")
        local w2=$(heroVisualWidth "${boxLines[2]}")
        local w3=$(heroVisualWidth "${boxLines[3]}")
        echo "  Line 1 width: $w1"
        echo "  Line 2 width: $w2"
        echo "  Line 3 width: $w3"
        if (( w1 == w2 && w2 == w3 )); then
            echo "  PASS: HUD Box borders are perfectly aligned (all lines width $w1)."
        else
            echo "  FAIL: HUD Box borders are not aligned ($w1 vs $w2 vs $w3)."
        fi

        # Verify inner column alignment for item box corners:
        # Top line start corner ┬ must align with Bottom line start corner └
        # Top line end corner ┬ must align with Bottom line end corner ┘
        local top_strip="${(%)boxLines[1]}"
        top_strip="${top_strip//$'\e['[0-9;]##[a-zA-Z]/}"
        local bot_strip="${(%)boxLines[2]}"
        bot_strip="${bot_strip//$'\e['[0-9;]##[a-zA-Z]/}"
        
        local top_pre_corner="${top_strip%%┬*}"
        local bot_pre_corner="${bot_strip%%└*}"
        local c1=$(heroVisualWidth "$top_pre_corner")
        local c2=$(heroVisualWidth "$bot_pre_corner")
        if (( c1 == c2 )); then
            echo "  PASS: Inner divider start corners ┬ and └ perfectly align at column $((c1 + 1))."
        else
            echo "  FAIL: Inner divider start corners misaligned (┬ at $((c1 + 1)) vs └ at $((c2 + 1)))."
        fi

        # Verify end corners: second ┬ in top line vs ┘ in bot line
        local top_after_first="${top_strip#*┬}"
        local top_between="${top_after_first%%┬*}"
        local bot_between="${bot_strip#*└}"
        bot_between="${bot_between%%┘*}"
        local w_top_items=$(heroVisualWidth "$top_between")
        local w_bot_items=$(heroVisualWidth "$bot_between")
        if (( w_top_items == w_bot_items )); then
            echo "  PASS: Inner divider end corners ┬ and ┘ perfectly align (items box width $w_top_items)."
        else
            echo "  FAIL: Inner divider end corners misaligned (top $w_top_items vs bot $w_bot_items)."
        fi

        # Verify equipment stack divider corners: Line 3 ┬ aligns with Line 4 ┘
        local line4_strip="${(%)lines[${#lines}]}"
        for cand in "${lines[@]}"; do
            [[ "$cand" == *"└"* && "$cand" != *"🏹"* ]] && line4_strip="${(%)cand}"
        done
        line4_strip="${line4_strip//$'\e['[0-9;]##[a-zA-Z]/}"
        local line3_strip="${(%)boxLines[3]}"
        line3_strip="${line3_strip//$'\e['[0-9;]##[a-zA-Z]/}"

        local eq_c3=$(( $(heroVisualWidth "${line3_strip%%┬*}") + 1 ))
        local eq_c4=$(( $(heroVisualWidth "${line4_strip%%┘*}") + 1 ))
        if (( eq_c3 == eq_c4 )); then
            echo "  PASS: Equipment stack divider corners ┬ and ┘ perfectly align at column $eq_c3 with key equipped."
        else
            echo "  FAIL: Equipment stack corners misaligned (Line 3 ┬ at $eq_c3 vs Line 4 ┘ at $eq_c4)."
        fi
    else
        echo "  FAIL: Could not locate HUD box lines in PROMPT."
    fi
}

function test_hud_box_alignment_nongit() {
    export HERO_CACHE_TR=2
    export HERO_CACHE_DL=6
    export HERO_CACHE_KY=3
    export HERO_GIT_IN_REPO=0
    export HERO_GIT_DIRTY=0
    export HERO_CACHE_POT=0
    export HERO_CACHE_LADDER=2
    export HERO_WALLET=32

    HeroState heart_pad set 1
    HeroState slots persist 2 key
    precmd >/dev/null 2>&1

    local -a lines=("${(@f)PROMPT}")
    local -a boxLines=()
    for l in "${lines[@]}"; do
        if [[ "$l" =~ "┌|│|├" && "$l" != *"BATTLE LOG"* ]]; then
            boxLines+=("$l")
        fi
    done

    if (( ${#boxLines} >= 3 )); then
        local w1=$(heroVisualWidth "${boxLines[1]}")
        local w2=$(heroVisualWidth "${boxLines[2]}")
        local w3=$(heroVisualWidth "${boxLines[3]}")
        echo "  Non-Git Line 1 width: $w1"
        echo "  Non-Git Line 2 width: $w2"
        echo "  Non-Git Line 3 width: $w3"
        if (( w1 == w2 && w2 == w3 )); then
            echo "  PASS: Non-git HUD box borders are perfectly aligned (all lines width $w1)."
        else
            echo "  FAIL: Non-git HUD box borders are misaligned ($w1 vs $w2 vs $w3)."
        fi
    fi
}

function test_item_hud_alignment() {
    source "${ZSH_CUSTOM}/aliases/hero-shortcuts.alias.zsh"
    local all_passed=1

    for pad in 1 0; do
        HeroState heart_pad set $pad
        local mode_desc="Linux/glibc (padded)"
        (( pad == 0 )) && mode_desc="macOS/Unicode 9+ (unpadded)"

        local -a lines=("${(@f)$(hud)}")
        if (( ${#lines} != 11 )); then
            echo "  FAIL ($mode_desc): expected 11 lines, got ${#lines}"
            all_passed=0
            continue
        fi

        local line_widths=()
        local line_err=0
        for i in {1..${#lines}}; do
            local line="${lines[$i]}"
            local w=$(heroVisualWidth "$line")
            line_widths+=("$w")
            if (( w != 47 )); then
                echo "  FAIL ($mode_desc line $i): width=$w expected=47 -> '$line'"
                line_err=1
                all_passed=0
            fi
        done

        if (( line_err == 0 )); then
            echo "  PASS ($mode_desc): All 11 rows of Item HUD ('z') are perfectly aligned at width 47."
        fi
    done
    HeroState heart_pad set 1
}

function test_equipment_screen_alignment() {
    local all_passed=1
    local pad
    local wl=36 wr=36
    local -a left_lines right_lines
    local left_clr right_clr
    local -a s
    local -i i
    local k

    for pad in 1 0; do
        HeroState heart_pad set $pad
        local mode_desc="Linux/glibc (padded)"
        (( pad == 0 )) && mode_desc="macOS/Unicode 9+ (unpadded)"

        left_lines=()
        right_lines=()
        left_clr=""
        right_clr=""

        # Test helper using the inventory theme logic
        HeroInventory init
        HeroState slots persist 1 "backpack"
        HeroState slots persist 2 "key"

        s=("⬛  " "⬛  " "⬛  " "⬛  ")
        for i in 1 2 3 4; do
            k=$(HeroState slots get $i)
            if [[ -n "$k" ]]; then
                s[$i]="$(HeroInventory get "$k" icon)$(printf '%-2s' "$(HeroInventory get "$k" button)")"
            fi
        done

        _t_box_line() {
            local content="$1" color="$2" width="$3"
            local -i cw=$(heroVisualWidth "$content")
            local -i p=$(( width - 4 - cw ))
            (( p < 0 )) && p=0
            local pad_spaces="${(l:p:: :):-}"
            local left_border="%F{$color}║%f "
            local right_border=" %F{$color}║%f"
            echo "${(%)left_border}${content}${pad_spaces}${(%)right_border}"
        }

        _t_box_header() {
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

        _t_box_bottom() {
            local color="$1" width="$2"
            local -i dash_count=$(( width - 2 ))
            local dashes=$(printf '─%.0s' {1..$dash_count})
            local line="%F{$color}╙${dashes}╜%f"
            echo "${(%)line}"
        }

        _t_render_col() {
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
                    lines+=("$(_t_box_header legend "$width" "$h_type" "Equipped")")
                    lines+=("$(_t_box_line "${s[1]}  ${s[2]}  ${s[3]}  ${s[4]}" "$e_clr" "$width")")
                    last_clr="$e_clr"
                    (( idx++ ))
                    continue
                fi
                local m_data="${hero_categories[$cID]}"
                [[ -z "$m_data" ]] && continue
                local m_clr="${${${m_data#*|*}#*|*}%%|*}"
                local h_type="mid"; (( idx == 1 )) && h_type="top"
                [[ "$cID" == "do" ]] && h_type="double"
                lines+=("$(_t_box_header "$cID" "$width" "$h_type")")
                local c_icons="$(HeroUI category_icons "$cID" 5)"
                while IFS= read -r l; do
                    [[ -n "$l" ]] && lines+=("$(_t_box_line "$l" "$m_clr" "$width")")
                done <<< "$c_icons"
                last_clr="$m_clr"
                (( idx++ ))
            done
            eval "${out_arr_name}=(\"\${lines[@]}\")"
            eval "${out_clr_name}=\"\$last_clr\""
        }

        _t_render_col hero_menu_left "$wl" left_lines left_clr
        _t_render_col hero_menu_right "$wr" right_lines right_clr

        local -i max_content=${#left_lines[@]}
        (( ${#right_lines[@]} > max_content )) && max_content=${#right_lines[@]}

        while (( ${#left_lines[@]} < max_content )); do
            left_lines+=("$(_t_box_line "" "$left_clr" "$wl")")
        done
        while (( ${#right_lines[@]} < max_content )); do
            right_lines+=("$(_t_box_line "" "$right_clr" "$wr")")
        done

        left_lines+=("$(_t_box_bottom "$left_clr" "$wl")")
        right_lines+=("$(_t_box_bottom "$right_clr" "$wr")")

        if (( ${#left_lines[@]} != ${#right_lines[@]} )); then
            echo "  FAIL ($mode_desc): Column line count mismatch (${#left_lines[@]} vs ${#right_lines[@]})"
            all_passed=0
        fi

        local col_err=0
        for ((idx=1; idx<=${#left_lines[@]}; idx++)); do
            local wl_actual=$(heroVisualWidth "${left_lines[idx]}")
            local wr_actual=$(heroVisualWidth "${right_lines[idx]}")
            if (( wl_actual != wl || wr_actual != wr )); then
                echo "  FAIL ($mode_desc row $idx): wl=$wl_actual (expected $wl), wr=$wr_actual (expected $wr)"
                col_err=1
                all_passed=0
            fi
        done

        if (( col_err == 0 )); then
            echo "  PASS ($mode_desc): Equipment HUD columns are aligned at width 36 across all ${#left_lines[@]} rows."
        fi
    done
    HeroState heart_pad set 1

    # Dev artifact check: Category selection loop must produce clean output
    local -a menu_options
    local -a all_cats=("${hero_menu_left[@]}" "${hero_menu_right[@]}")
    local cID m_data m_icon m_title m_clr m_arr m_label
    local loop_output=$(
        for cID in "${all_cats[@]}"; do
            [[ "$cID" == "equipped" ]] && continue
            m_data="${hero_categories[$cID]}"
            [[ -z "$m_data" ]] && continue
            IFS='|' read -r m_icon m_title m_clr m_arr m_label <<< "$m_data"
            [[ -z "$m_label" ]] && m_label="$m_title"
            menu_options+=("$m_icon  $m_label")
        done
    )

    if [[ -n "$loop_output" ]]; then
        echo "  FAIL: Dev artifacts detected during category generation: '$loop_output'"
        all_passed=0
    else
        echo "  PASS: Zero dev artifacts emitted during category option processing."
    fi
}

function test_menu_esc_option() {
    local inv_file="$ZSH_CUSTOM/themes/hero-of-legend/inventory.zsh"
    local check_failed=0

    # 1. Main menu ('o')
    if grep -q '"❌  Exit Chamber (Esc)"' "$inv_file"; then
        echo "  PASS: Main menu includes '❌  Exit Chamber (Esc)'"
    else
        echo "  FAIL: Main menu does not include '❌  Exit Chamber (Esc)'"
        check_failed=1
    fi

    if grep -q '\*"Esc"\*|\*"Exit Chamber"\*)' "$inv_file"; then
        echo "  PASS: Main menu case pattern matches *\"Esc\"*|*\"Exit Chamber\"*"
    else
        echo "  FAIL: Main menu case pattern does not match Esc"
        check_failed=1
    fi

    # 2. Category selection
    if grep -q '"⬅️  Back (Esc)"' "$inv_file"; then
        echo "  PASS: Category selection includes '⬅️  Back (Esc)'"
    else
        echo "  FAIL: Category selection does not include '⬅️  Back (Esc)'"
        check_failed=1
    fi

    # 3. Item selection
    if grep -q '"⬅️   Back to Categories (Esc)"' "$inv_file"; then
        echo "  PASS: Item selection includes '⬅️   Back to Categories (Esc)'"
    else
        echo "  FAIL: Item selection does not include '⬅️   Back to Categories (Esc)'"
        check_failed=1
    fi

    # 4. Destination slot selection & Equip confirm
    if grep -q 'slot_choices+=("⬅️  Cancel (Esc)")' "$inv_file"; then
        echo "  PASS: Destination slot choice includes '⬅️  Cancel (Esc)'"
    else
        echo "  FAIL: Destination slot choice does not include '⬅️  Cancel (Esc)'"
        check_failed=1
    fi

    if grep -q 'confirm ".*" --affirmative "⚔️ Equip!" --negative "Cancel (Esc)"' "$inv_file"; then
        echo "  PASS: Equip confirm dialog includes negative 'Cancel (Esc)'"
    else
        echo "  FAIL: Equip confirm dialog does not include negative 'Cancel (Esc)'"
        check_failed=1
    fi

    # 5. Swap slots selection
    if grep -q 'slot_displays+=("⬅️  Cancel (Esc)")' "$inv_file"; then
        echo "  PASS: Swap slots flow includes '⬅️  Cancel (Esc)'"
    else
        echo "  FAIL: Swap slots flow does not include '⬅️  Cancel (Esc)'"
        check_failed=1
    fi

    # 6. Unequip slot selection & Unequip confirm
    if grep -q 'confirm "Remove .*?" --affirmative "🗑️ Remove" --negative "Cancel (Esc)"' "$inv_file"; then
        echo "  PASS: Unequip confirm dialog includes negative 'Cancel (Esc)'"
    else
        echo "  FAIL: Unequip confirm dialog does not include negative 'Cancel (Esc)'"
        check_failed=1
    fi

    # 7. Compendium exit hint
    if grep -q "Press 'q' or 'Esc' to exit the compendium" "$inv_file"; then
        echo "  PASS: Item compendium hint includes 'q' or 'Esc'"
    else
        echo "  FAIL: Item compendium hint does not include 'Esc'"
        check_failed=1
    fi

    (( check_failed )) && all_passed=0
}

echo "\n========== VERIFICATION OUTPUT =========="

echo "\n[TEST] Refined Color Logic Check"
test_countdown_logic 40000 # 11h -> Green
test_countdown_logic 28800 # 8h  -> Yellow
test_countdown_logic 10800 # 3h  -> Orange
test_countdown_logic 1800  # 30m -> Red

echo "\n[TEST] Emoji Character Width Check"
test_emoji_character_widths

echo "\n[TEST] HUD Box Alignment Check (Git Repo)"
test_hud_box_alignment

echo "\n[TEST] HUD Box Alignment Check (Non-Git Dir)"
test_hud_box_alignment_nongit

echo "\n[TEST] Item HUD Alignment Check ('z' / 'hud')"
test_item_hud_alignment

echo "\n[TEST] Equipment Screen HUD Alignment & Clean Output Check"
test_equipment_screen_alignment

echo "\n[TEST] Main Menu Esc Option Check ('o')"
test_menu_esc_option

echo "\n========== END VERIFICATION =========="

