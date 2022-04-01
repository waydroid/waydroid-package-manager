# Waydroid Package Manager

Easy to manage interface for managing (install/remove) Android apps into Waydroid and managing (add/remove/update) repos as well 

## Install

First, clone this repo:

    repo clone https://github.com/waydroid/waydroid-package-manager

Then you can install it like so:

    sudo chmod +x wpm.sh
    cp wpm.sh ~/.local/bin/wpm && cp -r repos/ ~/.local/share/wpm/

## Usage

    Usage options:
    -h | --help: Shows this dialog
    -c | --clean: cleans up downloaded apps
    -v | --version: Shows version info
    -s | --search | search: Searches all repos for a package
    -l | --listrepos | listrepos: Lists all added fdroid repos
    -a | --addrepo | addrepo (repo repo_url): Adds a new fdroid repo
    -r | --removerepo | removerepo (repo): Removes a repo
    -u | --updaterepo | updaterepo (repo repo_url): Updates a new fdroid repo
    -i | --install | install (app_name): Searches for & installs an app
    -n | --remove | remove (app_name): uninstalls an app
    -m | --listapps | listapps: Lists all installed apps