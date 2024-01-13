
{
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/master";
  };
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShell.x86_64-linux =
        pkgs.mkShell {

            buildInputs = with pkgs; [ gitui ripgrep rustup
            #gcc-arm-embedded probe-rs-cli
            ];
            shellHook = ''
              export PATH="$HOME/dev/paradigm/zig-bin:$PATH"
            '';
        };
   };
}
