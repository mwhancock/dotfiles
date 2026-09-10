function fish_greeting
    set_color d8a657
    echo '   ______                 __               '
    echo '  / ____/______  ___  __ / /_  ____  _  __'
    set_color e78a4e
    echo ' / / __ / ___/ / / / | / / __ \/ __ \| |/_/'
    set_color ea6962
    echo '/ /_/ // /  / /_/ /| |/ / /_/ / /_/ />  <  '
    echo '\____//_/   \__,_/ |___/_.___/\____/_/|_|  '
    set_color normal
    echo
    command -v fastfetch &> /dev/null && fastfetch --key-padding-left 5
end
