# Copyright 2011-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9,10,11} )
inherit unpacker python-single-r1 systemd

DESCRIPTION="FoundationDB is a distributed database designed to handle large volumes of structured data across clusters"
HOMEPAGE="https://www.foundationdb.org/"

MY_PN="foundationdb"
# https://github.com/apple/foundationdb/releases/download/6.3.24/foundationdb-clients_6.3.24-1_amd64.deb
KEYWORDS="-* ~amd64"
DEB_REL="1"
#MY_P="${MY_PN}_${PV}-1"
MY_PV="${PV}-${DEB_REL}"

SRC_URI=" https://github.com/apple/foundationdb/releases/download/${PV}/foundationdb-clients_${MY_PV}_amd64.deb
	server? ( https://github.com/apple/foundationdb/releases/download/${PV}/foundationdb-server_${MY_PV}_amd64.deb ) "

LICENSE="Apache-2.0"
SLOT="0"
IUSE="server"
REQUIRED_USE="
	 server? ( ${PYTHON_REQUIRED_USE} ) "
RESTRICT="bindist mirror strip"
RDEPEND=" server? ( ${PYTHON_DEPS}
		acct-user/foundationdb
		acct-group/foundationdb ) "
BDEPEND="${RDPEEND}"

QA_PREBUILT="*"
#QA_DESKTOP_FILE="usr/share/applications/google-chrome.*\\.desktop"
S="${WORKDIR}"

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "Sorry, this binary package is only available on amd64"
}

pkg_setup() {
	use server && python-single-r1_pkg_setup
}
src_install() {
	dodir /
	if use server; then
		insinto /etc/foundationdb
		sed -i s#/usr/lib/foundationdb#/usr/$(get_libdir)/foundationdb# etc/foundationdb/foundationdb.conf || die
		doins etc/foundationdb/foundationdb.conf
		exeinto /usr/$(get_libdir)/foundationdb
		doexe usr/lib/foundationdb/fdbmonitor
		python_scriptinto /usr/$(get_libdir)/foundationdb
		python_doscript usr/lib/foundationdb/make_public.py
		dosbin usr/sbin/fdbserver
		keepdir /var/log/foundationdb
		keepdir /var/lib/foundationdb/data
		fowners foundationdb:foundationdb /var/log/foundationdb
		fowners  foundationdb:foundationdb /var/lib/foundationdb /var/lib/foundationdb/data
		fowners :foundationdb /etc/foundationdb
		fperms g+w /etc/foundationdb
		cp "${FILESDIR}"/foundationdb-{openrc,systemd} ./ || die
		sed -i s#LIBDIR#$(get_libdir)# ./foundationdb-{openrc,systemd}
		newinitd foundationdb-openrc foundationdb
		systemd_newunit foundationdb-systemd foundationdb.service
	fi
	# Client
		dobin usr/bin/{dr_agent,fdbbackup,fdbcli,fdbdr,fdbrestore}
		doheader -r usr/include/foundationdb
		insinto /usr/$(get_libdir)/pkgconfig
		doins usr/lib/pkgconfig/foundationdb-client.pc
		dolib.so usr/lib/libfdb_c.so
		insinto /usr/$(get_libdir)/cmake/FoundationDB-Client
		doins usr/lib/cmake/FoundationDB-Client/*
		exeinto /usr/$(get_libdir)/foundationdb/backup_agent
		doexe usr/lib/foundationdb/backup_agent/backup_agent
}
pkg_postinst() {
	if [ ! -f /etc/foundationdb/fdb.cluster ] && use server; then
		einfo "First install detected, setting up fdb.cluster with random description and ids"
		cf=/etc/foundationdb/fdb.cluster
		desc=$(tr -dc A-Za-z0-9 </dev/urandom 2>/dev/null | head -c8)
		rand=$(tr -dc A-Za-z0-9 </dev/urandom 2>/dev/null | head -c8)
		echo ''${desc}:''${rand}@127.0.0.1:4500 > $cf
		chmod 0660 $cf && chown foundationdb:foundationdb $cf
		touch "/var/lib/foundationdb/.first_startup"
	fi
}
