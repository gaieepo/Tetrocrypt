local pcfinder = require 'PCFinder'

local function printf(f)
  for i = 1, #f, 10 do
    print(f:sub(i, i + 9))
  end
end

local finder = {}

local loaded = ...

if loaded == true then
  local max_height = 6
  local swap = false
  local searchtype = 0

  -- pcfinder.setThread(4) -- (Optional)

  while true do
    local requestChannel = love.thread.getChannel('pcrequest')
    local req = requestChannel:pop()
    if req then
      -- printf(req[1])
      -- print(req[2], req[3])
      -- print(req[4], req[5], req[6])
      local solution = pcfinder.action(req[1], req[2], req[3],
        req[4], max_height, swap, searchtype, req[5], req[6])
      local producer = love.thread.getChannel('solution')
      producer:push(solution)
    end
  end
else
  local thinkFinished
  local pathToThisFile = (...):gsub('%.', '/') .. '.lua'
  local _solution

  local function getFoundSolutionIfAvailable()
    local consumer = love.thread.getChannel('solution')
    local solution = consumer:pop()
    if solution then
      _solution = solution
      print(solution)
      thinkFinished()
    end
  end

  function finder.start()
    local thread = love.thread.newThread(pathToThisFile)
    thread:start(true)
    finder.thread = thread
  end

  function finder.action(thinkFinishedCallback, field, queue, hold, height, combo, b2b)
    pcfinder.updatethinking(true)

    thinkFinished = thinkFinishedCallback or function() end

    local requestChannel = love.thread.getChannel('pcrequest')
    requestChannel:push({field, queue, hold, height, combo, b2b})
  end

  function finder.terminate()
    pcfinder.updatethinking(false)
  end

  function finder.update()
    if finder.thread then
      if finder.thread:isRunning() then
        getFoundSolutionIfAvailable()
      else
        local errorMessage = finder.thread:getError()
        assert(not errorMessage, errorMessage)
      end
    end
  end

  function finder.getSolution()
    return _solution
  end

  function finder.shutdown()
    pcfinder.shutdown()
  end

  return finder
end
