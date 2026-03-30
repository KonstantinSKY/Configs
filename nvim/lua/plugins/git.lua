return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "^" },
        changedelete = { text = "~" },
      },
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)

      local gs = require("gitsigns")
      local map = vim.keymap.set

      map("n", "]h", gs.next_hunk, { desc = "Next git hunk" })
      map("n", "[h", gs.prev_hunk, { desc = "Previous git hunk" })
      map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
      map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
      map("n", "<leader>gb", gs.blame_line, { desc = "Blame line" })
    end,
  },
}
