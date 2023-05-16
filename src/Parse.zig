pub const Error = error{ParseError} || Allocator.Error;

gpa: Allocator,
source: []const u8,
token_tags: []const Token.Tag,
token_starts: []const Ast.ByteOffset,
tok_i: TokenIndex,
errors: std.ArrayListUnmanaged(AstError),
nodes: Ast.NodeList,
extra_data: std.ArrayListUnmanaged(Node.Index),
scratch: std.ArrayListUnmanaged(Node.Index),

const SmallSpan = union(enum) {
    zero_or_one: Node.Index,
    multi: Node.SubRange,
};

const Members = struct {
    len: usize,
    lhs: Node.Index,
    rhs: Node.Index,
    trailing: bool,

    fn toSpan(self: Members, p: *Parse) !Node.SubRange {
        if (self.len <= 2) {
            const nodes = [2]Node.Index{ self.lhs, self.rhs };
            return p.listToSpan(nodes[0..self.len]);
        } else {
            return Node.SubRange{ .start = self.lhs, .end = self.rhs };
        }
    }
};

fn listToSpan(p: *Parse, list: []const Node.Index) !Node.SubRange {
    try p.extra_data.appendSlice(p.gpa, list);
    return Node.SubRange{
        .start = @intCast(Node.Index, p.extra_data.items.len - list.len),
        .end = @intCast(Node.Index, p.extra_data.items.len),
    };
}

fn addNode(p: *Parse, elem: Ast.NodeList.Elem) Allocator.Error!Node.Index {
    const result = @intCast(Node.Index, p.nodes.len);
    try p.nodes.append(p.gpa, elem);
    return result;
}

fn setNode(p: *Parse, i: usize, elem: Ast.NodeList.Elem) Node.Index {
    p.nodes.set(i, elem);
    return @intCast(Node.Index, i);
}

fn reserveNode(p: *Parse, tag: Ast.Node.Tag) !usize {
    try p.nodes.resize(p.gpa, p.nodes.len + 1);
    p.nodes.items(.tag)[p.nodes.len - 1] = tag;
    return p.nodes.len - 1;
}

fn unreserveNode(p: *Parse, node_index: usize) void {
    if (p.nodes.len == node_index) {
        p.nodes.resize(p.gpa, p.nodes.len - 1) catch unreachable;
    } else {
        // There is zombie node left in the tree, let's make it as inoffensive as possible
        // (sadly there's no no-op node)
        p.nodes.items(.tag)[node_index] = .unreachable_literal;
        p.nodes.items(.main_token)[node_index] = p.tok_i;
    }
}

fn warnExpected(p: *Parse, expected_token: Token.Tag) error{OutOfMemory}!void {
    @setCold(true);
    try p.warnMsg(.{
        .tag = .expected_token,
        .token = p.tok_i,
        .extra = .{ .expected_tag = expected_token },
    });
}

fn warnMsg(p: *Parse, msg: Ast.Error) error{OutOfMemory}!void {
    @setCold(true);
    try p.errors.append(p.gpa, msg);
}

fn warn(p: *Parse, error_tag: AstError.Tag) error{OutOfMemory}!void {
    @setCold(true);
    try p.warnMsg(.{ .tag = error_tag, .token = p.tok_i });
}

fn fail(p: *Parse, tag: Ast.Error.Tag) error{ ParseError, OutOfMemory } {
    @setCold(true);
    return p.failMsg(.{ .tag = tag, .token = p.tok_i });
}

fn failExpected(p: *Parse, expected_token: Token.Tag) error{ ParseError, OutOfMemory } {
    @setCold(true);
    return p.failMsg(.{
        .tag = .expected_token,
        .token = p.tok_i,
        .extra = .{ .expected_tag = expected_token },
    });
}

fn failMsg(p: *Parse, msg: Ast.Error) error{ ParseError, OutOfMemory } {
    @setCold(true);
    try p.warnMsg(msg);
    return error.ParseError;
}


/// Root <- skip container_doc_comment? ContainerMembers eof
pub fn parseRoot(p: *Parse) !void {
    // Root node must be index 0.
    p.nodes.appendAssumeCapacity(.{
        .tag = .root,
        .main_token = 0,
        .data = undefined,
    });
    const root_members = try p.parseContainerMembers();
    const root_decls = try root_members.toSpan(p);
    if (p.token_tags[p.tok_i] != .eof) {
        try p.warnExpected(.eof);
    }
    p.nodes.items(.data)[0] = .{
        .lhs = root_decls.start,
        .rhs = root_decls.end,
    };
}

