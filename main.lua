-- Debug
Inspect = require 'libraries/inspect/inspect'

Input = require 'libraries/boipushy/Input'
Timer = require 'modules/TimerEx'
Class = require 'libraries/middleclass/middleclass'

require 'Entity'
require 'field'
require 'piece'
require 'globals'

function love.load()
  -- Env

  -- Game Entities
  field = Field:new(startx, starty)
  -- field:debugGarbage()
  piece = Piece:new(field, 'T', spawnx, spawny, default_rot)

  -- Input
  input = Input()
  input:bind('escape', function()
    love.event.quit()
  end)

  -- input:bind('w', function()
  --   if not piece:collide(nil, piece.y + 1, nil, nil) then
  --     piece.y = piece.y + 1
  --   end
  -- end)
  input:bind('a', function()
    if not piece:collide(piece.x - 1, nil, nil, nil) then
      piece.x = piece.x - 1
    end
  end)
  input:bind('s', function()
    if not piece:collide(nil, piece.y - 1, nil, nil) then
      piece.y = piece.y - 1
    end
  end)
  input:bind('d', function()
    if not piece:collide(piece.x + 1, nil, nil, nil) then
      piece.x = piece.x + 1
    end
  end)

  for i=1, #pieces do
    input:bind(tostring(i), function()
      piece.id = pieces[i]
      piece.rot = 0
    end)
  end

  input:bind('k', function()
    piece:rotateRight()
  end)
  input:bind('m', function()
    piece:rotateLeft()
  end)
  input:bind('l', function()
    piece:rotate180()
  end)
end

function love.update(dt)
  -- Timer.update(dt) -- global timer
  field:update(dt)
  piece:update(dt)
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
  -- love.keyboard.setKeyRepeat(false)
  -- if key == 'k' then
  --   piece:rotateRight()
  -- elseif key == 'm' then
  --   piece:rotateLeft()
  -- elseif key == 'l' then
  --   piece:rotate180()
  -- elseif tonumber(key) ~= nil and tonumber(key) >= 1 and tonumber(key) <= 7 and piece.id ~= pieces[tonumber(key)] then
  --   piece.id = pieces[tonumber(key)]
  --   piece.rot = 0
  -- end
end

function love.run()
  -- Random
  -- if love.math then love.math.setRandomSeed(os.time()) end

  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  if love.timer then love.timer.step() end

  local dt = 0
  -- local fixed_dt = 1/60
  -- local accumulator = 0

  -- Main loop time.
  return function()
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == 'quit' then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Update dt, as we'll be passing it to update
    if love.timer then dt = love.timer.step() end

    -- Call update and draw
    -- accumulator = accumulator + dt
    -- while accumulator >= fixed_dt do
    --     if love.update then love.update(fixed_dt) end
    --     accumulator = accumulator - fixed_dt
    -- end
    if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      if love.draw then love.draw() end
      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.001) end
  end
end
