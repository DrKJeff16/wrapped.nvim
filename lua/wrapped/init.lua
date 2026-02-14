local config = require 'wrapped.config'
local utils = require 'wrapped.utils'

local M = {}

---@class WrappedConfig
---@field enabled boolean

---@param opts WrappedConfig?
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', config.defaults, opts or {})
end

function M.run()
  if M.config.enabled then
    print 'wrapped.nvim is active'
  else
    print 'wrapped.nvim is disabled'
  end
end

return M
