-- Constants --
default_seed = nil -- optional
frame_time = 1/60 -- (second)
gravity = 3
softdrop = 300 -- coefficient
drop_coefficient = 256
hold_allowed = true
num_preview = 6
default_font = 'firacode_retina.ttf'
default_font_size = 20
line_clear_delay = 0 -- (frame)
spin_mode = 'tspinonly' -- disable / tspinonly / allspin

GAME_NORMAL = 0
GAME_WIN = 1
GAME_COUNTDOWN = 2
GAME_NOT = 3
GAME_LOSS = 4

-- Colors --
session_background_color = { 10/255,  10/255,  10/255}
pause_background_color   = {  0/255,   0/255,   0/255}
grid_color               = {100/255, 100/255, 100/255}
block_colors = {
  ['E'] = { 50/255,  50/255,   50/255},
  ['B'] = {200/255, 200/255, 200/255},
  ['S'] = {  0/255, 240/255,   0/255},
  ['Z'] = {240/255,   0/255,   0/255},
  ['L'] = {240/255, 160/255,   0/255},
  ['J'] = {  0/255,   0/255, 240/255},
  ['T'] = {160/255,   0/255, 240/255},
  ['O'] = {240/255, 240/255,   0/255},
  ['I'] = {  0/255, 240/255, 240/255},
}

-- Position --
startx = 20 -- game session positioning, include field, piece, stats, preview and hold (pixel)
starty = 20 -- game session positioning, include field, piece, stats, preview and hold (pixel)

-- Grid
grid_size = 23 -- (pixel)
grid_size_mini = 15 -- (pixel)
h_grids = 10
v_grids = 20
x_grids = 20
display_height = 24

-- Hold
hold_sx_offset = 50 -- (pixel)
hold_sy_offset = 20 -- (pixel)

-- Preview
preview_sx_offset = 400 -- (pixel)
preview_sy_offset = 0 -- (pixel)
y_separation = 70

-- Field
field_sx_offset = 150 -- (pixel)
field_sy_offset = 550 -- (pixel)
garbage_block_value = 10
empty_block_value = 0

-- Stat
stat_sx_offset = 550
stat_sy_offset = 0

