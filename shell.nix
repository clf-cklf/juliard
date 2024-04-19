# FIXME this is probably not needed
#let pkgs = import /home/chris/gt/nixpkgs {};
let pkgs = import <nixpkgs> {};
in

pkgs.mkShell {
  packages = with pkgs; [
    julia
    avrdude
    pkgsCross.avr.buildPackages.gcc
    ];
}
