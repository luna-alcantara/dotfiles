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
        return vim.fn.getcwd()
      end

      local function set_project_dir(project_root)
        local ok, err = pcall(vim.api.nvim_set_current_dir, project_root)
        if not ok then
          vim.notify('Failed to set working directory: ' .. tostring(err), vim.log.levels.ERROR)
          return false
        end
        return true
      end

      local function run_dotnet_build(project_root)
        local output = vim.fn.system({ 'dotnet', 'build', project_root })
        if vim.v.shell_error ~= 0 then
          vim.notify('dotnet build failed:\n' .. output, vim.log.levels.ERROR)
          return false
        end
        return true
      end

      local function find_lambda_handlers()
        local handlers = {}
        local project_root = get_project_root()

        local defaults_files = vim.fs.find('aws-lambda-tools-defaults.json', {
          path = project_root,
          type = 'file',
          limit = math.huge,
        })

        for _, file_path in ipairs(defaults_files) do
          local file = io.open(file_path, 'r')
          if file then
            local content = file:read('*all')
            file:close()
            local handler = content:match('"function%-handler"%s*:%s*"([^"]+)"')
            if handler then
              table.insert(handlers, handler)
            end
          end
        end
        return handlers
      end

      local function find_lambda_config_files()
        local project_root = get_project_root()

        local files = vim.fs.find(function(name, path)
          return name:sub(-5) == '.json' and not path:match('/bin/') and not path:match('/obj/')
        end, {
          path = project_root,
          type = 'file',
          limit = math.huge,
        })

        table.sort(files)
        return files
      end

      local function get_aws_profiles()
        local profiles = {}

        if vim.fn.executable('aws') ~= 1 then
          return profiles
        end

        local result = vim.system({ 'aws', 'configure', 'list-profiles' }, { text = true }):wait()
        if result.code ~= 0 then
          return profiles
        end

        for line in (result.stdout or ''):gmatch('[^\r\n]+') do
          if line ~= '' then
            table.insert(profiles, line)
          end
        end

        return profiles
      end

      local function run_lambda_debugger()
        local project_root = get_project_root()
        local handlers = find_lambda_handlers()
        local profiles = get_aws_profiles()
        local config_files = find_lambda_config_files()

        local function start_debug(handler, payload, config_file, profile)
          vim.g.selected_lambda_handler = handler

          if not set_project_dir(project_root) then
            return
          end

          if not run_dotnet_build(project_root) then
            return
          end

          local no_ui = (payload and payload ~= '') or (config_file and config_file ~= '')
          local args = { '--port', '5050', '--handler', handler or '' }
          if profile and profile ~= '' then
            table.insert(args, '--profile')
            table.insert(args, profile)
          end
          if config_file and config_file ~= '' then
            table.insert(args, '--config-file')
            table.insert(args, config_file)
          end
          if payload and payload ~= '' then
            table.insert(args, '--payload')
            table.insert(args, payload)
          end
          if no_ui then
            table.insert(args, '--no-ui')
          end

          vim.defer_fn(function()
            local cfg = vim.deepcopy(dap.configurations.cs[2])
            cfg.args = args
            require('dap').run(cfg)
          end, 500)
        end

        local function select_profile(callback)
          if #profiles > 0 then
            vim.ui.select(profiles, { prompt = 'AWS Profile:' }, function(choice)
              callback(choice)
            end)
          else
            callback(nil)
          end
        end

        local function select_config_file(callback)
          if #config_files > 0 then
            vim.ui.select(config_files, { prompt = 'Config file (optional):' }, function(choice)
              callback(choice)
            end)
          else
            callback(nil)
          end
        end

        if #handlers > 0 then
          select_profile(function(profile)
            vim.ui.select(handlers, { prompt = 'Select Lambda handler:' }, function(choice)
              if choice then
                select_config_file(function(config_file)
                  vim.ui.input({ prompt = 'Payload (JSON):' }, function(payload)
                    start_debug(choice, payload, config_file, profile)
                  end)
                end)
              end
            end)
          end)
        else
          select_profile(function(profile)
            vim.ui.input({ prompt = 'Lambda handler (namespace::class::method):' }, function(input)
              if input then
                select_config_file(function(config_file)
                  vim.ui.input({ prompt = 'Payload (JSON):' }, function(payload)
                    start_debug(input, payload, config_file, profile)
                  end)
                end)
              end
            end)
          end)
        end
      end

      local opts = { noremap = true, silent = true }
      local map = vim.keymap.set

      map('n', '<leader>db', run_lambda_debugger, opts)

      local function run_console_debugger()
        local project_root = get_project_root()

        if not set_project_dir(project_root) then
          return
        end

        if not run_dotnet_build(project_root) then
          return
        end

        vim.defer_fn(function()
          require('dap').run(dap.configurations.cs[1])
        end, 500)
      end

      map('n', '<leader>dc', run_console_debugger, opts)

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
        {
          type = 'netcoredbg',
          name = 'launch - Lambda Test Tool',
          request = 'launch',
          program = 'dotnet-lambda-test-tool-8.0',
          args = { '--port', '5050' },
          cwd = function()
            return get_project_root()
          end,
          justMyCode = false,
          stopAtEntry = false,
        },
      }

      dap.configurations.python = {
        {
          type = 'debugpy',
          name = 'launch - python file',
          request = 'launch',
          program = '${file}',
          pythonPath = function()
            local venv_path = os.getenv('VIRTUAL_ENV')
            if venv_path then
              return venv_path .. '/bin/python'
            end
            return vim.fn.exepath('python') or 'python'
          end,
        },
        {
          type = 'debugpy',
          name = 'launch - python module',
          request = 'launch',
          module = function()
            return vim.fn.input('Module name: ', '', 'file')
          end,
          pythonPath = function()
            local venv_path = os.getenv('VIRTUAL_ENV')
            if venv_path then
              return venv_path .. '/bin/python'
            end
            return vim.fn.exepath('python') or 'python'
          end,
        },
        {
          type = 'debugpy',
          name = 'attach - remote',
          request = 'attach',
          host = function()
            return vim.fn.input('Host: ', '127.0.0.1', 'file')
          end,
          port = function()
            return tonumber(vim.fn.input('Port: ', '5678', 'file'))
          end,
          localRoot = function()
            return vim.fn.input('Local root: ', vim.fn.getcwd(), 'dir')
          end,
          remoteRoot = function()
            return vim.fn.input('Remote root: ', '/app')
          end,
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
      map('n', '<leader>dR', function()
        dap.repl.open()
      end, opts)
      map('n', '<leader>dl', function()
        dap.run_last()
      end, opts)
    end,
  },
}
