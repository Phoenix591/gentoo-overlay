# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="This utility tracks modules loaded by the kernel, for localmodconfig"

HOMEPAGE="https://github.com/graysky2/modprobed-db"

SRC_URI="https://github.com/graysky2/modprobed-db/archive/v${PV}.tar.gz -> ${P}.tar.gz"

#S="${WORKDIR}/${P}"

LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64"

#IUSE="+doc"

RDEPEND="app-shells/bash"

src_install() {
	emake DESTDIR="${D}" install-bin
	doman doc/${PN}.8
}
