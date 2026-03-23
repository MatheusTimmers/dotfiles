return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "gopls", "clangd", "ts_ls" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						format = { enable = false },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})
			lspconfig.gopls.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--offset-encoding=utf-8",
				},
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})

			vim.keymap.set("n", "K",          vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd",         vim.lsp.buf.definition, {})
			vim.keymap.set("n", "gr",         vim.lsp.buf.references, {})
			vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, {})
			vim.keymap.set("n", "<C-]>",      vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev, {})
			vim.keymap.set("n", "]d",         vim.diagnostic.goto_next, {})
			vim.keymap.set("n", "<leader>d",  vim.diagnostic.open_float, {})
		end,
	},
}
