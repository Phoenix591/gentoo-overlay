# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

DESCRIPTION="GOverlay is an opensource project that aims to create a Graphical UI to help manage Linux overlays."
HOMEPAGE="https://github.com/benjamimgois/goverlay"
if [[ ${PV} = "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/benjamimgois/goverlay.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/benjamimgois/goverlay/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="opengl vulkan"

DEPEND="
	opengl? (
		x11-apps/mesa-progs
	)
	vulkan? (
		dev-util/vulkan-tools
	)
"

RDEPEND="${DEPEND}"

BDEPEND="
	>=dev-lang/lazarus-2.0.6
	dev-libs/qt5pas
"


src_compile() {

	lazbuild \
		--lazarusdir=/usr/share/lazarus \
		--primary-config-path="${T}/lazarus" \
		--build-all \
		"${PN}.lpi"
}

src_install() {
	dobin "${PN}"
	domenu "${S}/data/io.github.benjamimgois.${PN}.desktop"
	insinto "/usr/share/metainfo"
	doins "${S}/data/io.github.benjamimgois.${PN}.metainfo.xml"

	for icon_size in 128 256 512; do
		doicon --size ${icon_size} "${S}/data/icons/${icon_size}x${icon_size}/${PN}.png"
	done
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	einfo ""
	einfo "Goverlay is a GUI program for configuring MangoHUD, and vkBasalt."
	einfo ""
	einfo "MangoHUD can be installed via the pkg <games-util/mangohud>."
	einfo "vkBasalt can be installed via the pkg <games-util/vkbasalt>."
	einfo ""
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
