Field = class('Field', Entity)

function Field:initialize(state, sx, sy)
  Field.super.initialize(self, state)

  -- Field Env
  self.trigger_update = false
  self.clearing = false
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

function Field:__tostring()
  local _field = ''
  local colbreak = ','
  local rowbreak = '|'
  local rowprefix = ''
  for i = v_grids, 1, -1 do
    local row = ''
    local colprefix = ''
    for j = 1, #self.board[i] do
      row = row .. colprefix .. (self.board[i][#self.board[i] - j + 1] == 0 and 0 or 2)
      colprefix = colbreak
    end
    _field = _field .. rowprefix .. row
    rowprefix = rowbreak
  end
  return _field
end

function Field:update(dt)
  Field.super.update(self, dt) -- update timer

  local lines = self:checkLines()
  if self.trigger_update then
    stat:updateStatus(lines)
    self.trigger_update = false
  end
  if lines > 0 then
    self.clearing = true
    self:clearLines()
    self.timer:after(line_clear_delay * frame_time, function()
      self:fallStack()
      self.clearing = false
    end)
  end
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
          love.graphics.setColor(fn.mapi(block_colors[piece_names[self.board[i][j]]], function(v) return v * 0.8 end))
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

function Field:addPiece(name, rot, x, y)
  for i = 1, num_piece_blocks do
    local x2 = x + piece_xs[name][rot + 1][i]
    local y2 = y - piece_ys[name][rot + 1][i]
    self.board[y2][x2] = piece_ids[name]
  end

  -- Trigger stat update
  self.trigger_update = true
end

function Field:getBlock(x, y)
  if x < 1 or x > h_grids or y < 1 or y > v_grids + x_grids then
    return garbage_block_value
  else
    return self.board[y][x]
  end
end

function Field:checkLines()
  local lines = 0
  for r = 1, v_grids + x_grids do
    if table.full(self.board[r]) then lines = lines + 1 end
  end
  return lines
end

function Field:clearLines()
  for r = 1, v_grids + x_grids do
    if table.full(self.board[r]) then
      self.board[r] = {}
      for i = 1, h_grids do self.board[r][i] = 0 end
    end
  end
end

function Field:fallStack()
  for r = 1, v_grids + x_grids do
    if table.empty(self.board[r]) then
      while table.empty(self.board[r]) do
        local done = true
        for s = r, v_grids + x_grids - 1 do
          self.board[s] = table.copy(self.board[s + 1])
          if not table.empty(self.board[s]) then done = false end
        end

        if done then break end -- prevent infinite while loop

        -- top-most row should be all empty
        self.board[v_grids + x_grids] = table.zeros(h_grids)
      end
    end
  end
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

function Field:debugC4W()
  local g = function(v) return v * garbage_block_value end
  self.board[1] = fn.mapi({1, 1, 1, 1, 1, 1, 0, 1, 1, 1}, g)
  for i = 2, v_grids + x_grids do
    self.board[i] = fn.mapi({1, 1, 1, 0, 0, 0, 0, 1, 1, 1}, g)
  end
end

function Field:debugComplexTSpin()
  local g = function(v) return v * garbage_block_value end
  self.board[10] = fn.mapi({0,0,0,0,0,0,0,0,0,0}, g)
  self.board[19] = fn.mapi({0,0,0,0,0,0,0,0,0,0}, g)
  self.board[18] = fn.mapi({1,1,1,1,0,0,0,0,0,0}, g)
  self.board[17] = fn.mapi({1,1,1,0,0,0,0,0,1,1}, g)
  self.board[16] = fn.mapi({1,1,1,0,1,1,1,1,1,1}, g)
  self.board[15] = fn.mapi({1,1,1,0,0,0,0,1,1,1}, g)
  self.board[14] = fn.mapi({1,1,1,0,0,0,1,1,1,1}, g)
  self.board[13] = fn.mapi({1,1,1,1,1,0,0,1,1,1}, g)
  self.board[11] = fn.mapi({1,1,1,1,1,0,0,0,1,1}, g)
  self.board[11] = fn.mapi({1,1,1,1,1,1,1,0,1,1}, g)
  self.board[10] = fn.mapi({1,1,1,1,1,1,0,0,1,1}, g)
  self.board[9] = fn.mapi({1,1,1,1,0,0,0,0,1,1}, g)
  self.board[8] = fn.mapi({1,1,1,1,0,0,0,1,1,1}, g)
  self.board[7] = fn.mapi({1,1,1,1,0,0,1,1,1,1}, g)
  self.board[6] = fn.mapi({1,1,1,1,0,0,0,1,1,1}, g)
  self.board[5] = fn.mapi({1,1,1,1,1,1,0,1,1,1}, g)
  self.board[4] = fn.mapi({1,1,1,1,1,0,0,0,1,1}, g)
  self.board[3] = fn.mapi({1,1,1,1,1,1,0,1,1,1}, g)
  self.board[1] = fn.mapi({1,1,1,1,0,1,1,1,1,1}, g)
  self.board[1] = fn.mapi({1,1,1,1,1,0,1,1,1,1}, g)
end
