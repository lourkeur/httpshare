let
  # use a pinned version of nixpkgs
  nixpkgs-version = "19.03";
  nixpkgs = (import (builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixpkgs-${nixpkgs-version}";
    url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-version}.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "0q2m2qhyga9yq29yz90ywgjbn9hdahs7i8wwlq7b55rdbyiwa5dy";
  }) {}).extend (self: super: {
  });
  httpshare = with nixpkgs; stdenv.mkDerivation {
    name = "httpshare";
    src = ./.;

    buildInputs = [bats python3Packages.python];

    buildPhase = ''
      # set epoch to 1980 because zip doesn't support the seventies
      find -exec touch -t 198001010000.00 {} +
      ./make_zipapp.py
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp httpshare.pyz $out/bin/httpshare
    '';
  };
in
  httpshare
