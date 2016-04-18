lib_string
==========

Basic string manipulation functions.

`strlen(s)`

Returns the length of the string `s`.

Input         | Output
------------- | -------------
strlen("")    | 0
strlen("a")   | 1
strlen("ab")  | 2
strlen(1.23)  | 4

`rpad(s, length)`

Pads the string `s` to the right with spaces.

Input            | Output
---------------- | -------------
rpad("", 1)      | " "
rpad("abc", 5)   | "abc  "
rpad("abc", 3)   | "abc"
rpad(1.23)       | "1.23 "

`lpad(s, length)`

Pads the string `s` to the left with spaces.

Input            | Output
---------------- | -------------
lpad("", 1)      | " "
lpad("abc", 5)   | "  abc"
lpad("abc", 3)   | "abc"
lpad(1.23)       | " 1.23"
