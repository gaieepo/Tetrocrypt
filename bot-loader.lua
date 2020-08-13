local bot = require 'GaiAI'
local lume = require 'libraries/lume/lume'

local loader = {}

local function printf(f)
  local rows = lume.split(f, '|')
  print('>>>>>')
  for _, v in ipairs(rows) do
    if #v > 0 then
      local row = ''
      for i = #v, 1, -1 do
        if v:sub(i, i) ~= ',' then
          row = row .. (v:sub(i, i) == '0' and '_' or 'X')
        end
      end
      print(row)
    end
  end
  print('<<<<<')
end

local loaded = ...

if loaded == true then
  while true do
    local requestChannel = love.thread.getChannel('request')
    local request = requestChannel:pop()
    if request == true then
      local move = bot.move()
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
    local move = consumer:pop()
    if move then
      _move = move
      -- print(move)
      thinkFinished()
    end
  end

  function loader.start()
    bot.configure(bot_params, bot_holdallowed, bot_allspin, bot_tsdonly, bot_searchwidth)

    local thread = love.thread.newThread(pathToThisFile)
    thread:start(true)
    loader.thread = thread
  end

  function loader.updateBot(queue, curr, hold, field, combo, b2b, incoming)
    -- printf(field)
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
      if loader.thread:isRunning() and bot.alive() then
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

  function loader.findPath(field, piece, x, y, r, hold)
    return bot.findPath(field, piece, x, y, r, hold)
  end

  return loader
end
