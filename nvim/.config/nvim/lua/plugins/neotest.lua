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
        output = { open_on_run = 'short' },
      })

      local function debug_nearest()
        neotest.run.run({ strategy = 'dap' })
      end

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map('n', '<F5>', function() neotest.run.run() end, opts)
      map('n', '<F6>', debug_nearest, opts)
      map('n', '<F7>', function() neotest.run.stop() end, opts)
      map('n', '<leader>dt', debug_nearest, { desc = 'Debug nearest test' })
      map('n', '<leader>dr', function() neotest.run.run() end, { desc = 'Run test' })
      map('n', '<leader>da', function() neotest.run.run({ suite = true }) end, { desc = 'Run all tests' })
      map('n', '<leader>ds', function() neotest.summary.toggle() end, { desc = 'Toggle summary' })
      map('n', '<leader>do', function() neotest.output.open({ enter = true }) end, { desc = 'Open output' })
      map('n', '<leader>dp', function() neotest.output_panel.toggle() end, { desc = 'Toggle output panel' })
    end,
  },
}
