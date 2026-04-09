return {
  {
    'mfussenegger/nvim-lint',
    config = function()
      local lint = require('lint')

      lint.linters_by_ft = {
        json = { 'prettier' },
        yaml = { 'prettier' },
        python = { 'ruff' },
      }

      local augroup = vim.api.nvim_create_augroup('LintGroup', { clear = false })

      local function is_cloudformation()
        local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
        for _, line in ipairs(lines) do
          if line:match('AWSTemplateFormatVersion') then
            return true
          end
        end
        return false
      end

      vim.api.nvim_create_autocmd('BufWritePost', {
        group = augroup,
        pattern = { '*.yml', '*.yaml' },
        callback = function()
          if is_cloudformation() then
            require('lint').linters_by_ft.yaml = { 'cfn_lint' }
          else
            require('lint').linters_by_ft.yaml = { 'prettier' }
          end
          lint.try_lint()
        end,
        desc = 'Run appropriate linter based on file type',
      })

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
        group = augroup,
        pattern = { '*.py' },
        callback = function()
          lint.try_lint()
        end,
        desc = 'Run ruff via nvim-lint when saving Python files',
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
        pattern = { '*.yml', '*.yaml', '*.json', '*.py' },
        callback = function(event)
          vim.keymap.set('n', '<leader>cL', show_lint_diagnostics, {
            buffer = event.buf,
            desc = 'Run lint and show diagnostics',
            silent = true,
          })
        end,
      })

      vim.api.nvim_create_user_command('LintFile', function()
        lint.try_lint()
      end, {
        desc = 'Run linter on the current buffer',
      })
    end,
  },
}
