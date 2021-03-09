#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  local -A CFG=()
  source -- config.rc || return $?

  local PKGS=(
    autotools-dev
    build-essential
    libevent-dev
    )
  sudo -E apt install "${PKGS[@]}" || return $?

  local OUT_DIR="$SELFPATH"/result
  mkdir --parents -- "$OUT_DIR"

  local BUILD_DIR="$SELFPATH"/build
  git clone "${CFG[tunsocks_repo_url]}" "$BUILD_DIR" || return $?
  cd -- "$BUILD_DIR" || return $?
  git submodule init || return $?
  git submodule update || return $?

  ./autogen.sh || return $?
  ./configure || return $?
  make || return $?
  list_files

  local WANT=(
    tunsocks
    )
  cp --verbose --target-directory="$OUT_DIR" -- "${WANT[@]}" || return $?

  cd -- "$OUT_DIR" || return $?
  list_files
}


function list_files () {
  echo
  echo "=== Files in $PWD: ==="
  ls -l
  echo "=== --- ==="
  echo
}


build "$@"; exit $?
