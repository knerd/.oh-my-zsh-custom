# ------------------------------------------------------------------------------
# Hero of Legend - Configuration & Registry
# ------------------------------------------------------------------------------
# Quantum Capsule: config.zsh
# Single Responsibility: Declarative item registry, icons, categories & tokens.
# ------------------------------------------------------------------------------

# 1. Realm Areas
typeset -gA hero_areas=(
    castle  "🏰"
    dungeon "💀"
    compass "🧭"
    map     "🗺️"
)

# 2. Comprehensive Item Registry
# Format: [key]="ICON|BUTTON|NAME|COMMAND:FUN_DESCRIPTION"
typeset -gA hero_registry=(
    # === HUD & CORE ===
    [sword]="🗡️|z|Magic Sword|clear:The blade that never leaves your side. Clears the screen and awaits your command."
    [shield]="🛡️|s|Magic Shield|omz reload:Deflect corruption! Reloads Oh-My-Zsh to restore your defenses."
    [tunic]="🥻|c|Hero's Tunic|:The essence of the Hero of Legend theme. Your journey and your identity in this terminal realm."
    [backpack]="🎒|o|Backpack|HeroInventory open:Your trusty adventurer's pack! Open it to manage your equipment and discover new items."

    # === ARROWS ===
    [bow]="🏹|a|Magic Bow|arw:Loose an arrow straight to ~/Downloads. Shows file count and lands you there instantly!"
    [firearrow]="🔥|a!|Fire Arrow|hero-fire-arrows:🎮 ARCHERY MINI-GAME! Select targets, time your shots, earn points & rupees."
    [lightarrow]="⚡|a+|Light Arrow|source hero-light-arrow:Create warp points! Name your arrow (a.docs) to teleport back instantly."
    [icearrow]="❄️|a-|Ice Arrow|hero-ice-arrow:Freeze your changes with git stash! View, thaw, or melt frozen work anytime."
    [bomb]="💣|b|Magic Bombs|bomb:Explosive trash management! 'b' detonates the bin, 'b+' moves to trash, 'b-' peeks inside."

    # === GIT CUTS ===
    [hammer]="🔨|A|Magic Hammer|git add:Forge your changes into the staging area. Pound files into git's index!"
    [bean]="🌱|B|Magic Bean|git checkout -b:Plant a new branch! Watch it grow from a tiny seed into a mighty feature."
    [scroll]="📜|C|Magic Scroll|git commit -m:Inscribe your changes into the ancient scrolls of version history."
    [mirror]="🪞|D|Magic Mirror|git diff:Gaze into the mirror to see what has changed. Reveals all modifications."
    [bottle]="🫙|M|Magic Bottle|git merge:Capture another branch's essence and merge it into your current timeline."
    [boomerang]="🪃|P|Magic Boomerang|git push:Fling your commits to the remote! They always come back... eventually."
    [magnet]="🧲|p|Magnetic Gloves|git pull:Attract remote changes with magnetic force. Pull commits right to you!"
    [mushroom]="🍄|S|Magic Mushroom|git status:Reveals the current state of your repository. What's staged? What's changed?"
    [hookshot]="🪝|CO|Hookshot|git checkout:Grapple onto any branch or commit! Instantly teleport through git history."

    # === UTILITIES ===
    [lantern]="🏮|L|Magic Lantern|ls -la:Illuminate the darkness! Reveals ALL files, even the hidden ones lurking in shadows."
    [book]="📘|h|Book of Spells|history | grep:Search the ancient texts of command history. Find that spell you cast before!"
    [lens]="🔍|f|Lens of Truth|find . | grep:Search for files matching your query."
    [portal]="🌀|lt|Magic Portal|lt:Expose local ports to the world."
    [marker]="🖍️|m|Magic Marker|mark:Scribble quick notes! Saves code snippets to ~/hero-magic-marker for later."
    [ocarina]="🎵|st|Ocarina of Time|HeroState cycle reset:Play the Song of Time! Resets the 3-day cycle back to Dawn of the First Day."
    [chest]="🪄|z+|Magic Chest|hero-magic-chest:Open the legendary chest to download or update Hero tools!"
    [crystal]="🔮|t|Crystal Ball|htop:Peer into system resources! Opens htop (or top) to see what's running."
    [flute]="🪈|fl|Magic Flute|echo 'Playing the flute...':Summon the bird to carry you across the terminal."
    [trumpet]="🎺|lt|Magic Trumpet|lt:Use LocalTunnel to open a publicly accessible portal to any local port."
    [font]="🔤|fn|Magic Quill|hero-font:Inscribe your terminal with ancient MesloLGS Nerd Font runes."

    # === NAVIGATION & GEAR ===
    [key]="🗝️|k|Small Key|hero-magic-key:Unlock passage upward! k goes up 1 dir, k2-k9 climbs that many levels."
    [boots]="🥾|?|Pegasus Boots|?:Run the Help Menu at lightning speed! Master all shortcuts and become unstoppable."
    [ring]="💍|R|Blue Ring|source ~/.zshrc:Channel the ring's power to reload your .zshrc. Refresh your magic!"
    [exit]="💥|x|Magic Quake|exit:Quake the terminal with a dramatic farewell."
    [glove]="🥊|G|Power Glove|powerGloves:Heavy lifting! Clears vendor & node_modules, then runs package manager."
    [feather]="🪶|j|Magic Feather|z:Leap with grace! Jump to a directory using z (zoxide/autojump)."
    [cape]="🧣|H|Magic Cape|hide:Vanish from sight! Toggle visibility of HUD elements."
    [net]="🕸️|n|Magic Net|n:Catch those pesky bugs! Toggle Navi's messages on/off."
    [shovel]="⛏️|d|Magic Shovel|dirs -v:Dig into your directory stack! Shows where you have been."
    [cat]="🐈|ct|Magic Cat|cat:A helpful companion that displays file contents."

    # === ARTIFACTS & UPCOMING ===
    [flippers]="🤿|v|Magic Flippers|:Coming Soon! Dive into the deep web with VPN protection."
    [somaria]="🦯|r|Cane of Somaria|reset:Coming Soon! Clear your terminal path with magic blocks."
    [powder]="✨|CO|Magic Powder|git checkout:Transform branches with a sprinkle of magic powder."
    [amulet]="🧿|am|Magic Amulet|:Ancient protective talisman warding off runtime errors."
    [rupee]="♦️||Rupee|:Earn rupees by running successful commands!"

    # === HUD INDICATORS ===
    [pot]="🏺||Pot|:Files in the current directory. Smash them to see what is inside!"
    [ladder]="🪜||Ladder|:Subdirectories to explore. Climb deeper into the dungeon!"
)

