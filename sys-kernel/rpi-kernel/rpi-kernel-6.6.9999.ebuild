# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit kernel-build toolchain-funcs

MY_P="linux-${PV%.*}"

DESCRIPTION="Linux kernel built with Raspberry Pi patches"
HOMEPAGE="
	https://github.com/raspberrypi/linux
	https://www.kernel.org/
"
#S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
#KEYWORDS=""
IUSE="debug pi1 pi2 pi3 pi4 pi5"
REQUIRED_USE="
	^^ ( pi1 pi2 pi3 pi4 pi5 )
"
EGIT_REPO_URI="https://github.com/raspberrypi/linux/"
EGIT_BRANCH="rpi-$(ver_cut 1-2).y"
inherit git-r3
DEPEND="
	initramfs? ( sys-kernel/dracut )
"
#PDEPEND="
#	>=virtual/dist-kernel-${PV}
#"
QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

src_prepare() {
	default
}
src_configure() {
	tc-export_build_env
	export KCFLAGS="${BUILD_CFLAGS}"
	mkdir -p "${WORKDIR}/mkconfig"
	local CDIR="${WORKDIR}/mkconfig"
	#Defconfig device/arch pairs from
	#  https://www.raspberrypi.com/documentation/computers/linux_kernel.html
	# Retrived/updated: 12/12/2023
	if use pi1; then
		export KERNEL=kernel
		local DEFCONFIG="bcmrpi_defconfig"
	elif (use pi2 || use pi3 ) && use arm; then
		export KERNEL=kernel7
		local DEFCONFIG="bcm2709_defconfig"
	elif (use pi3 || use pi4 ) && use arm64; then
		export KERNEL=kernel8
		local DEFCONFIG="bcm2711_defconfig"
	elif use pi4 && use arm; then
		export KERNEL=kernel7l
		local DEFCONFIG="bcm2711_defconfig"
	elif use pi5 && use arm64; then
		export KERNEL=kernel_2712
		local DEFCONFIG="bcm2712_defconfig"
	else
		die "Invalid Use/arch combination"
	fi
	emake O="${CDIR}" "${DEFCONFIG}"
	cp "${CDIR}/.config" ./ || die
	kernel-build_merge_configs # apply user configs from /etc/kernel/config.d
	kernel-build_src_configure
}
src_install() {
	kernel-build_src_install
	into /etc/kernel/postinst.d
	doins "${FILESDIR}/99_pi-rename"
}
pkg_postinst() {
	kernel-build_pkg_postinst
	einfo "You probabily want to rename your kernel, device tree, and overlays"
	einfo "to the locations expected by the Pi's bootloader"
	einfo "An example script is installed into /etc/kernel/postinst.d"
}
