function sync-packages
    echo "Updating package manifests..."
    # Arch Packages
    pacman -Qqe | grep -v "$(pacman -Qqm)" >~/dotfiles/pkglist/pacman.txt
    # AUR Packages
    pacman -Qqm >~/dotfiles/pkglist/aur.txt
    # Flatpak Apps
    flatpak list --app --columns=application >~/dotfiles/pkglist/flatpaks.txt

    echo "Committing to Git..."
    cd ~/dotfiles
    git add pkglist/
    git commit -m "Auto-update package manifests"
    git push
    echo "Done!"
end

#fish_add_path ~/.platformio/penv/bin
fnm env --use-on-cd | source

set -gx EDITOR nvim


# Added by Antigravity CLI installer
set -gx PATH "/home/mark/.local/bin" $PATH

# ==========================================
# MATERIAL GRUVBOX CONFIG FOR FISH
# ==========================================

# Disable the generic default greeting
set -g fish_greeting ""

# Custom Gruvbox Greeting Banner
function fish_greeting
    # Colors pulled straight from your Material Gruvbox spec
    set -l orange (set_color d79921)
    set -l blue   (set_color 458588)
    set -l cream  (set_color ebdbb2)
    set -l gray   (set_color a89984)
    set -l normal (set_color normal)

    echo ""
    echo "                                  $blue      _.._     "
    echo "                                  $blue    .' ._  '.    "
    echo "                                  $blue   /  /   \\  \\  "
    echo "                                  $blue   |  |   |  |     "
    echo "                                    $blue '. '._.' .'     "
    echo "                                      $blue '--''--'     "
    echo "                                                       "
    echo "                                       $cream   __  "
    echo "                                       $cream  /\_\ "
    echo "                                      $cream / / // "
    echo "                                      $cream/ /  / "
    echo "                                $cream   __/ /  / "
    echo "                              ○  $cream/\__\/  / "
    echo "                          $cream//|\ \_\/\/___/ "
    echo "                         $cream//\  \/_/      "
    echo "                         $cream //_//  "
    echo "                                      "
    echo "    $orange      _.._                "
    echo "   $orange    .' ._  '.$cream 🍰 ≡ "
    echo "   $orange   /  /   \\  \\    "
    echo "   $orange   |  |   |  |       "
    echo "   $orange    '. '._.' .'      "
    echo "   $orange      '--''--'      "
    echo "  $gray                     "
    echo "  $gray   [ testing protocols initialized ] "
    echo ""
end

# --- Syntax Highlighting Colors ---
set -g fish_color_normal ebdbb2
set -g fish_color_command 458588       # Blue / Secondary Accent
set -g fish_color_quote b8bb26         # Pastel Green
set -g fish_color_redirection b16286   # Purple / Custom Accent
set -g fish_color_end a89984           # Muted Gray
set -g fish_color_error cc241d         # Destructive Red
set -g fish_color_param ebdbb2         # Normal Text
set -g fish_color_comment 504945        # Dark Border / Comment Gray
set -g fish_color_match d79921          # Gold Match
set -g fish_color_selection 3c3836     # Muted Popover Background

# --- Pager / Autocomplete Menu Colors ---
set -g fish_pager_color_prefix 458588
set -g fish_pager_color_completion ebdbb2
set -g fish_pager_color_description a89984
set -g fish_pager_color_progress 3c3836

zoxide init fish | source
starship init fish | source
set -gx PATH (string match -v '*platformio*' $PATH)

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"

# ==========================================
# HISTORY EXPANSIONS (!! and !$)
# ==========================================
function __history_previous_command
    echo $history[1]
end

function __history_last_argument
    set -l cmd (string split -n " " -- $history[1])
    if set -q cmd[-1]
        echo $cmd[-1]
    end
end

abbr -a !! --position anywhere --function __history_previous_command
abbr -a -- '!$' --position anywhere --function __history_last_argument
