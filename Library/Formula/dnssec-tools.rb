class DnssecTools < Formula
  desc "tool-suite for DNSSEC"
  homepage "http://www.dnssec-tools.org"
  url "http://www.dnssec-tools.org/download/dnssec-tools-2.1.tar.gz"
  version "2.1"
  sha256 "64eebfd1213714b530e501f22b5ff9786db9b982897c432fecba75740ddcda52"
  head "https://www.dnssec-tools.org/svn/dnssec-tools/"

  depends_on "bind"
  depends_on "openssl"
  depends_on "perl"

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-bind-checks",
                          "--disable-ecdsa-check"
    system "make", "install"
  end

  test do
    system "dnssec-tools", "-v"
  end
end
