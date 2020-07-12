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

local params = {
  -- TSPIN + B2B (baseline)
  16, 9, 11, 17, 17,
  25, 39, 2, 12, 19,
  7, 24, 18, 7, 14,
  19, 99, 14, 19, 0,
  0,

  -- TST
  -- 16, 9, 11, 17, 500,
  -- 25, 39, 2, 12, 19,
  -- 7, 1, 18, 7, 14,
  -- 19, 25, 30, 18, 19,
  -- 0,

  -- JSTSPIN (baseline)
  -- 13, 9, 17, 10, 29,
  -- 25, 39, 2, 12, 19,
  -- 7, 24, 21, 16, 14,
  -- 19, 0, 0, 0, 0,
  -- 200,

  -- JSREN
  -- 13, 9, 17, 10, -271,
  -- 25, 39, 2, 12, 19,
  -- 7, -276, 21, 16, 11,
  -- 19, 0, 0, 0, 0,
  -- 200,


  -- RENTRAIN
  -- 13, 9, 17, 10, -300,
  -- 25, 39, 2, 12, 19,
  -- 7, -300, 21, 16, 9,
  -- 19, 0, 500, 0, 0,
  -- 200
}
local holdallowed = true
local allspin = false
local tsdonly = false
local searchwidth = 1000 -- 1000 optimal

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
      print(move)
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
