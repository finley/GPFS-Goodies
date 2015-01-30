Summary: GPFS Goodies -- Tools to deploy GPFS on Linux with Device Mapper Multipath
Name: gpfs_goodies
Version: __VERSION__
Release: 1
Source: %{name}-%{version}.tar.bz2
BuildRoot: /tmp/%{name}-buildroot
BuildArchitectures: noarch
Requires: lsscsi >= 0.21, expect
License: Apache License, Version 2.0


%description
GPFS Goodies includes a set of tools and a HOWTO for using the included
"multipath.conf-creator", a simple command-line tool to create a
multipath.conf configuration appropriate for an entire GPFS storage
cluster.  Includes step-by-step guidance on deployment.  Start by
viewing the HOWTO.
.
Includes: 
  Tools
    - multipath.conf-creator
    - brians_own_hot-add_script
    - gpfs_stanzafile-creator
    - test_block_device_settings
    - tune_block_device_settings
  OpenSM init script for direct connect InfiniBand storage
    - /etc/init.d/opensmd.for_direct_connect_storage
      (installed inactive)
  HOWTOs
    - GPFS Multi-Cluster Routing HOWTO
  Some half-baked goodies and examples



%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
make -f Makefile.rpm PREFIX=$RPM_BUILD_ROOT install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%config(noreplace) /etc/gpfs_goodies/*
%config(noreplace) /etc/init.d/*
%{_prefix}/sbin/*
%{_prefix}/share/*

%changelog
* Fri Sep 20 2013 Brian Elliott Finley <bfinley@us.ibm.com>
- created this spec file

