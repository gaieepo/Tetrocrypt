local Class = require 'libraries/middleclass/middleclass'
local Timer = require 'libraries/hump/timer'

local TimerEx = Class('TimerEx')


function TimerEx:initialize()
  self.timer = Timer.new()
  self.tags = {}
end

function TimerEx:update(dt)
  if self.timer then self.timer:update(dt) end
end

function TimerEx:after(tag, duration, func)
  if type(tag) == 'string' then
    self:cancel(tag)
    self.tags[tag] = self.timer:after(duration, func)
    return self.tags[tag]
  else
    return self.timer:after(tag, duration, func)
  end
end

function TimerEx:during(tag, duration, func, after)
  if type(tag) == 'string' then
    self:cancel(tag)
    self.tags[tag] = self.timer:during(duration, func, after)
    return self.tags[tag]
  else
    return self.timer:during(tag, duration, func, after)
  end
end

function TimerEx:every(tag, duration, func, count)
  if type(tag) == 'string' then
    self:cancel(tag)
    self.tags[tag] = self.timer:every(duration, func, count)
    return self.tags[tag]
  else
    return self.timer:every(tag, duration, func, count)
  end
end

function TimerEx:tween(tag, duration, table, tween_table, tween_function, after, ...)
  if type(tag) == 'string' then
    self:cancel(tag)
    self.tags[tag] = self.timer:tween(duration, table, tween_table, tween_function, after, ...)
    return self.tags[tag]
  else
    return self.timer:tween(tag, duration, table, tween_table, tween_function, after, ...)
  end
end

function TimerEx:cancel(tag)
  if tag then
    if self.tags[tag] then
      self.timer:cancel(self.tags[tag])
      self.tags[tag] = nil
    else
      self.timer:cancel(tag)
    end
  end
end

function TimerEx:clear()
  self.timer:clear()
  self.tags = {}
end

function TimerEx:destroy()
  self.timer:clear()
  self.tags = {}
  self.timer = nil
end

return TimerEx
