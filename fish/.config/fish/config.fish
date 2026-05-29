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

fish_add_path ~/.platformio/penv/bin
fnm env --use-on-cd | source
