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
        layout = 'float',
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
        floating_window = {
          width = 0.9,
          height = 0.8,
          border = 'rounded',
          relative = 'editor',
          row = 'center',
          col = 'center',
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

    opts = {
      log_level = 'DEBUG',
    },
  },
}