fn parseContainerMembers(p: *Parse) !Members {
    const scratch_top = p.scratch.items.len;
    defer p.scratch.shrinkRetainingCapacity(scratch_top);

    var field_state: union(enum) {
        /// No fields have been seen.
        none,
        /// Currently parsing fields.
        seen,
        /// Saw fields and then a declaration after them.
        /// Payload is first token of previous declaration.
        end: Node.Index,
        /// There was a declaration between fields, don't report more errors.
        err,
    } = .none;

    //var last_field: TokenIndex = undefined;
    var trailing = false;
    while (true) {
        switch (p.token_tags[p.tok_i]) {
            .keyword_pub,
            .keyword_mod => {
                const top_level_decl = try p.expectTopLevelDeclRecoverable();
                if (top_level_decl != 0) {
                    if (field_state == .seen) {
                        field_state = .{ .end = top_level_decl};
                    }
                    try p.scratch.append(p.gpa, top_level_decl);
                }
            },
            .eof => {
                break;
            },
            .builtin,
            .char_literal,
            .invalid,
            .identifier,
            .period,
            .comma,
            .semicolon,
            .string_literal,
            .pipe,
            .pipe_pipe,
            .minus,
            .number_literal,
            .arrow,
            .equal,
            .equal_angle_bracket_right,
            .colon,
            .colon_colon,
            .l_paren,
            .r_paren,
            .l_brace,
            .r_brace,
            .l_bracket,
            .r_bracket,
            .angle_bracket_right,
            .angle_bracket_left,

            .keyword_anytype,
            .keyword_comptime,
            .keyword_else,
            .keyword_enum,
            .keyword_fn,
            .keyword_if,
            .keyword_lazy,
            .keyword_let,
            .keyword_match,
            .keyword_portcullis,
            .keyword_run,
            .keyword_spawn,
            .keyword_summon,
            .keyword_sketch,
            .keyword_stable,
            .keyword_sunset,
            .keyword_seeyou,
            .keyword_thread,
            .keyword_url,
            .keyword_use,
            .keyword_who => {
                break;
            },

        }
    }
    const items = p.scratch.items[scratch_top..];
    switch (items.len) {
        0 => return Members{
            .len = 0,
            .lhs = 0,
            .rhs = 0,
            .trailing = trailing,
        },
        1 => return Members{
            .len = 1,
            .lhs = items[0],
            .rhs = 0,
            .trailing = trailing,
        },
        2 => return Members{
            .len = 2,
            .lhs = items[0],
            .rhs = items[1],
            .trailing = trailing,
        },
        else => {
            const span = try p.listToSpan(items);
            return Members{
                .len = items.len,
                .lhs = span.start,
                .rhs = span.end,
                .trailing = trailing,
            };
        },
    }

}

/// Attempts to find next container member by searching for certain tokens
fn findNextContainerMember(p: *Parse) void {
    var level: u32 = 0;
    while (true) {
        const tok = p.nextToken();
        switch (p.token_tags[tok]) {
            // Any of these can start a new top level declaration.
            .keyword_url,
            .keyword_mod,
            => {
                if (level == 0) {
                    p.tok_i -= 1;
                    return;
                }
            },
            .identifier => {
                if (p.token_tags[tok + 1] == .comma and level == 0) {
                    p.tok_i -= 1;
                    return;
                }
            },
            .comma, .semicolon => {
                // this decl was likely meant to end here
                if (level == 0) {
                    return;
                }
            },
            .l_paren, .l_bracket, .l_brace => level += 1,
            .r_paren, .r_bracket => {
                if (level != 0) level -= 1;
            },
            .r_brace => {
                if (level == 0) {
                    // end of container, exit
                    p.tok_i -= 1;
                    return;
                }
                level -= 1;
            },
            .eof => {
                p.tok_i -= 1;
                return;
            },
            else => {},
        }
    }
}



