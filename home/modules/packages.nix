{ pkgs, inputs, ... }:

let
  unstable-pkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in

{
  home.packages = with pkgs; [
    gcc
    gnumake
    rustup
    lua
    luarocks
    glib
    fd
    ripgrep
    jq
    tree
    ncdu
    unzip
    curl
    wget
    lazygit
    pkg-config
    dbeaver-bin
    easyeffects
    firefox
    wezterm
    rofi
    grim
    slurp
    mpv
    fastfetch
    pavucontrol
    zathura
    ungoogled-chromium
    swayimg
    ayugram-desktop
    selectdefaultapplication
    nwg-look
    wlogout
    nautilus
    tmux
    wmenu
    texliveFull
    texlab
    xdotool
    psmisc
    neovim
    imagemagick
    dialog
    optipng
    powertop
    nvd
    feh
    localsend
    brightnessctl
    clipmenu
    clipnotify
    xclip
    maim
    slop
    nsxiv
    playerctl
    mako
    cliphist
    libsForQt5.qt5ct 
    qt6Packages.qt6ct 
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    unstable-pkgs.brave-origin
  ];
}
