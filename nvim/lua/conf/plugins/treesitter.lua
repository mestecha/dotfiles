return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",

	config = function()
		-- new API: just install parsers, highlighting is built into neovim
		require("nvim-treesitter").setup({})

		-- install parsers
		local parsers = {
			"c",
			"cpp",
			"python",
			"html",
			"css",
			"javascript",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"bash",
			"markdown",
		}

		-- auto-install missing parsers
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ft = args.match
				local lang = vim.treesitter.language.get_lang(ft) or ft
				if vim.tbl_contains(parsers, lang) then
					pcall(vim.treesitter.start)
				end
			end,
		})

		-- install parsers on startup
		for _, parser in ipairs(parsers) do
			local ok = pcall(vim.treesitter.language.add, parser)
			if not ok then
				vim.fn.system({ "nvim", "--headless", "-c", "TSInstall " .. parser, "-c", "q" })
			end
		end
	end,
}
