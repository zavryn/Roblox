--[[
	Flux Utility Library
	-> Made by @zavryn
]]--


--================================================
-- Flux Library Setup
--================================================

local Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/Maid.luau"))()

local Flux = {
	_maid = Maid.new()
}

function Flux.Destroy()
	Flux._maid:Cleanup()
end

--================================================
-- TweenManager
--================================================

local TweenManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/TweenManager.luau"))()

function Flux.Tween(object: Instance, properties: {}, duration: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween?
	local tween = TweenManager.Tween(object, properties, duration, style, direction)
	if not tween then
		return
	end
	
	Flux._maid:GiveTask(tween)
	
	return tween
end

--================================================
-- UIManager
--================================================

local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/UIManager.luau"))()

function Flux.MouseEnter(object: GuiObject, callback: () -> ()): RBXScriptConnection?
	UIManager.MouseEnter(object, callback, Flux._maid)
end

function Flux.MouseLeave(object: GuiObject, callback: () -> ()): RBXScriptConnection?
	UIManager.MouseLeave(object, callback, Flux._maid)
end

function Flux.InputBegan(object: GuiObject, callback: (...any) -> ()): RBXScriptConnection?
	UIManager.InputBegan(object, callback, Flux._maid)
end

function Flux.InputEnded(object: GuiObject, callback: (...any) -> ()): RBXScriptConnection?
	UIManager.InputEnded(object, callback, Flux._maid)
end

function Flux.InputChanged(object: GuiObject, callback: (...any) -> ()): RBXScriptConnection?
	UIManager.InputChanged(object, callback, Flux._maid)
end

--================================================
-- Utility
--================================================

local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Modules/Utility.luau"))()

Flux.Noop = Utility.Noop
Flux.Lerp = Utility.Lerp
Flux.SafeCallback = Utility.SafeCallback


return Flux
