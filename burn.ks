@lazyglobal off.

function burn_sequence {
  local start_time is time:seconds.
  local state is "idle".
  local lock max_acc to ship:maxthrust / ship:mass.
  local node to NEXTNODE.
  local lock dv to node:deltav:mag.
  local lock burn_start to node:eta - burn_duration / 2.

  function stop {
    unlock steering.
    unlock throttle.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  }

  function set_state {
    parameter new_state.

    set state to new_state.
    update_hud(True).
  }

  function warpfor {
    parameter warp_duration.

    if warp_duration <= 0 {
      return.
    }

    set_state("warping").
    local end_warp_time is TIME:SECONDS + warp_duration.

    info("Warping for " + ROUND(warp_duration) + "s").

    warpto(end_warp_time).
  }

  function set_course {
    parameter node.

    set_state("setting course").
    info("Setting course").
    local np to lookdirup(node:DELTAV, SHIP:FACING:TOPVECTOR).
    lock steering to np.
    local lock on_course to abs(np:PITCH - SHIP:FACING:PITCH) < 0.15 and abs(np:yaw - SHIP:FACING:YAW) < 0.15.
    until on_course {
      update_hud(False).
    }
  }

  function burn {
    parameter node.

    set_state("burning").
    info("Ignition").
    //we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
    local tset is 0.
    lock throttle to tset.

    //initial deltav
    local dv0 is node:deltav.
    //local max_acc to ship:maxthrust / ship:mass.
    local lock very_close to node:deltav:mag < 0.1.
    local lock direction_reversed to vdot(dv0, node:deltav) < 0.
    local lock node_has_drifted to vdot(dv0, node:deltav) < 0.5.

    until False
    {
        //throttle is 100% until there is less than 1 second of time left to burn
        //when there is less than 1 second - decrease the throttle linearly
        set tset to min(node:deltav:mag / max_acc, 1).
        update_hud(False).
        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        if direction_reversed
        {
          set_state("ending").

            break.
        }

        //we have very little left to burn, less then 0.1m/s
        if very_close
        {
          set_state("finalizing").
            info("Finalizing burn, remain dv " + round(node:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, node:deltav),1)).
            //we burn slowly until our node vector starts to drift significantly from initial vector

            //this usually means we are on point
            until node_has_drifted {
                update_hud(False).
            }

            break.
        }
    }

    lock throttle to 0.
    info("Burn complete; remainaining dv: " + round(node:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, node:deltav),1)).
  }

  function info {
    parameter message.

    print round(time:seconds - start_time) + ": " + message.
  }

  function ttime {
    parameter t.

    if t >= 0 {
      return "T-" + round(t) + "s".
    }

    return "T+" + round(t * -1) + "s".
  }

  local last_print is 0.
  local lock burn_duration to dv / max_acc.

  function update_hud {
    parameter force.

    if force or time:seconds > last_print + .5 {
      print "state: " + state + "               " at (0, 0).
      print "dv: " + round(dv) + "m/s" + ", start: " + ttime(burn_start) + ", remaining time: " + round(burn_duration) + "s" + "          " at (0, 1).
      print "========================================" at (0, 2).
      set last_print to time:seconds.
    }
  }

  ////////////
  // MAIN
  ////////////
  clearscreen.
  print ".".
  print ".".
  print ".".
  update_hud(True).

  lock steering to sun:position.
  warpfor(burn_start - 60).
  wait until burn_start <= 60.

  set_course(node).

  set_state("waiting").
  until burn_start <= 0 {
    update_hud(False).
  }

  burn(node).

  stop().
  wait 5.
  set_state("complete").
  remove node.
}

burn_sequence().
