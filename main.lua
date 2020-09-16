-- Debug
Inspect = require 'libs/inspect'

-- Libraries
fn = require 'libs/moses_min'
lume = require 'libs/lume'
Stateful = require 'libs/stateful'
Input = require 'libs/Input'
Timer = require 'modules/TimerEx'
class = require 'libs/middleclass'
log = require 'libs/log'
bot_loader = require 'bot-loader'
pc_finder = require 'pc-finder'

require 'globals'
require 'utils'
require 'entity'
require 'game'

require 'field'
require 'piece'
require 'preview'
require 'stat'
require 'hold'
require 'layout'

function love.load()
  -- Main Env
  global_font = love.graphics.newFont(DEFAULT_FONT, DEFAULT_FONT_SIZE)
  love.graphics.setFont(global_font)

  focused = true

  -- Global Input Handler
  input = Input()

  -- Bot Loader
  if BOT_PLAY then bot_loader.start() end
  if PCFINDER_PLAY then pc_finder.start() end

  -- Memory Debug
  input:bind('space', function()
    log.info("Before collection: " .. collectgarbage("count") / 1024)
    collectgarbage()
    log.info("After collection: " .. collectgarbage("count") / 1024)
    log.info("Object count: ")
    local counts = type_count()
    for k, v in pairs(counts) do log.info(k, v) end
    log.info("-------------------------------------")
  end)

  game = Game:new()
end

function love.update(dt)
  -- Timer.update(dt) -- global timer
  if focused then game:update(dt) end

  -- Bot update
  if BOT_PLAY then bot_loader.update() end
  if PCFINDER_PLAY then pc_finder.update() end
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
  -- math.randomseed(DEFAULT_SEED or os.time())
  -- if love.math then love.math.setRandomSeed(DEFAULT_SEED or os.time()) end

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

function love.quit()
  if BOT_PLAY then bot_loader.terminate() end
  if PCFINDER_PLAY then
    pc_finder.terminate()
    -- pc_finder.shutdown()
  end
end
