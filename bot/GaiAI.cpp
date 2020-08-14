#include <stdio.h>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include "GaiAI.h"
#include "Bot.h"
#include "stuff.h"

extern "C" {
#include "lua51/include/lua.h"
#include "lua51/include/lualib.h"
#include "lua51/include/lauxlib.h"
// #include "lua.h"
// #include "lualib.h"
// #include "lauxlib.h"
}

Bot MisaBot;
std::map<char, int> m_gemMap;

extern "C" {
  static int configure(lua_State *L) {
    m_gemMap[' '] = AI::GEMTYPE_NULL;
    m_gemMap['I'] = AI::GEMTYPE_I;
    m_gemMap['T'] = AI::GEMTYPE_T;
    m_gemMap['L'] = AI::GEMTYPE_L;
    m_gemMap['J'] = AI::GEMTYPE_J;
    m_gemMap['Z'] = AI::GEMTYPE_Z;
    m_gemMap['S'] = AI::GEMTYPE_S;
    m_gemMap['O'] = AI::GEMTYPE_O;

    int params[21] = {0};
    for (int i = 0; i < 21; ++i) {
      lua_pushnumber(L, i+1);
      lua_gettable(L, 1);
      params[i] = lua_tointeger(L, -1);
      lua_pop(L, 1);
    }

    // for (int j = 0; j < 21; ++j) {
    //   printf("%d ", params[j]);
    // }
    // printf("\n");
    // printf("holdallow: %d\n", lua_toboolean(L, -4));
    // printf("allspin: %d\n", lua_toboolean(L, -3));
    // printf("tsdonly: %d\n", lua_toboolean(L, -2));
    // printf("multiplier: %d\n", lua_tointeger(L, -1));

    MisaBot = Bot();
    MisaBot.updateStyle(params);
    MisaBot.updateHoldAllowed(lua_toboolean(L, -4));
    MisaBot.updateAllSpin(lua_toboolean(L, -3));

    TSD_only = lua_toboolean(L, -2);
    sw_map_multiplier = lua_tointeger(L, -1);
    MisaBot.setup();

    return 0;
  }

  static int alive(lua_State *L) {
    lua_pushboolean(L, MisaBot.tetris.alive());
    return 1;
  }

  static int updatecombo(lua_State *L) {
    int combo = lua_tointeger(L, -1);
    // printf("combo: %d\n", combo);
    MisaBot.updateCombo(combo);
    return 0;
  }

  static int updateb2b(lua_State *L) {
    int b2b = lua_tointeger(L, -1);
    // printf("b2b: %d\n", b2b);
    MisaBot.updateB2B(b2b);
    return 0;
  }

  static int updatequeue(lua_State *L) {
    const char* queue = lua_tostring(L, -1);
    // printf("queue: %s\n", queue);
    MisaBot.updateQueue(queue);
    return 0;
  }

  static int updateincoming(lua_State *L) {
    int garbage = lua_tointeger(L, -1);
    // printf("garbage: %d\n", garbage);
    MisaBot.updateIncoming(garbage);
    return 0;
  }

  static int updatefield(lua_State *L) {
    const char* field = lua_tostring(L, -1);
    // printf("field: %s\n", field);
    MisaBot.updateField(field);
    return 0;
  }

  static int updatehold(lua_State *L) {
    const char* hold = lua_tostring(L, -1);
    // printf("hold: %s\n", hold);
    MisaBot.updateHold(hold);
    return 0;
  }

  static int updatecurrent(lua_State *L) {
    const char* current = lua_tostring(L, -1);
    // printf("current: %s\n", current);
    MisaBot.updateCurrent(current);
    return 0;
  }

  static int updatethinking(lua_State *L) {
    Thinking = lua_toboolean(L, -1);
    return 0;
  }

  static int move(lua_State *L) {
    std::string move = MisaBot.outputAction(NULL, 0);
    lua_pushstring(L, move.c_str());
    return 1;
  }

  static int findPath(lua_State *L) {
    const char* schar = lua_tostring(L, -6);
    std::string s = schar;
    const char* pschar = lua_tostring(L, -5);
    std::string ps = pschar;
    int x = lua_tointeger(L, -4);
    int y = lua_tointeger(L, -3);
    int r = lua_tointeger(L, -2);
    bool hold = lua_toboolean(L, -1);

    // std::cout << "field: " << s << std::endl;
    // std::cout << "piece: " << ps << std::endl;
    // std::cout << "x: " << x << std::endl;
    // std::cout << "y: " << y << std::endl;
    // std::cout << "rot: " << r << std::endl;
    // std::cout << "hold: " << hold << std::endl;

    std::vector<int> rows;
    bool solidGarbage = false;

    int row = 0, col = 0;

    for (const auto &c : s) {
      switch (c) {
        case '0':
        case '1':
          ++col;
          break;
        case '2':
          ++col;
          row |= (1 << (10 - col));
          break;
        case '3':
          solidGarbage = true;
          break;
        default:
          break;
      }

      if (solidGarbage)
        break;

      if (col == 10) {
        rows.push_back(row);
        row = 0;
        col = 0;
      }
    }

    // std::cout << "row: " << row << std::endl;
    // std::cout << "col: " << col<< std::endl;

    AI::GameField field;
    field.reset(10, rows.size());
    for (auto &row : rows) {
      field.addRow(row);
    }
    AI::Gem piece = AI::getGem(m_gemMap[ps[0]], 0);

    AI::Moving result;
    AI::FindPathMoving(field, result, piece, AI::gem_beg_x, AI::gem_beg_y, hold, x, y, r, -1);

    std::stringstream out;
    for (int i = 0; i < result.movs.size(); ++i) {
      out << result.movs[i] << ((i == result.movs.size() - 1) ? "|" : ",");
    }
    out << ((int) result.wallkick_spin);

    std::string a = out.str();
    lua_pushstring(L, a.c_str());
    return 1;
  }
}

extern "C" int luaopen_GaiAI(lua_State *L) {
  luaL_Reg l[] = {
    {"move", move},
    {"findPath", findPath},
    {"updatethinking", updatethinking},
    {"updateincoming", updateincoming},
    {"updateb2b", updateb2b},
    {"updatecombo", updatecombo},
    {"updatecurrent", updatecurrent},
    {"updatefield", updatefield},
    {"updatehold", updatehold},
    {"updatequeue", updatequeue},
    {"alive", alive},
    {"configure", configure},
    {nullptr, nullptr}
  };

  // luaL_newlib(L, l);
  luaL_register(L, "GaiAI", l);
  return 1;
}
