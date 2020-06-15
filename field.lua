Field = class('Field', Entity)

function Field:initialize(state, sx, sy)
  Field.super.initialize(self, state)

  self.sx = self.state.startx + field_sx_offset
  self.sy = self.state.starty + field_sy_offset
  self.board = {}
  for r = 1, v_grids + x_grids do
    local row = {}
    for c = 1, h_grids do
      row[c] = 0
    end
    self.board[r] = row
  end

  -- Debug
end

function Field:update(dt)
  Field.super.update(self, dt) -- update timer

  self:clearLines()
end

function Field:draw()
  -- Grid
  for i, row in ipairs(self.board) do
    if i <= display_height then
      for j, col in ipairs(row) do
        if self.board[i][j] == 0 then
          love.graphics.setColor(block_colors['E'])
        elseif self.board[i][j] == garbage_block_value then
          love.graphics.setColor(block_colors['B'])
        else
          love.graphics.setColor(block_colors[piece_names[self.board[i][j]]])
        end
        love.graphics.rectangle('fill',
                                self.sx + (j - 1) * grid_size, self.sy - i * grid_size,
                                grid_size, grid_size)
        love.graphics.setColor(grid_color)
        love.graphics.rectangle('line',
                                self.sx + (j - 1) * grid_size, self.sy - i * grid_size,
                                grid_size, grid_size)
      end
    end
  end

  -- Hidden break line
  love.graphics.setColor(1, 0, 0)
  love.graphics.line(self.sx, self.sy - v_grids * grid_size,
                     self.sx + h_grids * grid_size, self.sy - v_grids * grid_size)
end

function Field:destroy()
  Field.super.destroy(self, dt)
end

function Field:clearLines()
  local lines = 0
  local r2 = 1
  for r = 1, v_grids + x_grids do
    local full = true
    for c = 1, h_grids do
      if self.board[r][c] == empty_block_value then
        full = false
        break
      end
    end

    if full then
      lines = lines + 1
    else
      self.board[r2] = self.board[r]
      r2 = r2 + 1
    end
  end
  return lines
end

-- Debug --
function Field:debugGarbage(height)
  local height = height or 5
  for r = 1, height do
    for c = 1, h_grids do
      self.board[r][c] = love.math.random() < 0.3 and garbage_block_value or empty_block_value
    end
  end
end

function Field:debugTSpin()
  local g = function(v) return v * garbage_block_value end
  self.board[1] = fn.mapi({1, 1, 0, 1, 1, 1, 1, 1, 1, 1}, g)
  self.board[2] = fn.mapi({1, 1, 0, 1, 1, 1, 1, 1, 1, 1}, g)
  self.board[3] = fn.mapi({1, 0, 0, 0, 1, 1, 1, 1, 1, 1}, g)
  self.board[4] = fn.mapi({1, 0, 0, 1, 1, 1, 1, 1, 1, 1}, g)
  self.board[5] = fn.mapi({1, 1, 0, 1, 1, 1, 1, 1, 1, 1}, g)
  self.board[6] = fn.mapi({0, 0, 0, 1, 1, 1, 1, 0, 0, 1}, g)
  self.board[7] = fn.mapi({0, 0, 1, 1, 0, 1, 1, 0, 0, 0}, g)
  self.board[8] = fn.mapi({0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, g)
end
