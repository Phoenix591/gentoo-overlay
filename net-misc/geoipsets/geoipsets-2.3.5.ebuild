# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1 systemd

DESCRIPTION="Utility to generate country-specific network ranges"
HOMEPAGE="https://pypi.org/project/geoipsets/"
#SRC_URI="https://files.pythonhosted.org/packages/90/cd/0beacbcfdf9b3af9e7c615cb3dba7ec4be1030d4b283e3c9717e3fd9af3c/jsonlines-1.2.0.tar.gz"
if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/chr0mag/geoipsets"
	inherit git-r3
else
	KEYWORDS="~amd64 ~arm64 ~x86"
#	tests not distributed through pypi mirror
#	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
	SRC_URI="https://github.com/chr0mag/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
fi
LICENSE="GPL-3"
SLOT="0"
IUSE="test"
RESTRICT="mirror" #overlay, no real issue

#DEPEND=""
RDEPEND=( "${DEPEND}"
	"dev-python/requests[${PYTHON_USEDEP}]"
	"dev-python/beautifulsoup4[${PYTHON_USEDEP}]"
)
BDEPEND="(
	test? ( "${RDEPEND}"
		"dev-python/pytest[${PYTHON_USEDEP}]" )
	)"

distutils_enable_tests pytest
#RESTRICT="test" # broken/outdated upstream, fails 5 tests

S="${WORKDIR}/${P}/python"

src_install() {
	distutils-r1_src_install
	systemd_dounit ../systemd/update-geoipsets.{service,timer}
	dobin ../bash/build-country-sets.sh
	insinto /etc
	doins ../bash/bcs.conf
	doins geoipsets.conf
}

python_test() {
	local EPYTEST_DESELECT=(
		#Fails
		'tests/config_test.py::test_no_cli_opts_no_config_file'
	)
	epytest
}
