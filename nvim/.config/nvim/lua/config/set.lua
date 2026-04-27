vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 8

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

if vim.fn.executable('zsh') == 1 then
  vim.o.shell = vim.fn.exepath('zsh')
end

-- Deal with windows repos
local windows_repos = {
  '/home/luna/source/work',
  -- add other paths if needed
}

local function is_windows_repo(path)
  for _, repo in ipairs(windows_repos) do
    if path:find(repo, 1, true) == 1 then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)

    if is_windows_repo(file) then
      -- Prefer CRLF
      vim.opt_local.fileformats = { 'dos', 'unix' }

      -- If new file or detected as unix, switch to CRLF
      if vim.bo.fileformat ~= 'dos' then
        vim.opt_local.fileformat = 'dos'
      end
    end
  end,
})
