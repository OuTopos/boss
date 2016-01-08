local humanoid = {}
humanoid.stand_left   = {delay = 0.08, first = 118, last = 118, loop = true, finish = false, reverse = false}
humanoid.stand_right  = {delay = 0.08, first = 144, last = 144, loop = true, finish = false, reverse = false}
humanoid.stand_up     = {delay = 0.08, first = 105, last = 105, loop = true, finish = false, reverse = false}
humanoid.stand_down   = {delay = 0.08, first = 131, last = 131, loop = true, finish = false, reverse = false}

humanoid.walk_left    = {delay = 0.08, first = 119, last = 126, loop = true, finish = false, reverse = false}
humanoid.walk_right   = {delay = 0.08, first = 145, last = 152, loop = true, finish = false, reverse = false}
humanoid.walk_up      = {delay = 0.08, first = 106, last = 113, loop = true, finish = false, reverse = false}
humanoid.walk_down    = {delay = 0.08, first = 132, last = 139, loop = true, finish = false, reverse = false}

humanoid.sword_left    = {delay = 0.04, first = 171, last = 175, loop = false, finish = true, reverse = false}
humanoid.sword_right   = {delay = 0.04, first = 197, last = 201, loop = false, finish = true, reverse = false}
humanoid.sword_up      = {delay = 0.04, first = 158, last = 162, loop = false, finish = true, reverse = false}
humanoid.sword_down    = {delay = 0.04, first = 184, last = 188, loop = false, finish = true, reverse = false}

return humanoid