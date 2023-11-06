# Waydroid Package Manager
Version 1.0.16

Easy to use interface for managing (install/remove) Android apps into [Waydroid](https://waydro.id) and managing (add/remove/update) f-droid based repos as well.
This script is provided as a convenience and is not intended to be used as an enterprise solution.

Copyright (c) 2022 Waydroid, GPLv3

Created by: Waydroid Development Team (Erfan Abdi, Jon West and others)


## Dependencies

    xmlstarlet
    dpkg (armv7a/arm64 detection)

## Install

First, clone this repo:

    repo clone https://github.com/waydroid/waydroid-package-manager

Then you can install it like so:

    sudo chmod +x wpm.sh
    mkdir -p ~/.local/bin && cp wpm.sh ~/.local/bin/wpm
    mkdir -p ~/.local/share/wpm/repos && cp -r repos/* ~/.local/share/wpm/repos

Check that `~/.local/bin` is in your `PATH`; else, add it to your `.bashrc` and log in again (you may want to adjust it for your shell, e.g. by appending the export to your `.profile`):

    if ! echo $PATH | tr : '\n' | grep "$HOME/.local/bin" > /dev/null; then echo 'export PATH="$HOME/.local/bin:$PATH"' | tee -a ~/.bashrc && su $USER; fi

## Usage

    Usage options:
    -h | --help: Shows this dialog
    -c | --clean: cleans up downloaded apps
    -v | --version: Shows version info
    -s | --search | search: Searches all repos for a package
    -l | --listrepos | listrepos: Lists all added fdroid repos
    -la | --listallapps | listallapps: Lists all apps on a specific repo
    -a | --addrepo | addrepo (repo repo_url): Adds a new fdroid repo
    -r | --removerepo | removerepo (repo): Removes a repo
    -u | --updaterepo | updaterepo (repo repo_url): Updates a new fdroid repo
    -i | --install | install (app_name): Searches for & installs an app
    -n | --remove | remove (app_name): uninstalls an app
    -m | --listapps | listapps: Lists all installed apps
    -p | --apkinstall | apkinstall (apk_location): installs an apk

## Examples

Add Repo:

    wpm addrepo unofficialfirefox https://rfc2822.gitlab.io/fdroid-firefox/fdroid/repo

List all installed apps:

    wpm listapps

Search for package (searching by name itself is not yet implemented):

    wpm search org.kde.kdeconnect_tp

Install package:

    wpm install org.kde.kdeconnect_tp

Install APK package:

    wpm apkinstall ~/Downloads/Smart-Dock.apk

Remove pagkage:

    wpm remove org.kde.kdeconnect_tp
