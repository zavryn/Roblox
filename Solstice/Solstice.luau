--[[
	Solstice UI Library
	-> Made by @zavryn
]]--


--//========================================
--// Services
--//========================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

--//========================================
--// Aliases
--//========================================

local RGB = Color3.fromRGB
local New = Instance.new
local Vec3New = Vector3.new
local Vec2New = Vector2.new
local Dim2New = UDim2.new
local DimNew = UDim.new

--//========================================
--// Library Setup
--//========================================

local Flux = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Flux.luau"))

local Solstice = {
	Registry = {},

	CurrentTheme = nil,
	PreventDrag = false,
	ActivePage = nil
}

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

--//========================================
--// Constants
--//========================================

local THEMES = {
	Ember = {
		WindowBG = RGB(29, 18, 16),
		SectionBG = RGB(25, 15, 14),
		SidebarBG = RGB(11, 7, 6),

		Border = RGB(61, 47, 43),
		Accent = RGB(191, 96, 50),

		Text = RGB(255, 227, 210),
		ActiveText = RGB(255, 255, 255),
		InactiveText = RGB(178, 156, 144),
		RiskyText = RGB(235, 80, 80),
		PlaceholderText = RGB(137, 119, 109),

		Element = RGB(41, 31, 28),
		ElementHover = RGB(56, 43, 39),

		DarkLiner = RGB(21, 7, 0)
	}
}

local DEFAULT_VALUES = {
	Frame = {
		BorderSizePixel = 0
	},

	ScrollingFrame = {
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = Dim2New(0, 0, 0, 0),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	},

	TextLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.BuilderSans,
		RichText = true,
		TextScaled = true
	},

	TextBox = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.BuilderSans,
		TextScaled = true
	},

	ImageLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}
}

local KEYS = {
	[Enum.KeyCode.LeftShift] = "LShift",
	[Enum.KeyCode.RightShift] = "RShift",
	[Enum.KeyCode.LeftControl] = "LCtrl",
	[Enum.KeyCode.RightControl] = "RCtrl",
	[Enum.KeyCode.LeftAlt] = "LAlt",
	[Enum.KeyCode.RightAlt] = "RAlt",
	[Enum.KeyCode.Backspace] = "Back",
	[Enum.KeyCode.Return] = "Enter",
	[Enum.KeyCode.CapsLock] = "Caps",
	[Enum.KeyCode.Insert] = "Ins",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.Semicolon] = ",",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Backquote] = "`",
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "Esc",
	[Enum.KeyCode.Space] = "Space",
}

--//========================================
--// Functions
--//========================================

--// Theme Management
function Solstice.SetThemeValue(object: Instance, properties: {}): {}?
	if not object or typeof(properties) ~= "table" then
		return
	end

	local themeProperties = {}
	for property, value in properties do
		if typeof(value) == "string" and Solstice.CurrentTheme[value] ~= nil then
			object[property] = Solstice.CurrentTheme[value]
			themeProperties[property] = value
		elseif typeof(value) == "table" then
			local keypoints = {}
			local themeKeypoints = {}

			for _, keypoint in ipairs(value) do
				local time = keypoint[1]
				local color = keypoint[2]

				table.insert(themeKeypoints, {time, color})

				if typeof(color) == "string" and Solstice.CurrentTheme[color] ~= nil then
					color = Solstice.CurrentTheme[color]
				end

				table.insert(keypoints, ColorSequenceKeypoint.new(time, color))
			end

			if #themeKeypoints > 0 then
				themeProperties[property] = {
					Type = "ColorSequence",
					Keypoints = themeKeypoints
				}
			end

			object[property] = ColorSequence.new(keypoints)
		else
			object[property] = value
		end
	end

	if next(themeProperties) then
		Solstice.Registry[object] = {
			ThemeProperties = themeProperties
		}
	end

	return themeProperties
end

function Solstice.SetTheme(newThemeName: string)
	local newTheme = THEMES[newThemeName]
	if not newTheme then
		return
	end

	Solstice.CurrentTheme = newTheme

	for object, data in Solstice.Registry do
		if not object.Parent then
			return
		end

		for property, value in pairs(data.ThemeProperties) do
			if typeof(value) == "string" then
				object[property] = newTheme[value]
			elseif typeof(value) == "table" and value.Type == "ColorSequence" then
				local keypoints = {}

				for _, keypoint in ipairs(value.Keypoints) do
					local time = keypoint[1]
					local color = keypoint[2]

					table.insert(keypoints, ColorSequenceKeypoint.new(time, color))
				end

				object[property] = ColorSequence.new(keypoints)
			end
		end
	end
