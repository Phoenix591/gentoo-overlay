# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit python-r1 cmake

DESCRIPTION="Sasl plugin to facilitate oauth2, tested with postfix"
HOMEPAGE="https://github.com/tarickb/sasl-xoauth2"
if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/tarickb/sasl-xoauth2"
else
	KEYWORDS="~amd64 ~arm64"
	SRC_URI="https://github.com/tarickb/sasl-xoauth2/archive/refs/tags/release-${PV}.tar.gz -> ${P}.tar.gz"
fi

S="${WORKDIR}/${PN}-release-${PV}"
LICENSE="Apache-2.0"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"
RESTRICT+=" mirror" #overlay, no real issue
PATCHES="${FILESDIR}/fix-for-curl-8.17.patch"
BDEPEND="
	virtual/pkgconfig
	virtual/pandoc
"
DEPEND="
	net-misc/curl:=
	dev-libs/jsoncpp:=
	dev-libs/cyrus-sasl:2
"
RDEPEND="${DEPEND}
	dev-python/msal[${PYTHON_USEDEP}]
	${PYTHON_DEPS}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
src_prepare() {
	sed -i -e s/-Werror// src/CMakeLists.txt || die
	sed -i s/3.31.6/4.1.0/ CMakeLists.txt || die
	cmake_src_prepare
}
src_configure() {
	local mycmakeargs=(
		-DEnableTests=$(usex test)
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
	)
	cmake_src_configure
}
src_install() {
	cmake_src_install
	mv "${ED}/usr/bin/sasl-xoauth2-tool" "${T}/"
	python_foreach_impl python_doscript "${T}/sasl-xoauth2-tool"
	keepdir /etc/tokens
}

pkg_postinst() {
	einfo "See ${EPREFIX}/usr/share/doc/${PF}/README.md.bz2 for detailed setup guide"
}
