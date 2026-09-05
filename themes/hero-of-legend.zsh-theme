# ------------------------------------------------------------------------------
# HERO OF LEGEND THEME - v2026.1.0
# Features:
#   - Hero Shortcuts: Quick access to Hero Inventory, Hero State, Hero NPC, Hero Magic Chest, Hero Helpers
#   - Hero Inventory: Hero Inventory (o)
#   - Hero NPC (z+)
#   - Hero Magic Chest (z+)
#   - Hero Helpers (hero-helpers)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# IMPORTS & SETUP
# ------------------------------------------------------------------------------
[[ -f "$ZSH_CUSTOM/bin/_hero-helpers" ]] && source "$ZSH_CUSTOM/bin/_hero-helpers"
[[ -f "$ZSH_CUSTOM/aliases/hero-shortcuts.alias.zsh" ]] && source "$ZSH_CUSTOM/aliases/hero-shortcuts.alias.zsh"
[[ -f "$ZSH_CUSTOM/bin/hero-npc" ]] && source "$ZSH_CUSTOM/bin/hero-npc"
export PATH="$ZSH_CUSTOM/bin:$PATH"
setopt prompt_subst

# --- Load Colors ---
autoload -U colors && colors

# --- Aliases ---
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
       
       Start Adventure (z+) | Equip Items (o)
'"

alias o='HeroInventory open'
alias st='HeroState cycle reset'
alias z+='z; if command -v hero-magic-chest >/dev/null 2>&1; then hero-magic-chest; else bash -c "$(curl -fsSL https://raw.githubusercontent.com/Knerd/hero-bin/master/hero-magic-chest)"; fi'
alias '???'='export HEY_LISTEN="???";'

# ------------------------------------------------------------------------------
# CONFIGURATION (File Paths, Constants, Global State)
# ------------------------------------------------------------------------------

# --- ICON CONFIGURATION
typeset -gA hero_areas=(
    castle  "🏰" 
    dungeon "💀" 
    compass "🧭" 
    map     "🗺️" # Alternatives: 📍, 🌐, 🌍
)

# --- Registry Format: [key]="ICON|BUTTON|NAME|COMMAND:FUN_DESCRIPTION"
# Fun descriptions appear during item selection to help users understand each item
typeset -A hero_registry=(
    # === HUD & CORE ===
    [sword]="🗡️|z|Magic Sword|clear:The blade that never leaves your side. Clears the screen and awaits your command."
    [shield]="🛡️|s|Magic Shield|omz reload:Deflect corruption! Reloads Oh-My-Zsh to restore your defenses."
    [tunic]="🥻|c|Hero's Tunic|:The essence of the Hero of Legend theme. Your journey and your identity in this terminal realm."
    [backpack]="🎒|o|Backpack|HeroInventory open:Your trusty adventurer's pack! Open it to manage your equipment and discover new items."

    # === ARROWS ===
    [bow]="🏹|a|Magic Bow|arw:Loose an arrow straight to ~/Downloads. Shows file count and lands you there instantly!"
    [firearrow]="🔥|a!|Fire Arrow|hero-fire-arrows:🎮 ARCHERY MINI-GAME! Select targets, time your shots, earn points & ranks. Compete for the leaderboard!"
    [lightarrow]="⚡️|a+|Light Arrow|hero-light-arrow:Create warp points! Name your arrow (a.docs) to teleport back instantly. Stored in your Quiver."
    [icearrow]="❄️|a-|Ice Arrow|hero-ice-arrow:Freeze your changes with git stash! View, thaw, or melt frozen work anytime."
    [bomb]="💣|b|Magic Bombs|bomb:Explosive trash management! 'b' detonates the bin, 'b+' moves to trash, 'b-' peeks inside."
    
    # === GIT CUTS ===
    [hammer]="🔨|A|Magic Hammer|git add:Forge your changes into the staging area. Pound files into git's index!"
    [bean]="🌱|B|Magic Bean|git checkout -b:Plant a new branch! Watch it grow from a tiny seed into a mighty feature."
    [scroll]="📜|C|Magic Scroll|git commit -m:Inscribe your changes into the ancient scrolls of version history."
    [mirror]="🪞 |D|Magic Mirror|git diff:Gaze into the mirror to see what has changed. Reveals all modifications."
    [bottle]="🫙 |M|Magic Bottle|git merge:Capture another branch's essence and merge it into your current timeline."
    [boomerang]="🪃 |P|Magic Boomerang|git push:Fling your commits to the remote! They always come back... eventually."
    [magnet]="🧲|p|Magnetic Gloves|git pull:Attract remote changes with magnetic force. Pull commits right to you!"
    [mushroom]="🍄|S|Magic Mushroom|git status:Reveals the current state of your repository. What's staged? What's changed?"
    [hookshot]="🪝 |CO|Hookshot|git checkout:Grapple onto any branch or commit! Instantly teleport through git history."
    
    # === UTILS ===
    [lantern]="🏮|L|Magic Lantern|ls -la:Illuminate the darkness! Reveals ALL files, even the hidden ones lurking in shadows."
    [book]="📘|h|Book of Spells|history | grep:Search the ancient texts of command history. Find that spell you cast before!"
    [lens]="🔍|f|Lens of Truth|find . | grep:Search for files matching your query."
    [portal]="🌀|lt|Magic Portal|lt: Expose local ports to the world. "
    [marker]="🖍️|m|Magic Marker|mark:Scribble quick notes! Saves code snippets to ~/hero-magic-marker for later."
    [ocarina]="🎵|st|Ocarina of Time|HeroState cycle reset:Play the Song of Time! Resets the 3-day cycle back to Dawn of the First Day."
    [chest]="🪄 |z+|Magic Chest|hero-magic-chest:Open the legendary chest to download or update Hero tools!"
    [crystal]="🔮|t|Crystal Ball|htop:Peer into system resources! Opens htop (or top) to see what's running."
    
    # === DO ===
    [key]="🗝️|k|Small Key|hero-magic-key:Unlock passage upward! k goes up 1 dir, k2-k9 climbs that many levels."
    [boots]="🥾|?|Pegasus Boots|?:Run the Help Menu at lightning speed! Master all shortcuts and become unstoppable."
    [ring]="💍|R|Blue Ring|source ~/.zshrc:Channel the ring's power to reload your .zshrc. Refresh your magic!"
    [exit]="💥|x|Magic Quake|exit: Quake the terminal with a dramatic farewell."

    
    [glove]="🥊|G|Power Glove|powerGloves:Heavy lifting! Default: clears vendor & node_modules, then runs yarn."
    [feather]="🪶 |j|Magic Feather|z:Leap with grace! Jump to a directory using z (zoxide/autojump)."
    [cape]="🧣|H|Magic Cape|hide:Vanish from sight! Toggle visibility of HUD elements."
    [net]="🕸️|n|Magic Net|n:Catch those pesky bugs! Toggle Navi's messages on/off."
    [shovel]="⛏️|d|Magic Shovel|dirs -v:Dig into your directory stack! Shows where you've been."
    [cat]="🐈|ct|Magic Cat|cat:A helpful cat that displays file contents. Reads files for you!"
    
    # === COMING SOON ===
    [flippers]="🤿|v|Magic Flippers|:Coming Soon! Dive into the deep web with VPN protection."
    [somaria]="🦯|r|Cane of Magic|reset:Coming Soon! Clear your terminal path with magic."
    [powder]="✨||Magic Powder|git checkout:Coming Soon! Transform branches with a sprinkle of magic."
    [rupee]="♦️||Rupee|:Earn rupees by running successful commands!"
    
    # === HUD INDICATORS ===
    [pot]="🏺||Pot|:Files in the current directory. Smash them to see what's inside!"
    [ladder]="🪜 ||Ladder|:Subdirectories to explore. Climb deeper into the dungeon!"
)

# --- Inventory Categories (Source of Truth for HUD and Menus)
# Format: ID "Icon|DisplayTitle|Color|ArrayName|MenuLabel"
typeset -A hero_categories
hero_categories=(
    git     "🎒|Items|117|hero_cat_git|Items"
    utils   "🎒|Utils|80|hero_cat_utils|Utilities"
    do      "🧭|Do|196|hero_cat_do|Navigation"
    legend  "🛡️|Gear|117|hero_cat_legend|Gear"
    arrows  "🏹|Arrows|120|hero_cat_arrows|Arrows"
    special "💍|Accessories|117|hero_cat_special|Accessories"
    soon    "✨|Coming Soon|242|hero_cat_soon|New Items"
)

# --- Menu Layout Configuration (Determine which category is on which side and order)
# Use 'equipped' keyword to place the active slots info. 
# Comment out an entry to remove it from the menu.
typeset -a hero_menu_left=(git arrows do)
typeset -a hero_menu_right=(equipped legend  special)

typeset -a hero_cat_git=(
    bow      boomerang   hookshot    bomb        mushroom
    bean        magnet   scroll      net        book               
    lantern     hammer   ocarina   lens        shovel         
    bottle      cape     marker           cat mirror      
    
       )
    #    firearrow   lightarrow  icearrow 
