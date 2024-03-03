const std = @import("std");
const msgpack = @import("msgpack");
const allocator = std.testing.allocator;
const expect = std.testing.expect;

const bufferType = std.io.FixedBufferStream([]u8);

const pack = msgpack.Pack(
    *bufferType,
    *bufferType,
    bufferType.WriteError,
    bufferType.ReadError,
    bufferType.write,
    bufferType.read,
);

test "nil write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    try p.write_nil();
    try p.read_nil();
}

test "bool write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val_1 = false;
    const test_val_2 = true;

    try p.write(test_val_1);
    try p.write(test_val_2);

    const val_1 = try p.read(bool, allocator);
    const val_2 = try p.read(bool, allocator);

    try expect(val_1 == test_val_1);
    try expect(val_2 == test_val_2);
}

test "int/uint write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    // positive fix int
    const test_val_1: u8 = 21;
    try p.write(test_val_1);
    const val_1 = try p.read(u8, allocator);
    try expect(val_1 == test_val_1);

    // negative fix int
    const test_val_2: i8 = -6;
    try p.write(test_val_2);
    const val_2 = try p.read(i8, allocator);
    try expect(val_2 == test_val_2);

    // u8
    const test_val_3: u8 = 233;
    try p.write(test_val_3);
    const val_3 = try p.read(u8, allocator);
    try expect(val_3 == test_val_3);

    // i8
    const test_val_4: i8 = -66;
    try p.write(test_val_4);
    const val_4 = try p.read(i8, allocator);
    try expect(val_4 == test_val_4);

    // u16
    const test_val_5: u16 = 0xfff;
    try p.write(test_val_5);
    const val_5 = try p.read(u16, allocator);
    try expect(val_5 == test_val_5);

    // i16
    const test_val_6: i16 = -666;
    try p.write(test_val_6);
    const val_6 = try p.read(i16, allocator);
    try expect(val_6 == test_val_6);

    // u32
    const test_val_7: u32 = 0xffff_f;
    try p.write(test_val_7);
    const val_7 = try p.read(u32, allocator);
    try expect(val_7 == test_val_7);

    // i32
    const test_val_8: i32 = 0 - 0xffff_f;
    try p.write(test_val_8);
    const val_8 = try p.read(i32, allocator);
    try expect(val_8 == test_val_8);

    // u64
    const test_val_9: u64 = 0xffff_ffff_f;
    try p.write(test_val_9);
    const val_9 = try p.read(u64, allocator);
    try expect(val_9 == test_val_9);

    // i64
    const test_val_10: i64 = 0 - 0xffff_ffff_f;
    try p.write(test_val_10);
    const val_10 = try p.read(i64, allocator);
    try expect(val_10 == test_val_10);
}

test "float write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    // f32
    const test_val_1: f32 = 3.14;
    try p.write(test_val_1);
    const val_1 = try p.read(f32, allocator);
    try expect(val_1 == test_val_1);

    // f64
    const test_val_2: f64 = 3.5e+38;
    try p.write(test_val_2);
    const val_2 = try p.read(f64, allocator);
    try expect(val_2 == test_val_2);
}

test "str write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    // fix str
    const test_str = "Hello, world!";
    try p.write(msgpack.wrapStr(test_str));
    const val_1: msgpack.Str = try p.read(msgpack.Str, allocator);
    defer allocator.free(val_1.value());
    try expect(std.mem.eql(u8, test_str, val_1.value()));

    // u8 str
    const test_str_2 = "This is a string that is more than 32 bytes long.";
    try p.write(msgpack.wrapStr(test_str_2));
    const val_2: msgpack.Str = try p.read(msgpack.Str, allocator);
    defer allocator.free(val_2.value());
    try expect(std.mem.eql(u8, test_str_2, val_2.value()));

    // u16 str
    const test_str_3 = "When the zig test tool is building a test runner, only resolved test declarations are included in the build. Initially, only the given Zig source file's top-level declarations are resolved. Unless nested containers are referenced from a top-level test declaration, nested container tests will not be resolved.";
    try p.write(msgpack.wrapStr(test_str_3));
    const val_3: msgpack.Str = try p.read(msgpack.Str, allocator);
    defer allocator.free(val_3.value());
    try expect(std.mem.eql(u8, test_str_3, val_3.value()));

    // NOTE: maybe we should add u32 str test
}

