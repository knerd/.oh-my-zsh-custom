# ------------------------------------------------------------------------------
# Hero of Legend - Core Services & Utilities
# ------------------------------------------------------------------------------
# Quantum Capsule: core.zsh
# Single Responsibility: Foundational runtime, datetime, safe I/O & string math.
# ------------------------------------------------------------------------------

# 1. Builtin Modules & Shell Options
zmodload -F zsh/datetime b:EPOCHSECONDS 2>/dev/null
setopt prompt_subst

# 2. State File Paths (with Writable Verification & Fallback)
function _hero_resolve_state_file() {
    local default_path="$1"
    local fallback_name="$2"
    local dir="${default_path:h}"
    
    # Check if target directory is writable, create if needed
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" 2>/dev/null
    fi
    
    if [[ -w "$dir" || ( ! -e "$default_path" && -w "${dir}" ) || -w "$default_path" ]]; then
        echo "$default_path"
    else
        local fallback_dir="${TMPDIR:-/tmp}/hero_state_${UID:-0}"
        mkdir -p "$fallback_dir" 2>/dev/null
        echo "${fallback_dir}/${fallback_name}"
    fi
}

local _default_wallet="${HERO_WALLET_FILE:-$HOME/.hero_wallet}"
[[ -z "$HERO_WALLET_FILE" && ! -f "$HOME/.hero_wallet" && -f "$HOME/.hero-wallet" ]] && _default_wallet="$HOME/.hero-wallet"
typeset -g hero_wallet_file="$(_hero_resolve_state_file "$_default_wallet" "wallet")"
typeset -g hero_cycle_file="$(_hero_resolve_state_file "${HERO_CYCLE_FILE:-$HOME/.hero_cycle}" "cycle")"
typeset -g hero_slots_file="$(_hero_resolve_state_file "${HERO_SLOTS_FILE:-$HOME/.hero_slots}" "slots")"
typeset -g hero_sound_file="$(_hero_resolve_state_file "${HERO_SOUND_FILE:-$HOME/.hero_sound}" "sound")"
typeset -g hero_heart_pad_file="$(_hero_resolve_state_file "${HERO_HEART_PAD_FILE:-$HOME/.hero_heart_pad}" "heart_pad")"

# 3. String & Number Utilities (Pure Native Zsh, Zero Subprocesses)
function heroTrim() {
    local str="$1"
    echo -n "${str// /}"
}

function heroDigitsOnly() {
    local str="$1"
    echo -n "${str//[^0-9]/}"
}

function heroIsBlank() {
    local str="$1"
    [[ -z "${str// /}" ]]
}

# 4. Pure Zsh Terminal Display Width Calculator
# Calculates accurate column width on screen for unicode, emojis, and ANSI escapes.
function heroVisualWidth() {
    setopt local_options extended_glob
    local raw="$1"
    
    # Expand prompt tokens (%F{...}, %B, %f, etc.)
    local expanded="${(%)raw}"
    
    # Strip ANSI escape sequences (\e[...m)
    expanded="${expanded//$'\e['[0-9;]##[a-zA-Z]/}"
    
    # Strip zero-width variation selector 16 (\uFE0F)
    local vs16=$'\xef\xb8\x8f'
    expanded="${expanded//$vs16/}"
    
    local -i width=0
    local -i len=${#expanded}
    local -i i=1
    
    while (( i <= len )); do
        local char="${expanded[i]}"
        local -i code=##$char
        
        # Zero-width codepoints: variation selectors, zero-width spaces
        if (( code == 0xfe0e || code == 0xfe0f || (code >= 0x200b && code <= 0x200f) )); then
            (( i++ ))
            continue
        fi
        
        # Wide codepoints (emojis, east asian characters, symbols)
        local -i is_wide=0
        if (( code == 0x1F5DD || code == 0x1FA9C || code == 0x1F5FA || \
              code == 0x1F5E1 || code == 0x1F58D || code == 0x1F6E1 || \
              code == 0x1FA83 || code == 0x1FA9E || code == 0x1FAD9 )); then
            # Emojis that occupy 1 column on Linux/glibc terminals (key, ladder, map, sword, marker, shield, boomerang, mirror, jar):
            # In padded mode (current_pad == 1), their character code counts as 1 (with space = 2).
            # In unpadded mode (current_pad == 0), they occupy 2 columns directly.
            local -i current_pad=$(HeroState heart_pad get 2>/dev/null || echo 1)
            (( current_pad == 0 )) && is_wide=1
        elif (( (code >= 0x1F000 && code <= 0x1FAFF) || \
              (code >= 0x2E80 && code <= 0x9FFF) || \
              (code >= 0xF900 && code <= 0xFAFF) || \
              code == 0x26A1 || code == 0x2728 )); then
            is_wide=1
        elif (( code == 0x2764 || code == 0x2665 )); then
            # If heart padding is disabled (Unicode 9+ mode), red heart occupies 2 columns directly
            local -i current_pad=$(HeroState heart_pad get 2>/dev/null || echo 1)
            (( current_pad == 0 )) && is_wide=1
        fi

        if (( is_wide )); then
            (( width += 2 ))
        else
            (( width += 1 ))
        fi
        (( i++ ))
    done
    
    echo "$width"
}
