return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"Hoffs/omnisharp-extended-lsp.nvim",
		"Issafalcon/lsp-overloads.nvim",
		"williamboman/mason.nvim",
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		local rounded_borders = {
			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
		}

		local capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())

		require("mason").setup()
		local lspconfig = require("lspconfig")

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			handlers = rounded_borders,
		})

		lspconfig.omnisharp.setup({
			cmd = { "omnisharp.cmd" },
			capabilities = capabilities,
			root_dir = function(fname)
				local primary = lspconfig.util.root_pattern("*.sln")(fname)
				local fallback = lspconfig.util.root_pattern("*.csproj")(fname)
				return primary or fallback
			end,
			settings = {
				FormattingOptions = {
					OrganizeImports = true,
				},
				RoslynExtensionsOptions = {
					AnalyzeOpenDocumentsOnly = true,
					EnableImportCompletion = true,
					EnableDecompilationSupport = true,
				},
				Sdk = {
					IncludePrereleases = true,
				},
			},
			handlers = vim.tbl_extend("force", rounded_borders, {
				["textDocument/definition"] = require("omnisharp_extended").definition_handler,
				["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
				["textDocument/references"] = require("omnisharp_extended").references_handler,
				["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
			}),
		})

		lspconfig.gopls.setup({
			capabilities = capabilities,
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
					templateExtensions = { "gohtml" },
				},
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				local opts = { noremap = true, silent = true, buffer = bufnr }
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end

				vim.keymap.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
				vim.keymap.set("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
				vim.keymap.set("n", "<leader>bo", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
				vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
				vim.keymap.set("n", "<leader>dl", "<cmd>lua vim.lsp.diagnostic.setloclist()<CR>", opts)
				vim.keymap.set("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
				vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
				vim.keymap.set("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
				vim.keymap.set(
					"n",
					"<leader>wl",
					"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
					opts
				)
				vim.keymap.set("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
				vim.keymap.set("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
				vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
				vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
				vim.keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
				vim.keymap.set("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
				vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
				vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

				if client.server_capabilities.signatureHelpProvider then
					---@diagnostic disable-next-line: missing-fields
					require("lsp-overloads").setup(client, {})
					vim.keymap.set({ "n", "i" }, "<A-s>", "<CMD>LspOverloadsSignature<CR>", opts)
				end

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function() require("conform").format({ bufnr = bufnr }) end,
				})
			end,
		})
	end,
}