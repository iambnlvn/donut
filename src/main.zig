const std = @import("std");
const cos = std.math.cos;
const sin = std.math.sin;

pub fn main() void {
    var A: f32 = 0;
    var B: f32 = 0;
    var z: [4000]f32 = undefined;
    var b: [4000]u8 = undefined;
    const dPi = std.math.pi * 2;
    const symbols = ".,-~:;=!*#$@%&?<>[]{}";
    const width = 80;
    const height = 30;
    const cursor2homePos = "\x1b[H";
    const escapeClearScreen = "\x1b[2J";

    const Color = struct {
        Red: []const u8 = "\x1b[31m",
        Green: []const u8 = "\x1b[32m",
        Yellow: []const u8 = "\x1b[33m",
        Blue: []const u8 = "\x1b[34m",
        Reset: []const u8 = "\x1b[0m",
    };

    std.debug.print(escapeClearScreen, .{});

    while (true) {
        @memset(&z, 0);
        @memset(&b, 32);

        const cosA = cos(A);
        const sinA = sin(A);
        const cosB = cos(B);
        const sinB = sin(B);

        var j: f32 = 0;
        while (j < dPi) : (j += 0.07) {
            const cosJ = cos(j);
            const sinJ = sin(j);
            const h = cosJ + 2;
            const hSinA = h * sinA;

            var i: f32 = 0;
            while (i < dPi) : (i += 0.03) {
                const cosI = cos(i);
                const sinI = sin(i);
                const cosIhCosB = cosI * h * cosB;
                const t = (sinI * h * cosA) - (sinJ * sinA);
                const D: f32 = 1 / (sinI * hSinA + sinJ * cosA + 5);
                const x: i32 = @intFromFloat(40 + 30 * D * (cosIhCosB - t * sinB));
                const y: i32 = @intFromFloat(12 + 15 * D * (cosI * h * sinB + t * cosB));
                if (y >= 0 and y < height and x >= 0 and x < width) {
                    const O = @as(u32, @intCast(x + width * y));
                    if (D > z[O]) {
                        z[O] = D;
                        const N: i32 = @intFromFloat(8 * ((sinJ * sinA - sinI * cosJ * cosA) * cosB - sinI * cosJ * sinA - sinJ * cosA - cosI * cosJ * sinB));
                        b[O] = symbols[@as(u32, @intCast(if (N > 0) N else 0))];
                    }
                }
            }
        }

        std.debug.print(cursor2homePos, .{});

        var k: i32 = 0;
        var rng = std.rand.DefaultPrng.init(@as(u64, @intCast(std.time.nanoTimestamp())));

        const color = Color{};
        const colors = [_][]const u8{
            color.Red,
            color.Green,
            color.Yellow,
            color.Blue,
        };
        const idx = rng.random().int(usize) % 4;

        while (k < 1761) : (k += 1) {
            if (@rem(k, width) != 0) {
                std.debug.print("{s}{c}", .{ colors[idx], b[@as(u32, @intCast(k))] });
            } else {
                std.debug.print("{s}{c}", .{ color.Green, 10 });
            }
            A += 0.00004;
            B += 0.00002;
        }
        std.time.sleep(40000000);
    }
}
