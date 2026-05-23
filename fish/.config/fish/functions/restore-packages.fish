function restore-packages
    echo "Starting restoration of packages (Paru-powered)..."

    # 1. Ensure Paru is installed (Paru requires base-devel)
    if not command -v paru >/dev/null
        echo "Installing paru (AUR helper)..."
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si
    end

    # 2. Restore Official Repos
    echo "Installing official packages..."
    sudo pacman -S --needed - <~/dotfiles/fish/.config/fish/pkglist/pacman.txt

    # 3. Restore AUR Packages via Paru
    echo "Installing AUR packages..."
    # Paru handles both repo and AUR packages well, 
    # but we'll feed it just the AUR list
    paru -S --needed - <~/dotfiles/fish/.config/fish/pkglist/aur.txt

    # 4. Restore Flatpaks
    echo "Restoring Flatpaks..."
    if command -v flatpak >/dev/null
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        xargs -a ~/dotfiles/fish/.config/fish/pkglist/flatpaks.txt flatpak install -y flathub
    end

    echo "Done! Your workstation is fully restored."
end
