local M = {}

local utils = require('sendline.utils')

---@return string[]
---@diagnostic disable-next-line:unused-local
function M.complete_sendline_buffers(arglead, cmdline, cur_byte_pos)
    local buffers = {} ---@type string[]
    for _, buf in
        ipairs(vim.tbl_filter(function(x)
            return vim.api.nvim_buf_is_loaded(x)
        end, vim.api.nvim_list_bufs()))
    do
        if vim.b[buf].sendlineChannel then
            table.insert(buffers, tostring(buf))
        end
    end
    return buffers
end

---@return string[]
function M.complete_term_buffers(arglead, cmdline, curbytepos) ---@diagnostic disable-line:unused-local
    local buffers = {}
    for _, term in ipairs(utils.get_terminals()) do
        table.insert(buffers, tostring(term.buf))
    end
    ---@type nil|number
    local first_space = string.find(cmdline, ' ', 1, true)
    if first_space and curbytepos >= first_space then
        return buffers
    end
    return {}
end

return M
