# TODO pin nixpkgs version
let pkgs = import <nixpkgs> {};
in

pkgs.mkShell {
  packages = with pkgs; [
    julia
    avrdude
    pkgsCross.avr.buildPackages.gcc
    ];
}
