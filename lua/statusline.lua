-- Feline statusline definition.
--
-- Note: This statusline does not define any colors. Instead the statusline is
-- built on custom highlight groups that I define. The colors for these
-- highlight groups are pulled from the current colorscheme applied. Check the
-- file: `lua/eden/modules/ui/colors.lua` to see how they are defined.

if not pcall(require, 'feline') then
  return
end

local feline = require('feline')
local vi_mode = require('feline.providers.vi_mode')
local git = require('feline.providers.git')

--
-- 1. define some constants
--

-- left and right constants (first and second items of the components array)
local LEFT = 1
local RIGHT = 2

-- vi mode color configuration
local MODE_COLORS = {
  ['NORMAL'] = 'green',
  ['COMMAND'] = 'skyblue',
  ['INSERT'] = 'orange',
  ['REPLACE'] = 'red',
  ['LINES'] = 'violet',
  ['VISUAL'] = 'violet',
  ['OP'] = 'yellow',
  ['BLOCK'] = 'yellow',
  ['V-REPLACE'] = 'yellow',
  ['ENTER'] = 'yellow',
  ['MORE'] = 'yellow',
  ['SELECT'] = 'yellow',
  ['SHELL'] = 'yellow',
  ['TERM'] = 'yellow',
  ['NONE'] = 'yellow',
}

local function first_to_upper(s)
  return s:sub(1, 1):upper() .. s:sub(2)
end

local function set_highlights(groups)
  local lines = {}
  for group, opts in pairs(groups) do
    if opts.link then
      table.insert(lines, fmt('highlight! link %s %s', group, opts.link))
    else
      table.insert(
        lines,
        fmt(
          'highlight %s guifg=%s guibg=%s gui=%s guisp=%s',
          group,
          opts.fg or 'NONE',
          opts.bg or 'NONE',
          opts.style or 'NONE',
          opts.sp or 'NONE'
        )
      )
    end
  end
  vim.cmd(table.concat(lines, ' | '))
end

local function get_highlight(name)
  local hl = vim.api.nvim_get_hl_by_name(name, true)
  if hl.link then
    return get_highlight(hl.link)
  end

  local hex = function(n)
    if n then
      return string.format('#%06x', n)
    end
  end

  local names = { 'underline', 'undercurl', 'bold', 'italic', 'reverse' }
  local styles = {}
  for _, n in ipairs(names) do
    if hl[n] then
      table.insert(styles, n)
    end
  end

  return {
    fg = hex(hl.foreground),
    bg = hex(hl.background),
    sp = hex(hl.special),
    style = #styles > 0 and table.concat(styles, ',') or 'NONE',
  }
end

local function generate_pallet_from_colorscheme()
  -- stylua: ignore
  local color_map = {
    black   = { index = 0, default = "#393b44" },
    red     = { index = 1, default = "#c94f6d" },
    green   = { index = 2, default = "#81b29a" },
    yellow  = { index = 3, default = "#dbc074" },
    blue    = { index = 4, default = "#719cd6" },
    magenta = { index = 5, default = "#9d79d6" },
    cyan    = { index = 6, default = "#63cdcf" },
    white   = { index = 7, default = "#dfdfe0" },
  }

  local diagnostic_map = {
    hint = { hl = 'DiagnosticHint', default = color_map.green.default },
    info = { hl = 'DiagnosticInfo', default = color_map.blue.default },
    warn = { hl = 'DiagnosticWarn', default = color_map.yellow.default },
    error = { hl = 'DiagnosticError', default = color_map.red.default },
  }

  local pallet = {}
  for name, value in pairs(color_map) do
    local global_name = 'terminal_color_' .. value.index
    pallet[name] = vim.g[global_name] and vim.g[global_name] or value.default
  end

  for name, value in pairs(diagnostic_map) do
    pallet[name] = get_highlight(value.hl).fg or value.default
  end

  pallet.sl = get_highlight('StatusLine')
  pallet.tab = get_highlight('TabLine')
  pallet.sel = get_highlight('TabLineSel')
  pallet.fill = get_highlight('TabLineFill')

  return pallet
