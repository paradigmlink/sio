sio-vm

`sio` - secure input output language is an implementation of oz.

Oz Kernel Language

```
<s> ::=
    skip
  | <s>1 <s>2
  | local <x> in <s> end
  | <x>1=<x>2
  | <x>=<v>
  | if <x> then <s>1 else <s>2 end
  | case <x> of <pattern> then <s>1 else <s>2 end
  | { <x> <y>1 ... <y>n }
```

Sio Kernel Language
```
<s> ::=
    skip                                     empty statement
  | <s>1 <s>2                                statement sequence
  | let { <x> } in { <s> }                   variable creation
  | <x>1=<x>2                                variable-variable binding
  | <x>=<v>                                  value creation
  | if <x> { <s>1 } else { <s>2 }            conditional
  | match <x> { <pattern> => { <s>1 } }      pattern matching
  | <x> ( <y>1 ... <y>n )                    procedure application
```

- [ ] empty statement
- [ ] statement sequence
- [ ] variable creation
- [ ] variable-variable binding
- [ ] value creation
- [ ] conditional
- [ ] pattern matching
- [ ] procedure application

Value expressions in the declarative kernel language

Oz Kernel value expressions
```
<v>                 ::= <number> | <record> | <procedure>
<number>            ::= <int> | <float>
<record>, <pattern> ::= <literal> | <literal>(<feature>1: <x>1 ... <feature>n: <x>n)
<procedure>         ::= proc { $ <x>1 ... <x>n } <s> end
<literal>           ::= <atom> | <bool>
<feature>           ::= <atom> | <bool> | <int>
<bool>              ::= true | false
```
 Sio Kernel value expressions
```
<v>                 ::= <number> | <record> | <procedure>
<number>            ::= <int> | <float>
<record>, <pattern> ::= <literal> | <literal> { <feature>1: <x>1 ... <feature>n: <x>n }
<procedure>         ::= $ :: ( <x>1 ... <x>n ) { <s> }
<literal>           ::= <atom> | <bool>
<feature>           ::= <atom> | <bool> | <int>
<bool>              ::= true | false
```

- [ ] value
- [ ] number
- [ ] record, pattern
- [ ] procedure
- [ ] literal
- [ ] feature
- [ ] bool


<program> ::= <statement>

<statement> ::= <assignment_statement>
 | <let_statement>
 | <if_statement>
 | "print( " <exp> " )"
 | <statement> " " <statement>

<assignment_statement> ::= <var_identifier> ": " <type_identifier> " = " <exp>
<let_statement> ::= "let { " <statement>+ " } in { " <statement>+ " }"
<if_statement> ::= "if ( " <boolean_expression> " ) { " <statement> " } else { " <statement> " }"
<data_statement> ::= "data " <type_identifier> " = " <type_identifier>

<exp> ::= <boolean_expression> | <mathematical_expression>

<mathematical_expression> ::= <num>
 | "( " <mathematical_expression> " )"
 | <mathematical_expression> <mathematical_operator> <mathematical_expression>
 | <var_identifier>

<num> ::= [0-9]+
<mathematical_operator> ::= " + " | " - " | " * " | " / "
<type_identifier> ::= <uppercase> <lower> | <uppercase> <digit>
<var_identifier> ::= <lower> | <lower> <digit>

<boolean_expression> ::= <boolean>
 | "( " <boolean_expression> " )"
 | "!" <boolean_expression>
 | <boolean_expression> <boolean_operator> <boolean_expression>
 | <var_identifier>
 | <mathematical_expression> <equality_operator> <mathematical_expression>
 | <boolean_expression> <equality_operator> <boolean_expression>
 | <mathematical_expression> <comparison_operator> <mathematical_expression>

<boolean_operator> ::= " && " | " || "
<boolean> ::= " true " | " false "
<equality_operator> ::= " == " | " != "
<comparison_operator> ::= " > " | " >= " | " < " | " <= "

<digit> ::= [0-9]+
<uppercase> ::= [A-Z]+
<lower> ::= [a-z]+
