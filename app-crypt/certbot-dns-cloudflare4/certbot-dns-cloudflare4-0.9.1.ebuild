# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=(python3_{11..13})
# certbot ready for 3.14, but not cloudflare
DISTUTILS_USE_PEP517=setuptools

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://github.com/Phoenix591/certbot-dns-cloudflare4.git"
	inherit git-r3
#	S=${WORKDIR}/${P}/${PN}
else
	SRC_URI="https://github.com/Phoenix591/${PN}/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64"
#	S=${WORKDIR}/certbot-${PV}/${PN}
fi

inherit distutils-r1

DESCRIPTION="Port of Cloudflare DNS Authenticator plugin for Certbot to Cloudflare4"
HOMEPAGE="https://github.com/Phoenix591/certbot-dns-cloudflare4"

LICENSE="Apache-2.0"
SLOT="0"

RDEPEND="${CDEPEND}
	>=app-crypt/certbot-5.1.0[${PYTHON_USEDEP}]
	>=dev-python/cloudflare-4[${PYTHON_USEDEP}]"
#BDEPEND="test? ( ${RDEPEND} )"
distutils_enable_sphinx docs dev-python/sphinx-rtd-theme
