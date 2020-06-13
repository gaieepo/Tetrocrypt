Piece = class('Piece')

function Piece:initialize(field, id, x, y, rot)
  -- local opts = opts or {}
  -- if opts then for k, v in pairs(opts) do self[k] = v end end
  self.field = field
  self.id, self.x, self.y, self.rot = id, x, y, rot
end

function Piece:update(dt)
end

function Piece:draw()
  -- rot 0, 1, 2, 3
  for i = 1, 4 do
    local x = piece_xs[self.id][self.rot + 1][i]
    local y = piece_ys[self.id][self.rot + 1][i]
    love.graphics.setColor(block_colors[self.id])
    love.graphics.rectangle('fill',
                            self.field.sx + (self.x + x - 1) * grid_size, self.field.sy + (self.y + y - 1) * grid_size,
                            grid_size, grid_size)
    love.graphics.setColor(grid_color)
    love.graphics.rectangle('line',
                            self.field.sx + (self.x + x - 1) * grid_size, self.field.sy + (self.y + y - 1) * grid_size,
                            grid_size, grid_size)
  end
end

function Piece:rotateRight()
  self.rot = (self.rot + 1) % 4
end

function Piece:rotateLeft()
  self.rot = (self.rot + 4 - 1) % 4
end

function Piece:rotate180()
  self.rot = (self.rot + 4 - 2) % 4
end
