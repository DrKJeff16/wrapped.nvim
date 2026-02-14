local config = require 'wrapped.config'

local M = {}

M.config = config.defaults

---@class WrappedConfig
---@field enabled boolean

---@param opts WrappedConfig?
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.run()
  if M.config.enabled then
    local git = require 'wrapped.core.git'
    local commits = git.get_commits()
    local total_count = git.get_total_count()

    require('wrapped.ui.ui').open(commits, total_count)
  else
    print 'wrapped.nvim is disabled'
  end
end

return M
