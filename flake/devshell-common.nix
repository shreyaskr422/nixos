{ pkgs }:

''
  export DEV_NIXOS_SHELL=1

  # Common shell identity
  export EDITOR=nvim
  export VISUAL=nvim

  # Keep the normal user shell
  export SHELL=${pkgs.zsh}/bin/zsh

  # Start the user's normal interactive environment
  exec ${pkgs.zsh}/bin/zsh -i
''
