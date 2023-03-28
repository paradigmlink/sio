# Syntax and semantics

Sio has a pure functional eager core.

```f#
// An identifier
abc123_

// A number literal
42

// Another number literal
3.14

// A string literal
"Hello world"

// A raw string literal
r"Can contain newlines
world"
r#"With # as delimiters raw strings can also contain quotes without escapinng `"`"#
r###" "## "###

// A character literal
'e'
```

### Comments

C style comments

`//` for line comments ended in a newline

`/*` starts a block comment which is ended by `*/`

### Functions

```f#
f(x, "argument", 3, 3.14)
```

Even though functions are ubiquitous in sio. A deliberate design decision to use C stylee function application is chosen. Familiarity and clear deliniation makes for easier reading, as we read code more than write code.

### Variable bindings

```f#,rust
let x: number = 1 + 2 in x;
```

let bindings allow functions to be defined too

```f#,rust
let id :: (x: number) { id } in id(1)
```

Mutually recursive values work too by using `rec ... in` to enclose the `let` bindings.

```f#
rec
let f::(x: number) { g(x) }
let g::(x: number) { f(x) }
in f(1) // Never returns
```

This is not limited to functions but works with any value that is capable of recursion (records, variants and functions).

```f#
/// An infinite list of `1`
rec let ones = 1 | ones in ()

/// A recursive set of records
rec
let value1 =
  let f::(x: number) = value2.f(x+1)
  { f }
let value2 =
  let f::(x: number) = value1.f(x+2)
  { f }
in ()
```

### If expressions

A simple if expression evaluates a boolean expression, choosing the first branch if the evaluation is `true` otherwise the second path is chosen, given the evaluation is `false`

```f#, rust
if true { 1 } else { 0 }
```

### Record expressions
Complex datatypes are created by coupling data that is logically grouped into a single type.

```f#,rust
{ pi = 3.14, add1 = (x){x+1} }
```

To access the fields of a record, `.` is used.

```f#,rust
let record = { pi = 3.14, add1 = (x){x+1.0}}
in record.pi // Returns 3.14
```

Field assignments can be omitted if there is a variable in scope with the same name as the field.

```f#,rust
let id x = x in {id}
```

The `..` operator can be used at the end of an expression to take all the fields of one record and fill the constructed record. Explicityle defining fields that also exist in the record will be in the same order as they are in the base record while all other fields will be prepended in the order that they are written.

```f#,rust
let base_record = { x = 1, y = 2, name = "gluon" }
in
// Results in a record with type
// { field: bool, x: int, y: int, name: string }
{
  field = true,
  ..
  base_record
}
```

### Array expressions

Arrays can be constructed with array literals

```f#,rust
// Results in an `array int`
[1, 2, 3, 4]
```

Since sio is statically typed all values must be of the same type. This allows the sio interpreter to avoid tagging each value individually which makes types such as `array byte` be convertible into Rust's `&[u8]` type without allocations.

```f#
// ERROR:
// Types do not match:
//       Expected: int
//       Actual:   string
[1, ""]
```

Functions that operate on arrays con be found in the `array` module.

```f#
array.len([1, 2, 3])
```

### Variants

While records are great for grouping data together, there is oftten a need to have data which can be one of several variants. Unlike records, variants need to be defined before they can be used.

```f#,rust
data Option<A> = | Some(A) | None
Some(1)
```

### Match expressions

To allow variants to be unpacked so their contents can be retrieved, sio has the `match` expression.

```f#,rust
match None {
  | Some(x) => { x }
  | Non => { 0 }
}
```

Here, a pattern is written for each variant's constructor and the value passed in (`None` in this case) is matched to each of the patterns. When a matching pattern is found, the expression on the right of `=>` is evaluated with each of the constructor's arguments bound to variables.

`match` expressions can also be used to unpack records.

```f#,rust
match { x = 1.0, pi = 3.14 } {
    | { x = y, pi } => { y + pi }
}
```

```f#,rust
// Patterns can be nested as well
match { x = Some(Some(123)) } {
    | { x = Some(None) } => { 0 }
    | { x = Some(Some(x)) => { x }
    | { x = None } => { -1 }
}
```

`let` bindings can also match and unpack on data but only with irrefutable patterns. In other words, only with patters which cannot fail.

```f#,rust
// Matching on records will always succeed since they are the only variant
let { x = y, pi } = { x = 1.0, pi = 3.14 }
in y + pi

// These will be rejected howere as `let` can only handle one variant (`Some` in this example)
let Some(X) = None
let Some(y) = Some(123)
x + y
```

### Tuple expressions

Sio also has tuplee expressions for when you don't have sensible name for your fields.

```f#,rust
(1, "", 3.14) // (int, string, dec)
```

Similarly to records they can be unpacked with `match` and `let`.

```f#
match (1, None) {
  | (x, Some(y)) => { x + y },
  | (x, None) => {x},
}

let (a, b) = (1.0, 3.14)
a+b
```

In fact, tuples are only syntax sugar over records with fields named aftter numbers (`_0`, `_1`, ...) which makes the above equivalennt to the following code.

```f#
match { _0 = 1, _1 = None } {
    | { _0 = x, _1 = Some(y) } => { x + y },
    | { _0 = x, _1 = None } => { x },
}

let { _0 = a, _1 = b } = { _0 = 1.0, _1 = 3.14 }
a + b
```
The record accessor fields all one to access tuple fields without directly unpacking.

```f#,rust
(0, 3.14)._1 // 3.14
```

### Lambda expressions

We have seen functions can be defined in let expressions. Now let us define a function without giving it an explicit name.

```f#,rust
// (x, y) { x + y - 10 }
```

```f#,rust
// Equivalent to
let f::(x, y) { x + y - 10 } in f
```

### Type expressions

Sio allows new types to be defined through the `data` expression which, just like the `let` expression, requires `in <expression>` to be written at the end to ensure it returns a value.

```f#,rust
// data <identifier> < <identifier>,* > <type> <| type>* in <expression>
data MyOption<A> | None | Some(A)
let divide :: (x: int, y: int) => MyOption<int> {
    if (x / y) * y == x {
        Some(x/y)
    } else {
        None
    }
}
in divide(10, 4)
```

An important differenc from many languages however is that `data` only defines aliases. This means that all types in the example below are actually equivalent to each other.

```f#,rust
data Type1 { x: int }
data Type2 Type1
data Type3 { x: int }
let r1 : Type1 = { x = 0 }
let r2 : Type2 = r1
let r3 : Type3 = r2
in r1
```

Mutually recursive types can be defined by writing a `rec` block.

```f#,rust
rec
data SExpr_ | Atom<string> | Cons<SExpr, SExpr>
data SExpr = { location: int, expr: SExpr_ }
in Atom("name")
```

### Do expressions

`do` expressions are syntax sugar over the commonly used `Monad` type which is used to encapsulate side-effects. By using `do` instead of `>>=` or `flat_map` we can write code in a sequential manner instead of the closure necessary for sugar free versions. Note `do` still requires a `flat_map` binding to be in scope with the correct type or else you will get an error during typechecking.

```f#
flat_map :: ((x:int) -> Some(int){x+2}

```type <name> [params] = <definition> [where <constraints>]```

string that has a length of 16 characters

```f#,rust
type String16 = String where length self.0 == 16
```
number that has 3 decimals places

```f#,rust
type Number100s = Number where self.0 > 100 && self.0 < 1_000
```

ascii only string where all characters is above the parameter N where N is also below 0x80 (1 byte UTF8 characters)

```f#,rust
type StringRestriction (N: Number) = (s: String) where
  N < 0x80
  forall c in (characters s) => c > N






