function fish_greeting
    set -l cols (tput cols 2>/dev/null)
    if test -z "$cols"
        set cols 80
    end

    # Full banner is 54 columns wide.
    if test "$cols" -ge 56
        set_color d8a657
        echo '   ______                 __'
        echo '  / ____/______  ___  __ / /_  ____  _  __'
        set_color e78a4e
        echo ' / / __ / ___/ / / / | / / __ \/ __ \| |/_/'
        set_color ea6962
        echo '/ /_/ // /  / /_/ /| |/ / /_/ / /_/ />  <'
        echo '\____//_/   \__,_/ |___/_.___/\____/_/|_|'
        set_color normal
        echo
    else if test "$cols" -ge 22
        # Compact single-line banner for narrow terminals.
        set_color d8a657
        printf ' %s' (set_color e78a4e)' 𓊪 '(set_color normal)
        set_color d8a657
        printf '%s' hypr
        set_color normal
        echo
    end

    command -v fastfetch &> /dev/null
    or return

    # fastfetch lays the logo out beside the module box: the logo is ~48
    # columns and the box ~41, so that two-column layout needs ~90 columns
    # before it fits. Below that fastfetch happily emits wider lines than the
    # terminal has, and the hard wrap smushes the box. Ask for a narrower
    # structure instead of letting the terminal wrap for us.
    if test "$cols" -ge 90
        fastfetch --key-padding-left 5
    else if test "$cols" -ge 40
        fastfetch --logo none --key-padding-left 1
    else
        # Even the logo-less box is 37 wide, so below 40 the box has to go
        # too. Colons instead of commas drop the box and stop the value
        # column from padding out to a fixed width. This set is the
        # shortest that still carries the essentials: the wm and packages
        # values are both longer than 30 columns on their own.
        fastfetch --logo none --key-padding-left 0 \
            --structure os:shell:uptime:host
    end
end
