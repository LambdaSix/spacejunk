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
//      //   x   y  width
//      list(10, 0, 15), // status
//      list(10, 1, 8),  // altitude
//      list(21, 1, 8),  // apoapsis
//      list(53, 1, 8)   // periapsis
//    )
//  ).
function template_init {
  parameter template, fields.

  return list(template, fields).
}

// Populates the template and displays it at 0, 0.
//
// Example
// =======
//  local launch_template is template_init(...).
//  until False {
//    // stuff
//    local values is list(
//      "LIFT-OFF",
//      round(ship:altitude, 1),
//      round(alt:apoapsis, 1),
//      round(alt:periapsis, 1)
//    ).
//    display_template(launch_template, values).
//  }
function display_template {

}
