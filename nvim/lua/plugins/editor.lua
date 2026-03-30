local function open_files()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.uv.cwd()
  else
    path = vim.fn.fnamemodify(path, ":p:h")
  end

  require("mini.files").open(path, true)
end

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
      },
    },
  },
  {
    "nvim-mini/mini.nvim",
    branch = "stable",
    config = function()
      require("mini.ai").setup()
      require("mini.bracketed").setup()
      require("mini.bufremove").setup()
      require("mini.comment").setup()
      require("mini.files").setup()
      require("mini.indentscope").setup({
        symbol = "|",
      })
      require("mini.pairs").setup()
      require("mini.pick").setup()
      require("mini.statusline").setup({
        use_icons = false,
      })
      require("mini.surround").setup()

      vim.keymap.set("n", "<leader>e", open_files, { desc = "File explorer" })
      vim.keymap.set("n", "<C-n>", open_files, { desc = "File explorer" })

      vim.keymap.set("n", "<leader>ff", function()
        MiniPick.builtin.files()
      end, { desc = "Find files" })

      vim.keymap.set("n", "<leader>fg", function()
        MiniPick.builtin.grep_live()
      end, { desc = "Live grep" })

      vim.keymap.set("n", "<leader>fb", function()
        MiniPick.builtin.buffers()
      end, { desc = "Find buffers" })

      vim.keymap.set("n", "<leader>fh", function()
        MiniPick.builtin.help()
      end, { desc = "Find help" })

      vim.keymap.set("n", "<leader>bd", function()
        MiniBufremove.delete()
      end, { desc = "Delete buffer" })
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gwrite",
      "Gread",
    },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
    },
  },
}
