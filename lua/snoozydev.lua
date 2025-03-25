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

local M = {
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

local function require_module(plugin_spec, modName, callback)
	local status, mod = pcall(require, modName)
	if status then
		callback(mod)
	else
		local state = require('snoozydev').state
		-- vim.notify(vim.inspect(require("snoozydev").state))
		-- Warn the user that we couldn't run the devhook, but only once
		if not state.has_warned[modName] then
			vim.notify("Warning: Could not run devhook:\nCould not require('" .. modName .. "') for plugin " .. plugin_spec.name, vim.log.levels.WARN, {title = "snoozydev.nvim"})
			state.has_warned[modName] = true
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
			-- Try to guess the module name
			local modName = plugin_spec.name:gsub(".nvim$", "")

			-- Run the plugin's pre-reload devhook function if found
			-- TODO maybe think of a better name for the hook than "devhook_pre_reload"
			require_module(plugin_spec, modName, function(mod)
				if mod.devhook_pre_reload then
					mod.devhook_pre_reload()
				end
			end)

			-- Reload the plugin
			vim.cmd(":Lazy reload " .. plugin_spec.name)

			-- Run the plugin's devhook function if found
			require_module(plugin_spec, modName, function(mod)
				if mod.devhook then
					mod.devhook()
				end
			end)
		end,
	})
end

-- A test dev hook
function M.devhook()
	vim.notify("this is snoozydev devhook!")
end

return M
