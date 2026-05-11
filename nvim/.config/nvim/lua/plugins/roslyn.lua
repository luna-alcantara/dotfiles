return {
  'seblyng/roslyn.nvim',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    broad_search = true,
    config = {
      settings = {
        ['csharp|background_analysis'] = {
          dotnet_analyzer_diagnostics_scope = 'openFiles',
          dotnet_compiler_diagnostics_scope = 'fullSolution',
        },
        ['csharp|formatting'] = {
          dotnet_organize_imports_on_format = true,
        },
      },
    },
  },
}
