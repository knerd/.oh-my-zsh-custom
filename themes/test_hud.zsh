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
        "♦️ˣ000:6"
        "🧭 master:9"
        "🏺2:3"
        "🪜4:3"
        "♥️♥️🖤:6"
        "🏹ˣ08:5"
        "🗝️ˣ004:6"
        "🗺️~:3"
        "🎒:2"
        "🗡️ƶ:3"
        "🧙:2"
        "🧚:2"
        "⬆1:2"
        "⬇2:2"
        "➤:1"
    )
    
    local all_passed=1
    for tc in "${test_cases[@]}"; do
        local input="${tc%:*}"
        local expected="${tc#*:}"
        local actual=$(heroVisualWidth "$input")
        if (( actual != expected )); then
            echo "  FAIL: input='$input' expected=$expected actual=$actual"
            all_passed=0
        fi
    done
    if (( all_passed )); then
        echo "  PASS: All emoji and symbol character widths match expected terminal cells."
    fi
}

function test_hud_box_alignment() {
    export HERO_CACHE_TR=3
    export HERO_CACHE_DL=8
    export HERO_CACHE_KY=4
    export HERO_GIT_IN_REPO=1
    export HERO_GIT_DIRTY=1
    export HERO_GIT_REF="master"

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
    else
        echo "  FAIL: Could not locate HUD box lines in PROMPT."
    fi
}

echo "\n========== VERIFICATION OUTPUT =========="

echo "\n[TEST] Refined Color Logic Check"
test_countdown_logic 40000 # 11h -> Green
test_countdown_logic 28800 # 8h  -> Yellow
test_countdown_logic 10800 # 3h  -> Orange
test_countdown_logic 1800  # 30m -> Red

echo "\n[TEST] Emoji Character Width Check"
test_emoji_character_widths

echo "\n[TEST] HUD Box Alignment Check"
test_hud_box_alignment

echo "\n========== END VERIFICATION =========="
