local M = {}

local utils = require('sendline.utils')

---@param candidates string[]
---@param prefix string
---@return string[]
local function prepare_candidates(candidates, prefix)
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
    return prepare_candidates(term_bufs, arglead)
end

return M
