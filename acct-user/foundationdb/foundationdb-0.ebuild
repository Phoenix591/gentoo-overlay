# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8
inherit acct-user

Description="User for Foundationdb"

#dynamically assign uid
ACCT_USER_ID="-1"
ACCT_USER_GROUPS=( ${PN} )
acct-user_add_deps
