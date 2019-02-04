# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib toolchain-funcs flag-o-matic

SNAPSHOTDATE="${P##*.}"
MY_PV="${PN}-${SNAPSHOTDATE}"

DESCRIPTION="GNUCap is the GNU Circuit Analysis Package"
SRC_URI="http://git.savannah.gnu.org/cgit/gnucap.git/snapshot/${MY_PV}.tar.gz
	http://git.savannah.gnu.org/cgit/gnucap/gnucap-models.git/snapshot/${PN}-models-${SNAPSHOTDATE}.tar.gz"
HOMEPAGE="http://www.gnucap.org/"

IUSE="examples"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND="sys-libs/ncurses
	sys-libs/readline"
RDEPEND=""

S="${WORKDIR}/${MY_PV}"

src_prepare() {
	default

	mv "${WORKDIR}/gnucap-models-20171003/plugins/*" .
	local z
	local n
	for z in models-*; do
#		for n in `find ${z}/* -type d`; do
		ln -s ../main/gnucap-conf ${z}/gnucap-conf
#		done
	done
	ln -s main/gnucap-conf gnucap-conf
	sed -i -e 's:CFLAGS = -O2 -g:CPPFLAGS +=:' \
		-e '/CCFLAGS =/i\CFLAGS += $(CPPFLAGS)' \
		-e 's:CCFLAGS = $(CFLAGS):CXXFLAGS += $(CPPFLAGS):' \
		-e 's:LDFLAGS = :LDFLAGS += :' \
		-e 's:CCFLAGS:CXXFLAGS:' \
		models-*/Make2 || die "sed failed"
#		-e 's:../Gnucap:Gnucap:' \

	sed -i -e '2i\#include <iostream>\n#include <iomanip>' \
	{lib,apps}/test_readline.cc || die "sed failed"

	sed -i -e 's/termcap/ncurses/' \
	{lib,apps}/configure || die "sed failed"

#	sed -i -e '/-lgnucap/a\echo "-ldl \\\\" >>Make.libs' \
#	{modelgen,main}/configure || die "sed failed"

	tc-export CC CXX
#	append-cxxflags -std=gnu++98
}

#src_compile () {
#	emake || die "Compilation failed"
#	for PLUGIN_DIR in models-* ; do
#		cd "${PLUGIN_DIR}"
#		emake CC=$(tc-getCC) CCC=$(tc-getCXX) || die "Compilation failed in ${PLUGIN_DIR}"
#	done
#}

#src_install () {
#	emake DESTDIR="${D}" install || die "Installation failed"
#	insopts -m0755
#	for PLUGIN_DIR in models-* ; do
#		insinto /usr/$(get_libdir)/gnucap/${PLUGIN_DIR}
#		cd "${S}/${PLUGIN_DIR}"
#		for PLUGIN in */*.so ; do
#			newins ${PLUGIN} ${PLUGIN##*/} \
#			|| die "Installation of ${PLUGIN_DIR}/${PLUGIN} failed"
#		done
#	done
#}

pkg_postinst() {
	elog "Documentation for development releases is now available at :"
	elog "    http://wiki.gnucap.org/dokuwiki/doku.php?id=gnucap:manual"
}
