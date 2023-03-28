# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Searches git for secrets"

HOMEPAGE="https://github.com/trufflesecurity/trufflehog"

# Point to any required sources; these will be automatically downloaded by
# Portage.
SRC_URI="https://github.com/trufflesecurity/trufflehog/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://drive.google.com/uc?export=download&id=1MAphTZHlaVogl-WnjCxqwN6BKVrXHPEk -> ${P}-vendor.tar.xz"

#Generate vendor tarball
#$go mod vendor
#$ $cd ..
#$ $tar --create --auto-compress --file foo-1-vendor.tar.xz foo-1/vendor

LICENSE="AGPL-3"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE=""

#RESTRICT="fetch"

RDEPEND="dev-vcs/git"

#DEPEND="${RDEPEND}"

#BDEPEND="virtual/pkgconfig"

#pkg_nofetch(){
#	einfo "Due to the pending removal of EGO_SUM, please download the vendor file from"
#	einfo "https://drive.google.com/file/d/1_zQWS0FYg9g9I9J74PZMnRr0ohGhx7Hb/view"
#	einfo "Place it in your distfiles directory"
#	einfo "If theres some other magic more easily fetchable free storage solution you can suggest"
#	einfo "Please open an issue https://github.com/Phoenix591/gentoo-overlay/issues"
#}

src_compile(){
	ego build
}

src_install(){
	dobin trufflehog
	dodoc README.md
}
