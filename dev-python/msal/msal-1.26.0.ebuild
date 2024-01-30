# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Microsoft Authentication Library for Python allows integration with the Microsoft identity platform"
HOMEPAGE="https://github.com/AzureAD/microsoft-authentication-library-for-python"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
SRC_URI="https://github.com/AzureAD/microsoft-authentication-library-for-python/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
MYPN="microsoft-authentication-library-for-python"
S="${WORKDIR}/${MYPN}-${PV}"
#DEPEND="dev-python/jsonlines[${PYTHON_USEDEP}]"
#RDEPEND="( ${DEPEND}
#	dev-python/requests[${PYTHON_USEDEP}]
#	dev-python/pyyaml[${PYTHON_USEDEP}] )"
#S="${WORKDIR}/python-${P}"
RESTRICT="test mirror" #mirror restricted only becausw overlay
#PROPERTIES="test_network" # passes all but a test about the max cryptography version not sure how to fix right this second
distutils_enable_tests unittest
RDEPEND="
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pyjwt[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
BDEPEND="	test? (	
		 	dev-python/python-dotenv[${PYTHON_USEDEP}]
		)
"
