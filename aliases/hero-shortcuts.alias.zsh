# ** Nerd fonts used in comment below
#  理[ A| B|ﯜ C| CO|繁 D| f| h| M| P| p|ﭾ S| CL| x]

: '/////////////////// Heads Up Display //////////////////////////'
: '
 ┌┬─┐
 ├┼─┤
 └┴ ─┘
'

# Classic
# alias hud="echo '
# ┌💍 HUD ──a─────────────────┐  ┌Crystals──┐
# │ 🏹 a 🪃 P 🎣 p 💣 b  🍄 S │  │   💎 💎  │
# │ 🔥a! ⚡ a+ 🌀 g ✨ CO 💥 x │  │ 💎 💎 💎 │
# │ 🔦 f 🔨 A 🎺 lt🖍 n 📗 h  │  │   💎 💎  │
# │️ 🫙 M 🌱 B 📜 C 🪞 D       │
# ├ EQUIPMENT  ───────────────┤  ┌EQUIPPED──┐
# │ 🥾 ?  🥊 e   🤿 v  🔮 t   │  │ 💍 🛡️ 👕 │
# └───────────────────────────┘  └──────────┘
# '"

# Modern
alias hud="echo ' 
┌ 💍 HUD ───────────────────┐  ┌ CRYSTALS ┐
│ 🏹 a 💣 b 🔑 k 🗡 z 💥 x  │  │  💎 💎   │  
├ 🎒 ITEMS  ────────────────┤  │ 💎 💎 💎 │
│ 🔥 a! 🔦 f 🎺 lt          │  │   💎 💎  │     
│ ⚡ a+ 📗 h 🖍 m           │  ├ PENDANTS ┤
├ 🧰 GIT TOOLS ─────────────┤  │ 💍 👑 🔱️ │
│ 🌀 g 🪃 P 🎣 p ✨ CO 🍄 S │  ├ EQUIPPED ┤
│ 🔨 A 🌱 B 📜 C 🪞 D  🫙 M │  │ 🗡 🛡️ 👕 │
├ 🤺 DO ────────────────────┤  ├ DUNGEON ─┤
│ 🥾 ?  🥊 G  🤿 v  🔮 t    │  │ 🗺️ 🧭 🔑 │ 
└───────────────────────────┘  └──────────┘ 
'"

# o and z+ aliases are now handled in the theme file to ensure consistent integration with the inventory and magic chest systems.

# Clear terminal
alias CL='clear'

# Toggle HUD items
alias i="((HERO_HIDE_ITEMS=!HERO_HIDE_ITEMS)); CL;"
alias c="((HERO_HIDE_CLOCK=!HERO_HIDE_CLOCK)); CL;"
alias n="((HERO_HIDE_NAVI=!HERO_HIDE_NAVI)); CL;"
alias i-="((HERO_HIDE_EVERYTHING=!HERO_HIDE_EVERYTHING));((HERO_HIDE_ITEMS=HERO_HIDE_EVERYTHING)); CL;"

# Clear terminal show hud
alias z="CL; hud"
# Hash-pinned remote execution for safety
# z+ and o are now handled in the theme file.

# Close terminal
alias x='exit'

# Magic Arrows
alias arw="cd ~/Downloads 2>/dev/null || cd ~; ls -l; echo '🏹 ---> Nice shot! Straight to Downloads. 🎯'"
alias a="arw"
alias a!="hero-fire-arrows"
alias a+="source hero-light-arrow"
alias a-="hero-ice-arrow"

# Magic Bomb
alias bomb="hero-magic-bomb"
alias b=bomb
alias b\?="bomb --help"
alias b!="bomb !"
alias b-="bomb l"
alias b+="bomb file"

# "Keys"
alias k="source hero-magic-key"
alias k2="k 2"
alias k3="k 3"
alias k4="k 4"
alias k5="k 5"
alias k6="k 6"
alias k7="k 7"
alias k8="k 8"
alias k9="k 9"

: '/////////////////// ITEMS //////////////////////////'
# Magic Marker
alias mark="source hero-magic-marker"
alias m="mark"
alias m-="mark -d"

# Magic Font (Nerd Font Provisioner)
alias fn="hero-font"

# Find things
# Find a file recursively
alias f='find . | grep '
alias F='f'

# Find an old command
alias h='history | grep '
alias H='h'

#### Add git shortcuts - listed in hero-of-legend zsh-theme terminal
alias A='git add '
alias B='git checkout -b'
alias C='git commit -m '
alias CO='git checkout '
alias D='git diff '
alias M='git merge '
alias P='git push'
alias p='git pull'
alias S='git status '

