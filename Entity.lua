Entity = class('Entity')

function Entity:initialize()
  local opts = opts or {}
  if opts then for k, v in pairs(opts) do self[k] = v end end

  self.timer = Timer()
end

function Entity:update(dt)
  if self.timer then self.timer:update(dt) end
end

function Entity:draw()
end

function Entity:destroy()
  self.timer:destroy()
end