typeset -a hero_cat_utils=(  shovel lens book   )
# cape net  feather 
typeset -a hero_cat_arrows=( firearrow lightarrow icearrow exit)
typeset -a hero_cat_do=( boots glove flippers crystal  )
typeset -a hero_cat_legend=(sword shield tunic backpack  )
typeset -a hero_cat_soon=(flippers somaria powder amulet)
typeset -a hero_cat_special=(key ring portal chest )
# --- Triforce (Tri-Color) Constants ---
tri_color="${TRI_COLOR:-yellow}"
tri_top_norm="%B%F{${tri_color}} ▲ %f%b"
tri_bot_norm="%B%F{${tri_color}}▲ ▲%f%b"
tri_top_git="%B%F{${tri_color}}⯆ ⯆%f%b"
tri_bot_git="%B%F{${tri_color}} ⯆ %f%b"

# --- State File Paths ---
hero_wallet_file="$HOME/.hero_wallet"
hero_cycle_file="$HOME/.hero_cycle"
hero_slots_file="$HOME/.hero_slots"

# --- Cache Globals (Updated by HeroCache) ---
typeset -g HERO_CACHE_TS=0
typeset -g HERO_CACHE_TR=0
typeset -g HERO_CACHE_DL=0
typeset -g HERO_CACHE_KY=0

# --- Git Cache Globals (Updated by HeroCache) ---
typeset -g HERO_GIT_IN_REPO=0
typeset -g HERO_GIT_REF=""
typeset -g HERO_GIT_DIRTY=0
typeset -g HERO_GIT_AHEAD=0
typeset -g HERO_GIT_BEHIND=0

# --- String Utilities ---
heroTrim() { echo "${1// /}"; }                    # Remove all whitespace
heroDigitsOnly() { echo "${1//[^0-9]/}"; }        # Extract only digits
heroIsBlank() { [[ -z "${1// /}" ]]; }            # Check if empty/whitespace-only

# ------------------------------------------------------------------------------
# HeroState Service (Wallet, Time, Slots)
# ------------------------------------------------------------------------------
function HeroState() {
    local service=$1; shift
    case "$service" in
        # Usage: HeroState wallet [get|set|adjust] [value]
        wallet)
            local op=$1; shift
            case "$op" in
                get)
                    local balance=$(cat "$hero_wallet_file" 2>/dev/null)
                    echo "${balance:-0}"
                    ;;
                set)
                    local newBalance=$1
                    (( newBalance < 0 )) && newBalance=0
                    echo "$newBalance" > "$hero_wallet_file"
                    ;;
                adjust)
                    local diff=$1
                    local current=$(HeroState wallet get)
                    HeroState wallet set $(( current + diff ))
                    ;;
            esac
            ;;

        # Usage: HeroState cycle [day|reset|check]
        cycle)
            local op=$1; shift
            case "$op" in
                day)
                    local currentTs=$(date -d "today 00:00:00" +%s)
                    [[ ! -f "$hero_cycle_file" ]] && echo "$currentTs" > "$hero_cycle_file"
                    local startTs=$(cat "$hero_cycle_file")
                    if [[ -z "$startTs" || "$startTs" -gt "$currentTs" ]]; then 
                        startTs=$currentTs; echo "$startTs" > "$hero_cycle_file"
                    fi
                    echo $(( ((currentTs - startTs) / 86400) + 1 ))
                    ;;
                reset)
                    echo "🎼 Playing the Song of Time..."
                    [[ -x "$ZSH_CUSTOM/bin/hero-song-of-time" ]] && "$ZSH_CUSTOM/bin/hero-song-of-time" || { printf "\a"; sleep 0.4; printf "\a"; sleep 0.4; printf "\a"; }
                    date -d "today 00:00:00" +%s > "$hero_cycle_file"
                    echo "You have returned to the dawn of the First Day."
                    ;;
                check)
                    local currentDay=$(HeroState cycle day)
                    if (( currentDay > 3 )); then
                        print -P "\n%F{red}🌑 The Moon has crashed. You've met with a terrible fate, haven't you?%f"
                        print -P "%F{yellow}Play the Song of Time (st) to return to the Dawn of the First Day.%f\n"
                    fi
                    ;;
            esac
            ;;

        # Usage: HeroState slots [init|persist|status|get|iterate]
        slots)
            local op=$1; shift
            case "$op" in
                init)
                    # Initialize slot variables
                    HERO_SLOT_1="" HERO_SLOT_2="" HERO_SLOT_3="" HERO_SLOT_4=""
                    
                    # Load from persistence file if exists
                    if [[ -f "$hero_slots_file" ]]; then
                        source "$hero_slots_file"
                    else
                        # Default Loadout for new adventurers - just the backpack to start
                        HERO_SLOT_1="backpack"    # o - opens inventory
                        
                        # Persist defaults immediately
                        printf '%s\n' \
                            "HERO_SLOT_1=\"${HERO_SLOT_1}\"" \
                            "HERO_SLOT_2=\"${HERO_SLOT_2}\"" \
                            "HERO_SLOT_3=\"${HERO_SLOT_3}\"" \
                            "HERO_SLOT_4=\"${HERO_SLOT_4}\"" \
                            >| "$hero_slots_file"
                    fi
                    
                    # Export for global access
                    export HERO_SLOT_1 HERO_SLOT_2 HERO_SLOT_3 HERO_SLOT_4
                    ;;
                persist)
                    local slotNumber=$1 itemKey=$2
                    local varName="HERO_SLOT_${slotNumber}"
                    
                    # Update in memory / current session
                    export "${varName}=${itemKey}"
                    
                    # Rewrite the persistence file to match current state
                    printf '%s\n' \
                        "HERO_SLOT_1=\"${HERO_SLOT_1}\"" \
                        "HERO_SLOT_2=\"${HERO_SLOT_2}\"" \
                        "HERO_SLOT_3=\"${HERO_SLOT_3}\"" \
                        "HERO_SLOT_4=\"${HERO_SLOT_4}\"" \
                        >| "$hero_slots_file"
                    ;;
                get)
                    case "$slotNum" in
                        1) echo "$HERO_SLOT_1" ;;
                        2) echo "$HERO_SLOT_2" ;;
                        3) echo "$HERO_SLOT_3" ;;
                        4) echo "$HERO_SLOT_4" ;;
                    esac
                    ;;
                iterate)
                    # Usage: for itemKey in $(HeroState slots iterate); do ...
                    echo "$HERO_SLOT_1" "$HERO_SLOT_2" "$HERO_SLOT_3" "$HERO_SLOT_4"
                    ;;
                list_lines)
                    # Usage: local -a slots=("${(@f)$(HeroState slots list_lines)}")
                    print -l "$HERO_SLOT_1" "$HERO_SLOT_2" "$HERO_SLOT_3" "$HERO_SLOT_4"
                    ;;
                status)
                    local itemKey=$1
                    [[ -n "$itemKey" ]] && echo "${hero_icons[$itemKey]} ${hero_buttons[$itemKey]}" || echo "Empty"
                    ;;
            esac
            ;;
    esac
}

# ------------------------------------------------------------------------------
# HeroCache Service (File Counts)
# ------------------------------------------------------------------------------
function HeroCache() {
    local op=$1
    case "$op" in
        refresh)
            local now=$(date +%s)
            # Update heavy file counts every 60s
            if (( now - HERO_CACHE_TS > 60 )); then
                [[ -d "$HOME/.local/share/Trash/files" ]] && HERO_CACHE_TR=$(ls -U1q "$HOME/.local/share/Trash/files" 2>/dev/null | wc -l) || HERO_CACHE_TR=0
                HERO_CACHE_DL=$(ls -Uqp ~/Downloads 2>/dev/null | grep -v / | wc -l | tr -d ' ')
                HERO_CACHE_TS=$now
            fi
            # Count how many levels you can go up
            # Root "/" has 1 slash but 0 levels up; "/home" has 1 slash and 1 level up
            local depth=$(echo "$PWD" | tr -cd '/' | wc -c | tr -d ' ')
            if [[ "$PWD" == "/" ]]; then
                HERO_CACHE_KY=0
            else
                HERO_CACHE_KY=$depth
            fi
            

            ;;
    esac
}

# ------------------------------------------------------------------------------
# HeroInventory Service (Inventory Management)
# ------------------------------------------------------------------------------
# --- Inventory Icons ---
typeset -A hero_icons hero_buttons hero_inventory hero_desc