/// ParamDeclList <- (ParamDecl COMMA)* ParamDecl?
fn parseParamDeclList(p: *Parse) !SmallSpan {
    _ = try p.expectToken(.l_paren);
    const scratch_top = p.scratch.items.len;
    defer p.scratch.shrinkRetainingCapacity(scratch_top);
    var varargs: union(enum) { none, seen, nonfinal: TokenIndex } = .none;
    while (true) {
        if (p.eatToken(.r_paren)) |_| break;
        if (varargs == .seen) varargs = .{ .nonfinal = p.tok_i };
        const param = try p.expectParamDecl();
        if (param != 0) {
            try p.scratch.append(p.gpa, param);
        }
        switch (p.token_tags[p.tok_i]) {
            .comma => p.tok_i += 1,
            .r_paren => {
                p.tok_i += 1;
                break;
            },
            .colon, .r_brace, .r_bracket => return p.failExpected(.r_paren),
            // Likely just a missing comma; give error but continue parsing.
            else => try p.warn(.expected_comma_after_param),
        }
    }
    const params = p.scratch.items[scratch_top..];
    return switch (params.len) {
        0 => SmallSpan{ .zero_or_one = 0 },
        1 => SmallSpan{ .zero_or_one = params[0] },
        else => SmallSpan{ .multi = try p.listToSpan(params) },
    };
}

/// TypeExpr <- PrefixTypeOp* ErrorUnionExpr
///
/// PrefixTypeOp
///     <- QUESTIONMARK
///      / KEYWORD_anyframe MINUSRARROW
///      / SliceTypeStart (ByteAlign / AddrSpace / KEYWORD_const / KEYWORD_volatile / KEYWORD_allowzero)*
///      / PtrTypeStart (AddrSpace / KEYWORD_align LPAREN Expr (COLON Expr COLON Expr)? RPAREN / KEYWORD_const / KEYWORD_volatile / KEYWORD_allowzero)*
///      / ArrayTypeStart
///
/// SliceTypeStart <- LBRACKET (COLON Expr)? RBRACKET
///
/// PtrTypeStart
///     <- ASTERISK
///      / ASTERISK2
///      / LBRACKET ASTERISK (LETTERC / COLON Expr)? RBRACKET
///
/// ArrayTypeStart <- LBRACKET Expr (COLON Expr)? RBRACKET
fn parseTypeExpr(p: *Parse) Error!Node.Index {
    switch (p.token_tags[p.tok_i]) {
        .l_bracket => switch (p.token_tags[p.tok_i + 1]) {
            else => {
                const lbracket = p.nextToken();
                const len_expr = try p.parseExpr();
                const sentinel: Node.Index = if (p.eatToken(.colon)) |_|
                    try p.expectExpr()
                else
                    0;
                _ = try p.expectToken(.r_bracket);
                if (len_expr == 0) {
                    const mods = try p.parsePtrModifiers();
                    const elem_type = try p.expectTypeExpr();
                    if (mods.bit_range_start != 0) {
                        try p.warnMsg(.{
                            .tag = .invalid_bit_range,
                            .token = p.nodes.items(.main_token)[mods.bit_range_start],
                        });
                    }
                    if (sentinel == 0 and mods.addrspace_node == 0) {
                        return p.addNode(.{
                            .tag = .ptr_type_aligned,
                            .main_token = lbracket,
                            .data = .{
                                .lhs = mods.align_node,
                                .rhs = elem_type,
                            },
                        });
                    } else if (mods.align_node == 0 and mods.addrspace_node == 0) {
                        return p.addNode(.{
                            .tag = .ptr_type_sentinel,
                            .main_token = lbracket,
                            .data = .{
                                .lhs = sentinel,
                                .rhs = elem_type,
                            },
                        });
                    } else {
                        return p.addNode(.{
                            .tag = .ptr_type,
                            .main_token = lbracket,
                            .data = .{
                                .lhs = try p.addExtra(Node.PtrType{
                                    .sentinel = sentinel,
                                    .align_node = mods.align_node,
                                    .addrspace_node = mods.addrspace_node,
                                }),
                                .rhs = elem_type,
                            },
                        });
                    }
                } else {
                    switch (p.token_tags[p.tok_i]) {
                        else => {},
                    }
                    const elem_type = try p.expectTypeExpr();
                    if (sentinel == 0) {
                        return p.addNode(.{
                            .tag = .array_type,
                            .main_token = lbracket,
                            .data = .{
                                .lhs = len_expr,
                                .rhs = elem_type,
                            },
                        });
                    } else {
                        return p.addNode(.{
                            .tag = .array_type_sentinel,
                            .main_token = lbracket,
                            .data = .{
                                .lhs = len_expr,
                                .rhs = try p.addExtra(.{
                                    .elem_type = elem_type,
                                    .sentinel = sentinel,
                                }),
                            },
                        });
                    }
                }
            },
        },
        else => return p.parseErrorUnionExpr(),
    }
}

