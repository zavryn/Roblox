--[[
	UIManager - A Module for Flux.
	-> Made by @zavryn
]]--


local UIManager = {}


local function Connect(object: GuiObject, event: string, callback: () -> (), maid): RBXScriptConnection?
	if typeof(object) ~= "Instance" or not object:IsA("GuiObject") or typeof(callback) ~= "function" then
		return
	end
	
	local connection = object[event]:Connect(callback)
	
	if maid then
		maid:GiveTask(connection)
	end
	
	return connection
end

function UIManager.MouseEnter(object: GuiObject, callback: () -> (), maid): RBXScriptConnection?
	Connect(object, "MouseEnter", callback, maid)
end

function UIManager.MouseLeave(object: GuiObject, callback: () -> (), maid): RBXScriptConnection?
	Connect(object, "MouseLeave", callback, maid)
end

function UIManager.InputBegan(object: GuiObject, callback: (...any) -> (), maid): RBXScriptConnection?
	Connect(object, "InputBegan", callback, maid)
end

function UIManager.InputEnded(object: GuiObject, callback: (...any) -> (), maid): RBXScriptConnection?
	Connect(object, "InputEnded", callback, maid)
end

function UIManager.InputChanged(object: GuiObject, callback: (...any) -> (), maid): RBXScriptConnection?
	Connect(object, "InputChanged", callback, maid)
end


return UIManager
