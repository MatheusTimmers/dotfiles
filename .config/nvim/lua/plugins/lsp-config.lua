return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()

			local registry = require("mason-registry")
			registry.refresh(function()
				for _, name in ipairs({ "stylua", "clang-format", "gofumpt", "goimports" }) do
					local ok, pkg = pcall(registry.get_package, name)
					if ok and not pkg:is_installed() then
						pkg:install()
					end
				end
			end)
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "gopls", "clangd", "ts_ls", "vhdl_ls", "verible", "texlab", "omnisharp" },
				automatic_enable = { exclude = { "rust_analyzer" } },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- vim.lsp.config faz merge por cima do lsp/<nome>.lua do nvim-lspconfig,
			-- entao aqui so vai o que difere do padrao.
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						format = { enable = false },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--offset-encoding=utf-8",
					"--clang-tidy",
					"--query-driver="
						.. table.concat({
							vim.env.HOME .. "/.platformio/packages/**/bin/xtensa-esp32-elf-*",
							vim.env.HOME .. "/.espressif/tools/**/bin/*-esp-elf-*",
						}, ","),
				},
			})

			vim.lsp.config("texlab", {
				settings = {
					texlab = {
						build = {
							executable = "latexmk",
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
							onSave = true,
						},
						forwardSearch = {
							executable = "zathura",
							args = { "--synctex-forward", "%l:1:%f", "%p" },
						},
					},
				},
			})

			vim.lsp.config("omnisharp", {
				settings = {
					FormattingOptions = {
						EnableEditorConfigSupport = true,
						OrganizeImports = true,
					},
					RoslynExtensionsOptions = {
						-- analisa so arquivos abertos (mais rapido em projetos grandes)
						AnalyzeOpenDocumentsOnly = true,
					},
				},
				-- Desativa o formatter nativo do omnisharp -- usamos csharpier via none-ls
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						staticcheck = true,
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			})

			-- O verible publica os mesmos diagnosticos pelos dois caminhos do LSP:
			-- push (publishDiagnostics) e pull (textDocument/diagnostic). Cada um
			-- cai num namespace proprio do Neovim, entao tudo aparecia em dobro.
			vim.lsp.config("verible", {
				on_attach = function(client)
					client.server_capabilities.diagnosticProvider = nil
				end,
			})

			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { desc = desc })
			end

			for _, lhs in ipairs({ "grr", "gri", "grn", "gra", "grt", "grx" }) do
				pcall(vim.keymap.del, { "n", "x" }, lhs)
			end

			map("K", vim.lsp.buf.hover, "Hover")
			map("gd", vim.lsp.buf.definition, "Definition")
			map("gr", vim.lsp.buf.references, "References")
			map("gi", vim.lsp.buf.implementation, "Implementation")
			map("<C-]>", vim.lsp.buf.definition, "Definition")
			map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
			map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
			map("[d", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end, "Previous diagnostic")
			map("]d", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, "Next diagnostic")
			map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
			map("<leader>cl", vim.lsp.codelens.run, "Run code lens")

			vim.diagnostic.config({
				virtual_text = true,
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			vim.lsp.codelens.enable(true)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client then
						return
					end
					if client:supports_method("textDocument/inlayHint", ev.buf) then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
					if client.name == "clangd" then
						vim.keymap.set("n", "<leader>cH", "<cmd>LspClangdSwitchSourceHeader<cr>", {
							buffer = ev.buf,
							desc = "Switch source/header",
						})
					end
				end,
			})

			map("<leader>ch", function()
				local on = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
				vim.lsp.inlay_hint.enable(not on, { bufnr = 0 })
			end, "Toggle inlay hints")
		end,
	},
}
