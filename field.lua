local Each = require 'modules/Each'

Field = class('Field', Entity):include(Each)

function Field.static:sendGarbageToOthers(id, garbage)
  for instance, _ in pairs(self._instances) do
    if instance.id ~= id then
      fn.push(instance.incoming_garbage, garbage)
    end
  end
end

------------------------------------

function Field:initialize(layout, fsx, fsy)
  Field.super.initialize(self)

  -- Entity reference
  self.layout = layout

  -- Field Env
  self.trigger_update = false
  self.field_updated = true -- initial true for bot update sequence
  self.clearing = false
  self.fstartx = fsx + FIELD_SX_OFFSET
  self.fstarty = fsy + FIELD_SY_OFFSET
  self.board = {}
  self.incoming_garbage = {}

  -- Stat register
  self.total_lines = 0
  self.combo_count = -1
  self.b2b_count = 0
  self.pc_distance = 0 -- piece distance since last pc
  self.ps_count = 0 -- pc series count
  self.current_attack = 0
  self.total_attack = 0

  -- Initialize board
  for r = 1, V_GRIDS + X_GRIDS do
    local row = {}
    for c = 1, H_GRIDS do
      row[c] = 0
    end
    self.board[r] = row
  end

  -- Debug (TODO logic not smooth)
  if DIG_MODE then
    self.dig_timer = 0
  end

  -- add to field collections
  self.class:add(self)
end

