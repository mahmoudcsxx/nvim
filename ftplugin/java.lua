-- Java LSP via nvim-jdtls (runs per buffer, not globally)
local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then return end

local data = vim.fn.stdpath("data")
local mason_jdtls = data .. "/mason/packages/jdtls"

-- Find the equinox launcher jar
local launcher = vim.fn.glob(mason_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher == "" then
  vim.notify("jdtls launcher not found — run :Mason to install jdtls", vim.log.levels.WARN)
  return
end

-- Per-project workspace (isolate each project's index)
local root_markers = { "pom.xml", "build.gradle", ".git", "mvnw", "gradlew", ".classpath", ".project" }
local root_dir = jdtls.setup.find_root(root_markers)
if not root_dir or root_dir == "" then
  root_dir = vim.fn.getcwd()
end
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = data .. "/jdtls-workspace/" .. project_name

-- Collect debug/test bundles from Mason
local bundles = {}
local debug_jar = vim.fn.glob(
  data .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
)
if debug_jar ~= "" then
  table.insert(bundles, debug_jar)
end

local test_jars = vim.fn.glob(
  data .. "/mason/packages/java-test/extension/server/*.jar", true, true
)
vim.list_extend(bundles, test_jars)

local lsputil = require("util.lsp")
local capabilities = lsputil.capabilities()

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher,
    "-configuration", mason_jdtls .. "/config_linux",
    "-data", workspace_dir,
  },
  root_dir = root_dir,
  capabilities = capabilities,
  init_options = { bundles = bundles },

  settings = {
    java = {
      eclipse = { downloadSources = true },
      configuration = { updateBuildConfiguration = "interactive" },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      format = { enabled = true },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        filteredTypes = {
          "com.sun.*", "io.micrometer.shaded.*",
          "java.awt.*", "jdk.*", "sun.*",
        },
        importOrder = { "java", "javax", "com", "org" },
      },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },

  on_attach = function(client, bufnr)
    lsputil.on_attach(client, bufnr)

    -- Java-specific keymaps
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "Java: " .. desc })
    end

    map("<leader>jo", function() jdtls.organize_imports() end, "Organize imports")
    map("<leader>jt", function() jdtls.test_class() end, "Test class")
    map("<leader>jT", function() jdtls.test_nearest_method() end, "Test nearest method")
    map("<leader>je", function() jdtls.extract_variable() end, "Extract variable")
    map("<leader>jE", function() jdtls.extract_constant() end, "Extract constant")

    vim.keymap.set("v", "<leader>jm", function()
      jdtls.extract_method(true)
    end, { buffer = bufnr, desc = "Java: Extract method" })

    -- Enable DAP for Java
    if #bundles > 0 then
      jdtls.setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end
  end,
}

jdtls.start_or_attach(config)
