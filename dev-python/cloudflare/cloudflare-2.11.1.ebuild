# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Python wrapper for the Cloudflare v4 API"
HOMEPAGE="https://pypi.org/project/cloudflare/"
#SRC_URI="https://files.pythonhosted.org/packages/9b/8c/973e3726c2aa73821bb4272717c6f9f6fc74e69d41ba871bdf97fc671782/${P}.tar.gz"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
SRC_URI="https://github.com/cloudflare/python-cloudflare/archive/refs/tags/${PV}.tar.gz -> ${P}-gh.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""
RESTRICT="mirror" #overlay, not goign to be mirrored
DEPEND="dev-python/jsonlines[${PYTHON_USEDEP}]"
RDEPEND="( ${DEPEND}
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/future[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}] )"
BDEPEND=""
S="${WORKDIR}/python-${P}"
PROPERTIES="test_network" #actually sends a test request
RESTRICT="test"

distutils_enable_tests pytest
python_prepare_all() {
	sed -r -e "/packages *=/ s|\[[^]]*\]\+||" -i -- setup.py

	rm -r examples

	distutils-r1_python_prepare_all
}
python_test() {
epytest tests/test1.py
}
