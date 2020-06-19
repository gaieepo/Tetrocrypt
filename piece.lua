Piece = class('Piece', Entity)

function Piece.static.getRotateRight(rot)
  return (rot + 1) % 4
end

function Piece.static.getRotateLeft(rot)
  return (rot + 4 - 1) % 4
end

function Piece.static.getRotate180(rot)
  return (rot + 4 - 2) % 4
end

function Piece:initialize(state, field, name, rot, x, y)
  Piece.super.initialize(self, state)

  -- Piece Env
  self.field = field
  self.name = name -- TODO copy constructor, index, name
  self.rot = rot or default_rot -- rot 0, 1, 2, 3
  self.x = x or self:getSpawnX()
  self.y = y or self:getSpawnY()
  self.hold_used = false
  self.last_valid_move = 'null'

  self.shift_delay = das * frame_time
  self.arr_delay = arr * frame_time

  self.last_left_shift = '0'
  self.last_right_shift = '0'
  self.left_shift = '0'
  self.right_shift = '0'
  self.shift_direction = 0

  self.lock_delay = 0
  self.lock_delay_maximum = lock_delay_limit * frame_time
  self.force_lock_delay = 0
  self.force_lock_delay_maximum = force_lock_delay_limit * frame_time

  -- Passive
  -- Auto Drop
  self.timer:every('autodrop', drop_coefficient * frame_time / gravity, function() -- TODO handle zero
    if not self:collide(self.x, self.y - 1, self.rot, self.field) then
      self.y = self.y - 1
      -- self.timer:tween(0.5, self, {y = self.y - 1}, 'in-out-expo') -- non-blocking animation
    end
  end)
end

function Piece:update(dt)
  Piece.super.update(self, dt) -- update timer

  -- Input handler
  if input:pressed('harddrop') then self:harddrop() end
  if input:pressed('softdrop') then self:onSoftdropStart() end
  if input:released('softdrop') then self:onSoftdropEnd() end

  -- piece shift state
  if input:pressed('move_left') then
    self.last_left_shift = self.left_shift
    self.last_right_shift = self.right_shift
    self.left_shift = '1'
  end
  if input:released('move_left') then
    self.last_left_shift = self.left_shift
    self.last_right_shift = self.right_shift
    self.left_shift = '0'
  end
  if input:pressed('move_right') then
    self.last_left_shift = self.left_shift
    self.last_right_shift = self.right_shift
    self.right_shift = '1'
  end
  if input:released('move_right') then
    self.last_left_shift = self.left_shift
    self.last_right_shift = self.right_shift
    self.right_shift = '0'
  end
  self.shift_direction = piece_shift[self.last_left_shift .. self.last_right_shift .. self.left_shift .. self.right_shift]
  if input:down('move_left', self.arr_delay, self.shift_delay) and self.shift_direction == -1 then self:moveLeft() end
  if input:down('move_right', self.arr_delay, self.shift_delay) and self.shift_direction == 1 then self:moveRight() end

  if input:pressed('piece_rotate_right') then self:rotateRight() end
  if input:pressed('piece_rotate_left') then self:rotateLeft() end
  if input:pressed('piece_rotate_180') then self:rotate180() end
  if input:pressed('hold') then self:hold() end

  -- Passive --
  -- Lock & Force Lock
  if self:collide(nil, self.y - 1, nil, nil) then  -- collide bottom
    if self.lock_delay > self.lock_delay_maximum or self.force_lock_delay > self.force_lock_delay_maximum then
      -- Pre-lock process
      stat.pieces = stat.pieces + 1

      if self.name == 'T' and self.last_valid_move == 'rotation' then
        if spin_mode == 'tspinonly' then
          self:setTSpin()
        elseif spin_mode == 'allspin' then
          self:setAllSpin()
        end
      else
        stat.tspin = false
        stat.tspinmini = false
      end

      field:addPiece(self.name, self.rot, self.x, self.y)

      -- Respawn new piece
      self:reset(piece_names[preview:next()])
    else
      self.lock_delay = self.lock_delay + dt
      self.force_lock_delay = self.force_lock_delay + dt
    end
  else
    self.lock_delay = 0
    -- self.force_lock_delay = 0 (caution: temporary floating does not reset force lock delay)
  end

  -- Dead condition (might move to session)
  -- 1. spawn with collision, when legal collide everything
  -- 2. lock with higher than visible field TODO
  if self:collide() then self.state.session_state = GAME_LOSS end
end

function Piece:draw()
  -- Ghost
  local y2 = self.y
  while not self:collide(nil, y2 - 1, nil, nil) do y2 = y2 - 1 end

  if y2 ~= self.y then
    for i = 1, num_piece_blocks do
      local x = piece_xs[self.name][self.rot + 1][i]
      local y = piece_ys[self.name][self.rot + 1][i]
      love.graphics.setColor(block_colors[self.name])
      love.graphics.setLineWidth(3)
      love.graphics.rectangle('line',
                              self.field.sx + (self.x + x - 1) * grid_size, self.field.sy - (y2 - y) * grid_size,
                              grid_size, grid_size)
    end
    love.graphics.setLineWidth(1) -- reset line width TODO better way to resolve this
  end

  -- Piece
  for i = 1, num_piece_blocks do
    local x = piece_xs[self.name][self.rot + 1][i]
    local y = piece_ys[self.name][self.rot + 1][i]
    love.graphics.setColor(block_colors[self.name])
    love.graphics.rectangle('fill',
                            self.field.sx + (self.x + x - 1) * grid_size, self.field.sy - (self.y - y) * grid_size,
                            grid_size, grid_size)
    love.graphics.setColor(grid_color)
    love.graphics.rectangle('line',
                            self.field.sx + (self.x + x - 1) * grid_size, self.field.sy - (self.y - y) * grid_size,
                            grid_size, grid_size)
  end
