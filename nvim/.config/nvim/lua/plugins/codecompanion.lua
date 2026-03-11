return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<leader>ccc', '<cmd>CodeCompanionChat<CR>', desc = 'CodeCompanion Chat' },
    {
      '<leader>cca',
      '<cmd>CodeCompanionActions<CR>',
      mode = { 'n', 'v' },
      desc = 'CodeCompanion Actions',
    },
  },
  opts = {
    chat = {
      window = {
        layout = 'vertical',
        border = 'rounded',
      },
      auto_scroll = true,
    },
    inline = {
      fill_char = '󰆧',
      auto_insert = true,
    },
    display = {
      chat = {
        syntax_highlighting = true,
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

    opts = {
      log_level = 'DEBUG',
    },
  },
}
