{ pkgs }:
let
  version = with builtins; with fromJSON (readFile src/httpshare/version.json);
    "${toString major}.${toString minor}.${toString patch}"
      + (if suffix != "" then "-${suffix}" else "");
  pyz = pkgs.callPackage ({ bats, curl, git, stdenv, python3, ensureNewerSourcesForZipFilesHook }:
    stdenv.mkDerivation {
      pname = "httpshare.pyz";
      inherit version;
      src = ./.;

      buildInputs = [python3 ensureNewerSourcesForZipFilesHook];

      dontPatchShebangs = true;  # Keep the portable shebang.

      buildPhase = ''
        ${python3}/bin/python make_zipapp.py
      '';

      checkInputs = [bats curl git];
      doCheck = true;

      checkPhase = ''
        # test.bats call make_zipapp.py, which we don't want.
        echo "#!/bin/sh" >make_zipapp.py
        env MODE=release bats test.bats
      '';

      installPhase = ''
        cp httpshare.pyz $out
      '';
    }) {};
in
pkgs.callPackage ({ stdenv, python, makeWrapper }:
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

    buildInputs = [python makeWrapper];

    phases = "installPhase";
    inherit pyz;
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${python}/bin/python $out/bin/httpshare --add-flags $pyz
    '';
  }) {}
