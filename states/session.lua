local Session = Game:addState('Session')

function Session:enteredState()
  -- Session Env

  -- Session State Input Handler
  input:bind('escape', 'pause')
  input:bind('backspace', function()
    field = Field:new(startx, starty)
    piece = Piece:new(field, 'T', spawnx, spawny, default_rot)
  end)

  input:bind('w', 'harddrop')
  input:bind('a', 'move_left')
  input:bind('s', 'softdrop')
  input:bind('d', 'move_right')
  input:bind('k', 'piece_rotate_right')
  input:bind('m', 'piece_rotate_left')
  input:bind('l', 'piece_rotate_180')
  for i=1, #piece_ids do input:bind(tostring(i), 'debug_switch_piece_' .. i) end

  -- Game Entities
  field = Field:new(startx, starty)
  piece = Piece:new(field, 'T', spawnx, spawny, default_rot)
end

function Session:update(dt)
  -- Switch State
  if input:pressed('pause') then
    self:pushState('Pause')
  end

  -- Entity Update
  field:update(dt)
  piece:update(dt)
end

function Session:draw()
  love.graphics.setBackgroundColor(session_background_color)

  -- Entity Draw
  field:draw()
  piece:draw()
end
