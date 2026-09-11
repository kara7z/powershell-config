return {
  "saghen/blink.cmp",
  opts = {
    -- Windows: skip 600ms Rust fuzzy build/download, use Lua (instant)
    fuzzy = { implementation = "lua" },
    keymap = {
      preset = "enter",
      ["<Tab>"] = { "select_next", LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }), "fallback" },
      ["<S-Tab>"] = { "select_prev", LazyVim.cmp.map({ "snippet_backward" }), "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-y>"] = { "select_and_accept", "fallback" },
    },
  },
}
