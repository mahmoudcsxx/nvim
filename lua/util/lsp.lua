local M = {}

M.on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("n", "gd", function() require("telescope.builtin").lsp_definitions() end, "Go to Definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  map("n", "gr", function() require("telescope.builtin").lsp_references() end, "References")
  map("n", "gi", function() require("telescope.builtin").lsp_implementations() end, "Go to Implementation")
  map("n", "gt", function() require("telescope.builtin").lsp_type_definitions() end, "Go to Type Definition")
  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
  map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, "Document Symbols")
  map("n", "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end, "Workspace Symbols")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")

  -- Inlay hints (Neovim 0.10+)
  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    map("n", "<leader>uh", function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    end, "Toggle Inlay Hints")
  end

  -- Highlight symbol under cursor
  if client.supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("lsp_highlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

M.capabilities = function()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    caps = vim.tbl_deep_extend("force", caps, cmp_lsp.default_capabilities())
  end
  caps.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
  return caps
end

return M
