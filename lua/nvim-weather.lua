-- Get nvim-data directory
local data_dir = vim.fn.stdpath('data')

-- Perform a GET request to the OpenWeatherMap API
local function get_weather()
  local api_key = plugin_config['nvim-weather']['api_key']
  local zip_code = plugin_config['nvim-weather']['zip_code']
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

weather_data = parse_weather()
