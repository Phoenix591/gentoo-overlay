# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..12} )

inherit cmake python-single-r1 flag-o-matic

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

SLOT="0"
LICENSE="BSD"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="mirror" #overlay

BDEPEND="sys-apps/dtc"
DEPEND="${PYTHON_DEPS}"
RDEPEND="${PYTHON_DEPS}
	${DEPEND}"
src_configure() {
	filter-lto
	cmake_src_configure
}
