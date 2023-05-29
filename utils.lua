local M = {
    levels = vim.log.levels ---@type table<'DEBUG'|'ERROR'|'INFO'|'TRACE'|'WARN'|'OFF', number>
}

---@return {chan: integer, buf: integer }[]
function M.get_terminals()
    local terminals = {}
    for _, channel in ipairs(vim.api.nvim_list_chans()) do
        if channel.mode == 'terminal' then
            table.insert(terminals, { chan = channel.id, buf = channel.buffer })
        end
    end
    return terminals
end

---@param opts? {as_string:boolean}
---@return number[]|(string[])
function M.get_senders(opts)
    opts = opts or {}
    local sendline_buffers = {} ---@type number[]|(string[])
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].sendlineChannel then
            if opts.as_string then
                table.insert(sendline_buffers, tostring(buf))
            else
                table.insert(sendline_buffers, buf)
            end
        end
    end
    return sendline_buffers
end

---@return boolean is_valid
---@return integer? buffer
function M.validate_fargs(cmd)
    vim.validate({ cmd = { cmd, 'table' } })
    -- check args
    local n = #cmd.fargs
    if n > 1 then
        vim.notify('Sendline: ArgumentError - Only 0 or 1 arguments allowed!', M.levels.ERROR)
        return false
    elseif n > 0 then
        local ok, buffer = pcall(tonumber, cmd.fargs[1])
        if not ok then
            vim.notify("Sendline: ArgumentError - '" .. cmd.fargs[1] .. "' is not convertible to number!", M.levels.ERROR)
            return false
        end
        return true, buffer
    end
    return true, nil
end

return M
