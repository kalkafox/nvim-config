local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

PLUGIN_CONFIG = require('plugin_config')

function LOAD_CONFIG()
  require('nvim_meteostronomy')
  require('packer_mod')
  require('plugins')
  require('options')
  require('keymaps')
  require('commands')
  require('statusline')
end

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  -- delete plugin/packer_compiled.lua if it exists
  local compiled_path = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua'
  if vim.fn.empty(vim.fn.glob(compiled_path)) == 0 then
    vim.fn.delete(compiled_path)
  end
  vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
  vim.cmd([[packadd packer.nvim]])
  require('packer_mod')
  require('packer').sync()
  vim.cmd([[autocmd User PackerComplete ++once echo ' Let the magic begin.' | lua LOAD_CONFIG()]])
  return
end

LOAD_CONFIG()
