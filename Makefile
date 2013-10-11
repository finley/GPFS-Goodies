#
# 	2013.10.11 Brian Finley <bfinley@us.ibm.com>
#	- improve version handling
#

PKG_NAME 	:= gpfs_goodies
MAJOR_VER 	:= $(shell git describe --tags | sed -e 's/^v//' -e 's/-.*//')
MINOR_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*-//' -e 's/-.*//')
MINOR_VER   ?= 0
VERSION     := ${MAJOR_VER}.${MINOR_VER}
TMPDIR 		:= $(shell mktemp -d)
SPECFILE 	:= $(shell mktemp)
PKG_DIR     := ${PKG_NAME}-${VERSION}
TARBALL		:= /tmp/${PKG_DIR}.tar.bz2

.PHONY += all
all: tarball

.PHONY += install
install:
	mkdir -p ${PREFIX}/usr/sbin/
	install -m 755 sbin/* ${PREFIX}/usr/sbin/
	
	mkdir -p ${PREFIX}/usr/share/${PKG_NAME}/etc/modprobe.d/
	install -m 644 etc/modprobe.d/* ${PREFIX}/usr/share/${PKG_NAME}/etc/modprobe.d/
	
	mkdir -p ${PREFIX}/usr/share/${PKG_NAME}/etc/udev/rules.d/
	install -m 644 etc/udev/rules.d/* ${PREFIX}/usr/share/${PKG_NAME}/etc/udev/rules.d/
	
	mkdir -p ${PREFIX}/usr/share/doc/${PKG_NAME}-${VERSION}/
	install -m 644 doc/* ${PREFIX}/usr/share/doc/${PKG_NAME}-${VERSION}/

.PHONY += tarball
tarball:
	
	#
	# Make a copy of the repo
	git clone . ${TMPDIR}/${PKG_DIR}
	rm -fr ${TMPDIR}/${PKG_DIR}/.git
	
	#
	# Create an RPM appropriate Makefile
	cp ${TMPDIR}/${PKG_DIR}/Makefile 								${TMPDIR}/${PKG_DIR}/Makefile.rpm
	perl -pi -e "s/^MAJOR_VER\s+.*/MAJOR_VER := ${MAJOR_VER}/g" 	${TMPDIR}/${PKG_DIR}/Makefile.rpm
	perl -pi -e "s/^MINOR_VER\s+.*/MINOR_VER := ${MINOR_VER}/g" 	${TMPDIR}/${PKG_DIR}/Makefile.rpm
	
	#
	# Version the Files
	perl -pi -e "s/^Version:.*/Version: ${VERSION}/g" 				${TMPDIR}/${PKG_DIR}/gpfs_goodies.spec
	perl -pi -e "s/^(my \$version_string\s+=).*/$1 '${VERSION}'/g" 	${TMPDIR}/${PKG_DIR}/sbin/multipath.conf-creator
	perl -pi -e "s/^VERSION=.*/VERSION=${VERSION}/g" 			    ${TMPDIR}/${PKG_DIR}/sbin/gpfs_goodies
	
	#
	# Tar it up
	cd ${TMPDIR} && tar -cvjf ${TARBALL} ${PKG_DIR}

.PHONY += rpm
rpm:	tarball
	rpmbuild -ta ${TARBALL}

