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

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map('n', '<F5>', "<Cmd>lua require'dap'.continue()<CR>", opts)
      map('n', '<F6>', "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
      map('n', '<F9>', "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
      map('n', '<F10>', "<Cmd>lua require'dap'.step_over()<CR>", opts)
      map('n', '<F11>', "<Cmd>lua require'dap'.step_into()<CR>", opts)
      map('n', '<F8>', "<Cmd>lua require'dap'.step_out()<CR>", opts)
      -- map('n', '<F12>', "<Cmd>lua require'dap'.step_out()<CR>", opts)
      map('n', '<leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", opts)
      map('n', '<leader>dl', "<Cmd>lua require'dap'.run_last()<CR>", opts)
      map(
        'n',
        '<leader>dt',
        "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>",
        { noremap = true, silent = true, desc = 'debug nearest test' }
      )
    end,
  },
}
