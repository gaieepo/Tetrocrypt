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

function Piece.static.getHorizontalFlip(rot)
  if rot == 1 then return 3 end
  if rot == 3 then return 1 end
  return rot
end

------------------------------------------

function Piece:initialize(state, layout, name, rot, x, y)
  Piece.super.initialize(self)

  -- Entity reference
  self.state = state
  self.layout = layout
  self.is_human = layout.is_human

  -- Piece Env
  self.name = name -- TODO copy constructor, index, name
  self.rot = rot or default_rot -- rot 0, 1, 2, 3
  self.x = x or self:getSpawnX()
  self.y = y or self:getSpawnY()
  self.hold_used = false
  self.last_valid_move = 'null'
  self.softdropping = false -- not used

  self.softdrop_delay = drop_coefficient * frame_time / softdrop_constant
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

  self.reset_done = false
  self.waiting_pcfinder = pcfinder_play
  self.waiting_bot = bot_play

  -- Stat register
  self.piece_count = 0
  self.do_tspinmini = false
  self.do_tspin = false
  self.is_b2b = false

  -- Bot
  self.thinkFinished = false
  self.use_bot_sequence = false
  self.pc_sequence = {}
  self.bot_sequence = {}
  self.bot_move_delay = bot_move_delay * frame_time
  self.bot_last_move = 0
  self.pcFinderThinkFinished = false

  -- Empty reset for consistency
  self:reset(self.name, false)

  -- Passive
  -- Auto Drop
  self.timer:every('autodrop', drop_coefficient * frame_time / gravity, function() -- TODO handle zero
    if not self:collide(self.x, self.y - 1, self.rot, self.layout.field) then
      self.y = self.y - 1
      -- self.timer:tween(0.5, self, {y = self.y - 1}, 'in-out-expo') -- non-blocking animation
    end
  end)
end

