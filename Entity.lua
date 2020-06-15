Entity = class('Entity')

function Entity:initialize(state)
  local opts = opts or {}
  if opts then for k, v in pairs(opts) do self[k] = v end end

  self.state = state
  self.timer = Timer()
  self.id = UUID()
end

function Entity:update(dt)
  if self.timer then self.timer:update(dt) end
end

function Entity:draw()
end

function Entity:destroy()
  self.timer:destroy()
end