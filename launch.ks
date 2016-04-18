// kOS launch Script for Kerbal Space Program by onebit
//
// Perform launch based on launch profile calculated by thrust to weight ratio [1].
//
// Formula: A * tan(θ/2)^q / |sin(θ)|
// Where A = orbital speed,
//       θ = pitch of space craft
//       q = TWR (thrust to weight ratio)
//
// Special thanks to silentdeth [2] for the idea.
//
// Usage:
//   run launch(altitude).
//
// References:
//   [1] Basics of Space Flight by Ludwik Marian Celnikier (p. 149-156)
//       https://books.google.com/books?id=kz216MKHBqcC&pg=PA151&dq=rocket+gravity+turn&hl=en&sa=X&ved=0CFAQ6AEwCWoVChMIw5OKsru9yAIVT9BjCh3qwQx5#v=onepage&q=rocket%20gravity%20turn&f=false
//   [2] Let's Play KSP 0.90 (Science Harder Campaign) S3E26 Gravity Turn Script by silentdeth
//       https://www.youtube.com/watch?v=qzj-oIxQ_Hk
//
// @version 0.1
// @author https://github.com/dtandersen
@lazyglobal off.

parameter orbit_alt.

run lib_tty.
run lib_template.
run lib_string.
run lib_util.
run lib_orbit.
run lib_ship.

launch(orbit_alt).

