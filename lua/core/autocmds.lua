local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on Yank ─────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ── Restore cursor position on file open ─────────────────────────────────
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-resize splits when Neovim is resized ────────────────────────────
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ── Close certain filetypes with just 'q' ────────────────────────────────
autocmd("FileType", {
  group = augroup("QuickClose", { clear = true }),
  pattern = {
    "qf", "help", "man", "notify", "lspinfo",
    "spectre_panel", "startuptime", "tsplayground",
    "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- ── Strip trailing whitespace on save ────────────────────────────────────
autocmd("BufWritePre", {
  group = augroup("StripTrailingWS", { clear = true }),
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- ── Django HTML filetype detection (when in a Django project) ─────────────
local function in_django_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 1
end
if in_django_project() then
  autocmd({ "BufNewFile", "BufRead" }, {
    group = augroup("DjangoFiletype", { clear = true }),
    pattern = "*.html",
    callback = function()
      vim.bo.filetype = "htmldjango"
    end,
  })
end

-- ── Disable Dropbar for Snacks Picker ──────────────────────────────────────
autocmd("FileType", {
  group = augroup("DisableDropbar", { clear = true }),
  pattern = { "snacks_picker_list", "snacks_picker_input", "snacks_picker_preview", "snacks_layout_box", "snacks_terminal" },
  callback = function(event)
    vim.b[event.buf].dropbar_enable = false
  end,
})

-- ── Auto-Sync LeetCode Solutions to Git by Difficulty ───────────────────────
autocmd("BufWritePost", {
  group = augroup("LeetCodeGitSync", { clear = true }),
  pattern = { "*/leetcode/*", "*/leetcode/**/*" },
  callback = function(event)
    local filepath = event.match
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local ext = vim.fn.fnamemodify(filepath, ":e")
    
    -- Only sync actual solutions or descriptions, ignore directories/configs/subfolders
    if ext == "json" or ext == "cache" or filename == "cookie" or filename == "" then
      return
    end
    
    local leetcode_dir = vim.fn.expand("~/.local/share/nvim/leetcode")
    
    -- Prevent infinite loop: if the file being saved is already inside a difficulty folder, return
    local relative_path = filepath:gsub(leetcode_dir .. "/", "")
    if relative_path:find("^easy/") or relative_path:find("^medium/") or relative_path:find("^hard/") or relative_path:find("^other/") then
      return
    end

    -- Determine difficulty
    local difficulty = "other"
    local ok_utils, utils = pcall(require, "leetcode.utils")
    if ok_utils then
      local ok_q, q = pcall(utils.curr_question)
      if ok_q and q and q.q and q.q.difficulty then
        difficulty = q.q.difficulty:lower()
      end
    end

    local diff_dir = leetcode_dir .. "/" .. difficulty
    local target_path = diff_dir .. "/" .. filename

    -- Ensure the difficulty directory exists
    vim.fn.mkdir(diff_dir, "p")

    -- Copy the file to the difficulty folder
    local infile = io.open(filepath, "r")
    if infile then
      local content = infile:read("*a")
      infile:close()
      local outfile = io.open(target_path, "w")
      if outfile then
        outfile:write(content)
        outfile:close()
      end
    end

    -- Stage changes: Stage the target file, remove the root file from Git, and delete it from root filesystem
    vim.system({ "git", "add", difficulty .. "/" .. filename }, { cwd = leetcode_dir }, function(obj)
      if obj.code ~= 0 then return end
      
      -- Remove the root file from filesystem and Git
      os.remove(filepath)
      vim.system({ "git", "rm", "-f", filename }, { cwd = leetcode_dir }, function(obj_rm)
        
        local commit_msg = "sync: solved " .. filename .. " [" .. difficulty:upper() .. "]"
        vim.system({ "git", "commit", "-m", commit_msg }, { cwd = leetcode_dir }, function(obj2)
          -- Always push to remote regardless of whether git commit was clean or had new changes
          vim.system({ "git", "push", "origin", "main" }, { cwd = leetcode_dir }, function(obj3)
            if obj3.code == 0 then
              vim.schedule(function()
                -- Notify only if new changes were actually committed
                if obj2.code == 0 then
                  vim.notify(("LeetCode %s solution pushed to GitHub!"):format(difficulty:upper()), vim.log.levels.INFO, { title = "Git Sync" })
                end
              end)
            else
              vim.schedule(function()
                local err_msg = obj3.stderr or "Unknown Git push error"
                vim.notify("Failed to push LeetCode solution to GitHub:\n" .. err_msg, vim.log.levels.ERROR, { title = "Git Sync Error" })
              end)
            end
          end)
        end)
      end)
    end)
  end,
})
