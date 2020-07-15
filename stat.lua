Stat = class('Stat', Entity)

local garbage_table = {
  ['single'] = 0,
  ['double'] = 1,
  ['triple'] = 2,
  ['tetris'] = 4,
  ['tspin single'] = 2,
  ['tspin double'] = 4,
  ['tspin triple'] = 6,
}

local combo_table = {
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

local clear_table = {'single', 'double', 'triple', 'tetris'}

function Stat:initialize(state)
  self.state = state
  self.pieces = 0
  self.pps = 0
  self.lines = 0
  self.status = ''

  self.combo_counter = -1
  self.total_attack = 0
  self.current_attack = 0

  self.tspin = false
  self.tspinmini = false

  self.prev_back = false
  self.b2b = false
end

function Stat:update(dt)
end

function Stat:draw()
  local sy_offset = stat_sy_offset
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Statistics    ', stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Pieces:       ' .. self.pieces, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('PPS:          ' .. string.format('%.1f', self.pieces / self.state.session_duration), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Lines:        ' .. self.lines, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('LPM:          ' .. string.format('%.1f', 60 * self.lines / self.state.session_duration), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('APM:          ' .. string.format('%.1f', 60 * self.total_attack / self.state.session_duration), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Combo:        ' .. self.combo_counter, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Curr Atack:   ' .. self.current_attack, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Total Atack:  ' .. self.total_attack, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Lock Delay:   ' .. string.format('%.1f', piece.lock_delay), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('F Lock Delay: ' .. string.format('%.1f', piece.force_lock_delay), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Last Move:    ' .. piece.last_valid_move, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Tspin:        ' .. tostring(self.tspin), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Tspin Mini:   ' .. tostring(self.tspinmini), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('B2B:          ' .. tostring(self.b2b), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Status:       ' .. self.status, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
end

function Stat:updateStatus(lines)
  if lines == 0 then
    self.combo_counter = -1 -- reset to -1 since first combo does not send garbage
  else
    self.combo_counter = self.combo_counter + 1
    self.lines = self.lines + lines
    self.status = clear_table[lines]

    if self.tspin then
      self.status = 'tspin ' .. self.status
    end

    if (lines == 4 or self.tspin) and self.prev_back then self.b2b = true else self.b2b = false end
    if lines == 4 or self.tspin then self.prev_back = true else self.prev_back = false end

    self.current_attack = garbage_table[self.status] + self:getComboAttack() + (self.b2b and 1 or 0)
    self.total_attack = self.total_attack + self.current_attack
  end

  -- (Temporary) 40L Sprint
  -- if self.lines >= 40 then
  --   print(self.state.session_duration)
  -- end
end

function Stat:getComboAttack()
  if self.combo_counter < 1 then
    return 0
  elseif self.combo_counter < 12 then
    return combo_table[self.combo_counter]
  else
    return combo_table[#combo_table]
  end
end