// launch into circular orbit at the given  altitude.
//
// Parameters
// ----------
// orbit_alt - orbital altitude (m)
function launch {
  parameter orbit_alt.

  function orient {

    local panel is list (
        "status:                   heading:               ",
        "yaw:         roll:        pitch:                 ",
        "=================================================="
      ).
    local template is template_init(panel).

    local lock on_course to (90 - ship_heading()) <= .15.

    until on_course {
      ship_stage().
      lock steering to heading(90, 90).
      display_template(template, lexicon(
          "status", "ORIENT",
          "heading", round(ship_heading()),
          "yaw", round(ship:facing:yaw),
          "roll", round(ship:facing:pitch),
          "pitch", round(ship:facing:roll)
        )).
    }
  }

  /// launch ship and reach orbital apoapsis.
  function ascend {
    parameter twr_list, desired_v.

    /// calculate angle of ascent for speed.
    function calc_angle {
      parameter v, pitch, twr3.

      return v * tan(pitch/2) ^ (twr3*1) / abs(sin(pitch)).
    }

    /// generate ascient profile based desired speed and twr.
    function calc {
      parameter orbital_speed, twr.

      local v to list().
      v:add(0).

      local angle to 1.
      until angle > 90 {
        local velocity to calc_angle(orbital_speed, angle, twr).
        v:add(velocity).
        set angle to angle + 1.
      }

      return v.
    }

    /// get angle of ascent from ascent profile.
    function getAngle {
      parameter current_velocity, twr2, v, desired_v.

      if current_velocity <= 25 {
        return 0.
      }
      local angle is 0.
      for var in v {
        if current_velocity <= var {
          v:remove(angle).
          v:insert(angle, calc_angle(desired_v, angle, twr2)).
          return angle.
        }
        set angle to angle + 1.
      }

      return 90.
    }

    // ASCEND
    local panel is list (
        "status:   {status}                                        ",
        "speed:    {speed}m/s  pitch: {pitch}       twr: {twr}         ",
        "apoapsis: {apoapsis}m    periapsis: {periapsis}m         ",
        "=================================================="
      ).
    local template is template_init(panel).

    lock throttle to 1.

    local ship_gravity to body:mu / ((ship:altitude + body:radius)^2).
    local twr to SHIP:AVAILABLETHRUST / (SHIP:MASS * ship_gravity).
    print "m: " + SHIP:MASS + ", g: " + ship_gravity + ", T: " + SHIP:AVAILABLETHRUST + ", twr: " + twr.
    print "desired velocity: " + desired_v + " m/s".
    local v to calc(desired_v, twr).

    local angle is 0.
    for var in v {
      print "speed: " + var + ", angle: " + angle.
      set angle to angle + 1.
    }
    print "=========================".
    lock speed to SHIP:VELOCITY:surface:mag.
    local tt to 0.
    lock throttle to 1.
    lock steering to heading(90, tt).
    local last_twr to 0.
    local last_calc2 to 0.
    until speed >= desired_v or alt:APOAPSIS >= orbit_alt * .99 {
      set ship_gravity to body:mu / ((ship:altitude + body:radius)^2).
      set twr to SHIP:AVAILABLETHRUST / (SHIP:MASS * ship_gravity).
      if time:seconds >= last_twr + 5 {
        twr_list:add(twr).
        set last_twr to time:seconds.
      }
      if ship_stage() or v:length = 0 {
        local z is twr.
        set v to calc(desired_v, z).
      }
      local tilt to 90 - getAngle(speed, twr, v, desired_v).
      set tt to tilt.

      local data is lexicon(
          "status", "LIFT-OFF",
          "speed", lpad(round(speed, 1), 6),
          "pitch", lpad(round(tilt, 1), 5),
          "twr", lpad(round(twr, 2), 4),
          "apoapsis", lpad(round(alt:APOAPSIS), 7),
          "periapsis", lpad(round(alt:PERIAPSIS), 7)
        ).
      display_template(template, data).
    }
  }

  /// coast to edge of atmosphere, keeping apoapsis above orbit altitude.
  function coast {
    parameter orbital_speed, orbit_alt.

    local panel is list(
        "status:   {status}               apoapsis eta: {eta}           ",
        "speed:    {speed}m/s     pitch: {pitch}                  ",
        "apoapsis: {apoapsis}m       periapsis: {periapsis}m      ",
        "=================================================="
      ).
    local coast_template is template_init(panel).

    lock steering to prograde.
    local lock reached_apoapsis to alt:apoapsis >= orbit_alt.
    local lock above_atmosphere to ship:altitude > 70000.
    until above_atmosphere and reached_apoapsis {
      if reached_apoapsis {
        lock throttle to 0.
      } else {
        lock throttle to 1.
      }
      local data is lexicon(
          "status", "COAST",
          "eta", ttime(eta:apoapsis),
          "speed", round(SHIP:VELOCITY:orbit:mag, 1),
          "pitch", round(ship:facing:pitch, 1),
          "apoapsis", round(ALT:APOAPSIS),
          "periapsis", round(ALT:periapsis)
        ).
      display_template(coast_template, data).
    }

    ship_stop().
  }

  /// bring periapsis up to orbit altitude.
  function circularize {
    parameter orbit_alt.

    local panel is list(
        "status:   {status}                       ",
        "speed:    {speed}m/s    pitch: {pitch}      ",
        "apoapsis: {apoapsis}m  periapsis: {periapsis}m ",
        "=================================================="
      ).
    local coast_template is template_init(panel).

    if alt:periapsis < orbit_alt {
      local data is lexicon(
          "status", "CIRCULARIZE",
          "speed", round(SHIP:VELOCITY:surface:mag, 1),
          "pitch", round(ship:facing:pitch, 1),
          "apoapsis", round(ALT:APOAPSIS),
          "periapsis", round(ALT:periapsis)
        ).
      display_template(coast_template, data).
      local node to node(time:seconds + eta:apoapsis, 0, 0, 1).
      add node.
      local inc to 10.
      until node:orbit:periapsis >= orbit_alt and inc >= .1 {
        set node:prograde to node:prograde + inc.
        if node:orbit:periapsis >= orbit_alt {
          set node:prograde to node:prograde - inc.
          if inc = .1 {
            break.
          }
          if inc = 1 {
            set inc to .1.
          }
          if inc = 10 {
            set inc to 1.
          }
        }
      }
      wait 3.
      run burn.
    }
  }

  /// display details of the launch
  function report {
    parameter desired_v, orbit_alt, twr_list, speed.

    print "========================================".
    print "           LAUNCH REPORT".
    print "========================================".
    print "Orbital Speed: " + round(desired_v, 1) + "m/s".
    print "Speed: " + round(speed, 1) + "m/s".
    print "Orbit: " + round(orbit_alt) + "m".
    print "Apoapsis: " + round(alt:APOAPSIS) + "m".
    print "Periapsis: " + round(alt:periapsis) + "m".

    if twr_list:length > 0 {
      local sum_twr to 0.
      for ttwr in twr_list {
        set sum_twr to sum_twr + ttwr.
      }
      print "Average TWR: " + round(sum_twr / twr_list:length, 2).
    }

    tty_print_lines(
      list(
        list("status: COMPLETE"),
        list(
          "speed: " +  round(SHIP:VELOCITY:orbit:mag, 1) + "m/s"
          , "pitch: " + round(ship:facing:pitch, 1)
          , "apoapsis: " + round(alt:APOAPSIS) + "m"
        )
      )).
  }

  /// launch sequence
  set terminal:width to 50.
  //clearscreen.
  local twr_list to list().
  local desired_v to orbit_speed(orbit_alt, body:mu, body:radius).

  //orient().
  ascend(twr_list, desired_v).
  coast(desired_v, orbit_alt).
  ship_stop().
  circularize(orbit_alt).
  report(desired_v, orbit_alt, twr_list, SHIP:VELOCITY:orbit:mag).
}
