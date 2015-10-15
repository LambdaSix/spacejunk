// kOS TTY library for Kerbal Space Program
//
// @version 0.1
// @author David Andersen
@lazyglobal off.

global sj_tty_tabs to list(0, 17, 34).

// Accepts a list of lines, each with a sub-list of x coordinates and values.
//
//   list(
//     list(value1, value2, valueN, ...),
//     list(value3, ...),
//     ...
//   )
//
// The lines are printed in each and the line is cleared before each pass.
//
// Example
// =======
//
// tty_set_tabs(0, 17, 34).
// tty_print(
//   list(
//     list("a: 1", "b: 2", "c: 3"),
//     list("d: 4", "e: 5")
//   )
// ).
//
// Output:
// a: 1           b: 2           c: 3
// d: 4           e: 5
// ===================================================
function tty_print_lines {
  parameter lines.

  local y is 0.
  for line in lines {
    tty_print(line, y).
    set y to y + 1.
  }

  tty_separator(y).
}

function tty_print {
  parameter line, y.

  tty_clearline(y).

  from { local i to 0. } until i >= line:length step { set i to i + 1. } DO {
    local x to sj_tty_tabs[i].
    local col to line[i].

    print col at (x, y).
  }
}

function tty_clearline {
  parameter y.

  print "                                                   " at (0, y).
}

function tty_separator {
  parameter y.

  print "===================================================" at (0, y).
}


function tty_set_tabs {
  parameter tabs.

  set sj_tty_tabs to tabs.
}
