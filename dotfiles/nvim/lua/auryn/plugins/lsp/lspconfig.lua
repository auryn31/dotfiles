return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		local opts = { noremap = true, silent = true }
		local on_attach = function(_, bufnr)
			opts.buffer = bufnr

			-- set keybinds
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- configure html server
		vim.lsp.config("html", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "html" })

		-- configure typescript server with plugin
		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "ts_ls" })

		-- configure css server
		vim.lsp.config("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "cssls" })

		-- configure tailwindcss server
		vim.lsp.config("tailwindcss", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "tailwindcss" })

		-- configure svelte server
		vim.lsp.config("svelte", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "svelte" })

		-- configure prisma orm server
		vim.lsp.config("prismals", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "prismals" })

		-- configure docker server
		vim.lsp.config("dockerls", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "Dockerfile", "dockerfile" },
			vim.lsp.enable({ "dockerls" }),
		})

		-- configure rust
		vim.lsp.config("rust_analyzer", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "rust_analyzer" })

		-- configure graphql language server
		vim.lsp.config("graphql", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			vim.lsp.enable({ "graphql" }),
		})

		-- configure emmet language server
		vim.lsp.config("emmet_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		})
		vim.lsp.enable({ "emmet_ls" })

		-- configure python server
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "pyright" })

		vim.lsp.config("gopls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "gopls" })

		-- configure python server
		vim.lsp.config("erlangls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "erlangls" })

		-- configure elixir server
		vim.lsp.config("elixirls", {
			cmd = { "elixir-ls" },
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "elixirls" })

		vim.lsp.config("gleam", {
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable({ "gleam" })

		vim.lsp.config("hls", {
			capabilities = capabilities,
			on_attach = on_attach,
			-- filetypes = { "haskell", "lhaskell", "cabal" },
			-- hls = function()
			-- 	return true
			-- end,
		})
		vim.lsp.enable({ "hls" })

		vim.lsp.config("kotlin_language_server", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "kotlin" },
		})
		vim.lsp.enable({ "kotlin_language_server" })

		-- configure lua server (with special settings)
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = { -- custom settings for lua
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})
		vim.lsp.enable({ "lua_ls" })

		-- require("java").setup()
		vim.lsp.config("jdtls", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "java" },
		})
		vim.lsp.enable({ "jdtls" })
	end,
}
