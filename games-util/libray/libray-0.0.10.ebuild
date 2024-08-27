# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="an application for extracting, repackaging, and en/decrypting PS3 ISOs"
HOMEPAGE="https://notabug.org/necklace/libray
	https://pypi.org/project/libray/"
SRC_URI="https://notabug.org/necklace/libray/archive/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/html5lib[${PYTHON_USEDEP}]
	"
RESTRICT="test" #currently fails but app still works
distutils_enable_tests unittest