-- Piece
left_direction = -1
right_direction = 1
lock_delay_limit = 30 -- (frame)
force_lock_delay_limit = 500 -- (frame)
das = 7 -- (frame)
arr = 0 -- (frame)
num_piece_blocks = 4
default_rot = 0
piece_names = {'S', 'Z', 'L', 'J', 'T', 'O', 'I'}
piece_ids = {
  ['S'] = 1,
  ['Z'] = 2,
  ['L'] = 3,
  ['J'] = 4,
  ['T'] = 5,
  ['O'] = 6,
  ['I'] = 7,
}
piece_xs = {
  ['S'] = {{2, 1, 1, 0}, {2, 2, 1, 1}, {0, 1, 1, 2}, {0, 0, 1, 1}},
  ['Z'] = {{0, 1, 1, 2}, {2, 2, 1, 1}, {2, 1, 1, 0}, {0, 0, 1, 1}},
  ['L'] = {{2, 2, 1, 0}, {2, 1, 1, 1}, {0, 0, 1, 2}, {0, 1, 1, 1}},
  ['J'] = {{0, 0, 1, 2}, {2, 1, 1, 1}, {2, 2, 1, 0}, {0, 1, 1, 1}},
  ['T'] = {{1, 0, 1, 2}, {2, 1, 1, 1}, {1, 2, 1, 0}, {0, 1, 1, 1}},
  ['O'] = {{0, 1, 1, 0}, {1, 1, 0, 0}, {1, 0, 0, 1}, {0, 0, 1, 1}},
  ['I'] = {{0, 1, 2, 3}, {2, 2, 2, 2}, {3, 2, 1, 0}, {1, 1, 1, 1}},
}
piece_ys = {
  ['S'] = {{0, 0, 1, 1}, {2, 1, 1, 0}, {2, 2, 1, 1}, {0, 1, 1, 2}},
  ['Z'] = {{0, 0, 1, 1}, {0, 1, 1, 2}, {2, 2, 1, 1}, {2, 1, 1, 0}},
  ['L'] = {{0, 1, 1, 1}, {2, 2, 1, 0}, {2, 1, 1, 1}, {0, 0, 1, 2}},
  ['J'] = {{0, 1, 1, 1}, {0, 0, 1, 2}, {2, 1, 1, 1}, {2, 2, 1, 0}},
  ['T'] = {{0, 1, 1, 1}, {1, 0, 1, 2}, {2, 1, 1, 1}, {1, 2, 1, 0}},
  ['O'] = {{0, 0, 1, 1}, {0, 1, 1, 0}, {1, 1, 0, 0}, {1, 0, 0, 1}},
  ['I'] = {{1, 1, 1, 1}, {0, 1, 2, 3}, {2, 2, 2, 2}, {3, 2, 1, 0}},
}
piece_spinbonus_high_x = {
  ['S'] = {{0, 2      }, {1, 2      }, {2, 0      }, {1, 0      }},
  ['Z'] = {{2, 1      }, {2, 1      }, {0, 2      }, {0, 1      }},
  ['L'] = {{1, 0      }, {2, 2      }, {1, 2      }, {0, 0      }},
  ['J'] = {{0, 1      }, {2, 2      }, {1, 0      }, {0, 0      }},
  ['T'] = {{0, 2      }, {2, 2      }, {0, 2      }, {0, 0      }},
  ['O'] = {{          }, {          }, {          }, {          }},
  ['I'] = {{1, 2, 2, 1}, {1, 3, 3, 1}, {1, 2, 2, 1}, {0, 2, 0, 2}},
}
piece_spinbonus_high_y = {
  ['S'] = {{0, 1      }, {2, 0      }, {2, 1      }, {0, 2      }},
  ['Z'] = {{0, 1      }, {2, 0      }, {2, 1      }, {0, 2      }},
  ['L'] = {{0, 0      }, {1, 0      }, {2, 2      }, {1, 2      }},
  ['J'] = {{0, 0      }, {1, 2      }, {2, 2      }, {1, 0      }},
  ['T'] = {{0, 0      }, {0, 2      }, {2, 2      }, {0, 2      }},
  ['O'] = {{          }, {          }, {          }, {          }},
  ['I'] = {{0, 2, 2, 0}, {1, 2, 2, 1}, {1, 3, 1, 3}, {1, 2, 2, 1}},
}
piece_spinbonus_low_x = {
  ['S'] = {{3, -1       }, {1, 2      }, {-1, 3       }, {1, 0      }},
  ['Z'] = {{-1, 3       }, {2, 1      }, {3, -1       }, {0, 1      }},
  ['L'] = {{2, 0        }, {0, 0      }, {0, 2        }, {2, 2      }},
  ['J'] = {{0, 2        }, {0, 0      }, {0, 2        }, {2, 2      }},
  ['T'] = {{0, 2        }, {0, 0      }, {2, 0        }, {2, 2      }},
  ['O'] = {{            }, {          }, {            }, {          }},
  ['I'] = {{-1, 4, -1, 4}, {2, 2, 2, 2}, {-1, 4, -1, 4}, {1, 1, 1, 1}},
}
piece_spinbonus_low_y = {
  ['S'] = {{0, 1        }, {-1, 3       }, {2, 1      }, {3, -1       }},
  ['Z'] = {{0, 1        }, {-1, 3       }, {2, 1      }, {3, -1       }},
  ['L'] = {{2, 2        }, {2, 0        }, {0, 0      }, {0, 3        }},  -- Caution: 0, 3
  ['J'] = {{2, 2        }, {0, 2        }, {0, 0      }, {2, 0        }},
  ['T'] = {{2, 2        }, {0, 2        }, {0, 0      }, {0, 2        }},
  ['O'] = {{            }, {            }, {          }, {            }},
  ['I'] = {{1, 1, 1, 1  }, {-1, 4, -1, 4}, {2, 2, 2, 2}, {-1, 4, -1, 4}},
}
piece_widths = {
  ['S'] = {3, 2, 3, 2},
  ['Z'] = {3, 2, 3, 2},
  ['L'] = {3, 2, 3, 2},
  ['J'] = {3, 2, 3, 2},
  ['T'] = {3, 2, 3, 2},
  ['O'] = {2, 2, 2, 2},
  ['I'] = {4, 1, 4, 1},
}
piece_heights = {
  ['S'] = {2, 3, 2, 3},
  ['Z'] = {2, 3, 2, 3},
  ['L'] = {2, 3, 2, 3},
  ['J'] = {2, 3, 2, 3},
  ['T'] = {2, 3, 2, 3},
  ['O'] = {2, 2, 2, 2},
  ['I'] = {1, 4, 1, 4},
}
piece_max_heights = {
  ['S'] = {2, 3, 2, 3},
  ['Z'] = {2, 3, 2, 3},
  ['L'] = {2, 3, 2, 3},
  ['J'] = {2, 3, 2, 3},
  ['T'] = {2, 3, 2, 3},
  ['O'] = {2, 2, 2, 2},
  ['I'] = {2, 4, 2, 4},
}

