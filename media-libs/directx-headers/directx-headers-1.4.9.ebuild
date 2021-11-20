# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MYPN="DirectX-Headers"
inherit meson
if [ "${PV}" == 9999 ]; then
	EGIT_REPO_URI="https://github.com/microsoft/DirectX-Headers"
	inherit git-r3
else
	KEYWORDS="-* ~amd64 ~arm64" # only archs that windows 11 supports, since these are used for WSLg
	SRC_URI="https://github.com/microsoft/DirectX-Headers/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${MYPN}-${PV}"
fi
DESCRIPTION="DirectX headers for WSL 2 graphics"

HOMEPAGE="https://github.com/microsoft/DirectX-Headers"

LICENSE="MIT"

SLOT="0"

IUSE=""

pkg_pretend() {
	if ! grep 'LDPATH="/usr/lib/wsl/lib"' -qr "${ROOT}/etc/env.d"; then
		eerror "Please create a file in /etc/env.d/ containing the following:"
		eerror 'LDPATH="/usr/lib/wsl/lib"'
		eerror 'LIBPATH="/usr/lib/wsl/lib"'
		einfo 'so that the libraries wsl mounts at that unusual location are found correctly'
		die
	fi
}

src_configure() {

#local emesonargs=(
#	-Dbuild-test=false #uncomment to ignore WSLg check ( needs the env file mentioned in pkg_pretend so that it can find it )
#	)
	meson_src_configure
}