function HeroInventory() {
    local action=$1; shift
    case "$action" in
        # Usage: HeroInventory init
        init)
            # Register all items from hero_registry
            local -a registry_keys
            registry_keys=(${(k)hero_registry})
            for key in "${registry_keys[@]}"; do
                local val="${hero_registry[$key]}"
                # Split by pipe without trimming to preserve spacing in button if needed
                IFS='|' read -r icon btn name desc <<< "$val"
                HeroInventory register "$key" "$icon" "$btn" "$name" "$desc"
                
                # SYSTEMIC FIX: Auto-alias if button is not empty and not already defined
                local clean_btn=$(heroTrim "$btn")
                if [[ -n "$clean_btn" && "$desc" == *:* ]] && ! alias "$clean_btn" > /dev/null 2>&1; then
                    alias "$clean_btn"="${desc%%:*}"
                fi
            done
            ;;

        # Usage: HeroInventory register key icon btn name desc
        register)
            local key=$1 icon=$2 btn=$3 name=$4 desc=$5
            [[ -n "$icon" ]] && hero_icons[$key]=$icon
            [[ -n "$btn" ]]  && hero_buttons[$key]=$btn
            [[ -n "$name" ]] && hero_inventory[$key]=$name
            [[ -n "$desc" ]] && hero_desc[$key]=$desc
            ;;
        
        # Usage: HeroInventory get itemKey property [default]
        get)
            local itemKey=$1 property=$2 default=$3
            case "$property" in
                icon)   echo "${hero_icons[$itemKey]:-${default:-❓}}" ;;
                button) echo "${hero_buttons[$itemKey]:-${default:-?}}" ;;
                name)   echo "${hero_inventory[$itemKey]:-${default:-Unknown}}" ;;
                desc)   echo "${hero_desc[$itemKey]:-${default:-}}" ;;
            esac
            ;;
        
        # Usage: HeroInventory open
        open)
            HeroInventory _open_modern_hud
            ;;

        # Internal: Modern HUD (Full Screen) - Gum UI Edition
        _open_modern_hud)
            HeroInventory _equip_with_gum
            ;;
        
        # Beautiful multi-dialog equipping experience with Charm Gum
        # Compact intro HUD (Just basic status)
        _equip_with_gum)
            clear
            
            local s1="⬛" s2="⬛" s3="⬛" s4="⬛"
            local slot1=$(HeroState slots get 1); [[ -n "$slot1" ]] && s1="$(HeroInventory get "$slot1" icon)"
            local slot2=$(HeroState slots get 2); [[ -n "$slot2" ]] && s2="$(HeroInventory get "$slot2" icon)"
            local slot3=$(HeroState slots get 3); [[ -n "$slot3" ]] && s3="$(HeroInventory get "$slot3" icon)"
            local slot4=$(HeroState slots get 4); [[ -n "$slot4" ]] && s4="$(HeroInventory get "$slot4" icon)"
            
            local intro=$(HeroUI legend "82" "BACKPACK" 30 2 "" "  Equipped:  $s1   $s2   $s3   $s4")
            echo ""
            echo "$intro"
            echo ""
            
            # ═══════════════════════════════════════════════════════════════════
            # STEP 2: MAIN ACTION MENU
            # ═══════════════════════════════════════════════════════════════════
            
            # ═══════════════════════════════════════════════════════════════════
            # STEP 2: MAIN ACTION MENU
            # ═══════════════════════════════════════════════════════════════════
            local mainChoice
            mainChoice=$(gum choose \
                --header "What would you like to do?" \
                --header.foreground 213 \
                --cursor.foreground 82 \
                --selected.foreground 82 \
                --height 8 \
                "🗡️  Equip Item" \
                "🔄  Swap Slots" \
                "🗑️  Unequip Slot" \
                "📜  View All Items" \
                "❌  Exit Chamber")
            
            [[ -z "$mainChoice" ]] && return
            
            case "$mainChoice" in
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
                "❌  Exit Chamber")
                    gum style --foreground 245 --italic "  Safe travels, Hero!"
                    return
                    ;;
            esac
            ;;
        
        # ═══════════════════════════════════════════════════════════════════════
        # EQUIP ITEM FLOW: Category → Item → Slot
        # ═══════════════════════════════════════════════════════════════════════
        _equip_item_flow)
            clear
            
            # 1. Fetch Background Status (Active Slots)
            local -a s; s=("⬛  " "⬛  " "⬛  " "⬛  ")
            local i k
            for i in 1 2 3 4; do
                k=$(HeroState slots get $i)
                [[ -n "$k" ]] && s[$i]="$(HeroInventory get "$k" icon)$(printf '%-2s' "$(HeroInventory get "$k" button)")"
            done

            # 2. Build Stacked HUD Box Layout
            local wl=36  # Width Left
            local wr=28  # Width Right
            
            # Helper for consistent line building
            _hero_line() {
                local content="$1" color="$2" width="$3"
                local body=$(gum style --foreground 255 --width $((width-4)) "$content")
                local raw="%F{$color}║%f $body %F{$color}║%f"
                echo "${(%)raw}"
            }
            
            # Helper for category headers
            _hero_header() {
                local catId=$1 width=$2 type=$3 titleOverride=$4
                local catData="${hero_categories[$catId]}"
                local h_icon h_title h_color h_arrayName h_menuLabel
                if [[ -n "$catData" ]]; then
                    IFS='|' read -r h_icon h_title h_color h_arrayName h_menuLabel <<< "$catData"
                else
                    h_icon="❓" h_title="$catId" h_color="240"
                fi
                [[ -n "$titleOverride" ]] && h_title="$titleOverride"
                
                local char="─" start="╓" end="╖" mid="─"
                case "$type" in
                    top)    start="╓" end="╖" mid="─" ;;
                    mid)    start="╟" end="╢" mid="─" ;;
                    double) start="╠" end="╣" mid="═"; char="═" ;;
                esac
                
                # Dynamic dash calculation: width - prefix(3) - title - space(1) - suffix(1)
                # Correct width: start(1) + mid(1) + space(1) + title(N) + space(1) + dashes(D) + end(1) = width
                # 1 + 1 + 1 + N + 1 + D + 1 = 5 + N + D = width => D = width - 5 - N
                local dashCount=$(( width - 5 - ${#h_title} ))
                (( dashCount < 0 )) && dashCount=0
                local line="%F{$h_color}${start}${mid} ${h_title} $(printf "${char}%.0s" {1..$dashCount})${end}%f"
                echo "${(%)line}"
            }

            # --- RENDER COLUMNS ---
            local left_out=""
            local right_out=""
            
            # Helper to render a full column based on config array
            _render_hero_column() {
                local side_arr_name=$1 width=$2
                local -a side_arr=("${(@P)side_arr_name}")
                local out="" last_clr="240" idx=1
                
                for cID in "${side_arr[@]}"; do
                    # Special Case: Equipped Slots
                    if [[ "$cID" == "equipped" ]]; then
                        local lData="${hero_categories[legend]:-🛡️|Legend|220|hero_cat_legend|Legend}"
                        local e_clr="${${${lData#*|*}#*|*}%%|*}"
                        local hType="mid"; [[ $idx -eq 1 ]] && hType="top"
                        out+=$(_hero_header legend "$width" "$hType" "Equipped")$'\n'
                        out+=$(_hero_line "${s[1]}  ${s[2]}  ${s[3]}  ${s[4]}" "$e_clr" "$width")$'\n'
                        last_clr="$e_clr"
                        ((idx++))
                        continue
                    fi
                    
                    # Normal Category
                    local mData="${hero_categories[$cID]}"
                    [[ -z "$mData" ]] && continue
                    
                    local mClr="${${${mData#*|*}#*|*}%%|*}"
                    local hType="mid"; [[ $idx -eq 1 ]] && hType="top"
                    [[ "$cID" == "do" ]] && hType="double"
                    
                    out+=$(_hero_header "$cID" "$width" "$hType")$'\n'
                    local cIcons="$(HeroUI category_icons "$cID" 5)"
                    while read -r l; do [[ -n "$l" ]] && out+=$(_hero_line "$l" "$mClr" "$width")$'\n'; done <<< "$cIcons"
                    last_clr="$mClr"
                    ((idx++))
                done
                [[ -n "$out" ]] && out+=$(print -P "%F{$last_clr}╙$(printf '─%.0s' {1..$((width-2))})╜%f")
                echo -n "$out"
            }

            left_out="$(_render_hero_column hero_menu_left "$wl")"
            right_out="$(_render_hero_column hero_menu_right "$wr")"

            # 4. Final Layout Join
            local fullHUD=$(gum join --horizontal --align top "$left_out" "  " "$right_out")
            
            echo ""
            echo "$fullHUD"
            echo ""

            # Step 2a: Category Selection
            local -a menuOptions
            local cID mData mIcon mTitle mClr mArr mLabel
            local -a all_cats; all_cats=("${hero_menu_left[@]}" "${hero_menu_right[@]}")
            for cID in "${all_cats[@]}"; do
                [[ "$cID" == "equipped" ]] && continue
                mData="${hero_categories[$cID]}"
                [[ -z "$mData" ]] && continue
                
                IFS='|' read -r mIcon mTitle mClr mArr mLabel <<< "$mData"
                [[ -z "$mLabel" ]] && mLabel="$mTitle"
                menuOptions+=("$mIcon  $mLabel")
            done
            menuOptions+=("🔎  Search All Items" "⬅️  Back")

            local category
            category=$(printf '%s\n' "${menuOptions[@]}" | gum choose \
                --header "Choose a category:" \
                --header.foreground 245 \
                --cursor.foreground 214 \
                --selected.foreground 214 \
                --height 10)
            
            [[ -z "$category" || "$category" == *"Back"* ]] && { HeroInventory _equip_with_gum; return; }
            
            # Build item list based on category
            local -a itemList
            if [[ "$category" == "🔎  Search All Items" ]]; then
                itemList=(${(k)hero_registry})
            else
                # Extract array name from matching config
                for catId in ${(k)hero_categories}; do
                    local catData="${hero_categories[$catId]}"
                    if [[ "$catData" == *"${category#*  }"* ]]; then
                        local icon title clr arr mLabel
                        IFS='|' read -r icon title clr arr mLabel <<< "$catData"
                        itemList=("${(@P)arr}")
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
            
            # Build nice display strings for items with fun descriptions
            local -a displayItems
            for itemKey in "${itemList[@]}"; do
                local icon=$(HeroInventory get "$itemKey" icon)
                local name=$(HeroInventory get "$itemKey" name)
                local btn=$(HeroInventory get "$itemKey" button)
                local desc=$(HeroInventory get "$itemKey" desc)
                # Extract the fun description (after the colon)
                local funDesc="${desc#*:}"
                [[ "$funDesc" == "$desc" ]] && funDesc=""
                
                # Format: ICON NAME [BTN]
                displayItems+=("$icon  $name [$btn]")
            done
            
            # Add back option
            displayItems+=("⬅️   Back to Categories")
            
            # Use filter for searching if many items, otherwise choose
            local selectedDisplay
            if [[ "$category" == "🔎  Search All Items" ]]; then
                selectedDisplay=$(printf '%s\n' "${displayItems[@]}" | gum filter \
                    --header "Type to search:" \
                    --header.foreground 245 \
                    --indicator.foreground 82 \
                    --match.foreground 214 \
                    --height 15 \
                    --placeholder "🔍 Search items...")
            else
                selectedDisplay=$(printf '%s\n' "${displayItems[@]}" | gum choose \
                    --header "Select an item:" \
                    --header.foreground 245 \
                    --cursor.foreground 82 \
                    --selected.foreground 82 \
                    --height 12)
            fi
            
            [[ -z "$selectedDisplay" || "$selectedDisplay" == "⬅️   Back to Categories" ]] && { HeroInventory _equip_item_flow; return; }
            
            # Extract item key from selection
            local selectedItem=""
            for itemKey in "${itemList[@]}"; do
                local icon=$(HeroInventory get "$itemKey" icon)
                if [[ "$selectedDisplay" == "$icon"* ]]; then
                    selectedItem="$itemKey"
                    break
                fi
            done
            
            [[ -z "$selectedItem" ]] && { HeroInventory _equip_with_gum; return; }
            
            # Special case: Master Sword is always equipped (it's the prompt!)
            if [[ "$selectedItem" == "sword" ]]; then
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
                    "Press 'z' to clear the screen and" \
                    "prepare for your next command."
                
                echo ""
                gum style --foreground 245 --italic "  Press any key to continue..."
                read -k 1
                HeroInventory _equip_with_gum
                return
            fi
            
            # Step 2c: Item Preview & Slot Selection
            clear
            local selIcon=$(HeroInventory get "$selectedItem" icon)
            local selName=$(HeroInventory get "$selectedItem" name)
            local selBtn=$(HeroInventory get "$selectedItem" button)
            local selDescFull=$(HeroInventory get "$selectedItem" desc)
            local selCommand="${selDescFull%%:*}"
            local selFunDesc="${selDescFull#*:}"
            [[ "$selFunDesc" == "$selDescFull" ]] && selFunDesc=""
            
            # Show compact item preview (single box)
            gum style \
                --foreground 82 --border-foreground 99 \
                --border rounded --align center \
                --width 55 --margin "1 2" --padding "1 2" \
                "$selIcon $selName [$selBtn]" \
                "" \
                "${selFunDesc:-No description}" \
                "" \
                "Runs: $selCommand"
            echo ""
            
            # Build slot display with current contents
            local -a slotChoices
            for slotNum in 1 2 3 4; do
                local currentItem=$(HeroState slots get $slotNum)
                if [[ -n "$currentItem" ]]; then
                    local curIcon=$(HeroInventory get "$currentItem" icon)
                    local curName=$(HeroInventory get "$currentItem" name)
                    slotChoices+=("Slot $slotNum: $curIcon $curName (will replace)")
                else
                    slotChoices+=("Slot $slotNum: ⬜ Empty")
                fi
            done
            slotChoices+=("⬅️  Cancel")
            
            local slotChoice
            slotChoice=$(printf '%s\n' "${slotChoices[@]}" | gum choose \
                --header "Select destination slot:" \
                --header.foreground 245 \
                --cursor.foreground 214 \
                --selected.foreground 214 \
                --height 8)
            
            [[ -z "$slotChoice" || "$slotChoice" == "⬅️  Cancel" ]] && { HeroInventory _equip_with_gum; return; }
            
            # Extract slot number
            local targetSlot="${slotChoice:5:1}"
            
            # Confirmation dialog
            local existingItem=$(HeroState slots get $targetSlot)
            local confirmMsg="Equip $selIcon $selName to Slot $targetSlot?"
            [[ -n "$existingItem" ]] && confirmMsg="Replace $(HeroInventory get "$existingItem" icon) $(HeroInventory get "$existingItem" name) with $selIcon $selName?"
            
            echo ""
            if gum confirm "$confirmMsg" --affirmative "⚔️ Equip!" --negative "Cancel"; then
                # Animated equipping with spinner
                gum spin --spinner dot --title "⚡ Channeling ancient power..." -- sleep 0.8
                
                # Persist the change
                HeroState slots persist "$targetSlot" "$selectedItem"
                
                # Success celebration
                clear
                gum style \
                    --foreground 82 --border-foreground 82 \
                    --border double --align center \
                    --width 50 --margin "2" --padding "2 4" \
                    "✨ EQUIPMENT UPGRADED! ✨" \
                    "" \
                    "$selIcon $selName" \
                    "equipped to Slot $targetSlot" \
                    "" \
                    "May your blade strike true, Hero!"
                
                sleep 1.5
            fi
            
            # Return to main menu
            HeroInventory _equip_with_gum
            ;;
        
        # ═══════════════════════════════════════════════════════════════════════
        # SWAP SLOTS FLOW
        # ═══════════════════════════════════════════════════════════════════════
        _swap_slots_flow)
            clear
            gum style \
                --foreground 81 --border-foreground 240 \
                --border rounded --align center \
                --width 50 --margin "1 2" --padding "0 2" \
                "🔄  SWAP EQUIPMENT SLOTS"
            echo ""
            
            # Build slot displays
            local -a slotDisplays
            local slotNum
            for slotNum in 1 2 3 4; do
                local itemKey=$(HeroState slots get $slotNum)
                if [[ -n "$itemKey" ]]; then
                    slotDisplays+=("Slot $slotNum: $(HeroInventory get "$itemKey" icon) $(HeroInventory get "$itemKey" name)")
                else
                    slotDisplays+=("Slot $slotNum: ⬜ Empty")
                fi
            done
            slotDisplays+=("⬅️  Cancel")
            
            local firstSlot
            firstSlot=$(printf '%s\n' "${slotDisplays[@]}" | gum choose \
                --header "Select FIRST slot to swap:" \
                --header.foreground 245 \
                --cursor.foreground 81 \
                --selected.foreground 81 \
                --height 8)
            
            [[ -z "$firstSlot" || "$firstSlot" == "⬅️  Cancel" ]] && { HeroInventory _equip_with_gum; return; }
            
            local secondSlot
            secondSlot=$(printf '%s\n' "${slotDisplays[@]}" | gum choose \
                --header "Select SECOND slot to swap with:" \
                --header.foreground 245 \
                --cursor.foreground 214 \
                --selected.foreground 214 \
                --height 8)
            
            [[ -z "$secondSlot" || "$secondSlot" == "⬅️  Cancel" ]] && { HeroInventory _equip_with_gum; return; }
            
            # Extract slot numbers
            local slot1="${firstSlot:5:1}"
            local slot2="${secondSlot:5:1}"
            
            if [[ "$slot1" == "$slot2" ]]; then
                gum style --foreground 208 "  ⚠️  Cannot swap a slot with itself!"
                sleep 1
                HeroInventory _swap_slots_flow
                return
            fi
            
            # Perform swap
            local item1=$(HeroState slots get $slot1)
            local item2=$(HeroState slots get $slot2)
            
            gum spin --spinner dot --title "🔄 Swapping equipment..." -- sleep 0.6
            
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
        
        # ═══════════════════════════════════════════════════════════════════════
        # UNEQUIP SLOT FLOW
        # ═══════════════════════════════════════════════════════════════════════
        _unequip_slot_flow)
            clear
            gum style \
                --foreground 203 --border-foreground 240 \
                --border rounded --align center \
                --width 50 --margin "1 2" --padding "0 2" \
                "🗑️  UNEQUIP A SLOT"
            echo ""
            
            # Build slot displays (only show equipped slots)
            local -a slotDisplays
            local slotNum
            local hasEquipped=0
            for slotNum in 1 2 3 4; do
                local itemKey=$(HeroState slots get $slotNum)
                if [[ -n "$itemKey" ]]; then
                    slotDisplays+=("Slot $slotNum: $(HeroInventory get "$itemKey" icon) $(HeroInventory get "$itemKey" name)")
                    hasEquipped=1
                fi
            done
            
            if (( !hasEquipped )); then
                gum style --foreground 245 --italic "  All slots are already empty."
                sleep 1.5
                HeroInventory _equip_with_gum
                return
            fi
            
            slotDisplays+=("⬅️  Cancel")
            
            local slotChoice
            slotChoice=$(printf '%s\n' "${slotDisplays[@]}" | gum choose \
                --header "Select slot to clear:" \
                --header.foreground 245 \
                --cursor.foreground 203 \
                --selected.foreground 203 \
                --height 8)
            
            [[ -z "$slotChoice" || "$slotChoice" == "⬅️  Cancel" ]] && { HeroInventory _equip_with_gum; return; }
            
            local targetSlot="${slotChoice:5:1}"
            local itemToRemove=$(HeroState slots get $targetSlot)
            local removeIcon=$(HeroInventory get "$itemToRemove" icon)
            local removeName=$(HeroInventory get "$itemToRemove" name)
            
            echo ""
            if gum confirm "Remove $removeIcon $removeName from Slot $targetSlot?" --affirmative "🗑️ Remove" --negative "Cancel"; then
                gum spin --spinner dot --title "Unequipping..." -- sleep 0.5
                HeroState slots persist "$targetSlot" ""
                
                gum style --foreground 82 "  ✅ Slot $targetSlot is now empty."
                sleep 1
            fi
            
            HeroInventory _equip_with_gum
            ;;
        
        # ═══════════════════════════════════════════════════════════════════════
        # VIEW ALL ITEMS (Pager View)
        # ═══════════════════════════════════════════════════════════════════════
        _view_all_items)
            clear
            local content=""
            content+="╔══════════════════════════════════════════════════════════════╗\n"
            content+="║              📜  HERO'S ITEM COMPENDIUM  📜                  ║\n"
            content+="╚══════════════════════════════════════════════════════════════╝\n\n"
            
            content+="┌─ 🏹 COMBAT & ARROWS ─────────────────────────────────────────┐\n"
            for itemKey in bow firearrow lightarrow bomb sword shield; do
                local icon=$(HeroInventory get "$itemKey" icon)
                local name=$(HeroInventory get "$itemKey" name)
                local btn=$(HeroInventory get "$itemKey" button)
                local desc=$(HeroInventory get "$itemKey" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="┌─ 🧰 GIT TOOLS ────────────────────────────────────────────────┐\n"
            for itemKey in hammer bean scroll mirror bottle boomerang magnet mushroom hookshot; do
                local icon=$(HeroInventory get "$itemKey" icon)
                local name=$(HeroInventory get "$itemKey" name)
                local btn=$(HeroInventory get "$itemKey" button)
                local desc=$(HeroInventory get "$itemKey" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="┌─ 🎒 UTILITIES ─────────────────────────────────────────────────┐\n"
            for itemKey in lantern book flute trumpet marker key ring ocarina somaria chest; do
                local icon=$(HeroInventory get "$itemKey" icon)
                local name=$(HeroInventory get "$itemKey" name)
                local btn=$(HeroInventory get "$itemKey" button)
                local desc=$(HeroInventory get "$itemKey" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="┌─ 🧭 EQUIPMENT & GEAR ──────────────────────────────────────────┐\n"
            for itemKey in boots glove feather cape net flippers crystal shovel; do
                local icon=$(HeroInventory get "$itemKey" icon)
                local name=$(HeroInventory get "$itemKey" name)
                local btn=$(HeroInventory get "$itemKey" button)
                local desc=$(HeroInventory get "$itemKey" desc)
                content+="│  $icon  $(printf '%-16s' "$name") [$btn]  ${desc#*:}\n"
            done
            content+="└───────────────────────────────────────────────────────────────┘\n\n"
            
            content+="                    Press 'q' to exit the compendium\n"
            
            echo -e "$content" | gum pager
            ;;

        # Usage: HeroInventory list item1 item2 ...
        list)
            local -a items=("$@")
            for item in "${items[@]}"; do
                HeroInventory _format_item "$item"
            done
            ;;

        # Internal: Simple list for text menu
        _list_simple)
            local -a items=("$@")
            for item in "${items[@]}"; do
                 printf "  [%-3s] %s %-12s - %s\n" "${hero_buttons[$item]}" "${hero_icons[$item]}" "$item" "${hero_desc[$item]}"
            done
            ;;

        # Internal: Format single item for visual menu
        _format_item)
            local itemKey=$1
            local icon=$(HeroInventory get "$itemKey" icon)
            local button=$(HeroInventory get "$itemKey" button)
            local descriptionRaw=$(HeroInventory get "$itemKey" desc)
            local commandPart="${descriptionRaw%%:*}"
            local humanPart="${descriptionRaw#*:}"
            
            local fullDescription="$commandPart"
            [[ -n "$humanPart" && "$commandPart" != "$humanPart" ]] && fullDescription="$commandPart ($humanPart)"
            
            local itemDisplayName="${hero_inventory[$itemKey]:-$itemKey}"
            local shortcutTag="[${icon} ${button}]"
            
            printf "%-10s  %-20s  %s\n" "$shortcutTag" "$itemDisplayName" "$fullDescription"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# HeroStatus Service (Environment, Hearts, Areas)
