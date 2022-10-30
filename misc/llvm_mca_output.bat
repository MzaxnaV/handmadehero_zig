@echo off

pushd misc

llvm-mca -all-stats -all-views handmade.s -o llvm_mca_output.txt
zig run parse_llvm_output.zig

popd