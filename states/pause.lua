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
  love.graphics.setBackgroundColor(100/255, 100/255, 100/255)
  love.graphics.setColor(1, 1, 1)
  local pause_text = 'Game Pause'
  love.graphics.print(pause_text,
                      gw / 2, gh / 2,
                      0, 1, 1,
                      global_font:getWidth(pause_text) / 2, global_font:getHeight(pause_text) / 2)
end
