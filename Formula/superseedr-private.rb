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

  bottle do
    root_url "https://github.com/Jagalite/homebrew-tap/releases/download/superseedr-private-1.0.15"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b03b2aff382e01f2aa314bab65569282d7e61aa8ddbce58f56dc684c1e60c5e5"
    sha256 cellar: :any,                 x86_64_linux:  "e425905f47328e5cc117f638b5063c2ba20ee06d56489654d0e29607031fa7aa"
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
