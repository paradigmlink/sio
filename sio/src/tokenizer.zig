const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize,
    };
    pub const keywords = std.ComptimeStringMap(Tag, .{
        .{ "if", .keyword_if },
        .{ "else", .keyword_else },
    });
    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }
    pub const Tag = enum {
        invalid,
        identifier,
        eof,
        keyword_if,
        keyword_else,
    };
    pub fn lexeme(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .keyword_if => "if",
            .keyword_else => "else",
        };
    }
    pub fn symbol(tag: Tag) []const u8 {
        return tag.lexeme() orelse switch (tag) {
            .string_literal => "a string literal",
            else => unreachable,
        };
    }
};

pub const Tokenizer = struct {
    buffer: [:0]const u8,
    index: usize,
    pending_invalid_token: ?Token,

    pub fn dump(self: *Tokenizer, token: *const Token) void {
        std.debug.print("{s} \"{s}\"\n", .{@tagName(token.tag), self.buffer[token.loc.start..token.loc.end] });
    }
    pub fn init(buffer: [:0]const u8) Tokenizer {
        const src_start: usize = if (std.mem.startsWith(u8, buffer, "\xEF\xBB\xBF")) 3 else 0;
        return Tokenizer {
            .buffer = buffer,
            .index = src_start,
            .pending_invalid_token = null,
        };
    }
    const State = enum {
        start,
        identifier,
    };
    pub fn findTagAtCurrentIndex(self: *Tokenizer, tag: Token.Tag) Token {
        if (tag == .invalid) {
            const target_index = self.index;
            var starting_index = target_index;
            while (starting_index > 0) {
                if (self.buffer[starting_index] == '\n') {
                    break;
                }
                starting_index -= 1;
            }
            self.index = starting_index;
            while (self.index <= target_index or self.pending_invalid_token != null) {
                const result = self.next();
                if (result.loc.start == target_index and result.tag == tag) {
                    return result;
                }
            }
            unreachable;
        } else {
            return self.next();
        }
    }
    pub fn next(self: *Tokenizer) Token {
        if (self.pending_invalid_token) |token| {
            self.pending_invalid_token = null;
            return token;
        }
        var state: State = .start;
        var result = Token {
            .tag = .eof,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
        };
        //var seen_escape_digits: usize = undefined;
        //var remaining_code_units: usize = undefined;
        while (true) : (self.index += 1) {
            const c = self.buffer[self.index];
            switch (state) {
                .start => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            result.tag = .invalid;
                            result.loc.start = self.index;
                            self.index += 1;
                            result.loc.end = self.index;
                            return result;
                        }
                        break;
                    },
                    ' ', '\n', '\t', '\r' => {
                        result.loc.start = self.index + 1;
                    },
                    'a'...'z', 'A'...'Z', '_' => {
                        state = .identifier;
                        result.tag = .identifier;
                    },
                    else => {
                        result.tag = .invalid;
                        result.loc.end = self.index;
                        self.index += 1;
                        return result;
                    }
                },
                .identifier => switch (c) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => {},
                    else => {
                        if (Token.getKeyword(self.buffer[result.loc.start..self.index])) |tag| {
                            result.tag = tag;
                        }
                        break;
                    },
                },
            }
        }
        if (result.tag == .eof) {
            if (self.pending_invalid_token) |token| {
                self.pending_invalid_token = null;
                return token;
            }
            result.loc.start = self.index;
        }
        result.loc.end = self.index;
        return result;
    }
};

test "keywords" {
    try testTokenize("if else", &.{.keyword_if, .keyword_else});
}

pub fn testTokenize(source: [:0]const u8, expected_token_tags: []const Token.Tag) !void {
    var tokenizer = Tokenizer.init(source);
    for (expected_token_tags) |expected_token_tag| {
        const token = tokenizer.next();
        try std.testing.expectEqual(expected_token_tag, token.tag);
    }
    const last_token = tokenizer.next();
    try std.testing.expectEqual(Token.Tag.eof, last_token.tag);
    try std.testing.expectEqual(source.len, last_token.loc.start);
    try std.testing.expectEqual(source.len, last_token.loc.end);
}
