A "plugin" for the Lazy package manager that automatically reloads your dev plugins as you edit them.

# Features

- Any plugins marked `dev = true` in your lazy config will be automatically reloaded as you edit them.
- If your plugin exports a function called `devhook` on its root module, that function will be called on every reload.
  This is useful for setting up "development only" keybinds or settings.

# Setup

Just run the "setup" function to enable auto-reloading on "dev" plugins.

```lua
require("snoozydev").setup()
```

# Default config values
```lua
require("snoozydev").setup({
	enabled = true,
	-- No other config items atm, but maybe someday.
})
```

# The "devhook"

Usually when I'm developing a plugin, I have some temporary keybinds/maps I use to test a small feature or facet of the
plugin. I only want these keybinds to be active while I'm working on that plugin though.

By implementing a "devhook" on your plugin's root module, you can have these maps be created when you start developing
your plugin, and updated as you continue working on it.

To run the devhook, this plugin will try to guess what module it needs to "require", but if the module is too different
from the plugin name, it won't work. E.g. if your plugin name is "foobar" or "foorbar.nvim", we'll try to import
"foobar". I could add a config item to allow specifying the name to import, but that issue hasn't come up yet.

## Sample plugin with devhook
``` lua
M = {}

-- ... your main plugin code here ...

function M.devhook()
-- TODO add sample maps
end

return M
```

