local Session = Game:addState('Session')

function Session:enteredState()
  -- Session Env
  self.start_time = love.timer.getTime()
  self.session_duration = 0 -- (second)
  self.session_state = GAME_COUNTDOWN
  self.counting_down_text = nil
  self.startx, self.starty = startx, starty

  -- Session State Input Handler
  input:bind('escape', 'pause')
  input:bind('backspace', 'restart')

  input:bind('w', 'harddrop')
  input:bind('a', 'move_left')
  input:bind('s', 'softdrop')
  input:bind('d', 'move_right')
  input:bind('k', 'piece_rotate_right')
  input:bind('m', 'piece_rotate_left')
  input:bind('l', 'piece_rotate_180')
  input:bind('q', 'hold')

  -- Game Entities
  hold = Hold:new(self.startx, self.starty)
  preview = Preview:new(self.startx, self.starty)
  stat = Stat:new(self)

  field = Field:new(self)
  piece = Piece:new(self, field, piece_names[preview:next()])
end

function Session:update(dt)
  -- Update timer in state
  self.timer:update(dt)

  -- Session Env
  -- Count down
  if self.session_state == GAME_COUNTDOWN and self.counting_down_text == nil then
    self.timer:after(1, function() self.session_state = GAME_NORMAL end)
    self.timer:during(0.5, function() self.counting_down_text = 'READY' end, function()
      self.timer:during(0.5, function() self.counting_down_text = 'GO' end, function()
        self.counting_down_text = nil
      end)
    end)
  end

  if self.session_state == GAME_NORMAL then self.session_duration = love.timer.getTime() - self.start_time end

  -- Switch State
  if input:pressed('pause') then self:pushState('Pause') end
  if input:pressed('restart') then self:gotoState('Session') end
  if self.session_state == GAME_LOSS then self:finish() end

  -- Entity Update
  if self.session_state == GAME_NORMAL then
    field:update(dt)

    if not field.clearing then
      piece:update(dt)
    end
  end
end

function Session:draw()
  love.graphics.setBackgroundColor(session_background_color)

  -- Session Draw
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
  love.graphics.print('Time: ' .. human_time(self.session_duration), 0, gh - default_font_size)

  -- Entity Draw
  hold:draw()
  preview:draw()
  field:draw()
  piece:draw()
  stat:draw()

  -- Dead
  if self.session_state == GAME_LOSS then
    love.graphics.setColor(1, 0, 0)
    local gg_text = 'Game Over'
    love.graphics.print(gg_text,
                        gw / 2, gh / 2,
                        0, 1, 1,
                        global_font:getWidth(gg_text) / 2, global_font:getHeight(gg_text) / 2)
  end

  -- Count down
  if self.counting_down_text ~= nil then
    local temp_font = love.graphics.newFont(default_font, 50)
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(temp_font)
    love.graphics.print(self.counting_down_text,
                        field.sx + h_grids * grid_size / 2, field.sy - v_grids * grid_size / 2,
                        0, 1, 1,
                        temp_font:getWidth(self.counting_down_text) / 2, temp_font:getHeight(self.counting_down_text) / 2)
    love.graphics.setFont(global_font)
  end
end

function Session:finish()
  -- Finishing content
end
