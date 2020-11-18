-- Constants --
DEBUG = false
DEFAULT_SEED = 42 -- optional
FRAME_TIME = 1/60 -- (second)
GRAVITY = 5
SOFTDROP_CONSTANT = 300 -- coefficient
DROP_COEFFICIENT = 256
HOLD_ALLOWED = true
NUM_PREVIEW = 6
LINE_CLEAR_DELAY = 30 -- (frame)
SPIN_MODE = 'tspinonly' -- disable / tspinonly / allspin

-- Font --
DEFAULT_FONT = 'firacode_retina.ttf'
DEFAULT_FONT_SIZE = 20
MAJOR_FONT_SIZE = 50
STAT_FONT_SIZE = 15

-- Colors --
SESSION_BACKGROUND_COLOR = { 10/255,  10/255,  10/255}
PAUSE_BACKGROUND_COLOR   = {100/255, 100/255, 100/255}
GRID_COLOR               = {100/255, 100/255, 100/255}
BLOCK_COLORS = {
  ['E'] = { 50/255,  50/255,  50/255},
  ['B'] = {200/255, 200/255, 200/255},
  ['S'] = {  0/255, 240/255,   0/255},
  ['Z'] = {240/255,   0/255,   0/255},
  ['L'] = {240/255, 160/255,   0/255},
  ['J'] = {  0/255,   0/255, 240/255},
  ['T'] = {160/255,   0/255, 240/255},
  ['O'] = {240/255, 240/255,   0/255},
  ['I'] = {  0/255, 240/255, 240/255},
}
BLOCK_ALPHA_COLORS = {
  ['E'] = { 50/255,  50/255,  50/255, 0.4},
  ['B'] = {200/255, 200/255, 200/255, 0.4},
  ['S'] = {  0/255, 240/255,   0/255, 0.4},
  ['Z'] = {240/255,   0/255,   0/255, 0.4},
  ['L'] = {240/255, 160/255,   0/255, 0.4},
  ['J'] = {  0/255,   0/255, 240/255, 0.4},
  ['T'] = {160/255,   0/255, 240/255, 0.4},
  ['O'] = {240/255, 240/255,   0/255, 0.4},
  ['I'] = {  0/255, 240/255, 240/255, 0.4},
}
LOCK_COLOR = 'colored' -- mono / colored

SESSION_NORMAL = 1
SESSION_COUNTDOWN = 2
SESSION_END = 4
GAME_NORMAL = 8
GAME_WIN = 16
GAME_LOSE = 32
SESSION_MODE = 'bot-match' -- analysis / match / bot-match
GAME_MODE = 'infinite' -- infinite / sprint / bot
SPRINT_LINES = 40
HUMAN_INDEX = 0
NUM_PLAYERS = 2 -- not used

-- Garbage --
PC_GARBAGE_BONUS = 7
BASE_GARBAGE_TABLE = {0, 1, 2, 4}
TSPIN_GARBAGE_TABLE = {2, 4, 6}
DEFAULT_B2B_BONUS_COEFF = 1
DEFAULT_B2B_BONUS_LOG = 0.8

-- Bot & PC Finder --
BOT_PLAY = true
PCFINDER_PLAY = false
BOT_MOVE_DELAY = 1 -- (frame)

NUM_BOT_PREVIEW = 14
THINK_DURATION = 0.1
BOT_HOLDALLOWED = true
BOT_ALLSPIN = false
BOT_TSDONLY = false
BOT_SEARCHWIDTH = 1000 -- 1000 optimal

NUM_PCFINDER_PREVIEW = 14
PCFINDER_THINK_DURATION = 0.1

