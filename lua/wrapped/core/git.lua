local Job = require 'plenary.job'

local M = {}

local config_path = vim.fn.stdpath 'config'

---@return string[]
function M.get_commits()
  local job = Job:new {
    command = 'git',
    args = { 'log', '-n', '5', '--oneline' },
    cwd = config_path,
  }

  job:sync()
  return job:result()
end

---@return string
function M.get_total_count()
  local job = Job:new {
    command = 'git',
    args = { 'rev-list', '--count', 'HEAD' },
    cwd = config_path,
  }

  job:sync()
  return job:result()[1] or '0'
end

return M
