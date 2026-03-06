return {
  {
    'stevearc/conform.nvim',
    lazy = false,
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        cs = { 'csharpier' },
        css = { 'prettier' },
        html = { 'prettier' },
        csproj = { 'xmlformat' },
        xml = { 'xmlformat' },
      },
      formatters = {
        xmlformat = {
          command = 'xmlformat',
          -- args = { "--overwrite" },
        },
        csharpier = {
          command = 'csharpier',
          args = {
            'format',
            '--write-stdout',
          },
          to_stdin = true,
        },
      },

      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
    config = function(_, opts)
      local conform = require('conform')
      conform.setup(opts)

      vim.api.nvim_create_user_command('Format', function()
        conform.format()
      end, {})

      vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        conform.format()
      end, { desc = 'Format buffer' })
    end,
  },
}
