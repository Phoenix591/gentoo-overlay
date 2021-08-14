# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..9} )

inherit distutils-r1

DESCRIPTION="Voice command core"
HOMEPAGE="https://github.com/MycroftAI/mycroft-core"
#SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS=""
PYDEPEND="
>=dev-python/six-1.13.0[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]
dev-python/pyaudio[${PYTHON_USEDEP}]
www-servers/tornado[${PYTHON_USEDEP}]
dev-python/websocket-client[${PYTHON_USEDEP}]
dev-python/pyserial[${PYTHON_USEDEP}]




DEPEND="dev-vcs/git
	sys-devel/libtool
	dev-libs/libffi
	dev-libs/openssl
	dev-lang/swig
	sys-devel/autoconf
	sys-devel/automake
	dev-libs/glib
	>=media-libs/portaudio-19.00.00
	media-sound/mpg123
	app-misc/screen
	media-libs/flac
	net-misc/curl
	dev-libs/icu
	dev-util/pkgconfig
	media-libs/libjpeg-turbo
	sci-mathematics/fann
	app-misc/jq
	media-sound/pulseaudio
	media-libs/alsa-lib"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"
#	test? (
#		dev-python/cryptography[${PYTHON_USEDEP}]
#		>=dev-python/httpretty-0.9.6[${PYTHON_USEDEP}]
#	)"

distutils_enable_tests pytest
