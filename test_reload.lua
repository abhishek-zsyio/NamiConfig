-- Initialize a dummy settings file
local f = io.open("lua/test_settings.lua", "w")
f:write("return { val = 1 }")
f:close()

package.path = "./lua/?.lua;" .. package.path

local s1 = require("test_settings")
print("s1:", s1.val)

-- Modify the file
f = io.open("lua/test_settings.lua", "w")
f:write("return { val = 2 }")
f:close()

-- Attempt to reload
package.loaded["test_settings"] = nil
local ok, s2 = pcall(require, "test_settings")
print("s2:", ok and s2.val or "error")

