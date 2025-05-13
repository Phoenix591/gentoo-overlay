# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

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

LICENSE="BSD rpi-eeprom"
SLOT="0"
IUSE="test tools"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	test? ( tools ) "

RESTRICT="mirror !test? ( test )" #overlay

BDEPEND="sys-apps/help2man"
DEPEND="${PYTHON_DEPS}"
RDEPEND="${PYTHON_DEPS}
	|| (
		>=media-libs/raspberrypi-userland-0_pre20201022
		>=media-libs/raspberrypi-userland-bin-1.20201022
		dev-embedded/rpi-utils
	)
	dev-libs/openssl
	tools? ( dev-python/pycryptodome[${PYTHON_USEDEP}] ) "

QA_PREBUILT="usr/sbin/vl805"
QA_PRESTRIPPED="usr/sbin/vl805"

src_prepare() {
	default
	# Adjust config file path
	sed -i \
		-e 's:/etc/default/rpi-eeprom-update:/etc/conf.d/rpi-eeprom-update:' \
		-e 's:IGNORE_DPKG_CHECKSUMS=${LOCAL_MODE}:IGNORE_DPKG_CHECKSUMS=1:' \
		rpi-eeprom-update || die "Failed sed on rpi-eeprom-update"
	# Script is set for pycryptodomex which uses the same code but
	# different namespace than pycrptodome
	use tools && sed -i -e \
		's/Cryptodome./Crypto./' tools/rpi-sign-bootcode rpi-eeprom-config tools/rpi-bootloader-key-convert \
			|| die "Failed sed for cryotodome"
}
python_install() {
	python_scriptinto /usr/sbin
	python_doscript rpi-eeprom-config
	use tools && python_doscript tools/{rpi-bootloader-key-convert,rpi-sign-bootcode}
}

src_install() {
	python_foreach_impl python_install

	use tools && dosbin tools/rpi-otp-private-key tools/vl805
	dosbin rpi-eeprom-update rpi-eeprom-digest
	keepdir /var/lib/raspberrypi/bootloader/backup

	for dev in 2711 2712; do
		for dir in default latest; do
			insinto /usr/lib/firmware/raspberrypi/bootloader-${dev}
			doins -r firmware-${dev}/${dir}
			TAR="/usr/lib/firmware/raspberrypi/bootloader-${dev}"
			dosym latest ${TAR}/beta
			dosym latest ${TAR}/stable
			dosym default ${TAR}/critical
		done
		newdoc firmware-${dev}/release-notes.md ${dev}-release-notes.md
	done
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
	elog 'FIRMWARE_RELEASE_STATUS="critical|stable" determines'
	elog 'which release track you get. "critical" is recommended and the default.'

	elog 'The updater script can optionally use sys-apps/flashrom[linux-spi] to flash updates'
}
src_test() {
	python_test() {
		cd "${S}/test"
		./test-rpi-eeprom-config
	}
	python_foreach_impl python_test
}
