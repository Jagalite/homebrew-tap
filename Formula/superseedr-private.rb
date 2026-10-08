class SuperseedrPrivate < Formula
  desc "Terminal BitTorrent client without DHT, PEX, or WebTorrent"
  homepage "https://github.com/Jagalite/superseedr"
  url "https://github.com/Jagalite/superseedr/archive/refs/tags/v1.0.15.tar.gz"
  sha256 "ca658aefa9d39656cffc8af2a0005bf27f9d61bc8d97afdb059dbd970cc89bfa"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args, "--no-default-features", "--bin", "superseedr"
    mv bin/"superseedr", bin/"superseedr-private"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/superseedr-private --version")
    assert_match "show-shared-config", shell_output("#{bin}/superseedr-private --help")
    assert_path_exists bin/"superseedr-private"
    refute_path_exists bin/"superseedr"
  end
end
