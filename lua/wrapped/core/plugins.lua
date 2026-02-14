local M = {}

---@return number
function M.get_count()
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    return 0
  end
  return lazy.stats().count
end

return M