end

--// UI
function Solstice.Create(class: string, properties: {}): Instance?
	if typeof(class) ~= "string" then
		return
	end

	local object = New(class)

	object.Name = "\0"
	for property, value in pairs(DEFAULT_VALUES[class] or {}) do
		object[property] = value
	end

	Solstice.SetThemeValue(object, properties)

	return object
end

function Solstice.CreateCorner(parent: Instance, radius: UDim?): UICorner?
	return Solstice.Create("UICorner", {
		Parent = parent,
		CornerRadius = radius or DimNew(0, 6)
	})
end

function Solstice.CreateStroke(parent: Instance, color: Color3?, transparency: number?): UIStroke?
	return Solstice.Create("UIStroke", {
		Parent = parent,
		Color = color or RGB(255, 255, 255),
		Transparency = transparency or 0
	})
end

function Solstice.CreateListLayout(parent: Instance, padding: UDim?, direction: Enum.FillDirection?, horizontalAlignment: Enum.HorizontalAlignment?): UIListLayout?
	return Solstice.Create("UIListLayout", {
		Parent = parent,
		Padding = padding or DimNew(0, 5),
		FillDirection = direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left,
	})
end

--// Misc
function Solstice.Keybind(key: EnumItem, callback: () -> ()): RBXScriptConnection?
	if typeof(key) ~= "EnumItem" or key.EnumType ~= Enum.KeyCode or typeof(callback) ~= "function" then
		return
	end
	
	return Flux.Connect(UserInputService.InputBegan, function(input, gpe)
		if input.KeyCode == key and not gpe then
			callback()
		end
	end)
end

--//========================================
--// Window Construction
--//========================================

local WindowMethods = {}
WindowMethods.__index = WindowMethods