# ------------------------------------------------------------------------------
function HeroStatus() {
    local action=$1; shift
    
    case "$action" in
        # Usage: HeroStatus refresh
        refresh)
             # Git Cache (Per Prompt)
            HERO_GIT_IN_REPO=0
            HERO_GIT_REF=""
            HERO_GIT_DIRTY=0
            HERO_GIT_AHEAD=0
            HERO_GIT_BEHIND=0
            
            if command git rev-parse --is-inside-work-tree &>/dev/null; then
                HERO_GIT_IN_REPO=1
                HERO_GIT_REF=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
                # Check if dirty (index or working tree)
                if ! git diff-index --quiet --cached HEAD -- 2>/dev/null || ! git diff-files --quiet 2>/dev/null; then
                    HERO_GIT_DIRTY=1
                fi
                
                # Check Sync
                local counts
                counts=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
                if [[ -n "$counts" ]]; then
                    read -r HERO_GIT_BEHIND HERO_GIT_AHEAD <<< "$counts"
                fi
            fi
            ;;

        # Usage: HeroStatus check
        check) echo "$HERO_GIT_IN_REPO" ;;

        # Usage: HeroStatus environment (sets vars for consumption)
        # Output: TRI_TOP TRI_BOT AREA_ICON AREA_TEXT
        environment)
            if (( HERO_GIT_IN_REPO )); then
                # Get repo name: owner/repo from remote, or just dirname
                local repoName=""
                local rurl=$(git config --get remote.origin.url 2>/dev/null)
                if [[ -n "$rurl" ]]; then
                    repoName=$(echo "$rurl" | sed -E 's/.*[:/]([^/]+\/[^/]+)(\.git)?$/\1/')
                fi
                [[ -z "$repoName" ]] && repoName=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
                echo "$tri_top_git|$tri_bot_git|${hero_areas[dungeon]}|%F{white}${repoName}%f"
            else
                echo "$tri_top_norm|$tri_bot_norm|${hero_areas[castle]}|%F{240}%m%f"
            fi
            ;;

        # Usage: HeroStatus hearts
        hearts)
            local heartFull="♥️"
            local heartEmpty="🖤"
            if (( HERO_GIT_IN_REPO )); then
                (( HERO_GIT_DIRTY )) && echo "${heartFull}${heartFull}${heartEmpty}" || echo "${heartFull}${heartFull}${heartFull}"
            else
                echo "${heartFull}${heartEmpty}${heartEmpty}"
            fi
            ;;
    esac
}

