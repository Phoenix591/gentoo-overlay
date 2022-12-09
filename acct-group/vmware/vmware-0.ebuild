# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8
inherit acct-group

Description="Group for vmware (udev rules for it)"

#dynamically assign gid
ACCT_GROUP_ID="-1"

