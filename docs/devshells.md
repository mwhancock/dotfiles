# Project development environments

How this machine handles per-project toolchains: shared "master" shells in
`~/dotfiles/devshells`, a small `flake.nix` in each project that imports one,
and direnv (`use flake`, via nix-direnv) to load it on `cd`.

The short version of the philosophy: a compiler is part of a project, not part
of the computer. The machine provides hardware, services and an editor; the
project provides the tools that build it.

## The three scopes

| Scope | Owns | Where it lives | How it lands |
| --- | --- | --- | --- |
| Machine | drivers, udev rules, services, shell, terminal, editor, fonts | `/etc/nixos` | `nixos-rebuild switch` |
| Project | compilers, SDKs, linters, formatters, flashers, test tools | `<project>/flake.nix` | `cd` into it (direnv) |
| One-off | "I need `jq` for one command" | nowhere | `nix shell nixpkgs#jq` |

Use the tightest scope that works:

- If forgetting it would break boot, a device, or the login shell: **machine**.
- If forgetting it would break a build, a test or a flashing step: **project**.
- If you only need it for the next few minutes: **one-off**.

Nothing language-shaped belongs on the machine. `rustup`, `npm install -g`,
`pip install --user` and distro packages are all ways of putting a project tool
in the machine scope, which is exactly what this setup avoids.

## Anatomy of a project environment

A project shell is three small files:

```
project/
  flake.nix     # which toolchain, pinned to an exact nixpkgs
  flake.lock    # the resolved pins; commit this
  .envrc        # one line: use flake
```

`.envrc` activates on `cd` and unloads on the way out. `direnv allow` is
required once per checkout (and again whenever `.envrc` changes).

`flake.lock` is not optional: it is what makes the environment the same on
every machine and every week. Commit it.

## Starting a new project

Pick the builder you need and paste this into `flake.nix`, then:

```bash
echo 'use flake' > .envrc
direnv allow
git add flake.nix flake.lock .envrc   # required: Nix ignores untracked files
```

`cd` out and back in; the shell loads (first time a few seconds, then cached).

### Template

```nix
{
  description = "myproject";

  inputs = {
    # The pin. `nix flake update` moves it deliberately; the lockfile is what
    # everyone else builds.
    nixpkgs.url = "github:NixOS/nixpkgs/1d060086d60cb76a40cf37109f979d88a5bd6396";

    # The shared masters. `follows` keeps the pin above authoritative: the
    # builders run against this nixpkgs, but their definitions live in
    # ~/dotfiles/devshells.
    devshells = {
      url = "path:/home/mark/dotfiles/devshells";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { devshells, ... }:
    let
      system = "x86_64-linux";
      lib = devshells.lib.${system};
    in
    {
      devShells.${system}.default = lib.mkRust {
        # Cross targets pull their std source into the sysroot, which is what
        # `cargo build` with build-std needs.
        targets = [ ];
        extraPackages = with lib.pkgs; [ ];
        shellHook = ''
          echo "--- myproject environment ---" >&2
        '';
      };
    };
}
```

Swap `mkRust` for whichever builder fits. Two projects can share one flake.

## The masters

| Builder | Brings | Tunables |
| --- | --- | --- |
| `mkRust` | rust-overlay stable 1.99.1 (with `rust-src`), gcc, gnumake, pkg-config, openssl, `RUST_SRC_PATH` | `rustVersion`, `targets`, `extensions`, `extraPackages`, `shellHook` |
| `mkJava` | `jdk25`, `gradle_9`, `maven`, `JAVA_HOME` | `jdk`, `extraPackages`, `shellHook` |
| `mkKotlin` | `mkJava` + `kotlin` | same as `mkJava` |
| `mkCC` | gcc, clang, clang-tools, cmake, gnumake, pkg-config, gdb | `extraPackages`, `shellHook` |
| `mkNode` | node 24, pnpm, typescript, typescript-language-server | `nodejs`, `extraPackages`, `shellHook` |
| `mkPython` | python 3.13, uv, pyright, ruff | `python`, `extraPackages`, `shellHook` |

Every builder returns a plain `mkShell`, so `pkgs` is reachable as `lib.pkgs`
for anything project-specific. A shell can also be run without a project:

```bash
nix develop ~/dotfiles/devshells#rust
nix develop ~/dotfiles/devshells#python
```

## Extending a shell

Three levels, in order of preference:

**1. Extra packages** — the normal case.

```nix
lib.mkRust {
  extraPackages = with lib.pkgs; [ probe-rs-tools espflash ];
}
```

**2. `overrideAttrs`** — patch what the master returns, without restating it.
This is how a shell adds runtime environment that `mkShell` does not model:

```nix
base = lib.mkJava { extraPackages = runtimeLibs; };
in
{
  devShells.${system}.default = base.overrideAttrs (_: {
    LD_LIBRARY_PATH = lib.pkgs.lib.makeLibraryPath runtimeLibs
      + ":/run/opengl-driver/lib";
  });
}
```

