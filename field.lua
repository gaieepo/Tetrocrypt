Field = class('Field')

function Field:initialize(sx, sy)
  self.sx, self.sy = sx, sy
  self.board = {}
  for row = 1, 20 do
    self.board[row] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  end
end

function Field:draw()
  for i, row in ipairs(self.board) do
    for j, col in ipairs(row) do
      love.graphics.setColor(block_colors['E'])
      love.graphics.rectangle('fill',
                              self.sx + (j - 1) * grid_size, self.sy + (i - 1) * grid_size,
                              grid_size, grid_size)
      love.graphics.setColor(grid_color)
      love.graphics.rectangle('line',
                              self.sx + (j - 1) * grid_size, self.sy + (i - 1) * grid_size,
                              grid_size, grid_size)
    end
  end
end
