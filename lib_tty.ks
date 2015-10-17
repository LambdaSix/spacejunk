// kOS TTY library for Kerbal Space Program
//
// See lib_display.ks for version 2 of this.
//
// @version 0.1
// @author David Andersen
@lazyglobal off.

global sj_tty_tabs to list(0, 17, 34).

// Prints a status area at the top of the screen.
//
// Each line is cleared before printing to remove artifacts.
//
// Parameters
// ==========
//
// lines is a list that contains sub-lists of values to print:
//
// e.g.
//
//   list(
//     list(value1, value2, valueN, ...),
//     list(value3, ...),
//     ...
//   )
//
// Example
// =======
//
// Print oribital status of the ship.
//
// tty_set_tabs(0, 25).
// tty_print_lines(
//   list(
//     list("state: LIFT-OFF"),
//     list("apoapsis: " + ALT:APOAPSIS + "m", "periapsis: " + ALT:PERIAPSIS + "m")
//   )
// ).
//
// Output:
// state: LIFT-OFF
// apoapsis: 102000.5m      periapsis: -24501.6m
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

// Prints a list of values on a line with specified tab stops.
// Line is cleared before printing.
function tty_print {
  parameter line, y.

  tty_clearline(y).

  from { local i to 0. } until i >= line:length step { set i to i + 1. } DO {
    local x to sj_tty_tabs[i].
    local col to line[i].

    print col at (x, y).
  }
}

// Clear the line.
function tty_clearline {
  parameter y.

  print "                                                   " at (0, y).
}

// Print a separator.
function tty_separator {
  parameter y.

  print "===================================================" at (0, y).
}

// Set the tab stops.
function tty_set_tabs {
  parameter tabs.

  set sj_tty_tabs to tabs.
}
