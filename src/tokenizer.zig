const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize,
    };
    pub const keywords = std.ComptimeStringMap(Tag, .{
        .{ "anytype", .keyword_anytype },
        .{ "comptime", .keyword_comptime },
        .{ "else", .keyword_else },
        .{ "enum", .keyword_enum },
        .{ "fn", .keyword_fn},
        .{ "if", .keyword_if },
        .{ "lazy", .keyword_lazy },
        .{ "let", .keyword_let },
        .{ "match", .keyword_match },
        .{ "mod", .keyword_mod },
        .{ "portcullis", .keyword_portcullis },
        .{ "pub", .keyword_pub },
        .{ "run", .keyword_run },
        .{ "spawn", .keyword_spawn },
        .{ "summon", .keyword_summon },
        .{ "sketch", .keyword_sketch },
        .{ "stable", .keyword_stable },
        .{ "sunset", .keyword_sunset },
        .{ "seeyou", .keyword_seeyou },
        .{ "thread", .keyword_thread },
        .{ "url", .keyword_url},
        .{ "use", .keyword_use },
        .{ "who", .keyword_who },

    });
    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }
    pub const Tag = enum {
        builtin,
        char_literal,
        invalid,
        identifier,
        eof,
        period,
        comma,
        semicolon,
        string_literal,
        pipe,
        pipe_pipe,
        minus,
        number_literal,
        arrow,
        equal,
        equal_angle_bracket_right,
        colon,
        colon_colon,
        l_paren,
        r_paren,
        l_brace,
        r_brace,
        l_bracket,
        r_bracket,
        angle_bracket_right,
        angle_bracket_left,

        keyword_anytype,
        keyword_comptime,
        keyword_else,
        keyword_enum,
        keyword_fn,
        keyword_if,
        keyword_lazy,
        keyword_let,
        keyword_match,
        keyword_mod,
        keyword_portcullis,
        keyword_pub,
        keyword_run,
        keyword_spawn,
        keyword_summon,
        keyword_sketch,
        keyword_stable,
        keyword_sunset,
        keyword_seeyou,
        keyword_thread,
        keyword_url,
        keyword_use,
        keyword_who,
        pub fn lexeme(tag: Tag) ?[]const u8 {
            return switch (tag) {
                .builtin,
                .char_literal,
                .eof,
                .identifier,
                .invalid,
                .number_literal,
                .string_literal,
                => null,

                .comma => ",",
                .period => ".",
                .semicolon => ";",
                .pipe => "|",
                .pipe_pipe => "||",
                .minus => "-",
                .arrow => "->",
                .equal => "=",
                .equal_angle_bracket_right => "=>",
                .colon => ":",
                .colon_colon => "::",
                .l_paren => "(",
                .r_paren => ")",
                .l_brace => "{",
                .r_brace => "}",
                .l_bracket => "[",
                .r_bracket => "]",
                .angle_bracket_left => "<",
                .angle_bracket_right => ">",

                .keyword_anytype => "anytype",
                .keyword_comptime => "comptime",
                .keyword_else => "else",
                .keyword_enum => "enum",
                .keyword_fn => "fn",
                .keyword_if => "if",
                .keyword_lazy => "lazy",
                .keyword_let => "let",
                .keyword_match => "match",
                .keyword_mod => "mod",
                .keyword_portcullis => "portcullis",
                .keyword_pub => "pub",
                .keyword_run => "run",
                .keyword_spawn => "spawn",
                .keyword_summon => "summon",
                .keyword_sketch => "sketch",
                .keyword_stable => "stable",
                .keyword_sunset => "sunset",
                .keyword_seeyou => "seeyou",
                .keyword_thread => "thread",
                .keyword_url => "url",
                .keyword_use => "use",
                .keyword_who => "who",
            };
        }
        pub fn symbol(tag: Tag) []const u8 {
            return tag.lexeme() orelse switch (tag) {
                .invalid => "invalid bytes",
                .identifier => "an identifier",
                .string_literal => "a string literal",
                .char_literal => "a character literal",
                .eof => "EOF",
                .builtin => "a builtin function",
                .number_literal => "a number literal",
                else => unreachable,
            };
        }
    };

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
        pipe,
        minus,
        equal,
        colon,
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
                    '-' => {
                        state = .minus;
                    },
                    '=' => {
                        state = .equal;
                    },
                    ':' => {
                        state = .colon;
                    },
                    ',' => {
                        result.tag = .comma;
                        self.index += 1;
                        break;
                    },
                    ';' => {
                        result.tag = .semicolon;
                        self.index += 1;
                        break;
                    },
                    '.' => {
                        result.tag = .period;
                        self.index += 1;
                        break;
                    },
                    '|' => {
                        state = .pipe;
                    },
                    '{' => {
                        result.tag = .l_brace;
                        self.index += 1;
                        break;
                    },
                    '}' => {
                        result.tag = .r_brace;
                        self.index += 1;
                        break;
                    },

                    '(' => {
                        result.tag = .l_paren;
                        self.index += 1;
                        break;
                    },
                    ')' => {
                        result.tag = .r_paren;
                        self.index += 1;
                        break;
                    },
                    '[' => {
                        result.tag = .l_bracket;
                        self.index += 1;
                        break;
                    },
                    ']' => {
                        result.tag = .r_bracket;
                        self.index += 1;
                        break;
                    },
                    '<' => {
                        result.tag = .angle_bracket_left;
                        self.index += 1;
                        break;
                    },
                    '>' => {
                        result.tag = .angle_bracket_right;
                        self.index += 1;
                        break;
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
                .pipe => switch (c) {
                    '|' => {
                        result.tag = .pipe_pipe;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .pipe;
                        break;
                    },
                },
                .minus => switch (c) {
                    '>' => {
                        result.tag = .arrow;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .minus;
                        break;
                    },
                },
                .equal => switch (c) {
                    '>' => {
                        result.tag = .equal_angle_bracket_right;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .equal;
                        break;
                    },
                },
                .colon => switch (c) {
                    ':' => {
                        result.tag = .colon_colon;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .colon;
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
    try testTokenize(
    "anytype comptime else enum fn if lazy let match mod portcullis pub run spawn  summon sketch stable sunset seeyou thread use who",
    &.{
        .keyword_anytype,
        .keyword_comptime,
        .keyword_else,
        .keyword_enum,
        .keyword_fn,
        .keyword_if,
        .keyword_lazy,
        .keyword_let,
        .keyword_match,
        .keyword_mod,
        .keyword_portcullis,
        .keyword_pub,
        .keyword_run,
        .keyword_spawn,
        .keyword_summon,
        .keyword_sketch,
        .keyword_stable,
        .keyword_sunset,
        .keyword_seeyou,
        .keyword_thread,
        .keyword_use,
        .keyword_who,
    });
}

test "pipe pipe" {
    try testTokenize("| ||", &.{
        .pipe,
        .pipe_pipe,
    });
}

test "arrow minus arrow minus" {
    try testTokenize("->-->-", &.{
        .arrow,
        .minus,
        .arrow,
        .minus,
    });
}

test "equal equal equal_angle_braket_right equal" {
    try testTokenize("===>=", &.{
        .equal,
        .equal,
        .equal_angle_bracket_right,
        .equal,
    });
}

test "colon eof" {
    try testTokenize(":", &.{
        .colon,
        .eof
    });
}

test "period comma colon colon colon_colon" {
    try testTokenize(".,:; : ::", &.{
        .period,
        .comma,
        .colon,
        .semicolon,
        .colon,
        .colon_colon,
    });
}

test "l_braket r_bracket l_brace r_brace l_paren r_paren angle_bracket_left angle_bracket_right" {
    try testTokenize("[]{}()<>", &.{
        .l_bracket,
        .r_bracket,
        .l_brace,
        .r_brace,
        .l_paren,
        .r_paren,
        .angle_bracket_left,
        .angle_bracket_right,
    });
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
