# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Searches git for secrets"

HOMEPAGE="https://github.com/trufflesecurity/trufflehog"

# Point to any required sources; these will be automatically downloaded by
# Portage.
SRC_URI="mirror+https://github.com/trufflesecurity/trufflehog/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${P}-vendor.tar.xz"

#Generate vendor tarball
#$go mod vendor
#$ $cd ..
#$ $tar --create --auto-compress --file foo-1-vendor.tar.xz foo-1/vendor

# Source directory; the dir where the sources can be found (automatically
# unpacked) inside ${WORKDIR}.  The default value for S is ${WORKDIR}/${P}
# If you don't need to change it, leave the S= line out of the ebuild
# to keep it tidy.
#S="${WORKDIR}/${P}"

LICENSE="AGPL-3"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE=""

RESTRICT="fetch"

RDEPEND="dev-vcs/git"

# Build-time dependencies that need to be binary compatible with the system
# being built (CHOST). These include libraries that we link against.
# The below is valid if the same run-time depends are required to compile.
#DEPEND="${RDEPEND}"

# Build-time dependencies that are executed during the emerge process, and
# only need to be present in the native build system (CBUILD). Example:
#BDEPEND="virtual/pkgconfig"

pkg_nofetch(){
	einfo "Due to the pending removal of EGO_SUM, please download the vendor file from"
	einfo "https://drive.google.com/file/d/1_zQWS0FYg9g9I9J74PZMnRr0ohGhx7Hb/view"
	einfo "Place it in your distfiles directory"
	einfo "If theres some other magic more easily fetchable free storage solution you can suggest"
	einfo "Please open an issue https://github.com/Phoenix591/gentoo-overlay/issues"
}

src_compile(){
	ego build
}

src_install(){
	dobin trufflehog
	dodoc README.md
}
