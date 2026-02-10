{
  description = "myapp.theor.net";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Infra tools (keep these)
            just
            docker
            sops
            age

            # TODO: Add your runtime here, e.g.:
            # bun
            # nodejs_22
            # python3
          ];

          shellHook = ''
            echo "myapp.theor.net dev shell"
            echo "Run 'just' to see available commands."
          '';
        };
      });
}
