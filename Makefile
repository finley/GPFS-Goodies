PKG_NAME 	:= gpfs_goodies
#
# If we're running 'make' out of the git repo, then set the version
# here.  If we're running during an RPM build, then take the VERSION
# flag set in the environment by the spec file.
#
VERSION 	:= $(shell git describe --tags)
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
	cp ${TMPDIR}/${PKG_DIR}/Makefile ${TMPDIR}/${PKG_DIR}/Makefile.rpm
	
	#
	# Version the Files
	perl -pi -e "s/^Version:.*/Version: ${VERSION}/g" 				${TMPDIR}/${PKG_DIR}/gpfs_goodies.spec
	perl -pi -e "s/^(my \$version_string\s+=).*/$1 '${VERSION}'/g" 	${TMPDIR}/${PKG_DIR}/sbin/multipath.conf-creator
	perl -pi -e "s/^(version_string=).*/$1 '${VERSION}'/g" 			${TMPDIR}/${PKG_DIR}/sbin/gpfs_goodies
	perl -pi -e "s/^VERSION\s+.*/VERSION := ${VERSION}/g" 			${TMPDIR}/${PKG_DIR}/Makefile.rpm
	
	#
	# Tar it up
	cd ${TMPDIR} && tar -cvjf ${TARBALL} ${PKG_DIR}

.PHONY += rpm
rpm:	tarball
	rpmbuild -ta ${TARBALL}