BOT_PARAMS = {
  -- miny_factor, hole, open_hole, v_transitions, tspin3,
  -- clear_efficient, upcomeAtt, h_factor, hole_dis_factor2, hole_dis, // flat_factor,
  -- hole_dis_factor, tspin, hole_T, hole_I, clear_useless_factor, // ready_combo,
  -- dif_factor, b2b, combo, avoid_softdrop, tmini,
  -- strategy_4w,

  -- Sprint 40L
  -- 0, 0, 0, 0, -300,
  -- 0, 0, 0, 0, 0,
  -- 0, -300, 0, 0, 0,
  -- 0, 0, 0, 300, -300,
  -- 0

  -- MISAMINO
  -- 16, 9, 11, 17, 17,
  -- 25, 39, 2, 12, 19,
  -- 7, 24, 18, 7, 14,
  -- 19, 25, 30, 18, 19,
  -- 0,

  -- TSPIN + B2B (baseline)
  16, 9, 11, 17, 17,
  25, 39, 2, 12, 19,
  7, 24, 18, 7, 14,
  19, 99, 14, 19, 0,
  0,

  -- TSPINPLUS
  -- 13, 9, 17, 10, 29,
  -- 25, 39, 2, 12, 19,
  -- 7, 24, 21, 16, 14,
  -- 19, 0, 30, 0, 24,
  -- 0,

  -- TST
  -- 16, 9, 11, 17, 500,
  -- 25, 39, 2, 12, 19,
  -- 7, 1, 18, 7, 14,
  -- 19, 25, 30, 18, 19,
  -- 0,

  -- Ultra
  -- 16, 9, 11, 23, 20,
  -- 1, 39, 2, 12, 19,
  -- 7, 24, 32, 16, 1,
  -- 19, 500, 0, 63, 0,
  -- 0,

  -- TSD20 (not exactly)
  -- 0, 0, 0, 500, 0,
  -- 0, 0, 2, 12, 19,
  -- 7, 74, 0, 0, 0,
  -- 19, 500, 0, 0, 0,
  -- 0,

  -- JSTSPIN (baseline)
  -- 13, 9, 17, 10, 29,
  -- 25, 39, 2, 12, 19,
  -- 7, 24, 21, 16, 14,
  -- 19, 0, 0, 0, 0,
  -- 200,

  -- JSREN
  -- 13, 9, 17, 10, -271,
  -- 25, 39, 2, 12, 19,
  -- 7, -276, 21, 16, 11,
  -- 19, 0, 0, 0, 0,
  -- 200,

  -- RENTRAIN (combo practice)
  -- 13, 9, 17, 10, -300,
  -- 25, 39, 2, 12, 19,
  -- 7, -300, 21, 16, 9,
  -- 19, 0, 500, 0, 0,
  -- 200
}

-- Position --
SESSION_STARTX = 0 -- game session positioning, include field, piece, stats, preview and hold (pixel)
SESSION_STARTY = 20 -- game session positioning, include field, piece, stats, preview and hold (pixel)

-- Grid
GRID_SIZE = 23 -- (pixel)
GRID_SIZE_MINI = 15 -- (pixel) not used
H_GRIDS = 10
V_GRIDS = 20
X_GRIDS = 20
DISPLAY_HEIGHT = 24

-- Hold
HOLD_SX_OFFSET = 50 -- (pixel)
HOLD_SY_OFFSET = 20 -- (pixel)

-- Preview
NUM_BAGS = 4
BASE_BAG = {1, 2, 3, 4, 5, 6, 7} -- {'S', 'Z', 'L', 'J', 'T', 'O', 'I'}
PREVIEW_SX_OFFSET = 400 -- (pixel)
PREVIEW_SY_OFFSET = 0 -- (pixel)
Y_SEPARATION = 70

-- Field
FIELD_SX_OFFSET = 150 -- (pixel)
FIELD_SY_OFFSET = 550 -- (pixel)
GARBAGE_BLOCK_VALUE = 10
EMPTY_BLOCK_VALUE = 0
DIG_MODE = false
DIG_DELAY = 1

-- Stat
STAT_SX_OFFSET = 550
STAT_SY_OFFSET = 0

