# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Find credentials all over the place"

HOMEPAGE="https://github.com/trufflesecurity/trufflehog"

SRC_URI="https://github.com/trufflesecurity/trufflehog/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://drive.google.com/uc?export=download&id=1MAphTZHlaVogl-WnjCxqwN6BKVrXHPEk -> ${P}-vendor.tar.xz"

#Generate vendor tarball
#$go mod vendor
#$ cd ..
#$ tar --create --auto-compress --file foo-1-vendor.tar.xz foo-1/vendor
# generate direct download link for gdrive: https://sites.google.com/site/gdocs2direct/
# Have a good hosting suggestion for the vendor tarball?
# Let me know: https://github.com/Phoenix591/gentoo-overlay/issues
LICENSE="AGPL-3"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE=""

src_compile(){
	ego build
}

src_install(){
	dobin trufflehog
	dodoc README.md
}
