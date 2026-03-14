-- Set <space> as the leader key

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set

-- Buffers

map('n', '[b', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
map('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bs', '<C-^>', { desc = 'Alternate buffer' })

map('n', '<leader>bb', function()
  require('telescope.builtin').buffers()
end, { desc = 'Find buffer' })

map('n', '<leader>bd', function()
  vim.api.nvim_buf_delete(0, {})
end, { desc = 'Delete buffer' })

map('n', '<leader>bD', function()
  vim.api.nvim_buf_delete(0, { force = true })
end, { desc = 'Force delete buffer' })

map('n', '<leader>bo', function()
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
      pcall(vim.api.nvim_buf_delete, b, {})
    end
  end
end, { desc = 'Delete other buffers' })

-- Splits

-- Create/close splits
map('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Vertical split' })
map('n', '<leader>ws', '<cmd>split<CR>', { desc = 'Horizontal split' })
map('n', '<leader>wc', '<cmd>close<CR>', { desc = 'Close split' })
map('n', '<leader>wo', '<cmd>only<CR>', { desc = 'Only this split' })
map('n', '<leader>we', '<C-w>=', { desc = 'Equalize splits' })
-- Resize splits (Alt + hjkl)
map('n', '<A-h>', '<cmd>vertical resize -2<CR>', { desc = 'Narrower' })
map('n', '<A-l>', '<cmd>vertical resize +2<CR>', { desc = 'Wider' })
map('n', '<A-j>', '<cmd>resize -2<CR>', { desc = 'Shorter' })
map('n', '<A-k>', '<cmd>resize +2<CR>', { desc = 'Taller' })

-- Tabs
map('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Prev tab' })
map('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next tab' })

map('n', '<leader><tab>n', '<cmd>tabnew<CR>', { desc = 'New tab' })
map('n', '<leader><tab>c', '<cmd>tabclose<CR>', { desc = 'Close tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<CR>', { desc = 'Close other tabs' })

map('n', '<leader><tab><', '<cmd>tabmove -1<CR>', { desc = 'Move tab left' })
map('n', '<leader><tab>>', '<cmd>tabmove +1<CR>', { desc = 'Move tab right' })

for i = 1, 9 do
  map('n', '<leader><tab>' .. i, i .. 'gt', { desc = 'Go to tab ' .. i })
end

-- Terminal
map('n', '<leader>t', function()
  vim.cmd('botright split | terminal')
end)

map('t', '<Esc>', [[<C-\><C-n>]])

-- Copy to clipboard
map('n', '<leader>y', '"+y')
map('v', '<leader>y', '"+y')
map('n', '<leader>Y', '"+Y')

-- Clear highlights on search when pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
