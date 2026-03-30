local M = {}

function M.setup()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    virtual_text = {
      source = "if_many",
      spacing = 2,
    },
    float = {
      source = "if_many",
      border = "rounded",
    },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("sky_nvim_lsp", { clear = true }),
    callback = function(args)
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, {
          buffer = args.buf,
          desc = desc,
        })
      end

      map("gd", vim.lsp.buf.definition, "LSP definition")
      map("gD", vim.lsp.buf.declaration, "LSP declaration")
      map("gi", vim.lsp.buf.implementation, "LSP implementation")
      map("gr", vim.lsp.buf.references, "LSP references")
      map("K", vim.lsp.buf.hover, "LSP hover")
      map("<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      map("<leader>cf", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, "Format buffer")
    end,
  })

  local servers = {
    bashls = "bash-language-server",
    jsonls = "vscode-json-language-server",
    lua_ls = "lua-language-server",
    marksman = "marksman",
    pyright = "pyright-langserver",
    rust_analyzer = "rust-analyzer",
    taplo = "taplo",
    yamlls = "yaml-language-server",
  }

  for server, bin in pairs(servers) do
    local opts = {
      capabilities = capabilities,
    }

    if server == "lua_ls" then
      opts.settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      }
    end

    vim.lsp.config(server, opts)

    if vim.fn.executable(bin) == 1 then
      vim.lsp.enable(server)
    end
  end
end

return M
