# proglang

A generic programming language. It currently only has a lexenizer. The tokelexer has identifier, string, symbol, and number characters.
- Identifiers consist of #, @, $, _, and capital and lowercase letters, and digits (except at the start of an identifier).
- Numbers consist of base-10 digits.
- Strings start with ' or " and end with the same. Escapes are made using \\. \t is tab, \n is newline, \r is carriage return, and \u followed by any number of decimal digits is the unicode character with that number in decimal.
- Every other ASCII non-control character is a symbol. The following symbol sequences with no whitespace in between count as one symbol:
  - !=
  - %=
  - &=
  - &&=
  - *=
  - +=
  - -=
  - /=
  - <=
  - <<
  - ==
  - \>=
  - \>>
  - ^=
  - |=
  - ||=
  - ~/=
  - ~/