end

local pallet = generate_pallet_from_colorscheme()

-- T theme
local T = {
  fg = '#ebdbb2',
  bg = '#3c3836',
  black = '#3c3836',
  skyblue = '#83a598',
  cyan = '#8e07c',
  green = '#b8bb26',
  oceanblue = '#076678',
  blue = '#458588',
  magenta = '#d3869b',
  orange = '#d65d0e',
  red = '#fb4934',
  violet = '#b16286',
  white = '#ebdbb2',
  yellow = '#fabd2f',
}

local sl = pallet.sl

T = {
  fg = sl.fg,
  bg = sl.bg,
  black = pallet.black or T.black,
  skyblue = pallet.skyblue or T.skyblue,
  cyan = pallet.cyan or T.cyan,
  green = pallet.green or T.green,
  oceanblue = pallet.oceanblue or T.oceanblue,
  blue = pallet.blue or T.blue,
  magenta = pallet.magenta or T.magenta,
  orange = pallet.orange or T.orange,
  red = pallet.red or T.red,
  violet = pallet.violet or T.violet,
  white = pallet.white or T.white,
  yellow = pallet.yellow or T.yellow,
}

local function hex2rgb(hex)
  hex = hex:gsub('#', '')
  return {
    tonumber('0x' .. hex:sub(1, 2)),
    tonumber('0x' .. hex:sub(3, 4)),
    tonumber('0x' .. hex:sub(5, 6)),
  }
end

local function rgb2hex(rgb)
  local hexadecimal = '#'
  for key, value in pairs(rgb) do
    local hex = ''
    while value > 0 do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub('0123456789ABCDEF', index, index) .. hex
    end
    if string.len(hex) == 0 then
      hex = '00'
    elseif string.len(hex) == 1 then
      hex = '0' .. hex
    end
    hexadecimal = hexadecimal .. hex
  end
  return hexadecimal
end

-- color helpers
local function darken(color, value)
  -- vanilla lua to darken a color by a value
  local rgb = hex2rgb(color)
  for i = 1, 3 do
    rgb[i] = math.max(rgb[i] - value, 0)
  end
  return rgb2hex(rgb)
end

local function lighten(color, value)
  -- vanilla lua to lighten a color by a value
  local rgb = hex2rgb(color)
  for i = 1, 3 do
    rgb[i] = math.min(rgb[i] + value, 255)
  end
  return rgb2hex(rgb)
end

--
-- 2. setup some helpers
--

--- get the current buffer's file name, defaults to '[no name]'
function get_filename()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == '' then
    filename = '[﬘]'
  end
  -- this is some vim magic to remove the current working directory path
  -- from the absilute path of the filename in order to make the filename
  -- relative to the current working directory
  return vim.fn.fnamemodify(filename, ':~:.')
end

--- get the current buffer's file type, defaults to '[not type]'
function get_filetype()
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[no type]'
  end
  return filetype:lower()
end

--- get the cursor's line
function get_line_cursor()
  local cursor_line = vim.fn.line('.')
  return cursor_line
end

-- get the cursor's column
function get_column_cursor()
  local cursor_column = vim.fn.col('.')
  return cursor_column
end

--- get the file's total number of lines
function get_line_total()
  return vim.api.nvim_buf_line_count(0)
end

local function convert_string_to_unicode(string)
  -- format is "04n"
  local icon = string.sub(string, 1, 2)
  local icon_map = {
    ['01'] = '',
    ['02'] = '',
    ['03'] = '',
    ['04'] = '',
    ['09'] = '',
    ['10'] = '',
    ['11'] = '',
    ['13'] = '',
    ['50'] = '',
    ['09'] = '',
    ['10'] = '',
    ['11'] = '',
    ['13'] = '',
    ['50'] = '',
  }
  return icon_map[icon]
end

