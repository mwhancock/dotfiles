# The base shells.
#
# Every builder returns a plain mkShell. Projects add their own packages and
# shellHook on top rather than restating the toolchain, so the pinned version
# of a language lives in exactly one place.
#
# `pkgs` arrives from the consuming flake, with rust-overlay already applied
# and the consumer's nixpkgs pin in effect.
{ pkgs }:

rec {
  inherit pkgs;

  # Rust.
  #
  # The toolchain comes from rust-overlay rather than rustup, so the version is
  # pinned in the flake instead of by whatever `~/.rustup` last downloaded.
  # `rust-src` is the reason this is not just pkgs.rustc: it puts the standard
  # library source inside the toolchain's own sysroot, which is where cargo's
  # `build-std` looks for it (a Nix rustc has no cross std, and RUST_SRC_PATH
  # only helps rust-analyzer).
  mkRust =
    {
      rustVersion ? "1.99.1",
      targets ? [ ],
      extensions ? [ "rust-src" "rust-analyzer" "rustfmt" "clippy" ],
      extraPackages ? [ ],
      shellHook ? "",
    }:
    let
      toolchain = pkgs.rust-bin.stable.${rustVersion}.default.override {
        inherit extensions targets;
      };
    in
    pkgs.mkShell {
      packages = [
        toolchain
        pkgs.gcc
        pkgs.gnumake
        pkgs.pkg-config
        pkgs.openssl
      ] ++ extraPackages;

      # rustaceanvim reads this instead of looking for a rustup component.
      RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";

      shellHook = ''
        echo "rust $(rustc --version)" >&2
      '' + shellHook;
    };

  # JVM.
  #
  # JAVA_HOME is set to the shell's JDK so Gradle and the language servers use
  # the same one the project builds against.
  mkJava =
    {
      jdk ? pkgs.jdk25,
      extraPackages ? [ ],
      shellHook ? "",
    }:
    pkgs.mkShell {
      packages = [
        jdk
        pkgs.gradle_9
        pkgs.maven
      ] ++ extraPackages;

      JAVA_HOME = "${jdk}";

      shellHook = ''
        echo "java $(java -version 2>&1 | head -1)" >&2
      '' + shellHook;
    };

  # Kotlin is Java plus the compiler; Gradle drives it in practice.
  mkKotlin =
    args:
    mkJava (
      args
      // {
        extraPackages = (args.extraPackages or [ ]) ++ [ pkgs.kotlin ];
      }
    );

  # C / C++.
  #
  # mkShell already brings stdenv's compiler, so `cc` works here regardless.
  # This adds the second compiler, clangd for the editor, and the build tools.
  mkCC =
    {
      extraPackages ? [ ],
      shellHook ? "",
    }:
    pkgs.mkShell {
      packages = [
        pkgs.gcc
        pkgs.clang
        pkgs.clang-tools
        pkgs.cmake
        pkgs.gnumake
        pkgs.pkg-config
        pkgs.gdb
      ] ++ extraPackages;

      shellHook = ''
        echo "cc $(clang --version | head -1)" >&2
      '' + shellHook;
    };

  mkNode =
    {
      nodejs ? pkgs.nodejs_24,
      extraPackages ? [ ],
      shellHook ? "",
    }:
    pkgs.mkShell {
      packages = [
        nodejs
        pkgs.pnpm
        pkgs.typescript
        pkgs.typescript-language-server
      ] ++ extraPackages;

      shellHook = ''
        echo "node $(node --version)" >&2
      '' + shellHook;
    };

  mkPython =
    {
      python ? pkgs.python313,
      extraPackages ? [ ],
      shellHook ? "",
    }:
    pkgs.mkShell {
      packages = [
        python
        pkgs.uv
        pkgs.pyright
        pkgs.ruff
      ] ++ extraPackages;

      shellHook = ''
        echo "python $(${python}/bin/python --version)" >&2
      '' + shellHook;
    };
}
