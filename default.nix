let
  # use a pinned version of nixpkgs
  nixpkgs-version = "19.09";
  nixpkgs = (import (builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixpkgs-${nixpkgs-version}";
    url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-version}.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "0mhqhq21y5vrr1f30qd2bvydv4bbbslvyzclhw0kdxmkgg3z4c92";
  }) {}).extend (self: super: {
  });
in
  nixpkgs.callPackage ./package.nix {}
