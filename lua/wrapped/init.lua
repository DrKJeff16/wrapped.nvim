local config = require 'wrapped.config'

local M = {}

M.config = config.defaults

---@param opts table?
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.run()
  local git = require 'wrapped.core.git'
  local plugins = require 'wrapped.core.plugins'

  local commits = git.get_commits()
  local total_count = git.get_total_count()
  local plugin_count = plugins.get_count()

  require('wrapped.ui.ui').open(commits, total_count, plugin_count)
end

return M