# ------------------------------------------------------------------------------
# HeroUI Service (Counters, HUD Components)
# ------------------------------------------------------------------------------
function HeroUI() {
    setopt local_options extended_glob
    local component=$1; shift
    case "$component" in
        # Usage: HeroUI rupee
        rupee)
            local amount=$(HeroState wallet get)
            local color=$(HeroUI _threshold_color $amount 1000:yellow 500:242 300:red 100:blue 0:green)
            # 
            printf "%s%sˣ%03d%s" "$color" "${hero_icons[rupee]}" "$amount" "%f"
            ;;

        # Usage: HeroUI timer
        timer)
            local dayNumber=$1
            # Time until dawn tomorrow (Max 24h)
            local totalSeconds=$(( $(date -d "tomorrow 00:00:00" +%s) - $(date +%s) ))
            
            # If we've passed the 3-day window, time is up
            if (( dayNumber > 3 )); then
                totalSeconds=0
            fi

            local hours=$((totalSeconds / 3600))
            local minutes=$(((totalSeconds % 3600) / 60))
            local seconds=$((totalSeconds % 60))
            
            # Individual gradients per HH:MM:SS
            # Using 23 as max for hours to keep it "cool" (full color range) within the day
            printf "%s%02d%s:%s%02d%s:%s%02d%s" \
                "$(HeroUI _tcolor $hours 23)" $hours "%f" \
                "$(HeroUI _tcolor $minutes 59)" $minutes "%f" \
                "$(HeroUI _tcolor $seconds 59)" $seconds "%f"
            ;;

        # Usage: HeroUI day [day_number] [color]
        day)
            local dayNumber=$1
            local suffix="th"
            local color="$2"
            case "$dayNumber" in
                1) suffix="st" ;;
                2) suffix="nd" ;;
                3) suffix="rd" ;;
            esac
            # Fallback to defaults if no color provided
            if [[ -z "$color" ]]; then
                color=$(HeroUI _threshold_color $dayNumber 4:red 3:blue 0:white)
            fi
            echo -n "${color}${dayNumber}${suffix}%f"
            ;;

        # Internal: Time Color Calculation
        _tcolor)
            local value=$1
            local maximum=$2
            (( value > maximum )) && value=$maximum
            (( value < 0 )) && value=0
            local percent=$(( (value * 100) / maximum ))
            if (( percent >= 50 )); then
                # percent >= 50: Green to Yellow (Decrease percent increases Red)
                printf '%%F{#%02x%02x00}' $(( 255 * (100 - percent) / 50 )) 255
            else
                # percent < 50: Yellow to Red (Decrease percent decreases Green)
                printf '%%F{#%02x%02x00}' 255 $(( 255 * percent / 50 ))
            fi
            ;;
        
        # Internal: Threshold Color Picker
        # Usage: HeroUI _threshold_color VALUE threshold:color threshold:color ...
        _threshold_color)
            local value=$1; shift
            local result="%F{242}"  # default
            for spec in "$@"; do
                local threshold="${spec%%:*}"
                local color="${spec#*:}"
                if (( value >= threshold )); then
                    result="%F{$color}"
                    break
                fi
            done
            echo "$result"
            ;;

        # Usage: HeroUI legend "ColorCode" "Label" "ContentLines..."
        # Note: This version draws a CLOSED box.
        legend)
            local color="%F{$1}" label=" $2 "; shift 2
            local -a lines=("$@")
            local w=22
            local label_len=${#label}
            # Draw top border with legend
            print -P "${color}╔═${label}$(printf '═%.0s' {1..$((w-4-label_len))})╗%f"
            # Draw lines with both borders
            for line in "${lines[@]}"; do
                [[ -z "$line" ]] && continue 
                local body=$(gum style --width $((w-4)) "$line")
                print -P "${color}║%f $body ${color}║%f"
            done
            # Draw bottom border
            print -P "${color}╚$(printf '═%.0s' {1..$((w-2))})╝%f"
            ;;
        
        # Usage: HeroUI category_icons "category_name" "items_per_row"
        category_icons)
            local catName=$1 itemsPerRow=${2:-5}
            local catData="${hero_categories[$catName]}"
            [[ -z "$catData" ]] && return
            
            local icon title color arrayName menuLabel
            IFS='|' read -r icon title color arrayName menuLabel <<< "$catData"
            
            local -a items
            items=("${(@P)arrayName}")
            local row="" count=0
            for item in "${items[@]}"; do
                local icon="$(HeroInventory get "$item" icon)"
                local btn="$(HeroInventory get "$item" button)"
                # SYSTEMIC FIX: Pad button to 2 chars for grid alignment (e.g. "z " or "a!")
                local btn_padded="$(printf '%-2s' "$btn")"
                row+="${icon}${btn_padded}  "
                ((count++))
                if (( count % itemsPerRow == 0 )); then
                    echo "${row%%  }"
                    row=""
                fi
            done
            [[ -n "$row" ]] && echo "${row%%  }"
            ;;

        # Usage: HeroUI box "Title" "Line1" "Line2" ... --color red
        box)
            local title=$1; shift
            local color="%F{red}"
            local -a lines=()
            
            # Simple Arg Parse
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --color) color="%F{$2}"; shift 2 ;;
                    *) lines+=("$1"); shift ;;
                esac
            done
            
            local maxLength=30
            for line in "${lines[@]}"; do
                local expanded="${(%)line}"
                local stripped="${expanded//$'\e['[0-9;]##[a-zA-Z]/}"
                local lineLength=${#stripped}
                ((lineLength > maxLength)) && maxLength=$lineLength
            done
            
            local horizontalBar=$(printf '─%.0s' {1..$((maxLength))})
            
            echo "${color}┌─ ${title} ${horizontalBar}${color}%f"
            for line in "${lines[@]}"; do
                echo "${color}│ %F{242}${line}%f"
            done
            echo "${color}└$(printf '─%.0s' {1..$((maxLength + 15))})%f"
            ;;


        # Usage: HeroUI bombs | HeroUI arrows | HeroUI keys
        bombs)
            local count=$(HeroUI _cap "${HERO_CACHE_TR:-0}")
            (( HERO_CACHE_TR > 20 )) && echo "%F{red}🧨ˣ${count}%f" || echo "%F{242}${hero_icons[bomb]}ˣ${count}%f"
            ;;
        arrows)
            echo "%F{242}${hero_icons[bow]}ˣ$(HeroUI _cap "${HERO_CACHE_DL:-0}")%f"
            ;;
        keys)
            # Realtime calculation for keys in current dir is fast enough if optimized, but using cache for consistency
            echo "%F{242}${hero_icons[key]}ˣ$(HeroUI _cap "${HERO_CACHE_KY:-0}")%f"
            ;;
        
        # Internal: Cap and Format Count
        _cap)
            local count=$(heroDigitsOnly "$1")
            [[ -z "$count" ]] && count=0
            (( 10#${count} > 999 )) && echo "999" || printf "%02d" $(( 10#${count} ))
            ;;

        # Usage: HeroUI location | HeroUI compass (isInRepo)
        location)
            local suffix=""; [[ ! -w . ]] && suffix=" 🔒"
            echo "$(print -P "%~")${suffix}"
            ;;
        compass)
            local isInRepo=$1
            
            # Count pots (files) and ladders (subdirs) in current directory
            local potCount=$(ls -Up 2>/dev/null | grep -v / | wc -l | tr -d ' ')
            local ladderCount=$(ls -Up 2>/dev/null | grep / | wc -l | tr -d ' ')
            local roomStats="%F{240}┤%F{242}${hero_icons[pot]}${potCount} ${hero_icons[ladder]}${ladderCount}%F{240}├%f"
            
            if (( isInRepo )); then
                # Branch name (green like other git info)
                local branchPart="%F{green}${HERO_GIT_REF}%f"
                
                # Sync status (grey)
                local syncPart=""
                [[ "$HERO_GIT_AHEAD" -gt 0 ]] && syncPart+="%F{242}⬆${HERO_GIT_AHEAD}%f"
                [[ "$HERO_GIT_BEHIND" -gt 0 ]] && syncPart+="%F{242}⬇${HERO_GIT_BEHIND}%f"
                
                if [[ -n "$syncPart" ]]; then
                    echo "${branchPart} ${syncPart} ${roomStats}"
                else
                    echo "${branchPart} ${roomStats}"
                fi
            else
                # Non-repo: show current dir name + room stats
                local dirName="%F{green}%1~%f"
                echo "${dirName} ${roomStats}"
            fi
            ;;

        # Usage: HeroUI equipped (renders all equipped slots)
        equipped)
            local output=""
            local slotValue
            for slotValue in $(HeroState slots iterate); do
                if [[ -n "$slotValue" ]]; then
                    output+="$(HeroInventory get "$slotValue" icon)$(HeroInventory get "$slotValue" button) "
                fi
            done
            print -rn -- "$output"
            ;;

        # Usage: HeroUI equipment_stack
        # Returns: 
        # Line 1: Icons (├ 🔨 ┬ 🪃 ...)
        # Line 2: Keys  (└ A  ┴ P  ...)
        equipment_stack)
            local mode="$1"
            local borderColor="%F{240}"
            local textColor="%F{green}"
            local resetColor="%f"
            
            local topContent=""
            local botContent=""
            local -a slotItems=("${(@f)$(HeroState slots list_lines)}")
            local equippedCount=0
            
            # Only show equipped slots (skip empty ones)
            for slotValue in "${slotItems[@]}"; do
                # Skip empty slots
                [[ -z "$slotValue" ]] && continue
                
                local itemIcon=$(HeroInventory get "$slotValue" icon)
                local buttonShortcut=$(HeroInventory get "$slotValue" button)
                
                # Add separator before this item (if not the first)
                if (( equippedCount > 0 )); then
                    topContent+=" "
                    botContent+=" "
                fi
                
                # Add icon and padded button (2 chars for alignment)
                botContent+="${itemIcon}"
                topContent+="${textColor}$(printf '%-2s' "$buttonShortcut")${resetColor}"
                
                ((equippedCount++))
            done

            if [[ "$mode" == "raw" ]]; then
                echo "$topContent"
                echo "$botContent"
                return
            fi
            
            print -r -- "${borderColor}┌${resetColor}${topContent}${borderColor}┐${resetColor}"
            print -r -- "${borderColor}└${resetColor}${botContent}${borderColor}┘${resetColor}"
            ;;

        # ═══════════════════════════════════════════════════════════════════════════
        # BOX_RENDER - Unified HUD Box Renderer
        # ═══════════════════════════════════════════════════════════════════════════
        # Creates a bordered box containing:
        #   Line 1 (top):    Stats headers (LIFE, DAY, TIME, etc.)
        #   Line 2 (middle): Stats values (hearts, timer, counters)
        #   Line 3 (icons):  Equipment icons + optional NPC message
        #   Line 4 (keys):   Equipment shortcuts + area/prompt
        #
        # Usage: HeroUI box_render "$topStr" "$botStr" "$npcContent" "$icons" "$keys" "$interaction"
        # ═══════════════════════════════════════════════════════════════════════════
        box_render)
            # ─────────────────────────────────────────────────────────────
            # STEP 1: Parse Input Arguments
            # ─────────────────────────────────────────────────────────────
            # Trailing " #" is stripped (legacy artifact from join operations)
            local hudTopRow="${1%% #}"          # Headers: -LIFE- -DAY- -TIME- etc.
            local hudBottomRow="${2%% #}"       # Values: hearts, timer, counters
            local npcMessage="${3%% #}"         # Optional NPC companion text
            local equipmentIcons="${4%% #}"     # Equipped item icons (🔨┬🪃┬...)
            local equipmentShortcuts="${5%% #}" # Shortcut keys ( A ┴ P ┴...)
            local promptContent="${6%% #}"      # Area icon + text + sword prompt
            
            # Visual styling constants
            local BORDER="%F{240}"  # Grey border color
            local RESET="%f"        # Reset to default color
            
            # ─────────────────────────────────────────────────────────────
            # STEP 2: Build Line 3 (Equipment Icons + NPC Message)
            # ─────────────────────────────────────────────────────────────
            # Line 3 shows equipment icons, optionally followed by NPC dialogue
            # Format: 🔨┬🪃┬📜┬🪞 ┬ 🧚 "Hey listen!"
            local equipmentAndNpcLine=""
            if [[ -n "${equipmentIcons// /}" ]]; then
                # Has equipment: show icons + separator
                equipmentAndNpcLine="${equipmentIcons}${BORDER} ┬ ${RESET}"
            fi
            if [[ -n "${npcMessage// /}" ]]; then
                # Append NPC message if present
                equipmentAndNpcLine+="${npcMessage}"
            fi
            
            # ─────────────────────────────────────────────────────────────
            # STEP 3: Calculate Visual Width of Each Line
            # ─────────────────────────────────────────────────────────────
            # We need to measure the "visual" width (what the user sees),
            # ignoring ANSI escape codes and ZSH prompt expansions.
            #
            # Process: Expand ZSH codes -> Strip ANSI escapes -> Count chars
            # Pattern: $'\e['[0-9;]##[a-zA-Z] matches sequences like \e[0m, \e[38;5;82m
            # Note: Must use pattern inline - storing ## patterns in variables doesn't work
            
            # Line 1: Top row (headers)
            local expandedTop="${(%)hudTopRow}"                        # Expand %F{...}, %f, etc.
            expandedTop="${expandedTop//$'\e['[0-9;]##[a-zA-Z]/}"      # Strip \e[...m sequences
            local visualWidthTop=${#expandedTop}
            
            # Line 2: Bottom row (values)
            local expandedBot="${(%)hudBottomRow}"
            expandedBot="${expandedBot//$'\e['[0-9;]##[a-zA-Z]/}"
            local visualWidthBot=${#expandedBot}
            
            # Line 3: Equipment + NPC
            local expandedLine3="${(%)equipmentAndNpcLine}"
            expandedLine3="${expandedLine3//$'\e['[0-9;]##[a-zA-Z]/}"
            local visualWidthLine3=${#expandedLine3}
            
            # ─────────────────────────────────────────────────────────────
            # STEP 4: Calculate "Reach" (Border Offset + Content Width)
            # ─────────────────────────────────────────────────────────────
            # Each line has a different border prefix that takes up space:
            #   Line 1: "┌ "  = 2 visible characters
            #   Line 2: "│ "  = 2 visible characters  
            #   Line 3: "├ "  = 2 visible characters
            #
            # "Reach" = how far the content extends from the left edge
            local LINE1_BORDER_WIDTH=2  # "┌ " prefix
            local LINE2_BORDER_WIDTH=1  # "│ " prefix
            local LINE3_BORDER_WIDTH=2  # "├ " prefix
            
            local reachLine1=$(( LINE1_BORDER_WIDTH + visualWidthTop ))
            local reachLine2=$(( LINE2_BORDER_WIDTH + visualWidthBot ))
            local reachLine3=$(( LINE3_BORDER_WIDTH + visualWidthLine3 ))
            
            # Find the longest reach (determines box width)
            local maxReach=$reachLine1
            (( reachLine2 > maxReach )) && maxReach=$reachLine2
            (( reachLine3 > maxReach )) && maxReach=$reachLine3
            
            # ─────────────────────────────────────────────────────────────
            # STEP 5: Calculate Padding for Right-Edge Alignment
            # ─────────────────────────────────────────────────────────────
            # Each line needs padding to reach the box's right edge
            # IMPORTANT: Padding must never be negative or the left-pad expansion breaks
            local paddingLine1=$(( maxReach - reachLine1 + 3 ))
            (( paddingLine1 < 0 )) && paddingLine1=2
            
            local paddingLine2=$(( maxReach - reachLine2 + 0 ))
            
            (( paddingLine2 < 2 )) && paddingLine2=0
            
            local paddingLine3=$(( maxReach - reachLine3 + 5 ))
            if [[ -n "${npcMessage// /}" ]]; then
                paddingLine3=$(( maxReach - reachLine3 + 4 ))
            fi
            (( paddingLine3 < 0 )) && paddingLine3=4
            
            
            # ─────────────────────────────────────────────────────────────
            # STEP 6: Render the Box
            # ─────────────────────────────────────────────────────────────
            # Line 1: ┌ [top content]────────────────────────────────────┐
            # Line 2: │ [bottom content]                                 │
            # Line 3: ├[equipment icons] ┬ [npc message]─────────────────┘
            # Line 4: └[shortcut keys]┴[area icon + prompt]
            
            # Line 1: Top border with header stats
            # ${(l:N::char:):-} = left-pad empty string with N copies of 'char'
            print -r -- "${BORDER}┌ ${RESET}${hudTopRow}${BORDER}${(l:paddingLine1::─:):-}┐${RESET}"
            
            # Line 2: Stats values row
            # Note: Extra space before │ for visual balance
            print -r -- "${BORDER}│ ${RESET}${hudBottomRow}${(l:paddingLine2:: :):-} ${BORDER}│${RESET}"
            
            # Line 3: Equipment icons (+ optional NPC) with corner close
            print -r -- "${BORDER}├ ${RESET}${equipmentAndNpcLine}${BORDER}${(l:paddingLine3::─:):-}┘${RESET}"
            
            # Line 4: Equipment shortcuts + interaction prompt (no newline at end)
            # Always print Line 4 - it contains the prompt which is required
            if [[ -n "$equipmentShortcuts" ]]; then
                # With equipment: show shortcuts + separator + prompt
                print -rn -- "${BORDER}└ ${RESET}${equipmentShortcuts}${BORDER} ┘${RESET}${promptContent}"
            else
                # No equipment: just show the prompt with a simple close
                print -rn -- "${BORDER}└${RESET}${promptContent}"
            fi
            ;;

        # Usage: HeroUI slots_bar "NPC Content" [targetWidth]
        slots_bar)
            local npcContent=$1
            local targetWidth=$2
            local -a slots
            local slotValue
            local borderColor="%F{240}"
            local resetColor="%F{242}"
            
            local -a slotItems=("${(@f)$(HeroState slots list_lines)}")
            for slotValue in "${slotItems[@]}"; do
                if [[ -n "$slotValue" ]]; then
                    slots+=("${resetColor}$(HeroInventory get "$slotValue" icon)$(HeroInventory get "$slotValue" button)${borderColor}")
                else
                    slots+=("${borderColor} ${borderColor}")
                fi
            done
            
            local leftSide="${borderColor}├ %F{242}${npcContent} "
            heroIsBlank "$npcContent" && leftSide="${borderColor}├─"
            
            local rightSide=" ${borderColor}[${resetColor} ${(j: :)slots} ${borderColor}]${resetColor} ${borderColor}─┘${resetColor}"
            local fullString="${leftSide}${rightSide}"
            local expanded="${(%)fullString}"
            local stripped="${expanded//$'\e['[0-9;]##[a-zA-Z]/}"
            local currentWidth=${#stripped}
            
            local filler=""
            if [[ -n "$targetWidth" ]]; then
                local paddingAmount=$(( targetWidth - currentWidth ))
                (( paddingAmount < 0 )) && paddingAmount=0
                filler=$(printf '─%.0s' {1..$paddingAmount})
            fi
            
            echo "${leftSide}${borderColor}${filler}${resetColor}${rightSide}"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# HeroGame Service (Adventure Logic, Battle Log)
# ------------------------------------------------------------------------------
function HeroGame() {
    local action=$1; shift
    case "$action" in
        # Usage: HeroGame process exitStatus lastCommand companionMsg
        process)
            local exitStatus=$1 lastCommand=$2 companionMsg=$3
            if (( exitStatus != 0 )); then
                HeroGame _notify_theft
                HeroGame _log_failure "$lastCommand" "$companionMsg"
                HeroState wallet adjust -10
            else
                HeroState wallet adjust 1
            fi
            ;;
        
        _notify_theft)
            command -v notify-send >/dev/null && notify-send -u normal -t 3000 " MISS!" "Villain stole 10 Rupees!"
            ;;
        
        _log_failure)
            local cmdName=$1 compData=$2
            local compText="${compData#*|}"
            local vIcon="${HERO_NPC_ICONS[villain]:-🦹}"
            local -a entries=(
                "%F{white}$USER%f casts %F{green}${cmdName}%f..."
                "%F{yellow}➤%f %F{red}It had no effect!%f"
                "${vIcon} %F{magenta}\"Mwuahaha!\"%f (10 ${hero_icons[rupee]} were stolen!)"
            )
            [[ -n "$compText" && "$compData" == *"|"* ]] && entries+=("%F{yellow}➤%f $compText")
            
            # Build Log Box String using HeroUI helper
            HERO_CACHED_BATTLE_LOG=$(HeroUI box "⚔️ BATTLE LOG" "${entries[@]}" --color red)
            HERO_CACHED_BATTLE_LOG+=$'\n'
            ;;
    esac
}