# 3. Inventory Categories
# Format: ID "Icon|DisplayTitle|Color|ArrayName|MenuLabel"
typeset -gA hero_categories=(
    git     "🎒|Items|117|hero_cat_git|Items"
    utils   "🎒|Utils|80|hero_cat_utils|Utilities"
    do      "🧭|Do|196|hero_cat_do|Navigation"
    legend  "🛡️|Gear|117|hero_cat_legend|Gear"
    arrows  "🏹|Arrows|120|hero_cat_arrows|Arrows"
    special "💍|Accessories|117|hero_cat_special|Accessories"
    soon    "✨|Coming Soon|242|hero_cat_soon|New Items"
)

# 4. Menu Column Layouts
typeset -ga hero_menu_left=(git arrows do)
typeset -ga hero_menu_right=(equipped legend special)

typeset -ga hero_cat_git=(
    bow boomerang hookshot bomb mushroom
    bean magnet scroll net book
    lantern hammer ocarina lens shovel
    bottle cape marker cat mirror
)

typeset -ga hero_cat_utils=(
    shovel lens book lantern marker font
)

typeset -ga hero_cat_arrows=(
    firearrow lightarrow icearrow exit
)

typeset -ga hero_cat_do=(
    boots glove flippers crystal feather
)

typeset -ga hero_cat_legend=(
    sword shield tunic backpack
)

typeset -ga hero_cat_soon=(
    flippers somaria powder amulet
)

typeset -ga hero_cat_special=(
    key ring portal chest flute trumpet
)

# 5. Triforce & Visual Styling Tokens
typeset -g tri_color="${TRI_COLOR:-yellow}"
typeset -g tri_top_norm="%B%F{${tri_color}} ▲ %f%b"
typeset -g tri_bot_norm="%B%F{${tri_color}}▲ ▲%f%b"
typeset -g tri_top_git="%B%F{${tri_color}}⯆ ⯆%f%b"
typeset -g tri_bot_git="%B%F{${tri_color}} ⯆ %f%b"

# Git Sync Indicators
typeset -g hero_git_ahead_icon="${HERO_GIT_AHEAD_ICON:-↑}"
typeset -g hero_git_behind_icon="${HERO_GIT_BEHIND_ICON:-↓}"
typeset -g hero_git_ahead_color="${HERO_GIT_AHEAD_COLOR:-cyan}"
typeset -g hero_git_behind_color="${HERO_GIT_BEHIND_COLOR:-red}"

