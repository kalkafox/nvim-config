local is_windows = vim.loop.os_uname().sysname:find('Windows') ~= nil

vim.o.termguicolors = true

require('packer').startup(function(use)
  -- Package manager
  use('wbthomason/packer.nvim')

  use({ -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  })

  use({ -- Autocompletion
    'hrsh7th/nvim-cmp',
    requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  })

  use({ -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update({ with_sync = true }))
    end,
  })

  use('norcalli/nvim-colorizer.lua')

  use({ -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  })

  -- Git related plugins
  use('tpope/vim-fugitive')
  use('tpope/vim-rhubarb')
  use('lewis6991/gitsigns.nvim')

  -- nvim projectconfig
  use('kalkafox/nvim-projectconfig')

  -- emmet
  use({
    'mattn/emmet-vim',
    ft = { 'html', 'css', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    config = function()
      vim.g.user_emmet_leader_key = ','
    end,
  })

  use({
    'github/copilot.vim',
    config = function()
      vim.g.copilot_autostart = 1
    end,
  }) -- Copilot
  use('sainnhe/everforest') -- Everforest theme
  use('sainnhe/gruvbox-material') -- Gruvbox Material theme
  use('EdenEast/nightfox.nvim') -- Nightfox theme
  use('folke/tokyonight.nvim') -- Tokyonight theme
  --use 'nvim-lualine/lualine.nvim' -- Fancier statusline
  use('feline-nvim/feline.nvim') -- Fancier fancier statusline
  use('lukas-reineke/indent-blankline.nvim') -- Add indentation guides even on blank lines
  use('numToStr/Comment.nvim') -- "gc" to comment visual regions/lines
  use('tpope/vim-sleuth') -- Detect tabstop and shiftwidth automatically

  -- Autopairs (automatically close brackets, quotes, etc.)
  use('windwp/nvim-autopairs')

  -- Discord Rich Presence
  use('andweeb/presence.nvim')

  -- Trouble (quickfix and location list)
  use({
    'folke/trouble.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
  })

  -- File explorer plugin
  use({
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
  })

  -- Tabline plugin
  use({ 'romgrk/barbar.nvim', wants = 'nvim-web-devicons' })

  -- Fuzzy Finder (files, lsp, etc)
  --use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }

  use({ 'kalkafox/telescope.nvim', branch = 'fix-preview-buffer-error', requires = { 'nvim-lua/plenary.nvim' } })

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  --use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

  if is_windows then
    use({
      'nvim-telescope/telescope-fzf-native.nvim',
      run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    })
  else
    use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable('make') == 1 })
  end

  -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end
end)
