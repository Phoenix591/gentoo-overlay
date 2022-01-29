# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Accurately separate the TLD from the registered domain and subdomains of a URL."
HOMEPAGE="https://pypi.org/project/tldextract/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

BDEPEND="
	test? ( dev-python/pytest-mock[${PYTHON_USEDEP}]
		dev-python/responses[${PYTHON_USEDEP}] )"
DEPEND="
"
RDEPEND="
	dev-python/idna[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/requests-file[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.0.8[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
distutils_enable_tests pytest
