// kOS display template library
//
// Changes
// 0.2 -
//
// @version 0.2
// @author https://github.com/dtandersen
@lazyglobal off.

run once lib_string.

// Initializes a template.
//
// Example
// =======
//
//  local template is template_init(
//    list(
//      "status:   {status}                                     ",
//      "altitude: {altitude}m  apoapsis: {apoapsis}m  periapsis: {periapsis}m",
//      "=============================================================="
//    )
//  ).
function template_init {
  parameter layout.

  local fields is lexicon().
  local lines is layout:copy.

  local linenum is 0.
  for line in lines {
    until not line:contains("{") {
      local start is line:find("{").
      local stop is line:find("}").
      local varname is line:substring(start + 1, stop - start - 1).
      fields:add(varname, lexicon(
          "line", linenum,
          "start", start,
          "stop", stop
        )).
      set line to line:remove(start, stop - start + 1).
    }
    set linenum to linenum + 1.
  }

  return lexicon(
      "layout", layout,
      "fields", fields,
      "last_update", 0
    ).
}

// Parses the template and populates it with data.
//
// Example
// =======
//  local template is template_init(...).
//  local lines is parse_template(template, lexicon(
//      "status", LIFT-OFF",
//      "altitude", round(ship:altitude),
//      "apoapsis", round(alt:apoapsis),
//      "periapsis", round(alt:periapsis)
//    ).
function parse_template {
  parameter template, data.

  local layout is template["layout"].
  local fieldinfo is template["fields"].
  local lines is layout:copy.

  for key in data:keys {
    local value is data[key].
    local f is fieldinfo[key].
    local linenum is f["line"].
    local start is f["start"].
    local stop is f["stop"].
    local width is stop - start + 1.

//    local line is lines[linenum]:remove(start, width):insert(start, "" + value).
    local line is lines[linenum]:replace("{" + key + "}", "" + value).
    set lines[linenum] to line.
  }

  return lines.
}

// Populates the template and displays it at 0, 0.
//
// Example
// =======
//  local launch_template is template_init(...).
//  until False {
//    // stuff
//    local data is list(
//      list("status", "LIFT-OFF"),
//      list("altitude", round(ship:altitude, 1)),
//      list("apoapsis", round(alt:apoapsis, 1)),
//      list("periapsis", round(alt:periapsis, 1))
//    ).
//    display_template(launch_template, data).
//  }
function display_template {
  parameter template, data.

  local last_time is template["last_update"].

  if time:seconds < last_time + .25 {
    return.
  }

  set template["last_update"] to time:seconds.
  local lines is parse_template(template, data).

  local i is 0.
  for line in lines {
    print line:padright(terminal:width) at (0, i).
    set i to i + 1.
  }
}
