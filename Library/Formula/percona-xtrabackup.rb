require "formula"

class PerconaXtrabackup < Formula
  homepage "http://www.percona.com/software/percona-xtrabackup"
  url "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.9/source/tarball/percona-xtrabackup-2.2.9.tar.gz"
  version "2.2.9"
  sha256 "d4a65c425262e55deeee3c0c4316a7acf861e2822c1321637ba5350dc68fc4af"

  depends_on "cmake" => :build
  depends_on "libgcrypt" => :build
  depends_on "openssl"

  option :universal
  option 'with-tests', 'Build with unit tests'
  option 'enable-local-infile', 'Build with local infile loading support'

  # Where the database files should be located. Existing installs have them
  # under var/percona, but going forward they will be under var/msyql to be
  # shared with the mysql and mariadb formulae.
  def datadir
    @datadir ||= (var/'percona').directory? ? var/'percona' : var/'mysql'
  end

  def install
    # Don't hard-code the libtool path. See:
    # https://github.com/mxcl/homebrew/issues/20185
    inreplace "cmake/libutils.cmake",
      "COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION}",
      "COMMAND libtool -static -o ${TARGET_LOCATION}"

    # Build without compiler or CPU specific optimization flags to facilitate
    # compilation of gems and other software that queries `mysql-config`.
    ENV.minimal_optimization

    args = %W[
      -DBUILD_CONFIG=xtrabackup_release
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=ON
      -DMYSQL_DATADIR=#{datadir}
      -DINSTALL_MANDIR=#{man}
      -DINSTALL_DOCDIR=#{doc}
      -DINSTALL_INFODIR=#{info}
      -DWITH_SSL=yes
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DSYSCONFDIR=#{etc}
      -DCOMPILATION_COMMENT=Homebrew
      -DWITH_EDITLINE=system
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
    ]

    # PAM plugin is Linux-only at the moment
    args.concat %W[
      -DWITHOUT_AUTH_PAM=1
      -DWITHOUT_AUTH_PAM_COMPAT=1
      -DWITHOUT_DIALOG=1
    ]

    # To enable unit testing at build, we need to download the unit testing suite
    if build.with? 'tests'
      args << "-DENABLE_DOWNLOADS=ON"
    else
      args << "-DWITH_UNIT_TESTS=OFF"
    end

    # Make universal for binding to universal applications
    if build.universal?
      ENV.universal_binary
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.universal_archs.as_cmake_arch_flags}"
    end

    # Build with local infile loading support
    args << "-DENABLED_LOCAL_INFILE=1" if build.include? 'enable-local-infile'

    system "cmake", *args
    system "make"
    system "make", "install"
  end

end
