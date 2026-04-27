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
      map('n', '<leader>tn', function() neotest.run.run() end, { desc = 'Run nearest test' })
      map('n', '<leader>td', debug_nearest, { desc = 'Debug nearest test' })
      map('n', '<leader>ta', function() neotest.run.run({ suite = true }) end, { desc = 'Run all tests' })
      map('n', '<leader>ts', function() neotest.run.stop() end, { desc = 'Stop test run' })
      map('n', '<leader>tu', function() neotest.summary.toggle() end, { desc = 'Toggle test summary' })
      map('n', '<leader>to', function() neotest.output.open({ enter = true }) end, { desc = 'Open test output' })
      map('n', '<leader>tp', function() neotest.output_panel.toggle() end, { desc = 'Toggle test output panel' })
    end,
  },
}
