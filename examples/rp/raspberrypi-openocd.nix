{ stdenv, lib, openocd, makeWrapper }:
stdenv.mkDerivation {
  name = "openocd";
  buildInputs = [
    openocd
    makeWrapper
  ];
  src = openocd;
  noBuild = true;
  installPhase =
    let
      openOcdFlags = [
        "-f" "${openocd}/share/openocd/scripts/interface/stlink-v2-1.cfg"
        "-f" "${openocd}/share/openocd/scripts/target/stm32f4x.cfg"
        "-c" "init"
      ];
    in ''
      mkdir -p $out/bin
      makeWrapper ${openocd}/bin/openocd $out/bin/openocd-nucleo-f429zi \
        --add-flags "${lib.escapeShellArgs openOcdFlags}"
    '';
}
