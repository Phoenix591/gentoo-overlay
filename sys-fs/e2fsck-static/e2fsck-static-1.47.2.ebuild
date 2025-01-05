# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic systemd toolchain-funcs udev multilib-minimal
MYPN="e2fsprogs"
MYP="${MYPN}-${PV}"
DESCRIPTION="Standard EXT2/EXT3/EXT4 filesystem utilities"
HOMEPAGE="https://e2fsprogs.sourceforge.net/"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${PV}/${MYP}.tar.xz"
S="${WORKDIR}/${MYP}"
LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="lto nls +threads"

RDEPEND="nls? ( virtual/libintl )
	>=sys-apps/util-linux-2.16"
DEPEND="${RDEPEND}"

#e2fsprogs has odd issues with bundling its internal libraries or not, depending on the full e2fsprogs
#to ensure the libraries are  consistent
BDEPEND="virtual/pkgconfig
	sys-apps/texinfo
	~sys-fs/e2fsprogs-${PV}
	nls? ( sys-devel/gettext )
	sys-apps/util-linux[static-libs]"

PATCHES=(
	"${FILESDIR}"/${MYPN}-1.42.13-fix-build-cflags.patch #516854
	"${FILESDIR}"/no-profile.patch
	# Upstream patches (can usually removed with next version bump)
)

pkg_setup() {
		MULTILIB_WRAPPED_HEADERS=(
			/usr/include/ext2fs/ext2_types.h
		)
}

src_prepare() {
	default

	cp doc/RelNotes/v${PV}.txt ChangeLog || die "Failed to copy Release Notes"

	# Get rid of doc -- we don't use them. This also prevents a sandbox
	# violation due to mktexfmt invocation
	rm -r doc || die "Failed to remove doc dir"

	# prevent included intl cruft from building #81096
	sed -i -r \
		-e 's:@LIBINTL@:@LTLIBINTL@:' \
		MCONFIG.in || die 'intl cruft'
}

multilib_src_configure() {
	# Keep the package from doing silly things #261411
	export VARTEXFONTS="${T}/fonts"

	# needs open64() prototypes and friends
	append-cppflags -D_GNU_SOURCE

	local myeconfargs=(
		--with-root-prefix="${EPREFIX}"
		--with-systemd-unit-dir="$(systemd_get_systemunitdir)"
		--with-udev-rules-dir="${EPREFIX}$(get_udevdir)/rules.d"
		--enable-symlink-install
		--enable-elf-shlibs
		$(tc-has-tls || echo --disable-tls)
		$(use_enable nls)
		--disable-fsck
		--disable-uuidd
		--disable-profile
		$(use_enable lto)
		$(use_with threads pthread)
	)

	# we use blkid/uuid from util-linux now
#	if use kernel_linux ; then
		export ac_cv_lib_{uuid_uuid_generate,blkid_blkid_get_cache}=yes
		myeconfargs+=( --disable-lib{blkid,uuid} )
#	fi

	ac_cv_path_LDCONFIG=: \
		ECONF_SOURCE="${S}" \
		CC="$(tc-getCC)" \
		BUILD_CC="$(tc-getBUILD_CC)" \
		BUILD_LD="$(tc-getBUILD_LD)" \
		econf "${myeconfargs[@]}"

	if grep -qs 'USE_INCLUDED_LIBINTL.*yes' config.{log,status} ; then
		eerror "INTL sanity check failed, aborting build."
		eerror "Please post your ${S}/config.log file as an"
		eerror "attachment to https://bugs.gentoo.org/show_bug.cgi?id=81096"
		die "Preventing included intl cruft from building"
	fi
}

multilib_src_compile() {
	emake V=1 static-progs

}

multilib_src_install() {
	into /
	dosbin e2fsck/e2fsck.static
}
