return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
      'nvim-treesitter/nvim-treesitter',
      'mfussenegger/nvim-dap',
      'Issafalcon/neotest-dotnet',
    },
    event = 'VeryLazy',
    config = function()
      local neotest = require('neotest')

      neotest.setup({
        adapters = {
          require('neotest-dotnet'),
        },
      })

      local function debug_nearest_test()
        neotest.run.run({ strategy = 'dap' })
      end

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map('n', '<F6>', debug_nearest_test, opts)
      map('n', '<leader>dt', debug_nearest_test, {
        noremap = true,
        silent = true,
        desc = 'Debug nearest test',
      })
    end,
  },
}
