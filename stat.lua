Stat = class('Stat')

function Stat:initialize(state)
  self.state = state
  self.pieces = 0
  self.pps = 0
  self.lines = 0
end

function Stat:update(dt)
end

function Stat:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Statistics', stat_sx_offset, stat_sy_offset)
  love.graphics.print('Pieces:   ' .. self.pieces, stat_sx_offset, stat_sy_offset + 30)
  love.graphics.print('PPS:      ' .. string.format('%.1f', self.pieces / self.state.session_duration), stat_sx_offset, stat_sy_offset + 60)
  love.graphics.print('Lines:    ' .. self.lines, stat_sx_offset, stat_sy_offset + 90)
  love.graphics.print('LPM:      ' .. string.format('%.1f', 60 * self.lines / self.state.session_duration), stat_sx_offset, stat_sy_offset + 120)
end

function Stat:calculateAttack()
end
