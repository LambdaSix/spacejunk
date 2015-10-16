// kOS Display library
//
// @version 0.1
// @author David Andersen
@lazyglobal off.

// Initializes a template.
//
// Example
// =======
//
//  local template is template_init(
//    list(
//      "status:   SSSSSSSSSSSSSSS                                     ",
//      "altitude: EEEEEEEEm  apoapsis: AAAAAAAAm  periapsis: PPPPPPPPm",
//      "=============================================================="
//    ),
//    list(
//      //   x   y
//      list(10, 0), // status
//      list(10, 1),  // altitude
//      list(21, 1),  // apoapsis
//      list(53, 1)   // periapsis
//    )
//  ).
function template_init {
  parameter layout, fieldinfo.

  return list(
      layout,
      fieldinfo,
      0          // last time printed
    ).
}

// Populates the template and displays it at 0, 0.
//
// Example
// =======
//  local launch_template is template_init(...).
//  until False {
//    // stuff
//    local data is list(
//      "LIFT-OFF",
//      round(ship:altitude, 1),
//      round(alt:apoapsis, 1),
//      round(alt:periapsis, 1)
//    ).
//    display_template(launch_template, data).
//  }
function display_template {
  parameter template, data.

  local layout is template[0].
  local fieldinfo is template[1].
  local last_time is template[2].

  if time:seconds < last_time + .25 {
    return.
  }

  local y is 0.
  for line in layout {
    print line at (0, y).
    set y to y + 1.
  }

  local i is 0.
  for element in data {
    local pos is fieldinfo[i].
    local x is pos[0].
    local y is pos[1].
    print element at (x, y).
    set i to i + 1.
  }

  set template[2] to time:seconds.
}
