local bot1 = require 'GaiAI1'
local bot2 = require 'GaiAI2'
local lume = require 'libs/lume'

local loaders = {}

local BOT2_PARAMS = {
  -- JSTSPIN (baseline)
  13, 9, 17, 10, 29,
  25, 39, 2, 12, 19,
  7, 24, 21, 16, 14,
  19, 0, 0, 0, 0,
  200,
}

local loaded = ...

if loaded == 1 then
  while true do
    local requestChannel = love.thread.getChannel('request1')
    local request = requestChannel:pop()
    if request == true then
      local move1 = bot1.move()
      local producer = love.thread.getChannel('move1')
      producer:push(move1)
    end
  end
elseif loaded == 2 then
  while true do
    local requestChannel = love.thread.getChannel('request2')
    local request = requestChannel:pop()
    if request == true then
      local move2 = bot2.move()
      local producer = love.thread.getChannel('move2')
      producer:push(move2)
    end
  end
else
  local thinkFinished1, thinkFinished2
  local pathToThisFile = (...):gsub('%.', '/') .. '.lua'
  local _move1, _move2

  local function getFinishedMoveIfAvailable()
    local consumer1 = love.thread.getChannel('move1')
    local move1 = consumer1:pop()
    if move1 then
      _move1 = move1
      if DEBUG then log.trace(move1) end
      thinkFinished1()
    end

    local consumer2 = love.thread.getChannel('move2')
    local move2 = consumer2:pop()
    if move2 then
      _move2 = move2
      if DEBUG then log.trace(move2) end
      thinkFinished2()
    end
  end

  function loaders.start()
    bot1.configure(BOT_PARAMS['TSPINB2B'], BOT_HOLDALLOWED, BOT_ALLSPIN, BOT_TSDONLY, BOT_SEARCHWIDTH)
    bot2.configure(BOT_PARAMS['JSTSPINCOMBO'], BOT_HOLDALLOWED, BOT_ALLSPIN, BOT_TSDONLY, BOT_SEARCHWIDTH)

    local thread1 = love.thread.newThread(pathToThisFile)
    thread1:start(1)
    loaders.thread1 = thread1

    local thread2 = love.thread.newThread(pathToThisFile)
    thread2:start(2)
    loaders.thread2 = thread2
  end

  function loaders.updateBot(index, queue, curr, hold, field, combo, b2b, incoming)
    if index == 1 then
      bot1.updatequeue(queue)
      bot1.updatecurrent(curr)
      bot1.updatehold(hold)
      bot1.updatefield(field)
      bot1.updatecombo(combo)
      bot1.updateb2b(b2b)
      bot1.updateincoming(incoming)
    elseif index == 2 then
      bot2.updatequeue(queue)
      bot2.updatecurrent(curr)
      bot2.updatehold(hold)
      bot2.updatefield(field)
      bot2.updatecombo(combo)
      bot2.updateb2b(b2b)
      bot2.updateincoming(incoming)
    end
  end

  function loaders.think(index, thinkFinishedCallback)
    if index == 1 then
      bot1.updatethinking(true)

      thinkFinished1 = thinkFinishedCallback or function() end

      local request1 = love.thread.getChannel('request1')
      request1:push(true)
    elseif index == 2 then
      bot2.updatethinking(true)

      thinkFinished2 = thinkFinishedCallback or function() end

      local request2 = love.thread.getChannel('request2')
      request2:push(true)
    end
  end

  function loaders.terminate(index)
    if index == 1 then
      bot1.updatethinking(false)
    elseif index == 2 then
      bot2.updatethinking(false)
    else
      bot1.updatethinking(false)
      bot2.updatethinking(false)
    end
  end

  function loaders.update()
    if loaders.thread1 and loaders.thread2 then
      if loaders.thread1:isRunning() and loaders.thread2:isRunning() and bot1.alive() and bot2.alive() then
        getFinishedMoveIfAvailable()
      else
        local errorMessage1 = loaders.thread1:getError()
        assert(not errorMessage1, errorMessage1)

        local errorMessage2 = loaders.thread2:getError()
        assert(not errorMessage2, errorMessage2)
      end
    end
  end

  function loaders.getMove(index)
    if index == 1 then
      return _move1
    elseif index == 2 then
      return _move2
    end
  end

  function loaders.findPath(index, field, piece, x, y, r, hold)
    if index == 1 then
      return bot1.findPath(field, piece, x, y, r, hold)
    elseif index == 2 then
      return bot2.findPath(field, piece, x, y, r, hold)
    end
  end

  return loaders
end
