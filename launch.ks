@lazyglobal off.

parameter orbit_alt.

launch(orbit_alt).

function launch {
  parameter orbit_alt.

  ///
  function orbital_speed_at_altitude {
    parameter altitude, mu, radius.

    local gravity_at_sea_level to  body:mu / (body:radius) ^ 2.
    print "g at sea: " + gravity_at_sea_level + " m/s^2".
    return body:radius * sqrt(gravity_at_sea_level / (body:radius + altitude)).
  }

  ///
  function orbital_speed_at_altitude {
    parameter altitude, mu, radius.

    set gravity_at_sea_level to  body:mu / (body:radius) ^ 2.
    print "g at sea: " + ghere + " m/s^2".
    return body:radius * sqrt(gravity_at_sea_level / (body:radius + altitude)).
  }

  ///
  function calc_angle {
    parameter v, pitch, twr3.
    //print "twr3=" + twr3.
    return v * tan(pitch/2) ^ (twr3*1) / abs(sin(pitch)).
  }

  ///
  function calc {
    parameter twr2, desired_v.

    local aa to 1.
    local v to list().
    v:add(0).
    until aa > 90 {
      local aa5 to calc_angle(desired_v, aa, twr2).
      v:add(aa5).
      set aa to aa + 1.
    }

    return v.
  }

  ///
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

  ///
  function check_stage {
    local staged to False.
    until ship:maxthrust > 0 {
      PRINT "Out of fuel. Staging.".
      STAGE.
      wait 1.
      set staged to True.
   }
   return staged.
  }

  function ascend {
    parameter twr_list, desired_v.
    lock throttle to 1.

    local ship_gravity to body:mu / ((ship:altitude + body:radius)^2).
    //lock a to body:mu * (body:radius / (body:radius + ship:altitude)) ^ 2.
    local twr to SHIP:AVAILABLETHRUST / (SHIP:MASS * ship_gravity).
    print "m: " + SHIP:MASS + ", g: " + ship_gravity + ", T: " + SHIP:AVAILABLETHRUST + ", twr: " + twr.
    print "desired velocity: " + desired_v + " m/s".
    //local v to list().
    local v to calc(twr, desired_v).

    local angle is 0.
    for var in v {
      print "speed: " + var + ", angle: " + angle.
      set angle to angle + 1.
    }
    print "=========================".
    lock speed to SHIP:VELOCITY:surface:mag.
    local tt to 0.
    lock throttle to 1.
    local last_calc to 0.
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
      if check_stage() or v:length = 0 {
        local z is twr.
        set v to calc(z, desired_v).
      }
      local tilt to 90 - getAngle(speed, twr, v, desired_v).
      set tt to tilt.

      if (time:seconds >= last_calc + .5) {
        print "speed: " +  round(speed, 1) + " m/s, pitch: " + round(tilt) + ", twr: " + round(twr, 2) + "apo: " + round(alt:APOAPSIS) + "            " at (0, 0).
        print "========================================" at (0, 1).
        set last_calc to time:seconds.
      }
    }
  }

  function coast {
    parameter orbital_speed, orbit_alt.

    lock steering to heading(90, 0).
    lock throttle to 0.
    //local lock speed to SHIP:VELOCITY:surface:mag.
    local lock reached_altitude to alt:apoapsis >= orbit_alt.
    until ship:altitude > 70000 {
        print "speed: " + speed + ", orbital_speed: " + orbital_speed.
        if reached_altitude {
          lock throttle to 0.
        } else {
          lock throttle to 0.05.
        }
    }
  }

  function stop {
    unlock steering.
    unlock throttle.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  }

  function circularize {
    parameter orbit_alt.
    if alt:periapsis < orbit_alt {
      local node to node(time:seconds + eta:apoapsis, 0, 0, 1).
      add node.
      local inc to 10.
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

  ///
  function report {
    parameter desired_v, orbit_alt, twr_list, speed.

    print "Desired Orbital Speed: " + round(desired_v, 1) + "m/s, Desired Orbit: " + round(orbit_alt) + "m".
    print "Final Speed: " + round(speed, 1) + "m/s, Final Apoapsis: " + round(alt:APOAPSIS) + "m" + ", Final Periapsis: " + round(alt:periapsis) + "m".
    if twr_list:length > 0 {
      local sum_twr to 0.
      for ttwr in twr_list {
        set sum_twr to sum_twr + ttwr.
      }
      print "Average TWR: " + round(sum_twr / twr_list:length, 2).
    }
  }

  /// MAIN
  local twr_list to list().
  local desired_v to orbital_speed_at_altitude(orbit_alt, body:mu, body:radius).

  ascend(twr_list, desired_v).
  coast(desired_v, orbit_alt).
  stop().
  circularize(orbit_alt).
  report(desired_v, orbit_alt, twr_list, SHIP:VELOCITY:orbit:mag).
}
