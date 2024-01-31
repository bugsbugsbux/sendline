local utils = require('sendline.utils')

local M = {}

---Only includes terminal in current buffer if config allows it.
---@return {chan: integer, buf: integer }[]
function M.get_terminals()
    local terminals = {}
    for _, channel in ipairs(vim.api.nvim_list_chans()) do
        if channel.mode == 'terminal' then
            if channel.buffer ~= vim.api.nvim_get_current_buf()
                or require('sendline.config').get('allow_connect_to_self')
            then
                table.insert(terminals, { chan = channel.id, buf = channel.buffer })
            end
        end
    end
    return terminals
end

---Return ids of buffers with saved sendline connection; optionally filtered for a
---specific target.
---@param opts? {as_string:boolean?, to:number?}
---@return number[]|(string[])
function M.get_senders(opts)
    opts = opts or {}
    local sendline_buffers = {} ---@type number[]|(string[])
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].sendlineConnection then
            if not opts.to or opts.to == vim.b[buf].sendlineConnection then
                if opts.as_string then
                    table.insert(sendline_buffers, tostring(buf))
                else
                    table.insert(sendline_buffers, buf)
                end
            end
        end
    end
    return sendline_buffers
end

---@return integer? channel A valid channel-id or nil if connecting failed.
function M.get_connection(opts)
    opts = opts or {}
    vim.validate{ opts = { opts, 'table' } }
    vim.validate{
        ['opts.to'] = { opts.to, 'number', true },
        ['opts.persist'] = { opts.persist, 'boolean', true },
    }
    local config = require('sendline.config')
    local user_supplied = opts.to and true or false
    local valid_targets = M.get_terminals()

    if #valid_targets == 0 then
        utils.notify_error('Sendline: No valid targets found. Open a terminal first!')
        return nil
    end

    if not opts.to and vim.b.sendlineConnection then
        opts.to = vim.b.sendlineConnection
    end
    if not opts.to then -- try to autoconnect
        if config.get('autoconnect') then -- autoconnecting allowed?
            if #valid_targets == 1 then -- autoconnecting possible?
                local buf = valid_targets[1].buf
                if opts.persist then
                    vim.b.sendlineConnection = buf
                end
                utils.notify_info('Sendline: Autoconnected to buffer ' .. buf)
                return valid_targets[1].chan
            else
                utils.notify_error(
                    'Sendline: Could not autoconnect. Specify a target buffer!')
                return nil
            end
        else
            utils.notify_error(
                'Sendline: No connection found. Specify a target buffer!')
            return nil
        end
    end
    assert(opts.to, 'LOGIC ERROR')

    for _, target in ipairs(valid_targets) do
        if target.buf == opts.to then
            if opts.persist then
                if vim.b.sendlineConnection and vim.b.sendlineConnection ~= opts.to then
                    utils.notify_warn(
                        'Sendline: Connection changed to target buffer ' .. target.buf)
                end
                vim.b.sendlineConnection = target.buf
            end
            return target.chan
        end
    end
    -- getting a valid connection failed at this point...

    if user_supplied then
        utils.notify_error('Sendline: Buffer ' .. opts.to .. 'is not a valid target!')
    end
    if not user_supplied or vim.b.sendlineConnection == opts.to then
        vim.b.sendlineConnection = nil
        utils.notify_warn('Sendline: Removed invalid connection to buffer ' .. opts.to)
    end
    return nil
end

---@param buf? integer Buffer number. Current if missing
function M.disconnect(buf)
    vim.validate{ buf = { buf, 'number', true } }
    if vim.b[buf or 0].sendlineConnection then
        vim.b[buf or 0].sendlineConnection = nil
        utils.notify_info('Sendline: Removed connection of buffer ' .. (buf or 0))
    else
        utils.notify_warn('Sendline: No saved connection to remove found.')
    end
end

---@return boolean success
function M.send(opts)
    vim.validate({
        opts = { opts, 'table' },
        ['opts.text'] = { opts.text, 'string' },
        ['opts.to'] = { opts.to, 'number', true },
        ['opts.save_connection'] = { opts.save_connection, 'boolean', true },
    })
    local config = require('sendline.config')

    ---NOTE: input() receives all keys after <CR> of a mapping like `:Sendline<CR>+`
    if vim.bo.buftype == 'terminal' and config.get('confirm_send_from_terminal') then
        local choice = vim.fn.input(opts.text .. ' Sendline: Send above lines? [y|N] ')
        if not vim.tbl_contains({'y', 'Y'}, choice) then
            return false
        end
    end

    local chan = M.get_connection({to = opts.to, persist = opts.save_connection })
    if not chan then
        -- error message was handled by M.get_connection()
        return false
    end

    local ok = pcall(vim.api.nvim_chan_send, chan, opts.text)
    if not ok then
        utils.notify_error('Sendline: Failed to send lines for unknown reason.')
        return false
    end
    return true
end

return M
