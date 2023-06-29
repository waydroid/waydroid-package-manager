#!/bin/bash
# set -e

# This script adds a package manager for Waydroid and will work across all devices. 
# This script is provided as a convenience and is not intended to be used as an enterprise solution.
# 
# Copyright (c) 2022 Waydroid, GPLv3
#
# Created by: Waydroid Development Team (Erfan Abdi, Jon West and others)

USER_HOME=$(xdg-user-dir)
SHARED_DIR="$USER_HOME/.local/share/wpm"
BINFOLDER="$SHARED_DIR/bin"	
TEMPFOLDER="$SHARED_DIR/tmp"
REPOSFOLDER="$SHARED_DIR/repos"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LT_BLUE='\033[0;94m'

NC='\033[0m' # No Color


# Device type selection	(v2)
MAIN_ARCH=""
SUB_ARCH=""
case $(uname -m) in
    i386)   MAIN_ARCH="x86" && echo "ABI:x86 & ABI2:x86 was detected" ;;
    i686)   MAIN_ARCH="x86" && echo "ABI:x86 & ABI2:x86 was detected" ;;
    x86_64) MAIN_ARCH="x86_64" && SUB_ARCH="x86" && echo "ABI:x86_64 & ABI2:x86 was detected" ;;
    arm)    dpkg --print-architecture | grep -q "arm64" && MAIN_ARCH="arm64-v8a" && SUB_ARCH="armeabi-v7a" && echo "ABI:arm64-v8a & ABI2:armeabi-v7a was detected" || MAIN_ARCH="armeabi-v7a" && echo "ABI:armeabi-v7a was detected" ;;
esac

mkdir -p $SHARED_DIR
mkdir -p $BINFOLDER

downloadStuff() {
	    what="$1"
		where="$2"
		
		while ! wget --connect-timeout=10 --tries=2 "$what" -O "$where";do sleep 1;done
}

#downloadFromRepo repo repo_dir packageName overrides
downloadFromRepo() {
        # Repos 
		repo="$1"
		repo_dir="$2"
		package="$3"
		overrides="$4"
				
		mkdir -p "$repo_dir"
	if [ ! -f "$repo_dir"/index.xml ];then
		downloadStuff "$repo"/index.jar "$repo_dir"/index.jar
		unzip -po "repo_dir"/index.jar index.xml > "$repo_dir"/index.xml
	fi
		marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]' -v ./nativecode "$repo_dir"/index.xml || true)"
		apk="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[1]' -v ./apkname "$repo_dir"/index.xml)"
		downloadStuff "$repo"/"$apk" $BINFOLDER/"$apk"

}

# addRepo repo repo_dir
# Creates a repo file in repo/ directory and adds the url to it.
addRepo() {
	repo="$1"
	repoUrl="$2"
	if [ ! -f "$REPOSFOLDER/$repo" ];then
		echo "$repoUrl" > "$REPOSFOLDER/$repo"
	fi
	echo "Added repo: $repo $repoUrl"
	exit 0
}

updateRepo() {
	repo="$1"
	repoUrl="$2"
	if [ -f "$REPOSFOLDER/$repo" ];then
		echo "$repoUrl" > "$REPOSFOLDER/$repo"
	fi
	echo "Updated repo: $repo $repoUrl"
	exit 0
}

removeRepo() {
	repo="$1"
	if [ -f "$REPOSFOLDER/$repo" ];then
		rm -rf "$REPOSFOLDER/$repo"
	fi
	echo "Removed repo: $repo"
	exit 0
}

