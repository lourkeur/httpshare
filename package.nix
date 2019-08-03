{ stdenv, bats, python3, ensureNewerSourcesForZipFilesHook }:
stdenv.mkDerivation {
  name = "httpshare";
  src = ./.;

  buildInputs = [bats python3 ensureNewerSourcesForZipFilesHook];

  dontPatchShebangs = true;  # Keep the portable shebang.

  buildPhase = ''
    ./make_zipapp.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp httpshare.pyz $out/bin/httpshare
  '';
}
