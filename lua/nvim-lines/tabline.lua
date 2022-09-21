local M = {}
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local common = require'nvim-lines.common'

local dirname = ' ' .. common.get_diricon() .. api.nvim_eval("$PWD == $HOME ? '~' : substitute($PWD, '\\v(.*/)*', '', 'g')") .. ' '
local line_modi_mark = vim.g.line_modi_mark or '+'
local line_unnamed_filename = vim.g.line_unnamed_filename or '[unnamed]'
local tabline_headsymbol = vim.g.line_tabline_headsymbol or '▒'

local function get_buf_list()
    local buflist = {}
    local current = fn.bufnr('%')
    local i = 1
    while i <= fn.bufnr('$') do
        if fn.bufexists(i) == 1 and fn.buflisted(i) == 1 then
            local name = fn.bufname(i)
            local icon = common.get_fileicon(fn.getbufvar(i, '&ft'), name)
            local modi_mark = fn.getbufvar(i, '&mod') == 1 and line_modi_mark or ''
            name = #(fn.fnamemodify(name, ':t')) > 0 and fn.fnamemodify(name, ':t') or line_unnamed_filename
            name = icon .. name .. modi_mark
            table.insert(buflist, { nr = i, name = name, iscurrent = i == current })
        end
        i = i + 1
    end
    return buflist
end