end

function Piece:destroy()
  Piece.super.destroy(self)
end

function Piece:getSpawnX()
  return 1 + math.floor((h_grids - piece_widths[self.name][self.rot + 1]) / 2)
end

function Piece:getSpawnY()
  return v_grids + piece_max_heights[self.name][self.rot + 1]
end

function Piece:collide(x, y, rot, field)
  local x = x or self.x
  local y = y or self.y
  local rot = rot or self.rot
  local field = field or self.field

  for i = 1, num_piece_blocks do
    local x2 = x + piece_xs[self.name][rot + 1][i]
    local y2 = y - piece_ys[self.name][rot + 1][i]
    -- if x2 > h_grids or y2 < 1 then return true end
    if field:getBlock(x2, y2) ~= 0 then return true end
  end
  return false
end

-- Movement --
function Piece:harddrop()
  local y = self.y
  while not self:collide(nil, y - 1, nil, nil) do y = y - 1 end

  self.y = y
  self.lock_delay = self.lock_delay_maximum
end

function Piece:onSoftdropStart()
  self.timer:cancel('autodrop')

  self.timer:every('softdrop', drop_coefficient * frame_time / softdrop, function()
    if not self:collide(self.x, self.y - 1, self.rot, self.field) then
      self.y = self.y - 1
    end
  end)
end

function Piece:onSoftdropEnd()
  self.timer:cancel('softdrop')

  self.timer:every('autodrop', drop_coefficient * frame_time / gravity, function()
    if not self:collide(self.x, self.y - 1, self.rot, self.field) then
      self.y = self.y - 1
    end
  end)
end

function Piece:moveLeft()
    if not self:collide(self.x - 1, nil, nil, nil) then
      self.x = self.x - 1

      -- reset lock delay only when movable
      self.lock_delay = 0
      self.last_valid_move = 'shift'
    end
end

function Piece:moveRight()
    if not self:collide(self.x + 1, nil, nil, nil) then
      self.x = self.x + 1

      -- reset lock delay only when movable
      self.lock_delay = 0
      self.last_valid_move = 'shift'
    end
end

function Piece:rotateRight()
  local rot = self.class.getRotateRight(self.rot)
  if not self:collide(nil, nil, rot, nil) then
    self.rot = rot
  else
    local kw = self.name == 'I' and wallkick_I_right or wallkick_normal_right
    for i = 1, #kw[self.rot + 1] do
      local x2 = kw[self.rot + 1][i][1]
      local y2 = kw[self.rot + 1][i][2]
      if not self:collide(self.x + x2, self.y - y2, rot, nil) then
        self.x = self.x + x2
        self.y = self.y - y2
        self.rot = rot
        break
      end
    end
  end

  -- reset lock delay
  self.lock_delay = 0
  self.last_valid_move = 'rotation'
end

function Piece:rotateLeft()
  local rot = self.class.getRotateLeft(self.rot)
  if not self:collide(nil, nil, rot, nil) then
    self.rot = rot
  else
    local kw = self.name == 'I' and wallkick_I_left or wallkick_normal_left
    for i = 1, #kw[self.rot + 1] do
      local x2 = kw[self.rot + 1][i][1]
      local y2 = kw[self.rot + 1][i][2]
      if not self:collide(self.x + x2, self.y - y2, rot, nil) then
        self.x = self.x + x2
        self.y = self.y - y2
        self.rot = rot
        break
      end
    end
  end

  -- reset lock delay
  self.lock_delay = 0
  self.last_valid_move = 'rotation'
end

function Piece:rotate180()
  local rot = self.class.getRotate180(self.rot)
  if not self:collide(nil, nil, rot, nil) then
    self.rot = rot
  else
    local kw = self.name == 'I' and wallkick_I_180 or wallkick_normal_180
    for i = 1, #kw[self.rot + 1] do
      local x2 = kw[self.rot + 1][i][1]
      local y2 = kw[self.rot + 1][i][2]
      if not self:collide(self.x + x2, self.y - y2, rot, nil) then
        self.x = self.x + x2
        self.y = self.y - y2
        self.rot = rot
        break
      end
    end
  end

  -- reset lock delay
  self.lock_delay = 0
  self.last_valid_move = 'rotation'
end

function Piece:hold()
  if hold_allowed and not self.hold_used then
    local _to_hold = self.name
    if hold.name ~= nil then
      self:reset(hold.name)
    else
      self:reset(piece_names[preview:next()])
    end
    hold.name = _to_hold

    self.hold_used = true
  end
end

function Piece:reset(name, x, y, rot)
  self.name = name

  self.rot = rot or default_rot
  self.x = x or self:getSpawnX()
  self.y = y or self:getSpawnY()
  self.hold_used = false
  self.last_valid_move = 'null'

  self.lock_delay = 0
  self.force_lock_delay = 0
end

function Piece:setTSpin()
  if self:collide(nil, nil, self.class.static.getRotateLeft(self.rot), nil)
    and self:collide(nil, nil, self.class.static.getRotateRight(self.rot), nil) then
    stat.tspinmini = true
  else
    stat.tspinmini = false
  end

  local tx = {0, 2, 0, 2}
  local ty = {0, 0, 2, 2}

  local count = 0
  for i = 1, #tx do
    if self.field:getBlock(self.x + tx[i], self.y - ty[i]) ~= empty_block_value then
      count = count + 1
    end
  end

  if count >= 3 then
    stat.tspin = true
  else
    stat.tspin = false
  end
end

function Piece:setAllSpin()
end
