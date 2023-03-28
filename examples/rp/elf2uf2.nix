{ lib, stdenv, rustPlatform, fetchFromGitHub, pkg-config, libudev }:

rustPlatform.buildRustPackage rec {
  pname = "elf2uf2-rs";
  version = "91ae98873ed01971ab1543b98266a5ad2ec09210";

  src = fetchFromGitHub {
    owner = "JoNil";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-DGrT+YdDLdTYy5SWcQ+DNbpifGjrF8UTXyEeE/ug564=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libudev
  ];

  cargoSha256 = "sha256-4xaZmRP/E2+SFhJmkNxe6dWgWlujmGhxQGR29s4109c=";
}
