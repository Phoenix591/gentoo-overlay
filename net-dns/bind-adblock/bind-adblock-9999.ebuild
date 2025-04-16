# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit git-r3 python-single-r1

DESCRIPTION="Fetch various blocklists and generate a BIND zone from them."
HOMEPAGE="https://github.com/Trellmor/bind-adblock"

EGIT_REPO_URI="https://github.com/Trellmor/bind-adblock.git"

LICENSE="MIT"
SLOT="0"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="${PYTHON_DEPS}"
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pycryptodome[${PYTHON_USEDEP}]
		dev-python/dnspython[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/validators[${PYTHON_USEDEP}]
		')
"

src_prepare() {
	sed -i -e s#blocklist.txt#/etc/bind-blocklist.txt# \
		-e s#.cache/bind_adblock#/tmp/bind_adblock# config.yml || die
	eapply "${FILESDIR}/use-etc.patch" || die
	default
}
src_install() {
	python_doscript update-zonefile.py
	dodoc README.md
	insinto /etc
	newins config.yml bind-adblock.yml
	newins  blocklist.txt bind-blocklist.txt

}

pkg_postinst() {
	einfo "The script has been modified to look for its config in /etc"
}
