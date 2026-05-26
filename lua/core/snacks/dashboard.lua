return {
  preset = {
    header = [[
   _   __               _         
  / | / /___ _____ ___ (_)____    
 /  |/ / __ `/ __ `__ \/ / __ \   
/ /|  / /_/ / / / / / / / / / /   
/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/    
                                  
   Ultimate Dev Environment
    ]],
    keys = {
      { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
      { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
      { icon = " ", key = "p", desc = "Restore Session", action = ":lua require('persistence').load()" },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
  },
}
