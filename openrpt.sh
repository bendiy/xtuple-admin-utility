#!/bin/bash
# Copyright (c) 2014-2018 by OpenMFG LLC, d/b/a xTuple.
# See www.xtuple.com/CPAL for the full text of the software license.

if [ -z "$OPENRPT_SH" ] ; then # {
OPENRPT_SH=true

openrpt_menu() {
echo "In: ${BASH_SOURCE} ${FUNCNAME[0]}"

    log "Opened openrpt menu"

    while true; do

        CC=$(whiptail --backtitle "$( window_title )" --menu "$( menu_title OpenRPT\ Menu )" 0 0 10 --cancel-button "Cancel" --ok-button "Select" \
            "1" "Install All" \
            "2" "Install Package" \
            "3" "Build from source" \
            "4" "Install xvfb" \
            "5" "Remove xvfb" \
            "6" "Install initscript" \
            "7" "Return to main menu" \
            3>&1 1>&2 2>&3)

        RET=$?

        if [ $RET -ne 0 ]; then
            break
        else
            case "$CC" in
            "1") log_exec setup_webprint ;;
            "2") log_exec install_openrpt ;;
            "3") log_exec build_openrpt ;;
            "4") log_exec install_xvfb ;;
            "5") log_exec remove_xvfb ;;
            "6") log_exec install_xtuple_xvfb;;
            "7") break ;;
            *) msgbox "Don't know how you got here! Please report on GitHub >> openrpt_menu $CC" && break ;;
            esac
        fi
    done
}

install_openrpt() {
echo "In: ${BASH_SOURCE} ${FUNCNAME[0]}"

    log "Installing OpenRPT from apt..."
    log_exec sudo apt-get -y --quiet install openrpt
    RET=$?
    if [ $RET -ne 0 ]; then
        msgbox "There was an error installing OpenRPT. Check the log and correct any issues before trying again"
    fi
    return $RET

}

build_openrpt() {
  echo "In: ${BASH_SOURCE} ${FUNCNAME[0]} $@"

  cd $WORKDIR || die "Couldn't cd $WORKDIR"

  log "preparing to build OpenRPT from source"
  rm -rf openrpt
  log_exec git clone -q https://github.com/xtuple/openrpt.git || die "Can't clone openrpt"
  log_exec sudo apt-get install --quiet --force-yes qt4-qmake libqt4-dev libqt4-sql-psql || die "Can't install Qt"
  cd openrpt || die "Can't cd openrpt"
  OPENRPT_VER=master #TODO: OPENRPT_VER=`latest stable release`
  log_exec git checkout -q $OPENRPT_VER || die "Can't checkout openrpt"
  log "Starting OpenRPT build (this will take a few minutes)..."
  qmake || die "Can't qmake openrpt"
  make > /dev/null || die "Can't make openrpt"
  log_exec sudo mkdir -p /usr/local/bin || die "Can't make /usr/local/bin"
  log_exec sudo mkdir -p /usr/local/lib || die "Can't make /usr/local/lib"
  log_exec sudo tar cf - bin lib | sudo tar xf - -C /usr/local || die "Can't install OpenRPT"
  log_exec sudo ldconfig || die "ldconfig failed"

}

install_xtuple_xvfb() {
  echo "In: ${BASH_SOURCE} ${FUNCNAME[0]}"

  case "$CODENAME" in
    "trusty") ;&
    "utopic") ;&
    "wheezy")
        log "Installing xtuple-Xvfb to /etc/init.d..."
        log_exec sudo cp $WORKDIR/templates/xtuple-Xvfb /etc/init.d
        log_exec sudo chmod 755 /etc/init.d/xtuple-Xvfb
        log_exec sudo update-rc.d xtuple-Xvfb defaults
        log_exec sudo service xtuple-Xvfb start
        ;;
  esac
}

setup_webprint() {
echo "In: ${BASH_SOURCE} ${FUNCNAME[0]}"

    install_openrpt
    install_xtuple_xvfb
}

fi # }
