--[[
	Simple Task Handling Module for Flux.
	-> Made by @zavryn
]]--


--//========================================
--// Library Setup
--//========================================

local Maid = {}
Maid.__index = Maid

--//========================================
--// Functions
--//========================================

function Maid.new()
	return setmetatable({
		_tasks = {},
		_connections = {},
		_nextId = 0,
		_cleaning = false
	}, Maid)
end

local function CleanupTask(task: RBXScriptConnection | Instance | () -> ())
	local taskType = typeof(task)
	
	local ok, result = pcall(function()
		if taskType == "RBXScriptConnection" then
			task:Disconnect()
		elseif taskType == "Instance" then
			if task:IsA("Tween") then
				task:Cancel()
			else
				task:Destroy()
			end
		elseif taskType == "function" then
			task()
		end
	end)
	
	if not ok then
		warn(`[Flux/Maid] Cleanup Error: {tostring(result)}`)
	end
end

function Maid:GiveTask(task: RBXScriptConnection | Instance | () -> ()): number?
	local taskType = typeof(task)
	if taskType ~= "RBXScriptConnection" and taskType ~= "Instance" and taskType ~= "function" then
		warn(`[Flux/Maid] Unsupported Task Type: {taskType}`)
		return
	end
	
	if self._cleaning then
		CleanupTask(task)
		return
	end
	
	self._nextId += 1
	local taskId = self._nextId
	
	self._tasks[taskId] = task
	
	if typeof(task) == "Instance" and task:IsA("Tween") then
		self._connections[taskId] = task.Completed:Once(function()
			self._tasks[taskId] = nil
			self._connections[taskId] = nil
		end)
	end
	
	return taskId
end

function Maid:RemoveTask(taskId: number, cleanup: boolean)
	local task = self._tasks[taskId]
	if not task then
		return
	end
	
	local connection = self._connections[taskId]
	if connection then
		connection:Disconnect()
		self._connections[taskId] = nil
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
	
	local ok, result = pcall(function()
		for taskId, task in pairs(self._tasks) do
			local connection = self._connections[taskId]
			if connection then
				self._connections[taskId] = nil
				connection:Disconnect()
			end

			self._tasks[taskId] = nil

			CleanupTask(task)
		end
	end)
	
	if not ok then
		warn(`[Flux/Maid] Cleanup Error: {tostring(result)}`)
	end
	
	self._cleaning = false
end

--//========================================
--// Return
--//========================================

return Maid
