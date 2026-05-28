local M = {}

function M.wrap_settings(raw_settings)
	return setmetatable(raw_settings, {
		__index = function(self, key)
			-- 1. Check if key is directly on the top level
			if rawget(self, key) ~= nil then
				return rawget(self, key)
			end

			-- 2. Handle flat to grouped translations if any key was renamed
			local translations = {

				show_hidden_files = self.explorer.show_hidden,
				file_explorer_position = self.explorer.position,
				enable_linting = self.linting.enable,
				enable_project_config = self.project.enable_config,
				lsp_servers = self.custom_tools.lsp_servers,
				mason_tools = self.custom_tools.mason_tools,
				picker_layout = self.ui.picker.layout,
				picker_width = self.ui.picker.width,
				picker_height = self.ui.picker.height,
				menu_border = self.ui.picker.border,
				neovide_transparency = self.ui.neovide.transparency,
				line_height = self.ui.neovide.line_height,
			}
			if translations[key] ~= nil then
				return translations[key]
			end

			-- 3. Traverse nested groups to find the key (for identical names like highlight_current_line)
			local function find_key(t, k)
				if type(t) ~= "table" then
					return nil
				end
				if rawget(t, k) ~= nil then
					return rawget(t, k)
				end
				for sub_key, v in pairs(t) do
					if type(v) == "table" and sub_key ~= "extras" and sub_key ~= "lsp_servers" and sub_key ~= "mason_tools" then
						local res = find_key(v, k)
						if res ~= nil then
							return res
						end
					end
				end
				return nil
			end

			return find_key(self, key)
		end,
		__newindex = function(self, key, value)
			-- Ensure writes to theme update the nested ui.theme correctly (for the theme switcher)
			if key == "theme" then
				self.ui.theme = value
			else
				rawset(self, key, value)
			end
		end,
	})
end

function M.load()
	-- Clear require cache to force fresh load of raw config file
	package.loaded["settings"] = nil
	local ok, raw = pcall(require, "settings")
	if not ok then
		raw = {}
	end
	local wrapped = M.wrap_settings(raw)
	package.loaded["settings"] = wrapped
	return wrapped
end

return M
