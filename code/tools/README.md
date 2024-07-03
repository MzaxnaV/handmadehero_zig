# Custom tools

1. [wave generator script](./gen_wav.py)
    - Generates 1 second sine wave.
    - Run `zig build gen_wav --summary all`.
2. [llvm-mca parser](./parse_llvm_mca.zig)
    - Runs `llvm-mca` is available.
    - Parses the output to [markdown](/misc/llvm_mca_output.md), assumes above generation was successful.
    - Run `zig build parse_llvm_mca --summary all`.