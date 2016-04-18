// kOS String Library
//
// A library of inefficient string manipulation functions.
//
// References:
//   [1] https://www.reddit.com/r/Kos/comments/3oqt58/googlefu_is_failing_me_how_to_parse_a_string_into/cvzoddb
//
// Changelog
// 0.2 - refactored to use build-in KOS string functions
//
// @version 0.2
// @author David Andersen
@lazyglobal off.

// Returns the length of string s. If s is not a string, it is treated as if it were a string.
// e.g. strlen("abc") = 3
//      strlen(1.25) = 4
function strlen {
  parameter s.

  local s2 is "" + s.
  return s2:length.
}

// adds spaces to the right of the string to increase its length to the specified width.
// e.g. rpad("abc", 5) = "abc  "
function rpad {
  parameter s, width.

  local s2 is "" + s.
  return s2:padright(width).
}

// adds spaces to the left of the string to increase its length to the specified width.
// e.g. lpad("abc", 5) = "  abc"
function lpad {
  parameter s, width.

  local s2 is "" + s.
  return s2:padleft(width).
}
