vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.termguicolors = true
o.signcolumn = "yes"
o.ignorecase = true
o.smartcase = true
o.clipboard = "unnamedplus"

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Theme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({ theme = "wave" })
      vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- Syntax (helm + go_template parsers are the important ones here)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "yaml", "helm", "gotmpl", "lua", "bash", "json", "markdown", "dockerfile" },
        sync_install = true, -- block until parsers are compiled (needed for headless setup)
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP: helm-ls and yaml-language-server are installed by post-create.sh
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.enable({ "helm_ls" })
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(k, f) vim.keymap.set("n", k, f, { buffer = ev.buf }) end
          map("gd", vim.lsp.buf.definition)
          map("K", vim.lsp.buf.hover)
          map("<leader>rn", vim.lsp.buf.rename)
          map("<leader>ca", vim.lsp.buf.code_action)
        end,
      })
    end,
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        yaml = { "yamllint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- Fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local b = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", b.find_files)
      vim.keymap.set("n", "<leader>fg", b.live_grep)
    end,
  },
})
