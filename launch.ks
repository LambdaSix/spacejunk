@lazyglobal off.

launch().

function launch {
  set orbit_alt to 80000.
  lock gravity to body:mu / ((ship:altitude + body:radius)^2).
  lock a to body:mu * (body:radius / (body:radius + ship:altitude)) ^ 2.
  lock twr to SHIP:AVAILABLETHRUST / (SHIP:MASS * gravity).
  set use_twr to 2.42.
  print "m: " + SHIP:MASS + ", g: " + gravity + ", T: " + SHIP:AVAILABLETHRUST + ", twr: " + twr.

  function orbital_speed_at_altitude {
    parameter altitude, mu, radius.

    set gravity_at_sea_level to  body:mu / (body:radius) ^ 2.
    print "g at sea: " + gravity_at_sea_level + " m/s^2".
    return body:radius * sqrt(gravity_at_sea_level / (body:radius + altitude)).
  }

  function orbital_speed_at_altitude {
    parameter altitude, mu, radius.

    set gravity_at_sea_level to  body:mu / (body:radius) ^ 2.
    print "g at sea: " + ghere + " m/s^2".
    return body:radius * sqrt(gravity_at_sea_level / (body:radius + altitude)).
  }

  //exit.
  set desired_v to orbital_speed_at_altitude(orbit_alt, body:mu, body:radius).
  print "desired velocity: " + desired_v + " m/s".

  function calc_angle {
    parameter v, pitch, twr2.
    return v * tan(pitch/2) ^ twr2 / abs(sin(pitch)).
  }

  function calc {
    parameter twr2.

    set aa to 1.
    set v to list().
    v:add(0).
    until aa > 90 {
      set aa5 to calc_angle(desired_v, aa, twr2).
      v:add(aa5).
      set aa to aa + 1.
    }

    return v.
  }
  set v to calc(twr).
  function getAngle {
    parameter current_velocity, twr2.
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

  function check_stage {
    set staged to False.
    until ship:maxthrust > 0 {
      PRINT "Out of fuel. Staging.".
      STAGE.
      wait .5.
      set staged to True.
   }
   return staged.
  }

  local angle is 0.
  for var in v {
    print "speed: " + var + ", angle: " + angle.
    set angle to angle + 1.
  }
  print "=========================".
  lock speed to  SHIP:VELOCITY:surface:mag.
  lock tilt to 90 - getAngle(speed, twr).
  set tt to 0.
  lock throttle to 1.
  set last_calc to 0.
  lock steering to heading(90, tt).
  set twr_list to list().
  set last_twr to 0.
  set last_calc2 to 0.
  until speed >= desired_v or alt:APOAPSIS >= orbit_alt * .99 {
    if time:seconds >= last_twr + 5 {
      twr_list:add(twr).
      set last_twr to time:seconds.
    }
    set tt to tilt.
    if check_stage() {
      set v to calc(twr).
    }
  //  if (time:seconds >= last_calc2 + 1) {
  //    set v to calc(twr * 1).
  //    set last_calc2 to time:seconds.
  //    print "updated nav data".
  //  }

    if (time:seconds >= last_calc + .5) {
      print "speed: " +  round(speed, 1) + " m/s, pitch: " + round(tilt) + ", twr: " + round(twr, 2) + "apo: " + round(alt:APOAPSIS) + "            " at (0, 0).
      print "========================================" at (0, 1).
      set last_calc to time:seconds.
    }
    //wait 1.
  }

  print "Desired Orbital Speed: " + round(desired_v, 1) + "m/s, Desired Orbit: " + round(orbit_alt) + "m".
  print "Final Speed: " + round(speed, 1) + "m/s, Final Apoapsis: " + round(alt:APOAPSIS) + "m" + ", Final Periapsis: " + round(alt:periapsis) + "m".

  lock steering to prograde.
  lock throttle to 0.

  until ship:altitude > 70000 {
      if alt:APOAPSIS < orbit_alt {
        lock throttle to .05.
      } else if alt:APOAPSIS >= orbit_alt {
        lock throttle to 0.
      }
  }

  print "Desired Orbital Speed: " + round(desired_v, 1) + "m/s, Desired Orbit: " + round(orbit_alt) + "m".
  print "Final Speed: " + round(speed, 1) + "m/s, Final Apoapsis: " + round(alt:APOAPSIS) + "m" + ", Final Periapsis: " + round(alt:periapsis) + "m".


  unlock steering.
  unlock throttle.
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

  if twr_list:length > 0 {
    set sum_twr to 0.
    for ttwr in twr_list {
      set sum_twr to sum_twr + ttwr.
    }
    print "Average TWR: " + round(sum_twr / twr_list:length, 2).
  }


  if alt:periapsis < orbit_alt {
    set node to node(time:seconds + eta:apoapsis, 0, 0, 1).
    add node.
    set inc to 10.
    until node:orbit:periapsis >= orbit_alt and inc >= .1{
      print "peri: " + node:orbit:periapsis.
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