local function get_temperature_color(temp)
  local temp = tonumber(temp)
  if temp < 50 then
    return T.cyan
  elseif temp < 60 then
    return T.blue
  elseif temp < 70 then
    return T.green
  elseif temp < 80 then
    return T.yellow
  elseif temp < 90 then
    return T.orange
  else
    return T.red
  end
end

-- get weather info (is localized in weather_data global)
function get_weather()
  local weather = weather_data
  if weather == nil then
    return ''
  end

  local icon = convert_string_to_unicode(weather.weather[1].icon)

  local temp = weather.main.temp

  return icon .. '  ' .. temp .. '°F '
end

-- get git info
function get_git_diff_added()
  local diff_added = git.git_diff_added()
  local diff = ''
  if tonumber(diff_added) ~= nil and tonumber(diff_added) > 0 then
    diff = diff .. '  ' .. diff_added .. ' '
  end
  return diff
end

function get_git_diff_removed()
  local diff_removed = git.git_diff_removed()
  local diff = ''
  if tonumber(diff_removed) ~= nil and tonumber(diff_removed) > 0 then
    diff = diff .. '  ' .. diff_removed
  end
  return diff
end

function get_git_diff_changed()
  local diff_changed = git.git_diff_changed()
  local diff = ''
  if tonumber(diff_changed) ~= nil and tonumber(diff_changed) > 0 then
    diff = diff .. '  ' .. diff_changed .. ' '
  end
  return diff
end

function get_git_branch()
  -- info is in the local git variable
  -- git_branch function: 0x028e9e353268 git_info_exists function: 0x028e9e352e90 git_diff_added function: 0x028e9e2f1ce0 git_diff_removed function: 0x028e9e3041c0 git_diff_changed function: 0x028e9e210960
  if git.git_info_exists() == 0 then
    return ''
  end

  local branch = git.git_branch()

  return branch ~= '' and '' .. branch .. ' ' or ''
end

--- wrap a string with whitespaces
function wrap(string)
  return ' ' .. string .. ' '
end

--- wrap a string with whitespaces and add a '' on the left,
-- use on left section components for a nice  transition
function wrap_left(string)
  --return ' ' .. string .. ' '
  return ' ' .. string .. ' '
end

--- wrap a string with whitespaces and add a '' on the right,
-- use on left section components for a nice  transition
function wrap_right(string)
  --return ' ' .. string .. ' '
  return ' ' .. string .. ' '
end

--- decorate a provider with a wrapper function
-- the provider must conform to signature: (component, opts) -> string
-- the wrapper must conform to the signature: (string) -> string
function wrapped_provider(provider, wrapper)
  return function(component, opts)
    return wrapper(provider(component, opts))
  end
end

--
-- 3. setup custom providers
--

--- provide the vim mode (NOMRAL, INSERT, etc.)
function provide_mode(component, opts)
  return vi_mode.get_vim_mode()
end

--- provide the buffer's file name
function provide_filename(component, opts)
  return get_filename()
end

--- provide the line's information (curosor position and file's total lines)
function provide_linenumber(component, opts)
  return get_line_cursor() .. '/' .. get_line_total()
end

-- provide the column's information (cursor position)
function provide_column(component, opts)
  return get_column_cursor()
end

function provide_linenumber_and_column(component, opts)
  return get_line_cursor() .. ':' .. get_column_cursor()
end

-- provide the buffer's file type
function provide_filetype(component, opts)
  return get_filetype()
end

-- provide the paw
function provide_paw(component, opts)
  return ' '
end

-- provide weather
function provide_weather(component, opts)
  return get_weather()
end

-- provide git branch
function provide_git_added(component, opts)
  return get_git_diff_added()
end

function provide_git_changed(component, opts)
  return get_git_diff_changed()
end

function provide_git_removed(component, opts)
  return get_git_diff_removed()
end

function provide_git_branch(component, opts)
  return get_git_branch()
end

--
-- 4. build the components
--

