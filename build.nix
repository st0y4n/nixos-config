let
  # This matches the Unstable channel you use locally
  unstable = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgs = import unstable {
    overlays = [ (import ./overlay.nix) ];
  };
in
{
  inherit (pkgs.kdePackages) plasma-workspace plasma-desktop;
}
