# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"
EGIT_REPO_URI="git@gitlab.fydeos.xyz:misc/detachable_emulator.git"
EGIT_BRANCH="master"

inherit git-r3 linux-info linux-mod

DESCRIPTION="Detachable Device Emulator Kernel Driver"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="kernel-4_14 kernel-5_4 kernel-4_19"

RDEPEND=""

DEPEND="${RDEPEND}"
MODULE_NAMES="fyde-vdtb(kernel/drivers/input)"

pre_pkg_setup() {
  export KV_OUT_DIR=${ROOT}usr/src/linux
#  linux-info_get_any_version
  use kernel-4_14 && export KERNEL_DIR="/mnt/host/source/src/third_party/kernel/v4.14"
  use kernel-5_4 && export KERNEL_DIR="/mnt/host/source/src/third_party/kernel/v5.4"
  use kernel-4_19 && export KERNEL_DIR="/mnt/host/source/src/third_party/kernel/v4.19"
  linux-mod_pkg_setup
  einfo 
  if [ ! -r $KV_OUT_DIR/source ]; then
    ln -f -s $KERNEL_DIR $KV_OUT_DIR/source
  fi
  if [ ! -r ${ROOT}/lib/modules/${KV_FULL}/source ]; then
    ln -f -s $KERNEL_DIR ${ROOT}/lib/modules/${KV_FULL}/source
  fi
  sed -i -e "s|^MAKEARGS := -C.*|MAKEARGS := -C ${KERNEL_DIR}|" $KV_OUT_DIR/Makefile
}

src_compile() {
  unset ARCH
  linux-mod_src_compile    
}

src_install() {
  linux-mod_src_install
  exeinto /lib/udev
  doexe ${FILESDIR}/switch_tablet_mode.sh  
  insinto /etc/init
  doins ${FILESDIR}/load-vdtb-module.conf
}
