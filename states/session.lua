local Session = Game:addState('Session')

function Session:enteredState()
  -- Session Env
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
  -- Switch State
  if input:pressed('pause') then self:pushState('Pause') end
  if input:pressed('restart') then self:finish() end

  -- Entity Update
  field:update(dt)
  piece:update(dt)
end

function Session:draw()
  love.graphics.setBackgroundColor(session_background_color)

  -- Session Draw
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 0, 0)

  -- Entity Draw
  hold:draw()
  preview:draw()
  field:draw()
  piece:draw()
  stat:draw()

  -- Preview sequence draw
end

function Session:finish()
  self:gotoState('Session')
end
