return {
  {
    'NeogitOrg/neogit',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>gG', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
    },
  },
}
