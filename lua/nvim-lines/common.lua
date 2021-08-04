local M = {}
local fn = vim.fn

local line_powerline_enable = vim.g.line_powerline_enable == 1
local line_nerdfont_enable = vim.g.line_nerdfont_enable == 1

local _powerline_symbols = vim.g.powerline_symbols or {}
local powerline_symbols = {
    light_right = _powerline_symbols['light_right'] or '',
    dark_right = _powerline_symbols['dark_right'] or '',
    light_left = _powerline_symbols['light_left'] or '',
    dark_left = _powerline_symbols['dark_left'] or ''
}
local icons = { folderClosed = '', folderOpened = '', folderSymlink = '', file = '', fileSymlink = '', fileHidden = '﬒', excel = '', word = '', ppt = '', stylus = '', sass = '', html = '', xml = '謹', ejs = '', css = '', webpack = 'ﰩ', markdown = '', json = '', javascript = '', javascriptreact = '', ruby = '', php = '', python = '', coffee = '', mustache = '', conf = '', image = '', ico = '', twig = '', c = '', h = '', haskell = '', lua = '', java = '', terminal = '', ml = 'λ', diff = '', sql = '', clojure = '', edn = '', scala = '', go = '', dart = '', firefox = '', vs = '', perl = '', rss = '', csharp = '', fsharp = '', rust = '', dlang = '', erlang = '', elixir = '', elm = '', mix = '', vim = '', ai = '', psd = '', psb = '', typescript = '', typescriptreact = '', julia = '', puppet = '', vue = '﵂', swift = '', git = '', bashrc = '', favicon = '', docker = '', gruntfile = '', gulpfile = '', dropbox = '', license = '', procfile = '', jquery = '', angular = '', backbone = '', requirejs = '', materialize = '', mootools = '', vagrant = '', svg = 'ﰟ', font = '', text = '', archive = '', lock = '' }
local extensions = { ['styl'] = 'stylus', ['sass'] = 'sass', ['scss'] = 'sass', ['htm'] = 'html', ['html'] = 'html', ['slim'] = 'html', ['xml'] = 'xml', ['xaml'] = 'xml', ['ejs'] = 'ejs', ['css'] = 'css', ['less'] = 'css', ['md'] = 'markdown', ['mdx'] = 'markdown', ['markdown'] = 'markdown', ['rmd'] = 'markdown', ['lock'] = 'lock', ['json'] = 'json', ['js'] = 'javascript', ['cjs'] = 'javascript', ['mjs'] = 'javascript', ['es6'] = 'javascript', ['jsx'] = 'javascriptreact', ['rb'] = 'ruby', ['ru'] = 'ruby', ['php'] = 'php', ['py'] = 'python', ['pyc'] = 'python', ['pyo'] = 'python', ['pyd'] = 'python', ['coffee'] = 'coffee', ['mustache'] = 'mustache', ['hbs'] = 'mustache', ['config'] = 'conf', ['conf'] = 'conf', ['ini'] = 'conf', ['yml'] = 'conf', ['yaml'] = 'conf', ['toml'] = 'conf', ['jpg'] = 'image', ['jpeg'] = 'image', ['bmp'] = 'image', ['png'] = 'image', ['gif'] = 'image', ['webp'] = 'image', ['ico'] = 'ico', ['twig'] = 'twig', ['cpp'] = 'c', ['c++'] = 'c', ['cxx'] = 'c', ['cc'] = 'c', ['cp'] = 'c', ['c'] = 'c', ['h'] = 'h', ['hh'] = 'h', ['hpp'] = 'h', ['hxx'] = 'h', ['hs'] = 'haskell', ['lhs'] = 'haskell', ['lua'] = 'lua', ['java'] = 'java', ['jar'] = 'java', ['sh'] = 'terminal', ['fish'] = 'terminal', ['bash'] = 'terminal', ['zsh'] = 'terminal', ['ksh'] = 'terminal', ['csh'] = 'terminal', ['awk'] = 'terminal', ['ps1'] = 'terminal', ['bat'] = 'terminal', ['cmd'] = 'terminal', ['ml'] = 'ml', ['mli'] = 'ml', ['diff'] = 'diff', ['db'] = 'sql', ['sql'] = 'sql', ['dump'] = 'sql', ['accdb'] = 'sql', ['clj'] = 'clojure', ['cljc'] = 'clojure', ['cljs'] = 'clojure', ['edn'] = 'edn', ['scala'] = 'scala', ['go'] = 'go', ['dart'] = 'dart', ['xul'] = 'firefox', ['pl'] = 'perl', ['pm'] = 'perl', ['t'] = 'perl', ['rss'] = 'rss', ['sln'] = 'vs', ['suo'] = 'vs', ['csproj'] = 'vs', ['cs'] = 'csharp', ['fsscript'] = 'fsharp', ['fsx'] = 'fsharp', ['fs'] = 'fsharp', ['fsi'] = 'fsharp', ['rs'] = 'rust', ['rlib'] = 'rust', ['d'] = 'dlang', ['erl'] = 'erlang', ['hrl'] = 'erlang', ['ex'] = 'elixir', ['eex'] = 'elixir', ['exs'] = 'elixir', ['exx'] = 'elixir', ['leex'] = 'elixir', ['vim'] = 'vim', ['ai'] = 'ai', ['psd'] = 'psd', ['psb'] = 'psd', ['ts'] = 'typescript', ['tsx'] = 'javascriptreact', ['jl'] = 'julia', ['pp'] = 'puppet', ['vue'] = 'vue', ['elm'] = 'elm', ['swift'] = 'swift', ['xcplayground'] = 'swift', ['svg'] = 'svg', ['otf'] = 'font', ['ttf'] = 'font', ['fnt'] = 'font', ['txt'] = 'text', ['text'] = 'text', ['zip'] = 'archive', ['tar'] = 'archive', ['gz'] = 'archive', ['gzip'] = 'archive', ['rar'] = 'archive', ['7z'] = 'archive', ['iso'] = 'archive', ['doc'] = 'word', ['docx'] = 'word', ['docm'] = 'word', ['csv'] = 'excel', ['xls'] = 'excel', ['xlsx'] = 'excel', ['xlsm'] = 'excel', ['ppt'] = 'ppt', ['pptx'] = 'ppt', ['pptm'] = 'ppt' }
local patternMatches = { {'.*jquery.*.js$', 'jquery'}, {'.*angular.*.js$', 'angular'}, {'.*backbone.*.js$', 'backbone'}, {'.*require.*.js$', 'requirejs'}, {'.*materialize.*.js$', 'materialize'}, {'.*materialize.*.css$', 'materialize'}, {'.*mootools.*.js$', 'mootools'} }
local filenames = { ['gruntfile'] = 'gruntfile', ['gulpfile'] = 'gulpfile', ['gemfile'] = 'ruby', ['guardfile'] = 'ruby', ['capfile'] = 'ruby', ['rakefile'] = 'ruby', ['mix'] = 'mix', ['dropbox'] = 'dropbox', ['vimrc'] = 'vim', ['.vimrc'] = 'vim', ['.gvimrc'] = 'vim', ['_vimrc'] = 'vim', ['_gvimrc'] = 'vim', ['license'] = 'license', ['procfile'] = 'procfile', ['Vagrantfile'] = 'vagrant', ['docker-compose.yml']= 'docker', ['.gitconfig'] = 'git', ['.gitignore'] = 'git', ['webpack'] = 'webpack', ['.bashrc'] = 'bashrc', ['.zshrc'] = 'bashrc', ['.bashprofile'] = 'bashrc', ['favicon.ico'] = 'favicon', ['dockerfile'] = 'docker', ['.dockerignore'] = 'docker' }

