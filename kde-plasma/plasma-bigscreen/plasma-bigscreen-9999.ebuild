# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ECM_HANDBOOK="forceoptional"
ECM_TEST="forceoptional"
KFMIN=5.74.0
PVCUT=$(ver_cut 1-3)
QTMIN=5.15.1
VIRTUALX_REQUIRED="test"
inherit ecm kde.org

DESCRIPTION="KDE Plasma Big Screen Launcher"

LICENSE="GPL-2"
SLOT="5"
if [ "${PV}" == "9999" ]; then
	EGIT_REPO_URI="https://invent.kde.org/plasma/plasma-bigscreen"
	KEYWORDS=""
	inherit git-r3

else
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
fi

IUSE="mycroft"


BDEPEND="virtual/pkgconfig"
COMMON_DEPEND="
	mycroft? ( dev-python/mycroft-core )
	kde-plasma/plasma-nano
	>=dev-libs/wayland-1.15
	dev-libs/icu:=
	dev-libs/libffi:=
	>=dev-qt/qtmultimedia-${QTMIN}
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtnetwork-${QTMIN}:5
        >=dev-qt/qtquickcontrols-${QTMIN}:5[widgets]
        >=dev-qt/qtquickcontrols2-${QTMIN}:5
	>=dev-qt/qtxml-${QTMIN}:5
	>=kde-frameworks/kactivities-${KFMIN}:5
	>=kde-frameworks/kactivities-stats-${KFMIN}:5
	>=kde-frameworks/kcmutils-${KFMIN}:5
	>=kde-frameworks/kdeclarative-${KFMIN}:5
	>=kde-frameworks/kio-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kirigami-${KFMIN}:5
	>=kde-frameworks/knotifications-${KFMIN}:5
	>=kde-frameworks/kwayland-${KFMIN}:5
	>=kde-frameworks/kwindowsystem-${KFMIN}:5
	>=kde-frameworks/plasma-${KFMIN}:5
	>=kde-plasma/libkworkspace-5.21:5
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
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
