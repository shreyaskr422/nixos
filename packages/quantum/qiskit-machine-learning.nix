{ pkgs }:

pkgs.python313Packages.qiskit-machine-learning.overrideAttrs (old: {
  meta = old.meta // {
    broken = false;
  };
})
