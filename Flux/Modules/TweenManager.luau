--[[
	TweenManager - A Module for Flux.
	-> Made by @zavryn
]]--


local TweenService = game:GetService("TweenService")


local TweenManager = {}


function TweenManager.Tween(object: Instance, properties: {}, duration: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween?
	if not object or not object.Parent or typeof(properties) ~= "table" then
		return
	end
	
	local info = TweenInfo.new(
		duration or 0.1,
		style or Enum.EasingStyle.Linear,
		direction or Enum.EasingDirection.InOut
	)
	
	local tween = TweenService:Create(object, info, properties)
	tween:Play()
	
	return tween
end


return TweenManager
