return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'CodeCompanion Chat Toggle' },
    { '<leader>ci', '<cmd>CodeCompanion<cr>', desc = 'CodeCompanion Inline' },
    {
      '<leader>cA',
      '<cmd>CodeCompanionActions<cr>',
      mode = { 'n', 'v' },
      desc = 'CodeCompanion Actions',
    },
  },
  opts = {
    -- NOTE: The log_level is in `opts.opts`
    opts = {
      log_level = 'DEBUG', -- or "TRACE"
    },
    display = {
      chat = {
        window = {
          layout = 'vertical',
          position = 'right',
        },
      },
    },
    adapters = {
      acp = {
        opencode = function()
          return require('codecompanion.adapters').extend('opencode', {
            commands = {
              default = { 'opencode', 'acp' },
            },
          })
        end,
        kiro = function()
          return require('codecompanion.adapters').extend('kiro', {
            commands = {
              default = { 'kiro-cli', 'acp' },
            },
          })
        end,
      },
    },
    strategies = {
      chat = {
        adapter = 'opencode',
      },
      inline = {
        adapter = 'opencode',
      },
      agent = {
        adapter = 'opencode',
      },
    },
  },
}
