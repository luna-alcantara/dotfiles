return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'ramboe/ramboe-dotnet-utils',
    },
    event = 'VeryLazy',
    config = function()
      local dap = require('dap')

      local netcoredbg_adapter = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg/netcoredbg',
        args = { '--interpreter=vscode' },
      }

      dap.adapters.coreclr = netcoredbg_adapter
      dap.adapters.netcoredbg = netcoredbg_adapter

      dap.configurations.cs = {
        {
          type = 'coreclr',
          name = 'Attach to Lambda Test Tool',
          request = 'attach',
          processId = require('dap.utils').pick_process,
        },
        {
          type = 'coreclr',
          name = 'launch - netcoredbg',
          request = 'launch',
          program = function()
            return require('dap-dll-autopicker').build_dll_path()
          end,
        },
      }

      local function m(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
      end

      m('n', '<F5>', "<Cmd>lua require'dap'.continue()<CR>", 'start or continue debugging')
      m('n', '<S-F5>', "<Cmd>lua require'dap'.terminate()<CR>", 'stop debugging')
      m('n', '<F9>', "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", 'toggle breakpoint')
      m('n', '<S-F9>', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, 'set conditional breakpoint')
      m('n', '<F10>', "<Cmd>lua require'dap'.step_over()<CR>", 'step over')
      m('n', '<F11>', "<Cmd>lua require'dap'.step_into()<CR>", 'step into')
      m('n', '<S-F11>', "<Cmd>lua require'dap'.step_out()<CR>", 'step out')

      m('n', '<leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", 'open debug REPL')
      m('n', '<leader>dl', "<Cmd>lua require'dap'.run_last()<CR>", 'run last debug configuration')
      m('n', '<leader>dC', "<Cmd>lua require'dap'.clear_breakpoints()<CR>", 'clear all breakpoints')
    end,
  },
}
