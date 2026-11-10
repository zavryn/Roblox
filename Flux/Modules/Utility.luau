--[[
	Utilty - A Module for Flux.
	-> Made by @zavryn
]]--


local Utility = {}


function Utility.Noop() end

function Utility.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function Utility.SafeCallback(callback: () -> (), ...: any)
	if typeof(callback) ~= "function" then
		return
	end
	
	local ok, err = pcall(callback, ...)
	if not ok then
		warn(`[Flux/Utility] Callback Error: {tostring(err)}`)
	end
end


return Utility
