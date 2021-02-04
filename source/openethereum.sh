#!/bin/bash

GITHUB="github.com"

help() {
	echo "Usage is: -m --mirror [ wyzh / fastgit ] -u --uninstall"
}

check_os() {
	if [ "$(uname)" = "Linux" ] ; then
	PKG="linux"   # linux is default

	elif [ "$(uname)" = "Darwin" ] ; then
		PKG="macos"
		echo "Running on Apple"
	else
		echo "Unknown operating system"
		echo "Please select your operating system"
		echo "Choices:"
		echo "	     linux - any linux distro"
		echo "	     macos - MacOS"
		read PKG
	fi
}

get_package() {
  RELEASE_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://${GITHUB}/openethereum/openethereum/releases/latest)
  TAG="${RELEASE_URL##*/}"
  DOWNLOAD_FILE="https://${GITHUB}/openethereum/openethereum/releases/download/${TAG}/openethereum-${PKG}-${TAG}.zip"
  NEW_VERSION=$(echo $TAG | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tr -d 'v')
}

check_upgrade() {

  parity_bin=$(which openethereum)

	if [ -z $parity_bin ] ; then
		OLD_VERSION="0.0.0"
	else
		OLD_VERSION=$(openethereum --version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tr -d 'v')
	fi

	if [ "$NEW_VERSION" = "$OLD_VERSION" ] ; then
		echo "OpenEthereum $NEW_VERSION already installed"
		exit 1
	fi

  if  version_gt "$NEW_VERSION" "$OLD_VERSION"  ; then
		echo "Upgrading OpenEthereum from $OLD_VERSION to $NEW_VERSION"
	else
		echo "Existing version of OpenEthereum: $OLD_VERSION is newer than the version you attempting to install: $NEW_VERSION"
		exit 1
	fi
}

install() {
  TMPDIR=$(mktemp -d) && cd $TMPDIR
	curl -Lo temp.zip $DOWNLOAD_FILE
	unzip temp.zip
	if [ "$PKG" = "linux" ] ; then
	  sudo cp $TMPDIR/ethkey /usr/bin && sudo chmod +x /usr/bin/ethkey
	  sudo cp $TMPDIR/ethstore /usr/bin && sudo chmod +x /usr/bin/ethstore
	  sudo cp $TMPDIR/openethereum /usr/bin && sudo chmod +x /usr/bin/openethereum
	  sudo cp $TMPDIR/openethereum-evm /usr/bin && sudo chmod +x /usr/bin/openethereum-evm

	fi

	if [ "$PKG" = "macos" ] ; then
	  sudo cp $TMPDIR/ethkey /usr/local/bin && sudo chmod +x /usr/local/bin/ethkey
	  sudo cp $TMPDIR/ethstore /usr/local/bin && sudo chmod +x /usr/local/bin/ethstore
	  sudo cp $TMPDIR/openethereum /usr/local/bin && sudo chmod +x /usr/local/bin/openethereum
	  sudo cp $TMPDIR/openethereum-evm /usr/local/bin && sudo chmod +x /usr/local/bin/openethereum-evm
	fi
}

uninstall(){
  [[ -e /usr/bin/ethkey ]] && sudo rm -f /usr/bin/ethkey;
  [[ -e /usr/bin/ethstore ]] && sudo rm -f /usr/bin/ethstore;
  [[ -e /usr/bin/openethereum ]] && sudo rm -f /usr/bin/openethereum;
  [[ -e /usr/bin/openethereum-evm ]] && sudo rm -f /usr/bin/openethereum-evm;

  [[ -e /usr/local/bin/ethkey ]] && sudo rm -f /usr/local/bin/ethkey;
  [[ -e /usr/local/bin/ethstore ]] && sudo rm -f /usr/local/bin/ethstore;
  [[ -e /usr/local/bin/openethereum ]] && sudo rm -f /usr/local/bin/openethereum;
  [[ -e /usr/local/bin/openethereum-evm ]] && sudo rm -f /usr/local/bin/openethereum-evm;
}

cleanup() {
  rm -rf $TMPDIR
}

version_gt() {
	test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

## MAIN ##

## curl and unzip installed?
which curl &> /dev/null
if [[ $? -ne 0 ]] ; then
    echo '"curl" binary not found, please install and retry'
    exit 1
fi
which unzip &> /dev/null
if [[ $? -ne 0 ]] ; then
    echo '"unzip" binary not found, please install and retry'
    exit 1
fi
##

while [ "$1" != "" ]; do
	case $1 in
	-m | --mirror )       shift
		if [ $1 == "wyzh" ] || [ $1 == "wuyanzheshui" ]; then
		  GITHUB="github.wuyanzheshui.workers.dev"
		fi
		if [ $1 == "fastgit" ]; then
		  GITHUB="hub.fastgit.org"
		fi
		;;
  -u | --uninstall )    shift
    uninstall
    echo 'Uninstalled!'
    exit 0
    ;;
	* )  	help
		exit 1
		esac
	shift
done

check_os
get_package
check_upgrade
install
cleanup
