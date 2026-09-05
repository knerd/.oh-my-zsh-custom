# ------------------------------------------------------------------------------
# HERO OF LEGEND THEME - v2026.2.0 (Quantum Edition)
# ------------------------------------------------------------------------------
# Quantum-Atomic Architecture:
#   - Table-of-Contents Orchestrator
#   - Crystalline Service Capsules in ./hero-of-legend/
#   - 2-Stage Atomic Booleans & Discriminated States
#   - Sub-millisecond Prompt Lifecycle & Zero Subprocess Overhead
# ------------------------------------------------------------------------------

# 1. Environment & Path Resolution
typeset -g HERO_THEME_DIR="${0:A:h}/hero-of-legend"
[[ ! -d "$HERO_THEME_DIR" ]] && HERO_THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/hero-of-legend"

export PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin:$PATH"
autoload -U colors && colors 2>/dev/null

# 2. Source Supporting Libraries (Suppressed to prevent startup leakage)
[[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/_hero-helpers" ]] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/_hero-helpers"
[[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases/hero-shortcuts.alias.zsh" ]] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases/hero-shortcuts.alias.zsh"
[[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases/hero-arrows-alias.zsh" ]] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases/hero-arrows-alias.zsh"
[[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/hero-npc" ]] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/hero-npc" >/dev/null 2>&1

# 3. Source Crystalline Capsules
source "$HERO_THEME_DIR/core.zsh"
source "$HERO_THEME_DIR/config.zsh"
source "$HERO_THEME_DIR/state.zsh"
source "$HERO_THEME_DIR/status.zsh"
source "$HERO_THEME_DIR/cache.zsh"
source "$HERO_THEME_DIR/ui.zsh"
source "$HERO_THEME_DIR/inventory.zsh"
source "$HERO_THEME_DIR/game.zsh"
source "$HERO_THEME_DIR/npc.zsh"
source "$HERO_THEME_DIR/prompt.zsh"

# 4. Top-Level Command Aliases
alias o='HeroInventory open'
alias st='HeroState cycle reset'
alias snd='HeroState sound toggle'
alias sound='HeroState sound toggle'
alias hpad='HeroState heart_pad toggle'
function hpad() { HeroState heart_pad toggle "$@"; }
alias z+='z; if command -v hero-magic-chest >/dev/null 2>&1; then hero-magic-chest; else bash -c "$(curl -fsSL https://raw.githubusercontent.com/Knerd/hero-bin/master/hero-magic-chest)"; fi'
alias '???'='export HEY_LISTEN="???";'
alias fn='hero-font'

alias heroSplash="clear; echo '
       ()   ╔╦╗╦ ╦╔═╗  ╦  ╔═╗╔═╗╔═╗╔╗╔╔╦╗  ╔═╗╔═╗
       )(    ║ ╠═╣║╣   ║  ║╣ ║ ╦║╣ ║║║ ║║  ║ ║╠╣
     o====o  ╩ ╩ ╩╚═╝  ╩═╝╚═╝╚═╝╚═╝╝╚╝═╩╝  ╚═╝╚
     ██||███╗███████╗██╗  ██╗███████╗██╗     ██╗
     ╚═|███╔╝██╔════╝██║  ██║██╔════╝██║     ██║
       ███╔╝ ███████╗███████║█████╗  ██║     ██║
      ██|╔╝  ╚════██║██╔══██║██╔══╝  ██║     ██║
     ██||███╗███████║██║  ██║███████╗███████╗███████╗
     ╚═||═══╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
       \/              Oh-my & The Hero-of-Legend 👕
       
       Start Adventure (z+) | Equip Items (o) | Sound (snd)
'"

# 5. Theme Bootstrap
function HeroInitialize() {
    HeroInventory init
    HeroState slots init
    
    hero_last_histcmd=$HISTCMD
    HERO_NPC_SESSION_FIRST_RUN=1
    
    heroSplash
    
    if [[ -x "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/hero-song-of-time" ]]; then
        if (( $(HeroState sound get) == 1 )); then
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/bin/hero-song-of-time" startup >/dev/null 2>&1 &|
        fi
    fi
}

HeroInitialize
