---@meta

---@class Wrapped.Config
---@field path string?
---@field border boolean
---@field size {width: number, height: number}
---@field exclude_filetype string[]
---@field cap {commits: number, plugins: number, plugins_ever: number, lines: number}

---@class Wrapped.FileStat
---@field name string
---@field lines number

---@class Wrapped.FileStats
---@field total_lines number
---@field biggest Wrapped.FileStat
---@field smallest Wrapped.FileStat
---@field lines_by_type Wrapped.FileStat[]

---@class Wrapped.PluginInfo
---@field name string
---@field date number

---@class Wrapped.PluginHistory
---@field total_ever_installed number
---@field oldest_plugin Wrapped.PluginInfo?
---@field newest_plugin Wrapped.PluginInfo?

---@class Wrapped.ConfigStats
---@field longest_streak number
---@field last_change string
---@field lifetime string
---@field shortest_msg string
---@field longest_msg string
