@lazyglobal off.

function ttime {
  parameter t.

  if t >= 0 {
    return "T-" + round(t) + "s".
  }

  return "T+" + round(t * -1) + "s".
}
