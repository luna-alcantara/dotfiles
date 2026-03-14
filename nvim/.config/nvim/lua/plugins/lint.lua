return {
  {
    'mfussenegger/nvim-lint',
    config = function()
      local lint = require('lint')

      lint.linters_by_ft = {
        yaml = { 'cfn_lint' },
        yml = { 'cfn_lint' },
        json = { 'cfn_lint' },
      }

      local augroup = vim.api.nvim_create_augroup('CfnLintGroup', { clear = false })
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = augroup,
        pattern = { '*.yml', '*.yaml' },
        callback = function()
          lint.try_lint()
        end,
        desc = 'Run cfn-lint via nvim-lint when saving templates',
      })

      local function show_lint_diagnostics()
        lint.try_lint()
        vim.diagnostic.open_float(nil, {
          scope = 'buffer',
          border = 'rounded',
          focusable = false,
          prefix = function(d)
            local icons = {
              [vim.diagnostic.severity.ERROR] = 'Error',
              [vim.diagnostic.severity.WARN] = 'Warn',
              [vim.diagnostic.severity.INFO] = 'Info',
              [vim.diagnostic.severity.HINT] = 'Hint',
            }
            return icons[d.severity] .. ': '
          end,
        })
      end

      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
        group = augroup,
        pattern = { '*.yml', '*.yaml', '*.json' },
        callback = function(event)
          vim.keymap.set('n', '<leader>cL', show_lint_diagnostics, {
            buffer = event.buf,
            desc = 'Run cfn-lint and show diagnostics',
            silent = true,
          })
        end,
      })

      vim.api.nvim_create_user_command('CfnLint', function()
        lint.try_lint()
      end, {
        desc = 'Run cfn-lint on the current buffer',
      })

      vim.api.nvim_create_user_command('CfnLintMessages', function()
        lint.try_lint()
        vim.diagnostic.open_float(nil, {
          scope = 'buffer',
          border = 'rounded',
          focusable = false,
          prefix = function(d)
            local icons = {
              [vim.diagnostic.severity.ERROR] = 'Error',
              [vim.diagnostic.severity.WARN] = 'Warn',
              [vim.diagnostic.severity.INFO] = 'Info',
              [vim.diagnostic.severity.HINT] = 'Hint',
            }
            return icons[d.severity] .. ': '
          end,
        })
      end, {
        desc = 'Run cfn-lint and show every diagnostic in a floating window',
      })
    end,
  },
}
