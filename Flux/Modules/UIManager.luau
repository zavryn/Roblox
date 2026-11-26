--[[
	UI Managing Module for Flux
	-> Made by @zavryn
]]--


--//========================================
--// Library Setup
--//========================================

local UIManager = {}

--//========================================
--// Functions
--//========================================

function UIManager.MouseEnter(object: GuiObject, callback: () -> ()): RBXScriptConnection?
	return object.MouseEnter:Connect(callback)
end

function UIManager.MouseLeave(object: GuiObject, callback: () -> ()): RBXScriptConnection?
	return object.MouseLeave:Connect(callback)
end

function UIManager.InputBegan(object: GuiObject | UserInputService, callback: (...any) -> ()): RBXScriptConnection?
	return object.InputBegan:Connect(callback)
end

function UIManager.InputEnded(object: GuiObject | UserInputService, callback: (...any) -> ()): RBXScriptConnection?
	return object.InputEnded:Connect(callback)
end

function UIManager.InputChanged(object: GuiObject | UserInputService, callback: (...any) -> ()): RBXScriptConnection?
	return object.InputChanged:Connect(callback)
end

--//========================================
--// Return
--//========================================

return UIManager
