local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("cls", fmt(
    "namespace {ns};\n\npublic class {name}\n{{\n    {body}\n}}",
    { ns = i(1, "MyApp"), name = i(2, "MyClass"), body = i(0) }
  )),

  s("iface", fmt(
    "namespace {ns};\n\npublic interface {name}\n{{\n    {body}\n}}",
    { ns = i(1, "MyApp"), name = i(2, "IMyInterface"), body = i(0) }
  )),

  s("prop", fmt(
    "public {type} {name} {{ get; {set}; }}",
    { type = i(1, "string"), name = i(2, "Value"), set = i(3, "set") }
  )),

  s("propf", fmt(
    "private {type} _{field};\npublic {type2} {name}\n{{\n    get => _{field2};\n    set => _{field3} = value;\n}}",
    { type = i(1, "string"), field = i(2, "value"), type2 = rep(1),
      name = i(3, "Value"), field2 = rep(2), field3 = rep(2) }
  )),

  s("ctor", fmt(
    "public {name}({params})\n{{\n    {body}\n}}",
    { name = i(1, "MyClass"), params = i(2), body = i(0) }
  )),

  s("async", fmt(
    "public async Task{ret} {name}({params})\n{{\n    {body}\n}}",
    { ret = i(1, "<string>"), name = i(2, "DoWorkAsync"), params = i(3), body = i(0) }
  )),

  s("try", fmt(
    "try\n{{\n    {body}\n}}\ncatch ({exc} ex)\n{{\n    {handler}\n}}",
    { body = i(1), exc = i(2, "Exception"), handler = i(0) }
  )),

  s("linq", fmt(
    "var {result} = {source}\n    .Where({pred})\n    .Select({sel})\n    .ToList();",
    { result = i(1, "result"), source = i(2, "items"), pred = i(3, "x => x != null"), sel = i(0, "x => x") }
  )),

  s("test", fmt(
    "[Fact]\npublic async Task {name}()\n{{\n    // Arrange\n    {arrange}\n    // Act\n    {act}\n    // Assert\n    {assert}\n}}",
    { name = i(1, "Should_DoSomething"), arrange = i(2), act = i(3), assert = i(0) }
  )),

  s("using", fmt(
    "using var {name} = {expr};\n{body}",
    { name = i(1, "resource"), expr = i(2, "new MyResource()"), body = i(0) }
  )),

  s("rec", fmt(
    "public record {name}({params});",
    { name = i(1, "MyRecord"), params = i(0, "string Name, int Value") }
  )),

  s("sw", fmt(
    "switch ({expr})\n{{\n    case {val1}:\n        {body1}\n        break;\n    default:\n        {body2}\n        break;\n}}",
    { expr = i(1, "value"), val1 = i(2, "1"), body1 = i(3), body2 = i(0) }
  )),

  s("di", fmt(
    "private readonly {type} _{field};\n\npublic {cls}({type2} {param})\n{{\n    _{field2} = {param2};\n}}",
    { type = i(1, "IMyService"), field = i(2, "myService"), cls = i(3, "MyClass"),
      type2 = rep(1), param = rep(2), field2 = rep(2), param2 = rep(2) }
  )),
}
