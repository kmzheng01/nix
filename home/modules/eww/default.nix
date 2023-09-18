{ pkgs, config, ...}:

let
  # Fix werid script thing
  scriptDir = builtins.dirOf ../../../dots/eww/scripts/battery;
  configDir = pkgs.substituteAllFiles {
    src = ../../../dots/eww;
    files = [
      "eww.scss"
      "eww.yuck"
      "nixos-icon.svg"
    ];
    base00 = "#${config.colorScheme.colors.base00}";
    base03 = "#${config.colorScheme.colors.base03}";
    base0C = "#${config.colorScheme.colors.base0C}";
    scriptdir = "${scriptDir}";
  };
in
{
  programs.eww = {
    enable = true;
    configDir = configDir.out;
  };
}