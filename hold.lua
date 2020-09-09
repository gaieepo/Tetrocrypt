Hold = class('Hold')

function Hold:initialize(hsx, hsy)
  self.name = nil

  self.hstartx = hsx + HOLD_SX_OFFSET
  self.hstarty = hsy + HOLD_SY_OFFSET
end

function Hold:getBotName()
  if self.name == nil then return ' ' else return self.name end
end

function Hold:getPCFinderName()
  if self.name == nil then return 'E' else return self.name end
end

function Hold:update(dt)
end

function Hold:draw()
  if self.name then
    for i = 1, NUM_PIECE_BLOCKS do
      local x = PIECE_XS[self.name][1][i]
      local y = PIECE_YS[self.name][1][i]
      love.graphics.setColor(BLOCK_COLORS[self.name])
      love.graphics.rectangle('fill',
                              self.hstartx + x * GRID_SIZE, self.hstarty + y * GRID_SIZE,
                              GRID_SIZE, GRID_SIZE)
      love.graphics.setColor(GRID_COLOR)
      love.graphics.rectangle('line',
                              self.hstartx + x * GRID_SIZE, self.hstarty + y * GRID_SIZE,
                              GRID_SIZE, GRID_SIZE)
    end
  end
end

function Hold:destroy()
end
