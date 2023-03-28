{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, rust-overlay, nixpkgs }:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
      };
      openocd-fix = pkgs.openocd.overrideAttrs(old: {
          version = "unstable-2022-09-01";
          src = pkgs.fetchgit {
            url = "https://github.com/raspberrypi/openocd";
            #rev = "228ede43db3665e470d2e518730de013a8c7441";
            #rev = "rp2040";
            sha256 = "sha256-WxlZ+thixAm3U0BofSRydo64nlFyqoFo2yc8N/ecLts=";
            fetchSubmodules = true;
            leaveDotGit = true;
          };
          preConfigure = ''
              ./bootstrap
          '';
          configureFlags = [
              "--enable-ftdi"
              "--enable-sysfsgpio"
              "--enable-bcm2835gpio"
              "--disable-werror"
              "--enable-jtag_vpi"
              "--enable-usb_blaster_libftdi"
              (pkgs.lib.enableFeature (! pkgs.stdenv.isDarwin) "amtjtagaccel")
              (pkgs.lib.enableFeature (! pkgs.stdenv.isDarwin) "gw16012")
              "--enable-presto_libftdi"
              "--enable-openjtag_ftdi"
              (pkgs.lib.enableFeature (! pkgs.stdenv.isDarwin) "oocd_trace")
              "--enable-buspirate"
              (pkgs.lib.enableFeature pkgs.stdenv.isLinux "sysfsgpio")
              (pkgs.lib.enableFeature pkgs.stdenv.isLinux "linuxgpiod")
              "--enable-remote-bitbang"
          ];
          nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.autoreconfHook269 pkgs.libtool pkgs.which pkgs.git ];
        });
    in
    {
      packages.x86_64-linux.openocd = openocd-fix;
      devShell.x86_64-linux = pkgs.mkShell {
        shellHook = ''
            alias run-openocd='${openocd-fix}/bin/openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -s tcl'
            export LD_LIBRARY_PATH=${pkgs.zlib}/lib
        '';
        buildInputs = [
          (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
            targets = [ "thumbv6m-none-eabi" ];
            extensions = [ "rust-src" ];
          }))
          pkgs.rust-analyzer
          pkgs.flip-link
          pkgs.probe-run
          self.packages.x86_64-linux.openocd
          pkgs.rustfmt
        ];
      };
    };
}
