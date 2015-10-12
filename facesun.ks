print "Orientating ship towards sun.".
lock steering to sun:position.

//  info("Setting course").
local np to lookdirup(sun:position, SHIP:FACING:TOPVECTOR).
lock steering to np.
wait until abs(np:PITCH - SHIP:FACING:PITCH) < 0.05 and abs(np:yaw - SHIP:FACING:YAW) < 0.05.
