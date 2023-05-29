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

---@param arglead string Leading part of current word
---@param cmdline string Entire commandline
---@param curbytepos number Cursor position in commandline
---@return string[]
function M.complete_term_buffers(arglead, cmdline, curbytepos) ---@diagnostic disable-line:unused-local
    local term_bufs = {} ---@type string[]
    for _, term in ipairs(utils.get_terminals()) do
        table.insert(term_bufs, tostring(term.buf))
    end
    local candidates = {} ---@type string[]
    for _, buf in ipairs(term_bufs) do
        if vim.startswith(buf, arglead) and #buf > #arglead then
            table.insert(candidates, string.sub(buf, #arglead + 1))
        end
    end
    return candidates
end

return M
