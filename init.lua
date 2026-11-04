-- =============================================================================
--  init.lua — Neovim (arquivo único)
-- =============================================================================
--  ÍNDICE  (busque com  /\[N\]  — ex.: /\[5.6\] )
--
--    [1]   BASE ................ log do LSP e tecla leader
--    [2]   OPTIONS ............. opções do editor
--    [3]   KEYMAPS ............. atalhos globais
--    [4]   TEMAS ............... lista de temas, ajustes do koda, :Theme
--    [5]   LAZY.NVIM ........... bootstrap e lista de plugins
--      [5.1]  bootstrap
--      [5.2]  libs
--      [5.3]  temas (plugins)
--      [5.4]  interface (alpha, bufferline, lualine, nvim-tree, oil, extras)
--      [5.5]  edição (treesitter, blink.cmp, conform, autopairs, surround, cloak...)
--      [5.6]  navegação (telescope, trouble)
--      [5.7]  LSP (lspconfig, mason)
--      [5.8]  debugger (dap, dap-ui, dap-virtual-text)
--    [6]   INICIALIZAÇÃO ....... aplica o tema salvo
-- =============================================================================

-- =============================================================================
-- [1] BASE
-- =============================================================================

vim.lsp.log.set_level(vim.log.levels.ERROR)

-- interface nova de mensagens/cmdline do Neovim 0.12 (experimental; se der
-- problema depois de uma atualização, é só comentar este bloco)
pcall(function()
	require("vim._core.ui2").enable()
end)

-- precisa vir antes do lazy (atalhos com <leader> dependem disso)
vim.g.mapleader = " "

-- =============================================================================
-- [2] OPTIONS
-- =============================================================================

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. (vim.env.PATH or "")

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs / indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

-- margens de rolagem
opt.scrolloff = 8 -- mantém 8 linhas visíveis acima/abaixo do cursor
opt.sidescrolloff = 16 -- idem nas laterais (útil com wrap desligado)

-- sem swapfile/backup; undo persistente (sobrevive ao fechar o arquivo)
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- guia de coluna por linguagem (segue o limite do formatador de cada uma)
local colorcolumn_by_ft = {
	c = "100",
	cpp = "100",
	objc = "100",
	objcpp = "100",
	python = "88",
	javascript = "80",
	javascriptreact = "80",
	typescript = "80",
	typescriptreact = "80",
	json = "80",
	lua = "120",
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("VictorColorColumn", { clear = true }),
	callback = function(args)
		vim.opt_local.colorcolumn = colorcolumn_by_ft[args.match] or ""
	end,
})
opt.updatetime = 250

vim.filetype.add({
	extension = {
		h = "c",
		hpp = "cpp",
	},
})

-- =============================================================================
-- [3] KEYMAPS
-- =============================================================================

local keymap = vim.keymap

keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "<C-d>", "<C-d>zz")

-- pequenos ajustes de comportamento
keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous match (centered)" })
keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting clipboard" })
keymap.set("n", "<BS>", "<C-^>", { desc = "Go to alternate file" })
keymap.set("n", "Q", "<nop>")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase height" })
keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease height" })
keymap.set("n", "<C-Left>", ":vertical resize -4<CR>", { desc = "Narrower" })
keymap.set("n", "<C-Right>", ":vertical resize +4<CR>", { desc = "Wider" })

