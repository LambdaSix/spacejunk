lib_string
==========

Inefficient string manipulation functions to tide us over until kOS has them.

`strlen(s)`

Return length of `s`.

Input         | Output
------------- | -------------
strlen("")    | 0
strlen("a")   | 1
strlen("ab")  | 2
strlen(1.23)  | 4

`rpad(s, length)`

Pad `s` to the right.

Input            | Output
---------------- | -------------
rpad("", 1)      | " "
rpad("abc", 5)   | "abc  "
rpad("abc", 3)   | "abc"
rpad(1.23)       | "1.23 "

`lpad(s, length)`

Pad `s` to the left.

Input            | Output
---------------- | -------------
lpad("", 1)      | " "
lpad("abc", 5)   | "  abc"
lpad("abc", 3)   | "abc"
lpad(1.23)       | " 1.23"
