local fn = require 'libraries/Moses/moses'

local x = {2, 1, 3, 5, 4}
local y = {1, 2, 3, 4, 5}

print(fn.same(x, y))
