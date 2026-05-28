local group = vim.api.nvim_create_augroup("TestGroup", {clear = true})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*/lua/settings.lua",
  callback = function() print("MATCHED") end
})
vim.cmd("doautocmd BufWritePost /Users/apple/.config/nvim/lua/settings.lua")
