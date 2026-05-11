local M = {}

local function float_term(cmd)
  require("toggleterm.terminal").Terminal:new({
    cmd       = cmd,
    direction = "float",
    close_on_exit = false,
    float_opts = {
      border = "curved",
      width  = math.floor(vim.o.columns * 0.88),
      height = math.floor(vim.o.lines   * 0.82),
    },
    on_open = function() vim.cmd("startinsert!") end,
  }):toggle()
end

local function has(path) return vim.fn.filereadable(path) == 1 end
local function glob(pat) return vim.fn.glob(pat) ~= "" end

-- Returns the best source file to compile for C/C++ single-file mode.
-- Prefers the current file if it has main(); otherwise falls back to
-- main.cpp / main.c in the project root or the file's own directory.
local function resolve_c_src(ft, current_file, cwd, fdir)
  local buf_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if buf_text:find("int%s+main%s*%(") then
    return current_file, vim.fn.expand("%:t:r")
  end

  local ext = ft == "cpp" and "cpp" or "c"
  local candidates = {
    cwd  .. "/main." .. ext,
    fdir .. "/main." .. ext,
  }
  for _, c in ipairs(candidates) do
    if has(c) then
      return c, "main"
    end
  end

  return nil, nil
end

local function run_cmd()
  local ft   = vim.bo.filetype
  local f    = vim.fn.expand("%:p")
  local stem = vim.fn.expand("%:t:r")
  local fdir = vim.fn.expand("%:p:h")
  local cwd  = vim.fn.getcwd()

  if ft == "python" then
    return "python " .. vim.fn.shellescape(f)

  elseif ft == "cpp" then
    if has(cwd .. "/Makefile") then
      return "make && (make run 2>/dev/null || true)"
    elseif has(cwd .. "/CMakeLists.txt") then
      return ("cmake --build build -j$(nproc 2>/dev/null || echo 4) && ./build/%s"):format(stem)
    end
    local src, out_stem = resolve_c_src(ft, f, cwd, fdir)
    if not src then
      return nil, "No main() found — add a main() or use a Makefile/CMakeLists.txt"
    end
    local tmp = "/tmp/nvim_" .. out_stem
    return ("g++ -std=c++17 -O2 -Wall -o %s %s && %s"):format(tmp, src, tmp)

  elseif ft == "c" then
    if has(cwd .. "/Makefile") then return "make" end
    local src, out_stem = resolve_c_src(ft, f, cwd, fdir)
    if not src then
      return nil, "No main() found — add a main() or use a Makefile"
    end
    local tmp = "/tmp/nvim_" .. out_stem
    return ("gcc -O2 -Wall -o %s %s && %s"):format(tmp, src, tmp)

  elseif ft == "java" then
    if glob(cwd .. "/pom.xml")      then return "mvn -q compile exec:java" end
    if has(cwd .. "/gradlew")       then return "./gradlew run" end
    if glob(cwd .. "/build.gradle") then return "gradle run" end
    return ("javac %s && java -cp %s %s"):format(f, fdir, stem)

  elseif ft == "cs" then
    return "dotnet run"

  elseif ft == "lua" then
    return "lua " .. vim.fn.shellescape(f)

  elseif ft == "sh" or ft == "bash" then
    return "bash " .. vim.fn.shellescape(f)

  elseif ft == "javascript" then
    if has(cwd .. "/package.json") then return "npm start" end
    return "node " .. vim.fn.shellescape(f)

  elseif ft == "typescript" then
    return "ts-node " .. vim.fn.shellescape(f)
  end
end

local function build_cmd()
  local ft   = vim.bo.filetype
  local f    = vim.fn.expand("%:p")
  local cwd  = vim.fn.getcwd()
  local fdir = vim.fn.expand("%:p:h")

  if ft == "cpp" then
    if has(cwd .. "/Makefile") then return "make" end
    if has(cwd .. "/CMakeLists.txt") then
      return "cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j$(nproc 2>/dev/null || echo 4)"
    end
    local src, out_stem = resolve_c_src(ft, f, cwd, fdir)
    if not src then
      return nil, "No main() found — add a main() or use a Makefile/CMakeLists.txt"
    end
    return ("g++ -std=c++17 -O2 -Wall -o /tmp/nvim_%s %s"):format(out_stem, src)

  elseif ft == "c" then
    if has(cwd .. "/Makefile") then return "make" end
    local src, out_stem = resolve_c_src(ft, f, cwd, fdir)
    if not src then
      return nil, "No main() found — add a main() or use a Makefile"
    end
    return ("gcc -O2 -Wall -o /tmp/nvim_%s %s"):format(out_stem, src)

  elseif ft == "java" then
    if glob(cwd .. "/pom.xml")  then return "mvn -q compile" end
    if has(cwd .. "/gradlew")   then return "./gradlew build" end
    return "javac " .. f

  elseif ft == "cs" then
    return "dotnet build"

  elseif ft == "python" then
    return "python -m py_compile " .. vim.fn.shellescape(f) .. " && echo '✓ Syntax OK'"
  end
end

-- Build then run (the primary action — maps to <F5>)
function M.run()
  local cmd, err = run_cmd()
  if not cmd then
    vim.notify(err or ("No runner for: " .. vim.bo.filetype), vim.log.levels.WARN, { title = "Build & Run" })
    return
  end
  float_term(cmd)
end

-- Compile only, no execution (accessible via <leader>rb)
function M.build_only()
  local cmd, err = build_cmd()
  if not cmd then
    vim.notify(err or ("No build command for: " .. vim.bo.filetype), vim.log.levels.WARN, { title = "Build" })
    return
  end
  float_term(cmd)
end

return M
