EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1

DESCRIPTION="aiohttp-powered httpx client"

HOMEPAGE="https://github.com/karpetrosyan/httpx-aiohttp/"
SRC_URI="https://github.com/karpetrosyan/httpx-aiohttp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/aiohttp[${PYTHON_USEDEP}]
	"
PROPERTIES="test_network"
EPYTEST_PLUGINS=( pytest-asyncio anyio )
distutils_enable_tests pytest
python_test() {
	# upstream also runs tests from a full submodule of httpx...
	epytest tests/local
}
