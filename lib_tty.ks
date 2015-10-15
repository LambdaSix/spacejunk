/// kOS HUD library for Kerbal Space Program by onebit
///
/// Accepts a list of lines, each with a sub-list of x coordinates and values.
///
///   list(
///     list(x-coord, value, x-coord, value, ...),
///     list(x-coord, value, ...),
///     ...
///   )
///
/// The lines are printed in each and the line is cleared before each pass.
///
/// Example
/// =======
///
/// tty_print(
///   list(
///     list(0, "a: 1", 15, "b: 2", 30, "c: 3"),
///     list(0, "d: 4", 15, "e: 5")
///   )
/// ).
///
/// Output:
/// a: 1           b: 2           c: 3
/// d: 4           e: 5
/// ===================================================
function tty_print_lines_at {
  parameter lines.

  local y = 0.
  for line in lines {
    tty_print_line_at(line, y).
    set y = y + 1.
  }

  tty_print_separator_at(y).
}

function tty_print_line_at {
  parameter line, y.

  tty_clear_line(y).

  from { local i to 0. } until { i >= line::length. } step { set i to i + 2. } DO {
    local x to line[i].
    local col to line[i + 1].

    print col at (x, y).
  }
}

function tty_clear_line {
  parameter y.

  print "                                                   " at (0, y).
}

function tty_print_separator {
  parameter y.

  print "===================================================" at (0, y).
}
