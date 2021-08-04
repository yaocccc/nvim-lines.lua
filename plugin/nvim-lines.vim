if exists('s:loaded') | finish | endif
let s:loaded = 1

let s:line_statusline_enable = get(g:, 'line_statusline_enable', 1)
let s:line_tabline_enable = get(g:, 'line_tabline_enable', 1)
let s:line_tabline_show_pwd = get(g:, 'line_tabline_show_pwd', 1)
let s:line_hl = get(g:, 'line_hl', { 'none': 'NONE', 'light': '24', 'dark': '238', 'break': '244' })

exec printf('hi VimLine_None        ctermbg=%s', s:line_hl.none)
exec printf('hi VimLine_Light       ctermbg=%s', s:line_hl.light)
exec printf('hi VimLine_Dark        ctermbg=%s', s:line_hl.dark)
exec printf('hi VimLine_Light_Dark  ctermfg=%s ctermbg=%s', s:line_hl.light, s:line_hl.dark)
exec printf('hi VimLine_Dark_Light  ctermfg=%s ctermbg=%s', s:line_hl.dark, s:line_hl.light)
exec printf('hi VimLine_Light_None  ctermfg=%s ctermbg=%s', s:line_hl.light, s:line_hl.none)
exec printf('hi VimLine_Dark_None   ctermfg=%s ctermbg=%s', s:line_hl.dark, s:line_hl.none)
exec printf('hi VimLine_Light_Break ctermbg=%s ctermfg=%s', s:line_hl.light, s:line_hl.break)
exec printf('hi VimLine_Dark_Break  ctermbg=%s ctermfg=%s', s:line_hl.dark, s:line_hl.break)

exec printf('hi VimLine_Buf_None        ctermbg=%s', s:line_hl.none)
exec printf('hi VimLine_Buf_Light       ctermbg=%s', s:line_hl.light)
exec printf('hi VimLine_Buf_Dark        ctermbg=%s', s:line_hl.dark)
exec printf('hi VimLine_Buf_Light_Dark  ctermfg=%s ctermbg=%s', s:line_hl.light, s:line_hl.dark)
exec printf('hi VimLine_Buf_Dark_Light  ctermfg=%s ctermbg=%s', s:line_hl.dark, s:line_hl.light)
exec printf('hi VimLine_Buf_Light_None  ctermfg=%s ctermbg=%s', s:line_hl.light, s:line_hl.none)
exec printf('hi VimLine_Buf_Dark_None   ctermfg=%s ctermbg=%s', s:line_hl.dark, s:line_hl.none)
exec printf('hi VimLine_Buf_Light_Break ctermbg=%s ctermfg=%s', s:line_hl.light, s:line_hl.break)
exec printf('hi VimLine_Buf_Dark_Break  ctermbg=%s ctermfg=%s', s:line_hl.dark, s:line_hl.break)

let SetStatusline = { -> luaeval("require'nvim-lines.statusline'.set_statusline()")}
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
        lua require'nvim-lines.tabline'.set_tabline()
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
        set laststatus=2
        setglobal statusline=%!SetStatusline()
        au BufEnter,WinEnter * lua require'nvim-lines.statusline'.refresh_statusline()
    endif
    if s:line_tabline_enable == 1
        set showtabline=2
        au BufEnter,BufWritePost,TextChanged,TextChangedI * lua require'nvim-lines.tabline'.set_tabline()
    endif
augroup END
