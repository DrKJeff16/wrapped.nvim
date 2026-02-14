local Job = require "plenary.job"
local M = {}

local function get_path() return require("wrapped").config.path end

local function exec_git(args)
  local job = Job:new {
    command = "git",
    args = args,
    cwd = get_path(),
  }
  job:sync()
  return job:result()
end

---@return string[]
function M.get_commits()
  local all = exec_git { "log", "--format=%s" }
  if #all <= 5 then return all end

  local random_commits = {}
  local indices = {}
  while #indices < 5 do
    local idx = math.random(1, #all)
    if not vim.tbl_contains(indices, idx) then
      table.insert(indices, idx)
      table.insert(random_commits, all[idx])
    end
  end
  return random_commits
end

---@return string
function M.get_total_count()
  return exec_git({ "rev-list", "--count", "HEAD" })[1] or "0"
end

---@return string
function M.get_first_commit_date()
  return exec_git({ "log", "--reverse", "--format=%ad", "--date=short" })[1]
    or "Unknown"
end

-- converts seconds to human-readable
local function format_ago(secs)
  local days = math.floor(secs / 86400)
  if days >= 365 then return string.format("%.1f years ago", days / 365) end
  if days >= 30 then return math.floor(days / 30) .. " months ago" end
  if days >= 1 then return days .. " days ago" end
  local hours = math.floor(secs / 3600)
  if hours >= 1 then return hours .. " hours ago" end
  return math.floor(secs / 60) .. " minutes ago"
end

---@return Wrapped.ConfigStats
function M.get_config_stats()
  local dates = exec_git { "log", "--format=%ad", "--date=short" }
  local unique = {}
  for _, d in ipairs(dates) do
    unique[d] = true
  end

  -- sort unique dates
  local sorted = {}
  for d in pairs(unique) do
    table.insert(sorted, d)
  end
  table.sort(sorted)

  -- longest consecutive day streak
  local max_streak, cur_streak = 1, 1
  for i = 2, #sorted do
    local y, m, d = sorted[i]:match "(%d+)-(%d+)-(%d+)"
    local py, pm, pd = sorted[i - 1]:match "(%d+)-(%d+)-(%d+)"
    local t1 = os.time { year = y, month = m, day = d }
    local t0 = os.time { year = py, month = pm, day = pd }
    if math.abs(t1 - t0) <= 86400 then
      cur_streak = cur_streak + 1
    else
      cur_streak = 1
    end
    if cur_streak > max_streak then max_streak = cur_streak end
  end

  local now = os.time()

  -- time since last change
  local last = dates[1]
  local last_change = "Unknown"
  if last then
    local y, m, d = last:match "(%d+)-(%d+)-(%d+)"
    if y and m and d then
      last_change = format_ago(
        now
          - os.time { year = tonumber(y), month = tonumber(m), day = tonumber(d) }
      )
    end
  end

  -- config lifetime from first commit
  local first = sorted[1]
  local lifetime = "Unknown"
  if first then
    local y, m, d = first:match "(%d+)-(%d+)-(%d+)"
    if y and m and d then
      local age_days = (
        now
        - os.time { year = tonumber(y), month = tonumber(m), day = tonumber(d) }
      ) / 86400
      if age_days >= 365 then
        lifetime = string.format("%.1f years old", age_days / 365)
      elseif age_days >= 30 then
        lifetime = math.floor(age_days / 30) .. " months old"
      else
        lifetime = math.floor(age_days) .. " days old"
      end
    end
  end

  local subjects = exec_git { "log", "--format=%s" }
  local shortest, longest = subjects[1] or "", subjects[1] or ""
  for _, s in ipairs(subjects) do
    if #s < #shortest and #s > 0 then shortest = s end
    if #s > #longest then longest = s end
  end

  return {
    longest_streak = #sorted > 0 and max_streak or 0,
    last_change = last_change,
    lifetime = lifetime,
    shortest_msg = shortest,
    longest_msg = longest,
  }
end

-- commit count per day for a given year, keyed as ddmmyyyy
---@param year number
---@return table<string, number>
function M.get_commit_activity(year)
  local dates = exec_git { "log", "--format=%ad", "--date=short" }
  local yr = tostring(year)
  local counts = {}
  for _, d in ipairs(dates) do
    local y, m, day = d:match "(%d+)-(%d+)-(%d+)"
    if y == yr then
      local key = day .. m .. y
      counts[key] = (counts[key] or 0) + 1
    end
  end
  return counts
end

---@return number
function M.get_first_commit_year()
  local d = M.get_first_commit_date()
  local y = d:match "(%d+)"
  return tonumber(y) or tonumber(os.date "%Y")
end

-- sample ~12 commits and get total line count at each point
---@return { values: number[], labels: string[] }
function M.get_size_history()
  local log = exec_git { "log", "--reverse", "--format=%H %ad", "--date=short" }
  if #log == 0 then return { values = {}, labels = {} } end

  -- get the empty tree hash for this repo
  local empty = Job:new {
    command = "git",
    args = { "hash-object", "-t", "tree", "/dev/null" },
    cwd = get_path(),
  }
  empty:sync()
  local empty_tree = (empty:result()[1] or ""):match "%S+"

  -- sample ~20 evenly spaced commits
  local samples = {}
  local step = math.max(1, math.floor(#log / 49))
  for i = 1, #log, step do
    table.insert(samples, log[i])
  end
  -- always include latest
  if #samples > 0 and samples[#samples] ~= log[#log] then
    table.insert(samples, log[#log])
  end

  local values, labels = {}, {}
  for _, entry in ipairs(samples) do
    local hash, date = entry:match "(%S+)%s+(%S+)"
    if hash and empty_tree then
      local stat = exec_git { "diff", "--shortstat", empty_tree, hash }
      local ins = (stat[1] or ""):match "(%d+) insertion"
      table.insert(values, tonumber(ins) or 0)
      table.insert(labels, date)
    end
  end

  return { values = values, labels = labels }
end

return M
