{ pkgs }:
let
  version = with builtins; with fromJSON (readFile src/httpshare/version.json);
    "${toString major}.${toString minor}.${toString patch}"
      + (if suffix != "" then "-${suffix}" else "");
  pyz = pkgs.callPackage ({ stdenv, python3, ensureNewerSourcesForZipFilesHook }:
    stdenv.mkDerivation {
      pname = "httpshare.pyz";
      inherit version;

      src = ./.;

      buildInputs = [python3 ensureNewerSourcesForZipFilesHook];

      dontPatchShebangs = true;  # Keep the portable shebang.

      buildPhase = ''
        ${python3}/bin/python make_zipapp.py
      '';

      installPhase = ''
        cp httpshare.pyz $out
      '';
    }) {};
in
pkgs.callPackage ({ stdenv, python, makeWrapper, bats, curl }:
  stdenv.mkDerivation {
    pname = "httpshare";
    inherit version;

    meta = with stdenv.lib; {
      description = "A file transfer utility using an ephemeral HTTP service";
      license = licenses.zlib;
      homepage = https://github.com/lourkeur/httpshare;
      maintainers = [{
        name = "Louis Bettens";
        email = "louis@bettens.info";
        github = "lourkeur";
      }];
    };

    inherit pyz;
    src = ./.;

    buildInputs = [python makeWrapper];

    checkInputs = [bats curl];
    doCheck = true;
    checkPhase = ''
      cp $pyz httpshare.pyz
      env MODE=release bats test.bats
    '';

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${python}/bin/python $out/bin/httpshare --add-flags $pyz
    '';
  }) {}
