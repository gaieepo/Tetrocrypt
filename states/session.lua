local Session = Game:addState('Session')

function Session:enteredState()
  -- Session Env
  self.start_time = love.timer.getTime()
  self.session_duration = 0
  self.dead = false
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
  hold = Hold:new(self)
  preview = Preview:new(self)
  stat = Stat:new(self)
  field = Field:new(self)
  piece = Piece:new(self, field, piece_names[preview:next()])
end

function Session:update(dt)
  -- Session
  if not self.dead then self.session_duration = love.timer.getTime() - self.start_time end

  -- Switch State
  if input:pressed('pause') then self:pushState('Pause') end
  if input:pressed('restart') then self:gotoState('Session') end
  if self.dead then self:finish() end

  -- Entity Update
  if not self.dead then
    field:update(dt)
    piece:update(dt)
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
  if self.dead then
    love.graphics.setColor(1, 0, 0)
    local gg_text = 'Game Over'
    love.graphics.print(gg_text,
                        gw / 2, gh / 2,
                        0, 1, 1,
                        global_font:getWidth(gg_text) / 2, global_font:getHeight(gg_text) / 2)
  end
end

function Session:finish()
  -- Finishing content
end
