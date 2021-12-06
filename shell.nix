{ pkgs ? import <nixpkgs> {
    #overlays = [ (import <rust-overlay>) ];
    }
}:
with pkgs;
let
  #rust-overlay = rust-bin.nightly.latest.default.override {
  #    extensions = [ "rust-src" "llvm-tools-preview" ];
  #};
in
stdenv.mkDerivation {
  name = "sio";
  src = null;
  shellHook = ''
      export PATH=~/.cargo/bin:$PATH
  '';
  nativeBuildInputs = [
      #rust-overlay
      cargo-download
  ];
  buildInputs = [ pkgconfig ripgrep gitui nasm rustup qemu ];
}

