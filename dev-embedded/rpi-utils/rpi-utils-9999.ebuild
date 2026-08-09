# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

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
	sys-libs/ncurses:=
	gnutls? ( >=net-libs/gnutls-3.8.10:= )
"
RDEPEND="${PYTHON_DEPS}
	app-admin/sudo
	dev-lang/perl
	${DEPEND}"
src_prepare() {
	PUREPYD=( otpset ovmerge overlaycheck dtapply otamaker )
	for dir in ${PUREPYD[@]}; do sed -i "/add_subdirectory.*$dir/d" CMakeLists.txt || die ; done
	# python we handle ourselves
	sed -i '/install/d' splashasm/CMakeLists.txt || die # python but with c parser in subdirectory
	sed -i "s|exclusions_file = .*|exclusions_file = '/usr/share/${PN}/overlaycheck_exclusions.txt'|" \
		overlaycheck/overlaycheck || die # move exclusions file out of bin
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
python_install() {
	python_doscript otpset/otpset
	python_domodule ovmerge/ovmerge_engine.py
	python_doscript ovmerge/ovmerge
	python_newscript splashasm/splash_assembler.py splash-assembler
	python_doscript overlaycheck/overlaycheck
	python_doscript dtapply/dtapply
	python_doscript otamaker/otamaker
}
src_install() {
	cmake_src_install
	python_foreach_impl python_install
	insinto /usr/share/${PN}
	doins overlaycheck/overlaycheck_exclusions.txt
}
