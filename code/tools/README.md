# Custom tools

1. [wave generator script](./gen_wav.py). 
    - Generates 1 second sine wave 
2. [llvm-mca parser](./parse_llvm_mca.zig).
    - Generares [llvm-mca output](/misc/llvm_mca_output.txt). Assumes `llvm-mca` is available.
    - Parses it to [markdown](/misc/llvm_mca_output.md). Assumes above generation was successful.