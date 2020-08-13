local Session = Game:addState('Session')

function Session:enteredState()
  -- Session Env
  self.paused = false
  self.bot_play = bot_play
  self.pcfinder_play = pcfinder_play
  self.previous_start_time = love.timer.getTime()
  self.session_past_duration = 0
  self.session_duration = 0 -- (second)
  self.session_state = GAME_COUNTDOWN
  self.counting_down_text = nil
  self.sstartx, self.sstarty = session_startx, session_starty

  -- Session State Input Handler
  input:bind('escape', 'pause')
  input:bind('backspace', 'restart')
  input:bind('p', 'debug')

  -- if not self.bot_play then
  -- Always bind, just react differently
  input:bind('w', 'harddrop')
  input:bind('a', 'move_left')
  input:bind('s', 'softdrop')
  input:bind('d', 'move_right')
  input:bind('l', 'piece_rotate_right')
  input:bind(',', 'piece_rotate_left')
  input:bind(';', 'piece_rotate_180')
  input:bind('q', 'hold')

  -- Game Layouts
  if game_mode == 'match' then
    l1 = Layout:new(self, human_index, self.sstartx, self.sstarty)
    l2 = Layout:new(self, human_index + 1, self.sstartx + 500, self.sstarty)
  elseif game_mode == 'analysis' then
    layout = Layout:new(self, human_index, self.sstartx, self.sstarty)
  end
end

function Session:update(dt)
  -- Update timer in state
  self.timer:update(dt)

  -- Session Env
  -- Count down
  if self.session_state == GAME_COUNTDOWN and self.counting_down_text == nil then
    self.timer:after(1, function() self.session_state = GAME_NORMAL end)
    self.timer:during(0.5, function() self.counting_down_text = 'READY' end, function()
      self.timer:during(0.5, function() self.counting_down_text = 'GO' end, function()
        self.counting_down_text = nil
      end)
    end)
  end

  -- if self.session_state == GAME_NORMAL then
  --   self.session_duration = love.timer.getTime() - self.previous_start_time
  -- end
  if self.paused then
    self.session_duration = self.session_past_duration
  else
    self.session_duration = self.session_past_duration + love.timer.getTime() - self.previous_start_time
  end

  -- Switch State
  if input:pressed('pause') then
    -- TODO temporarily use in-state pause. Works quite well actually
    -- self:pushState('Pause')
    self.paused = not self.paused
    if self.paused then -- accumulate time elapsed if pause
      self.session_past_duration = self.session_past_duration + love.timer.getTime() - self.previous_start_time
    else
      self.previous_start_time = love.timer.getTime()
    end
  end
  if input:pressed('restart') then self:gotoState('Session') end
  if self.session_state == GAME_LOSS then self:finish() end

  -- Entity Update
  Layout:updateAll(dt)
end

function Session:draw()
  love.graphics.setBackgroundColor(session_background_color)

  -- Session Draw
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
  love.graphics.print('Time: ' .. human_time(self.session_duration), 0, gh - default_font_size)

  -- Layout Draw
  Layout:drawAll()

  -- Dead
  if self.session_state == GAME_LOSS then
    local temp_font = love.graphics.newFont(default_font, 50)
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(temp_font)
    local gg_text = 'Game Over'
    love.graphics.print(gg_text,
                        gw / 2, gh / 2,
                        0, 1, 1,
                        temp_font:getWidth(gg_text) / 2, temp_font:getHeight(gg_text) / 2)
    love.graphics.setFont(global_font)
  end

  -- Count down
  if self.counting_down_text ~= nil then
    local temp_font = love.graphics.newFont(default_font, 50)
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(temp_font)
    love.graphics.print(self.counting_down_text,
                        gw / 2, gh / 2,
                        0, 1, 1,
                        temp_font:getWidth(self.counting_down_text) / 2, temp_font:getHeight(self.counting_down_text) / 2)
    love.graphics.setFont(global_font)
  end
end

function Session:finish()
  -- Bot terminate
  bot_loader.terminate()
  pc_finder.terminate()
end

function Session:exitedState()
  -- Remove all layouts
  Layout:destroyAll()

  -- Bot terminate
  bot_loader.terminate()
  pc_finder.terminate()
end
