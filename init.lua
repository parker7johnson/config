-- init.lua

-- Basic settings
vim.opt.relativenumber = true  -- Enable relative line numbers
vim.opt.number = true          -- Show current line number
vim.opt.tabstop = 2            -- Number of spaces tabs count for
vim.opt.shiftwidth = 2         -- Size of an indent
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.smartindent = true     -- Insert indents automatically
vim.opt.wrap = false           -- Don't wrap lines
vim.opt.swapfile = false       -- Don't use swapfile
vim.opt.backup = false         -- Don't create backup files
vim.opt.undofile = true        -- Persistent undo
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')  -- Undo directory
vim.opt.hlsearch = false       -- Don't highlight search results
vim.opt.incsearch = true       -- Show search results as you type
vim.opt.termguicolors = true   -- True color support
vim.opt.scrolloff = 8          -- Lines of context
vim.opt.updatetime = 50        -- Faster completion
vim.opt.colorcolumn = "80"     -- Line length marker

-- Install Packer automatically if not installed
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- Plugin management with Packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  
  -- Rose Pine theme
  use({
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
      require('rose-pine').setup({
        dark_variant = 'moon',
        bold_vert_split = false,
        dim_nc_background = false,
        disable_background = false,
        disable_float_background = false,
        disable_italics = false,
      })
      vim.cmd('colorscheme rose-pine')
    end
  })
  
  -- Treesitter for better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "go", "typescript", "python", "java", "lua", "vim" },
        highlight = {
          enable = true,
        },
      }
    end
  }
  
  -- LSP
  use 'neovim/nvim-lspconfig'            -- LSP configurations
  use 'williamboman/mason.nvim'          -- Package manager for LSP servers
  use 'williamboman/mason-lspconfig.nvim' -- Bridge between mason and lspconfig
  
  -- Autocompletion
  use 'hrsh7th/nvim-cmp'         -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'     -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'       -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'         -- Path source for nvim-cmp
  use 'L3MON4D3/LuaSnip'         -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip' -- Luasnip source for nvim-cmp
  
  -- File explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      require("nvim-tree").setup()
    end
  }
  
  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'rose-pine'
        }
      }
    end
  }
  
  -- Git integration
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }
end)

-- Set <space> as the leader key
vim.g.mapleader = ' '
-- LSP Setup
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Buffer local mappings.
  local opts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<space>f', function() 
    vim.lsp.buf.format { async = true } 
  end, opts)
end

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "ts_ls", "pyright", "jdtls" }
})

-- LSP configuration
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Go LSP
lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- TypeScript LSP
lspconfig.ts_ls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Python LSP
lspconfig.pyright.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Java LSP (basic setup - jdtls typically requires more complex configuration)
lspconfig.jdtls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Setup nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

-- Telescope keymaps
local telescope_loaded, telescope = pcall(require, 'telescope.builtin')
if telescope_loaded then
  vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
  vim.keymap.set('n', '<leader>fg', telescope.live_grep, {})
  vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
  vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})
end

-- NvimTree keymaps
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })-- init.lua

-- Basic settings
vim.opt.relativenumber = true  -- Enable relative line numbers
vim.opt.number = true          -- Show current line number
vim.opt.tabstop = 2            -- Number of spaces tabs count for
vim.opt.shiftwidth = 2         -- Size of an indent
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.smartindent = true     -- Insert indents automatically
vim.opt.wrap = false           -- Don't wrap lines
vim.opt.swapfile = false       -- Don't use swapfile
vim.opt.backup = false         -- Don't create backup files
vim.opt.undofile = true        -- Persistent undo
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')  -- Undo directory
vim.opt.hlsearch = false       -- Don't highlight search results
vim.opt.incsearch = true       -- Show search results as you type
vim.opt.termguicolors = true   -- True color support
vim.opt.scrolloff = 8          -- Lines of context
vim.opt.updatetime = 50        -- Faster completion
vim.opt.colorcolumn = "80"     -- Line length marker

-- Install Packer automatically if not installed
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- Plugin management with Packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  
  -- Rose Pine theme
  use({
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
      require('rose-pine').setup({
        dark_variant = 'moon',
        bold_vert_split = false,
        dim_nc_background = false,
        disable_background = false,
        disable_float_background = false,
        disable_italics = false,
      })
      vim.cmd('colorscheme rose-pine')
    end
  })
  
  -- Treesitter for better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "go", "typescript", "python", "java", "lua", "vim" },
        highlight = {
          enable = true,
        },
      }
    end
  }
  
  -- LSP
  use {
    'neovim/nvim-lspconfig',            -- LSP configurations
    'williamboman/mason.nvim',          -- Package manager for LSP servers
    'williamboman/mason-lspconfig.nvim', -- Bridge between mason and lspconfig
  }
  
  -- Autocompletion
  use {
    'hrsh7th/nvim-cmp',         -- Completion engine
    'hrsh7th/cmp-nvim-lsp',     -- LSP source for nvim-cmp
    'hrsh7th/cmp-buffer',       -- Buffer source for nvim-cmp
    'hrsh7th/cmp-path',         -- Path source for nvim-cmp
    'L3MON4D3/LuaSnip',         -- Snippet engine
    'saadparwaiz1/cmp_luasnip', -- Luasnip source for nvim-cmp
  }
  
  -- File explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      require("nvim-tree").setup()
    end
  }
  
  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'rose-pine'
        }
      }
    end
  }
  
  -- Git integration
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }
end)

-- LSP Setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "ts_ls", "pyright", "jdtls" }
})

-- LSP configuration
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Go LSP
lspconfig.gopls.setup {
  capabilities = capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- TypeScript LSP
lspconfig.ts_ls.setup {
  capabilities = capabilities,
}

-- Python LSP
lspconfig.pyright.setup {
  capabilities = capabilities,
}

-- Java LSP (basic setup - jdtls typically requires more complex configuration)
lspconfig.jdtls.setup {
  capabilities = capabilities,
}

-- Global mappings
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Setup nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-space>'] = cmp.mapping.complete(),
    ['<cr>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<s-tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

-- telescope keymaps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- nvimtree keymaps
--vim.keymap.set('n', '<leader>e', ':nvimtreetoggle<cr>', { noremap = true, silent = true })

-- set <space> as the leader key
vim.g.mapleader = ' ' return {
    "neovim/nvim-lspconfig",
    config = function() end,
}
