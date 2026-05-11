local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("cls", fmt(
    "public class {name} {{\n    {body}\n}}",
    { name = i(1, "MyClass"), body = i(0) }
  )),

  s("iface", fmt(
    "public interface {name} {{\n    {body}\n}}",
    { name = i(1, "MyInterface"), body = i(0) }
  )),

  s("main", fmt(
    "public static void main(String[] args) {{\n    {body}\n}}",
    { body = i(0) }
  )),

  s("sout", fmt(
    "System.out.println({val});",
    { val = i(1, '"Hello, World!"') }
  )),

  s("serr", fmt(
    "System.err.println({val});",
    { val = i(1, '"Error: "') }
  )),

  s("forr", fmt(
    "for ({type} {var} : {iter}) {{\n    {body}\n}}",
    { type = i(1, "var"), var = i(2, "item"), iter = i(3, "list"), body = i(0) }
  )),

  s("fori", fmt(
    "for (int {var} = 0; {var2} < {size}; {var3}++) {{\n    {body}\n}}",
    { var = i(1, "i"), var2 = rep(1), size = i(2, "n"), var3 = rep(1), body = i(0) }
  )),

  s("test", fmt(
    "@Test\nvoid {name}() {{\n    // given\n    {given}\n    // when\n    {when}\n    // then\n    {then}\n}}",
    { name = i(1, "shouldDoSomething"), given = i(2), when = i(3), then = i(0) }
  )),

  s("getter", fmt(
    "public {type} get{Name}() {{\n    return {field};\n}}",
    { type = i(1, "String"), Name = i(2, "Value"), field = i(0, "value") }
  )),

  s("setter", fmt(
    "public void set{Name}({type} {field}) {{\n    this.{field2} = {field3};\n}}",
    { Name = i(1, "Value"), type = i(2, "String"), field = i(3, "value"), field2 = rep(3), field3 = rep(3) }
  )),

  s("try", fmt(
    "try {{\n    {body}\n}} catch ({exc} e) {{\n    {handler}\n}}",
    { body = i(1), exc = i(2, "Exception"), handler = i(0) }
  )),

  s("opt", fmt(
    "Optional<{type}> {name} = Optional.{method}({value});",
    { type = i(1, "String"), name = i(2, "opt"), method = i(3, "of"), value = i(0) }
  )),

  s("stream", fmt(
    "{source}.stream()\n    .filter({pred})\n    .map({mapper})\n    .collect(Collectors.toList());",
    { source = i(1, "list"), pred = i(2, "x -> x != null"), mapper = i(0, "x -> x") }
  )),

  s("rec", fmt(
    "public record {name}({params}) {{}}",
    { name = i(1, "MyRecord"), params = i(0, "String name, int value") }
  )),

  s("sw", fmt(
    "switch ({expr}) {{\n    case {val} -> {{\n        {body}\n    }}\n    default -> {{\n        {def}\n    }}\n}}",
    { expr = i(1, "value"), val = i(2, "1"), body = i(3), def = i(0) }
  )),
}
