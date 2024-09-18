# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Re dlz/mysql and threads, needs to be verified..
# MySQL uses thread local storage in its C api. Thus MySQL
# requires that each thread of an application execute a MySQL
# thread initialization to setup the thread local storage.
# This is impossible to do safely while staying within the DLZ
# driver API. This is a limitation caused by MySQL, and not the DLZ API.
# Because of this BIND MUST only run with a single thread when
# using the MySQL driver.

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit autotools toolchain-funcs systemd tmpfiles python-any-r1

MY_PV="${PV/_p/-P}"
MY_PV="${MY_PV/_rc/rc}"
MY_P="${PN}-${MY_PV}"

RRL_PV="${MY_PV}"

DESCRIPTION="Berkeley Internet Name Domain - Name Server"
HOMEPAGE="https://www.isc.org/bind/"

LICENSE="Apache-2.0 BSD BSD-2 GPL-2 HPND ISC MPL-2.0"
SLOT="0"
#KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
if [[ ${PV} == *"9999"* ]]; then
	if [ "$(ver_cut 3)" == "9999" ]; then
		EGIT_BRANCH="${PN}-$(ver_cut 1-2)"
	fi
	EGIT_REPO_URI="https://gitlab.isc.org/isc-projects/bind9.git"
	inherit git-r3
else
	SRC_URI="https://downloads.isc.org/isc/bind9/${PV}/${P}.tar.xz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi

# -berkdb by default re bug 602682
IUSE="dnstap doc fixed-rrset geoip geoip2 gssapi +jemalloc
json lmdb selinux static-libs systemd test xml +zlib"
# no PKCS11 currently as it requires OpenSSL to be patched, also see bug 409687

# Upstream dropped the old geoip library, but the BIND configuration for using
# GeoIP remained the same.

DEPEND="
	acct-group/named
	acct-user/named
	net-libs/nghttp2:=
	>=dev-libs/userspace-rcu-0.4.0:=
	dev-libs/openssl:=[-bindist(-)]
	>=sys-libs/libcap-2.1.0
	jemalloc? ( >=dev-libs/jemalloc-5.2.1:= )
	xml? ( dev-libs/libxml2 )
	geoip? ( dev-libs/libmaxminddb:= )
	geoip2? ( dev-libs/libmaxminddb:= )
	gssapi? ( virtual/krb5 )
	json? ( dev-libs/json-c:= )
	lmdb? ( dev-db/lmdb )
	zlib? ( sys-libs/zlib )
	systemd? ( sys-apps/systemd:= )
	dnstap? ( dev-libs/fstrm dev-libs/protobuf-c:= )
	>=dev-libs/libuv-1.40.0:=
"
#		net-analyzer/sslyze # optional test dep, available in pentoo overlay
BDEPEND=" test? (
		dev-util/cmocka
		dev-perl/Net-DNS
		dev-perl/IO-Socket-INET6
		net-libs/gnutls[tools]
		dev-libs/softhsm
		$(python_gen_any_dep '
			dev-python/dnspython[${PYTHON_USEDEP}]
			dev-python/pluggy[${PYTHON_USEDEP}]
			dev-python/pytest[${PYTHON_USEDEP}]')
		)
		"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-bind )
	sys-process/psmisc
	!net-dns/bind-tools"

python_check_deps() {
	python_has_version -b "dev-python/dnspython[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/pluggy[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/pytest[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
	true
}

PATCHES=(
	"${FILESDIR}/jemalloc-dlz.patch"
)

# bug 479092, requires networking
# bug 710840, cmocka fails LDFLAGS='-Wl,-O1'
# tests require network, and not JUST network, they require specific ip addresses
# mirror restriction just because overlay
RESTRICT="test mirror"

src_prepare() {
	default

	# should be installed by bind-tools. this wasnt actually disabling them anyway...
#	sed -i -r -e "s:(nsupdate|dig|delv) ::g" bin/Makefile.in || die

	# Disable tests for now, bug 406399
#	sed -i '/^SUBDIRS/s:tests::' bin/Makefile.in lib/Makefile.in || die

	# bug #220361
#	rm aclocal.m4 || die
#	rm -rf libtool.m4/ || die
	eautoreconf

}

