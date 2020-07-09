local pcfinder = require 'PCFinder'

local function convertfield(mx)
  local res = ''
  for i=1,#mx do
    res = res..mx[i]
  end
  return res
end

local matrix = {
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  '__________',
  -- 'XXXX__XXXX',
  -- 'XXX__XXXXX',
}

local queue = 'SZLJTOISZLJTOI'

local finder = {}

local loaded = ...

if loaded == true then
  while true do
    local requestChannel = love.thread.getChannel('request')
    local request = requestChannel:pop()
    if request == true then
      local solution = pcfinder.action(convertfield(matrix), queue, 'E',
        2, 6, false, 0, 0, 0)
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

  function finder.action(thinkFinishedCallback)
    pcfinder.updatethinking(true)

    thinkFinished = thinkFinishedCallback or function() end

    local request = love.thread.getChannel('request')
    request:push(true)
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

  return finder
end
