return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local theme = require('lualine.themes.catppuccin-mocha')
      require('lualine').setup({
        options = {
          theme = theme,
          globalstatus = false,
          section_separators = { left = '', right = '' },
          component_separators = { left = '|', right = '|' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'diagnostics' },
          lualine_c = {
            {
              'buffers',
              mode = 0, -- 0 name, 1 index, 2 name + index, 3 number, 4 name + number
              show_modified_status = true,
              buffers_color = {
                active = {
                  bg = theme.insert.a.bg,
                  fg = theme.insert.a.fg,
                  gui = 'bold',
                },
                inactive = {
                  bg = theme.inactive.a.bg,
                  fg = theme.inactive.a.fg,
                },
              },
            },
          },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'lsp_status' },
          lualine_z = { 'diff', 'branch' },
        },
      })
    end,
  },
}
