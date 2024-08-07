return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  -- {
   --  "neovim/nvim-lspconfig",
    -- config = function()
      -- require("nvchad.configs.lspconfig").defaults()
      -- require "configs.lspconfig"
     --end,
   --},
  
  {
  	"williamboman/mason.nvim",
  	opts = {
  		ensure_installed = {
 			"lua-language-server", "stylua",
  			"html-lsp", "css-lsp" , "prettier"
   		},
   	},
   },
  
  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css"
  		},
  	},
  },
  {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  },
 {
  "gbprod/yanky.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    }
  },
}