# ------------------------------------------------------------------------------
# HeroNPC Service (Companion & Extensions)
# ------------------------------------------------------------------------------
function HeroNPC() {
    local action=$1; shift
    case "$action" in
        # Usage: HeroNPC set_context exitStatus
        set_context)
            local exitStatus=$1
            if (( exitStatus != 0 )); then
                export HERO_NPC_ARGS="--error"
            elif [[ "$HISTCMD" == "$hero_last_histcmd" ]]; then
                export HERO_NPC_ARGS="--refresh"
            fi
            export hero_last_histcmd=$HISTCMD
            ;;

        # Usage: HeroNPC fetch
        fetch)
            local msg=""
            if typeset -f hero_npc_get_message > /dev/null; then
                local ctx=${HEY_LISTEN:-$HERO_NPC_ARGS}
                # Priority: 1. Manual HEY_LISTEN, 2. First Run, 3. Mystery, 4. Error/Tip
                if [[ -n "$HEY_LISTEN" ]]; then
                    ctx="$HEY_LISTEN"
                elif [[ "$HERO_NPC_SESSION_FIRST_RUN" == "1" ]]; then
                    ctx="--first-run"
                    export HERO_NPC_PENDING_MYSTERY=1
                elif [[ "$HERO_NPC_PENDING_MYSTERY" == "1" && "$HERO_NPC_ARGS" != "--refresh" ]]; then
                    # Randomly trigger mystery on next command after first run
                    ctx="???"
                    unset HERO_NPC_PENDING_MYSTERY
                elif [[ "$HERO_NPC_ARGS" == "--refresh" ]]; then
                    ctx="--refresh"
                else
                    # 25% chance of a tip on success if Navi is not silent
                    if (( RANDOM % 25 == 0 )); then ctx="--tip"; fi
                fi
                msg=$(hero_npc_get_message $ctx)
            fi
            # NOTE: This unset is ineffective when fetch is called via $(HeroNPC fetch)
            # because command substitution runs in a subshell. The real unset happens
            # in precmd() after capturing the output. Left here for direct calls.
            unset HEY_LISTEN HOL_NPC HERO_NPC_ARGS
            [[ "$HERO_HIDE_NAVI" != "1" && -n "$msg" ]] && echo "$msg"
            ;;

        # Usage: HeroNPC banner "Message" hudWidth
        banner)
            local message=$1
            local width=$2
            [[ "$message" != "--refresh" ]] && hero-npc --width "$width" "$message"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# PROMPT CONSTRUCTION
