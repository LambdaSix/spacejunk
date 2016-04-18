@lazyglobal off.

function assertEquals {
  parameter expected, actual.

  if actual <> expected {
    print "FAIL: expected <" + expected + ">, but was <" + actual + ">".
  } else {
    print "PASS: expected <" + expected + ">, and was <" + actual + ">".
  }
}
