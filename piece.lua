Piece = Class('Piece', Entity)

function Piece:initialize(field, id, x, y, rot)
  Piece.super:initialize(self)

  self.field = field
  self.id, self.x, self.y, self.rot = id, x, y, rot

  self.timer:every(1, function()
    if not self:collide(self.x, self.y - 1, self.rot, self.field) then
      self.y = self.y - 1
      -- self.timer:tween(0.5, self, {y = self.y - 1}, 'in-out-expo') -- non-blocking animation
    end
  end)
end

function Piece:update(dt)
  Piece.super.update(self, dt)
end

function Piece:draw()
  -- rot 0, 1, 2, 3
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

    if x2 > h_grids or y2 < 1 then
      return true
    end

    if field.board[y2][x2] ~= 0 then
      return true
    end
  end

  return false
end

-- Movement --
function Piece:rotateRight()
  self.rot = (self.rot + 1) % 4
end

function Piece:rotateLeft()
  self.rot = (self.rot + 4 - 1) % 4
end

function Piece:rotate180()
  self.rot = (self.rot + 4 - 2) % 4
end
