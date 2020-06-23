local bot = require 'GaiAI'

local loader = {}

local params = {
  -- 13, 9, 17, 10, -300,
  -- 25, 39, 2, 12, 19,
  -- 7, -300, 21, 16, 9,
  -- 19, 0, 500, 0, 0,
  -- 200
  16,  9, 11, 17, 17,
  25, 39,  2, 12, 19,
  7, 24, 18,  7, 14,
  19, 99, 14, 19,  0,
  0,
}
local holdallowed = true
local allspin = false
local tsdonly = false
local searchwidth = 1000 -- 1000 optimal

local loaded = ...

if loaded == true then
  local request, move

  while true do
    local requestChannel = love.thread.getChannel('request')
    request = requestChannel:pop()
    if request == true then
      move = bot.move()
      local producer = love.thread.getChannel('move')
      producer:push(move)
    end
  end
else
  local thinkFinished
  local pathToThisFile = (...):gsub('%.', '/') .. '.lua'
  local _move

  local function getFinishedMoveIfAvailable()
    local consumer = love.thread.getChannel('move')
    move = consumer:pop()
    if move then
      _move = move
      thinkFinished()
    end
  end

  function loader.start()
    bot.configure(params, holdallowed, allspin, tsdonly, searchwidth)

    local thread = love.thread.newThread(pathToThisFile)
    thread:start(true)
    loader.thread = thread
  end

  function loader.updateBot(queue, curr, hold, field, combo, b2b, incoming)
    -- print(queue, curr, hold)
    bot.updatequeue(queue)
    bot.updatecurrent(curr)
    bot.updatehold(hold)
    bot.updatefield(field)
    bot.updatecombo(combo)
    bot.updateb2b(b2b)
    bot.updateincoming(incoming)
  end

  function loader.think(thinkFinishedCallback)
    bot.updatethinking(true)

    thinkFinished = thinkFinishedCallback or function() end

    local request = love.thread.getChannel('request')
    request:push(true)
  end

  function loader.terminate()
    bot.updatethinking(false)
  end

  function loader.update()
    if loader.thread then
      if loader.thread:isRunning() then
        getFinishedMoveIfAvailable()
      else
        local errorMessage = loader.thread:getError()
        assert(not errorMessage, errorMessage)
      end
    end
  end

  function loader.getMove()
    return _move
  end

  return loader
end
