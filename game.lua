Game = class('Game'):include(Stateful)

-- require after initialization of game
require 'states/session'
require 'states/pause'

function Game:initialize()
  -- Game Env

  -- Default State
  self:gotoState('Session')
end

function Game:update(dt)
end

function Game:draw()
end
