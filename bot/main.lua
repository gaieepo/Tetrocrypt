local bot = require 'GaiAI'

local params = {
  13, 9, 17, 10, -300,
  25, 39, 2, 12, 19,
  7, -300, 21, 16, 9,
  19, 0, 500, 0, 0,
  200
}
local holdallowed = true
local allspin = false
local tsdonly = false
local searchwidth = 10000 -- 1000 optimal

local matrix = {
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {2,2,2,2,0,0,0,0,0,0},
  {2,2,2,0,0,0,0,0,2,2},
  {2,2,2,0,2,2,2,2,2,2},
  {2,2,2,0,0,0,0,2,2,2},
  {2,2,2,0,0,0,2,2,2,2},
  {2,2,2,2,2,0,0,2,2,2},
  {2,2,2,2,2,0,0,0,2,2},
  {2,2,2,2,2,2,2,0,2,2},
  {2,2,2,2,2,2,0,0,2,2},
  {2,2,2,2,0,0,0,0,2,2},
  {2,2,2,2,0,0,0,2,2,2},
  {2,2,2,2,0,0,2,2,2,2},
  {2,2,2,2,0,0,0,2,2,2},
  {2,2,2,2,2,2,0,2,2,2},
  {2,2,2,2,2,0,0,0,2,2},
  {2,2,2,2,2,2,0,2,2,2},
  {2,2,2,2,0,2,2,2,2,2},
  {2,2,2,2,2,0,2,2,2,2},
}

local function convertfield(mx)
  local res = ''
  local colbreak = ','
  local rowbreak = '|'
  local rowprefix = ''
  for i=1,#mx do
    local row = ''
    local colprefix = ''
    for j=1,#mx[i] do
      row = row..colprefix..mx[i][#mx[i] + 1 - j]
      colprefix = colbreak
    end
    res = res..rowprefix..row
    rowprefix = rowbreak
  end
  return res
end

-- check vs. to
-- bot.sum(1, 2)

bot.configure(params, holdallowed, allspin, tsdonly, searchwidth)

bot.updatethinking(true);

if bot.alive() then
  bot.updatequeue('S,Z,O,J,I')
  bot.updatecurrent('T')
  bot.updatehold(' ')
  bot.updatefield(convertfield(matrix))
  bot.updatecombo(0)
  bot.updateb2b(0)
  bot.updateincoming(0)

  local starttime = os.time()
  local mov = bot.move()
  local endtime = os.time()
  print('Time elapsed: '..os.difftime(endtime, starttime))
  print(mov)
end

-- print(convertfield(matrix))