function Field:convertBotStr()
  local _field = ''
  local colbreak = ','
  local rowbreak = '|'
  local rowprefix = ''
  for i = V_GRIDS, 1, -1 do
    local row = ''
    local colprefix = ''
    for j = 1, #self.board[i] do
      row = row .. colprefix .. (self.board[i][#self.board[i] - j + 1] == 0 and 0 or 2)
      colprefix = colbreak
    end
    _field = _field .. rowprefix .. row
    rowprefix = rowbreak
  end
  return _field
end

function Field:convertPCFinderStr()
  local _field = ''
  for i = V_GRIDS, 1, -1 do
    local row = ''
    for j = 1, #self.board[i] do
      row = row .. (self.board[i][j] == 0 and '_' or 'X')
    end
    _field = _field .. row
  end
  return _field
end

function Field:getPCHeight()
  local h = -1
  for i = V_GRIDS, 1, -1 do
    if not table.empty(self.board[i]) and h == -1 then h = i end
  end
  if h == -1 then h = 2 end
  return h
end

function Field:update(dt)
  Field.super.update(self, dt) -- update timer

  -- Dig mode timer
  if DIG_MODE and self.dig_timer then
    self.dig_timer = self.dig_timer + dt
  end

  -- Post piece event
  if self.trigger_update then
    -- Line clearing (including clear delay)
    local lines = self:checkLines()

    -- Update stat (for all piece lock)
    self.total_lines = self.total_lines + lines
    self.combo_count = lines == 0 and -1 or (self.combo_count + 1)

    if lines > 0 then
      self.clearing = true -- clearing will hold piece update if true
      self:clearLines()
      self.timer:after(LINE_CLEAR_DELAY * FRAME_TIME, function()
        self:fallStack()
        self.clearing = false -- bot piece to update bot and finder
        -- self.cleared = true TODO figure out when it is used
      end)

      -- Update stat (when lines cleared)
      self.current_attack = self:calculateAttack(lines)
      self.total_attack = self.total_attack + self.current_attack

      -- Post attack (b2b should be updated after attack)
      self.b2b_count = self:recognizeB2b(lines) and (self.b2b_count + 1) or 0
      if self:isEmpty() then -- Perfect Clear
        self.ps_count = self:recognizePS() and (self.ps_count + 1) or 0
        self.pc_distance = 0
      end

      -- Counter-garbage
      if self.current_attack > 0 then
        local attack_remain = self:counterGarbage(self.current_attack)

        -- Send garbage to the rest if there are still fire left
        -- (TODO more flexible tactic design)
        if attack_remain > 0 then
          Field:sendGarbageToOthers(self.id, attack_remain)
        end
      end
    end

    -- Dig mode logic
    if DIG_MODE and self.dig_timer > DIG_DELAY then
      fn.push(self.incoming_garbage, 1)
      self.dig_timer = 0
    end

    -- Spawn all existing garbage (TODO some will hold during combo)
    self:spawnGarbage()

    self.trigger_update = false
    self.field_updated = true
  end

  -- Game Mode
  if SESSION_MODE == 'analysis' and GAME_MODE == 'sprint' and self.total_lines >= SPRINT_LINES then
    self.layout.game_status = GAME_WIN
  end
end

function Field:draw()
  -- Grid
  for i, row in ipairs(self.board) do
    if i <= DISPLAY_HEIGHT then
      for j, col in ipairs(row) do
        if self.board[i][j] == EMPTY_BLOCK_VALUE then
          love.graphics.setColor(BLOCK_COLORS['E'])
        elseif self.board[i][j] == GARBAGE_BLOCK_VALUE then
          love.graphics.setColor(BLOCK_COLORS['B'])
        elseif LOCK_COLOR == 'colored' then
          love.graphics.setColor(fn.mapi(BLOCK_COLORS[PIECE_NAMES[self.board[i][j]]], function(v) return v * 0.8 end))
        elseif LOCK_COLOR == 'mono' then
          love.graphics.setColor(BLOCK_COLORS['B'])
        end
        love.graphics.rectangle('fill',
                                self.fstartx + (j - 1) * GRID_SIZE, self.fstarty - i * GRID_SIZE,
                                GRID_SIZE, GRID_SIZE)
        love.graphics.setColor(GRID_COLOR)
        love.graphics.rectangle('line',
                                self.fstartx + (j - 1) * GRID_SIZE, self.fstarty - i * GRID_SIZE,
                                GRID_SIZE, GRID_SIZE)
      end
    end
  end

  -- Hidden break line
  love.graphics.setColor(1, 0, 0)
  love.graphics.line(self.fstartx, self.fstarty - V_GRIDS * GRID_SIZE,
                     self.fstartx + H_GRIDS * GRID_SIZE, self.fstarty - V_GRIDS * GRID_SIZE)

  -- Combo / B2B / Incoming
  if SESSION_MODE ~= 'analysis' then
    love.graphics.setColor(1, 1, 1)

    -- combo
    if self.combo_count > 0 then
      love.graphics.print('Combo ' .. self.combo_count, self.fstartx - 5 * GRID_SIZE, self.fstarty - 10 * GRID_SIZE)
    end

    -- b2b
    if self.b2b_count > 1 then
      love.graphics.print('B2B ' .. self.b2b_count, self.fstartx - 5  * GRID_SIZE, self.fstarty - 7 * GRID_SIZE)
    end
  end

  -- Inncoming garbage bar
  love.graphics.setColor(GRID_COLOR)
  love.graphics.rectangle('line',
                          self.fstartx + H_GRIDS * GRID_SIZE, self.fstarty - DISPLAY_HEIGHT * GRID_SIZE,
                          BAR_WIDTH, DISPLAY_HEIGHT * GRID_SIZE)
  local bar_color = BAR_DEFAULT_COLOR
  local total_garbage = self:totalGarbage()
  if total_garbage > BAR_URGENT_HEIGHT then
    bar_color = BAR_URGENT_COLOR
  elseif total_garbage > BAR_WARN_HEIGHT then
    bar_color = BAR_WARN_COLOR
  else
    bar_color = BAR_DEFAULT_COLOR
  end
  if total_garbage > 0 then
    love.graphics.setColor(bar_color)
    love.graphics.rectangle('fill',
                            self.fstartx + H_GRIDS * GRID_SIZE, self.fstarty - total_garbage * GRID_SIZE,
                            BAR_WIDTH, total_garbage * GRID_SIZE)
  end
  -- love.graphics.print(self:totalGarbage(), self.fstartx - 5  * GRID_SIZE, self.fstarty - 3 * GRID_SIZE)
end

function Field:destroy()
  self.class:remove(self)
  Field.super.destroy(self, dt)
end

function Field:addPiece(name, rot, x, y)
  for i = 1, NUM_PIECE_BLOCKS do
    local x2 = x + PIECE_XS[name][rot + 1][i]
    local y2 = y - PIECE_YS[name][rot + 1][i]
    self.board[y2][x2] = PIECE_IDS[name]
  end

  -- PC distance: pieces since last PC
  self.pc_distance = self.pc_distance + 1

  -- Trigger stat update for field cycle (addPiece called before field update)
  self.trigger_update = true
end

function Field:getBlock(x, y)
  if x < 1 or x > H_GRIDS or y < 1 or y > V_GRIDS + X_GRIDS then
    return GARBAGE_BLOCK_VALUE
  else
    return self.board[y][x]
  end
end

function Field:isEmpty()
  for i, row in ipairs(self.board) do
    if not table.empty(row) then
      return false
    end
  end
  return true
end

function Field:checkLines()
  local lines = 0
  for r = 1, V_GRIDS + X_GRIDS do
    if table.full(self.board[r]) then lines = lines + 1 end
  end
  return lines
end

function Field:clearLines()
  for r = 1, V_GRIDS + X_GRIDS do
    if table.full(self.board[r]) then
      self.board[r] = {}
      for i = 1, H_GRIDS do self.board[r][i] = 0 end
    end
  end
end

function Field:fallStack()
  for r = 1, V_GRIDS + X_GRIDS do
    if table.empty(self.board[r]) then
      while table.empty(self.board[r]) do
        local done = true
        for s = r, V_GRIDS + X_GRIDS - 1 do
          self.board[s] = table.copy(self.board[s + 1])
          if not table.empty(self.board[s]) then done = false end
        end

        if done then break end -- prevent infinite while loop

        -- top-most row should be all empty
        if self.debug_c4w then
          self.board[V_GRIDS + X_GRIDS] = table.scale({1, 1, 1, 0, 0, 0, 0, 1, 1, 1}, GARBAGE_BLOCK_VALUE)
        else
          self.board[V_GRIDS + X_GRIDS] = table.zeros(H_GRIDS)
        end
      end
    end
  end
end

function Field:totalGarbage()
  return fn.sum(self.incoming_garbage)
end

function Field:spawnGarbage()
  while not table.empty(self.incoming_garbage) do
    lines = fn.pop(self.incoming_garbage)
    for r = V_GRIDS + X_GRIDS, 2, -1 do
      self.board[r] = table.copy(self.board[r - lines])
    end
    local _single_garbage = table.scale(table.onezero(H_GRIDS), GARBAGE_BLOCK_VALUE)
    for r = 1, lines do
      self.board[r] = table.copy(_single_garbage)
    end
  end
end

function Field:counterGarbage(attack)
  while not table.empty(self.incoming_garbage) do
    if attack > self.incoming_garbage[1] then
      attack = attack - self.incoming_garbage[1]
      fn.pop(self.incoming_garbage)
    else
      self.incoming_garbage[1] = self.incoming_garbage[1] - attack
      attack = 0
      break
    end
  end
  return attack
end

function Field:recognizeB2b(lines)
  return lines == 4 or self.layout.piece.do_tspinmini or self.layout.piece.do_tspin
end

function Field:recognizePS(distance)
  -- PC Series: consecutive PCs with maximum pc distance of 15 (six-line PC)
  local distance = distance or self.pc_distance
  return distance < 16
end

function Field:calculateB2bBonus(input_b2b)
  -- similar to tetr.io garbage mechanics
  local b2b = input_b2b or self.b2b_count
  if b2b < 1 then return 0 end
  local b2b_bonus_coeff = DEFAULT_B2B_BONUS_COEFF
  local b2b_bonus_log = DEFAULT_B2B_BONUS_LOG
  return math.floor(b2b_bonus_coeff * (
    math.floor(1 + math.log(1 + (b2b - 1) * b2b_bonus_log)) +
    ((b2b - 1) == 1 and 0 or ((1 + math.log(1 + (b2b - 1) * b2b_bonus_log) % 1) / 3))
  ))
end

function Field:calculatePCBonus(lines, input_ps)
  local base_pc_bonus = (self:isEmpty() and PC_GARBAGE_BONUS or 0) + lines
  local ps = input_ps or self.ps_count
  if ps < 1 then return base_pc_bonus end
  local ps_bonus = math.floor(0.1 * math.exp(ps / 5)) -- TODO default config
  return ps_bonus + base_pc_bonus
end

function Field:calculateComboBonus(input_combo)
  local combo = input_combo or self.combo_count
  local _combo_table = {
    [1]  = 0,
    [2]  = 1,
    [3]  = 1,
    [4]  = 2,
    [5]  = 2,
    [6]  = 3,
    [7]  = 3,
    [8]  = 4,
    [9]  = 4,
    [10] = 4,
    [11] = 5,
  }
  if combo < 1 then
    return 0 -- no bonus for only two consecutive line clears
  elseif combo < 12 then
    return _combo_table[combo]
  else
    return _combo_table[#combo_table]
  end
end

function Field:calculateAttack(lines)
  -- Base attack
  local base_attack = BASE_GARBAGE_TABLE[lines] -- 1, 2, 3 or 4

  -- T-spin bonus
  if self.layout.piece.do_tspin and not self.layout.piece.do_tspinmini then
    base_attack = TSPIN_GARBAGE_TABLE[lines] -- can only be 1, 2, or 3
  end

  -- PC bonus (clear clear already executed)

  return base_attack + self:calculateComboBonus() + self:calculateB2bBonus() + self:calculatePCBonus(lines)
end

-- Debug --
function Field:debugTSpin()
  self.board[8] = table.scale({0,0,0,0,0,1,0,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[7] = table.scale({0,0,1,1,0,1,1,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[6] = table.scale({0,0,0,1,1,1,1,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[5] = table.scale({1,1,0,1,1,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[4] = table.scale({1,0,0,1,1,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[3] = table.scale({1,0,0,0,1,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[2] = table.scale({1,1,0,1,1,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[1] = table.scale({1,1,0,1,1,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
end

function Field:debugC4W()
  self.debug_c4w = true
  self.board[1] = table.scale({1, 1, 1, 1, 1, 1, 0, 1, 1, 1}, GARBAGE_BLOCK_VALUE)
  for i = 2, V_GRIDS + X_GRIDS do
    self.board[i] = table.scale({1, 1, 1, 0, 0, 0, 0, 1, 1, 1}, GARBAGE_BLOCK_VALUE)
  end
end

function Field:debugComplexTSpin()
  self.board[20] = table.scale({0,0,0,0,0,0,0,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[19] = table.scale({0,0,0,0,0,0,0,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[18] = table.scale({1,1,1,1,0,0,0,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[17] = table.scale({1,1,1,0,0,0,0,0,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[16] = table.scale({1,1,1,0,1,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[15] = table.scale({1,1,1,0,0,0,0,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[14] = table.scale({1,1,1,0,0,0,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[13] = table.scale({1,1,1,1,1,0,0,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[12] = table.scale({1,1,1,1,1,0,0,0,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[11] = table.scale({1,1,1,1,1,1,1,0,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[10] = table.scale({1,1,1,1,1,1,0,0,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 9] = table.scale({1,1,1,1,0,0,0,0,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 8] = table.scale({1,1,1,1,0,0,0,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 7] = table.scale({1,1,1,1,0,0,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 6] = table.scale({1,1,1,1,0,0,0,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 5] = table.scale({1,1,1,1,1,1,0,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 4] = table.scale({1,1,1,1,1,0,0,0,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 3] = table.scale({1,1,1,1,1,1,0,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 2] = table.scale({1,1,1,1,0,1,1,1,1,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 1] = table.scale({1,1,1,1,1,0,1,1,1,1}, GARBAGE_BLOCK_VALUE)
end

function Field:debugTSpinTower()
  self.board[20] = table.scale({1,1,1,0,0,0,0,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[19] = table.scale({1,1,1,1,1,1,1,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[18] = table.scale({0,0,0,0,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[17] = table.scale({0,0,0,0,0,0,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[16] = table.scale({0,0,0,1,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[15] = table.scale({0,0,1,0,0,1,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[14] = table.scale({1,0,0,0,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[13] = table.scale({1,0,0,0,0,1,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[12] = table.scale({0,0,0,1,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[11] = table.scale({0,1,0,0,0,1,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[10] = table.scale({0,0,0,0,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[ 9] = table.scale({0,0,1,0,0,1,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 8] = table.scale({1,0,0,0,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[ 7] = table.scale({0,0,0,1,0,1,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 6] = table.scale({1,1,0,0,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[ 5] = table.scale({0,0,0,0,1,1,0,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 4] = table.scale({0,0,0,0,0,0,0,1,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[ 3] = table.scale({1,0,1,1,0,0,1,0,0,1}, GARBAGE_BLOCK_VALUE)
  self.board[ 2] = table.scale({1,0,0,0,0,0,0,0,0,0}, GARBAGE_BLOCK_VALUE)
  self.board[ 1] = table.scale({0,0,0,0,0,0,0,0,0,0}, GARBAGE_BLOCK_VALUE)
end
