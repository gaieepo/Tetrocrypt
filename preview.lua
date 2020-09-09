Preview = class('Preview')

function Preview:initialize(psx, psy)
  self.queue = {}
  self.generate_count = 0

  self.pstartx = psx + PREVIEW_SX_OFFSET
  self.pstarty = psy + PREVIEW_SY_OFFSET

  -- Initialize queue
  for i = 1, NUM_BAGS do
    self.queue = fn.append(self.queue, self:nextBag())
  end
end

function Preview:update(dt)
end

function Preview:draw()
  local _nextn = self:peak(NUM_PREVIEW)
  for index, pid in ipairs(_nextn) do
    for i = 1, NUM_PIECE_BLOCKS do
      local x = PIECE_XS[PIECE_NAMES[pid]][1][i]
      local y = PIECE_YS[PIECE_NAMES[pid]][1][i]
      love.graphics.setColor(BLOCK_COLORS[PIECE_NAMES[pid]])
      love.graphics.rectangle('fill',
                              self.pstartx + x * GRID_SIZE, self.pstarty + (index - 1) * Y_SEPARATION + y * GRID_SIZE,
                              GRID_SIZE, GRID_SIZE)
      love.graphics.setColor(GRID_COLOR)
      love.graphics.rectangle('line',
                              self.pstartx + x * GRID_SIZE, self.pstarty + (index - 1) * Y_SEPARATION + y * GRID_SIZE,
                              GRID_SIZE, GRID_SIZE)
    end
  end
end

function Preview:nextBag()
  local bag = table.shuffle(BASE_BAG)
  return bag
end

function Preview:next()
  local _next = fn.shift(self.queue, 1)
  self.generate_count = self.generate_count + 1

  if #self.queue <= (NUM_BAGS - 1) * #BASE_BAG then
    self.queue = fn.append(self.queue, self:nextBag())
  end
  return _next
end

function Preview:peak(n)
  local _nextn = {}
  for i = 1, n do
    _nextn[i] = self.queue[i]
  end
  return _nextn
end

function Preview:peakBotString(n)
  local _nextn = ''
  local delimiter = ','
  local d = ''
  for i = 1, n do
    _nextn = _nextn .. d .. BOT_PIECE_NAMES[PIECE_NAMES[self.queue[i]]]
    d = delimiter
  end
  return _nextn
end

function Preview:peakString(n)
  local _nextn = ''
  for i = 1, n do
    _nextn = _nextn .. PIECE_NAMES[self.queue[i]]
  end
  return _nextn
end

function Preview:destroy()
end
