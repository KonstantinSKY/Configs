local group = vim.api.nvim_create_augroup("sky_nvim", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    local row, _ = unpack(vim.api.nvim_buf_get_mark(args.buf, '"'))
    if row > 0 and row <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, { row, 0 })
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(args)
    local ignored = {
      diff = true,
      gitcommit = true,
      markdown = true,
      text = true,
    }

    if ignored[vim.bo[args.buf].filetype] then
      return
    end

    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "make",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
    vim.bo.softtabstop = 0
    vim.bo.shiftwidth = 8
  end,
})
