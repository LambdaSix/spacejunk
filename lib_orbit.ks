@lazyglobal off.

function orbit_speed {
  parameter altitude, mu, radius.

  local gravity_at_sea_level to body:mu / (body:radius) ^ 2.

  return body:radius * sqrt(gravity_at_sea_level / (body:radius + altitude)).
}
