require("starship"):setup()
require("duckdb"):setup()
require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}
require("easyjump"):setup()
