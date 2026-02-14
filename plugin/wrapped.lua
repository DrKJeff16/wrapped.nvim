vim.api.nvim_create_user_command(
  "NvimWrapped",
  function() require("wrapped").run() end,
  {}
)