// In fact, the logic implemented by bin and str is basically the same
test "bin write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    // u8 bin
    var test_bin_1 = "This is a string that is more than 32 bytes long.".*;
    try p.write(msgpack.wrapBin(&test_bin_1));
    const val_1: msgpack.Bin = try p.read(msgpack.Bin, allocator);
    defer allocator.free(val_1.value());
    try expect(std.mem.eql(u8, &test_bin_1, val_1.value()));

    // u16 bin
    var test_bin_2 = "When the zig test tool is building a test runner, only resolved test declarations are included in the build. Initially, only the given Zig source file's top-level declarations are resolved. Unless nested containers are referenced from a top-level test declaration, nested container tests will not be resolved.".*;
    try p.write(msgpack.wrapBin(&test_bin_2));
    const val_2: msgpack.Bin = try p.read(msgpack.Bin, allocator);
    defer allocator.free(val_2.value());
    try expect(std.mem.eql(u8, &test_bin_2, val_2.value()));

    // u32 bin
    var test_bin_3 = @as([16:0]u8, "0123456789564562".*) ** (0xfff * 2);
    try p.write_bin(msgpack.wrapBin(@constCast(&test_bin_3)));
    const val_3: msgpack.Bin = try p.read(msgpack.Bin, allocator);
    defer allocator.free(val_3.value());
    try expect(std.mem.eql(u8, &test_bin_3, val_3.value()));
}

test "map write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const other_type = struct { kk: i8 };
    const test_type = struct { id: u8, bo: bool, float: f32, str: msgpack.Str, bin: msgpack.Bin, ss: other_type, arr: []u8 };

    const str = "hello";
    var bin = [5]u8{ 1, 2, 3, 4, 5 };
    var kkk = [5]u8{ 1, 2, 3, 4, 5 };

    const test_val = test_type{
        .id = 16,
        .bo = true,
        .float = 3.14,
        .str = msgpack.wrapStr(str),
        .bin = msgpack.wrapBin(&bin),
        .ss = .{ .kk = -5 },
        .arr = &kkk,
    };

    try p.write(test_val);
    const val = try p.read(test_type, allocator);
    defer allocator.free(val.str.value());
    defer allocator.free(val.bin.value());
    defer allocator.free(val.arr);
    try expect(std.meta.eql(val.ss, test_val.ss));
    try expect(std.mem.eql(u8, val.str.value(), test_val.str.value()));
    try expect(std.mem.eql(u8, val.bin.value(), test_val.bin.value()));
    try expect(std.mem.eql(u8, val.arr, test_val.arr));
    try expect(val.id == test_val.id);
    try expect(val.bo == test_val.bo);
    try expect(val.float == test_val.float);
}

test "slice write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val = [5]u8{ 1, 2, 3, 4, 5 };

    try p.write(&test_val);
    const val = try p.read([]u8, allocator);
    defer allocator.free(val);
    try expect(std.mem.eql(u8, &test_val, val));
}

test "array write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val = [5]u8{ 1, 2, 3, 4, 5 };

    try p.write(&test_val);
    const val: [5]u8 = try p.readNoAlloc([5]u8);
    try expect(std.mem.eql(u8, &test_val, &val));
}

test "tuple write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const tuple = struct { u8, u8 };
    const test_val = tuple{ 1, 2 };

    try p.write_tuple(tuple, test_val);
    const val = try p.read_tuple(tuple, allocator);
    try expect(std.meta.eql(val, test_val));
}

test "enum write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_enum = enum { A, B, C, D };

    try p.write(test_enum.A);
    const val: test_enum = try p.read(test_enum, allocator);
    try expect(val == test_enum.A);
}

test "ext write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    var test_data = [5]u8{ 1, 2, 3, 4, 5 };
    const test_type: u8 = 1;

    try p.write(msgpack.EXT{ .type = test_type, .data = &test_data });
    const val: msgpack.EXT = try p.read(msgpack.EXT, allocator);
    defer allocator.free(val.data);
    try expect(std.mem.eql(u8, &test_data, val.data));
    try expect(test_type == val.type);
}

