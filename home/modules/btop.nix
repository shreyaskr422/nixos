{ config, pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = (pkgs.btop.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      makeFlags = (oldAttrs.makeFlags or []) ++ [ "GPU_SUPPORT=true" ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/btop \
          --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${pkgs.rocmPackages.rocm-smi}/lib"
      '';
    }));
  };
}