listRepos() {
	for repo in $REPOSFOLDER/*;do
		echo -e "${GREEN}$(basename "$repo")${NC} $(cat "$repo")"
	done
	exit 0
}

#searchRepo repo repo_dir packageName
searchRepo() {
        # Repos 
		repo="$1"
		repo_dir="$2"
		package="$3"
				
		mkdir -p "$repo_dir"
	if [ ! -f "$repo_dir"/index.xml ];then
		downloadStuff "$repo"/index.jar "$repo_dir"/index.jar
		unzip -po "$repo_dir"/index.jar index.xml > "$repo_dir"/index.xml
	fi
		marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]' -v ./nativecode "$repo_dir"/index.xml || true)"
		apk="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[1]' -v ./apkname "$repo_dir"/index.xml)"
		size="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./size "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[1]' -v ./size "$repo_dir"/index.xml)"
		version="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./version "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[1]' -v ./version "$repo_dir"/index.xml)"
		sdk="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./sdkver "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[1]' -v ./sdkver "$repo_dir"/index.xml)"
		targetsdk="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./targetSdkVersion "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]/package[1]' -v ./targetSdkVersion "$repo_dir"/index.xml)"
		name="$(xmlstarlet sel -t -m '//application[id="'"$package"'"]' -v ./name "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[id="'"$package"'"]' -v ./name "$repo_dir"/index.xml)"
		# Search by name instead of id
		npname="$(xmlstarlet sel -t -m '//application[name="'"$package"'"]' -v ./name "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[name="'"$package"'"]' -v ./name "$repo_dir"/index.xml)"
		npapk="$(xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[1]' -v ./apkname "$repo_dir"/index.xml)"
		npsize="$(xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./size "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[1]' -v ./size "$repo_dir"/index.xml)"
		npversion="$(xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./version "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[1]' -v ./version "$repo_dir"/index.xml)"
		npsdk="$(xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./sdkver "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[1]' -v ./sdkver "$repo_dir"/index.xml)"
		nptargetsdk="$(xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[versioncode="'"$marketvercode"'"]' -v ./targetSdkVersion "$repo_dir"/index.xml || xmlstarlet sel -t -m '//application[name="'"$package"'"]/package[1]' -v ./targetSdkVersion "$repo_dir"/index.xml)"
		
		if [ "$apk" != "" ]; then 
			echo ""
			echo -e "${GREEN}Found in repo: ${NC}$repo"
        	echo -e "Package: ${LT_BLUE}$apk${NC}"
        	echo "Size: $size"
        	echo "Version: $version"
        	echo "SDK: $sdk"
        	echo "TargetSDK: $targetsdk"
        	echo "Name: $name"
			echo ""
			return 0
		elif [ "$npname" != "" ]; then
			echo ""
			echo -e "${GREEN}Found in repo: ${NC}$repo"
        	echo -e "Package: ${LT_BLUE}$npapk${NC}"
        	echo "Size: $npsize"
        	echo "Version: $npversion"
        	echo "SDK: $npsdk"
        	echo "TargetSDK: $nptargetsdk"
        	echo "Name: $npname"
			echo ""
			return 0
		else
			# echo "$3 Not in repo: $repo"
			return 1
		fi
}

listAllRepoApps() {
	repo="$1"
	repo_dir="$2"

	# Process given repo first, because the user only passes in the repo name, not link
	repo_link=$(cat "$repo")

	if [ ! -f "$repo_dir"/index.xml ]; then
		downloadStuff "$repo_link"/index.jar "$repo_dir"/index.jar
		unzip -po "$repo_dir"/index.jar index.xml > "$repo_dir"/index.xnl
	fi

	PACKAGE_NAMES=()
	PACKAGE_IDS=$(xmlstarlet sel -t --value-of '//application/id' "$repo_dir"/index.xml)

	for i in $PACKAGE_IDS; do
		PACKAGE_NAMES+=( "$(xmlstarlet sel -t --value-of '//application[id = "'"$i"'"]'/name "$repo_dir"/index.xml)" )
	done

	echo -e "${GREEN}Found the following apps:${NC}"
	for (( i=0; i<${#PACKAGE_NAMES[@]}; i++ )); do
		echo "Package: ${PACKAGE_NAME[i]}"
	done
}

cleanUp() {
	rm -rf $TEMPFOLDER
	rm -rf $BINFOLDER
}

#installApp apkName 
installApp() {
	apkName="$1"
	if [ ! -f $BINFOLDER/$apkName ];then
		echo -e "${RED}$apkName not found in $BINFOLDER/$apkName ${NC}"
		exit 1
	fi
	if [ "$(waydroid status | grep RUNNING)" == "" ];then
		echo -e "${RED}waydroid is not running, please start it first ${NC}"
		exit 1
	fi
	echo -e "${GREEN}Installing $apkName ${NC}"
	waydroid app install $BINFOLDER/$apkName
}

removeApp() {
	apkName="$1"
	if [ "$(waydroid status | grep RUNNING)" == "" ];then
		echo -e "${RED}waydroid is not running, please start it first ${NC}"
		exit 1
	fi
	echo -e "${GREEN}Uninstalling $apkName ${NC}"
	waydroid app remove $apkName
}

listApps() {
	if [ "$(waydroid status | grep RUNNING)" == "" ];then
		echo -e "${RED}waydroid is not running, please start it first ${NC}"
		exit 1
	fi
	echo -e "${GREEN}Listing apps ${NC}"
	waydroid app list
}

installApk() {
	apkName="$1"
	if [ "$(waydroid status | grep RUNNING)" == "" ];then
		echo -e "${RED}waydroid is not running, please start it first ${NC}"
		exit 1
	fi
	echo -e "${GREEN}Installing $apkName ${NC}"
	waydroid app install $apkName
}

# Sort through flags
while test $# -gt 0
do
  case $1 in

  # Normal option processing
    -h | --help)
      echo "Usage: $0 options"
      echo "options: -h | --help: Shows this dialog"
      echo "	-c | --clean: cleans up downloaded apps"
      echo "	-v | --version: Shows version info"
      echo "	-s | --search | search: Searches all repos for a package"
      echo "	-l | --listrepos | listrepos: Lists all added fdroid repos"
      echo "	-la | --listallapps | listallapps: Lists all apps on a specific repo"
      echo "	-a | --addrepo | addrepo (repo repo_url): Adds a new fdroid repo"
      echo "	-r | --removerepo | removerepo (repo): Removes a repo"
      echo "	-u | --updaterepo | updaterepo (repo repo_url): Updates a new fdroid repo"
      echo "	-i | --install | install (app_name): Searches for & installs an app"
      echo "	-n | --remove | remove (app_name): uninstalls an app"
      echo "	-m | --listapps | listapps: Lists all installed apps"
      echo "	-p | --apkinstall | apkinstall (apk_location): installs an apk"
	  exit 0
      ;;
    -c | --clean)
      clean="y";
      echo "Cleaning..."
	  cleanUp
      ;;
    -v | --version)
      echo "Version: Waydroid Package Manager 0.01"
      echo "Updated: 03/31/2022"
	  exit 0
      ;;
    -s | --search | search)
      SEARCH="true";
	  ;;
    -a | --addrepo | addrepo)
	  ADD_REPO="true";
      ;;
    -r | --removerepo | removerepo)
	  REMOVE_REPO="true";
      ;;
    -u | --updaterepo | updaterepo)
	  UPDATE_REPO="true";
      ;;
    -l | --listrepos | listrepos)
	  LIST_REPOS="true";
      ;;
    -la | --listallapps | listallapps)
          shift
          LIST_ALL_APPS="true"
          REPONAME=$1
      ;;
    -i | --install | install)
	  INSTALL="true";
      ;;
    -n | --remove | remove)
	  REMOVE="true";
      ;;
    -m | --listapps | listapps)
	  LIST_APPS="true";
      ;;
    -p | --apkinstall | apkinstall)
	  APKINSTALL="true";
      ;;
  # ...

  # Special cases
    --)
      break
      ;;
    --*)
      # error unknown (long) option $1
      ;;
    -?)
      # error unknown (short) option $1
      ;;

  # FUN STUFF HERE:
  # Split apart combined short options
    -*)
      split=$1
      shift
      set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
      continue
      ;;

  # Done with options
    *)
      break
      ;;
  esac

  # for testing purposes:
  shift
done

if [ "$SEARCH" == "true" ]; then
	reponames=$(ls $REPOSFOLDER)
	# echo "Searching for $1..."
	for reponame in $reponames; do
		# echo "Searching $reponame..."
		IFS=' ' read -r -a search_repos <<< $(cat $REPOSFOLDER/$reponame)
		for search_repo in $search_repos; do
			# echo "Searching $search_repo..."
			if searchRepo "$search_repo" "$TEMPFOLDER/$reponame" "$1" ; then
				# echo "Found in repo: $search_repo"
				found="true"
			fi
			
		done
	done
	if [ ! $found ]; then
		echo -e "${RED}$apk not found ${NC}"
	fi
	exit 0
elif [ "$ADD_REPO" == "true" ]; then
	addRepo "$1" "$2";
elif [ "$REMOVE_REPO" == "true" ]; then
	removeRepo "$1";
elif [ "$UPDATE_REPO" == "true" ]; then
	updateRepo "$1" "$2";
elif [ "$LIST_REPOS" == "true" ]; then
	listRepos ;
elif [ "$LIST_APPS" == "true" ]; then
	listApps ;
elif [ "$LIST_ALL_APPS" == "true" ]; then
	listAllRepoApps "$REPOSFOLDER"/"$REPONAME" "$TEMPFOLDER"/"$REPONAME"
elif [ "$REMOVE" == "true" ]; then
	removeApp "$1";
elif [ "$APKINSTALL" == "true" ]; then
	installApk "$1";
elif [ "$INSTALL" == "true" ]; then
    # Start the main event
    # echo -e "${YELLOW}# Grabbing App${NC}"

	reponames=$(ls $REPOSFOLDER)
	# echo "Reponames: $reponames"
	for reponame in $reponames; do
		# echo "Reponame: $reponame"
		IFS=' ' read -r -a search_repos <<< $(cat $REPOSFOLDER/$reponame)
		# echo "$search_repos"
		for search_repo in $search_repos; do
			if searchRepo "$search_repo" "$TEMPFOLDER/$reponame" "$1" ; then
				# echo "Found in repo: $search_repo"
				found="true"
    			downloadFromRepo "$search_repo" "$TEMPFOLDER/$reponame" "$1" 
				# if app is downloaded, install it
				
				installApp "$apk"
				# cleanUp

    			echo -e "${GREEN}# DONE${NC}"
				exit 1
			else
				# echo -e "${RED}$apk not found in $search_repo ${NC}"
				echo -e -n "."
			fi
		done
	done

	if [ ! $found ]; then
		echo -e "${RED}$apk not found ${NC}"
	fi
else
	echo "No options specified, please see -h | --help for more info"

fi

