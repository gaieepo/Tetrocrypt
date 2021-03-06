-- Window constant
GW = 1000
GH = 600
SCALEX = 1 -- not used
SCALEY = 1 -- not used

function love.conf(t)
  t.identity = nil  -- the name of the save directory (string)
  t.version = '11.3' -- Love2D version this game was made for (string)
  t.console = false -- attach a console (boolean, Windows only)

  t.window.title = 'Tetrocrypt'
  t.window.icon = nil
  t.window.width = GW
  t.window.height = GH
  t.window.resizable = false
  t.window.borderless = false
  t.window.vsync = false -- enable vertical sync (boolean)
  t.window.highdpi = true
  t.window.x = nil  -- The x-coordinate of the window's position in the specified display (number)
  t.window.y = nil  -- The y-coordinate of the window's position in the specified display (number)

  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = true
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = true
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true  -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
  t.modules.window = true
  t.modules.thread = true
end