function Piece:update(dt)
  Piece.super.update(self, dt) -- update timer

  -- Input handler
  if input:pressed('debug') then self:adHocDebug() end

  -- A: is match, B: bot play, C: is human
  -- (C)(A + B') or B'C + AC
  if self.is_human and (game_mode == 'match' or not self.state.bot_play) then
    if input:pressed('harddrop') then self:harddrop() end
    -- if input:pressed('softdrop') then self:onSoftdropStart() end
    -- if input:released('softdrop') then self:onSoftdropEnd() end
    if input:down('softdrop', self.softdrop_delay) then self:softdrop() end

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
    -- Encoded
    self.shift_direction = piece_shift[self.last_left_shift .. self.last_right_shift .. self.left_shift .. self.right_shift]
    if input:down('move_left', self.arr_delay, self.shift_delay) and self.shift_direction == -1 then self:moveLeft() end
    if input:down('move_right', self.arr_delay, self.shift_delay) and self.shift_direction == 1 then self:moveRight() end

    if input:pressed('piece_rotate_right') then self:rotateRight() end
    if input:pressed('piece_rotate_left') then self:rotateLeft() end
    if input:pressed('piece_rotate_180') then self:rotate180() end
    if input:pressed('hold') then self:holdPiece() end
  end

  -- Passive --
  -- Bot logic
  if self.layout.field.field_updated and self.reset_done then
    -- (B)(A' + C')
    if self.state.bot_play and (not self.is_human or game_mode == 'analysis') then
      self:updateBot()
    end
    if self.state.pcfinder_play and (not self.is_human or game_mode == 'analysis') then
      self:updatePCFinder()
    end
    self.layout.field.field_updated = false
    self.reset_done = false
  end

  if self.pcFinderThinkFinished then
    local solution = pc_finder.getSolution()
    self:preprocessPCSolution(solution)
    self.waiting_pcfinder = false
    self.pcFinderThinkFinished = false
  end

  if self.thinkFinished and not self.waiting_pcfinder then
    local bot_move = bot_loader.getMove()
    local seq = fn.map(lume.split(lume.split(bot_move, '|')[1], ','), function(v )
      return tonumber(v)
    end)
    -- use bot only when both sequences are empty (normal)
    -- TODO when bot_sequence empty (dig mode)
    -- if #self.bot_sequence == 0 and #self.pc_sequence == 0 then
    if #self.bot_sequence == 0 then
      self.bot_sequence = fn.clone(seq)
    end
    self.waiting_bot = false
    self.thinkFinished = false
    self.use_bot_sequence = true -- start movement after both bot and pc done (TODO we assume pc faster than bot)
  end

  if self.use_bot_sequence and #self.bot_sequence > 0 and not self.waiting_bot then
    local elapsed = love.timer.getTime() - self.bot_last_move
    if elapsed > frame_time then
      if self:safeBotMove(self.bot_sequence) or elapsed > self.bot_move_delay then
        local valid = self:processBotSequence()
        if not valid then self.use_bot_sequence = false end

        self.bot_last_move = love.timer.getTime()
      end
    end
  end

  -- Lock & Force Lock
  if self:collide(nil, self.y - 1, nil, nil) then  -- collide bottom
    if self.lock_delay > self.lock_delay_maximum or self.force_lock_delay > self.force_lock_delay_maximum then
      -- Pre-lock process (update stat)
      self.piece_count = self.piece_count + 1

      if self.name == 'T' and self.last_valid_move == 'rotation' then
        if spin_mode == 'tspinonly' then
          self:setTSpin()
        elseif spin_mode == 'allspin' then
          self:setAllSpin()
        end
      else
        self.do_tspin = false
        self.do_tspinmini = false
      end

      self.layout.field:addPiece(self.name, self.rot, self.x, self.y)

      -- Respawn new piece
      self:reset(piece_names[self.layout.preview:next()], false)
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
                              self.layout.field.fstartx + (self.x + x - 1) * grid_size + 1, self.layout.field.fstarty - (y2 - y) * grid_size + 1,
                              grid_size - 2, grid_size - 2)
    end
    love.graphics.setLineWidth(1) -- reset line width TODO better way to resolve this
  end

  -- Piece
  for i = 1, num_piece_blocks do
    local x = piece_xs[self.name][self.rot + 1][i]
    local y = piece_ys[self.name][self.rot + 1][i]
    love.graphics.setColor(block_colors[self.name])
    love.graphics.rectangle('fill',
                            self.layout.field.fstartx + (self.x + x - 1) * grid_size, self.layout.field.fstarty - (self.y - y) * grid_size,
                            grid_size, grid_size)
    love.graphics.setColor(grid_color)
    love.graphics.rectangle('line',
                            self.layout.field.fstartx + (self.x + x - 1) * grid_size, self.layout.field.fstarty - (self.y - y) * grid_size,
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
  local field = field or self.layout.field

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

function Piece:softdrop()
  if not self:collide(nil, self.y - 1, nil, nil) then
    self.y = self.y - 1
    return true
  end
  return false
end

-- not used
-- function Piece:onSoftdropStart()
--   self.timer:cancel('autodrop')
--   self.softdropping = true
--
--   self.timer:every('softdrop', drop_coefficient * frame_time / softdrop, function()
--     if not self:collide(self.x, self.y - 1, self.rot, self.layout.field) then
--       self.y = self.y - 1
--     end
--   end)
-- end

-- not used
-- function Piece:onSoftdropEnd()
--   self.timer:cancel('softdrop')
--   self.softdropping = false
--
--   if not self.state.bot_play then
--     self.timer:every('autodrop', drop_coefficient * frame_time / gravity, function()
--       if not self:collide(self.x, self.y - 1, self.rot, self.layout.field) then
--         self.y = self.y - 1
--       end
--     end)
--   end
-- end

function Piece:moveLeft()
  if not self:collide(self.x - 1, nil, nil, nil) then
    self.x = self.x - 1

    -- reset lock delay only when movable
    self.lock_delay = 0
    self.last_valid_move = 'shift'
    return true
  else
    return false
  end
end

function Piece:moveRight()
  if not self:collide(self.x + 1, nil, nil, nil) then
    self.x = self.x + 1

    -- reset lock delay only when movable
    self.lock_delay = 0
    self.last_valid_move = 'shift'
    return true
  else
    return false
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

function Piece:holdPiece()
  if hold_allowed and not self.hold_used then
    local _to_hold = self.name
    if self.layout.hold.name ~= nil then
      self:reset(self.layout.hold.name, true)
    else
      self:reset(piece_names[self.layout.preview:next()], true)
    end
    self.layout.hold.name = _to_hold

    self.hold_used = true
  end
end

function Piece:updateBot()
  self.thinkFinished = false
  bot_loader.updateBot(
    self.layout.preview:peakBotString(num_bot_preview),
    bot_piece_names[self.name],
    bot_piece_names[self.layout.hold:getBotName()],
    self.layout.field:convertBotStr(),
    self.layout.field.combo_count + 1,
    self.layout.field.b2b_count + 1,
    0
    )
  bot_loader.think(function()
    self.thinkFinished = true
  end)
  self.timer:after(think_duration, function()
    bot_loader.terminate()
  end)
end

function Piece:updatePCFinder()
  self.pcFinderThinkFinished = false
  pc_finder.action(
    function()
      self.pcFinderThinkFinished = true
    end,
    self.layout.field:convertPCFinderStr(),
    self.name .. self.layout.preview:peakString(num_pcfinder_preview),
    self.layout.hold:getPCFinderName(),
    self.layout.field:getPCHeight(),
    self.layout.field.combo_count + 1,
    self.layout.field.b2b_count + 1
    )
  self.timer:after(pcfinder_think_duration, function()
    pc_finder.terminate()
  end)
end

function Piece:reset(name, use_hold)
  self.name = name
  self.rot = default_rot
  self.x = self:getSpawnX()
  self.y = self:getSpawnY()
  self.hold_used = false
  self.last_valid_move = 'null'

  self.shift_direction = 0
  self.lock_delay = 0
  self.force_lock_delay = 0

  -- Update bot
  if not use_hold then
    self.reset_done = true
    self.waiting_pcfinder = pcfinder_play
    self.waiting_bot = bot_play
  end

  -- if self.state.bot_play and not use_hold then
  --   self:updateBot()
  -- end

  -- if self.state.pcfinder_play and not use_hold then
  --   self:updatePCFinder()
  -- end

  if not use_hold then self.bot_sequence = {} end  -- make sure bot seq empty for every no-hold new piece

  -- Stat related
  -- self.do_tspinmini = false
  -- self.do_tspin = false
end

function Piece:setTSpin()
  -- Mini involves kicking
  if self:collide(nil, nil, self.class.static.getRotateLeft(self.rot), nil)
    and self:collide(nil, nil, self.class.static.getRotateRight(self.rot), nil) then
    self.do_tspinmini = true
  else
    self.do_tspinmini = false
  end

  local tx = {0, 2, 0, 2}
  local ty = {0, 0, 2, 2}

  local count = 0
  for i = 1, #tx do
    if self.layout.field:getBlock(self.x + tx[i], self.y - ty[i]) ~= empty_block_value then
      count = count + 1
    end
  end

  if count >= 3 then
    self.do_tspin = true
  else
    self.do_tspin = false
  end
end

function Piece:setAllSpin()
  -- (Optional) refer to nullpomino
end

-- Bot logic
function Piece:safeBotMove(m)
  local _safeMoves = {MOV_NULL, MOV_LL, MOV_RR, MOV_DD, MOV_HOLD}
  -- LL/RR/DD
  if fn.contains(_safeMoves, m[1]) then return true end
  -- two consecutive L or R or D
  if m[1] == m[2] then return true end
  -- L and R
  if (m[1] == MOV_L and m[2] == MOV_R) or (m[1] == MOV_R and m[2] == MOV_L) then return true end
  return false
end

function Piece:processBotSequence()
  -- MOV_NULL  = 0
  -- MOV_L     = 1
  -- MOV_R     = 2
  -- MOV_LL    = 3
  -- MOV_RR    = 4
  -- MOV_D     = 5
  -- MOV_DD    = 6
  -- MOV_LSPIN = 7
  -- MOV_RSPIN = 8
  -- MOV_DROP  = 9
  -- MOV_HOLD  = 10
  -- MOV_SPIN2 = 11
  if #self.bot_sequence == 0 then
    return false
  end

  if self.bot_sequence[1] == MOV_HOLD then
    self:holdPiece()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_L then
    self:moveLeft()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_R then
    self:moveRight()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_D then
    self:softdrop()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_DROP then
    self:harddrop()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_LSPIN then
    self:rotateLeft()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_RSPIN then
    self:rotateRight()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_SPIN2 then
    self:rotate180()
    table.remove(self.bot_sequence, 1)
  elseif self.bot_sequence[1] == MOV_LL then
    local valid = self:moveLeft()
    if not valid then table.remove(self.bot_sequence, 1) end
  elseif self.bot_sequence[1] == MOV_RR then
    local valid = self:moveRight()
    if not valid then table.remove(self.bot_sequence, 1) end
  elseif self.bot_sequence[1] == MOV_DD then
    local valid = self:softdrop()
    if not valid then table.remove(self.bot_sequence, 1) end
  else
    table.remove(self.bot_sequence, 1)
  end

  return true
end

function Piece:preprocessPCSolution(solution)
  -- Update new sequence
  if solution ~= nil and solution ~= '-1' then
    local solution = solution:sub(1, #solution - 1)
    bot_loader.terminate() -- bot terminate in advance
    local seq = lume.split(solution, '|')
    if #self.pc_sequence == 0 or #self.pc_sequence > #seq then
      self.pc_sequence = seq -- force update pc sequence if there is one
    end
  end

  -- Process first piece
  if #self.pc_sequence > 0 then
    local sol = lume.split(self.pc_sequence[1], ',')
    table.remove(self.pc_sequence, 1) -- pop first item

    local name = pcfinder_piece_names[tonumber(sol[1]) + 1]
    local x = tonumber(sol[2])
    local y = tonumber(sol[3])
    local rot = tonumber(sol[4])
    -- bot coord
    x = x + pcfinder_offset[name][rot + 1][1]
    y = y + pcfinder_offset[name][rot + 1][2]

    local path = bot_loader.findPath(
      self.layout.field:convertBotStr(),
      bot_piece_names[name],
      x,
      v_grids - y,
      self.class.getHorizontalFlip(rot),
      name ~= self.name
      )
    -- will not find path if in dig mode -> field changed compared to pc solution
    ---- path not found
    if path == '0' then return end

    local seq = fn.map(lume.split(lume.split(path, '|')[1], ','), function(v)
      return tonumber(v)
    end)
    -- assert bot_sequence zero
    if #self.bot_sequence == 0 then
      self.bot_sequence = fn.clone(seq)
    end
  end
end

function Piece:adHocDebug()
  fn.push(self.layout.field.incoming_garbage, love.math.random(1, 4))
  print('Debug add random garbage: ', Inspect(self.layout.field.incoming_garbage))
end
