# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit cmake python-r1 flag-o-matic

DESCRIPTION="Misc useful commands for Raspberry Pis"
HOMEPAGE="https://github.com/raspberrypi/utils"
if [ "${PV}" == 9999 ]; then
	EGIT_REPO_URI="https://github.com/raspberrypi/utils/"
	inherit git-r3
else
	KEYWORDS="~arm ~arm64"
	SRC_URI="https://github.com/raspberrypi/${PN}/archive/refs/tags/v${PV}.tar.gz"
fi
PATCHES=( "${FILESDIR}/dtovl-install.patch" )

LICENSE="BSD"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="mirror" #overlay

DEPEND="sys-apps/dtc"
RDEPEND="${PYTHON_DEPS}
	app-admin/sudo
	dev-lang/perl
	${DEPEND}"
src_prepare() {
	sed -i '/otpset/d' CMakeLists.txt || die # python we handle ourselves
	sed -i 's/dtovl STATIC dtoverlay.c/dtovl SHARED dtoverlay.c/' dtmerge/CMakeLists.txt|| die
	sed -i 's/ -Werror//' piolib/examples/CMakeLists.txt
	cmake_src_prepare
}
src_configure() {
	filter-lto
	cmake_src_configure
}
src_install() {
	cmake_src_install
	python_foreach_impl python_doscript otpset/otpset
}
