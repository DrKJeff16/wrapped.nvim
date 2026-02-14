local M = {}

function M.log(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'wrapped.nvim' })
end

return M