# ------------------------------------------------------------------------------
function precmd() {
    local exitStatus=$?
    local lastCommand=$(fc -ln -1 | sed 's/^[[:space:]]*//')
    
    # Skip game logic during timer ticks (only refresh time display)
    # Use cached values for NPC message and battle log
    if [[ -z "$HERO_TIMER_TICK" ]]; then
        HeroNPC set_context $exitStatus
        HERO_CACHED_NPC_MSG=$(HeroNPC fetch)
        # CRITICAL: Unset NPC context vars HERE in parent shell, not inside fetch()
        # The $(HeroNPC fetch) runs in a subshell, so unset inside it doesn't propagate!
        unset HEY_LISTEN HOL_NPC HERO_NPC_ARGS HERO_NPC_SESSION_FIRST_RUN

        HERO_CACHED_BATTLE_LOG=""
        HeroGame process $exitStatus "$lastCommand" "$HERO_CACHED_NPC_MSG"
        HeroState cycle check 
        HeroStatus refresh
        HeroCache refresh
    fi
    
    # Use cached values (set on real commands, reused on timer ticks)
    local companionMsg="$HERO_CACHED_NPC_MSG"
    local HERO_BATTLE_LOG="$HERO_CACHED_BATTLE_LOG"
    
    local day=$(HeroState cycle day)
    local wallet=$(HeroState wallet get)
    local repoStatus=$(HeroStatus environment) # tri_top|tri_bot|icon|text
    
    # Calculate Gradient Color for Time Header
    local secondsLeft=$(( $(date -d "tomorrow 00:00:00" +%s) - $(date +%s) ))
    secondsLeft=$(( secondsLeft + ( (3 - day) * 86400 ) ))
    local timeColor=$(HeroUI _tcolor $secondsLeft 259200)

    # Unpack repo status
    local triTop triBot areaIcon areaText
    IFS='|' read -r triTop triBot areaIcon areaText <<< "$repoStatus"
    
    local topStart="┌"
    [[ -n "$HERO_BATTLE_LOG" ]] && topStart="├"

    local rowTop=(
        "$triTop" 
        "%F{red}-LIFE-%f" 
        "${timeColor}-DAY-%f"
        "${timeColor}-TIME-%f" 
        "─┬"
        "$(HeroUI bombs)" 
        
        "$(HeroUI rupee)" 
        "┬"
        "${hero_areas[compass]} %F{green}$(HeroUI compass $(HeroStatus check))%f"
    )
    
    local rowBot=(
        "$triBot" 
        "$(HeroStatus hearts)" 
        " $(HeroUI day $day $timeColor)"
        "$(HeroUI timer $day)" 
        "└"
        "$(HeroUI arrows)" 
        
        "$(HeroUI keys)" 
        "─┘"
        "${hero_areas[map]} %F{cyan}$(HeroUI location)%f"
    )
    
    # NPC Processing
    local npcKey="" npcMsg="$companionMsg"
    if [[ "$companionMsg" == *"|"* ]]; then
        IFS='|' read -r npcKey npcMsg <<< "$companionMsg"
    fi
    
    local npcIcon="${HERO_NPC_ICONS[navi]}" # Default
    [[ -n "$npcKey" && -n "${HERO_NPC_ICONS[$npcKey]}" ]] && npcIcon="${HERO_NPC_ICONS[$npcKey]}"
    
    local topString="${(j: :)rowTop}"
    local botString="${(j: :)rowBot}"
    
    # 3. Assemble Equipment Stack (Raw Content Only)
    local -a equipmentRaw=("${(@f)$(HeroUI equipment_stack raw)}")
    local equipmentIcons="${equipmentRaw[1]}"
    local equipmentKeys="${equipmentRaw[2]}"

    # 4. Assemble The Prompt Box
    local rowEndContent=""
    [[ -n "${npcMsg// /}" ]] && rowEndContent="$npcIcon %F{242}$npcMsg %f"
    
    # Build interaction content (goes on equipment keys line)
    local interactionContent=" $areaIcon $areaText %F{green}${hero_icons[sword]}ƶ %f"
    local cursor=$'%{\e[5 q%}'
    
    local boxOutput
    boxOutput=$(HeroUI box_render "$topString" "$botString" "$rowEndContent" "$equipmentIcons" "$equipmentKeys" "$interactionContent")

    # PROMPT LAYOUT
    # Unified Box contains everything (HUD + Equipment + NPC + Prompt)
    PROMPT="${HERO_BATTLE_LOG}
${boxOutput}${cursor}%f"
}

# ------------------------------------------------------------------------------
# TIMER TICK (Second-by-Second Prompt Refresh)
# ------------------------------------------------------------------------------
# TMOUT triggers SIGALRM every N seconds; TRAPALRM refreshes the prompt
TMOUT=1

TRAPALRM() {
    # Set flag so precmd skips game logic (rupee adjustments, etc.)
    HERO_TIMER_TICK=1
    { precmd; zle reset-prompt; } 2>/dev/null
    unset HERO_TIMER_TICK
}

# ------------------------------------------------------------------------------
# 8. STARTUP
# ------------------------------------------------------------------------------
function HeroInitialize() {
    # Initialize all game systems in proper order
    HeroInventory init    # Load item registry and create aliases
    HeroState slots init  # Load equipped items from persistence
    
    # Set initial session state
    hero_last_histcmd=$HISTCMD
    HERO_NPC_SESSION_FIRST_RUN=1
    
    # Display welcome banner
    heroSplash
    
    # Run optional song of time startup effect
    [[ -x "$ZSH_CUSTOM/bin/hero-song-of-time" ]] && "$ZSH_CUSTOM/bin/hero-song-of-time" startup &|
}

# Run initialization
HeroInitialize
