// #include <iostream>
#include <string>
#include "PCFinder.h"
#include "flag.h"

#pragma unmanaged

extern "C" {
#include "lua51/include/lua.h"
#include "lua51/include/lualib.h"
#include "lua51/include/lauxlib.h"
}

core::PieceType charToPiece(char x) {
  switch (x) {
    case 'S':
      return core::PieceType::S;
    case 'Z':
      return core::PieceType::Z;
    case 'J':
      return core::PieceType::J;
    case 'L':
      return core::PieceType::L;
    case 'T':
      return core::PieceType::T;
    case 'O':
      return core::PieceType::O;
    case 'I':
      return core::PieceType::I;
    default:
      assert(true);
  }
}

extern "C" {
  static int updatethinking(lua_State *L) {
    Thinking = lua_toboolean(L, -1);
    return 0;
  }

  static int setThread(lua_State *L) {
    int threads = lua_tointeger(L, -1);
    threadPool.changeThreadCount(threads);
    return 0;
  }

  static int shutdown(lua_State *L) {
    threadPool.shutdown();
  }

  static int action(lua_State *L) {
    const char* field_chars = lua_tostring(L, -9);
    std::string field_string = field_chars;
    const char* queue_chars = lua_tostring(L, -8);
    const char* hold_chars = lua_tostring(L, -7);
    int height = lua_tointeger(L, -6);
    int max_height = lua_tointeger(L, -5);
    bool swap = lua_toboolean(L, -4);
    int searchtype = lua_tointeger(L, -3);
    int combo = lua_tointeger(L, -2);
    bool b2b = lua_toboolean(L, -1);

    // std::cout << "field: " << field_string << std::endl;
    // std::cout << "queue: " << queue_chars << std::endl;
    // std::cout << "hold: " << hold_chars << std::endl;
    // std::cout << "height: " << height << std::endl;
    // std::cout << "max height: " << max_height << std::endl;
    // std::cout << "swap: " << swap << std::endl;
    // std::cout << "searchtype: " << searchtype << std::endl;
    // std::cout << "combo: " << combo << std::endl;
    // std::cout << "b2b: " << b2b << std::endl;

    bool solved = false;
    std::stringstream out;

    auto field = core::createField(field_string);

    int minos_placed = 0;

    for (core::Bitboard v : field.boards)
      minos_placed = BitsSetTable256[v & 0xff] +
        BitsSetTable256[(v >> 8) & 0xff] +
        BitsSetTable256[(v >> 16) & 0xff] +
        BitsSetTable256[(v >> 24) & 0xff] +
        BitsSetTable256[(v >> 32) & 0xff] +
        BitsSetTable256[(v >> 40) & 0xff] +
        BitsSetTable256[(v >> 48) & 0xff] +
        BitsSetTable256[v >> 56];

    if (minos_placed % 2 == 0) {
      if (max_height < 0) max_height = 0;
      if (max_height > 20) max_height = 20;

      auto pieces = std::vector<core::PieceType>();

      bool holdEmpty = hold_chars[0] == 'E';
      bool holdAllowed = hold_chars[0] != 'X';
      if (!holdEmpty)
        pieces.push_back(charToPiece(hold_chars[0]));
      int max_pieces = (max_height * 10 - minos_placed) / 4 + 1;
      for (int i = 0; i < max_pieces && queue_chars[i] != '\0'; ++i)
        pieces.push_back(charToPiece(queue_chars[i]));

      height += (minos_placed % 4 == (height % 2)) ? 0 : 2;

      for(; height <= max_height; height += 2) {
        if ((height * 10 - minos_placed) / 4 + 1 > pieces.size()) break;

        auto result = pcfinder.run(
          field, pieces,
          height, holdEmpty, holdAllowed, !swap, searchtype, combo, b2b,
          true, 6
        );

        if (!result.empty()) {
          solved = true;

          for (const auto& item : result) {
            out << item.pieceType << ","
              << item.x << ","
              << item.y << ","
              << item.rotateType << "|";
          }

          break;
        }
      }
    }

    if (!solved) out << "-1";

    std::string a = out.str();
    lua_pushstring(L, a.c_str());
    return 1;
  }
}

extern "C" int luaopen_PCFinder(lua_State *L) {
  luaL_Reg l[] = {
    {"updatethinking", updatethinking},
    {"setThread", setThread},
    {"shutdown", shutdown},
    {"action", action},
    {nullptr, nullptr}
  };

  luaL_register(L, "PCFinder", l);
  return 1;
}
