local lazy = require("lazy")

local augroup_name = "snoozydev"

-- TODO:
-- 	 Config:
--     * support "skipping" certain plugins you don't want this to apply to ... config item named "disable_for" ?
--     * support "skipping" certain plugins you don't want this to apply to ... config item named "disable_for" ?
--     * the "devhook" feature will guess your module import... support a config item to specify what it will be if different from plugin name
--     * figure out how to suppress (or shorten) the reload notification
--   Features:
--     * Run the devhook as soon as you start editing a plugin?

M = {
	default_config = {
		enabled = true,
	},
	state = {
		has_warned = {},
	},
}
vim.api.nvim_create_augroup(augroup_name, { clear = true })

function M.setup(config)
	config = vim.tbl_extend("keep", config, M.default_config)

	if (config.enabled) then
		-- Register hooks to auto-reload dev plugins
		for _, val in ipairs(lazy.plugins()) do
			if val.dev then
				M.__hook_plugin(val)
			end
		end
	end
end

-- Register the hook for a single plugin
function M.__hook_plugin(plugin_spec)
	-- vim.notify("hooking " .. plugin_spec.name)
	vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
		group = augroup_name,
		pattern = { plugin_spec.dir .. "/*" }, --  TODO check if this works right recursively
		desc = "Automatically reload dev plugin " .. plugin_spec.name .. " on edit.",
		callback = function(cbtbl)
			vim.cmd(":Lazy reload " .. plugin_spec.name)

			-- Try to guess the module name
			local modName = plugin_spec.name:gsub(".nvim$", "")

			-- Run the plugin's devhook function if found
			local status, mod = pcall(require, modName)
			if status then
				if mod.devhook then
					mod.devhook()
				end
			else
				-- vim.notify(vim.inspect(require("snoozydev").state))
				-- Warn the user that we couldn't run the devhook, but only once
				if not require("snoozydev").state.has_warned[modName] then
					vim.notify("Warning: Could not run devhook:\nCould not require('" .. modName .. "') for plugin " .. plugin_spec.name, vim.log.levels.WARN, {title = "snoozydev.nvim"})
					require("snoozydev").state.has_warned[modName] = true
				end
			end
		end,
	})
end

-- A test dev hook
function M.devhook()
	vim.notify("this is snoozydev devhook!")
end

return M
