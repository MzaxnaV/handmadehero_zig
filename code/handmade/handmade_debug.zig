const platform = @import("handmade_platform");
const hi = platform.handmade_internal;

/// returns `END_BLOCK()` which should be called with defer
pub fn TIMED_BLOCK(comptime id: hi.debug_cycle_counter_type) *const fn () void {
    const timed_block = struct {
        fn END_BLOCK() void {
            platform.END_TIMED_BLOCK(id);
        }
    };

    platform.BEGIN_TIMED_BLOCK(id);

    // NOTE (Manav): Couldn't find any other way but to force defer by returning `END_BLOCK` function pointer.
    return timed_block.END_BLOCK;
}
