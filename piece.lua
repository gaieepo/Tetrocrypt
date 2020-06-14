Piece = Class('Piece', Entity)

function Piece:initialize(field, id, x, y, rot)
  Piece.super:initialize(self)

  self.field = field
  self.id, self.x, self.y = id, x, y

  self.shift_delay = das * frame_time
  self.arr_delay = arr * frame_time

  -- rot 0, 1, 2, 3
  self.rot = rot

  self.timer:every(gravity, function()
    if not self:collide(self.x, self.y - 1, self.rot, self.field) then
      self.y = self.y - 1
      -- self.timer:tween(0.5, self, {y = self.y - 1}, 'in-out-expo') -- non-blocking animation
    end
  end)
end

function Piece:update(dt)
  Piece.super.update(self, dt)

  -- Input handler
  if input:pressed('harddrop') then self:harddrop() end
  if input:down('move_left', self.arr_delay, self.shift_delay) then
    if not self:collide(self.x - 1, nil, nil, nil) then
      self.x = self.x - 1
    end
  end
  if input:down('softdrop') then
    if not self:collide(nil, self.y - 1, nil, nil) then
      self.y = self.y - 1
    end
  end
  if input:down('move_right', self.arr_delay, self.shift_delay) then
    if not self:collide(self.x + 1, nil, nil, nil) then
      self.x = self.x + 1
    end
  end

  if input:pressed('piece_rotate_right') then self:rotateRight() end
  if input:pressed('piece_rotate_left') then self:rotateLeft() end
  if input:pressed('piece_rotate_180') then self:rotate180() end

  for i=1, #piece_ids do
    input:bind(tostring(i), function()
      piece.id = piece_ids[i]
      piece.rot = 0
    end)
  end
end

function Piece:draw()
  for i = 1, num_piece_blocks do
    local x = piece_xs[self.id][self.rot + 1][i]
    local y = piece_ys[self.id][self.rot + 1][i]
    love.graphics.setColor(block_colors[self.id])
    love.graphics.rectangle('fill',
                            self.field.sx + (self.x + x - 1) * grid_size, self.field.sy - (self.y - y) * grid_size,
                            grid_size, grid_size)
    love.graphics.setColor(grid_color)
    love.graphics.rectangle('line',
                            self.field.sx + (self.x + x - 1) * grid_size, self.field.sy - (self.y - y) * grid_size,
                            grid_size, grid_size)
  end
end

function Piece:collide(x, y, rot, field)
  local x = x or self.x
  local y = y or self.y
  local rot = rot or self.rot
  local field = field or self.field

  for i = 1, num_piece_blocks do
    local x2 = x + piece_xs[self.id][rot + 1][i]
    local y2 = y - piece_ys[self.id][rot + 1][i]
    if x2 > h_grids or y2 < 1 then return true end
    if field.board[y2][x2] ~= 0 then return true end
  end
  return false
end

-- Movement --
function Piece:harddrop()
  local y = self.y
  while not self:collide(nil, y - 1, nil, nil) do y = y - 1 end

  -- lock
  for i = 1, num_piece_blocks do
    local x2 = self.x + piece_xs[self.id][self.rot + 1][i]
    local y2 = y - piece_ys[self.id][self.rot + 1][i]
    self.field.board[y2][x2] = piece_indices[self.id]
  end
end

function Piece:rotateRight()
  local rot = (self.rot + 1) % 4
  if not self:collide(nil, nil, rot, nil) then
    self.rot = rot
  else
    local kw = self.id == 'I' and wallkick_I_right or wallkick_normal_right
    for i = 1, #kw[self.rot + 1] do
      local x2 = kw[self.rot + 1][i][1]
      local y2 = kw[self.rot + 1][i][2]
      if not self:collide(self.x + x2, self.y - y2, rot, nil) then
        self.x = self.x + x2
        self.y = self.y - y2
        self.rot = rot
      return end
    end
  end
end

function Piece:rotateLeft()
  local rot = (self.rot + 4 - 1) % 4
  if not self:collide(nil, nil, rot, nil) then
    self.rot = rot
  else
    local kw = self.id == 'I' and wallkick_I_left or wallkick_normal_left
    for i = 1, #kw[self.rot + 1] do
      local x2 = kw[self.rot + 1][i][1]
      local y2 = kw[self.rot + 1][i][2]
      if not self:collide(self.x + x2, self.y - y2, rot, nil) then
        self.x = self.x + x2
        self.y = self.y - y2
        self.rot = rot
      return end
    end
  end
end

function Piece:rotate180()
  local rot = (self.rot + 4 - 2) % 4
  if not self:collide(nil, nil, rot, nil) then
    self.rot = rot
  else
    local kw = self.id == 'I' and wallkick_I_180 or wallkick_normal_180
    for i = 1, #kw[self.rot + 1] do
      local x2 = kw[self.rot + 1][i][1]
      local y2 = kw[self.rot + 1][i][2]
      if not self:collide(self.x + x2, self.y - y2, rot, nil) then
        self.x = self.x + x2
        self.y = self.y - y2
        self.rot = rot
      return end
    end
  end
end
