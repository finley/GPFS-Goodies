#
# 	2013.10.11 Brian Finley <bfinley@us.ibm.com>
#	- improve version handling
# 	2013.11.07 Brian Finley <bfinley@us.ibm.com>
#	- include ./var/*
#   - better handling of version setting in included progs
#   - put user docs, etc all in one place
#

package 	:= gpfs_goodies

MAJOR_VER 	:= $(shell git describe --tags | sed -e 's/^v//' -e 's/[.-].*//')
MAJOR_VER   ?= 0

MINOR_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*[.-]//' -e 's/[.-].*//')
MINOR_VER   ?= 0

PATCH_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*[.-][0-9]*[.-]//' -e 's/[.-].*//')
PATCH_VER   ?= 0

AUTO_VER	:= $(shell git describe --tags | sed -e 's/^v[0-9]*[.-][0-9]*[.-][0-9]*[.-]//' -e 's/[.-].*//')
AUTO_VER    ?= 0

# In case we have made commits (AUTO_VER) since updating a PATCH_VER in
# the tag. -BEF-
PATCH_VER	:= $(shell echo "$$(( $(PATCH_VER) + $(AUTO_VER) ))" )

VERSION     := ${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}

TMPDIR 		:= $(shell mktemp -d)
SPECFILE 	:= $(shell mktemp)
PKG_DIR     := ${package}-${VERSION}

TOPDIR 		:= $(CURDIR)
rpmbuild    = ~/rpmbuild

TARBALL		:= $(TOPDIR)/tmp/${PKG_DIR}.tar.bz2

.PHONY += all
all: tarball

.PHONY += install
install:
	mkdir -p             	${PREFIX}/usr/sbin/
	install -m 755 sbin/*	${PREFIX}/usr/sbin/
	
	mkdir -p                ${PREFIX}/etc/gpfs_goodies/multipath.conf-creator_config_chunks/
	install -m 755 etc/gpfs_goodies/multipath.conf-creator_config_chunks/*    ${PREFIX}/etc/gpfs_goodies/multipath.conf-creator_config_chunks/
	
	mkdir -p            			        ${PREFIX}/usr/share/${package}/
	rsync -av doc/* 						${PREFIX}/usr/share/${package}/
	find ${PREFIX}/usr/share/${package}/ -type d -exec chmod 755 '{}' \;
	find ${PREFIX}/usr/share/${package}/ -type f -exec chmod 644 '{}' \;
	
	mkdir -p                       			${PREFIX}/usr/share/${package}/etc/modprobe.d/
	install -m 644 etc/modprobe.d/*			${PREFIX}/usr/share/${package}/etc/modprobe.d/
	
	mkdir -p                       			${PREFIX}/usr/share/${package}/var/mmfs/etc/
	install -m 644 var/mmfs/etc/*			${PREFIX}/usr/share/${package}/var/mmfs/etc/
	
	mkdir -p                       			${PREFIX}/etc/init.d/
	install -m 755 etc/init.d/*				${PREFIX}/etc/init.d/
	
	mkdir -p ${PREFIX}/usr/share/doc/${PKG_DIR}/
	echo "See the files in /usr/share/${package}/" > ${PREFIX}/usr/share/doc/${PKG_DIR}/README

.PHONY += tarball
tarball:
	
	mkdir -p $(TOPDIR)/tmp/
	
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
	perl -pi -e "s/__VERSION__/${VERSION}/g"  					        ${TMPDIR}/${PKG_DIR}/${package}.spec
	perl -pi -e "s/^VERSION=.*/VERSION=${VERSION}/g"                    ${TMPDIR}/${PKG_DIR}/sbin/gpfs_goodies
	perl -pi -e "s/^VERSION=.*/VERSION=${VERSION}/g"  				    ${TMPDIR}/${PKG_DIR}/sbin/brians_own_hot-add_script
	perl -pi -e "s/version_number = .*/version_number = '${VERSION}';/g"  ${TMPDIR}/${PKG_DIR}/sbin/multipath.conf-creator
	perl -pi -e "s/version_number = .*/version_number = '${VERSION}';/g"  ${TMPDIR}/${PKG_DIR}/sbin/tune_block_device_settings
	perl -pi -e "s/version_number = .*/version_number = '${VERSION}';/g"  ${TMPDIR}/${PKG_DIR}/sbin/gpfs_stanzafile-creator
	
	#
	# Tar it up
	cd ${TMPDIR} && tar -cvjf ${TARBALL} ${PKG_DIR}

.PHONY += rpms
rpms:	rpm

.PHONY += rpm
rpm:	tarball
	rpmbuild -ta --sign ${TARBALL}
	/bin/cp -i ${rpmbuild}/RPMS/*/${package}-$(VERSION)-*.rpm   $(TOPDIR)/tmp/
	/bin/cp -i ${rpmbuild}/SRPMS/${package}-$(VERSION)-*.rpm	$(TOPDIR)/tmp/

.PHONY: release
release:
	@echo "Please try 'make test_release' or 'make stable_release'"

.PHONY: test_release
test_release:  rpms
	@echo 
	@echo "I'm about to upload the following files to:"
	@echo "  ~/src/www.systemimager.org/testing/${package}/"
	@echo "-----------------------------------------------------------------------"
	@/bin/ls -1 $(TOPDIR)/tmp/${package}[-_]$(VERSION)*.*
	@echo
	@echo "Hit <Enter> to continue..."
	@read i
	rsync -av --progress $(TOPDIR)/tmp/${package}[-_]$(VERSION)*.* ~/src/www.systemimager.org/testing/${package}/
	@echo
	@echo "Now run:   cd ~/src/www.systemimager.org/ && make upload"
	@echo

.PHONY: stable_release
stable_release:  rpms
	@echo 
	@echo "I'm about to upload the following files to:"
	@echo "  ~/src/www.systemimager.org/stable/${package}/"
	@echo "-----------------------------------------------------------------------"
	@/bin/ls -1 $(TOPDIR)/tmp/${package}[-_]$(VERSION)*.*
	@echo
	@echo "Hit <Enter> to continue..."
	@read i
	rsync -av --progress $(TOPDIR)/tmp/${package}[-_]$(VERSION)*.* ~/src/www.systemimager.org/stable/${package}/
	@echo
	@echo "Now run:   cd ~/src/www.systemimager.org/ && make upload"
	@echo

.PHONY += help
help:
	@echo "Targets include:"
	@echo "  help"
	@echo "  rpm"
	@echo "  tarball"
	@echo "  all"
	@echo "  install"

.PHONY: clean
clean:
	rm -fr $(TOPDIR)/tmp/

#   vi: set ts=4 noet ai tw=0:
