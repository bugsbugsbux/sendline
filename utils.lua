local M = {}

---@param level 'DEBUG'|'ERROR'|'INFO'|'TRACE'|'WARN'|'OFF'
---@return function(string)
local function make_notifier(level)
    ---@param msg string
    return function(msg)
        vim.notify(msg, vim.log.levels[level], {
            title = "Sendline", -- used by nvim-notify
        })
    end
end
M.notify_debug = make_notifier('DEBUG')
M.notify_error = make_notifier('ERROR')
M.notify_info = make_notifier('INFO')
M.notify_trace = make_notifier('TRACE')
M.notify_warn = make_notifier('WARN')

return M
