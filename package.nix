{ stdenv, bats, python3 }:
stdenv.mkDerivation {
  name = "httpshare";
  src = ./.;

  buildInputs = [bats python3];

  dontPatchShebangs = true;  # Keep the portable shebang.

  buildPhase = ''
    # set epoch to 1980 because zip doesn't support the seventies
    find -exec touch -t 198001010000.00 {} +
    ./make_zipapp.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp httpshare.pyz $out/bin/httpshare
  '';
}
