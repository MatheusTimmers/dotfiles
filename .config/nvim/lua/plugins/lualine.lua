return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-mini/mini.icons', 'SmiteshP/nvim-navic' },
  config = function()
    local navic = require('nvim-navic')
    require('lualine').setup({
      options = { theme = 'catppuccin-nvim' },
      sections = {
        lualine_c = {
          'filename',
          {
            function() return navic.get_location() end,
            cond = function() return navic.is_available() end,
          },
        },
      },
    })
  end
}