src_configure() {
	local myeconfargs=(
		AR="$(type -P $(tc-getAR))"
		--prefix="${EPREFIX}"/usr
		--sysconfdir=/etc/bind
		--localstatedir=/var
		--enable-full-report
		--without-readline
		--with-openssl="${EPREFIX}"/usr
		--without-cmocka
#		$(use_enable dnsrps)
		$(use_enable dnstap)
		$(use_enable fixed-rrset)
		$(use_with gssapi)
		$(use_with jemalloc)
		$(use_with json json-c)
		$(use_with lmdb)
		$(use_with systemd libsystemd)
		$(use_with test cmocka)
		$(use_with xml libxml2)
		$(use_with zlib)
		"${@}"
	)
	# This is for users to start to migrate back to USE=geoip, rather than
	# USE=geoip2
	if use geoip ; then
		myeconfargs+=( $(use_with geoip maxminddb) --enable-geoip )
	elif use geoip2 ; then
		# Added 2020/09/30
		# Remove USE=geoip2 support after 2020/03/01
		ewarn "USE=geoip2 is deprecated; update your USE flags!"
		myeconfargs+=( $(use_with geoip2 maxminddb) --enable-geoip )
	else
		myeconfargs+=( --without-maxminddb --disable-geoip )
	fi

	# bug #158664
#	gcc-specs-ssp && replace-flags -O[23s] -O

	export BUILD_CC=$(tc-getBUILD_CC)
	econf "${myeconfargs[@]}"

	# bug #151839
	echo '#undef SO_BSDCOMPAT' >> config.h

}

src_compile() {
	default
	emake -C doc/man/ man $(usev doc)
}

