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
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"
MODULE_NAMES="fyde-vdtb(kernel/drivers/input)"

pre_pkg_setup() {
  linux-info_get_any_version
  export KV_OUT_DIR=${ROOT}usr/src/linux
  export KERNEL_DIR="/mnt/host/source/src/third_party/kernel/v4.14"
  linux-mod_pkg_setup
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
