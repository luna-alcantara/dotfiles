return {
  {
    'mason-org/mason.nvim',
    opts = {
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
      ensure_installed = {
        'lua-language-server',
        'roslyn',

        -- formatter
        'stylua',
        'csharpier',
        'prettier',

        -- linter
        'ruff',
        'cfn-lint', -- aws cloudformation

        -- dap
        'netcoredbg',
        'debugpy',
      },
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'lua_ls',
        'basedpyright',
      },
    },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Lua
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          },
        },
      })
      vim.lsp.enable('lua_ls')

      -- Python
      vim.lsp.config('basedpyright', {
        capabilities = capabilities,
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = 'workspace',
            },
          },
          python = {
            analysis = {
              typeCheckingMode = 'basic',
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      vim.lsp.enable('basedpyright')

      -- Shared LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)

          vim.keymap.set('n', '<leader>qf', function()
            vim.lsp.buf.code_action({ only = { 'quickfix' } })
          end, opts)

          vim.keymap.set('n', '<leader>xd', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
        end,
      })
    end,
  },
}
