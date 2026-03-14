return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'ramboe/ramboe-dotnet-utils',
    },
    event = 'VeryLazy',
    config = function()
      local dap = require('dap')

      local mason_path = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg/netcoredbg'

      local netcoredbg_adapter = {
        type = 'executable',
        command = mason_path,
        args = { '--interpreter=vscode' },
      }

      dap.adapters.netcoredbg = netcoredbg_adapter
      dap.adapters.coreclr = netcoredbg_adapter

      local function get_project_root()
        local cwd = vim.fn.getcwd()
        local ok, picker = pcall(require, 'dap-dll-autopicker')
        if ok and picker.find_project_root_by_csproj then
          local root = picker.find_project_root_by_csproj(cwd)
          if root and root ~= '' then
            return root
          end
        end
        return cwd
      end

      dap.configurations.cs = {
        {
          type = 'coreclr',
          name = 'launch - netcoredbg',
          request = 'launch',
          program = function()
            local project_root = get_project_root()
            local ok, picker = pcall(require, 'dap-dll-autopicker')
            if ok then
              return picker.build_dll_path()
            end

            return vim.fn.input('Path to dll: ', project_root .. '/bin/Debug/', 'file')
          end,
          cwd = function()
            return get_project_root()
          end,
          justMyCode = false,
          stopAtEntry = false,
        },
      }

      local opts = { noremap = true, silent = true }
      local map = vim.keymap.set

      map('n', '<F5>', function()
        dap.continue()
      end, opts)
      map('n', '<F9>', function()
        dap.toggle_breakpoint()
      end, opts)
      map('n', '<F10>', function()
        dap.step_over()
      end, opts)
      map('n', '<F11>', function()
        dap.step_into()
      end, opts)
      map('n', '<F8>', function()
        dap.step_out()
      end, opts)
      map('n', '<leader>dr', function()
        dap.repl.open()
      end, opts)
      map('n', '<leader>dl', function()
        dap.run_last()
      end, opts)
    end,
  },
}
