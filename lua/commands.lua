-- Remove legacy commands from neotree v1
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })

vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand('$MYVIMRC'),
})

-- get current nvim config path
local config_path = vim.fn.stdpath('config')

-- command to reload feline config
vim.cmd([[ command! -nargs=0 FelineReload lua require('feline') ]])
