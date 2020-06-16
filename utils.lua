function UUID()
  local f = function(x)
    local r = love.math.random(16) - 1
    r = (x == 'x') and (r + 1) or (r % 4) + 9
    return ('0123456789abcdef'):gsub(r, r)
  end
  return (('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'):gsub('[xy]', f))
end

function table.random(t)
  return t[love.math.random(1, #t)]
end

function table.shuffle(t)
  local _shuffled = {}
  for index, value in ipairs(t) do
    local randPos = math.floor(love.math.random() * index)+1
    _shuffled[index] = _shuffled[randPos]
    _shuffled[randPos] = value
  end
  return _shuffled
end

function table.copy(t)
  local copy
  if type(t) == 'table' then
    copy = {}
    for k, v in next, t, nil do copy[table.copy(k)] = table.copy(v) end
    setmetatable(copy, table.copy(getmetatable(t)))
  else
    copy = t
  end
  return copy
end

function human_time(t) -- (second)
  local _minutes = math.floor(t / 60)
  local _seconds = math.floor(t % 60)
  local _millis = math.floor(t % 1 / 0.01)
  return string.format('%02d', _minutes) .. ':' .. string.format('%02d', _seconds) .. ':' .. _millis
end
