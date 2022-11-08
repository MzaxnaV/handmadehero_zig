# Handmade Hero zig

Handmade Hero personal repo written in zig (0.10.0, -fstage1). I try to be close to what Casey does, with small changes where it makes sense and it better organizes the code overall.

In addition to handmade hero stuff you'll find [references](/misc/REFERENCES.md) and other things in the [misc folder](/misc/).

# Debugging zig in vscode (cppvsdbg)
Set `debug.allowBreakpointsEverywhere` to `true` in vscode settings so you can add breakpoints by clicking on the [editor margin](https://code.visualstudio.com/docs/editor/debugging#_breakpoints). 

- [Function breakpoints](https://code.visualstudio.com/docs/editor/debugging#_function-breakpoints) work but some functions can't be added by just their name. When you `@import` zig source files, they are implicitly added as structs, with a name equal to the file's basename so add the file name before function names for those to work. For instance, `handmade_sim_region.MoveEntity` should work.

- To view disassembly while debugging, switch to C++ using language select mode(bottom right corner on the status bar) momentarily, right click to open disassembly and then switch back to zig.

- Can't add inline functions obviously as they are inlined :D.