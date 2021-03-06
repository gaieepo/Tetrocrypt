local Session = Game:addState('Session')

function Session:enteredState()
  -- Session Env
  self.paused = false
  self.bot_play = BOT_PLAY
  self.pcfinder_play = PCFINDER_PLAY
  self.session_status = SESSION_COUNTDOWN
  self.counting_down_text = nil
  self.sstartx, self.sstarty = SESSION_STARTX, SESSION_STARTY

  -- timer
  self.previous_start_time = love.timer.getTime()
  self.session_past_duration = 0
  self.session_duration = 0 -- (second)

  -- Session State Input Handler
  input:bind('escape', 'pause')
  input:bind('backspace', 'restart')
  input:bind('g', 'garbage')
  input:bind('o', 'auto')

  -- if not self.BOT_PLAY then
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
  if SESSION_MODE == 'match' then
    l1 = Layout:new(self, HUMAN_INDEX, self.sstartx, self.sstarty)
    l2 = Layout:new(self, HUMAN_INDEX + 1, self.sstartx + 500, self.sstarty)
  elseif SESSION_MODE == 'bot-match' then
    l1 = Layout:new(self, HUMAN_INDEX + 1, self.sstartx, self.sstarty)
    l2 = Layout:new(self, HUMAN_INDEX + 2, self.sstartx + 500, self.sstarty)
  elseif SESSION_MODE == 'analysis' then
    layout = Layout:new(self, HUMAN_INDEX, self.sstartx, self.sstarty)
  end
end

function Session:update(dt)
  -- Update timer in state
  self.timer:update(dt)

  -- Session Env
  if input:released('auto') and DEBUG then
    self.bot_play = not self.bot_play
    self.pcfinder_play = not self.bot_play
  end

  -- Count down
  if self.session_status == SESSION_COUNTDOWN and self.counting_down_text == nil then
    self.timer:after(1, function() self.session_status = SESSION_NORMAL end)

    self.timer:during(0.5, function() self.counting_down_text = 'READY' end, function()
      self.timer:during(0.5, function() self.counting_down_text = 'GO' end, function()
        self.counting_down_text = nil
      end)
    end)
  end

  if self.paused or self.session_status ~= SESSION_NORMAL then
    self.session_duration = self.session_past_duration
  else
    self.session_duration = self.session_past_duration + love.timer.getTime() - self.previous_start_time
  end

  -- Switch State
  if input:pressed('pause') then
    -- TODO temporarily use in-state pause. Works quite well actually
    -- self:pushState('Pause')
    self.paused = not self.paused
    if self.paused then
      -- accumulate time elapsed if pause
      self.session_past_duration = self.session_past_duration + love.timer.getTime() - self.previous_start_time
    else
      self.previous_start_time = love.timer.getTime()
    end
  end
  if input:pressed('restart') then self:gotoState('Session') end

  local is_all_layout_normal, layout_id = Layout:allNormal()
  if self.session_status ~= SESSION_END and not is_all_layout_normal then
    self.session_status = SESSION_END
    -- accumulate time elapsed if session ends
    self.session_past_duration = self.session_past_duration + love.timer.getTime() - self.previous_start_time
    self:finish()
  end

  -- Entity Update
  Layout:updateAll(dt)
end

function Session:draw()
  love.graphics.setBackgroundColor(SESSION_BACKGROUND_COLOR)

  -- Session Draw
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
  love.graphics.print('Time: ' .. human_time(self.session_duration), 0, GH - DEFAULT_FONT_SIZE)

  -- Layout Draw
  Layout:drawAll()

  -- Paused
  if self.paused then
    love.graphics.setBackgroundColor(PAUSE_BACKGROUND_COLOR)
    love.graphics.setColor(1, 1, 1)
    local pause_text = 'Game Pause'
    love.graphics.print(pause_text,
                        GW / 2, GH / 2,
                        0, 1, 1,
                        global_font:getWidth(pause_text) / 2, global_font:getHeight(pause_text) / 2)
  end

  -- Dead
  if self.session_status == SESSION_END then
    local major_font = love.graphics.newFont(DEFAULT_FONT, MAJOR_FONT_SIZE)
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(major_font)
    local gg_text = 'Game Over'
    love.graphics.print(gg_text,
                        GW / 2, GH / 2,
                        0, 1, 1,
                        major_font:getWidth(gg_text) / 2, major_font:getHeight(gg_text) / 2)
    love.graphics.setFont(global_font)
  end

  -- Count down
  if self.counting_down_text ~= nil then
    local major_font = love.graphics.newFont(DEFAULT_FONT, MAJOR_FONT_SIZE)
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(major_font)
    love.graphics.print(self.counting_down_text,
                        GW / 2, GH / 2,
                        0, 1, 1,
                        major_font:getWidth(self.counting_down_text) / 2, major_font:getHeight(self.counting_down_text) / 2)
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
