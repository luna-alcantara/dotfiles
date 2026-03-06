return {
  {
    'mason-org/mason.nvim',
    opts = {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'lua_ls',
        'basedpyright',
        'omnisharp',
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
      local util = require('lspconfig.util')

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

      -- C#
      vim.lsp.config('omnisharp', {
        cmd = { 'OmniSharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
        capabilities = capabilities,
        root_dir = function(bufnr)
          local path = vim.api.nvim_buf_get_name(bufnr)
          return util.root_pattern('*.csproj', '*.sln', '.git')(path) or vim.fs.dirname(path)
        end,
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            AnalyzeOpenDocumentsOnly = false,
          },
          MsBuild = {
            LoadProjectsOnDemand = false,
          },
        },
      })
      vim.lsp.enable('omnisharp')
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'cs', 'vb' },
        callback = function(args)
          if next(vim.lsp.get_clients({ bufnr = args.buf, name = 'omnisharp' })) then
            return
          end

          local conf = vim.deepcopy(vim.lsp.config.omnisharp)
          local root = conf.root_dir and conf.root_dir(args.buf)
          if not root or root == '' then
            return
          end

          conf.root_dir = root
          vim.lsp.start(conf, { bufnr = args.buf })
        end,
      })

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

          vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
        end,
      })
    end,
  },
}
