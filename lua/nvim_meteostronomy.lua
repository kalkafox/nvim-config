-- Get nvim-data directory
local data_dir = vim.fn.stdpath('data')

local function get_moon_phase()
  local date = os.date('*t')
  local year = date.year
  local month = date.month
  local day = date.day
  local hour = date.hour
  local min = date.min

  local c, e, jd, b

  if month <= 2 then
    year = year - 1
    month = month + 12
  end
  month = month + 1

  c = 365.25 * year
  e = 30.6 * month
  jd = c + e + day - 694039.09 -- jd is total days elapsed
  jd = jd + (hour + min / 60) / 24 -- add time of day
  b = jd / 29.5305882 -- divide by the moon cycle
  b = b - math.floor(b) -- int(b) -> b, take integer part of b
  b = math.floor(b * 8) -- scale fraction from 0-8 and round by adding 0.5
  if b == 8 then
    b = 0
  end
  return b
end

-- Perform a GET request to the OpenWeatherMap API
local function get_weather()
  local api_key = plugin_config['nvim_meteostronomy']['api_key']
  local zip_code = plugin_config['nvim_meteostronomy']['zip_code']
  local url = 'https://api.openweathermap.org/data/2.5/weather?zip='
    .. zip_code
    .. '&appid='
    .. api_key
    .. '&units=imperial'
  local handle = io.popen('curl -s "' .. url .. '"')
  local result = handle:read('*a')
  handle:close()
  return result
end

-- Parse the JSON response from the OpenWeatherMap API
local function parse_weather()
  -- Check if the weather data is less than 10 minutes old, if so, return it
  local weather_timestamp_file = io.open(data_dir .. '/weather_timestamp', 'r')
  if weather_timestamp_file ~= nil then
    local weather_timestamp = weather_timestamp_file:read('*all')
    weather_timestamp_file:close()
    if os.time() - weather_timestamp < 600 then
      local weather_file = io.open(data_dir .. '/weather.json', 'r')
      local weather = weather_file:read('*all')
      weather_file:close()
      local weather_table = vim.fn.json_decode(weather)
      return weather_table
    end
  end
  local weather = get_weather()
  local weather_table = vim.fn.json_decode(weather)
  if weather_table['cod'] ~= 200 then
    return 'Weather API error: ' .. weather_table['message']
  end
  local weather_timestamp = os.time()
  weather_timestamp_file = io.open(data_dir .. '/weather_timestamp', 'w')
  weather_timestamp_file:write(weather_timestamp)
  weather_timestamp_file:close()
  -- Save data to a file
  local weather_file = io.open(data_dir .. '/weather.json', 'w')
  weather_file:write(weather)
  weather_file:close()
  return weather_table
end

WEATHER_DATA = parse_weather()

WEATHER_DATA.moon_phase = get_moon_phase()
