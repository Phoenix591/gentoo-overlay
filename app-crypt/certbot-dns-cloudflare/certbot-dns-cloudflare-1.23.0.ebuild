# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=(python3_{8..10})
DISTUTILS_USE_PEP517="setuptools"
BASEP=certbot
if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://github.com/certbot/certbot.git"
	inherit git-r3
	S=${WORKDIR}/${P}/${PN}
else
	SRC_URI="https://github.com/${BASEP}/${BASEP}/archive/v${PV}.tar.gz -> ${BASEP}-${PV}.tar.gz"
#	SRC_URI="https://github.com/certbot/certbot/archive/v${PV}.tar.gz -> ${BASEP}-${PV}.tar.gz"
	KEYWORDS="~amd64"
	S=${WORKDIR}/${BASEP}-${PV}/${PN}
fi
inherit distutils-r1

DESCRIPTION="Cloudflare DNS Authenticator plugin for Certbot (Let's Encrypt Client)"
HOMEPAGE="https://github.com/certbot/certbot https://letsencrypt.org/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

CDEPEND=">=dev-python/setuptools-1.0[${PYTHON_USEDEP}]"
RDEPEND="${CDEPEND}
	=app-crypt/certbot-${PV%.*}*[${PYTHON_USEDEP}]
	=app-crypt/acme-${PV%.*}*[${PYTHON_USEDEP}]
	dev-python/mock[${PYTHON_USEDEP}]
	dev-python/zope-interface[${PYTHON_USEDEP}]
	dev-python/dns-lexicon[${PYTHON_USEDEP}]
	dev-python/cloudflare[${PYTHON_USEDEP}]"
DEPEND="${CDEPEND}"
distutils_enable_tests pytest
