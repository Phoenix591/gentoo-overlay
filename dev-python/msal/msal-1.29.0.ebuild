# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Microsoft Authentication Library for Python allows integration with Microsoft"
HOMEPAGE="https://github.com/AzureAD/microsoft-authentication-library-for-python"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
SRC_URI="https://github.com/AzureAD/microsoft-authentication-library-for-python/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
MYPN="microsoft-authentication-library-for-python"
S="${WORKDIR}/${MYPN}-${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
#RESTRICT="mirror" #mirror restricted only because overlay
PROPERTIES="test_network"
distutils_enable_tests pytest
RDEPEND="
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pyjwt[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
BDEPEND="	test? (
			dev-python/python-dotenv[${PYTHON_USEDEP}]
		)
"
python_test() {
	local EPYTEST_IGNORE=(
		#needs unpackaged perf-baseline module
		tests/test_benchmark.py
	)
	epytest
}
