class = require 'libraries/middleclass/middleclass'

require 'field'
require 'piece'
require 'globals'

function love.load()
  field = Field:new(startx, starty)
  piece = Piece:new(field, 'T', 4, 5, 0)

  love.keyboard.setKeyRepeat(false)
end

function love.update(dt)
end

function love.draw()
  love.graphics.setBackgroundColor(background_color)
  love.graphics.setColor(grid_color)

  -- Field
  field:draw()

  -- Piece
  piece:draw()
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'k' then
    piece:rotateRight()
  elseif key == 'm' then
    piece:rotateLeft()
  elseif key == 'l' then
    piece:rotate180()
  elseif tonumber(key) ~= nil and tonumber(key) >= 1 and tonumber(key) <= 7 and piece.id ~= pieces[tonumber(key)] then
    piece.id = pieces[tonumber(key)]
    piece.rot = 0
  end
end
