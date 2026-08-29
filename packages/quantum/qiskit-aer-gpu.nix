{ pkgs, cudaPkgs }:

let
  aer = pkgs.python313Packages.qiskit-aer;
in
aer.overrideAttrs (old: {
  pname = "qiskit-aer-gpu";

  nativeBuildInputs = old.nativeBuildInputs ++ [
    cudaPkgs.cudaPackages.cudatoolkit
  ];

  buildInputs = old.buildInputs ++ [
    cudaPkgs.cudaPackages.cudatoolkit
  ];

  postPatch = (old.postPatch or "") + ''
    python3 - <<'PY'
    from pathlib import Path

    p = Path("CMakeLists.txt")
    lines = p.read_text().splitlines()

    marker = (
        "cuda_select_nvcc_arch_flags(AER_CUDA_ARCH_FLAGS "
        + "$"
        + "{AER_CUDA_ARCH})"
    )

    try:
        i = next(
            n for n, line in enumerate(lines)
            if line.strip() == marker
        )
    except StopIteration:
        raise SystemExit(
            "Could not find cuda_select_nvcc_arch_flags()"
        )

    end = i
    while end < len(lines):
        if "set(CMAKE_CUDA_ARCHITECTURES" in lines[end]:
            break
        end += 1

    if end >= len(lines):
        raise SystemExit(
            "Could not find CMAKE_CUDA_ARCHITECTURES line"
        )

    new_block = [
        '            if(AER_CUDA_ARCH STREQUAL "12.0")',
        '                    set(AER_CUDA_ARCH_FLAGS "-gencode arch=compute_120,code=sm_120")',
        '                    set(AER_CUDA_ARCH_FLAGS_EXPAND "-gencode arch=compute_120,code=sm_120")',
        '                    set(AER_CUDA_ARCHITECTURES "120")',
        '                    set(CMAKE_CUDA_ARCHITECTURES "120")',
        '            else()',
        *lines[i:end + 1],
        '            endif()',
    ]

    lines[i:end + 1] = new_block
    p.write_text("\n".join(lines) + "\n")
    PY
  '';

  preBuild = (old.preBuild or "") + ''
    export DISABLE_CONAN=ON
    export AER_THRUST_BACKEND=CUDA
    export AER_CUDA_ARCH=12.0
  '';
})
