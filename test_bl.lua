local bl = require("bufferline")
bl.setup({
  highlights = function()
    print("Highlights function was called!")
    return { fill = { bg = "#ff0000" } }
  end
})
