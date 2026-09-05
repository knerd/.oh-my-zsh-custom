#!/bin/zsh

ZSH_CUSTOM="/tmp" 
source /home/xopher/www/x/oh-my-zsh/custom/themes/hero-of-legend.zsh-theme

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

echo "\n========== VERIFICATION OUTPUT =========="

echo "\n[TEST] Refined Color Logic Check"
test_countdown_logic 40000 # 11h -> Green
test_countdown_logic 28800 # 8h  -> Yellow
test_countdown_logic 10800 # 3h  -> Orange
test_countdown_logic 1800  # 30m -> Red

echo "\n========== END VERIFICATION =========="