test "write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val = [5]u8{ 1, 2, 3, 4, 5 };

    try p.write(&test_val);
    const val = try p.read([]u8, allocator);

    defer allocator.free(val);
    try expect(std.mem.eql(u8, &test_val, val));
}

test "void type" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    try p.write(void{});
    try p.read(void, allocator);

    try expect(arr[0] == 0xc0 and arr[1] == 0);
}

test "optional type write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val: ?u8 = null;

    try p.write(test_val);
    const val = try p.read(?u8, allocator);

    try expect(val == test_val);
}

test "skip" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    try p.write(1);
    try p.write(msgpack.wrapStr("test"));
    try p.write(true);

    try p.skip();
    try p.skip();
    try p.skip();
}

test "dynamic array write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_arr = [4]u16{ 15, 16, 17, 18 };

    const arraywriter = try p.getArrayWriter(4);
    for (test_arr) |value| {
        try arraywriter.write_element(value);
    }

    const arrayreader = try p.getArrayReader();
    try expect(arrayreader.len == arraywriter.len);
    for (0..arrayreader.len) |i| {
        const ele = try arrayreader.read_element_no_alloc(u16);
        try expect(ele == test_arr[i]);
    }
}

test "dynamic map write and read" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const key_1 = "key1";
    const key_2 = "key2";
    const val_1: u8 = 56;
    const val_2 = "val2";

    const mapwriter = try p.getMapWriter(2);
    try mapwriter.write(msgpack.wrapStr(key_1), val_1);
    try mapwriter.write(msgpack.wrapStr(key_2), msgpack.wrapStr(val_2));

    const mapreader = try p.getMapReader();

    try expect(mapreader.len == mapwriter.len);

    const read_key_1 = try mapreader.read_key(allocator);
    defer allocator.free(read_key_1.value());
    try expect(std.mem.eql(u8, key_1, read_key_1.value()));

    const read_val_1 = try mapreader.read_no_alloc(u8);
    try expect(val_1 == read_val_1);

    const read_key_2 = try mapreader.read_key(allocator);
    defer allocator.free(read_key_2.value());
    try expect(std.mem.eql(u8, key_2, read_key_2.value()));

    const read_val_2 = try mapreader.read(msgpack.Str, allocator);
    defer allocator.free(read_val_2.value());
    try expect(std.mem.eql(u8, val_2, read_val_2.value()));
}

test "write payload of nil" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    try p.write_nil();

    const payload = try p.read_payload(allocator);
    try expect(payload == .nil);
}

test "read payload of nil" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const val = msgpack.Payload{
        .nil = void{},
    };
    try p.write(val);

    const payload = try p.read(msgpack.Payload, allocator);
    try expect(payload == .nil);
}

test "read payload of bool" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val_1 = false;
    const test_val_2 = true;

    try p.write(test_val_1);
    try p.write(test_val_2);

    const val_1 = try p.read_payload(allocator);
    const val_2 = try p.read_payload(allocator);

    try expect(val_1 == .bool);
    try expect(val_2 == .bool);

    try expect(val_1.bool == test_val_1);
    try expect(val_2.bool == test_val_2);
}

test "read payload of int" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val: i64 = 0 - 0xffff_ffff_f;
    try p.write(test_val);
    const val = try p.read_payload(allocator);

    try expect(val == .int);
    try expect(val.int == test_val);
}

test "read payload of uint" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val: u64 = 0xffff_ffff_f;
    try p.write(test_val);
    const val = try p.read_payload(allocator);

    try expect(val == .uint);
    try expect(val.uint == test_val);
}

test "read payload of float" {
    var arr: [0xffff_f]u8 = std.mem.zeroes([0xffff_f]u8);
    var write_buffer = std.io.fixedBufferStream(&arr);
    var read_buffer = std.io.fixedBufferStream(&arr);
    var p = pack.init(
        &write_buffer,
        &read_buffer,
    );

    const test_val: f64 = 3.5e+38;
    try p.write(test_val);
    const val = try p.read_payload(allocator);

    try expect(val == .float);
    try expect(val.float == test_val);
}

// TODO: should add more test for payload
