<h1 align="center">PerfNvim</h1>

<p align="center">
  <b>Seamless Perforce integration for Neovim.</b><br>
  Effortlessly manage your Perforce workflow without leaving your editor.
</p>

<p align="center">
  <a href="https://github.com/guillemaru/perfnvim/stargazers"><img src="https://img.shields.io/github/stars/guillemaru/perfnvim?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/guillemaru/perfnvim/issues"><img src="https://img.shields.io/github/issues/guillemaru/perfnvim?style=flat-square" alt="Issues"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/guillemaru/perfnvim?style=flat-square" alt="License"></a>
</p>

---

## 🚀 Features

- 📄 **Add** current buffer to Perforce (`p4 add`)
- ✏️ **Edit** current buffer in Perforce (`p4 edit`)
- 🗂️ **Choose** between existing changelists, the Default one, or create a new one on the spot
- ♻️ **Revert** unchanged files
- 🔍 **Signs** in changed lines
- ⏩ **Navigate** between changed lines
- 🗃️ **View** checked out files using Telescope
- 🔎 **Grep** checked out files using Telescope

---

<p align="center">
  <img src="./perfnvim1.gif" width="600" alt="Demo: Add current buffer to Perforce"/>
  <br>
  <em>Demo: Add current buffer to Perforce</em>
</p>

<p align="center">
  <img src="./perfnvim2.gif" width="600" alt="Demo: View checked out files using Telescope"/>
  <br>
  <em>Demo: View checked out files using Telescope</em>
</p>

<p align="center">
  <img src="./perfnvim3.gif" width="600" alt="Demo: Signs in changed lines"/>
  <br>
  <em>Demo: Signs in changed lines</em>
</p>

---

> ⭐ **Like PerfNvim?** Star this repo and share it with your fellow Neovim users!

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
<details>
  <summary>Add the following to your `init.lua` or equivalent configuration file:
</summary>

  ```lua
  {
      "guillemaru/perfnvim",
      config = function()
          require("perfnvim").setup()

          vim.keymap.set("n", "<leader>pa", function() require("perfnvim").P4add() end, { noremap = true, silent = true, desc = "'p4 add' current buffer" })
          vim.keymap.set("n", "<leader>pe", function() require("perfnvim").P4edit() end, { noremap = true, silent = true, desc = "'p4 edit' current buffer" })
          vim.keymap.set("n", "<leader>pR", ":!p4 revert -a %<CR>", { noremap = true, silent = true, desc = "Revert if unchanged" })
          vim.keymap.set("n", "<leader>pn", function() require("perfnvim").P4next() end, { noremap = true, silent = true, desc = "Jump to next changed line" })
          vim.keymap.set("n", "<leader>pp", function() require("perfnvim").P4prev() end, { noremap = true, silent = true, desc = "Jump to previous changed line" })
          vim.keymap.set("n", "<leader>po", function() require("perfnvim").P4opened() end, { noremap = true, silent = true, desc = "'p4 opened' (telescope)" })
          vim.keymap.set("n", "<leader>pg", function() require("perfnvim").P4grep() end, { noremap = true, silent = true, desc = "grep p4 files" })
      end
  }
  ```
</details>


### Using [vim-plug](https://github.com/junegunn/vim-plug)
<details>
  <summary>Add the following to your `init.vim`:
</summary>

  ```vim
  " If using init.vim
  call plug#begin('~/.config/nvim/plugged')

  Plug 'guillemaru/perfnvim'

  call plug#end()

  lua << EOF
  require("perfnvim").setup()

  vim.keymap.set("n", "<leader>pa", function() require("perfnvim").P4add() end, { noremap = true, silent = true, desc = "'p4 add' current buffer" })
  vim.keymap.set("n", "<leader>pe", function() require("perfnvim").P4edit() end, { noremap = true, silent = true, desc = "'p4 edit' current buffer" })
  vim.keymap.set("n", "<leader>pR", ":!p4 revert -a %<CR>", { noremap = true, silent = true, desc = "Revert if unchanged" })
  vim.keymap.set("n", "<leader>pn", function() require("perfnvim").P4next() end, { noremap = true, silent = true, desc = "Jump to next changed line" })
  vim.keymap.set("n", "<leader>pp", function() require("perfnvim").P4prev() end, { noremap = true, silent = true, desc = "Jump to previous changed line" })
  vim.keymap.set("n", "<leader>po", function() require("perfnvim").P4opened() end, { noremap = true, silent = true, desc = "'p4 opened' (telescope)" })
  vim.keymap.set("n", "<leader>pg", function() require("perfnvim").P4grep() end, { noremap = true, silent = true, desc = "grep p4 files" })
  EOF
  ```
</details>

## Recommended Key Mappings

- `<leader>pa`: `'p4 add'` current buffer
- `<leader>pe`: `'p4 edit'` current buffer
- `<leader>pR`: Revert if unchanged
- `<leader>pn`: Jump to next changed line
- `<leader>pp`: Jump to previous changed line
- `<leader>po`: `'p4 opened'` (telescope)
- `<leader>pg`: grep p4 files (telescope)

These key mappings are designed to enhance your workflow by providing quick access to common Perforce commands. Feel free to customize them to your liking.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.
