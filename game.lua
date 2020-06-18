Game = class('Game'):include(Stateful)

-- require after initialization of game
require 'states/session'
require 'states/pause'

function Game:initialize()
  -- Game Env
  self.timer = Timer:new()

  -- Default State
  self:gotoState('Session')
end

function Game:update(dt)
  if self.timer then self.timer:update(dt) end
end

function Game:draw()
end

function Game:destroy()
  self.timer:destroy()
  self.timer = nil
end
