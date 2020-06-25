local Each = require 'modules/Each'

Entity = class('Entity'):include(Each)

function Entity.static:drawAll()
  self:each('draw')
end

function Entity.static:updateAll(dt)
  self:safeEach('update', dt)
end

function Entity.static:destroyAll()
  self:safeEach('destroy')
end

------------------------------------

function Entity:initialize(state)
  -- local opts = opts or {}
  -- if opts then for k, v in pairs(opts) do self[k] = v end end

  self.state = state
  self.timer = Timer:new()
  self.id = UUID()
end

function Entity:update(dt)
  if self.timer then self.timer:update(dt) end
end

function Entity:draw()
end

function Entity:destroy()
  self.timer:destroy()
  self.timer = nil
end
