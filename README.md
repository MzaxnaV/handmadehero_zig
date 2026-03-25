# Handmade Hero zig

Handmade Hero personal repo written in zig (0.15.2). I try to be close to what Casey does, with small changes where it makes sense to me.

For debug profiler display set `PROFILE` option to `true` in build.zig.
Custom tools on [code/tools](/code/tools).

In addition to handmade hero stuff you'll find [references](/misc/RESOURCES.md) and other things in the [misc folder](/misc/README.md).

## Style Guide

I am using a hybrid style. Broadly, I use Casey's naming where it translates naturally to Zig and Zig's conventions where Casey's style was a workaround.

| Category | Convention | Example |
|---|---|---|
| Functions | `PascalCase` | `AddLowEntity`, `SquareRoot` |
| Types / Structs / Enums | `snake_case` | `world_position`, `sim_entity` |
| Struct fields | `camelCase` | `entityIndex`, `chunkDimInMeters` |
| Variables / Parameters | `camelCase` | `gameState`, `renderGroup` |
| Constants | `SCREAMING_SNAKE` | `HANDMADE_INTERNAL`, `HIT_POINT_SUB_COUNT` |
| Enum values | `PascalCase`, **no prefix** | `entity_type.Hero`, `asset_state.Loaded` |
| Module namespace imports | `PascalCase` | `const Math = @import("handmade_math.zig")` |

## Instructions:
- Get Handmade Hero Assets and put it inside [data](/data/) folder
- Install LiberationMono-Regular.ttf
