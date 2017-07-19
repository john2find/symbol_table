# symbol_table
[![Pub](https://img.shields.io/pub/v/symbol_table.svg)](https://pub.dartlang.org/packages/symbol_table)
[![build status](https://travis-ci.org/thosakwe/symbol_table.svg)](https://travis-ci.org/thosakwe/symbol_table)

A generic symbol table implementation in Dart, with support for scopes and constants.
The symbol tables produced by this package are hierarchical (in this case, tree-shaped),
and utilize basic memoization to speed up repeated lookups.

# Variables
There are two types of symbols: `Variable` and `Constant`. I opted for the name
`Variable` to avoid conflict with the Dart primitive `Symbol`.

```dart
var foo = new Variable<String>('foo');
var bar = new Variable<String>('bar', value: 'baz');
var shelley = new Constant<String>('foo', 'bar');

foo.value = 'bar';
shelley.value = 'Mary'; // Throws a StateError - constants cannot be overwritten.

foo.lock();
foo.value = 'baz'; // Also throws a StateError - Once a variable is locked, it cannot be overwritten.
```

## Private Variables
Variables can also be marked as *private*. This can be helpful if you are trying
to determine which symbols should be exported from a library or class.

```dart
myVariable.markAsPrivate();

print(myVariable.isPrivate); // true
```

# Symbol Tables
It's easy to create a basic symbol table:

```dart
var mySymbolTable = new SymbolTable<int>();
var doubles = new SymbolTable<double>(values: {
  'hydrogen': 1.0,
  'avogadro': 6.022e23
});
```

# Exporting Symbols
Due to the tree structure of symbol tables, it is extremely easy to
extract a linear list of distinct variables, with variables lower in the hierarchy superseding their parents
(effectively accomplishing variable shadowing).

```dart
var allSymbols = mySymbolTable.allVariables;
```

We can also extract symbols which are *not* private. This helps us export symbols from libraries
or classes.

```dart
var exportedSymbols = mySymbolTable.allPublicVariables;
```

# Child Scopes
There are three ways to create a new symbol table:


## Regular Children
This is what most interpreters need; it simply creates a symbol table with the current symbol table
as its parent. The new scope can define its own symbols, which will only shadow the ancestors within the
correct scope.

```dart
var child = mySymbolTable.createChild();
var child = mySymbolTable.createChild(values: {...});
```

## Clones
This creates a scope at the same level as the current one, with all the same variables.

```dart
var clone = mySymbolTable.clone();
```

## Forked Scopes
If you are implementing a language with closure functions, you might consider looking into this.
A forked scope is a scope identical to the current one, but instead of merely copying references
to variables, the values of variables are copied into new ones.

The new scope is essentially a "frozen" version of the current one.

It is also effectively orphaned - though it is aware of its `parent`, the parent scope is unaware
that the forked scope is a child. Thus, calls to `resolve` may return old variables, if a parent
has called `remove` on a symbol.

```dart
var forked = mySymbolTable.fork();
var forked = mySymbolTable.fork(values: {...});
```