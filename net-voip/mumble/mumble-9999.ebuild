# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg multilib

DESCRIPTION="Mumble is an open source, low-latency, high quality voice chat software"
HOMEPAGE="https://wiki.mumble.info"
EGIT_REPO_URI="https://github.com/mumble-voip/mumble.git"
#speex and opus submodules readded only until license autogen fixed to use system/disable
#EGIT_SUBMODULES=( '*' -3rdparty/mach-override-src -3rdparty/minhook  )

if [[ "${PV}" == 9999 ]] ; then
	inherit git-r3
#	EGIT_SUBMODULES=( '-*' celt-0.7.0-src celt-0.11.0-src themes/Mumble 3rdparty/rnnoise-src )
elif [[ "$(ver_cut 3)" == 9999 ]] ; then
	EGIT_BRANCH="$(ver_cut 1-2).x"
	inherit git-r3
else
	if [[ "${PV}" == *_pre* ]] ; then
		SRC_URI="https://dev.gentoo.org/~polynomial-c/dist/${P}.tar.xz"
	else
		MY_PV="${PV/_/-}"
		MY_P="${PN}-${MY_PV}"
		SRC_URI="https://dl.mumble.info/stable/${MY_P}.tar.gz"
		S="${WORKDIR}/${P}.src"
	fi
		KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD MIT"
SLOT="0"
IUSE="+alsa debug g15 jack portaudio pulseaudio +multilib nls +rnnoise speech system-ms-gsl +system-rnnoise +system-json test zeroconf"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5[ssl]
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	>=dev-libs/protobuf-2.2.0:=
	>=dev-libs/poco-1.9.0:=[xml,zip]
	>=media-libs/libsndfile-1.0.20[-minimal]
	>=media-libs/opus-1.3.1
	>=media-libs/speex-1.2.0
	media-libs/speexdsp
	sys-apps/lsb-release
	x11-libs/libX11
	x11-libs/libXi
	alsa? ( media-libs/alsa-lib )
	g15? ( app-misc/g15daemon )
	jack? ( virtual/jack )
	>=dev-libs/openssl-1.0.0b:0=
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	speech? ( >=app-accessibility/speech-dispatcher-0.8.0 )
	system-ms-gsl? ( dev-cpp/ms-gsl )
	system-rnnoise? ( >=media-libs/rnnoise-0.4.1_p20210122 )
	system-json? ( >=dev-cpp/nlohmann_json-3.9.1 )
	zeroconf? ( net-dns/avahi[mdnsresponder-compat] )
"

DEPEND="${RDEPEND}
	>=dev-libs/boost-1.41.0
	x11-base/xorg-proto
"

BDEPEND="
	dev-qt/linguist-tools:5
	test? ( dev-qt/qttest:5 )
	virtual/pkgconfig
"

#src_unpack() {
#	if [ "${_GIT_R3}" -eq 1 ]; then
#		if use system-ms-gsl; then
#			EGIT_SUBMODULES+=(  -3rdparty/gsl )
#		fi
#		if use system-rnnoise; then
#			EGIT_SUBMODULES+=(  -3rdparty/rnnoise-src )
#		fi
#		if use system-json; then
#			EGIT_SUBMODULES+=(  -3rdparty/nlohmann_json )
#		fi
#		if use elibc_mingw; then
#			EGIT_SUBMODULES+=( 3rdparty/minhook )
#		fi
#		git-r3_src_unpack
#	fi
#	default_src_unpack
#}

src_prepare() {
	#Respect CFLAGS, don't auto-enable
	sed -i '/lto/d' CMakeLists.txt src/CMakeLists.txt src/mumble/CMakeLists.txt
	# required because of xdg.eclass also providing src_prepare
	cmake_src_prepare
}

src_configure() {

	local mycmakeargs=(
		-Dalsa="$(usex alsa)"
		-Dtests="$(usex test)"
#		-Dbundled-celt="ON" will be removed soon
		-Dbundled-opus="OFF"
		-Dg15="$(usex g15)"
		-Djackaudio="$(usex jack)"
		-Doverlay="ON"
		-Doverlay-xcompile="$(usex multilib)"
		-Dportaudio="$(usex portaudio)"
		-Dpulseaudio="$(usex pulseaudio)"
		-Drnnoise="$(usex rnnoise)"
		-Dserver="OFF"
		-Dspeechd="$(usex speech)"
		-Dbundled-gsl=$(usex !system-ms-gsl)
		-Dbundled-rnnoise=$(usex !system-rnnoise)
		-Dbundled-json=$(usex !system-json)
		-Dtranslations="$(usex nls)"
		-Dupdate="OFF"
		-Dzeroconf="$(usex zeroconf)"
		-Dwarnings-as-errors="OFF"
		-DMUMBLE_INSTALL_MANDIR:PATH="share/man1"
		-DMUMBLE_INSTALL_DOCDIR:PATH="share/doc/${P}"
	)
	if [ -z "${_GIT_R3}" ]; then
		mycmakeargs+=( -DBUILD_NUMBER=$(ver_cut 3) )
	fi
	cmake_src_configure
}

src_test() {
	local myctestargs+=(-Donline-tests="OFF")
	cmake_src_test
}
src_install() {
	cmake_src_install

	if use amd64 && use multilib; then
		# The 32bit overlay library gets automatically built and installed on x86_64 platforms.
		# Install it into the correct 32bit lib dir.
		local libdir_64="/usr/$(get_libdir)/mumble"
		local libdir_32="/usr/$(get_abi_LIBDIR x86)/mumble"
		dodir ${libdir_32}
		mv "${ED}"/${libdir_64}/libmumbleoverlay.x86.so* \
			"${ED}"/${libdir_32}/ || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	echo
	elog "Visit https://wiki.mumble.info/ for futher configuration instructions."
	elog "Run 'mumble-overlay <program>' to start the OpenGL overlay (after starting mumble)."
	echo
}
