{
  description = "Shared base development shells for this machine";

  # Each project imports this directory as an input:
  #
  #   inputs.devshells = {
  #     url = "path:/home/mark/dotfiles/devshells";
  #     inputs.nixpkgs.follows = "nixpkgs";
  #   };
  #
  # and then calls the builder it needs. The `follows` is what keeps the
  # project's own nixpkgs pin authoritative: the builders run against it, while
  # the shell definitions live here.
  #
  # A `path:` input is copied at lock time, which is what makes builds
  # reproducible but also means edits here are not instant. After changing
  # anything, move each consumer forward with:
  #
  #   nix flake update devshells
  #
  # The nixpkgs rev below only matters when this flake is evaluated on its own
  # (nix develop ~/dotfiles/devshells#rust); consumers override it.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/1d060086d60cb76a40cf37109f979d88a5bd6396";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, rust-overlay, ... }:
    let
      systems = [ "x86_64-linux" ];
      each = f: nixpkgs.lib.genAttrs systems f;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
    in
    {
      lib = each (system: import ./lib { pkgs = pkgsFor system; });

      # Handy for a one-off shell with no project attached:
      #   nix develop ~/dotfiles/devshells#cc
      devShells = each (system: {
        rust = self.lib.${system}.mkRust { };
        java = self.lib.${system}.mkJava { };
        kotlin = self.lib.${system}.mkKotlin { };
        cc = self.lib.${system}.mkCC { };
        node = self.lib.${system}.mkNode { };
        python = self.lib.${system}.mkPython { };
      });
    };
}
