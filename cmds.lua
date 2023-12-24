local core = require('sendline.core')

local M = {}

---@param cmd table -- see: nvim_create_user_command()
---@return integer? buffer
local function handle_args(cmd)
    -- check args
    local n = #cmd.fargs
    if n > 1 then
        error('Sendline: Only 0 or 1 arguments allowed!')
    elseif n > 0 then
        local buffer = tonumber(cmd.fargs[1])
        if not buffer then
            error("Sendline: '" .. cmd.fargs[1] .. "' is not convertible to number!")
        end
        return buffer
    end
    return nil
end

---@param candidates string[]
---@param prefix string
---@return string[]
local function prep_completion_candidates(candidates, prefix)
    local filtered = {} ---@type string[]
    for _, candidate in ipairs(candidates) do
        if vim.startswith(candidate, prefix) and #candidate > #prefix then
            table.insert(filtered, string.sub(candidate, #prefix + 1))
        end
    end
    return filtered
end

---@return string[]
---@diagnostic disable-next-line:unused-local
local function complete_sendline_buffers(arglead, cmdline, cur_byte_pos)
    return prep_completion_candidates(core.get_senders({as_string = true}), arglead)
end

---@param arglead string Leading part of current word
---@param cmdline string Entire commandline
---@param curbytepos number Cursor position in commandline
---@return string[]
---@diagnostic disable-next-line:unused-local
local function complete_term_buffers(arglead, cmdline, curbytepos)
    local term_bufs = {} ---@type string[]
    for _, term in ipairs(core.get_terminals()) do
        table.insert(term_bufs, tostring(term.buf))
    end
    return prep_completion_candidates(term_bufs, arglead)
end

function M.enable()
    vim.api.nvim_create_user_command('Sendline', function(cmd)
        local buf = handle_args(cmd)

        ---@type string[]
        local lines = vim.api.nvim_buf_get_lines(0, cmd.line1 - 1, cmd.line2, false)
        -- convert newlines to plattform specific ones
        local eol = '\n'
        if vim.fn.has('win32') == 1 then
            eol = '\r\n'
        elseif vim.fn.has('mac') == 1 then
            eol = '\r'
        end
        local text = table.concat(lines, eol)
        -- end with newline
        if not vim.endswith(text, eol) then
            text = text .. eol
        end

        core.send({ text = text, to = buf, save_connection = not cmd.bang })

    end, {
        nargs = '*', -- '?' would accept everything as 1 arg. '*' splits on \s*
        complete = complete_term_buffers,
        range = true,
        bang = true,
    })

    vim.api.nvim_create_user_command('SendlineConnect', function(cmd)
        local buf = handle_args(cmd)
        core.get_connection({to = buf, persist = true})
    end, {
        nargs = '*', -- '?' would accept everything as 1 arg. '*' splits on \s*
        complete = complete_term_buffers,
    })

    vim.api.nvim_create_user_command('SendlineDisconnect', function(cmd)
        local buf = handle_args(cmd)
        core.disconnect(buf)
    end, {
        nargs = '*', -- '?' would accept everything as 1 arg. '*' splits on \s*
        complete = complete_sendline_buffers,
    })
end

function M.disable()
    vim.api.nvim_del_user_command('Sendline')
    vim.api.nvim_del_user_command('SendlineConnect')
    vim.api.nvim_del_user_command('SendlineDisconnect')
end

return M
