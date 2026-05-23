return {
  {
    'andythigpen/nvim-coverage',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      auto_reload = true,
      commands = true,
      summary = { min_coverage = 80.0 },
    },
    config = function(_, opts)
      require('coverage').setup(opts)

      local map = vim.keymap.set
      map('n', '<leader>cl', function()
        require('coverage').load(true)
      end, { desc = 'Load coverage' })
      map('n', '<leader>ch', function()
        require('coverage').hide()
      end, { desc = 'Hide coverage' })
      map('n', '<leader>cs', function()
        require('coverage').summary()
      end, { desc = 'Coverage summary' })
      map('n', '<leader>cn', function()
        require('coverage').jump_next('uncovered')
      end, { desc = 'Next uncovered line' })
      map('n', '<leader>cp', function()
        require('coverage').jump_prev('uncovered')
      end, { desc = 'Previous uncovered line' })
      map('n', '<leader>ct', function()
        require('coverage').toggle()
      end, { desc = 'Toggle coverage' })
    end,
  },
}
