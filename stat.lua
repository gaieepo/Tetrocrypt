Stat = class('Stat')

function Stat:initialize(state, layout)
  -- Context reference
  self.state = state
  self.layout = layout
end

function Stat:update(dt)
end

function Stat:draw()
  local sy_offset = STAT_SY_OFFSET
  local stat_font = love.graphics.newFont(DEFAULT_FONT, STAT_FONT_SIZE)
  local linespace = STAT_FONT_SIZE + 2
  love.graphics.setFont(stat_font)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Statistics    ', STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Pieces:       ' .. self.layout.piece.piece_count, STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('PPS:          ' .. string.format('%.1f', self.layout.piece.piece_count / self.state.session_duration), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Tspin:        ' .. tostring(self.layout.piece.do_tspin), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Tspin Mini:   ' .. tostring(self.layout.piece.do_tspinmini), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Lock Delay:   ' .. string.format('%.1f', self.layout.piece.lock_delay), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('F Lock Delay: ' .. string.format('%.1f', self.layout.piece.force_lock_delay), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Last Move:    ' .. self.layout.piece.last_valid_move, STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('-----------------------', STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Lines:        ' .. self.layout.field.total_lines, STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('LPM:          ' .. string.format('%.1f', 60 * self.layout.field.total_lines / self.state.session_duration), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Combo:        ' .. self.layout.field.combo_count, STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('B2B:          ' .. tostring(self.layout.field.b2b_count), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('PS:           ' .. tostring(self.layout.field.ps_count), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Curr Attack:  ' .. self.layout.field.current_attack, STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Total Attack: ' .. self.layout.field.total_attack, STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('APM:          ' .. string.format('%.1f', 60 * self.layout.field.total_attack / self.state.session_duration), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('-----------------------', STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('Bot play:     ' .. tostring(self.state.bot_play), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.print('PC play:      ' .. tostring(self.state.pcfinder_play), STAT_SX_OFFSET, sy_offset); sy_offset = sy_offset + linespace
  love.graphics.setFont(global_font)
end

function Stat:destroy()
end
