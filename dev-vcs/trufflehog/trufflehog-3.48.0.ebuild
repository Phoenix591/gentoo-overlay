# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Find credentials all over the place"

HOMEPAGE="https://github.com/trufflesecurity/trufflehog"

SRC_URI="https://github.com/trufflesecurity/trufflehog/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Phoenix591/trufflehog/releases/download/${PV}/${P}-vendor.tar.xz"

#Generate vendor tarball
#$go mod vendor
#$ cd ..
#$ tar --create --auto-compress --file foo-1-vendor.tar.gz foo-1/vendor

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
