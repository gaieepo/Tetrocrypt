Stat = class('Stat')

function Stat:initialize(state, layout)
  -- Context reference
  self.state = state
  self.layout = layout
end

function Stat:update(dt)
end

function Stat:draw()
  local sy_offset = stat_sy_offset
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Statistics    ', stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Pieces:       ' .. self.layout.piece.piece_count, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('PPS:          ' .. string.format('%.1f', self.layout.piece.piece_count / self.state.session_duration), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Tspin:        ' .. tostring(self.layout.piece.do_tspin), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Tspin Mini:   ' .. tostring(self.layout.piece.do_tspinmini), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Lock Delay:   ' .. string.format('%.1f', self.layout.piece.lock_delay), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('F Lock Delay: ' .. string.format('%.1f', self.layout.piece.force_lock_delay), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Last Move:    ' .. self.layout.piece.last_valid_move, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('-----------------------', stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Lines:        ' .. self.layout.field.total_lines, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('LPM:          ' .. string.format('%.1f', 60 * self.layout.field.total_lines / self.state.session_duration), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Combo:        ' .. self.layout.field.combo_count, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('B2B:          ' .. tostring(self.layout.field.b2b_count), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('PS:           ' .. tostring(self.layout.field.ps_count), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Curr Attack:  ' .. self.layout.field.current_attack, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('Total Attack: ' .. self.layout.field.total_attack, stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
  love.graphics.print('APM:          ' .. string.format('%.1f', 60 * self.layout.field.total_attack / self.state.session_duration), stat_sx_offset, sy_offset); sy_offset = sy_offset + 30
end

function Stat:destroy()
end
