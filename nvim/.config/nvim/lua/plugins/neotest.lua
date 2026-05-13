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

      local map = vim.keymap.set
      map('n', '<F6>', function()
        neotest.run.run({ strategy = 'dap' })
      end, { desc = 'Debug nearest test' })
      map('n', '<leader>tn', function()
        neotest.run.run()
      end, { desc = 'Run nearest test' })
      map('n', '<leader>td', function()
        neotest.run.run({ strategy = 'dap' })
      end, { desc = 'Debug nearest test' })
      map('n', '<leader>tD', function()
        neotest.run.run({ vim.fn.expand('%'), strategy = 'dap' })
      end, { desc = 'Debug test file' })
      map('n', '<leader>tl', function()
        neotest.run.run_last()
      end, { desc = 'Re-run last test' })
      map('n', '<leader>ta', function()
        neotest.run.run({ suite = true })
      end, { desc = 'Run all tests' })
      map('n', '<leader>ts', function()
        neotest.run.stop()
      end, { desc = 'Stop test run' })
      map('n', '<leader>tu', function()
        neotest.summary.toggle()
      end, { desc = 'Toggle test summary' })
      map('n', '<leader>to', function()
        neotest.output.open({ enter = true })
      end, { desc = 'Open test output' })
      map('n', '<leader>tp', function()
        neotest.output_panel.toggle()
      end, { desc = 'Toggle test output panel' })
    end,
  },
}