src_install() {
	default
	# don't create /var/run
#	rmdir "${ED}"/var/run || die

	dodoc CHANGES README.md

	if use doc; then
		docinto misc
		dodoc -r doc/misc/

		# might a 'html' useflag make sense?
		docinto html
		dodoc -r doc/arm/
		docinto contrib
		dodoc contrib/scripts/nanny.pl

	fi

	insinto /etc/bind
	newins "${FILESDIR}"/named.conf-r9 named.conf

	# ftp://ftp.rs.internic.net/domain/named.cache:
	insinto /var/bind
	newins "${FILESDIR}"/named.cache-r4 named.cache

	insinto /var/bind/pri
	newins "${FILESDIR}"/localhost.zone-r3 localhost.zone

	newinitd "${FILESDIR}"/named.init-r14 named
	newconfd "${FILESDIR}"/named.confd-r7 named

	newenvd "${FILESDIR}"/10bind.env 10bind

	doman doc/man/*.{1,5,8}

	# reunifying bind with bind-tools, they share bind's internal libraries which are big
	# Let's get rid of those tools and their manpages since they're provided by bind-tools
#	rm -f "${ED}"/usr/share/man/man1/{dig,host,nslookup,delv,nsupdate}.1* || die
#	rm -f "${ED}"/usr/share/man/man8/nsupdate.8* || die
#	rm -f "${ED}"/usr/bin/{dig,host,nslookup,nsupdate,delv} || die
#	rm -f "${ED}"/usr/sbin/{dig,host,nslookup,nsupdate} || die
#	for tool in dsfromkey importkey keyfromlabel keygen \
#	revoke settime signzone verify; do
#		rm -f "${ED}"/usr/{,s}bin/dnssec-"${tool}" || die
#		rm -f "${ED}"/usr/share/man/man8/dnssec-"${tool}".8* || die
#	done

	# bug 405251, library archives aren't properly handled by --enable/disable-static
	if ! use static-libs; then
		find "${ED}" -type f -name '*.a' -delete || die
	fi

	# bug 405251
	find "${ED}" -type f -name '*.la' -delete || die

	# bug 450406
	dosym named.cache /var/bind/root.cache

	dosym ../../var/bind/pri /etc/bind/pri
	dosym ../../var/bind/sec /etc/bind/sec
	dosym ../../var/bind/dyn /etc/bind/dyn
	keepdir /var/bind/{pri,sec,dyn} /var/log/named

	fowners root:named /{etc,var}/bind /var/log/named /var/bind/{sec,pri,dyn}
	fowners root:named /var/bind/named.cache /var/bind/pri/localhost.zone /etc/bind/named.conf
	fperms 0640 /var/bind/named.cache /var/bind/pri/localhost.zone /etc/bind/named.conf
	fperms 0750 /etc/bind /var/bind/pri
	fperms 0770 /var/log/named /var/bind/{,sec,dyn}

	systemd_newunit "${FILESDIR}/named.service-r1" named.service
	dotmpfiles "${FILESDIR}"/named.conf
	exeinto /usr/libexec
	doexe "${FILESDIR}/generate-rndc-key.sh"
}

pkg_postinst() {
	tmpfiles_process named.conf || eerror "Failed to install named.conf"

	if [ ! -f '/etc/bind/rndc.key' ] && [ ! -f '/etc/bind/rndc.conf' ]; then
		einfo "Generating new rndc.key"
		/usr/sbin/rndc-confgen  -a
		echo
		chown root:named /etc/bind/rndc.key || die
		chmod 0640 /etc/bind/rndc.key || die
	fi

	einfo
	einfo "You can edit /etc/conf.d/named to customize named settings"
	einfo
	einfo "If you'd like to run bind in a chroot AND this is a new"
	einfo "install OR your bind doesn't already run in a chroot:"
	einfo "1) Uncomment and set the CHROOT variable in /etc/conf.d/named."
	einfo "2) Run \`emerge --config '=${CATEGORY}/${PF}'\`"
	einfo

	CHROOT=$(source /etc/conf.d/named 2>/dev/null; echo ${CHROOT})
	if [[ -n ${CHROOT} ]]; then
		elog "NOTE: As of net-dns/bind-9.4.3_p5-r1 the chroot part of the init-script got some major changes!"
		elog "To enable the old behaviour (without using mount) uncomment the"
		elog "CHROOT_NOMOUNT option in your /etc/conf.d/named config."
		elog "If you decide to use the new/default method, ensure to make backup"
		elog "first and merge your existing configs/zones to /etc/bind and"
		elog "/var/bind because bind will now mount the needed directories into"
		elog "the chroot dir."
	fi
}

pkg_config() {
	CHROOT=$(source /etc/conf.d/named; echo ${CHROOT})
	CHROOT_NOMOUNT=$(source /etc/conf.d/named; echo ${CHROOT_NOMOUNT})
	CHROOT_GEOIP=$(source /etc/conf.d/named; echo ${CHROOT_GEOIP})

	if [[ -z "${CHROOT}" ]]; then
		eerror "This config script is designed to automate setting up"
		eerror "a chrooted bind/named. To do so, please first uncomment"
		eerror "and set the CHROOT variable in '/etc/conf.d/named'."
		die "Unset CHROOT"
	fi
	if [[ -d "${CHROOT}" ]]; then
		ewarn "NOTE: As of net-dns/bind-9.4.3_p5-r1 the chroot part of the init-script got some major changes!"
		ewarn "To enable the old behaviour (without using mount) uncomment the"
		ewarn "CHROOT_NOMOUNT option in your /etc/conf.d/named config."
		ewarn
		ewarn "${CHROOT} already exists... some things might become overridden"
		ewarn "press CTRL+C if you don't want to continue"
		sleep 10
	fi

	echo; einfo "Setting up the chroot directory..."

	mkdir -m 0750 -p ${CHROOT} || die
	mkdir -m 0755 -p ${CHROOT}/{dev,etc,var/log,run} || die
	mkdir -m 0750 -p ${CHROOT}/etc/bind || die
	mkdir -m 0770 -p ${CHROOT}/var/{bind,log/named} ${CHROOT}/run/named/ || die

	chown root:named \
		${CHROOT} \
		${CHROOT}/var/{bind,log/named} \
		${CHROOT}/run/named/ \
		${CHROOT}/etc/bind \
		|| die

	if [ ! -e ${CHROOT}/dev/null ]; then
		mknod ${CHROOT}/dev/null c 1 3 || die
	fi
	chmod 0666 ${CHROOT}/dev/null || die
	if [ ! -e ${CHROOT}/dev/zero ]; then
		mknod ${CHROOT}/dev/zero c 1 5 || die
	fi
	chmod 0666 ${CHROOT}/dev/zero || die

	if [ ! -e ${CHROOT}/dev/urandom ]; then
		mknod ${CHROOT}/dev/urandom c 1 9 || die
	fi
		chmod 0666 ${CHROOT}/dev/urandom || die
	if [ ! -e ${CHROOT}/dev/random ]; then
		mknod ${CHROOT}/dev/random c 1 8 || die
	fi
	chmod 0666 ${CHROOT}/dev/random || die

	if [ "${CHROOT_NOMOUNT:-0}" -ne 0 ]; then
		cp -a /etc/bind ${CHROOT}/etc/ || die
		cp -a /var/bind ${CHROOT}/var/ || die
	fi

	if [ "${CHROOT_GEOIP:-0}" -eq 1 ]; then
		if use geoip; then
			mkdir -m 0755 -p ${CHROOT}/usr/share/GeoIP || die
		elif use geoip2; then
			mkdir -m 0755 -p ${CHROOT}/usr/share/GeoIP2 || die
		fi
	fi

	elog "You may need to add the following line to your syslog-ng.conf:"
	elog "source jail { unix-stream(\"${CHROOT}/dev/log\"); };"
}
