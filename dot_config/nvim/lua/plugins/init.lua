-- ~/.config/nvim/lua/plugins/init.lua
return {
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", "vendor" },
        }
      })
    end,
  },
  
  -- Commenting with <leader>cc
  { "preservim/nerdcommenter" },
  
  -- Git integration
  { "tpope/vim-fugitive" },
  
  -- Git decorations in gutter  
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
          section_separators = '',
          component_separators = '',
        }
      })
    end,
  },
}
