local M = {}

local utils = require('sendline.utils')
local core = require('sendline.core')

function M.send(cmd)
    local is_valid, buf = utils.validate_fargs(cmd)
    if not is_valid then
        return false
    end

    -- get lines
    local lines = vim.api.nvim_buf_get_lines(0, cmd.line1 - 1, cmd.line2, false) ---@type string[]
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

    -- send text
    if not core.send({ text = text, buffer = buf, once = cmd.bang }) then
        return false
    end
    return true
end

function M.connect(cmd)
    local valid, buf = utils.validate_fargs(cmd)
    if valid then
        core.connect(buf)
    end
end

function M.disconnect(cmd)
    local valid, buf = utils.validate_fargs(cmd)
    if valid then
        core.disconnect(buf)
    end
end

return M
