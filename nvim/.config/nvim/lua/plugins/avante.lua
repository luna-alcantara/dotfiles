return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false,
  opts = {
    provider = vim.env.NVIM_LLM_PROVIDER or 'opencode',
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
    selection = {
      hint_display = 'none',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
  },
}