local function hide_bufinfos(bufinfos, columns)
    if columns >= common.get_infos_text_width(bufinfos) then return bufinfos end

    local tempbufinfos = {}
    local width,len = 0, #bufinfos
    local current = 1

    -- 找到当前块
    for _,bufinfo in pairs(bufinfos) do
        if bufinfo.hl == 'VimLine_Buf_Light' then
            current = _
            break
        end
    end

    table.insert(tempbufinfos, bufinfos[current])
    table.insert(tempbufinfos, bufinfos[current + 1])
    width = width + fn.strwidth(bufinfos[current].text)
    width = width + fn.strwidth(bufinfos[current + 1].text)

    local l,r = 1,2
    local tempwidth = 0
    while true do
        if l + 1 <= r and current - l - 1 > 0 then
            tempwidth = fn.strwidth(bufinfos[current - l - 1].text) + fn.strwidth(bufinfos[current - l].text)
            if width + tempwidth > columns then break end
            width = width + tempwidth
            table.insert(tempbufinfos, 1, bufinfos[current - l])
            table.insert(tempbufinfos, 1, bufinfos[current - l - 1])

            l = l + 2
        else
            if current + r + 1 > len then
                if current - l - 1 < 1 then break end

                tempwidth = fn.strwidth(bufinfos[current - l - 1].text) + fn.strwidth(bufinfos[current - l].text)
                if width + tempwidth > columns then break end
                width = width + tempwidth
                table.insert(tempbufinfos, 1, bufinfos[current - l])
                table.insert(tempbufinfos, 1, bufinfos[current - l - 1])

                l = l + 2
            else
                tempwidth = fn.strwidth(bufinfos[current + r].text) + fn.strwidth(bufinfos[current + r + 1].text)
                if width + tempwidth > columns then break end
                width = width + tempwidth
                table.insert(tempbufinfos, #tempbufinfos + 1, bufinfos[current + r])
                table.insert(tempbufinfos, #tempbufinfos + 1, bufinfos[current + r + 1])

                r = r + 2
            end
        end
    end

    local lhide, rhide = current - l ~= 0, current + r ~= len + 1
    local emptywidth = 0

    -- 只隐藏了左边时 移除最右边的特殊块
    if lhide and not rhide then
        local _tempbufinfos = {}
        for i = 1, #tempbufinfos - 1 do
            table.insert(_tempbufinfos, tempbufinfos[i])
        end
        tempbufinfos = _tempbufinfos
        width = width - 1
    end

    -- 如果右边有隐藏 扩展右侧
    emptywidth = columns - width
    if rhide and emptywidth > 0 then
        local text = common.get_str_bycount(bufinfos[current + r].text .. '……', emptywidth)
        table.insert(tempbufinfos, #tempbufinfos + 1, { hl = 'VimLine_Dark', text = text })
        emptywidth = emptywidth - fn.strwidth(text)
        if common.get_str_bycount(text, -1) ~= '…' then
            tempbufinfos[#tempbufinfos].text = common.get_str_bycount(text, fn.strwidth(text) - 1) .. '…'
        end
    end

    -- 如果左边有隐藏 扩展左侧
    if lhide and emptywidth > 0 then
        local text = common.get_str_bycount('……' .. bufinfos[current - l - 1].text, -emptywidth + 1)
        table.insert(tempbufinfos, 1, { hl = common.get_powerline_hl('VimLine_Dark_Break'), text = common.get_powerline_text('dark_right') })
        table.insert(tempbufinfos, 1, { hl = 'VimLine_Dark', text = text })
    end

    -- 确保最左侧的符号为 …
    if lhide then
        local c = 1
        while tempbufinfos[c].text == '' do
            c = c + 1
        end
        if common.get_str_bycount(tempbufinfos[c].text, 1) ~= '…' then
            tempbufinfos[c].text = '…' .. common.get_str_bycount(tempbufinfos[c].text, -fn.strwidth(tempbufinfos[c].text) + 1)
        end
    end

    -- 确保最右侧的符号为 …
    if rhide then
        local c = #tempbufinfos
        while tempbufinfos[c].text == '' do
            c = c - 1
        end
        if common.get_str_bycount(tempbufinfos[c].text, -1) ~= '…' then
            tempbufinfos[c].text =  common.get_str_bycount(tempbufinfos[c].text, fn.strwidth(tempbufinfos[c].text) - 1) .. '…'
        end
    end

    table.insert(tempbufinfos, #tempbufinfos + 1, { hl = 'VimLine_None' })
    return tempbufinfos
end

function M.set_tabline()
    local tabline = ''
    local headinfos, bufinfos = {}, {}
    local buflist = get_buf_list()
    local isfirst = next(buflist) ~= nil and buflist[1].iscurrent

    table.insert(headinfos, { hl = 'VimLine_Light', text = tabline_headsymbol .. dirname })
    table.insert(headinfos, isfirst
        and { hl = common.get_powerline_hl('VimLine_Light_Break'), text = common.get_powerline_text('dark_right') }
        or { hl = common.get_powerline_hl('VimLine_Light_Dark'), text = common.get_powerline_text('light_right') })
    table.insert(headinfos, { text = '%<' })

    for _,bufinfo in pairs(buflist) do
        table.insert(bufinfos, { hl = bufinfo.iscurrent and 'VimLine_Buf_Light' or 'VimLine_Buf_Dark', text = ' ' .. bufinfo.name .. ' ', nr = bufinfo.nr })

        local hl, text = '', ''
        local n = next(buflist, _)
        if n == nil then
            hl = common.get_powerline_hl(bufinfo.iscurrent and 'VimLine_Buf_Light_None' or 'VimLine_Buf_Dark_None')
            text = common.get_powerline_text('light_right')
        elseif buflist[n].iscurrent == bufinfo.iscurrent then
            hl = common.get_powerline_hl('VimLine_Buf_Dark_Break')
            text = common.get_powerline_text('dark_right')
        else
            hl = common.get_powerline_hl(bufinfo.iscurrent and 'VimLine_Buf_Light_Dark' or 'VimLine_Buf_Dark_Light')
            text = common.get_powerline_text('light_right')
        end

        table.insert(bufinfos, { hl = hl, text = text })
    end

    -- 隐藏超过长度的bufs
    bufinfos = hide_bufinfos(bufinfos, api.nvim_eval('&columns') - fn.strwidth(dirname) - 2 )

    for _,info in pairs(headinfos) do
        tabline = tabline .. common.info_to_text(info)
    end
    for _,info in pairs(bufinfos) do
        tabline = tabline .. common.info_to_text(info)
    end
    cmd(string.format('let &tabline = "%s"', tabline))
end

return M
