# ⚡ NamiConfig Cheat Sheet

> Press `<leader>` (Space) and wait for the **which-key** panel for real-time guides.

---

## 💻 Modifier Keys

| Modifier | Description | Mac OS | Linux / Win |
|:---|:---|:---|:---|
| `<leader>` | **Primary prefix key** | `Space` | `Space` |
| `<C-...>` | **Ctrl combinations** | `Control` | `Ctrl` |
| `<A-...>` | **Alt / Option combinations** | `Option` | `Alt` |
| `<S-...>` | **Shift combinations** | `Shift` | `Shift` |

---

## 🧭 Core & Navigation

| Key | Mode | Action | Description |
|:---|:---|:---|:---|
| `jk` | `Insert` | **Escape** | Swiftly escape to Normal mode |
| `;` | `Normal` | **Command** | Enters command line mode (saves shift-press) |
| `<Esc>` | `Normal` | **No Highlight** | Clears search term matches on screen |
| `<C-s>` | `Normal` | **Save** | Writes current buffer to disk |
| `<C-q>` | `Normal` | **Quit Window** | Closes active pane / window |
| `<leader>th` | `Normal` | **Theme Switcher**| Syncs Ghostty and saves to `settings.lua` |
| `<leader>n` | `Normal` | **Line Numbers** | Toggles standard line numbers in gutter |
| `<leader>rn` | `Normal` | **Relative Numbers**| Toggles relative number gutter |
| `<leader>tc` | `Normal` | **Sticky Headers** | Toggles `treesitter-context` sticky lines |
| `<leader>ch` | `Normal` | **Cheat Sheet** | Opens this overlay guide (Read-only) |
| `<leader>ce` | `Normal` | **Edit Cheatsheet**| Edits this cheatsheet file directly |

---

## 📁 Files & Explorer

| Key | Mode | Action | Description |
|:---|:---|:---|:---|
| `<leader>e` | `Normal` | **Focus Tree** | Toggles or focuses the file explorer side panel |
| `<C-n>` | `Normal` | **Toggle Tree** | Toggles file explorer visibility |
| `<leader>ff` | `Normal` | **Find Files** | Fast file search via Snacks Picker |
| `<leader>fw` | `Normal` | **Grep Words** | Greps words globally in directory |
| `<leader>fr` | `Normal` | **Recent Files**| Opens interactive list of recent files |
| `<leader>fb` | `Normal` | **Find Buffers**| Lists active editor buffers |

---

## 🪟 Windows & Buffers

| Key | Mode | Action | Description |
|:---|:---|:---|:---|
| `<C-h>` | `Normal/Term` | **Window Left** | Shifts focus to left split pane |
| `<C-j>` | `Normal/Term` | **Window Down** | Shifts focus to bottom split pane |
| `<C-k>` | `Normal/Term` | **Window Up** | Shifts focus to top split pane |
| `<C-l>` | `Normal/Term` | **Window Right**| Shifts focus to right split pane |
| `<Tab>` | `Normal` | **Next Buffer** | Rotates to next file tab |
| `<S-Tab>` | `Normal` | **Prev Buffer** | Rotates to previous file tab |
| `<leader>x` | `Normal` | **Close Buffer** | Safely deletes active buffer pane |

---

## 🖥️ Terminals

| Key | Mode | Action | Layout |
|:---|:---|:---|:---|
| `<C-`>` | `Normal/Term` | **Floating Term** | Center modal popup terminal |
| `<A-h>` | `Normal/Term` | **Bottom Term** | Split window bottom pane (Height 15) |
| `<A-v>` | `Normal/Term` | **Vertical Term** | Split window right pane (Width 40%) |

---

## 🛠️ Code Editing & LSP

| Key | Mode | Action | Description |
|:---|:---|:---|:---|
| `<leader>/` | `Normal/Visual`| **Comment line**| Toggles commenting for lines/blocks |
| `<A-j>` | `Normal/Ins/Vis`| **Move Line Down**| Shifts current line or visual block down |
| `<A-k>` | `Normal/Ins/Vis`| **Move Line Up**| Shifts current line or visual block up |
| `<` / `>` | `Visual` | **Smart Indent**| Indents selected code block (keeps visual active)|
| `<leader>fm` | `Normal` | **LSP Format** | Formats buffer via attached language server |
| `<leader>cf` | `Normal` | **Registry Format**| Formats buffer via Conform.nvim |
| `gd` | `Normal` | **Go Definition**| Jumps to definition of active symbol |
| `gD` | `Normal` | **Go Declaration**| Jumps to declaration of active symbol |
| `gi` | `Normal` | **Go Impl** | Jumps to active symbol implementation |
| `gr` | `Normal` | **Go References**| Lists symbol references in interactive picker |
| `K` | `Normal` | **Hover Docs** | Opens documentation window for symbol |
| `<leader>ca` | `Normal` | **Code Actions** | Opens LSP quick-fixes & code actions |
| `<leader>ra` | `Normal` | **Rename Symbol**| Renames active symbol and updates references |
| `<leader>ds` | `Normal` | **Diagnostics** | Lists LSP diagnostics in telescope |

---

## 🏆 LeetCode (kawre/leetcode.nvim)

| Key | Mode | Action | Description |
|:---|:---|:---|:---|
| `<leader>lc` | `Normal` | **Dashboard** | Opens native LeetCode question console |
| `<leader>lr` | `Normal` | **Run Test** | Auto-saves and runs active tests asynchronously |
| `<leader>ls` | `Normal` | **Submit** | Auto-saves and submits solution asynchronously |
| `<leader>ld` | `Normal` | **Description** | Splits open or toggles question statement panel |
| `<leader>li` | `Normal` | **Stats/Info** | Opens statistic overlays for selected problem |

---

> 💡 **Tip**: Navigation arrow keys are **intentionally disabled** in standard normal/insert modes to help you practice proper Vim movements (`h/j/k/l`). Keep at it!
