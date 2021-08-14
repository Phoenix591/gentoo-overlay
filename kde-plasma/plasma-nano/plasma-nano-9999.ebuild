# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ECM_HANDBOOK="forceoptional"
ECM_TEST="forceoptional"
KFMIN=5.74.0
PVCUT=$(ver_cut 1-3)
QTMIN=5.15.0
VIRTUALX_REQUIRED="test"
inherit ecm kde.org

DESCRIPTION="KDE Plasma Minimal shell package"

LICENSE="GPL-2"
SLOT="5"
if [ "${PV}" == "9999" ]; then
	EGIT_REPO_URI="https://invent.kde.org/plasma/plasma-nano"
	KEYWORDS=""
	inherit git-r3

else
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
fi

IUSE=""


BDEPEND="virtual/pkgconfig"
COMMON_DEPEND="
	>=dev-libs/wayland-1.15
	>=dev-qt/qtcore-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5=[jpeg]
	>=dev-qt/qtquickcontrols2-${QTMIN}
	>=dev-qt/qtquickcontrols-${QTMIN}
	>=dev-qt/qtxml-${QTMIN}:5
	>=kde-frameworks/kwayland-${KFMIN}:5
	>=kde-frameworks/kwindowsystem-${KFMIN}:5
	>=kde-frameworks/plasma-${KFMIN}:5
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
	app-text/iso-codes
	>=dev-qt/qdbus-${QTMIN}:5
	>=dev-qt/qtquickcontrols-${QTMIN}:5[widgets]
	>=dev-qt/qtquickcontrols2-${QTMIN}:5
"
PDEPEND="
"


RESTRICT+=" test"

src_prepare() {
	ecm_src_prepare

}

src_configure() {
#	local mycmakeargs=(
#		$(cmake_use_find_package appstream AppStreamQt)
#	)


	ecm_src_configure
}

src_install() {
	ecm_src_install

#	# default startup and shutdown scripts
#	insinto /etc/xdg/plasma-workspace/env
#	doins "${FILESDIR}"/10-agent-startup.sh
#
#	insinto /etc/xdg/plasma-workspace/shutdown
#	doins "${FILESDIR}"/10-agent-shutdown.sh
#	fperms +x /etc/xdg/plasma-workspace/shutdown/10-agent-shutdown.sh
}

pkg_postinst () {
	ecm_pkg_postinst

}