wallkick_normal_left = {
  {{ 1,  0}, { 1, -1}, { 0,  2}, { 1,  2}},  -- 0 >> 3
  {{ 1,  0}, { 1,  1}, { 0, -2}, { 1, -2}},  -- 1 >> 0
  {{-1,  0}, {-1, -1}, { 0,  2}, {-1,  2}},  -- 2 >> 1
  {{-1,  0}, {-1,  1}, { 0, -2}, {-1, -2}},  -- 3 >> 2
}

wallkick_normal_right = {
  {{-1,  0}, {-1, -1}, { 0,  2}, {-1,  2}},  -- 0 >> 1
  {{ 1,  0}, { 1,  1}, { 0, -2}, { 1, -2}},  -- 1 >> 2
  {{ 1,  0}, { 1, -1}, { 0,  2}, { 1,  2}},  -- 2 >> 3
  {{-1,  0}, {-1,  1}, { 0, -2}, {-1, -2}},  -- 3 >> 0
}

wallkick_I_left = {
  {{-1,  0}, { 2,  0}, {-1, -2}, { 2,  1}},  -- 0 >> 3
  {{ 2,  0}, {-1,  0}, { 2, -1}, {-1,  2}},  -- 1 >> 0
  {{ 1,  0}, {-2,  0}, { 1,  2}, {-2, -1}},  -- 2 >> 1
  {{-2,  0}, { 1,  0}, {-2,  1}, { 1, -2}},  -- 3 >> 2
}

wallkick_I_right = {
  {{-2,  0}, { 1,  0}, {-2,  1}, { 1, -2}},  -- 0 >> 1
  {{-1,  0}, { 2,  0}, {-1, -2}, { 2,  1}},  -- 1 >> 2
  {{ 2,  0}, {-1,  0}, { 2, -1}, {-1,  2}},  -- 2 >> 3
  {{ 1,  0}, {-2,  0}, { 1,  2}, {-2, -1}},  -- 3 >> 0
}

wallkick_normal_180 = {
  {{ 1,  0}, { 2,  0}, { 1,  1}, { 2,  1}, {-1,  0}, {-2,  0}, {-1,  1}, {-2,  1}, { 0, -1}, { 3,  0}, {-3,  0}},  -- 0 >> 2
  {{ 0,  1}, { 0,  2}, {-1,  1}, {-1,  2}, { 0, -1}, { 0, -2}, {-1, -1}, {-1, -2}, { 1,  0}, { 0,  3}, { 0, -3}},  -- 1 >> 3
  {{-1,  0}, {-2,  0}, {-1, -1}, {-2, -1}, { 1,  0}, { 2,  0}, { 1, -1}, { 2, -1}, { 0,  1}, {-3,  0}, { 3,  0}},  -- 2 >> 0
  {{ 0,  1}, { 0,  2}, { 1,  1}, { 1,  2}, { 0, -1}, { 0, -2}, { 1, -1}, { 1, -2}, {-1,  0}, { 0,  3}, { 0, -3}},  -- 3 >> 1
}

wallkick_I_180 = {
  {{-1,  0}, {-2,  0}, { 1,  0}, { 2,  0}, { 0,  1}},  -- 0 >> 2
  {{ 0,  1}, { 0,  2}, { 0, -1}, { 0, -2}, {-1,  0}},  -- 1 >> 3
  {{ 1,  0}, { 2,  0}, {-1,  0}, {-2,  0}, { 0, -1}},  -- 2 >> 0
  {{ 0,  1}, { 0,  2}, { 0, -1}, { 0, -2}, { 1,  0}},  -- 3 >> 1
}

piece_shift = {
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
