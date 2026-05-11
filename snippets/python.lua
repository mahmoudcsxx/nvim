local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("def", fmt(
    "def {name}({params}) -> {ret}:\n    {body}",
    { name = i(1, "function_name"), params = i(2), ret = i(3, "None"), body = i(0) }
  )),

  s("async", fmt(
    "async def {name}({params}) -> {ret}:\n    {body}",
    { name = i(1, "function_name"), params = i(2), ret = i(3, "None"), body = i(0) }
  )),

  s("cls", fmt(
    "class {name}:\n    def __init__(self{params}) -> None:\n        {body}",
    { name = i(1, "MyClass"), params = i(2), body = i(0) }
  )),

  s("dc", fmt(
    "from dataclasses import dataclass, field\n\n\n@dataclass\nclass {name}:\n    {body}",
    { name = i(1, "MyData"), body = i(0) }
  )),

  s("main", fmt(
    "def main() -> None:\n    {body}\n\n\nif __name__ == \"__main__\":\n    main()",
    { body = i(0) }
  )),

  s("test", fmt(
    "def test_{name}() -> None:\n    # Arrange\n    {arrange}\n    # Act\n    {act}\n    # Assert\n    assert {assert_expr}",
    { name = i(1, "something"), arrange = i(2), act = i(3), assert_expr = i(0, "True") }
  )),

  s("prop", fmt(
    "@property\ndef {name}(self) -> {type}:\n    return self._{field}\n\n@{name2}.setter\ndef {name3}(self, value: {type2}) -> None:\n    self._{field2} = value",
    { name = i(1, "value"), type = i(2, "str"), field = i(3, "value"),
      name2 = rep(1), name3 = rep(1), type2 = rep(2), field2 = rep(3) }
  )),

  s("ctx", fmt(
    "with {expr} as {var}:\n    {body}",
    { expr = i(1, "open('file')"), var = i(2, "f"), body = i(0) }
  )),

  s("lc", fmt(
    "[{expr} for {var} in {iter}{cond}]",
    { expr = i(1, "x"), var = i(2, "x"), iter = i(3, "items"), cond = i(4) }
  )),

  s("try", fmt(
    "try:\n    {body}\nexcept {exc} as e:\n    {handler}",
    { body = i(1), exc = i(2, "Exception"), handler = i(0) }
  )),

  s("env", fmt(
    "import os\n\n{name} = os.getenv(\"{key}\", \"{default}\")",
    { name = i(1, "value"), key = i(2, "MY_VAR"), default = i(3) }
  )),

  s("log", fmt(
    "import logging\n\nlogger = logging.getLogger(__name__)\n\n{body}",
    { body = i(0) }
  )),

  s("typed", fmt(
    "from typing import {types}\n\n{body}",
    { types = i(1, "Any, Optional, List, Dict"), body = i(0) }
  )),
}
