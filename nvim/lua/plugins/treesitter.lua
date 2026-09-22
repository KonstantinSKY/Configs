return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    main = "nvim-treesitter.configs",
    init = function()
      vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/treesitter-parsers")
    end,
    opts = {
      parser_install_dir = vim.fn.stdpath("data") .. "/treesitter-parsers",
      ensure_installed = {
        "bash",
        "diff",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = false,
      highlight = {
        enable = true,
      },
    },
  },
}
