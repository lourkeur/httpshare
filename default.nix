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
in
  nixpkgs.callPackage ./package.nix {}
