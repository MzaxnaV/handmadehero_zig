@echo off

pushd misc

llvm-mca -all-stats -all-views ../build/handmade.s -o llvm_mca_output.txt
zig run ../code/tools/parse_llvm_mca.zig

popd