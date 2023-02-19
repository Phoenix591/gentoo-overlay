# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..11} )
PYTHON_REQ_USE="xml(+)"

inherit python-r1 systemd

DESCRIPTION="A Web Service Discovery host daemon."
HOMEPAGE="https://github.com/christgau/wsdd"
if [ "${PV}" -eq "9999" ]; then
	EGIT_REPO_URI="https://github.com/christgau/wsdd"
	inherit git-r3
else
	SRC_URI="https://github.com/christgau/wsdd/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="samba"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND=""
# Samba is technically not a requirement of wsdd, but depend on it if the use flags is set.
RDEPEND="${PYTHON_DEPS} acct-group/${PN} acct-user/${PN} samba? ( net-fs/samba )"
BDEPEND=""

src_install() {
	python_foreach_impl python_newscript src/wsdd.py wsdd

	# remove dependency on samba from init.d script if samba is not in use flags
	if ! use samba ; then
		sed -i -e '/need samba/d' etc/openrc/init.d/wsdd || die
	fi

	sed -i -e "s/daemon:daemon/${PN}:${PN}/" etc/openrc/init.d/wsdd || die

	doinitd etc/openrc/init.d/wsdd
	doconfd etc/openrc/conf.d/wsdd

	# install systemd unit file with dependency on samba service if use flag is set
	if use samba; then
		sed -i -e 's/;Wants=smb.service/Wants=samba.service/' etc/systemd/wsdd.service || die
	fi
	systemd_dounit etc/systemd/wsdd.service

	dodoc README.md
	doman man/wsdd.8
}
py_test() {
	sed -i -e "s/python_versions=(.*/python_versions=(\'${EPYTHON#python}\')/" \
		test/regressions/*/*.sh || die "Failed to sed test scripts"
	test/regressions/run-regressions.sh || die "Tests failed for ${EPYTHON}"
}
src_test() {
	python_foreach_impl py_test
}
