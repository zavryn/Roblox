--[[
	Tween Managing Module for Flux.
	-> Made by @zavryn
]]--


--//========================================
--// Library Setup
--//========================================

local TweenManager = {}

--//========================================
--// Services
--//========================================

local TweenService = game:GetService("TweenService")

--//========================================
--// Functions
--//========================================

function TweenManager.Tween(object: Instance, properties: {}, duration: number?, style: EnumItem?, direction: EnumItem?): Tween?
	if not object or not object.Parent or typeof(properties) ~= "table" then
		return
	end

	local tweenInfo = TweenInfo.new(duration or 0.1, style or Enum.EasingStyle.Linear, direction or Enum.EasingDirection.InOut)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()

	return tween
end

--//========================================
--// Return
--//========================================

return TweenManager
