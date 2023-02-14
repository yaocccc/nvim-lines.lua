if exists('s:loaded') | finish | endif
let s:loaded = 1

let SetStatusline = { -> luaeval("require'nvim-lines.statusline'.set_statusline()")}
let s:line_statusline_enable = get(g:, 'line_statusline_enable', 1)
let s:line_tabline_enable = get(g:, 'line_tabline_enable', 1)

func! s:init_hi()
    let s:default_hl = { 'none': 'NONE', 'light': '24', 'dark': '238', 'break': '244', 'space': '238' }
    let [s:fg_key, s:bg_key] = ['ctermfg', 'ctermbg']
    if &termguicolors == 1
        let s:default_hl = { 'none': 'NONE', 'light': '#11698e', 'dark': '#444445', 'break': '#868788', 'space': '#444445' }
        let [s:fg_key, s:bg_key] = ['guifg', 'guibg']
    endif
    let s:line_hl = get(g:, 'line_hl', s:default_hl)
    exec printf('hi VimLine_None        %s=%s', s:bg_key, s:line_hl.none)
    exec printf('hi VimLine_Light       %s=%s', s:bg_key, s:line_hl.light)
    exec printf('hi VimLine_Dark        %s=%s', s:bg_key, s:line_hl.dark)
    exec printf('hi VimLine_Light_Dark  %s=%s %s=%s', s:fg_key, s:line_hl.light, s:bg_key, s:line_hl.dark)
    exec printf('hi VimLine_Dark_Light  %s=%s %s=%s', s:fg_key, s:line_hl.dark, s:bg_key, s:line_hl.light)
    exec printf('hi VimLine_Light_None  %s=%s %s=%s', s:fg_key, s:line_hl.light, s:bg_key, s:line_hl.none)
    exec printf('hi VimLine_Dark_None   %s=%s %s=%s', s:fg_key, s:line_hl.dark, s:bg_key, s:line_hl.none)
    exec printf('hi VimLine_Light_Break %s=%s %s=%s', s:bg_key, s:line_hl.light, s:fg_key, s:line_hl.break)
    exec printf('hi VimLine_Dark_Break  %s=%s %s=%s', s:bg_key, s:line_hl.dark, s:fg_key, s:line_hl.break)

    exec printf('hi VimLine_Buf_None        %s=%s', s:bg_key, s:line_hl.none)
    exec printf('hi VimLine_Buf_Light       %s=%s', s:bg_key, s:line_hl.light)
    exec printf('hi VimLine_Buf_Dark        %s=%s', s:bg_key, s:line_hl.dark)
    exec printf('hi VimLine_Buf_Light_Dark  %s=%s %s=%s', s:fg_key, s:line_hl.light, s:bg_key, s:line_hl.dark)
    exec printf('hi VimLine_Buf_Dark_Light  %s=%s %s=%s', s:fg_key, s:line_hl.dark, s:bg_key, s:line_hl.light)
    exec printf('hi VimLine_Buf_Light_None  %s=%s %s=%s', s:fg_key, s:line_hl.light, s:bg_key, s:line_hl.none)
    exec printf('hi VimLine_Buf_Dark_None   %s=%s %s=%s', s:fg_key, s:line_hl.dark, s:bg_key, s:line_hl.none)
    exec printf('hi VimLine_Buf_Light_Break %s=%s %s=%s', s:bg_key, s:line_hl.light, s:fg_key, s:line_hl.break)
    exec printf('hi VimLine_Buf_Dark_Break  %s=%s %s=%s', s:bg_key, s:line_hl.dark, s:fg_key, s:line_hl.break)

    exec printf('hi VimLine_Space %s=%s', s:bg_key, s:line_hl.space)
endf

func! SetTabline(...)
    lua require'nvim-lines.tabline'.set_tabline()
endf
func! Clicktab(minwid, clicks, button, modifiers) abort
    let l:timerID = get(s:, 'clickTabTimer', 0)
    if a:clicks == 1 && a:button is# 'l'
        if l:timerID == 0
            let s:clickTabTimer = timer_start(100, 'SwitchTab')
            let l:timerID = s:clickTabTimer
        endif
    elseif a:clicks == 2 && a:button is# 'l'
        silent execute 'bd' a:minwid
        let s:clickTabTimer = 0
        call timer_stop(l:timerID)
        call SetTabline()
    endif
    let s:minwid = a:minwid
    let s:timerID = l:timerID
    func! SwitchTab(...)
        silent execute 'buffer' s:minwid
        let s:clickTabTimer = 0
        call timer_stop(s:timerID)
    endf
endf

augroup lines
    au!
    if s:line_statusline_enable == 1
        set laststatus=3
        setglobal statusline=%!SetStatusline()
    endif
    if s:line_tabline_enable == 1
        set showtabline=3
        au VimEnter,BufWritePost,TextChanged,TextChangedI,BufEnter * call SetTabline()
        au BufLeave * call timer_start(0, 'SetTabline')
    endif
    if s:line_statusline_enable == 1 || s:line_tabline_enable == 1
        call s:init_hi()
        au OptionSet termguicolors call s:init_hi()
    endif
augroup END
