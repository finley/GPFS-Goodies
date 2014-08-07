#
# 	2013.10.11 Brian Finley <bfinley@us.ibm.com>
#	- improve version handling
# 	2013.11.07 Brian Finley <bfinley@us.ibm.com>
#	- include ./var/*
#   - better handling of version setting in included progs
#   - put user docs, etc all in one place
#

PKG_NAME 	:= gpfs_goodies

MAJOR_VER 	:= $(shell git describe --tags | sed -e 's/^v//' -e 's/-.*//')
MAJOR_VER   ?= 0

MINOR_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*-//' -e 's/-.*//')
MINOR_VER   ?= 0

PATCH_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*-[0-9]*-//' -e 's/-.*//')
PATCH_VER   ?= 0

AUTO_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*-[0-9]*-[0-9]*-//' -e 's/-.*//')
AUTO_VER    ?= 0

# In case we have made commits (AUTO_VER) since updating a PATCH_VER in
# the tag. -BEF-
PATCH_VER	:= $(shell echo "$$(( $(PATCH_VER) + $(AUTO_VER) ))" )

VERSION     := ${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}

TMPDIR 		:= $(shell mktemp -d)
SPECFILE 	:= $(shell mktemp)
PKG_DIR     := ${PKG_NAME}-${VERSION}
TARBALL		:= /tmp/${PKG_DIR}.tar.bz2

.PHONY += all
all: tarball

.PHONY += install
install:
	mkdir -p             	${PREFIX}/usr/sbin/
	install -m 755 sbin/*	${PREFIX}/usr/sbin/
	
	mkdir -p                ${PREFIX}/etc/gpfs_goodies/multipath.conf-creator_config_chunks/
	install -m 755 etc/gpfs_goodies/multipath.conf-creator_config_chunks/*    ${PREFIX}/etc/gpfs_goodies/multipath.conf-creator_config_chunks/
	
	mkdir -p            			        ${PREFIX}/usr/share/${PKG_NAME}/
	rsync -av doc/* 						${PREFIX}/usr/share/${PKG_NAME}/
	find ${PREFIX}/usr/share/${PKG_NAME}/ -type d -exec chmod 755 '{}' \;
	find ${PREFIX}/usr/share/${PKG_NAME}/ -type f -exec chmod 644 '{}' \;
	
	mkdir -p                       			${PREFIX}/usr/share/${PKG_NAME}/etc/modprobe.d/
	install -m 644 etc/modprobe.d/*			${PREFIX}/usr/share/${PKG_NAME}/etc/modprobe.d/
	
	mkdir -p                       			${PREFIX}/usr/share/${PKG_NAME}/var/mmfs/etc/
	install -m 644 var/mmfs/etc/*			${PREFIX}/usr/share/${PKG_NAME}/var/mmfs/etc/
	
	mkdir -p                       			${PREFIX}/etc/init.d/
	install -m 755 etc/init.d/*				${PREFIX}/etc/init.d/
	
	mkdir -p ${PREFIX}/usr/share/doc/${PKG_DIR}/
	echo "See the files in /usr/share/${PKG_NAME}/" > ${PREFIX}/usr/share/doc/${PKG_DIR}/README

.PHONY += tarball
tarball:
	
	#
	# Make a copy of the repo
	git clone . ${TMPDIR}/${PKG_DIR}
	/bin/rm -fr ${TMPDIR}/${PKG_DIR}/.git
	#
	# Vizio files may be quite large, and can be found in the repo if
	# needed. -BEF-
	/bin/rm -fr ${TMPDIR}/${PKG_DIR}/doc/*.vsd

	#
	# Copy this file over (for testing only)
	/bin/cp Makefile ${TMPDIR}/${PKG_DIR}/
	
	#
	# Create an RPM appropriate Makefile
	cp ${TMPDIR}/${PKG_DIR}/Makefile 								${TMPDIR}/${PKG_DIR}/Makefile.rpm
	perl -pi -e "s/^MAJOR_VER\s+.*/MAJOR_VER := ${MAJOR_VER}/g" 	${TMPDIR}/${PKG_DIR}/Makefile.rpm
	perl -pi -e "s/^MINOR_VER\s+.*/MINOR_VER := ${MINOR_VER}/g" 	${TMPDIR}/${PKG_DIR}/Makefile.rpm
	perl -pi -e "s/^PATCH_VER\s+.*/PATCH_VER := ${PATCH_VER}/g" 	${TMPDIR}/${PKG_DIR}/Makefile.rpm
	
	#
	# Version the Files
	perl -pi -e "s/__VERSION__/${VERSION}/g"  					        ${TMPDIR}/${PKG_DIR}/${PKG_NAME}.spec
	perl -pi -e "s/^VERSION=.*/VERSION=${VERSION}/g"                    ${TMPDIR}/${PKG_DIR}/sbin/gpfs_goodies
	perl -pi -e "s/^VERSION=.*/VERSION=${VERSION}/g"  				    ${TMPDIR}/${PKG_DIR}/sbin/brians_own_hot-add_script
	perl -pi -e "s/version_number = .*/version_number = '${VERSION}';/g"  ${TMPDIR}/${PKG_DIR}/sbin/multipath.conf-creator
	perl -pi -e "s/version_number = .*/version_number = '${VERSION}';/g"  ${TMPDIR}/${PKG_DIR}/sbin/tune_block_device_settings
	
	#
	# Tar it up
	cd ${TMPDIR} && tar -cvjf ${TARBALL} ${PKG_DIR}

.PHONY += rpm
rpm:	tarball
	rpmbuild -ta ${TARBALL}

.PHONY += release
release:	rpm
	mkdir -p tmp/
	cp -i ~/rpmbuild/RPMS/noarch/${PKG_NAME}-${VERSION}-1.noarch.rpm    tmp/
	cp -i ~/rpmbuild/SRPMS/${PKG_NAME}-${VERSION}-1.src.rpm             tmp/
	cp -i ${TARBALL}                                                    tmp/
	@echo
	@echo "Results:"
	@/bin/ls -1 tmp/*${PKG_NAME}-${VERSION}* | sed 's/^/  /'

.PHONY += help
help:
	@echo "Targets include:"
	@echo "  help"
	@echo "  rpm"
	@echo "  tarball"
	@echo "  all"
	@echo "  install"
