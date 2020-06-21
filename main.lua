-- Debug
Inspect = require 'libraries/inspect/inspect'

-- Libraries
fn = require 'libraries/Moses/moses'
lume = require 'libraries/lume/lume'
Stateful = require 'libraries/stateful/stateful'
Input = require 'libraries/boipushy/Input'
Timer = require 'modules/TimerEx'
class = require 'libraries/middleclass/middleclass'
bot_loader = require 'bot-loader'

require 'globals'
require 'utils'
require 'entity'
require 'game'

require 'field'
require 'piece'
require 'preview'
require 'stat'
require 'hold'

function love.load()
  -- Main Env
  global_font = love.graphics.newFont(default_font, default_font_size)
  love.graphics.setFont(global_font)

  focused = true

  -- Global Input Handler
  input = Input()

  -- Bot Loader
  if bot_play then bot_loader.start() end

  -- Memory Debug
  input:bind('space', function()
    print("Before collection: " .. collectgarbage("count") / 1024)
    collectgarbage()
    print("After collection: " .. collectgarbage("count") / 1024)
    print("Object count: ")
    local counts = type_count()
    for k, v in pairs(counts) do print(k, v) end
    print("-------------------------------------")
  end)

  game = Game:new()
end

function love.update(dt)
  -- Timer.update(dt) -- global timer
  if focused then game:update(dt) end

  -- Bot update
  if bot_play then bot_loader.update() end
end

function love.draw()
  game:draw()
end

function love.focus(f)
  focused = f
end

-- Memory --
function count_all(f)
  local seen = {}
  local count_table
  count_table = function(t)
    if seen[t] then return end
    f(t)
    seen[t] = true
    for k,v in pairs(t) do
      if type(v) == "table" then
        count_table(v)
      elseif type(v) == "userdata" then
        f(v)
      end
    end
  end
  count_table(_G)
end

function type_count()
  local counts = {}
  local enumerate = function (o)
    local t = type_name(o)
    counts[t] = (counts[t] or 0) + 1
  end
  count_all(enumerate)
  return counts
end

global_type_table = nil
function type_name(o)
  if global_type_table == nil then
    global_type_table = {}
    for k,v in pairs(_G) do
      global_type_table[v] = k
    end
    global_type_table[0] = "table"
  end
  return global_type_table[getmetatable(o) or 0] or "Unknown"
end


function love.run()
  -- Random Seed (optional)
  -- math.randomseed(default_seed or os.time())
  -- if love.math then love.math.setRandomSeed(default_seed or os.time()) end

  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  if love.timer then love.timer.step() end

  local dt = 0
  -- local fixed_dt = 1/60
  -- local accumulator = 0

  -- Main loop time.
  return function()
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == 'quit' then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Update dt, as we'll be passing it to update
    if love.timer then dt = love.timer.step() end

    -- Call update and draw
    -- accumulator = accumulator + dt
    -- while accumulator >= fixed_dt do
    --     if love.update then love.update(fixed_dt) end
    --     accumulator = accumulator - fixed_dt
    -- end
    if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      if love.draw then love.draw() end
      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.001) end
  end
end
