local function select(query)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
  end
end

local function move(fn, query)
  return function()
    require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
  end
end

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    select = { lookahead = true },
    move = { set_jumps = true },
  },
  keys = {
    { "af", select("@function.outer"), mode = { "x", "o" }, desc = "Around function" },
    { "if", select("@function.inner"), mode = { "x", "o" }, desc = "Inside function" },
    { "ac", select("@class.outer"), mode = { "x", "o" }, desc = "Around class" },
    { "ic", select("@class.inner"), mode = { "x", "o" }, desc = "Inside class" },
    { "aa", select("@parameter.outer"), mode = { "x", "o" }, desc = "Around argument" },
    { "ia", select("@parameter.inner"), mode = { "x", "o" }, desc = "Inside argument" },
    { "al", select("@loop.outer"), mode = { "x", "o" }, desc = "Around loop" },
    { "il", select("@loop.inner"), mode = { "x", "o" }, desc = "Inside loop" },
    { "ai", select("@conditional.outer"), mode = { "x", "o" }, desc = "Around conditional" },
    { "ii", select("@conditional.inner"), mode = { "x", "o" }, desc = "Inside conditional" },
    { "]f", move("goto_next_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "Next function start" },
    { "[f", move("goto_previous_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "Prev function start" },
    { "]F", move("goto_next_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "Next function end" },
    { "[F", move("goto_previous_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "Prev function end" },
    { "]c", move("goto_next_start", "@class.outer"), mode = { "n", "x", "o" }, desc = "Next class start" },
    { "[c", move("goto_previous_start", "@class.outer"), mode = { "n", "x", "o" }, desc = "Prev class start" },
    { "]a", move("goto_next_start", "@parameter.inner"), mode = { "n", "x", "o" }, desc = "Next argument" },
    { "[a", move("goto_previous_start", "@parameter.inner"), mode = { "n", "x", "o" }, desc = "Prev argument" },
  },
}
