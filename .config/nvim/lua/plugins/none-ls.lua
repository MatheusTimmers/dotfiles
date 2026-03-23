return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.clang_format.with({
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
					extra_args = function(params)
						return { "--assume-filename", params.bufname }
					end,
				}),
				null_ls.builtins.formatting.gofumpt,
			},
		})

		vim.keymap.set("n", "<leader>gf", function()
			vim.lsp.buf.format({
				filter = function(client)
					return client.name == "null-ls"
				end,
			})
		end, {})
	end,
}
