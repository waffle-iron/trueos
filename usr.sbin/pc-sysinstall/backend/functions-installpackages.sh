#!/bin/sh
#-
# SPDX-License-Identifier: BSD-2-Clause-FreeBSD
#
# Copyright (c) 2010 iXsystems, Inc.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD$

# Functions which check and load any optional packages specified in the config

. ${BACKEND}/functions.sh
. ${BACKEND}/functions-parse.sh

# Check for any packages specified, and begin loading them
install_packages()
{
  echo "Checking for packages to install..."
  sleep 2

  # First, lets check and see if we even have any packages to install
  get_value_from_cfg installPackages

  # Nothing to do?
  if [ -z "${VAL}" ]; then return; fi

  echo "Installing packages..."
  sleep 3

  local PKGPTH

  # We dont want to be bothered with scripts asking questions
  PACKAGE_BUILDING=yes
  export PACKAGE_BUILDING

  # Install PKGNG into the chroot
  bootstrap_pkgng

  # Lets start by cleaning up the string and getting it ready to parse
  get_value_from_cfg_with_spaces installPackages
  PACKAGES="${VAL}"

  echo_log "Packages to install: `echo $PACKAGES | wc -w | awk '{print $1}'`"
  for i in $PACKAGES
  do
    PKGNAME="${i}"

    # Doing a local install into a different root
    PKGADD="pkg -r ${FSMNT} install -y ${PKGNAME}"
    PKGINFO="pkg info"

    # If the package is not already installed, install it!
    if ! run_chroot_cmd "${PKGINFO} -e ${PKGNAME}" >/dev/null 2>/dev/null
    then
      echo_log "Installing package: ${PKGNAME}"
      $PKGADD
      if [ $? -ne 0 ] ; then
        exit_err "Failed installing: $PKGADD"
      fi
      if ! run_chroot_cmd "${PKGINFO} -e ${PKGNAME}" >/dev/null 2>/dev/null
      then
        echo_log "WARNING: PKGNG reported 0, but pkg: ${PKGNAME} does not appear to be installed!"
      fi
    fi
  done

  echo_log "Package installation complete!"
};
