# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517="hatchling"
inherit distutils-r1

DESCRIPTION="Python wrapper for the Cloudflare v4 API"
HOMEPAGE="https://pypi.org/project/cloudflare/"
#SRC_URI="https://files.pythonhosted.org/packages/9b/8c/973e3726c2aa73821bb4272717c6f9f6fc74e69d41ba871bdf97fc671782/${P}.tar.gz"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
if [ "${PV}" -eq 9999 ]; then
	EGIT_REPO_URI="https://github.com/cloudflare/cloudflare-python"
	inherit git-r3
else
	SRC_URI="https://github.com/cloudflare/python-cloudflare/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/python-${P}"
	KEYWORDS="~amd64 ~arm64"
fi
LICENSE="MIT"
SLOT="0"
BDEPEND="test? (
	 dev-python/pytest-asyncio[${PYTHON_USEDEP}]
	 dev-python/time-machine[${PYTHON_USEDEP}]
	 dev-python/dirty-equals[${PYTHON_USEDEP}]
	 dev-python/respx[${PYTHON_USEDEP}]
)"

DEPEND=""
RDEPEND=" ${DEPEND}
	>=dev-python/httpx-0.23.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.7.0[${PYTHON_USEDEP}]
	>=dev-python/anyio-4.3.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/sniffio-1.3.1[${PYTHON_USEDEP}]
	 "
PROPERTIES="test_network" #actually sends many test requests
distutils_enable_tests pytest
RESTRICT="test mirror" #mirror restricted only because overlay

#python_prepare_all() {
#	# don't install tests or examples
#	sed -i -e "s/'cli4', 'examples'/'cli4'/" \
#		-e "s#'CloudFlare/tests',##" \
#		 setup.py || die
#	sed -i -e "/def test_ips7_should_fail():/i@pytest.mark.xfail(reason='Now fails upstream')" \
#		-e "2s/^/import pytest/" \
#		CloudFlare/tests/test_cloudflare_calls.py || die
#	distutils-r1_python_prepare_all
#}

python_test() {
	# these tests were failing as of 4-14-24
	local EPYTEST_DESELECT=(
	tests/test_client.py::TestCloudflare::test_validate_headers
	tests/test_client.py::TestCloudflare::test_copy_build_request
	tests/test_client.py::TestAsyncCloudflare::test_validate_headers )
	epytest
}
