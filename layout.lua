local Each = require 'modules/Each'

Layout = class('Layout'):include(Each)

function Layout.static:drawAll()
  self:each('draw')
end

function Layout.static:updateAll(dt)
  self:safeEach('update', dt) -- update timer
end

function Layout.static:destroyAll()
  self:safeEach('destroy')
end

------------------------------------

function Layout:initialize(state, lidx, lsx, lsy)
  -- State reference
  self.state = state
  self.is_human = (lidx == human_index) -- (TODO) use unique identifier
  self.lstartx, self.lstarty = lsx, lsy

  self.hold = Hold:new(self.lstartx, self.lstarty)
  self.preview = Preview:new(self.lstartx, self.lstarty)
  self.stat = Stat:new(state)
  self.field = Field:new(self.stat, self.lstartx, self.lstarty)
  self.piece = Piece:new(state, self.is_human, self.hold, self.preview, self.stat, self.field, piece_names[self.preview:next()])

  self.class:add(self)
end

function Layout:update(dt)
  -- Entity Update
  if not self.state.pause then
    if self.state.session_state == GAME_NORMAL then
      self.field:update(dt)

      if not self.field.clearing then
        self.piece:update(dt)
      end
    end
  end
end

function Layout:draw()
  self.hold:draw()
  self.preview:draw()
  self.field:draw()
  self.piece:draw()
  if game_mode == 'analysis' then
    self.stat:draw()
  end
end

function Layout:destroy()
  self.class:remove(self)
  self.hold:destroy()
  self.preview:destroy()
  self.stat:destroy()
  self.field:destroy()
  self.piece:destroy()
end
