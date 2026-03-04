local function set_diag_hl()
  vim.api.nvim_set_hl(0, 'DiagnosticSignError', { link = 'DiagnosticError' })
  vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { link = 'DiagnosticWarn' })
  vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { link = 'DiagnosticInfo' })
  vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { link = 'DiagnosticHint' })
end

vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diag_hl })
set_diag_hl()

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
    },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  severity_sort = true,
  update_in_insert = false,

  -- inline only for errors
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
    spacing = 2,
    prefix = function(d)
      local icons = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.WARN] = '',
        [vim.diagnostic.severity.INFO] = '',
        [vim.diagnostic.severity.HINT] = '',
      }
      return icons[d.severity] or '●'
    end,
  },

  float = {
    border = 'rounded',
    source = 'if_many',
    focusable = false,
  },
})
