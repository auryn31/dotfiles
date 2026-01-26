return {
	"pimalaya/himalaya-vim",
	branch = "master",
	config = function()
		vim.g.himalaya_executable = "/opt/homebrew/bin/himalaya"
		vim.g.himalaya_folder_picker = "telescope"
		vim.g.himalaya_folder_picker_telescope_preview = false
	end,
}
