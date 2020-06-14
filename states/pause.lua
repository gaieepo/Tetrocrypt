local Pause = Game:addState('Pause')

function Pause:enteredState()
  -- Pause State Input Handler
  input:bind('escape', 'unpause')
end

function Pause:update(dt)
  if input:pressed('unpause') then
    self:popState('Pause')
  end
end

function Pause:draw()
  love.graphics.setBackgroundColor(pause_background_color)
  love.graphics.setColor(1, 0, 0, 255)
  love.graphics.printf('Game Paused', gw / 2, gh / 2, 100, 'center')
end
