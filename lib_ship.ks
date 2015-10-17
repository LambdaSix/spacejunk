/// unlock controls and set throttle to 0.
function ship_stop {
  unlock steering.
  unlock throttle.
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

/// detach stage if out of fuel.
function ship_stage {
  global sj_launch_staged to False.
  when ship:maxthrust = 0 then {
    if not Stage:READY {
      preserve.
    } else {
      PRINT "Out of fuel. Staging.".
      STAGE.
      set sj_launch_staged to True.
      preserve.
    }
 }
 return sj_launch_staged.
}

// the ship's compass heading
function ship_heading {
  local northPole TO latlng(90,0).
  local head TO mod(360 - northPole:bearing,360).

  return head.
}
