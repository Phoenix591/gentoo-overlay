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
IUSE="static-libs gnutls"
RESTRICT="mirror" #overlay

DEPEND="
	sys-apps/dtc
	gnutls? ( >=net-libs/gnutls-3.8.10:= )
"
RDEPEND="${PYTHON_DEPS}
	app-admin/sudo
	dev-lang/perl
	${DEPEND}"
src_prepare() {
	sed -i '/otpset/d' CMakeLists.txt || die # python we handle ourselves
	#unforce static. no longer needed atm
#	sed -i -E 's/(add_library *\([^[:space:]]+ +)STATIC( +[^)]*\))/\1\2/' */CMakeLists.txt || die
	sed -i 's/ -Werror//' */CMakeLists.txt */*/CMakeLists.txt
	if ! use gnutls; then
		sed -i '/add_subdirectory(rpifwcrypto)/d' CMakeLists.txt || die
	fi
	cmake_src_prepare
}
src_configure() {
	filter-lto
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex static-libs OFF ON)
	)
	cmake_src_configure
}
src_install() {
	cmake_src_install
	python_foreach_impl python_doscript otpset/otpset
}
