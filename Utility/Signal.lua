--[[
    Signal Library
    -> Made by @zavryn
]]--


--// Library Initialization \\--
if getgenv().Signal then
    return
end

getgenv().Signal = {}
Signal.__index = Signal


--// Library Functions \\--
function Signal.new()
    return setmetatable({
        _connections = {},
        _destroyed = false
    }, Signal)
end
function Signal:Connect(callback)
    if self._destroyed or type(callback) ~= "function" then
        return
    end

    local connection = {
        Connected = true,
        Callback = callback,
        Signal = self
    }

    table.insert(self._connections, connection)

    function connection:Disconnect()
        if not self.Connected then
            return
        end

        self.Connected = false

        local index = table.find(self.Signal._connections, self)
        if index then
            table.remove(self.Signal._connections, index)
        end

        self.Callback = nil
        self.Signal = nil
    end

    return connection
end
function Signal:Fire(...)
    if self._destroyed then
        return
    end

    for _, connection in ipairs(table.clone(self._connections)) do
        if connection.Connected then
            connection.Callback(...)
        end
    end
end
function Signal:Once(callback)
    if self._destroyed then
        return
    end

    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        callback(...)
    end)

    return connection
end
function Signal:Wait()
    if self._destroyed then
        return
    end

    local thread = coroutine.running()
    self:Once(function(...)
        task.spawn(thread, ...)
    end)

    coroutine.yield()
end
function Signal:Destroy()
    if self._destroyed then
        return
    end

    for _, connection in ipairs(table.clone(self._connections)) do
        connection:Disconnect()
    end

    self._destroyed = true
    table.clear(self._connections)
end


--// Usage \\--
--      // Create Signal
--      local DamageTaken = Signal.new()
--
--      // Connect to Signal
--      DamageTaken:Connect(function(...) print(...) end)
-- 
--      // Disconnect from Signal
--      DamageTaken:Disconnect()
--
--      // Fire Signal
--      DamageTaken:Fire(123)
--
--      // Fire Signal Once
--      DamageTaken:Once(function(...) print(...) end)
--
--      // Wait for Signal to Fire
--      DamageTaken:Wait()
--
--      // Destroy Signal
--      DamageTaken:Destroy()
--
