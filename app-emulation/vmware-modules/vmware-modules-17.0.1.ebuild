# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit  flag-o-matic linux-info linux-mod  udev

DESCRIPTION="VMware kernel modules"
HOMEPAGE="https://github.com/mkubecek/vmware-host-modules"

SRC_URI=" workstation? ( https://github.com/mkubecek/vmware-host-modules/archive/refs/tags/w${PV}.tar.gz -> ${P}-workstation.tar.gz )
	 player? ( https://github.com/mkubecek/vmware-host-modules/archive/refs/tags/p${PV}.tar.gz -> ${P}-player.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+workstation player"
#REQUIRED_USE="^^ ( workstation player )"
RDEPEND="acct-group/vmware"
DEPEND=""
PDEPEND=""
RESTRICT="mirror"
S="${WORKDIR}/vmware-host-modules-${PV}"

src_unpack() {
	default
	mv "${WORKDIR}"/vmware-host-modules-?"${PV}" "${WORKDIR}/vmware-host-modules-${PV}" || die
}
pkg_setup() {
	CONFIG_CHECK="~HIGH_RES_TIMERS"
	if kernel_is -ge 5 5; then
		CONFIG_CHECK="${CONFIG_CHECK} X86_IOPL_IOPERM"
	fi
	if kernel_is -ge 2 6 37 && kernel_is -lt 2 6 39; then
		CONFIG_CHECK="${CONFIG_CHECK} BKL"
	fi
	CONFIG_CHECK="${CONFIG_CHECK} VMWARE_VMCI VMWARE_VMCI_VSOCKETS"

	linux-info_pkg_setup
	linux-mod_pkg_setup

	BUILD_PARAMS+='V=1 CFLAGS_MODULE="-Wno-error -Wno-error=strict-prototypes"'

	if linux_chkconfig_present CC_IS_CLANG; then
		ewarn "Warning: building ${PN} with a clang-built kernel is experimental"
		BUILD_PARAMS+=' CC=${CHOST}-clang'
		if linux_chkconfig_present LD_IS_LLD; then
			BUILD_PARAMS+=' LD=ld.lld'
			if linux_chkconfig_present LTO_CLANG_THIN; then
				# kernel enables cache by default leading to sandbox violations
				BUILD_PARAMS+=' ldflags-y=--thinlto-cache-dir= LDFLAGS_MODULE=--thinlto-cache-dir='
			fi
		fi
	fi
	BUILD_PARAMS+=" CC=$(get-KERNEL_CC)"
	VMWARE_MODULE_LIST="vmmon vmnet"

	VMWARE_MOD_DIR="${PN}-${PVR}"

	BUILD_TARGETS="auto-build KERNEL_DIR=${KERNEL_DIR} KBUILD_OUTPUT=${KV_OUT_DIR}"

	filter-flags -mfpmath=sse -mavx -mpclmul -maes
	append-cflags -mno-sse  # Found a problem similar to bug #492964
	append-cflags -Wno-error # Keeps pulling in Werror out of nowhere

	for mod in ${VMWARE_MODULE_LIST}; do
		MODULE_NAMES="${MODULE_NAMES} ${mod}(misc:${S}/${mod}-only)"
	done
}

src_prepare() {
	# decouple the kernel include dir from the running kernel version: https://github.com/stefantalpalaru/gentoo-overlay/issues/17
	sed -i \
		-e "s%HEADER_DIR = /lib/modules/\$(VM_UNAME)/build/include%HEADER_DIR = ${KERNEL_DIR}/include%" \
		-e "s%VM_UNAME = .*\$%VM_UNAME = ${KV_FULL}%" \
		*/Makefile || die "sed failed"

	sed -i -e 's/-Werror//' */Makefile* || die "Disabling Werror failed"
	# Allow user patches so they can support RC kernels and whatever else
	default
}

src_install() {
	linux-mod_src_install
	local udevrules="${T}/60-vmware.rules"
	cat > "${udevrules}" <<-EOF
		KERNEL=="vmci",  GROUP="vmware", MODE="660"
		KERNEL=="vmw_vmci",  GROUP="vmware", MODE="660"
		KERNEL=="vmmon", GROUP="vmware", MODE="660"
		KERNEL=="vsock", GROUP="vmware", MODE="660"
	EOF
	udev_dorules "${udevrules}"

	dodir /etc/modprobe.d/

	cat > "${D}"/etc/modprobe.d/vmware.conf <<-EOF
		# Support for vmware vmci in kernel module
		alias vmci	vmw_vmci
	EOF

	export installed_modprobe_conf=1
	dodir /etc/modprobe.d/
	cat >> "${D}"/etc/modprobe.d/vmware.conf <<-EOF
		# Support for vmware vsock in kernel module
		alias vsock	vmw_vsock_vmci_transport
	EOF

	export installed_modprobe_conf=1
}

pkg_postinst() {
	linux-mod_pkg_postinst
	ewarn "Don't forget to run '/etc/init.d/vmware restart' to use the new kernel modules."
}
