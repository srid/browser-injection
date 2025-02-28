{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    npmlock2nix = {
      url = "github:nix-community/npmlock2nix";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };
    in
    {
      packages.x86_64-linux.inject-browser =
        pkgs.runCommand
          "esbuild"
          { nativeBuildInputs = [ pkgs.esbuild ]; } ''
          cp ${./main.js} entrypoint.js
          mkdir -p $out
          export NODE_PATH=${(npmlock2nix.node_modules { src = ./.; }) + /node_modules}
          esbuild --bundle --outfile="$out/main.js" --log-limit=0 entrypoint.js
        '';
    };
}
