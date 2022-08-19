let
  pkgs = import (import ./nix/sources.nix { }).nixpkgs { };
  poetry2nix-latest-src = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "1.31.0";
    hash = "sha256-0o856HWRRc5q02+vIhlIW4NpeQUDvCv3CuP1w2rZ+ho=";
  };
  poetry2nix = (import poetry2nix-latest-src { inherit pkgs; poetry = pkgs.poetry; });
  poetryOverrides = poetry2nix.overrides.withDefaults (self: super: {
      # ModuleNotFoundError: No module named 'flit_core'
      # see https://github.com/nix-community/poetry2nix/issues/218
      pyparsing = super.pyparsing.overrideAttrs (old: { buildInputs = (old.buildInputs or [ ]) ++ [ self.flit-core ]; });

      # Cannot find hatchling otherwise
      platformdirs = super.platformdirs.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ self.hatchling self.hatch-vcs ];
      });
    });
  pythonPackage = poetry2nix.mkPoetryApplication {
    projectDir = ./.;
    overrides = poetryOverrides;
    python = pkgs.python310;
  };
  pythonEnv = poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    overrides = poetryOverrides;
    python = pkgs.python310;
  };
in
{
  pythonPackages = pkgs.python310Packages;
  inherit pythonPackage;
  inherit pkgs;
  inherit pythonEnv;
}