**3. A local `mkShell`** — only when the project genuinely shares nothing with
a master (a one-off tool, a non-language project). Even then, depend on
`lib.pkgs` so it builds against the project's own pin.

Prefer `extraPackages` for applications and libraries a *build* needs.
`LD_LIBRARY_PATH` is only for things that `dlopen()` by bare soname at runtime
(GTK, Skiko, OpenGL, ALSA), because those ignore RPATH.

## Changing the masters

`~/dotfiles/devshells` is a flake, and the input is `path:...`, which is
**snapshotted into `flake.lock` when the project locks it**. That is what makes
a project reproducible: a refactor here cannot silently change a submitted
project's environment. It also means edits are not automatic.

```bash
$EDITOR ~/dotfiles/devshells/lib/default.nix
nix develop ~/dotfiles/devshells#rust          # check the master on its own

cd ~/src/projA && nix flake update devshells   # opt this project in
cd ~/src/projB && nix flake update devshells
```

`git diff flake.lock` shows exactly when each project moved. Bump the version
in `~/dotfiles/devshells/flake.lock` with `nix flake update` there if the
masters themselves need newer nixpkgs, but note that consumers ignore it — they
always use *their own* nixpkgs pin.

## Keeping things current

| Command | Effect |
| --- | --- |
| `nix flake update` | move all inputs; inspect the `flake.lock` diff |
| `nix flake update nixpkgs` | move just the package set |
| `nix flake update devshells` | pick up local edits to the masters |
| `nix flake metadata` | print where the pins currently point |
| `nix flake check` | evaluate `checks`/`packages` (if the project defines them) |
| `direnv reload` | force a re-evaluation after edits |

Typical rhythm: edit code, commit. When you feel like it, `nix flake update`,
run the build and tests, commit the lockfile separately (`chore: update flake
inputs`) so the bump is easy to revert.

## How it works under the hood

```
cd project
  -> direnv runs .envrc (use flake)
     -> nix-direnv evaluates the flake, builds a profile in .direnv/
        -> on later entries it just activates the cached profile (~0.2s)
           -> watching flake.nix / flake.lock invalidates the cache
```

- `.direnv/` is generated and must be gitignored (it is, in every project here).
- `direnv allow` stores a hash of `.envrc`; changing it asks again. That is a
  safety feature, not a nuisance.
- The environment is loaded as a *profile*, so `command -v rustc` points into
  `/nix/store` and disappears when you `cd` out. Nothing is "installed".

## Where things actually live

| Thing | Belongs on | Why |
| --- | --- | --- |
| rustc, cargo, jdk, node, python, clang | project shell | version is a build decision |
| ESP32 udev rules / probe access | machine (`modules/hardware/probes.nix`) | kernel and device layer |
| `LD_LIBRARY_PATH` for GTK/Skiko/GL | project shell | it is that application's runtime |
| Mesa / GPU userspace | machine (`/run/opengl-driver/lib`) | must match the running kernel module |
| nvim, fish, starship, direnv | machine | used everywhere, not per build |
| `gcc` for nvim-treesitter parsers | machine (nixarchy `languageServer`) | editor tooling, not a project |
| a script's `python3` | machine | Omarchy/desktop scripting runtime |
| `jq` for one command | `nix shell nixpkgs#jq` | not worth a file |

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `direnv: error ... is blocked` | `.envrc` not allowed, or changed | `direnv allow` |
| Shell does nothing on `cd` | direnv hook not loaded | `direnv hook fish \| source`, check `config.fish` |
| `error: flake ... does not provide attribute` | `flake.nix` untracked in a git repo | `git add flake.nix flake.lock` |
| Master edits have no effect | `path:` input still points at the old snapshot | `nix flake update devshells` |
| `cannot open shared object file` | runtime `dlopen`, not an RPATH problem | add the lib to `LD_LIBRARY_PATH` via `overrideAttrs` |
| `command not found` inside the shell | package not in this shell's `packages` | add to `extraPackages` |
| `rust-src` missing / `build-std` fails | toolchain not from rust-overlay | use `mkRust`, do not add `pkgs.rustc` by hand |
| Gradle picks the wrong JDK | `JAVA_HOME` overridden | delete the override; `mkJava` sets it |
| Second `cd` is slow | nix-direnv not sourced | `~/.config/direnv/direnvrc` must source nix-direnv |

## Cheatsheet

```bash
# new project
cp /some/template/flake.nix . && echo 'use flake' > .envrc && direnv allow

# what is this shell giving me?
nix develop --command sh -c 'command -v rustc; echo $JAVA_HOME'

# try a tool without touching the project
nix shell nixpkgs#hyperfine

# move a project's pins
nix flake update
nix flake update devshells

# see what is locked
nix flake metadata
```