# GIT FLOW
alias g@="git remote add "
alias g="git flow "
alias g-="g init"
alias g.="g release "
alias g+="g feature "
alias g!="g hotfix "
alias g\?="g bugfix"
alias g+s="g+ start"
alias g+p="g+ publish"
alias g+f="g+ finish"
alias g!s="g! start"
alias g!p="g! publish"
alias g!f="g! finish"
alias g\?s="g? start"
alias g\?p="g? publish"
alias g\?f="g? finish"
alias g\.s="g. start"
alias g\.p="g. publish"
alias g\.f="g. finish"

# GEAR
alias G="powerGloves"
# Overwrite powerGloves with your own custom heavy lifting commands
powerGloves() {
    b+ vendor
    b+ node_modules
    yarn
}

alias t='launchTop'
launchTop() { if [ -x "$(command -v htop)" ]; then htop; else top; fi; }

: '///////////// ALIASES for HELP /////////////'
declare -A HERO_HELP=(
    # HUD
    [a]="🏹 a  - Arrows: # of files in ~/Downloads; a/arw is a direct shot to ~/Downloads"
    [b]="💣 b  - Magic Bombs: # of Gigs in Trash; b/bomb blows up the trash bin, b+ [FILE] moves file to trash, b- lists trash"
    [k]="🗝️ k  - Magic Keys: # of child directories; k[2-9] # of keys cd .. that many times."
    [z]="🗡️ z  - Magic Sword: Wipes the screen, shows your inventory, and awaits your next command."
    [x]="💥 x  - Quake: Close the terminal"

    # ITEMS
    ["a+"]="⚡️ a+ - Light Arrows: Bookmark Direct Travel to any location at the speed of light"
    ["a!"]="🔥 a! - Fire Arrows: Burn through all your downloads - one at a time. Uses rm -i."
    [f]="🔦 f  - Magic Lantern aka Flashlight: Search the castle for files that match"
    [h]="📗 h  - Magic Book of History: Search through the history of CLI command inputs"
    [m]="🖍️ m  - Magic Marker: Quickly save code snippets. m/mark [snippet] Saves to ~/hero-magic-marker"
    [lt]="🎺 lt - Magic Trumpet: Use LocalTunnel to open a pubically accessible portal to any local port."

    # GIT TOOLS
    [A]="🔨 A  - Magic Hammer: git add"
    [B]="🌱 B  - Magic Bean:   git checkout -b"
    [C]="📜 C  - Magic Scroll: git commit -m"
    [CO]="✨ CO - Magic Powder: git checkout"
    [D]="🪞 D  - Magic Mirror: git diff"
    [g]="🌀 g  - Git Flow:   git flow; g-,g+,g!,g?,g."
    ["g-"]="🌀 g  - Git Flow: git flow init"
    ["g+"]="🌀 g  - Git Flow: git flow feature; g+s g+f g+p"
    ["g!"]="🌀 g  - Git Flow: git flow hotfix; g!s g!f g!p"
    ["g?"]="🌀 g  - Git Flow: git flow bugfix; g?s g?f g?p"
    ["g."]="🌀 g  - Git Flow: git flow release;  g.s g.f g.p"
    [M]="🫙 M  - Magic Bottle: git merge"
    [P]="🪃 P  - Magic Boomerang: git push"
    [p]="🎣 p  - Magic? Fishing Poll: git pull"
    [S]="🍄 S  - Magic Mushroom: git status"

    # GEAR
    [G]="🥊 G  - Power Glove: Custom Heavy Lifting command. Default: rm vendor; rm node_modules; yarn"
    [v]="🤿 v  - Flippers: Coming Soon* Throw on your flippers(VPN) and take a secure dive into the deep web."
    [t]="🔮 t  - Crystal Ball: Shortcut to HTop or Top"
    [R]="💍 R  - Blue Ring: Reload your .zshrc and refresh the magic."
    [L]="🏮 L  - Magic Lantern: List all files including hidden ones (ls -la)."
    ["z+"]="🧰 z+ - Magic Chest: Open the chest to download/update Hero tools."
)

