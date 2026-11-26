--[[
	Flux Utility Library
	-> Made by @zavryn
]]--


--//========================================
--// Library Setup
--//========================================

local Flux = {
	_maid = nil,
	_destroyed = false
}

function Flux.Destroy()
	if Flux._destroyed or Flux._maid == nil then
		return
	end
	
	Flux._maid:Cleanup()
	Flux._destroyed = true
end

local Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/Maid.luau"))()
local TweenManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/TweenManager.luau"))()
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/UIManager.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/Utility.luau"))()

if not Maid or not TweenManager or not UIManager or not Utility then
	warn("[Flux] Failed to Load Modules.")
	return
end

--//========================================
--// Maid
--//========================================

Flux._maid = Maid.new()

function Flux.Connect(signal: RBXScriptSignal, callback: () -> ()): {}?
	if Flux._destroyed then
		return
	end

	if typeof(signal) ~= "RBXScriptSignal" or typeof(callback) ~= "function" then
		return
	end

	local connection = signal:Connect(callback)

	local taskId = Flux._maid:GiveTask(connection)

    return {
        Connection = connection,
        TaskId = taskId,
        Disconnect = function()
            Flux._maid:RemoveTask(taskId, true)
        end
    }
end

--//========================================
--// TweenManager
--//========================================

function Flux.Tween(object: Instance, properties: {}, duration: number?, style: EnumItem?, direction: EnumItem?): Tween?
	if Flux._destroyed then
		return
	end

	local tween = TweenManager.Tween(object, properties, duration, style, direction)
	if not tween then
		return
	end

	Flux._maid:GiveTask(tween)

	return tween
end

--//========================================
--// UIManager
--//========================================

function Flux.MouseEnter(object: GuiObject, callback: () -> ()): RBXScriptConnection?
	if Flux._destroyed then
		return
	end

	local connection = UIManager.MouseEnter(object, callback)

	Flux._maid:GiveTask(connection)

	return connection
end

function Flux.MouseLeave(object: GuiObject, callback: () -> ()): RBXScriptConnection?
	if Flux._destroyed then
		return
	end

	local connection = UIManager.MouseLeave(object, callback)

	Flux._maid:GiveTask(connection)

	return connection
end

function Flux.InputBegan(object: GuiObject, callback: (...any) -> ()): RBXScriptConnection?
	if Flux._destroyed then
		return
	end

	local connection = UIManager.InputBegan(object, callback)

	Flux._maid:GiveTask(connection)

	return connection
end

function Flux.InputEnded(object: GuiObject, callback: (...any) -> ()): RBXScriptConnection?
	if Flux._destroyed then
		return
	end

	local connection = UIManager.InputEnded(object, callback)

	Flux._maid:GiveTask(connection)

	return connection
end

function Flux.InputChanged(object: GuiObject, callback: (...any) -> ()): RBXScriptConnection?
	if Flux._destroyed then
		return
	end

	local connection = UIManager.InputChanged(object, callback)

	Flux._maid:GiveTask(connection)

	return connection
end

--//========================================
--// Utility
--//========================================

Flux.Noop = Utility.Noop
Flux.Lerp = Utility.Lerp
Flux.SafeCallback = Utility.SafeCallback

--//========================================
--// Return
--//========================================

return Flux
