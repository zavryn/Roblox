--[[
    Globals Library
    -> Made by @zavryn
]]


--// Library Initialization \\--
if getgenv().Globals then
    return
end

getgenv().Globals = {
    connections = {}
}


--// Services and Declarations \\--
function GetService(serviceName)
    return cloneref and cloneref(game:GetService(serviceName)) or game:GetService(serviceName)
end

getgenv().Players = GetService("Players")
getgenv().CoreGui = GetService("CoreGui")
getgenv().Http = GetService("HttpService")
getgenv().Run = GetService("RunService")
getgenv().UIS = GetService("UserInputService")
getgenv().Gui = GetService("GuiService")
getgenv().WS = GetService("Workspace")
getgenv().TS = GetService("TweenService")

getgenv().Vec2 = Vector2.new
getgenv().Vec3 = Vector3.new
getgenv().Dim = UDim.new
getgenv().Dim2 = UDim2.new

getgenv().Color = Color3.new
getgenv().RGB = Color3.fromRGB
getgenv().Hex = Color3.fromHex
getgenv().HSV = Color3.fromHSV

getgenv().Insert = table.insert
getgenv().Remove = table.remove
getgenv().Clear  = table.clear
getgenv().Find = table.find

getgenv().Camera = WS.CurrentCamera
getgenv().Player = {
    Player = Players.LocalPlayer,
    Character = Players.LocalPlayer.Character,
    HRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"),
    Mouse = Players.LocalPlayer:GetMouse()
}


--// Helper Functions \\--
function Globals:Unload()
    for _, connection in ipairs(table.clone(Globals.connections)) do
        connection:Declarations()
    end

    Clear(Globals.connections)
    getgenv().Globals = nil
end
getgenv().Connection = function(signal, callback)
    if not signal or not callback then
        return
    end

    local connection = signal:Connect(callback)
    Insert(Globals.connections, connection)
    return connection
end
Globals.Tween = function(instance, property, time)
    if not inst or not prop then
        return
    end

    local tween = TS:Create(instance, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), property)
    tween:Play()
    return tween
end


--// Connections \\--
Connection(WS:GetPropertyChangedSignal("CurrentCamera"), function()
    Camera = WS.CurrentCamera
end)

Connection(Player.Player.CharacterAdded, function(Character)
    Player.Character = Character
    Player.HRP = Character:WaitForChild("HumanoidRootPart")
end)
Connection(Player.Player.CharacterRemoving, function()
    Player.Character = nil
    Player.HRP = nil
end)
