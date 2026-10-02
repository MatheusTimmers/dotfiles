return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navegação entre hunks
        map("n", "]h", gs.next_hunk,  "Next Hunk")
        map("n", "[h", gs.prev_hunk,  "Prev Hunk")

        -- Ações
        map("n", "<leader>gs", gs.stage_hunk,        "Stage Hunk")
        map("n", "<leader>gr", gs.reset_hunk,        "Reset Hunk")
        map("n", "<leader>gS", gs.stage_buffer,      "Stage Buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk,   "Undo Stage Hunk")
        map("n", "<leader>gR", gs.reset_buffer,      "Reset Buffer")
        map("n", "<leader>gp", gs.preview_hunk,      "Preview Hunk")
        map("n", "<leader>gb", gs.blame_line,        "Blame Line")
        map("n", "<leader>gd", gs.diffthis,          "Diff This")

        -- Visual
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
      end,
    })
  end,
}
