@lazyglobal off.

function burn_sequence {

  local lock max_acc to ship:maxthrust / ship:mass.

  function stop {
    unlock steering.
    unlock throttle.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  }

  function warpfor {
    local parameter s.

    local tt is TIME:SECONDS + s.
    print "Warping for " + ROUND(tt) + "s".

    warpto(tt).
  }

  function set_course {
    local parameter node.

    print "Setting course".
    local np to lookdirup(node:DELTAV, SHIP:FACING:TOPVECTOR).
    lock steering to np.

    wait until abs(np:PITCH - SHIP:FACING:PITCH) < 0.15 and abs(np:yaw - SHIP:FACING:YAW) < 0.15.
  }

  function burn {
    local parameter node2.
    print "Ignition".
    //we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
    local tset is 0.
    lock throttle to tset.

    local done is False.
    //initial deltav
    local dv0 is node2:deltav.
    //local max_acc to ship:maxthrust / ship:mass.
    local lock very_close to node2:deltav:mag < 0.1.
    local lock direction_reversed to vdot(dv0, node2:deltav) < 0.
    local lock node_has_drifted to vdot(dv0, node2:deltav) < 0.5.
    until False
    {
        //recalculate current max_acceleration, as it changes while we burn through fuel
        //set max_acc to ship:maxthrust / ship:mass.

        //throttle is 100% until there is less than 1 second of time left to burn
        //when there is less than 1 second - decrease the throttle linearly
        set tset to min(node2:deltav:mag / max_acc, 1).

        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        if direction_reversed
        {

            break.
        }

        //we have very little left to burn, less then 0.1m/s
        if very_close
        {
            print "Finalizing burn, remain dv " + round(node2:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, node2:deltav),1).
            //we burn slowly until our node vector starts to drift significantly from initial vector

            //this usually means we are on point
            wait until node_has_drifted.

            break.
        }

    }
    print "Burn complete; remainaining dv: " + round(node2:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, node2:deltav),1).
    lock throttle to 0.
  }

  local node to NEXTNODE.
  local burn_duration to node:deltav:mag / max_acc.

  print "Node in: " + round(node:eta) + ", DeltaV: " + round(node:deltav:mag).
  print "Estimated burn duration: " + round(burn_duration) + "s".
  local lock burn_start to node:eta - burn_duration / 2.
  set_course(node).
  warpfor(burn_start - 60).
  wait until burn_start <= 60.

  print "Initiating burn in T-" + ROUND(burn_start) + "s".

  set_course(node).

  print "Initiating burn in T-" + ROUND(burn_start) + "s".

  wait until burn_start <= 0.

  burn(node).

  stop().
  wait 5.
  remove node.
}

burn_sequence().
