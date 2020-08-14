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
}

local queue = 'SZLJTOISZLJTOI'
-- {'T', 'I', 'L', 'J', 'S', 'Z', 'O'}
--   0    1    2    3    4    5    6

pcfinder.updatethinking(true)
-- pcfinder.setThread(8)
solution = pcfinder.action(convertfield(matrix), queue, 'E',
  2, 6, false, 0, 0, 0)

print('result: ' .. solution)

pcfinder.updatethinking(false)
