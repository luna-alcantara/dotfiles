return {
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false,
    build = 'make',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'folke/snacks.nvim',
    },
    opts = {
      provider = 'opencode',
      acp_providers = {
        opencode = {
          command = 'opencode',
          args = { 'acp' },
        },
        kiro = {
          command = 'kiro-cli',
          args = { 'acp' },
        },
      },
      input = {
        provider = 'snacks',
      },
      selector = {
        provider = 'snacks',
      },
    },
  },
}
