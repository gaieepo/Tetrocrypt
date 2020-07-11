Hold = class('Hold')

function Hold:initialize(sx, sy)
  self.name = nil

  self.sx = sx + hold_sx_offset
  self.sy = sy + hold_sy_offset
end

function Hold:getBotName()
  if self.name == nil then return ' ' else return self.name end
end

function Hold:getPCFinderName()
  if self.name == nil then return 'E' else return self.name end
end

function Hold:draw()
  if self.name then
    for i = 1, num_piece_blocks do
      local x = piece_xs[self.name][1][i]
      local y = piece_ys[self.name][1][i]
      love.graphics.setColor(block_colors[self.name])
      love.graphics.rectangle('fill',
                              self.sx + x * grid_size, self.sy + y * grid_size,
                              grid_size, grid_size)
      love.graphics.setColor(grid_color)
      love.graphics.rectangle('line',
                              self.sx + x * grid_size, self.sy + y * grid_size,
                              grid_size, grid_size)
    end
  end
end
