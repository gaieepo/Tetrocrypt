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
  self.stat = Stat:new(state, self)
  self.field = Field:new(self, self.lstartx, self.lstarty)
  self.piece = Piece:new(state, self, piece_names[self.preview:next()])

  -- add to layout collections
  self.class:add(self)
end

function Layout:update(dt)
  -- Entity Update
  if not self.state.paused then
    if self.state.session_state == GAME_NORMAL then
      if not self.field.clearing then
        self.piece:update(dt)
      end

      -- May involve post add piece triggered update
      self.field:update(dt)
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
