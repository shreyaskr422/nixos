{config, lib, pkgs ,...}:

{
fonts = {
  packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    inter
    liberation_ttf
  ];
  fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Inter" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "DankMono Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
    hinting.style = "slight";
    subpixel.rgba = "none";
    antialias = true;
  };
};
}