function Solstice:Window(properties: {}): {}
	local window = setmetatable({
		Instances = {},
		_visible = true,
		_draggable = true,
		_theme = THEMES[properties.Theme] or THEMES["Ember"],
		_properties = {
			Title = properties.Title or "Title",
			Subtitle = properties.Subtitle or "Subtitle",
			Logo = properties.Logo or "rbxassetid://98988085004726",
			ToggleKey = properties.ToggleKey or Enum.KeyCode.LeftControl
		}
	}, WindowMethods)

	local inst = window.Instances
	Solstice.CurrentTheme = window._theme

	--// Screen
	inst["screen"] = Solstice.Create("ScreenGui", {
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global
	})

	--// Background
	inst["background"] = Solstice.Create("Frame", {
		Parent = inst["screen"],
		BackgroundColor3 = RGB(0, 0, 0),
		BackgroundTransparency = 0.25,
		Size = Dim2New(1, 0, 1, 0)
	})

	--// Main
	inst["main"] = Solstice.Create("Frame", {
		Parent = inst["screen"],
		BackgroundColor3 = "WindowBG",
		BackgroundTransparency = 0.5,
		Position = Dim2New(0.5, -640, 0.5, -425),
		Size = Dim2New(0, 1280, 0, 850)
	})
	Solstice.CreateCorner(inst["main"], DimNew(0, 12))
	Solstice.CreateStroke(inst["main"], "Border")

	inst["blur"] = Solstice.Create("ImageLabel", {
		Parent = inst["main"],
		Position = Dim2New(0, -50, 0, -50),
		Size = Dim2New(1, 100, 1, 100),
		ZIndex = -1,
		ImageColor3 = "Accent",
		Image = "rbxassetid://112971167999062",
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(112, 112, 147, 147),
		SliceScale = 0.75
	})
	
	--// Sidebar
	inst["sidebar"] = Solstice.Create("Frame", {
		Parent = inst["main"],
		BackgroundColor3 = "SidebarBG",
		Size = Dim2New(0, 160, 1, 0)
	})
	Solstice.Create("UICorner", {
		Parent = inst["sidebar"],
		BottomLeftRadius = DimNew(0, 12),
		TopLeftRadius = DimNew(0, 12),
		BottomRightRadius = DimNew(0, 0),
		TopRightRadius = DimNew(0, 0)
	})
	Solstice.Create("Frame", {
		Parent = inst["sidebar"],
		BackgroundColor3 = "Border",
		Position = Dim2New(1, -1, 0, 0),
		Size = Dim2New(0, 1, 1, 0)
	})
	
	-- Top Section
	inst["logoBackground"] = Solstice.Create("Frame", {
		Parent = inst["sidebar"],
		BackgroundColor3 = "Element",
		Position = Dim2New(0, 8, 0, 8),
		Size = Dim2New(0, 31, 0, 31)
	})
	Solstice.CreateCorner(inst["logoBackground"], DimNew(0, 8))
	Solstice.Create("ImageLabel", {
		Parent = inst["logoBackground"],
		Position = Dim2New(0, 3, 0, 3),
		Size = Dim2New(0, 25, 0, 25),
		Image = window._properties.Logo or "rbxassetid://98988085004726"
	})
	
	Solstice.Create("TextLabel", {
		Parent = inst["sidebar"],
		Position = Dim2New(0, 44, 0, 7),
		Size = Dim2New(1, -54, 0, 16),
		Text = window._properties.Title,
		TextColor3 = "ActiveText",
		TextXAlignment = Enum.TextXAlignment.Left
	})
	Solstice.Create("TextLabel", {
		Parent = inst["sidebar"],
		Position = Dim2New(0, 44, 0, 23),
		Size = Dim2New(1, -54, 0, 12),
		Text = window._properties.Subtitle,
		TextColor3 = "InactiveText",
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- User Section
	inst["thumbnail"] = Solstice.Create("ImageLabel", {
		Parent = inst["sidebar"],
		BackgroundColor3 = "Element",
		BackgroundTransparency = 0,
		Position = Dim2New(0, 8, 1, -39),
		Size = Dim2New(0, 31, 0, 31),
		Image = `rbxthumb://type=AvatarHeadShot&id={LocalPlayer.UserId}&w=420&h=420`
	})
	Solstice.CreateCorner(inst["thumbnail"], DimNew(1, 0))
	
	inst["displayName"] = Solstice.Create("TextLabel", {
		Parent = inst["sidebar"],
		Position = Dim2New(0, 44, 1, -40),
		Size = Dim2New(1, -54, 0, 16),
		Text = LocalPlayer.DisplayName,
		TextColor3 = "ActiveText",
		TextXAlignment = Enum.TextXAlignment.Left
	})
	inst["username"] = Solstice.Create("TextLabel", {
		Parent = inst["sidebar"],
		Position = Dim2New(0, 44, 1, -24),
		Size = Dim2New(1, -54, 0, 12),
		Text = `@{LocalPlayer.Name}`,
		TextColor3 = "InactiveText",
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Category Section
	inst["categorySection"] = Solstice.Create("Frame", {
		Parent = inst["sidebar"],
		BackgroundTransparency = 1,
		Position = Dim2New(0, 8, 0, 59),
		Size = Dim2New(1, -16, 1, -119)
	})
	Solstice.CreateListLayout(inst["categorySection"], DimNew(0, 15))
	
	--// Topbar
	inst["topbar"] = Solstice.Create("Frame", {
		Parent = inst["main"],
		BackgroundTransparency = 1,
		Position = Dim2New(0, 160, 0, 0),
		Size = Dim2New(0.875, 0, 0, 39)
	})
	Solstice.Create("Frame", {
		Parent = inst["topbar"],
		BackgroundColor3 = "WindowBG",
		Position = Dim2New(0, 0, 1, -1),
		Size = Dim2New(1, 0, 0, 1)
	})
	
	inst["topbarTabs"] = Solstice.Create("Frame", {
		Parent = inst["topbar"],
		BackgroundTransparency = 1,
		Position = Dim2New(0, 8, 0, 8),
		Size = Dim2New(1, -100, 1, -16)
	})
	Solstice.CreateListLayout(inst["topbarTabs"], DimNew(0, 10), Enum.FillDirection.Horizontal)
	
	--// Content
	inst["content"] = Solstice.Create("Frame", {
		Parent = inst["main"],
		BackgroundTransparency = 1,
		Position = Dim2New(0, 168, 0, 47),
		Size = Dim2New(0.875, -16, 1, -55)
	})
	
	Solstice.Create("ImageLabel", {
		Parent = inst["content"],
		Size = Dim2New(1, 0, 1, 0),
		ImageColor3 = "InactiveText",
		Image = "rbxassetid://100962937028829",
		ImageTransparency = 0.9,
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = Dim2New(0, 18, 0, 18)
	})
	
	--// Behaviour
	window:Drag()
	Solstice.Keybind(window._properties.ToggleKey, function()
		window:ToggleVisible()
	end)
	
	--// Return
	return window
end

--//========================================
--// Window Methods
--//========================================

function WindowMethods:ToggleVisible(...)
	self._visible = not self._visible
	self.Instances["main"].Visible = self._visible
	self.Instances["background"].Visible = self._visible
end

function WindowMethods:Unload()
	Flux._maid:Cleanup()
	
	self.Instances["screen"]:Destroy()

	table.clear(Solstice)
	Solstice = nil
end

function WindowMethods:Drag()
	local size = self.Instances["main"].AbsoluteSize
	local inset = GuiService:GetGuiInset().Y
	local viewport = CurrentCamera.ViewportSize

	local dragging = {
		Enabled = false,
		StartInput = nil,
		StartPos = nil
	}
	local interpolation = {
		Current = Vec2New((viewport.X - size.X) / 2, (viewport.Y - size.Y) / 2),
		Target = Vec2New((viewport.X - size.X) / 2, (viewport.Y - size.Y) / 2)
	}
	
	local function began(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self._draggable then
			dragging.Enabled = true
			dragging.StartPos = interpolation.Current
			dragging.StartInput = input.Position
		end
	end
	
	local function ended(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging.Enabled = false
		end
	end
	
	Flux.InputBegan(self.Instances["topbar"], began)
	Flux.InputEnded(self.Instances["topbar"], ended)
	
	Flux.InputBegan(self.Instances["sidebar"], began)
	Flux.InputEnded(self.Instances["sidebar"], ended)
	
	Flux.Connect(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging.Enabled then
			local delta = input.Position - dragging.StartInput
			interpolation.Target = dragging.StartPos + Vec2New(delta.X, delta.Y)
			interpolation.Target = Vec2New(math.clamp(interpolation.Target.X, 2, viewport.X - size.X - 1), math.clamp(interpolation.Target.Y, inset + 1, viewport.Y - size.Y - 1))
		end
	end))
	
	Flux.Connect(RunService.Heartbeat:Connect(function(dt)
		if self._draggable then
			local delta = (interpolation.Target - interpolation.Current)
			interpolation.Current += delta * math.min(dt * 20, 1)
			self.Instances["main"].Position = UDim2.fromOffset(interpolation.Current.X, interpolation.Current.Y)
		end
	end))
end

--//========================================
--// Category
--//========================================

local CategoryMethods = {}
CategoryMethods.__index = CategoryMethods

function WindowMethods:Category(title: string)
	local category = setmetatable({
		Instances = {}
	}, CategoryMethods)
	
	local inst = category.Instances
	
	--// Category Container
	inst["container"] = Solstice.Create("Frame", {
		Parent = self.Instances["categorySection"],
		BackgroundTransparency = 1,
		Size = Dim2New(1, 0, 0, 12)
	})
	
	--// Title
	inst["title"] = Solstice.Create("TextLabel", {
		Parent = inst["container"],
		Size = Dim2New(1, 0, 0, 12),
		Text = title,
		TextColor3 = "PlaceholderText",
		TextScaled = false,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	--// Pages
	inst["pageContainer"] = Solstice.Create("Frame", {
		Parent = inst["container"],
		BackgroundTransparency = 1,
		Position = Dim2New(0, 0, 0, 19),
		Size = Dim2New(1, 0, 1, -19)
	})
	Solstice.CreateListLayout(inst["pageContainer"], DimNew(0, 5))
	
	--// Behaviour
	inst["pageContainer"].ChildAdded:Connect(function()
		local pages = 0
		
		for _, child in ipairs(inst["pageContainer"]:GetChildren()) do
			if child:IsA("Frame") then
				pages += 1
			end
		end
		
		inst["container"].Size = Dim2New(1, 0, 0, 12 + 7 + (pages * 17) + ((pages - 1) * 5)) -- 12 = title size, 7 = padding between title and pageContainer
	end)
	
	--// Return
	return category
end

--//========================================
--// Return
--//========================================

return Solstice
