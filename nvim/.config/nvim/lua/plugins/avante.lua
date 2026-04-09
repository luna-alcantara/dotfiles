return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false,
  opts = {
    provider = 'opencode',
    providers = {
      opencode = {
        name = 'opencode',
        module = 'avante.providers.opencode',
        sharing = 'acp',
      },
      kiro = {
        name = 'kiro-cli',
        module = 'avante.providers.kiro',
        sharing = 'acp',
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
  },
}