local function get_icon(key)
    return (icons[key] or icons.file) .. ' '
end

function M.get_powerline_hl(hl)
    return line_powerline_enable == true and hl or 'VimLine_None'
end
function M.get_powerline_text(symbol)
    if line_powerline_enable == false then return ' ' end
    return powerline_symbols[symbol] or ' '
end

function M.get_fileicon(ft, fname)
    if line_nerdfont_enable == false then return '' end
    if fname == '' then return '' end

    local key = filenames[fname]
    if key then
        return get_icon(key)
    end

    for _, mat in pairs(patternMatches) do
        if string.match(fname, mat[1]) then
            return get_icon(mat[2])
        end
    end

    key = extensions[vim.fn.fnamemodify(fname, ':e')]
    if key then
        return get_icon(key)
    end

    return get_icon(ft)
end

function M.get_diricon()
    if line_nerdfont_enable == false then return '' end
    return get_icon('folderOpened')
end

function M.info_to_text(info)
    local text = ''
    text = text .. (info.nr ~= nil and '%' .. info.nr .. '@Clicktab@' or '')
    text = text .. (info.hl ~= nil and '%#' .. info.hl .. '#' or '')
    text = text .. (info.text ~= nil and info.text or '')
    text = text .. (info.nr ~= nil and '%X' or '')
    return text
end

function M.get_infos_text_width(infos)
    local width = 0
    for _,info in pairs(infos) do
        width = width + (info.text ~= nil and fn.strwidth(info.text))
    end
    return width
end

function M.get_str_bycount(str, l)
    if l > 0 then
        return fn.strcharpart(str, 0, l)
    else
        local result = ''
        local index = 0
        local sindex = fn.strwidth(str) - 1
        while index < -l do
            local c = fn.strcharpart(str, sindex, 1)
            result = c .. result
            index = index + 1
            sindex = sindex - 1
        end
        return result
    end
end

function M.list_slice(list, l, r)
    local result = {}
    l = l + 1
    if r >= 0 then
        r = r + 1
    else
        r = #list + r
    end

    for i = l, r + 1, 1 do
        table.insert(result, list[i])
    end
    return result
end

return M