-- tab / buffer management
keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer" })
keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to previous buffer" })
keymap.set("n", "<leader>x", "<cmd>Bdelete<CR>", { desc = "Close current buffer" })
keymap.set("n", "<leader>n", "<cmd>tabnew<CR>", { desc = "New tab" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- LSP via telescope
keymap.set("n", "<leader>ci", "<cmd>Telescope lsp_incoming_calls<CR>")
keymap.set("n", "<leader>co", "<cmd>Telescope lsp_outgoing_calls<CR>")
keymap.set("n", "<leader>ch", "<cmd>Telescope lsp_implementations<CR>")
keymap.set("n", "<leader>cu", "<cmd>Telescope lsp_references<CR>")

-- themes (comandos definidos em [4])
keymap.set("n", "<leader>ts", "<cmd>Theme<CR>", { desc = "Select theme" })
keymap.set("n", "<leader>tn", "<cmd>ThemeNext<CR>", { desc = "Next theme" })
keymap.set("n", "<leader>tp", "<cmd>ThemePrev<CR>", { desc = "Previous theme" })

-- terminal related
keymap.set("t", "<Esc>", [[<C-\><C-n>]])

keymap.set("n", "<leader>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("L")
	vim.api.nvim_win_set_width(0, 80)
	vim.cmd.startinsert()
end, { desc = "Open terminal in vertical split" })

-- (o <C-n> do explorer está em [5.4], na seção do nvim-tree)

-- =============================================================================
-- [4] TEMAS
-- =============================================================================

-- ----- [4.1] lista de temas (repo do plugin + nomes dos colorschemes) --------

local colorschemes = {}

colorschemes.items = {
	{
		repo = "oskarnurm/koda.nvim",
		schemes = { "koda", "koda-dark", "koda-light", "koda-glade", "koda-moss" },
	},
	{
		repo = "andreypopp/vim-colors-plain",
		schemes = { "plain", "plain-cterm" },
	},
	{
		repo = "catppuccin/nvim",
		name = "catppuccin",
		schemes = {
			"catppuccin",
			"catppuccin-latte",
			"catppuccin-frappe",
			"catppuccin-macchiato",
			"catppuccin-mocha",
		},
	},
	{
		repo = "ellisonleao/gruvbox.nvim",
		schemes = { "gruvbox" },
	},
}

function colorschemes.names()
	local names = {}

	for _, item in ipairs(colorschemes.items) do
		vim.list_extend(names, item.schemes)
	end

	return names
end

-- ----- [4.2] ajustes de cor do koda (fundo/linha por variante) ---------------

local koda = {}

local koda_variant_overrides = {
	dark = {
		bg = "#090909",
		line = "#1a1a1a",
	},
	moss = {
		bg = "#090d0e",
		line = "#151d1e",
	},
}

local function koda_variant_for(name)
	if name == "koda-dark" then
		return "dark"
	end

	if name == "koda-moss" then
		return "moss"
	end

	if name == "koda" then
		return vim.o.background == "light" and "light" or "dark"
	end

	if name == "koda-light" then
		return "light"
	end

	if name == "koda-glade" then
		return "glade"
	end

	return nil
end

function koda.setup(name)
	local variant = koda_variant_for(name)
	if not variant then
		return
	end

	require("koda").setup({
		auto = false,
		colors = koda_variant_overrides[variant] or {},
	})
end

-- ----- [4.3] gerenciador de temas (:Theme, :ThemeNext, :ThemePrev) -----------

local theme = {}

local theme_config = {
	themes = colorschemes.names(),
	default = "koda",
	state_file = vim.fn.stdpath("state") .. "/theme.txt",
}

local function theme_index_of(name)
	for i, t in ipairs(theme_config.themes) do
		if t == name then
			return i
		end
	end

	return nil
end

local function theme_persist(name)
	local dir = vim.fn.fnamemodify(theme_config.state_file, ":h")
	vim.fn.mkdir(dir, "p")
	vim.fn.writefile({ name }, theme_config.state_file)
end

local function theme_read_persisted()
	if vim.fn.filereadable(theme_config.state_file) == 0 then
		return nil
	end

	local lines = vim.fn.readfile(theme_config.state_file)
	return lines[1]
end

local function theme_apply(name, opts)
	opts = opts or {}

	if not theme_index_of(name) then
		vim.notify(("Unknown theme: %s"):format(name), vim.log.levels.ERROR)
		return false
	end

	koda.setup(name)

	local ok, err = pcall(vim.cmd.colorscheme, name)
	if not ok then
		vim.notify(("Failed to load theme %s: %s"):format(name, err), vim.log.levels.ERROR)
		return false
	end

	if opts.persist ~= false then
		theme_persist(name)
	end

	if opts.notify then
		vim.notify(("Theme: %s"):format(name), vim.log.levels.INFO)
	end

	return true
end

function theme.names()
	return vim.deepcopy(theme_config.themes)
end

function theme.current()
	return vim.g.colors_name
end

function theme.set(name, opts)
	return theme_apply(name, opts)
end

function theme.cycle(step)
	step = step or 1

	local current = theme.current()
	local current_index = theme_index_of(current) or theme_index_of(theme_config.default) or 1
	local next_index = ((current_index - 1 + step) % #theme_config.themes) + 1

	return theme_apply(theme_config.themes[next_index], { notify = true })
end

function theme.select()
	vim.ui.select(theme_config.themes, {
		prompt = "Select theme",
		format_item = function(item)
			if item == theme.current() then
				return item .. " (current)"
			end

			return item
		end,
	}, function(choice)
		if choice then
			theme_apply(choice, { notify = true })
		end
	end)
end

function theme.load()
	local name = theme_read_persisted() or theme_config.default

	if theme_apply(name, { persist = false }) then
		return
	end

	if name ~= theme_config.default then
		theme_apply(theme_config.default)
	end
end

function theme.setup(opts)
	theme_config = vim.tbl_deep_extend("force", theme_config, opts or {})

	vim.api.nvim_create_user_command("Theme", function(command_opts)
		if command_opts.args == "" then
			theme.select()
			return
		end

		theme.set(command_opts.args, { notify = true })
	end, {
		nargs = "?",
		complete = function(arg_lead)
			return vim.tbl_filter(function(t)
				return t:find(arg_lead, 1, true) == 1
			end, theme_config.themes)
		end,
		desc = "Select or set the active theme",
	})

	vim.api.nvim_create_user_command("ThemeNext", function()
		theme.cycle(1)
	end, { desc = "Cycle to the next theme" })

	vim.api.nvim_create_user_command("ThemePrev", function()
		theme.cycle(-1)
	end, { desc = "Cycle to the previous theme" })

	theme.load()
end

-- =============================================================================
-- [5] LAZY.NVIM
-- =============================================================================

-- ----- [5.1] bootstrap -------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- specs dos plugins de tema, gerados a partir de colorschemes.items ([4.1])
local colorscheme_specs = vim.tbl_map(function(item)
	local spec = {
		item.repo,
		lazy = true,
		priority = 1000,
	}

	if item.name then
		spec.name = item.name
	end

	return spec
end, colorschemes.items)

require("lazy").setup({

	-- =========================================================================
	-- [5.2] libs
	-- =========================================================================
	"nvim-lua/plenary.nvim",

	-- =========================================================================
	-- [5.3] temas (plugins)
	-- =========================================================================
	colorscheme_specs,

	-- =========================================================================
	-- [5.4] interface
	-- =========================================================================

	-- ----- alpha (dashboard inicial) -----------------------------------------
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Set header
			dashboard.section.header.val = {
				[[                                                                     ]],
				[[       ███████████           █████      ██                     ]],
				[[      ███████████             █████                             ]],
				[[      ████████████████ ███████████ ███   ███████     ]],
				[[     ████████████████ ████████████ █████ ██████████████   ]],
				[[    █████████████████████████████ █████ █████ ████ █████   ]],
				[[  ██████████████████████████████████ █████ █████ ████ █████  ]],
				[[ ██████  ███ █████████████████ ████ █████ █████ ████ ██████ ]],
				[[ ██████   ██  ███████████████   ██ █████████████████ ]],
				[[ ██████   ██  ███████████████   ██ █████████████████ ]],
			}

			-- Set menu
			dashboard.section.buttons.val = {
				dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
				dashboard.button("f", " > Find file", "<cmd>Telescope find_files<CR>"),
				dashboard.button("<C-n>", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
				dashboard.button("SPC fw", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
				dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
			}

			-- Send config to alpha
			alpha.setup(dashboard.opts)

			-- Disable folding on alpha buffer
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("VictorAlpha", { clear = true }),
				pattern = "alpha",
				callback = function()
					vim.opt_local.foldenable = false
				end,
			})
		end,
	},

	-- ----- bufferline (abas de buffers) --------------------------------------
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },

		config = function()
			local bufferline = require("bufferline")

			local function hl(name)
				return vim.api.nvim_get_hl(0, { name = name, link = false })
			end

			local function fg_or_nil(group)
				local value = hl(group)
				return value and value.fg or nil
			end

			local function sync_fill_highlight()
				local normal = hl("Normal")
				local fill_bg = normal and normal.bg

				if fill_bg then
					vim.api.nvim_set_hl(0, "BufferLineFill", { bg = fill_bg })
				end
			end

			local function sync_tab_highlights()
				local normal = hl("Normal")
				local tabline = hl("TabLine")
				local tabline_sel = hl("TabLineSel")

				if not normal then
					return
				end

				local base_bg = normal.bg
				local base_fg = (tabline and tabline.fg) or normal.fg
				local cursorline = hl("CursorLine")
				local selected_bg = (cursorline and cursorline.bg) or (tabline_sel and tabline_sel.bg) or base_bg
				local selected_fg = (tabline_sel and tabline_sel.fg) or normal.fg

				vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = base_bg, fg = base_fg })
				vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = base_bg, fg = base_fg })
				vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = selected_bg, fg = selected_fg, bold = true })
				vim.api.nvim_set_hl(0, "BufferLineDuplicate", { bg = base_bg, fg = base_fg })
				vim.api.nvim_set_hl(0, "BufferLineDuplicateVisible", { bg = base_bg, fg = base_fg })
				vim.api.nvim_set_hl(
					0,
					"BufferLineDuplicateSelected",
					{ bg = selected_bg, fg = selected_fg, bold = true }
				)
				vim.api.nvim_set_hl(
					0,
					"BufferLineModified",
					{ bg = base_bg, fg = fg_or_nil("DiagnosticWarn") or base_fg }
				)
				vim.api.nvim_set_hl(
					0,
					"BufferLineModifiedVisible",
					{ bg = base_bg, fg = fg_or_nil("DiagnosticWarn") or base_fg }
				)
				vim.api.nvim_set_hl(
					0,
					"BufferLineModifiedSelected",
					{ bg = selected_bg, fg = fg_or_nil("DiagnosticWarn") or selected_fg }
				)
				vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = base_bg, fg = base_bg })
				vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { bg = base_bg, fg = base_bg })
				vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { bg = selected_bg, fg = selected_bg })
				vim.api.nvim_set_hl(
					0,
					"BufferLineIndicatorSelected",
					{ bg = selected_bg, fg = fg_or_nil("Special") or selected_fg }
				)
			end

			local options = {
				options = {
					mode = "buffers",
					separator_style = "thin",
					always_show_bufferline = true,
					sort_by = "insert_after_current",
					diagnostics = "nvim_lsp",
					modified_icon = "",
					show_buffer_close_icons = false,
					show_close_icon = false,
				},
			}

			bufferline.setup(options)
			sync_fill_highlight()
			sync_tab_highlights()

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("VictorBufferlineThemeSync", { clear = true }),
				callback = function()
					sync_fill_highlight()
					sync_tab_highlights()
				end,
			})

			-- Keymaps
			vim.keymap.set("n", "<leader>h", ":BufferLineMovePrev<CR>", { silent = true, desc = "Move buffer left" })
			vim.keymap.set("n", "<leader>l", ":BufferLineMoveNext<CR>", { silent = true, desc = "Move buffer right" })
		end,
	},

	-- ----- lualine (barra de status) -----------------------------------------
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status") -- to configure lazy pending updates count
			lualine.setup({
				options = {
					theme = "auto",
				},
				sections = {
					lualine_b = {
						{ "branch" },
						{ "diagnostics" },
					},
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
					lualine_z = {
						{ "location" },
						{
							function()
								return os.date("%H:%M")
							end,
						},
					},
				},
			})

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("VictorLualineThemeSync", { clear = true }),
				callback = function()
					lualine.refresh()
				end,
			})
		end,
	},

	-- ----- nvim-tree (explorer de arquivos) ----------------------------------
	{
		"nvim-tree/nvim-tree.lua",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local nvimtree = require("nvim-tree")

			nvimtree.setup({
				disable_netrw = true,
				hijack_directories = {
					enable = true,
					auto_open = true,
				},
				sync_root_with_cwd = true,
				respect_buf_cwd = false,
				update_focused_file = {
					enable = true,
					update_root = false,
				},
				view = {
					side = "left",
					width = 35,
					preserve_window_proportions = true,
				},
				actions = {
					open_file = {
						quit_on_open = false,
						resize_window = true,
					},
				},
				renderer = {
					highlight_opened_files = "all",
				},
				git = { enable = true },
				tab = {
					sync = {
						open = false,
						close = false,
						ignore = {},
					},
				},
			})

			local keymap = vim.keymap
			keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
			keymap.set("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
		end,
	},

	-- ----- oil (edita pastas como texto; "-" abre a pasta do arquivo atual) --
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Oil",
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
		},
		opts = {
			-- o nvim-tree continua sendo o explorer padrão ao abrir uma pasta
			default_file_explorer = false,
			view_options = {
				show_hidden = true,
			},
		},
	},

	-- ----- live-preview (servidor local com recarga automática, tipo o Live Server) --
	{
		"brianhuster/live-preview.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		cmd = "LivePreview",
		keys = {
			{ "<leader>ws", "<cmd>LivePreview start<CR>", desc = "Live preview: start server" },
			{ "<leader>wx", "<cmd>LivePreview close<CR>", desc = "Live preview: stop server" },
		},
	},

	-- ----- extras visuais ----------------------------------------------------

	-- dressing: UI melhor para vim.ui.input / vim.ui.select
	{ "stevearc/dressing.nvim", event = "VeryLazy" },

	-- highlight-colors: mostra um quadradinho com a cor de códigos como #ff0000
	-- (também aparece no menu de autocomplete, ver blink.cmp em [5.5])
	{
		"brenoprata10/nvim-highlight-colors",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-highlight-colors").setup({
				render = "virtual",
				virtual_symbol = "■",
				virtual_symbol_position = "inline", -- estilo VS Code
				enable_hex = true,
				enable_short_hex = true,
				enable_rgb = true,
				enable_hsl = true,
				enable_var_usage = true,
				enable_named_colors = true,
			})
		end,
	},

	-- smear-cursor: rastro animado do cursor
	{
		"https://github.com/sphamba/smear-cursor.nvim",
		config = function()
			require("smear_cursor").setup({
				-- enabled = false,
				cursor_color = "#ffffff",

				never_draw_over_target = true,

				smear_insert_mode = false,
				min_vertical_distance_smear = 2,
				min_horizontal_distance_smear = 2,

				time_interval = 17, -- ms
				stiffness = 0.9,
				trailing_stiffness = 0.4,
				damping = 0.99, -- stops bouncing

				-- anticipation = 0.2,
				-- distance_stop_animating = 0.6,
			})
		end,
	},

	-- satellite: barra de rolagem com marcadores
	{ "lewis6991/satellite.nvim", opts = {} },

	-- =========================================================================
	-- [5.5] edição
	-- =========================================================================

	-- ----- treesitter (colorização e parsers) --------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			-- parsers a instalar (assíncrono; precisa de tree-sitter-cli e compilador C)
			require("nvim-treesitter").install({
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"cpp",
				"python",
			})

			-- liga a colorização do treesitter em cada arquivo
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("VictorTreesitter", { clear = true }),
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})

			-- fecha tags HTML automaticamente
			require("nvim-ts-autotag").setup()
		end,
	},

	-- ----- blink.cmp (autocomplete) ------------------------------------------
	{
		"saghen/blink.cmp",
		-- snippets prontos (c, python, html...) usados pela fonte "snippets"
		dependencies = { "rafamadriz/friendly-snippets" },
		-- tag de release: baixa o fuzzy matcher pré-compilado (série 1.x, estável)
		version = "1.*",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- Tab confirma a sugestão; Enter só quebra a linha
			-- Ctrl+j / Ctrl+k: seleciona no menu, ou pula entre os campos de um snippet
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_and_accept", "fallback" },
				["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
				["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "cancel", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				menu = {
					draw = {
						components = {
							-- quadradinho de cor no menu (#ff0000, red...), via nvim-highlight-colors
							kind_icon = {
								text = function(ctx)
									local icon = ctx.kind_icon
									if ctx.item.source_name == "LSP" then
										local color_item = require("nvim-highlight-colors").format(
											ctx.item.documentation,
											{ kind = ctx.kind }
										)
										if color_item and color_item.abbr ~= "" then
											icon = color_item.abbr
										end
									end
									return icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									local highlight = "BlinkCmpKind" .. ctx.kind
									if ctx.item.source_name == "LSP" then
										local color_item = require("nvim-highlight-colors").format(
											ctx.item.documentation,
											{ kind = ctx.kind }
										)
										if color_item and color_item.abbr_hl_group then
											highlight = color_item.abbr_hl_group
										end
									end
									return highlight
								end,
							},
						},
					},
				},
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},
			-- sem completar o ':' (o nvim-cmp antigo também não completava)
			cmdline = { enabled = false },
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},

	-- ----- conform (formatadores: ruff e prettier) ---------------------------
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			format_on_save = { timeout_ms = 500, lsp_format = "never" },
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				objc = { "clang-format" },
				objcpp = { "clang-format" },
				python = { "ruff_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
			},
		},
		keys = {
			{
				"<leader>fm",
				function()
					require("conform").format({ lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "Format file",
			},
		},
	},

	-- ----- autopairs / surround ----------------------------------------------
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	{
		"kylechui/nvim-surround",
		event = { "BufReadPre", "BufNewFile" },
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = true,
	},

	-- cloak: esconde os valores de arquivos .env com asteriscos
	{
		"laytan/cloak.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("cloak").setup({
				enabled = true,
				cloak_character = "*",
				highlight_group = "Comment",
				cloak_length = nil, -- coloque um número pra esconder o tamanho real do valor
				try_all_patterns = true,
				cloak_telescope = true,
				cloak_on_leave = false,
				patterns = {
					{
						file_pattern = "*.env*",
						cloak_pattern = "=.+",
						replace = nil,
					},
				},
			})
		end,
	},

	-- ----- buffers / marcas / comentários destacados -------------------------

	-- bufdelete: fecha buffer sem fechar a janela (:Bdelete)
	{ "famiu/bufdelete.nvim", cmd = "Bdelete" },

	-- marks: mostra as marks na margem
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- todo-comments: destaca TODO, FIXME, NOTE...
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- =========================================================================
	-- [5.6] navegação
	-- =========================================================================

	-- ----- telescope (busca fuzzy) -------------------------------------------
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Fuzzy find recent files" },
			{ "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Find string in cwd" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Find document symbols" },
			{ "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Find string under cursor in cwd" },
			{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<C-b>", "<cmd>Telescope buffers<cr>", desc = "Find open buffers" },
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						"vendor",
						"build",
						"%.git",
					},
					path_display = { "smart" },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-t>"] = function()
								require("trouble.sources.telescope").open()
							end,
						},
					},
				},
			})

			pcall(telescope.load_extension, "fzf")
		end,
	},

	-- ----- trouble (lista de diagnósticos) -----------------------------------
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		config = function(_, opts)
			require("trouble").setup(opts)

			vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {
				desc = "Diagnostics (Trouble)",
			})
			vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", {
				desc = "Buffer diagnostics (Trouble)",
			})
			vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", {
				desc = "Symbols (Trouble)",
			})
		end,
	},

	-- =========================================================================
	-- [5.7] LSP
	-- =========================================================================

	-- ----- lazydev (tipos e workspace do lua_ls para configs Neovim) ---------
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- ----- lspconfig (servidores, atalhos e diagnósticos) --------------------
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		config = function()
			local keymap = vim.keymap
			-- setup keymaps when LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client.server_capabilities.semanticTokensProvider then
						client.server_capabilities.semanticTokensProvider = nil
					end

					opts.desc = "Show LSP references"
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Go to definition"
					keymap.set("n", "gd", vim.lsp.buf.definition, opts)

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

					opts.desc = "See available code actions"
					keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

					opts.desc = "Apply quick fix (no menu)"
					keymap.set("n", "<leader>cf", function()
						vim.lsp.buf.code_action({ context = { only = { "quickfix" } }, apply = true })
					end, opts)

					opts.desc = "Smart rename"
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, opts)

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, opts)

					opts.desc = "Show documentation under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts)

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

					-- Enable inlay hints if supported (disabled for C/C++)
					local ft = vim.bo[ev.buf].filetype
					local path = vim.api.nvim_buf_get_name(ev.buf)
					local disable_inlay_hints = vim.tbl_contains({ "c", "cpp", "objc", "objcpp" }, ft)
						or path:match("%.h$")
						or path:match("%.hh$")
						or path:match("%.hpp$")
						or path:match("%.hxx$")
						or path:match("%.inl$")

					if client and client.server_capabilities.inlayHintProvider and not disable_inlay_hints then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
				end,
			})

			-- LSP completion capabilities
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

			-- diagnostics: ícones na margem e texto inline
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 2,
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- ============================
			-- Language servers
			-- ============================

			-- TypeScript / JavaScript
			vim.lsp.config("ts_ls", {
				filetypes = {
					"typescript",
					"typescriptreact",
					"javascript",
					"javascriptreact",
				},
			})
			vim.lsp.enable("ts_ls")

			-- C / C++
			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--query-driver=/usr/bin/c++,/usr/bin/g++,/usr/bin/gcc,/usr/bin/cc",
				},
			})
			vim.lsp.enable("clangd")

			-- Python
			local function get_python_path(root_dir)
				local venv_names = { ".venv", "venv", "env" }

				for _, venv_name in ipairs(venv_names) do
					local unix_python = root_dir .. "/" .. venv_name .. "/bin/python"

					if vim.fn.executable(unix_python) == 1 then
						return unix_python, venv_name
					end
				end

				if vim.env.VIRTUAL_ENV then
					local virtualenv_python = vim.env.VIRTUAL_ENV .. "/bin/python"
					if vim.fn.executable(virtualenv_python) == 1 then
						return virtualenv_python
					end
				end

				local python3 = vim.fn.exepath("python3")
				if python3 ~= "" then
					return python3
				end

				local python = vim.fn.exepath("python")
				if python ~= "" then
					return python
				end
			end

			vim.lsp.config("pyright", {
				filetypes = { "python" },
				root_markers = {
					"pyrightconfig.json",
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					".git",
				},
				before_init = function(_, config)
					local root_dir = config.root_dir or vim.fn.getcwd()
					local python_path, venv_name = get_python_path(root_dir)

					config.settings = config.settings or {}
					config.settings.python = config.settings.python or {}
					config.settings.python.analysis = config.settings.python.analysis or {}
					config.settings.python.analysis.autoSearchPaths = true
					config.settings.python.analysis.useLibraryCodeForTypes = true

					if python_path then
						config.settings.python.pythonPath = python_path
					end

					if venv_name then
						config.settings.python.venvPath = root_dir
						config.settings.python.venv = venv_name
					end
				end,
			})
			vim.lsp.enable("pyright")

			-- Lua
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME },
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})
			vim.lsp.enable("lua_ls")
			vim.lsp.enable({ "html", "cssls", "emmet_ls", "ruff" })
		end,
	},

	-- ----- mason (instala os servidores) -------------------------------------
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- import mason
			local mason = require("mason")

			-- import mason-lspconfig
			local mason_lspconfig = require("mason-lspconfig")

			-- enable mason and configure icons
			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			local ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"lua_ls",
				"emmet_ls",
				"pyright",
				"clangd",
			}

			mason_lspconfig.setup({
				-- list of servers for mason to install
				ensure_installed = ensure_installed,
				automatic_enable = false,
			})
		end,
	},

	-- =========================================================================
	-- [5.8] debugger
	-- =========================================================================

	-- ----- nvim-dap (núcleo: adaptador lldb, configs e atalhos) --------------
	{
		"mfussenegger/nvim-dap",
		dependencies = { "nvim-neotest/nvim-nio" },

		config = function()
			local dap = require("dap")
			local uv = vim.uv

			local function file_exists(path)
				return path and uv.fs_stat(path) ~= nil
			end

			local function is_executable(path)
				return file_exists(path) and vim.fn.executable(path) == 1
			end

			local function workspace_root()
				local current = vim.api.nvim_buf_get_name(0)
				local root_markers = {
					".git",
					"compile_commands.json",
					"CMakeLists.txt",
					"Cargo.toml",
					"Makefile",
				}

				local root = vim.fs.dirname(vim.fs.find(root_markers, {
					path = current ~= "" and current or vim.fn.getcwd(),
					upward = true,
				})[1] or "")

				return root ~= "" and root or vim.fn.getcwd()
			end

			local function pick_cpp_binary()
				local cwd = workspace_root()
				local current = vim.api.nvim_buf_get_name(0)
				local stem = vim.fn.fnamemodify(current, ":t:r")
				local candidates = {
					cwd .. "/" .. stem,
					cwd .. "/build/" .. stem,
					cwd .. "/bin/" .. stem,
					cwd .. "/build/debug/" .. stem,
					cwd .. "/build/Debug/" .. stem,
					cwd .. "/out/" .. stem,
				}

				for _, candidate in ipairs(candidates) do
					if is_executable(candidate) then
						vim.notify("DAP launching " .. candidate, vim.log.levels.INFO)
						return candidate
					end
				end

				local picked = vim.fn.input("Path to executable: ", cwd .. "/", "file")
				if picked == "" then
					vim.notify("DAP launch cancelled: no executable selected", vim.log.levels.WARN)
					return dap.ABORT
				end
				if not is_executable(picked) then
					vim.notify("DAP launch aborted: not executable: " .. picked, vim.log.levels.ERROR)
					return dap.ABORT
				end
				return picked
			end

			local function split_args(input)
				local args = {}
				for arg in string.gmatch(input, "%S+") do
					table.insert(args, arg)
				end
				return args
			end

			local function prompt_args()
				return split_args(vim.fn.input("Program arguments: "))
			end

			local lldb_dap = vim.fn.exepath("lldb-dap")
			local codelldb = vim.fn.exepath("codelldb")

			-----------------------------------------------------------------------
			-- Adapter setup
			-----------------------------------------------------------------------
			if lldb_dap ~= "" then
				dap.adapters.lldb = {
					type = "executable",
					command = lldb_dap,
					name = "lldb",
				}
			elseif codelldb ~= "" then
				dap.adapters.lldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = codelldb,
						args = { "--port", "${port}" },
					},
				}
			else
				vim.notify("No C/C++ DAP adapter found. Install `lldb-dap` or `codelldb`.", vim.log.levels.WARN)
			end

			-----------------------------------------------------------------------
			-- Debug configurations for C, C++
			-----------------------------------------------------------------------
			local cpp_configurations = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = pick_cpp_binary,
					cwd = function()
						return workspace_root()
					end,
					stopOnEntry = false,
				},
				{
					name = "Launch with args",
					type = "lldb",
					request = "launch",
					program = pick_cpp_binary,
					args = prompt_args,
					cwd = function()
						return workspace_root()
					end,
					stopOnEntry = false,
				},
				{
					name = "Attach to process",
					type = "lldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					cwd = function()
						return workspace_root()
					end,
				},
			}

			dap.configurations.cpp = cpp_configurations
			dap.configurations.c = cpp_configurations

			-----------------------------------------------------------------------
			-- Keybindings
			-----------------------------------------------------------------------
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Breakpoint" })
			vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "Step Over" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
			vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
			vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "Restart" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
		end,
	},

	-- ----- nvim-dap-ui (painéis do debugger) ---------------------------------
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},

		config = function()
			local dap = require("dap")
			local ok_nio = pcall(require, "nio")
			if not ok_nio then
				vim.notify("nvim-dap-ui disabled: failed to load nvim-nio", vim.log.levels.ERROR)
				return
			end

			local ok_dapui, dapui = pcall(require, "dapui")
			if not ok_dapui then
				vim.notify("nvim-dap-ui disabled: failed to load dap-ui", vim.log.levels.ERROR)
				return
			end

			-----------------------------------------------------------------------
			-- UI SETUP
			-----------------------------------------------------------------------

			dapui.setup({
				layouts = {
					{
						elements = {
							"scopes",
							"breakpoints",
							"stacks",
							"watches",
						},
						size = 40,
						position = "left",
					},
				},
				controls = { enabled = false },
			})

			-----------------------------------------------------------------------
			-- AUTO OPEN / CLOSE UI
			-----------------------------------------------------------------------

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end

			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-----------------------------------------------------------------------
			-- KEYMAPS
			-----------------------------------------------------------------------

			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI toggle" })

			-- Watches API
			vim.keymap.set("n", "<leader>dw", function()
				local expr = vim.fn.input("Watch expression: ")
				if expr ~= "" then
					dapui.elements.watches.add(expr)
				end
			end, { desc = "DapUI add watch" })

			vim.keymap.set("n", "<leader>dW", function()
				dapui.elements.watches.remove()
			end, { desc = "DapUI remove watch" })

			vim.keymap.set("n", "<leader>dC", function()
				local watches = dapui.elements.watches.get()
				for i = #watches, 1, -1 do
					dapui.elements.watches.remove(i)
				end
			end, { desc = "DapUI clear watches" })
		end,
	},

	-- ----- nvim-dap-virtual-text (valores das variáveis inline) --------------
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },

		config = function()
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				highlight_changed_variables = true,
				show_stop_reason = true,
			})
		end,
	},
}, {
	change_detection = {
		notify = false,
	},
	-- nenhum plugin daqui precisa de luarocks; evita o "needs build" (hererocks)
	rocks = {
		enabled = false,
	},
})

-- =============================================================================
-- [6] INICIALIZAÇÃO
-- =============================================================================

-- registra :Theme / :ThemeNext / :ThemePrev e aplica o tema salvo
theme.setup()