local components = {
  -- components when buffer is active
  active = {
    {}, -- left section
    {}, -- right section
  },
  -- components when buffer is inactive
  inactive = {
    {}, -- left section
    {}, -- right section
  },
}

local function register_component(section, component_data, active)
  active = active == nil and true or active
  table.insert(active and components.active[section] or components.inactive[section], {
    name = component_data.name,
    provider = component_data.provider,
    left_sep = component_data.left_sep,
    right_sep = component_data.right_sep,
    hl = component_data.hl,
  })
end

local L, R = LEFT, RIGHT

-- insert the mode component at the beginning of the left section
register_component(L, {
  name = 'mode',
  provider = provide_paw,
  left_sep = '█',
  right_sep = ' ',
  hl = function()
    return {
      --fg = 'black',
      --bg = vi_mode.get_mode_color(),
      fg = vi_mode.get_mode_color(),
      bg = darken(T[vi_mode.get_mode_color()], 160),
    }
  end,
})

-- insert the filename component after the mode component
register_component(L, {
  name = 'filename',
  provider = provide_filename,
  left_sep = 'left_rounded',
  right_sep = ' ',
  hl = function()
    return {
      bg = darken(T[vi_mode.get_mode_color()], 120),
      fg = 'white',
    }
  end,
})

local git_folder_exists = function()
  local git_folder = vim.fn.finddir('.git', vim.fn.expand('%:p:h') .. ';')
  return git_folder ~= '' and git_folder ~= nil
end

register_component(L, {
  name = 'git_branch',
  provider = provide_git_branch,
  left_sep = 'left_rounded',
  hl = function()
    if git.git_info_exists() then
      return {
        bg = darken(T['blue'], 120),
        fg = 'white',
      }
    end
    return {
      fg = 'white',
    }
  end,
})

register_component(L, {
  name = 'git_added',
  provider = provide_git_added,
  hl = function()
    if git.git_info_exists() then
      return {
        bg = darken(T['green'], 120),
        fg = 'white',
      }
    end
    return {
      fg = 'white',
    }
  end,
})

register_component(L, {
  name = 'git_changed',
  provider = provide_git_changed,
  hl = function()
    if git.git_info_exists() then
      return {
        bg = darken(T['yellow'], 100),
        fg = 'white',
      }
    end
    return {
      fg = 'white',
    }
  end,
})

register_component(L, {
  name = 'git_removed',
  provider = provide_git_removed,
  right_sep = ' ',
  hl = function()
    if git.git_info_exists() then
      return {
        bg = darken(T['red'], 100),
        fg = 'white',
      }
    end
    return {
      fg = 'white',
    }
  end,
})

-- insert the filetype component before the linenumber component
register_component(R, {
  name = 'filetype',
  provider = 'lsp_client_names',
  left_sep = 'left_rounded',
  right_sep = ' ',
  hl = function()
    return {
      bg = darken(T[vi_mode.get_mode_color()], 80),
      fg = 'white',
    }
  end,
})

-- insert the linenumber component at the end of the left right section
table.insert(components.active[RIGHT], {
  name = 'linenumber',
  provider = wrapped_provider(provide_linenumber_and_column, wrap),
  right_sep = ' ',
  left_sep = 'left_rounded',
  hl = function()
    return {
      bg = darken(T[vi_mode.get_mode_color()], 100),
      fg = 'white',
    }
  end,
})

register_component(R, {
  name = 'weather',
  provider = provide_weather,
  left_sep = '',
  hl = function()
    return {
      bg = get_temperature_color(weather_data.main.temp),
      fg = 'white',
    }
  end,
})

-- insert the inactive filename component at the beginning of the left section
table.insert(components.inactive[LEFT], {
  name = 'filename_inactive',
  provider = wrapped_provider(provide_filename, wrap),
  right_sep = 'right_rounded',
  hl = {
    fg = 'white',
    bg = 'bg',
  },
})

--
-- 5. run the feline setup
--

feline.setup({
  theme = T,
  components = components,
  vi_mode_colors = MODE_COLORS,
})
