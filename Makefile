PKG_NAME 	:= $(shell basename `pwd`)
VERSION 	:= $(shell git describe --tags)
TMPDIR 		:= $(shell mktemp -d)
SPECFILE 	:= $(shell mktemp)
PKG_DIR     := ${PKG_NAME}-${VERSION}
TARBALL		:= /tmp/${PKG_DIR}.tar.bz2

.PHONY += all
all: tarball

.PHONY += install
install: version_executables
	mkdir -p ${PREFIX}/usr/sbin/
	install -m 755 sbin/* ${PREFIX}/usr/sbin/
	
	mkdir -p ${PREFIX}/usr/share/${PKG_NAME}/etc/modprobe.d/
	install -m 644 etc/modprobe.d/* ${PREFIX}/usr/share/${PKG_NAME}/etc/modprobe.d/
	
	mkdir -p ${PREFIX}/usr/share/${PKG_NAME}/etc/udev/rules.d/
	install -m 644 etc/udev/rules.d/* ${PREFIX}/usr/share/${PKG_NAME}/etc/udev/rules.d/
	
	mkdir -p ${PREFIX}/usr/share/doc/${PKG_NAME}-${VERSION}/
	install -m 644 doc/* ${PREFIX}/usr/share/doc/${PKG_NAME}-${VERSION}/

.PHONY += create_spec_file
create_spec_file:
	/bin/cp gpfs_goodies.spec ${SPECFILE}
	perl -pi -e "s/^Version:.*/Version: ${VERSION}/g" ${SPECFILE}

.PHONY += version_executables
version_executables:
	perl -pi -e "s/^(my \$version_string\s+=).*/$1 '${VERSION}'/g" ./bin/multipath.conf-creator

.PHONY += tarball
tarball: create_spec_file version_executables
	git clone . ${TMPDIR}/${PKG_DIR}
	rm -fr ${TMPDIR}/${PKG_DIR}/.git
	/bin/cp ${SPECFILE} ${TMPDIR}/${PKG_DIR}/gpfs_goodies.spec
	cd ${TMPDIR} && tar -cvjf ${TARBALL} ${PKG_DIR}

.PHONY += rpm
rpm:	tarball
	rpmbuild -ta ${TARBALL}

