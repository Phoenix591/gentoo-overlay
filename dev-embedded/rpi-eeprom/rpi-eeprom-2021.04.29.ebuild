# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit python-r1 systemd

DESCRIPTION="Updater for Raspberry Pi 4 bootloader and the VL805 USB controller"
HOMEPAGE="https://github.com/raspberrypi/rpi-eeprom/"
if [ "${PV}" == 9999 ]; then
	EGIT_REPO_URI="https://github.com/raspberrypi/rpi-eeprom"
	inherit git-r3
else
	VL_VER="138a1"
	KEYWORDS="~arm ~arm64"
	SRC_URI="https://github.com/raspberrypi/${PN}/archive/refs/tags/v${PV}-${VL_VER}.tar.gz"
	S="${WORKDIR}/${P}-${VL_VER}/"
fi

SLOT="0"
LICENSE="BSD rpi-eeprom"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="mirror" #overlay

BDEPEND="sys-apps/help2man"
DEPEND="${PYTHON_DEPS}"
RDEPEND="${PYTHON_DEPS}
	|| (
		>=media-libs/raspberrypi-userland-0_pre20201022
		>=media-libs/raspberrypi-userland-bin-1.20201022
	)"

src_prepare() {
	default
	sed -i \
		-e 's:/etc/default/rpi-eeprom-update:/etc/conf.d/rpi-eeprom-update:' \
		rpi-eeprom-update || die "Failed sed on rpi-eeprom-update"
}

src_install() {
	python_scriptinto /usr/sbin
	python_foreach_impl python_newscript rpi-eeprom-config rpi-eeprom-config

	dosbin rpi-eeprom-update
	keepdir /var/lib/raspberrypi/bootloader/backup

	for dir in critical stable beta; do
		insinto /lib/firmware/raspberrypi/bootloader
		doins -r firmware/${dir}
	done

	dodoc firmware/release-notes.md

	help2man -N \
		--version-string="${PV}" --help-option="-h" \
		--name="Bootloader EEPROM configuration tool for the Raspberry Pi 4B" \
		--output=rpi-eeprom-config.1 ./rpi-eeprom-config || die "Failed to create manpage for rpi-eeprom-config"

	help2man -N \
		--version-string="${PV}" --help-option="-h" \
		--name="Checks whether the Raspberry Pi bootloader EEPROM is \
			up-to-date and updates the EEPROM" \
		 --output=rpi-eeprom-update.1 ./rpi-eeprom-update || die "Failed to create manpage for rpi-eeprom-update"

	doman rpi-eeprom-update.1 rpi-eeprom-config.1

	newconfd rpi-eeprom-update-default rpi-eeprom-update

#	pushd debian 1>/dev/null || die "Cannot change into directory debian"

	systemd_dounit "${FILESDIR}/rpi-eeprom-update.service"
#	newdoc changelog changelog.Debian

#	popd 1>/dev/null || die

	newinitd "${FILESDIR}/init.d_rpi-eeprom-update-1" "rpi-eeprom-update"
}

pkg_postinst() {
	elog 'To have rpi-eeprom-update run at each startup, enable and start either'
	elog '/etc/init.d/rpi-eeprom-update (for openrc users)'
	elog 'or'
	elog 'rpi-eeprom-update.service (for systemd users)'
	elog '/etc/conf.d/rpi-eeprom-update contains the configuration.'
	elog 'FIRMWARE_RELEASE_STATUS="critical|stable|beta" determines'
	elog 'which release track you get. "critical" is recommended and the default.'
}
