set -l fzf_theme_opts "\
--color=bg+:#4e4639
--color=bg:#17130b
--color=spinner:#ece1d4
--color=hl:#ffb4ab
--color=fg:#ece1d4
--color=header:#ffb4ab
--color=info:#ecc06c
--color=pointer:#ece1d4
--color=marker:#d1c5b4
--color=fg+:#ece1d4
--color=prompt:#ecc06c
--color=hl+:#ffb4ab
--color=selected-bg:#4e4639
--color=border:#4e4639
--color=label:#ece1d4"

if set -q FZF_DEFAULT_OPTS[1]; and test -n "$FZF_DEFAULT_OPTS"
    set -Ux FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS
$fzf_theme_opts"
else
    set -Ux FZF_DEFAULT_OPTS "$fzf_theme_opts"
end
