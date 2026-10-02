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
				null_ls.builtins.formatting.goimports,
				null_ls.builtins.formatting.gofumpt,
				null_ls.builtins.formatting.csharpier,
				-- filetypes = { "verilog", "systemverilog" } ja vem no builtin.
				null_ls.builtins.formatting.verible_verilog_format,
			},
		})

		-- O none-ls nao tem source de Rust, entao nem anexa nesses buffers e o
		-- filtro fixo em "null-ls" deixava <leader>cf sem fazer nada. Quando ha
		-- none-ls no buffer ele ganha (clang-format, gofumpt, stylua); quando nao
		-- ha, cai para o formatter do proprio servidor (rustfmt via rust-analyzer).
		vim.keymap.set("n", "<leader>cf", function()
			local none_ls = #vim.lsp.get_clients({ bufnr = 0, name = "null-ls" }) > 0
			vim.lsp.buf.format({
				filter = function(client)
					return not none_ls or client.name == "null-ls"
				end,
			})
		end, { desc = "Format buffer" })
	end,
}
