%define sourcename @CPACK_SOURCE_PACKAGE_FILE_NAME@
%global dev_version %{lua: extraver = string.gsub('@EOS_NSAL_EXTRA_VERSION@', '%-', '.'); print(extraver) }

Name: eos-nsal
Version: @EOS_NSAL_BASE_VERSION@
Release: %{dev_version}%{?dist}
Summary: Namespace abstraction layer library
License: Seagate
Group: Development/Libraries
Url: http://seagate.com/eos-nsal
Source: %{sourcename}.tar.gz
BuildRequires: cmake gcc libini_config-devel
BuildRequires: @RPM_DEVEL_REQUIRES@
Requires: libini_config @RPM_REQUIRES@
Provides: %{name} = %{version}-%{release}

# EOS NSAL library paths
%define _nsal_dir		@INSTALL_DIR_ROOT@/@PROJECT_NAME_BASE@/nsal
%define _nsal_lib_dir		%{_nsal_dir}/lib
%define _nsal_include_dir	%{_includedir}/nsal

# Conditionally enable KVS and object stores
#
# 1. rpmbuild accepts these options:
#    --with eos
#    --without redis

%define on_off_switch() %%{?with_%1:ON}%%{!?with_%1:OFF}

# A few explanation about %bcond_with and %bcond_without
# /!\ be careful: this syntax can be quite messy
# %bcond_with means you add a "--with" option, default = without this feature
# %bcond_without adds a"--without" so the feature is enabled by default

@BCOND_KVS_REDIS@ kvs_redis
%global use_kvs_redis %{on_off_switch kvs_redis}

@BCOND_KVS_EOS@ kvs_eos
%global use_kvs_eos %{on_off_switch kvs_eos}

@BCOND_ENABLE_DASSERT@ enable_dassert
%global enable_dassert %{on_off_switch enable_dassert}

%description
The eos-nsal is Namespace abstraction layer library. It uses @KVS_OPT@ as Key-Value Store.

%package devel
Summary: Development file for the library eos-nsal
Group: Development/Libraries
Requires: %{name} = %{version}-%{release} pkgconfig
Requires: @RPM_DEVEL_REQUIRES@
Provides: %{name}-devel = %{version}-%{release}


%description devel
The eos-nsal is Namespace abstraction layer library.
This package contains tools for eos-nsal.

%prep
%setup -q -n %{sourcename}

%build
cmake . -DUSE_KVS_REDIS=%{use_kvs_redis}     \
	-DUSE_KVS_EOS=%{use_kvs_eos}       \
	-DEOSUTILSINC:PATH=@EOSUTILSINC@     \
	-DLIBEOSUTILS:PATH=@LIBEOSUTILS@	\
	-DENABLE_DASSERT=%{enable_dassert}

make %{?_smp_mflags} || make %{?_smp_mflags} || make

%install

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}
mkdir -p %{buildroot}%{_nsal_dir}
mkdir -p %{buildroot}%{_nsal_lib_dir}
mkdir -p %{buildroot}%{_nsal_include_dir}/
mkdir -p %{buildroot}%{_sysconfdir}/nsal.d
mkdir -p %{buildroot}%{_libdir}/pkgconfig
install -m 644 include/*.h  %{buildroot}%{_nsal_include_dir}
install -m 755 libeos-nsal.so %{buildroot}%{_nsal_lib_dir}
install -m 644 eos-nsal.pc  %{buildroot}%{_libdir}/pkgconfig
ln -s %{_nsal_lib_dir}/libeos-nsal.so %{buildroot}%{_libdir}/libeos-nsal.so

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_libdir}/libeos-nsal.so*
%{_nsal_lib_dir}/libeos-nsal.so*

%files devel
%defattr(-,root,root)
%{_libdir}/pkgconfig/eos-nsal.pc
%{_nsal_include_dir}/*.h

%changelog
* Tue Dec 24 2019 Seagate 1.0.1
- Release candidate