# Help
alias \?z="echo '${HERO_HELP[z]}'"
alias \?k="echo '${HERO_HELP[k]}'"
alias \?b="echo '${HERO_HELP[b]}'"
alias \?a="echo '${HERO_HELP[a]}'"
alias \?x="echo '${HERO_HELP[x]}'"
alias \?f="echo '${HERO_HELP[f]}'"
alias \?h="echo '${HERO_HELP[h]}'"
alias \?m="echo '${HERO_HELP[m]}'"
alias \?A="echo '${HERO_HELP[A]}'"
alias \?B="echo '${HERO_HELP[B]}'"
alias \?C="echo '${HERO_HELP[C]}'"
alias \?D="echo '${HERO_HELP[D]}'"
alias \?g="echo '${HERO_HELP[g]}'"
alias \?g-="echo '${HERO_HELP["g-"]}'"
alias \?g\?="echo '${HERO_HELP["g?"]}'"
alias \?g+="echo '${HERO_HELP["g+"]}'"
alias \?g!="echo '${HERO_HELP["g!"]}'"
alias \?g.="echo '${HERO_HELP["g."]}'"
alias \?M="echo '${HERO_HELP[M]}'"
alias \?P="echo '${HERO_HELP[P]}'"
alias \?p="echo '${HERO_HELP[p]}'"
alias \?S="echo '${HERO_HELP[S]}'"
alias \?G="echo '${HERO_HELP[G]}'"
alias \?v="echo '${HERO_HELP[v]}'"
alias \?t="echo '${HERO_HELP[t]}'"
alias \?CO="echo '${HERO_HELP[CO]}'"
alias \?a+="echo '️${HERO_HELP["a+"]}'"
alias \?a!="echo '️${HERO_HELP["a!"]}'"
alias \?R="echo '${HERO_HELP[R]}'"
alias \?L="echo '${HERO_HELP[L]}'"
alias \?z+="echo '${HERO_HELP["z+"]}'"
alias lt="lt -h http://localtunnel.me"

alias \?="echo '
┌ 💍 HUD ──────────────────────────────────────────────────────────────────────────────────
│ ${HERO_HELP[z]}
│ ${HERO_HELP[k]}
│ ${HERO_HELP[b]}
│ ${HERO_HELP[a]}
│ ${HERO_HELP[x]}
│ ${HERO_HELP[R]}
│ ${HERO_HELP[L]}
├ 🎒 ITEMS ────────────────────────────────────────────────────────────────────────────────
│ ${HERO_HELP["a+"]}
│ ${HERO_HELP["a!"]}
│ ${HERO_HELP[f]}
│ ${HERO_HELP[h]}
│ ${HERO_HELP[m]}
│ ${HERO_HELP[lt]}
├ 🧰 GIT TOOLS aka GITCUTS ────────────────────────────────────────────────────────────────
│ ${HERO_HELP[A]}
│ ${HERO_HELP[B]}
│ ${HERO_HELP[C]}
│ ${HERO_HELP[D]}
│ ${HERO_HELP[g]}
│ ${HERO_HELP[M]}
│ ${HERO_HELP[P]}
│ ${HERO_HELP[p]}
│ ${HERO_HELP[S]}
├ 🤺 EQUIPMENT ──────────────────────────────────────────────────────────────────────────────────
│ 🥾 ?  - Pegasus Boots: Run this Help menu, become uber-micro-fast by honing in on your CLI skills. 
│ ${HERO_HELP[G]}
│ ${HERO_HELP[v]}
│ ${HERO_HELP[t]}
├ EQUIPPED ──────────────────────────────────────────────────────────────────────────────────
│ 💍 Pendant: Shows if hero-of-legend aliases file is installed (R to reload)
│ 🛡️ Shield: Shows if all hero-of-legend bin scripts have been downloaded 
│ 👕 Tunic: This Theme
│ 🧰 z+ Magic Chest: ${HERO_HELP["z+"]}
└─────────────────────────────────────────────────────────────────────────────────────────
👕 $USER used the Pegasus Boots 🥾. Now they can run commands super quick!
'|less"

# alias hud="echo '
# ┌💍 HUD ────────────────────┐  ┌Crystals──┐
# │ 🗡 z 🗝 k 🏹 a ⚡a+ 🔥a!  │  │   💎 💎  │
# ├───────────────────────────┤  │ 💎 💎 💎 │
# │ 🎒 ITEMS  💣 b  💥 x      │  │   💎 💎  │
# │ 🔦 f 📗 h 💣 b? 🎺 lt 🖍 n │  └──────────┘
# ├───────────────────────────┤  ┌z┐ ┌ k ┐
# │ 🧰 GIT TOOLS              │ ️ 🗡   🔑
# ├───────────────────────────┤  └─┘ └───┘
# │ 🔨 A 🌱 B 📜 C ✨ CO 🪞 D │
# │ 🌀 I 🍯 M 🪃 P 🎣 p  🍄 S │
# ├───────────────────────────┤
# │ EQUIPMENT                 │  ┌EQUIPPED──┐
# │ 🥾 ?  🥊 e   🤿 v  🔮 t   │  │ 💍 🛡️  👕 │
# └───────────────────────────┘  └──────────┘
# '"
