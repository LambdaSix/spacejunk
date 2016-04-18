// unit tests for lib_template
run once lib_template.
run once lib_assert.

clearscreen.

local template is template_init(
    list(
      "var: {value}"
    )
  ).

local result is parse_template(template, lexicon("value", 2)).

assertEquals("var: 2", result[0]).

local result is parse_template(template, lexicon("value", 3)).

assertEquals("var: 3", result[0]).

///////////////

local template is template_init(
    list(
      "var1: {value1} var2: {value2}",
      "var3: {value3}"
    )
  ).

local result is parse_template(template, lexicon(
    "value1", 100,
    "value2", 2,
    "value3", 3
  )).

assertEquals("var1: 100 var2: 2", result[0]).
assertEquals("var3: 3", result[1]).
