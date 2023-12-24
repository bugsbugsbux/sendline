local core = require('sendline.core')

local M = {}

local GROUPNAME = 'Sendline'

function M.enable()
    local augroup = vim.api.nvim_create_augroup(GROUPNAME, {clear = true})
    vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*',
        group = augroup,
        callback = function(event)
            local senders = core.get_senders({to = event.buf})
            for _, sender in ipairs(senders) do
                ---@cast sender -string
                core.disconnect(sender)
            end
        end
    })
end

function M.disable()
    vim.api.nvim_del_augroup_by_name(GROUPNAME)
end

return M
