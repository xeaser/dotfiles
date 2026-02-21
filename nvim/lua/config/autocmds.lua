-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd({ "DirChanged", "SessionLoadPost" }, {
  group = vim.api.nvim_create_augroup("source_exrc", { clear = true }),
  desc = "Source .nvim.lua on project switch or directory change",
  callback = function(args)
    local contents = vim.secure.read(string.format("%s/.nvim.lua", args.file))
    if contents then
      assert(loadstring(contents))()
    end
  end,
})
