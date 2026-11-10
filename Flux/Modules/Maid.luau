--[[
	Maid - A Module for Flux.
	-> Made by @zavryn
]]--


local Maid = {}
Maid.__index = Maid


function Maid.new()
	return setmetatable({
		_tasks = {},
		_nextId = 0,
		_cleaning = false
	}, Maid)
end

local function CleanupTask(task)
	local ok, err = pcall(function()
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "Instance" then
			if task:IsA("Tween") then
				task:Cancel()
			else
				task:Destroy()
			end
		elseif typeof(task) == "function" then
			task()
		end
	end)
	if not ok then
		warn(`[Flux/Maid] Cleanup Error: {tostring(err)}`)
	end
end

function Maid:GiveTask(task)
	if task == nil or task == false then
		error("Task cannot be false or nil", 2)
	end
	
	if self._cleaning then
		CleanupTask(task)
		return
	end
	
	self._nextId += 1
	local taskId = self._nextId
	
	self._tasks[taskId] = task
	
	if typeof(task) == "Instance" and task:IsA("Tween") then
		task.Completed:Once(function()
			self._tasks[taskId] = nil
		end)
	end
	
	return taskId
end

function Maid:RemoveTask(taskId, cleanup)
	local task = self._tasks[taskId]
	if not task then
		return
	end
	
	self._tasks[taskId] = nil
	
	if cleanup ~= false then
		CleanupTask(task)
	end
end

function Maid:Cleanup()
	if self._cleaning then
		return
	end
	
	self._cleaning = true
	
	for taskId, task in pairs(self._tasks) do
		self._tasks[taskId] = nil
		
		CleanupTask(task)
	end
	
	self._cleaning = false
end


return Maid