-- Piece
LEFT_DIRECTION = -1 -- not used
RIGHT_DIRECTION = 1 -- not used
LOCK_DELAY_LIMIT = 30 -- (frame)
FORCE_LOCK_DELAY_LIMIT = 500 -- (frame)
DAS = 7 -- (frame)
ARR = 0 -- (frame)
NUM_PIECE_BLOCKS = 4
DEFAULT_ROT = 0
PIECE_NAMES = {'S', 'Z', 'L', 'J', 'T', 'O', 'I'} -- baseline
BOT_PIECE_NAMES = {
  ['S'] = 'Z',
  ['Z'] = 'S',
  ['L'] = 'J',
  ['J'] = 'L',
  ['T'] = 'T',
  ['O'] = 'O',
  ['I'] = 'I',
  [' '] = ' ',
}
PCFINDER_PIECE_NAMES = {'T', 'I', 'L', 'J', 'S', 'Z', 'O'}
PIECE_IDS = {
  ['S'] = 1,
  ['Z'] = 2,
  ['L'] = 3,
  ['J'] = 4,
  ['T'] = 5,
  ['O'] = 6,
  ['I'] = 7,
}
PIECE_XS = {
  ['S'] = {{2, 1, 1, 0}, {2, 2, 1, 1}, {0, 1, 1, 2}, {0, 0, 1, 1}},
  ['Z'] = {{0, 1, 1, 2}, {2, 2, 1, 1}, {2, 1, 1, 0}, {0, 0, 1, 1}},
  ['L'] = {{2, 2, 1, 0}, {2, 1, 1, 1}, {0, 0, 1, 2}, {0, 1, 1, 1}},
  ['J'] = {{0, 0, 1, 2}, {2, 1, 1, 1}, {2, 2, 1, 0}, {0, 1, 1, 1}},
  ['T'] = {{1, 0, 1, 2}, {2, 1, 1, 1}, {1, 2, 1, 0}, {0, 1, 1, 1}},
  ['O'] = {{0, 1, 1, 0}, {1, 1, 0, 0}, {1, 0, 0, 1}, {0, 0, 1, 1}},
  ['I'] = {{0, 1, 2, 3}, {2, 2, 2, 2}, {3, 2, 1, 0}, {1, 1, 1, 1}},
}
PIECE_YS = {
  ['S'] = {{0, 0, 1, 1}, {2, 1, 1, 0}, {2, 2, 1, 1}, {0, 1, 1, 2}},
  ['Z'] = {{0, 0, 1, 1}, {0, 1, 1, 2}, {2, 2, 1, 1}, {2, 1, 1, 0}},
  ['L'] = {{0, 1, 1, 1}, {2, 2, 1, 0}, {2, 1, 1, 1}, {0, 0, 1, 2}},
  ['J'] = {{0, 1, 1, 1}, {0, 0, 1, 2}, {2, 1, 1, 1}, {2, 2, 1, 0}},
  ['T'] = {{0, 1, 1, 1}, {1, 0, 1, 2}, {2, 1, 1, 1}, {1, 2, 1, 0}},
  ['O'] = {{0, 0, 1, 1}, {0, 1, 1, 0}, {1, 1, 0, 0}, {1, 0, 0, 1}},
  ['I'] = {{1, 1, 1, 1}, {0, 1, 2, 3}, {2, 2, 2, 2}, {3, 2, 1, 0}},
}
PCFINDER_OFFSET = {
  ['S'] = {{-1, 1}, {-1, 1}, {-1, 1}, {-1, 1}},
  ['Z'] = {{-1, 1}, {-1, 1}, {-1, 1}, {-1, 1}},
  ['L'] = {{-1, 1}, {-1, 1}, {-1, 1}, {-1, 1}},
  ['J'] = {{-1, 1}, {-1, 1}, {-1, 1}, {-1, 1}},
  ['T'] = {{-1, 1}, {-1, 1}, {-1, 1}, {-1, 1}},
  ['O'] = {{-1, 1}, {-1, 1}, {-1, 1}, {-1, 1}},
  ['I'] = {{-1, 1}, {-2, 1}, {-2, 2}, {-1, 2}},
}
PIECE_WIDTHS = {
  ['S'] = {3, 2, 3, 2},
  ['Z'] = {3, 2, 3, 2},
  ['L'] = {3, 2, 3, 2},
  ['J'] = {3, 2, 3, 2},
  ['T'] = {3, 2, 3, 2},
  ['O'] = {2, 2, 2, 2},
  ['I'] = {4, 1, 4, 1},
}
PIECE_HEIGHTS = {
  ['S'] = {2, 3, 2, 3},
  ['Z'] = {2, 3, 2, 3},
  ['L'] = {2, 3, 2, 3},
  ['J'] = {2, 3, 2, 3},
  ['T'] = {2, 3, 2, 3},
  ['O'] = {2, 2, 2, 2},
  ['I'] = {1, 4, 1, 4},
}
PIECE_MAX_HEIGHTS = {
  ['S'] = {2, 3, 2, 3},
  ['Z'] = {2, 3, 2, 3},
  ['L'] = {2, 3, 2, 3},
  ['J'] = {2, 3, 2, 3},
  ['T'] = {2, 3, 2, 3},
  ['O'] = {2, 2, 2, 2},
  ['I'] = {2, 4, 2, 4},
}

