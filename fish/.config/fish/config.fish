if status is-interactive
    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish | source

    # Vi keybindings
    fish_vi_key_bindings

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # History expansions (!! and !$)
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

    # Gruvbox Material (Noctalia) syntax highlighting
    set -g fish_color_normal ddc7a1
    set -g fish_color_command a9b665 --bold
    set -g fish_color_keyword e78a4e --bold
    set -g fish_color_quote d8a657
    set -g fish_color_redirection d3869b
    set -g fish_color_end e78a4e
    set -g fish_color_error ea6962
    set -g fish_color_param ddc7a1
    set -g fish_color_comment 928374 --italics
    set -g fish_color_selection --background=504945
    set -g fish_color_search_match --background=504945
    set -g fish_color_operator 7daea3
    set -g fish_color_escape 89b482
    set -g fish_color_autosuggestion 7c6f64
    set -g fish_color_cancel ea6962 --reverse

    # Pager / tab-completion colors
    set -g fish_pager_color_prefix d8a657 --bold --underline
    set -g fish_pager_color_completion ddc7a1
    set -g fish_pager_color_description 928374
    set -g fish_pager_color_selected_background --background=504945
    set -g fish_pager_color_selected_prefix d8a657 --bold
    set -g fish_pager_color_selected_completion ebdbb2
    set -g fish_pager_color_selected_description a89984

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end


# Added by Antigravity CLI installer
set -gx PATH "/home/mark/.local/bin" $PATH
set -gx TERMINAL ghostty
set -gx EDITOR nvim
