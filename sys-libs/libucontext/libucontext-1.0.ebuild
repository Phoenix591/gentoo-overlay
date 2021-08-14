# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="libucontext is a library which provides the ucontext.h C API"

HOMEPAGE="https://github.com/kaniini/libucontext"

SRC_URI="https://github.com/kaniini/${PN}/archive/${P}.tar.gz"

S="${WORKDIR}/${PN}-${P}"

#TODO, license is ISC minus a few terms in the bottom
LICENSE="ISC"

SLOT="0"

KEYWORDS="~arm64"
#IUSE=""

#In overlay so don't bother gentoo's mirros
RESTRICT="mirror"

#depends purely on libc

BDEPEND="
dev-util/meson
dev-util/ninja
"

src_prepare() {
	# tries to include its header from its installed location during compilation
	sed -i s#libucontext/bits.h#bits.h# "${S}/include/libucontext/libucontext.h" || die
	default_src_prepare
}
src_configure() {
	local emesonargs=(
	#normally the symbols this libary exports are defined by glibc so need a prefix if for some reason
		# this is installed on a glibc system. uclibc-ng has them defined if UCLIBC_SUSV3_LEGACY is set so
		# I'll only set unprefixed for musl
	-D export_unprefixed=$(usex elibc_musl true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	#change include back to final installation location
	sed -i s#bits.h#libucontext/bits.h# "${D}/usr/include/libucontext/libucontext.h" || die
}