fn expectTypeExpr(p: *Parse) Error!Node.Index {
    const node = try p.parseTypeExpr();
    if (node == 0) {
        return p.fail(.expected_type_expr);
    }
    return node;
}

/// Mod <- KEYWORD_mod IDENTIFIER LPAREN TypeExper RPAREN
fn parseMod(p: *Parse) !Node.Index {
    _ = p.eatToken(.keyword_mod) orelse return null_node;
    _ = p.eatToken(.identifier);
    _ = p.eatToken(.l_brace);
    _ = p.eatToken(.r_brace);
    return null_node;
}

/// URL <- KEYWORD_url IDENTIFIER COLON String SEMICOLON
fn parseUrl(p: *Parse) !Node.Index {
    _ = p.eatToken(.keyword_url) orelse return null_node;
    return null_node;
}

/// FnProto <- KEYWORD_fn IDENTIFIER? LPAREN ParamDeclList RPAREN ByteAlign? AddrSpace? LinkSection? CallConv? EXCLAMATIONMARK? TypeExpr
fn parseFnProto(_: *Parse) !Node.Index {
    return null_node;
}

/// This function can return null nodes and then still return nodes afterwards,
/// such as in the case of anytype and `...`. Caller must look for rparen to find
/// out when there are no more param decls left.
///
/// ParamDecl
///     <- doc_comment? (KEYWORD_noalias / KEYWORD_comptime)? (IDENTIFIER COLON)? ParamType
///      / DOT3
///
/// ParamType
///     <- KEYWORD_anytype
///      / TypeExpr
fn expectParamDecl(p: *Parse) !Node.Index {
    if (p.token_tags[p.tok_i] == .identifier and
        p.token_tags[p.tok_i + 1] == .colon)
    {
        p.tok_i += 2;
    }
    switch (p.token_tags[p.tok_i]) {
        .keyword_anytype => {
            p.tok_i += 1;
            return null_node;
        },
        else => return p.expectTypeExpr(),
    }
}


/// Decl
///      KEYWORD_URL Expr SEMICOLON
fn expectTopLevelDecl(p: *Parse) !Node.Index {
    const resource_decl = try p.parseUrl();
    if (resource_decl != 0) {
        try p.expectSemicolon(.expected_semi_after_decl, false);
        return resource_decl;
    }
    return null_node;
}


fn expectTopLevelDeclRecoverable(p: *Parse) error{OutOfMemory}!Node.Index {
    return p.expectTopLevelDecl() catch |err| switch (err) {
        error.OutOfMemory => return error.OutOfMemory,
        error.ParseError => {
            p.findNextContainerMember();
            return null_node;
        },
    };
}

fn eatToken(p: *Parse, tag: Token.Tag) ?TokenIndex {
    return if (p.token_tags[p.tok_i] == tag) p.nextToken() else null;
}

fn assertToken(p: *Parse, tag: Token.Tag) TokenIndex {
    const token = p.nextToken();
    assert(p.token_tags[token] == tag);
    return token;
}


fn expectToken(p: *Parse, tag: Token.Tag) Error!TokenIndex {
    if (p.token_tags[p.tok_i] != tag) {
        return p.failMsg(.{
            .tag = .expected_token,
            .token = p.tok_i,
            .extra = .{ .expected_tag = tag },
        });
    }
    return p.nextToken();
}

fn expectSemicolon(p: *Parse, error_tag: AstError.Tag, recoverable: bool) Error!void {
    if (p.token_tags[p.tok_i] == .semicolon) {
        _ = p.nextToken();
        return;
    }
    try p.warn(error_tag);
    if (!recoverable) return error.ParseError;
}



fn nextToken(p: *Parse) TokenIndex {
    const result = p.tok_i;
    p.tok_i += 1;
    return result;
}

const null_node: Node.Index = 0;

const Parse = @This();
const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const Ast = @import("Ast.zig");
const Node = Ast.Node;
const AstError = Ast.Error;
const TokenIndex = Ast.TokenIndex;
const Token = @import("tokenizer.zig").Token;

test {
    _ = @import("parser_test.zig");
}
