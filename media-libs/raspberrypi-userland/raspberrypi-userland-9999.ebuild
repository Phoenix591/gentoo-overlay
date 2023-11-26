# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake flag-o-matic udev

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN/-//}.git"
	SRC_URI=""
else
	# We base our versioning on  Raspbian
	# Go to https://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-userland/
	# Example:
	# * libraspberrypi-bin-dbgsym_2+git20201022~151804+e432bc3-1_arm64.deb
	# * "e432bc3" is the first 7 hex digits of the commit hash.
	# * Go to https://github.com/raspberrypi/userland/commits/master and find the full hash
	GIT_COMMIT="e432bc3400401064e2d8affa5d1454aac2cf4a00"
	SRC_URI="https://github.com/raspberrypi/userland/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~arm ~arm64"
	S="${WORKDIR}/userland-${GIT_COMMIT}"
fi

DESCRIPTION="Raspberry Pi userspace tools and libraries"
HOMEPAGE="https://github.com/raspberrypi/userland"

# can end up in a loop with libcec detecting the old .so but failing to build with the headers gone
RESTRICT="preserve-libs"

LICENSE="BSD"
SLOT="0"

DEPEND=""
RDEPEND="acct-group/video
	!media-libs/raspberrypi-userland-bin
	!sys-apps/dtc"

PATCHES=(
	# Install in $(get_libdir)
	# See https://github.com/raspberrypi/userland/pull/650
	"${FILESDIR}/${PN}-libdir.patch"
	# Don't install includes that collide.
	"${FILESDIR}/${PN}-include.patch"
	# See https://github.com/raspberrypi/userland/pull/655
#	"${FILESDIR}/${PN}-libfdt-static.patch"
	# See https://github.com/raspberrypi/userland/pull/659
	"${FILESDIR}/${PN}-pkgconf-arm64.patch"
)

pkg_pretend() {

	if ! ( use arm || use arm64 || [ -n "${I_KNOW_THIS_IS_FOR_THE_PI}" ]); then
		eerror "If you are trying to cross-compile things arn't set right and its trying to build for your host"
		die "${PN} is for the Raspberry pi: arm/arm64 only"
	fi
	if [ -n "${I_KNOW_THIS_IS_FOR_THE_PI}" ]; then
		ewarn "This is for the arm/arm64 pi only, if you set this on something not arm and it breaks you get to keep the pieces"
		ewarn "Wrappers such as aarch64-unknown-linux-gnu-emerge set things so that this isn't needed and should sucessfully cross compile this"
	fi
}

src_prepare() {
	cmake_src_prepare
	sed -i \
		-e 's:DESTINATION ${VMCS_INSTALL_PREFIX}/src:DESTINATION ${VMCS_INSTALL_PREFIX}/'"share/doc/${PF}:" \
		"${S}/makefiles/cmake/vmcs.cmake" || die "Failed sedding makefiles/cmake/vmcs.cmake"
	sed -i \
		-e 's:^install(TARGETS EGL GLESv2 OpenVG WFC:install(TARGETS:' \
		-e '/^install(TARGETS EGL_static GLESv2_static/d' \
		"${S}/interface/khronos/CMakeLists.txt" || die "Failed sedding interface/khronos/CMakeLists.txt"

	sed -i \
		-e 's:DESTINATION man/:DESTINATION share/man/:' \
		"${S}"/host_applications/linux/apps/*/CMakeLists.txt || die "Failed fixing man page install location"
}

src_configure() {
	append-ldflags $(no-as-needed)

	mycmakeargs=(
		-DVMCS_INSTALL_PREFIX="${EPREFIX}/usr"
		-DARM64=$(usex arm64)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	dolib.so "${WORKDIR}/${P}/build/lib/libfdt.so"
	udev_dorules "${FILESDIR}/92-local-vchiq-permissions.rules"
}
pkg_postinst() {
	udev_reload
	ewarn "Upstream has depreciated this package. Its useful commands have been split into rpi-utils"
}
pkg_postrm() {
	udev_reload
}
