{ stdenv, bats, python3, ensureNewerSourcesForZipFilesHook, python }:
stdenv.mkDerivation {
  name = "httpshare";
  src = ./.;

  buildInputs = [bats python3 ensureNewerSourcesForZipFilesHook];
  propagatedBuildInputs = [python]; # need python (any version) for the shebang.

  dontPatchShebangs = true;  # Keep the portable shebang.

  buildPhase = ''
    ${python3}/bin/python make_zipapp.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp httpshare.pyz $out/bin/httpshare
  '';
}