WALLKICK_NORMAL_LEFT = {
  {{ 1,  0}, { 1, -1}, { 0,  2}, { 1,  2}},  -- 0 >> 3
  {{ 1,  0}, { 1,  1}, { 0, -2}, { 1, -2}},  -- 1 >> 0
  {{-1,  0}, {-1, -1}, { 0,  2}, {-1,  2}},  -- 2 >> 1
  {{-1,  0}, {-1,  1}, { 0, -2}, {-1, -2}},  -- 3 >> 2
}

WALLKICK_NORMAL_RIGHT = {
  {{-1,  0}, {-1, -1}, { 0,  2}, {-1,  2}},  -- 0 >> 1
  {{ 1,  0}, { 1,  1}, { 0, -2}, { 1, -2}},  -- 1 >> 2
  {{ 1,  0}, { 1, -1}, { 0,  2}, { 1,  2}},  -- 2 >> 3
  {{-1,  0}, {-1,  1}, { 0, -2}, {-1, -2}},  -- 3 >> 0
}

WALLKICK_I_LEFT = {
  {{-1,  0}, { 2,  0}, {-1, -2}, { 2,  1}},  -- 0 >> 3
  {{ 2,  0}, {-1,  0}, { 2, -1}, {-1,  2}},  -- 1 >> 0
  {{ 1,  0}, {-2,  0}, { 1,  2}, {-2, -1}},  -- 2 >> 1
  {{-2,  0}, { 1,  0}, {-2,  1}, { 1, -2}},  -- 3 >> 2
}

WALLKICK_I_RIGHT = {
  {{-2,  0}, { 1,  0}, {-2,  1}, { 1, -2}},  -- 0 >> 1
  {{-1,  0}, { 2,  0}, {-1, -2}, { 2,  1}},  -- 1 >> 2
  {{ 2,  0}, {-1,  0}, { 2, -1}, {-1,  2}},  -- 2 >> 3
  {{ 1,  0}, {-2,  0}, { 1,  2}, {-2, -1}},  -- 3 >> 0
}

WALLKICK_NORMAL_180 = {
  {{ 1,  0}, { 2,  0}, { 1,  1}, { 2,  1}, {-1,  0}, {-2,  0}, {-1,  1}, {-2,  1}, { 0, -1}, { 3,  0}, {-3,  0}},  -- 0 >> 2
  {{ 0,  1}, { 0,  2}, {-1,  1}, {-1,  2}, { 0, -1}, { 0, -2}, {-1, -1}, {-1, -2}, { 1,  0}, { 0,  3}, { 0, -3}},  -- 1 >> 3
  {{-1,  0}, {-2,  0}, {-1, -1}, {-2, -1}, { 1,  0}, { 2,  0}, { 1, -1}, { 2, -1}, { 0,  1}, {-3,  0}, { 3,  0}},  -- 2 >> 0
  {{ 0,  1}, { 0,  2}, { 1,  1}, { 1,  2}, { 0, -1}, { 0, -2}, { 1, -1}, { 1, -2}, {-1,  0}, { 0,  3}, { 0, -3}},  -- 3 >> 1
}

WALLKICK_I_180 = {
  {{-1,  0}, {-2,  0}, { 1,  0}, { 2,  0}, { 0,  1}},  -- 0 >> 2
  {{ 0,  1}, { 0,  2}, { 0, -1}, { 0, -2}, {-1,  0}},  -- 1 >> 3
  {{ 1,  0}, { 2,  0}, {-1,  0}, {-2,  0}, { 0, -1}},  -- 2 >> 0
  {{ 0,  1}, { 0,  2}, { 0, -1}, { 0, -2}, { 1,  0}},  -- 3 >> 1
}

