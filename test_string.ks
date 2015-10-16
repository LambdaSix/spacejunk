run lib_string.

function assertEquals {
  parameter actual, expected.

  if actual <> expected {
    print "FAIL: expected <" + expected + ">, but was <" + actual + ">".
  }
  print "PASS: expected <" + expected + ">, and was <" + actual + ">".
}

assertEquals(strlen(""), 0).
assertEquals(strlen(" "), 1).
assertEquals(strlen("  "), 2).
assertEquals(strlen(1), 1).
assertEquals(strlen(5.8), 3).
assertEquals(strlen(-1), 2).

assertEquals(lpad("", 1), " ").
assertEquals(lpad(1, 5), "    1").
assertEquals(lpad(1.2, 4), " 1.2").
assertEquals(lpad("abcde", 1), "abcde").

assertEquals(rpad("", 1), " ").
assertEquals(rpad(1, 5), "1    ").
assertEquals(rpad(1.2, 4), "1.2 ").
assertEquals(rpad("abcde", 1), "abcde").
