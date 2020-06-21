Preview = class('Preview')

function Preview:initialize(sx, sy)
  self.queue = {}
  self.generate_count = 0

  self.sx = sx + preview_sx_offset
  self.sy = sy + preview_sy_offset

  -- Initialize queue
  -- 4 bags to ensure
  for i = 1, 4 do
    self.queue = fn.append(self.queue, self:nextBag())
  end
end

function Preview:update(dt)
end

function Preview:draw()
  local _nextn = self:peak(num_preview)
  for index, pid in ipairs(_nextn) do
    for i = 1, num_piece_blocks do
      local x = piece_xs[piece_names[pid]][1][i]
      local y = piece_ys[piece_names[pid]][1][i]
      love.graphics.setColor(block_colors[piece_names[pid]])
      love.graphics.rectangle('fill',
                              self.sx + x * grid_size, self.sy + (index - 1) * y_separation + y * grid_size,
                              grid_size, grid_size)
      love.graphics.setColor(grid_color)
      love.graphics.rectangle('line',
                              self.sx + x * grid_size, self.sy + (index - 1) * y_separation + y * grid_size,
                              grid_size, grid_size)
    end
  end
end

function Preview:nextBag()
  local bag = table.shuffle({1, 2, 3, 4, 5, 6, 7})
  return bag
end

function Preview:next()
  local _next = fn.shift(self.queue, 1)
  self.generate_count = self.generate_count + 1

  if #self.queue <= 21 then
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

function Preview:peakString(n)
  local _nextn = ''
  local delimiter = ','
  local d = ''
  for i = 1, n do
    _nextn = _nextn .. d .. piece_names[self.queue[i]]
    d = delimiter
  end
  return _nextn
end
