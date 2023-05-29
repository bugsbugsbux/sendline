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
    return prepare_candidates(utils.get_senders({as_string = true}), arglead)
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
