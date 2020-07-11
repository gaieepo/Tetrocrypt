local pcfinder = require 'PCFinder'

-- local function convertfield(mx)
--   local res = ''
--   for i=1,#mx do
--     res = res..mx[i]
--   end
--   return res
-- end
--
-- local matrix = {
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   '__________',
--   -- 'XXXX__XXXX',
--   -- 'XXX__XXXXX',
-- }
-- local queue = 'SZLJTOISZLJTOI'

local finder = {}

local loaded = ...

if loaded == true then
  local max_height = 6
  local swap = false
  local searchtype = 0

  while true do
    local requestChannel = love.thread.getChannel('request')
    local request = requestChannel:pop()
    if request then
      -- local solution = pcfinder.action(convertfield(matrix), queue, 'E',
      --   2, max_height, swap, searchtype, 0, false)
      local solution = pcfinder.action(request[1], request[2], request[3],
        request[4], max_height, swap, searchtype, request[5], request[6])
      -- for i = 1, 6 do
      --   print(request[i])
      -- end
      local producer = love.thread.getChannel('solution')
      producer:push(solution)
    end
  end
else
  local thinkFinished
  local pathToThisFile = (...):gsub('%.', '/') .. '.lua'
  local _solution
  local field, queue, hold, height, combo, b2b

  local function getFoundSolutionIfAvailable()
    local consumer = love.thread.getChannel('solution')
    local solution = consumer:pop()
    if solution then
      _solution = solution
      print(solution)
      thinkFinished()
    end
  end

  function finder.updatePCFinder(fld, que, hd, h, c, b)
    field = fld
    queue = que
    hold = hd
    height = h
    combo = c
    b2b = b
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
    request:push({field, queue, hold, height, combo, b2b})
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