PIECE_SHIFT = {
  ['1110'] = -1,
  ['1101'] =  1,
  ['1100'] =  0,

  ['0011'] =  0,
  ['0010'] = -1,
  ['0001'] =  1,
  ['0000'] =  0, -- initial shift state

  ['0111'] = -1,
  ['0100'] =  0,
  ['0110'] = -1,

  ['1011'] =  1,
  ['1001'] =  1,
  ['1000'] =  0,
}

MOV_NULL  = 0
MOV_L     = 1
MOV_R     = 2
MOV_LL    = 3
MOV_RR    = 4
MOV_D     = 5
MOV_DD    = 6
MOV_LSPIN = 7
MOV_RSPIN = 8
MOV_DROP  = 9
MOV_HOLD  = 10
MOV_SPIN2 = 11

-- PIECE_SPINBONUS_HIGH_X = {
--   ['S'] = {{0, 2      }, {1, 2      }, {2, 0      }, {1, 0      }},
--   ['Z'] = {{2, 1      }, {2, 1      }, {0, 2      }, {0, 1      }},
--   ['L'] = {{1, 0      }, {2, 2      }, {1, 2      }, {0, 0      }},
--   ['J'] = {{0, 1      }, {2, 2      }, {1, 0      }, {0, 0      }},
--   ['T'] = {{0, 2      }, {2, 2      }, {0, 2      }, {0, 0      }},
--   ['O'] = {{          }, {          }, {          }, {          }},
--   ['I'] = {{1, 2, 2, 1}, {1, 3, 3, 1}, {1, 2, 2, 1}, {0, 2, 0, 2}},
-- }
-- PIECE_SPINBONUS_HIGH_Y = {
--   ['S'] = {{0, 1      }, {2, 0      }, {2, 1      }, {0, 2      }},
--   ['Z'] = {{0, 1      }, {2, 0      }, {2, 1      }, {0, 2      }},
--   ['L'] = {{0, 0      }, {1, 0      }, {2, 2      }, {1, 2      }},
--   ['J'] = {{0, 0      }, {1, 2      }, {2, 2      }, {1, 0      }},
--   ['T'] = {{0, 0      }, {0, 2      }, {2, 2      }, {0, 2      }},
--   ['O'] = {{          }, {          }, {          }, {          }},
--   ['I'] = {{0, 2, 2, 0}, {1, 2, 2, 1}, {1, 3, 1, 3}, {1, 2, 2, 1}},
-- }
-- PIECE_SPINBONUS_LOW_X = {
--   ['S'] = {{3, -1       }, {1, 2      }, {-1, 3       }, {1, 0      }},
--   ['Z'] = {{-1, 3       }, {2, 1      }, {3, -1       }, {0, 1      }},
--   ['L'] = {{2, 0        }, {0, 0      }, {0, 2        }, {2, 2      }},
--   ['J'] = {{0, 2        }, {0, 0      }, {0, 2        }, {2, 2      }},
--   ['T'] = {{0, 2        }, {0, 0      }, {2, 0        }, {2, 2      }},
--   ['O'] = {{            }, {          }, {            }, {          }},
--   ['I'] = {{-1, 4, -1, 4}, {2, 2, 2, 2}, {-1, 4, -1, 4}, {1, 1, 1, 1}},
-- }
-- PIECE_SPINBONUS_LOW_Y = {
--   ['S'] = {{0, 1        }, {-1, 3       }, {2, 1      }, {3, -1       }},
--   ['Z'] = {{0, 1        }, {-1, 3       }, {2, 1      }, {3, -1       }},
--   ['L'] = {{2, 2        }, {2, 0        }, {0, 0      }, {0, 3        }},  -- Caution: 0, 3
--   ['J'] = {{2, 2        }, {0, 2        }, {0, 0      }, {2, 0        }},
--   ['T'] = {{2, 2        }, {0, 2        }, {0, 0      }, {0, 2        }},
--   ['O'] = {{            }, {            }, {          }, {            }},
--   ['I'] = {{1, 1, 1, 1  }, {-1, 4, -1, 4}, {2, 2, 2, 2}, {-1, 4, -1, 4}},
-- }
