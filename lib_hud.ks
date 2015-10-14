/// kOS HUD library for Kerbal Space Program by onebit
///
/// Accepts a list of lines, each with a sub-list of x coordinates and values.
///
///   list(
///     list(x-coord, value, ...),
///     list(x-coord, value, ...)
///   )
///
/// The lines are printed in each and the line is cleared before each pass.
///
/// Example
/// =======
///
/// hud_print(
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
function hud_print {
  parameter lines.

  local y = 0.
  for line in lines {
    hud_print_line_at(line, y).
    set y = y + 1.
  }

  hud_print_separator(y).
}

function hud_print_line_at {
  parameter line, y.

  hud_clear_line(y).

  local x to 0.
  from { local i to 0. } until { i >= line::length. } step { set i to i + 2. } DO {
    set x to line[i].
    set col to line[i+1].

    print col at (x, y).
  }
}

function hud_clear_line {
  parameter y.

  print "                                                   " at (0, y).
}

function hud_print_separator {
  parameter y.

  print "===================================================" at (0, y).
}
