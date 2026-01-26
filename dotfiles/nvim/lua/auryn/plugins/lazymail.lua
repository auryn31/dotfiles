return {
	dir = "/Users/aurynengel/coding/lazymail", -- Use your local path for testing
	-- OR after publishing: 'your-username/lazymail'
	config = function()
		require("lazymail").setup({
			maildir_path = "~/.local/share/lazymail/maildir",
			sync_tool = "mbsync",
			auto_sync_interval = 300000, -- Auto-sync every 5 minutes (in ms), set to 0 to disable
			accounts = {
				{
					name = "Auryn Engel",
					email = "auryn.engel@gmail.com",
					maildir = "~/.local/share/lazymail/maildir/gmail-main",
				},
				{
					name = "Gmail 24112009",
					email = "24112009na@gmail.com",
					maildir = "~/.local/share/lazymail/maildir/gmail",
				},
			},
		})
	end,
	keys = {
		{ "<leader>m", "<cmd>Lazymail<cr>", desc = "Open Lazymail" },
	},
}
