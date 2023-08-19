# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module xdg

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vinegarhq/vinegar.git"
else
	SRC_URI="https://github.com/vinegarhq/vinegar/archive/refs/tags/v${PV}.tar.gz"
	KEYWORDS="amd64"
fi

DESCRIPTION="An open-source, minimal, configurable, fast bootstrapper for running Roblox on Linux"
HOMEPAGE="https://vinegarhq.github.io"

LICENSE="GPL-3"
SLOT="0"
IUSE="pie +mutexer"

RDEPEND="
    virtual/wine
"
DEPEND="${RDEPEND}"
BDEPEND="
    dev-lang/go
    mutexer? ( dev-util/mingw64-toolchain )
"

src_compile() {
    GOFLAGS="${GOFLAGS}"
    if use pie ; then
        GOFLAGS+=" -buildmode=pie"
    fi
    emake vinegar
    if use mutexer ; then
        PATH="/usr/lib/mingw64-toolchain/bin:${PATH}"
        emake robloxmutexer
    fi
}

src_install() {
    emake DESTDIR="${D}" PREFIX="/usr" install
    if use mutexer ; then
        emake DESTDIR="${D}" PREFIX="/usr" install-robloxmutexer
    fi
}

pkg_postinst() {
    xdg_desktop_database_update
}

pkg_postrm() {
    xdg_desktop_database_update
}
