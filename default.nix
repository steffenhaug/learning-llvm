let
    pkgs      = import <nixpkgs> { };
    # https://ryantm.github.io/nixpkgs/languages-frameworks/ocaml/
    ocamlpkgs = pkgs.ocaml-ng.ocamlPackages_5_1;
in
pkgs.stdenv.mkDerivation {
    name = "ml-llvm";
    src  = ./.;

    buildInputs = [
        ocamlpkgs.ocaml
        ocamlpkgs.dune_3
        ocamlpkgs.findlib

        ocamlpkgs.utop
        ocamlpkgs.odoc
        ocamlpkgs.ocaml-lsp
        ocamlpkgs.ocamlformat

        pkgs.libllvm
        ocamlpkgs.llvm
    ];

    buildPhase= ''
      dune build
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp _build/install/default/bin/llvmtest $out/bin/
    '';
}