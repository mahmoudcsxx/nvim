local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("hguard", fmt("#pragma once\n\n{}", { i(0) })),

  s("main", fmt(
    "#include <iostream>\n\nint main(int argc, char* argv[]) {{\n    {}\n    return 0;\n}}",
    { i(0) }
  )),

  s("cp", fmt(
    "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {{\n    ios_base::sync_with_stdio(false);\n    cin.tie(NULL);\n\n    {}\n\n    return 0;\n}}",
    { i(0) }
  )),

  s("cls", fmt(
    "class {name} {{\npublic:\n    {name2}() = default;\n    ~{name3}() = default;\n\n    {body}\nprivate:\n}};",
    { name = i(1, "MyClass"), name2 = rep(1), name3 = rep(1), body = i(0) }
  )),

  s("struct", fmt(
    "struct {name} {{\n    {body}\n}};",
    { name = i(1, "MyStruct"), body = i(0) }
  )),

  s("ns", fmt(
    "namespace {name} {{\n\n{body}\n\n}} // namespace {name2}",
    { name = i(1, "my_ns"), body = i(0), name2 = rep(1) }
  )),

  s("forr", fmt(
    "for (auto& {var} : {container}) {{\n    {body}\n}}",
    { var = i(1, "elem"), container = i(2, "vec"), body = i(0) }
  )),

  s("fori", fmt(
    "for (int {var} = 0; {var2} < {size}; ++{var3}) {{\n    {body}\n}}",
    { var = i(1, "i"), var2 = rep(1), size = i(2, "n"), var3 = rep(1), body = i(0) }
  )),

  s("lam", fmt(
    "auto {name} = [{cap}]({params}) -> {ret} {{\n    {body}\n}};",
    { name = i(1, "fn"), cap = i(2), params = i(3), ret = i(4, "void"), body = i(0) }
  )),

  s("vec", fmt(
    "std::vector<{type}> {name}{init};",
    { type = i(1, "int"), name = i(2, "v"), init = i(3) }
  )),

  s("map", fmt(
    "std::unordered_map<{key}, {val}> {name};",
    { key = i(1, "std::string"), val = i(2, "int"), name = i(3, "m") }
  )),

  s("uptr", fmt(
    "auto {name} = std::make_unique<{type}>({args});",
    { name = i(1, "ptr"), type = i(2, "MyClass"), args = i(0) }
  )),

  s("sptr", fmt(
    "auto {name} = std::make_shared<{type}>({args});",
    { name = i(1, "ptr"), type = i(2, "MyClass"), args = i(0) }
  )),

  s("cout", fmt(
    "std::cout << {val} << '\\n';",
    { val = i(1, '"Hello"') }
  )),

  s("tpl", fmt(
    "template <{params}>\n{body}",
    { params = i(1, "typename T"), body = i(0) }
  )),

  s("enum", fmt(
    "enum class {name} {{\n    {body}\n}};",
    { name = i(1, "MyEnum"), body = i(0) }
  )),
}
