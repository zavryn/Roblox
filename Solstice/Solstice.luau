--[[
	Solstice UI Library
	-> Made by @zavryn
]]--


--//========================================
--// Services
--//========================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--//========================================
--// Aliases
--//========================================

local RGB = Color3.fromRGB
local New = Instance.new
local Vec2New = Vector2.new
local Dim2New = UDim2.new
local DimNew = UDim.new

--//========================================
--// Library Setup
--//========================================

local Flux = loadstring(game:HttpGet("https://raw.githubusercontent.com/zavryn/Roblox/refs/heads/main/Flux/Flux.luau"))()
if not Flux then
	warn("[Solstice] Failed to Load Flux.")
	return
end

local Solstice = {
	Registry = {},
	CurrentTheme = nil
}

local LocalPlayer = Players.LocalPlayer

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

--//========================================
--// Functions
--//========================================

--// Theme Management
function Solstice.RegisterThemeValue(object: Instance, properties: {}): ()
	if not object or typeof(properties) ~= "table" then
		return
	end
	
	local data = Solstice.Registry[object] or {ThemeProperties = {}}
	for property, value in pairs(properties) do
		data.ThemeProperties[property] = value
	end
end

function Solstice.SetThemeValue(object: Instance, properties: {}): {}?
	if not object or typeof(properties) ~= "table" or not Solstice.CurrentTheme then
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
		Solstice.RegisterThemeValue(object, themeProperties)
	end
	
	return themeProperties
end

function Solstice.SetTheme(newThemeName: string): boolean
	local newTheme = THEMES[newThemeName]
    if not newTheme then
        warn(`[Solstice] Unknown Theme: {newThemeName}`)
		return false
	end
	
	Solstice.CurrentTheme = newTheme
	
	for object, data in Solstice.Registry do
		if not object.Parent then
			Solstice.Registry[object] = nil
			continue
		end
		
		for property, value in pairs(data.ThemeProperties) do
			if typeof(value) == "string" then
				local resolved = newTheme[value]
				if resolved ~= nil then
					object[property] = resolved
				end
			elseif typeof(value) == "table" and value.Type == "ColorSequence" then
				local keypoints = {}

				for _, keypoint in ipairs(value.Keypoints) do
					local time = keypoint[1]
					local color = keypoint[2]

					if typeof(color) == "string" then
						color = newTheme[color] or color
					end

					table.insert(keypoints, ColorSequenceKeypoint.new(time, color))
				end

				object[property] = ColorSequence.new(keypoints)
			end
		end
    end
    
    return true
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

function Solstice.CreateStroke(parent: Instance, color: Color3? | string?, transparency: number?, borderStrokePosition: Enum.BorderStrokePosition?): UIStroke?
	return Solstice.Create("UIStroke", {
		Parent = parent,
		Color = color or RGB(255, 255, 255),
		Transparency = transparency or 0,
		BorderStrokePosition = borderStrokePosition or Enum.BorderStrokePosition.Outer
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

function Solstice:Window(properties: {}?): {}
    properties = properties or {}
    
    local window = setmetatable({
        Instances = {},
        ActivePage = nil,
        _visible = true,
        _draggable = true,
        _keybindConnection = nil,
        _properties = {
            Title = properties.Title or "Title",
            Subtitle = properties.Subtitle or "Subtitle",
            Logo = properties.Logo or "rbxassetid://98988085004726",
            ToggleKey = properties.ToggleKey or Enum.KeyCode.LeftControl
        }
    }, WindowMethods)
    
    local instances = window.Instances
    Solstice.CurrentTheme = THEMES[properties.Theme] or THEMES.Ember
    
    --// Screen
    instances["screen"] = Solstice.Create("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    Flux._maid:GiveTask(instances["screen"])

    --// Background
    instances["background"] = Solstice.Create("Frame", {
        Parent = instances["screen"],
        BackgroundColor3 = RGB(0, 0, 0),
        BackgroundTransparency = 0.25,
        Size = Dim2New(1, 0, 1, 0)
    })

    --// Main
    instances["main"] = Solstice.Create("Frame", {
        Parent = instances["screen"],
        BackgroundColor3 = "WindowBG",
        BackgroundTransparency = 0.5,
        Position = Dim2New(0.5, -640, 0.5, -425),
        Size = Dim2New(0, 1280, 0, 850)
    })
    Solstice.CreateCorner(instances["main"], DimNew(0, 12))
    Solstice.CreateStroke(instances["main"], "Border")

    instances["blur"] = Solstice.Create("ImageLabel", {
        Parent = instances["main"],
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
    instances["sidebar"] = Solstice.Create("Frame", {
        Parent = instances["main"],
        BackgroundColor3 = "SidebarBG",
        Size = Dim2New(0, 160, 1, 0)
    })
    Solstice.Create("UICorner", {
        Parent = instances["sidebar"],
        BottomLeftRadius = DimNew(0, 12),
        TopLeftRadius = DimNew(0, 12),
        BottomRightRadius = DimNew(0, 0),
        TopRightRadius = DimNew(0, 0)
    })
    Solstice.Create("Frame", {
        Parent = instances["sidebar"],
        BackgroundColor3 = "Border",
        Position = Dim2New(1, -1, 0, 0),
        Size = Dim2New(0, 1, 1, 0)
    })

    -- Top Section
    instances["logoBackground"] = Solstice.Create("Frame", {
        Parent = instances["sidebar"],
        BackgroundColor3 = "Element",
        Position = Dim2New(0, 8, 0, 8),
        Size = Dim2New(0, 31, 0, 31)
    })
    Solstice.CreateCorner(instances["logoBackground"], DimNew(0, 8))
    Solstice.Create("ImageLabel", {
        Parent = instances["logoBackground"],
        Position = Dim2New(0, 3, 0, 3),
        Size = Dim2New(0, 25, 0, 25),
        Image = window._properties.Logo or "rbxassetid://98988085004726"
    })

    Solstice.Create("TextLabel", {
        Parent = instances["sidebar"],
        Position = Dim2New(0, 44, 0, 7),
        Size = Dim2New(1, -54, 0, 16),
        Text = window._properties.Title,
        TextColor3 = "ActiveText",
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Solstice.Create("TextLabel", {
        Parent = instances["sidebar"],
        Position = Dim2New(0, 44, 0, 23),
        Size = Dim2New(1, -54, 0, 12),
        Text = window._properties.Subtitle,
        TextColor3 = "InactiveText",
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- User Section
    instances["thumbnail"] = Solstice.Create("ImageLabel", {
        Parent = instances["sidebar"],
        BackgroundColor3 = "Element",
        BackgroundTransparency = 0,
        Position = Dim2New(0, 8, 1, -39),
        Size = Dim2New(0, 31, 0, 31),
        Image = `rbxthumb://type=AvatarHeadShot&id={LocalPlayer.UserId}&w=420&h=420`
    })
    Solstice.CreateCorner(instances["thumbnail"], DimNew(1, 0))

    instances["displayName"] = Solstice.Create("TextLabel", {
        Parent = instances["sidebar"],
        Position = Dim2New(0, 44, 1, -40),
        Size = Dim2New(1, -54, 0, 16),
        Text = LocalPlayer.DisplayName,
        TextColor3 = "ActiveText",
        TextXAlignment = Enum.TextXAlignment.Left
    })
    instances["username"] = Solstice.Create("TextLabel", {
        Parent = instances["sidebar"],
        Position = Dim2New(0, 44, 1, -24),
        Size = Dim2New(1, -54, 0, 12),
        Text = `@{LocalPlayer.Name}`,
        TextColor3 = "InactiveText",
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Category Section
    instances["categorySection"] = Solstice.Create("Frame", {
        Parent = instances["sidebar"],
        BackgroundTransparency = 1,
        Position = Dim2New(0, 8, 0, 59),
        Size = Dim2New(1, -16, 1, -119)
    })
    Solstice.CreateListLayout(instances["categorySection"], DimNew(0, 15))

    --// Topbar
    instances["topbar"] = Solstice.Create("Frame", {
        Parent = instances["main"],
        BackgroundTransparency = 1,
        Position = Dim2New(0, 160, 0, 0),
        Size = Dim2New(0.875, 0, 0, 39),
        ClipsDescendants = true
    })
    Solstice.Create("Frame", {
        Parent = instances["topbar"],
        BackgroundColor3 = "WindowBG",
        Position = Dim2New(0, 0, 1, -1),
        Size = Dim2New(1, 0, 0, 1)
    })

    instances["topbarTabsContainers"] = Solstice.Create("Frame", {
        Parent = instances["topbar"],
        BackgroundTransparency = 1,
        Position = Dim2New(0, 8, 0, 8),
        Size = Dim2New(1, -100, 1, -16),
        ClipsDescendants = true
    })

    --// Content
    instances["content"] = Solstice.Create("Frame", {
        Parent = instances["main"],
        BackgroundTransparency = 1,
        Position = Dim2New(0, 168, 0, 47),
        Size = Dim2New(0.875, -16, 1, -55),
        ClipsDescendants = true
    })

    Solstice.Create("ImageLabel", {
        Parent = instances["content"],
        Size = Dim2New(1, 0, 1, 0),
        ImageColor3 = "InactiveText",
        Image = "rbxassetid://100962937028829",
        ImageTransparency = 0.9,
        ResampleMode = Enum.ResamplerMode.Pixelated,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = Dim2New(0, 18, 0, 18)
    })

    --// Behavior
    window:Drag()
    
    window._keybindConnection = Solstice.Keybind(window._properties.ToggleKey, function()
        window:ToggleVisible()
    end)
    Solstice.Keybind(Enum.KeyCode.Delete, function()
        window:Unload()
    end)

    --// Return
    return window
end

--//========================================
--// Window Methods
--//========================================

function WindowMethods:ToggleVisible(): ()
    self._visible = not self._visible
    self.Instances["main"].Visible = self._visible
    self.Instances["background"].Visible = self._visible
end

function WindowMethods:Unload(): ()
    Flux.Destroy()
end

function WindowMethods:Drag()
    --// Variables
    local main = self.Instances["main"]
    local size = main.AbsoluteSize
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.zero
    local inset = GuiService:GetGuiInset().Y
    
    local GAP = 1
    
    local dragging = {
        Enabled = false,
        StartInputPos = nil,
        StartPos = nil
    }
    local interpolation = {
        Current = Vec2New((viewport.X - size.X) / 2, (viewport.Y - size.Y) / 2),
        Target = Vec2New((viewport.X - size.X) / 2, (viewport.Y - size.Y) / 2)
    }
    
    --// Functions
    local function began(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self._draggable then
            dragging.Enabled = true
            dragging.StartInputPos = input.Position
            dragging.StartPos = interpolation.Current
        end
    end
    
    local function ended(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging.Enabled = false
        end
    end
    
    local function changed(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging.Enabled then
            local delta = input.Position - dragging.StartInputPos
            interpolation.Target = dragging.StartPos + Vec2New(delta.X, delta.Y)
        end
    end
    
    --// Connections
    Flux.InputBegan(self.Instances["topbar"], began)
    Flux.InputBegan(self.Instances["sidebar"], began)
    Flux.InputEnded(UserInputService, ended)
    Flux.InputChanged(UserInputService, changed)
    
    Flux.Connect(RunService.Heartbeat:Connect(function(dt)
        local maxX = math.max(GAP, viewport.X - size.X - GAP)
        local maxY = math.max(inset + GAP, viewport.Y - size.Y - GAP)
        interpolation.Target = Vec2New(
            math.clamp(interpolation.Target.X, GAP, maxX),
            math.clamp(interpolation.Target.Y, inset + GAP, maxY)
        )
        
        local delta = interpolation.Target - interpolation.Current
        interpolation.Current += delta * math.min(dt * 20, 1)
        main.Position = UDim2.fromOffset(interpolation.Current.X, interpolation.Current.Y)
    end))
end

--//========================================
--// Category Construction
--//========================================

local CategoryMethods = {}
CategoryMethods.__index = CategoryMethods

function WindowMethods:Category(title: string): {}
    local category = setmetatable({
        Instances = {},
        Window = self
    }, CategoryMethods)
    
    local instances = category.Instances
    
    --// Category Container
    instances["container"] = Solstice.Create("Frame", {
        Parent = self.Instances["categorySection"],
        BackgroundTransparency = 1,
        Size = Dim2New(1, 0, 0, 12)
    })

    --// Title
    instances["title"] = Solstice.Create("TextLabel", {
        Parent = instances["container"],
        Size = Dim2New(1, 0, 0, 12),
        Text = title,
        TextColor3 = "PlaceholderText",
        TextXAlignment = Enum.TextXAlignment.Left
    })

    --// Pages
    instances["pageContainer"] = Solstice.Create("Frame", {
        Parent = instances["container"],
        BackgroundTransparency = 1,
        Position = Dim2New(0, 0, 0, 19),
        Size = Dim2New(1, 0, 1, -19)
    })
    instances["pageListLayout"] = Solstice.CreateListLayout(instances["pageContainer"], DimNew(0, 5))
    
    --// Functions
    local TITLE_SIZE = instances["title"].TextSize
    local TITLE_GAP = 7
    
    local function UpdateCategorySize()
        local height = TITLE_SIZE + TITLE_GAP + instances["pageListLayout"].AbsoluteContentSize.Y
        instances["container"].Size = Dim2New(1, 0, 0, height)
    end
    
    --// Connections
    instances["pageContainer"].ChildAdded:Connect(UpdateCategorySize)
    instances["pageContainer"].ChildRemoved:Connect(UpdateCategorySize)
    
    Flux.MouseEnter(instances["container"], function()
        self._draggable = false
    end)
    
    Flux.MouseLeave(instances["container"], function()
        self._draggable = true
    end)
    
    --// Return
    return category
end

--//========================================
--// Page Construction
--//========================================

local PageMethods = {}
PageMethods.__index = PageMethods

function CategoryMethods:Page(title: string, icon: string?): {}
    local page = setmetatable({
        Instances = {},
        ActiveTab = nil,
        Window = self.Window
    }, PageMethods)
    
    local instances = page.Instances
    local active = self.Window.ActivePage == nil
    
    --// Page
    instances["page"] = Solstice.Create("Frame", {
        Parent = self.Instances["pageContainer"],
        BackgroundColor3 = active and "Element" or "SidebarBG",
        Size = Dim2New(1, 0, 0, 17)
    })
    Solstice.CreateCorner(instances["page"], DimNew(0, 6))

    instances["pageTitle"] = Solstice.Create("TextLabel", {
        Parent = instances["page"],
        Position = Dim2New(0, 21, 0, 1),
        Size = Dim2New(1, -26, 0, 15),
        Text = title or "Title",
        TextColor3 = active and "ActiveText" or "InactiveText",
        TextXAlignment = Enum.TextXAlignment.Left
    })

    instances["pageIcon"] = Solstice.Create("ImageLabel", {
        Parent = instances["page"],
        Position = Dim2New(0, 1, 0, 1),
        Size = Dim2New(0, 15, 0, 15),
        ImageColor3 = active and "Accent" or "InactiveText",
        Image = icon or "rbxassetid://6034767621"
    })

    --// Topbar Tabs Container
    instances["topbarTabs"] = Solstice.Create("Frame", {
        Parent = self.Window.Instances["topbarTabsContainers"],
        BackgroundTransparency = 1,
        Position = Dim2New(0, 0, -1, 0),
        Size = Dim2New(1, 0, 1, 0)
    })
    Solstice.CreateListLayout(instances["topbarTabs"], DimNew(0, 10), Enum.FillDirection.Horizontal)

    --// Page Content Container
    instances["contentContainer"] = Solstice.Create("Frame", {
        Parent = self.Window.Instances["content"],
        BackgroundTransparency = 1,
        Size = Dim2New(1, 0, 1, 0),
        ClipsDescendants = true
    })
    
    --// Connections
    Flux.MouseEnter(instances["page"], function()
        if self.Window.ActivePage == page then
            return
        end
        
        local theme = Solstice.CurrentTheme
        Flux.Tween(instances["pageTitle"], {TextColor3 = theme.Text})
        Flux.Tween(instances["pageIcon"], {ImageColor3 = theme.Text})
    end)
    
    Flux.MouseLeave(instances["page"], function()
        if self.Window.ActivePage == page then
            return
        end

        local theme = Solstice.CurrentTheme
        Flux.Tween(instances["pageTitle"], {TextColor3 = theme.InactiveText})
        Flux.Tween(instances["pageIcon"], {ImageColor3 = theme.InactiveText})
    end)
    
    Flux.InputBegan(instances["page"], function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            page:Activate()
        end
    end)
    
    --// Behavior
    if active then
        page:Activate()
    end
    
    --// Return
    return page
end

--//========================================
--// Page Methods
--//========================================

function PageMethods:Activate()
    --// Variables
    local previous = self.Window.ActivePage
    if previous == self then
        return
    end
    
    local instances = self.Instances
    local theme = Solstice.CurrentTheme
    
    --// New Page
    instances["topbarTabs"].Position = Dim2New(0, 0, -1, 0)
    Flux.Tween(instances["topbarTabs"], {Position = Dim2New(0, 0, 0, 0)})
    Flux.Tween(instances["page"], {BackgroundColor3 = theme.Element})
    Flux.Tween(instances["pageTitle"], {TextColor3 = theme.ActiveText})
    Flux.Tween(instances["pageIcon"], {ImageColor3 = theme.Accent})
    Flux.Tween(instances["contentContainer"], {Position = Dim2New(0, 0, 0, 0)})
    Solstice.RegisterThemeValue(instances["page"], {BackgroundColor3 = "Element"})
    Solstice.RegisterThemeValue(instances["pageTitle"], {TextColor3 = "ActiveText"})
    Solstice.RegisterThemeValue(instances["pageIcon"], {ImageColor3 = "Accent"})
    
    --//  Page
    if previous then
        local oldInstances = previous.Instances
        
        Flux.Tween(oldInstances["topbarTabs"], {Position = Dim2New(0, 0, 1, 0)})
        Flux.Tween(oldInstances["page"], {BackgroundColor3 = theme.SidebarBG})
        Flux.Tween(oldInstances["pageTitle"], {TextColor3 = theme.InactiveText})
        Flux.Tween(oldInstances["pageIcon"], {ImageColor3 = theme.InactiveText})
        Solstice.RegisterThemeValue(oldInstances["page"], {BackgroundColor3 = "SidebarBG"})
        Solstice.RegisterThemeValue(oldInstances["pageTitle"], {TextColor3 = "InactiveText"})
        Solstice.RegisterThemeValue(oldInstances["pageIcon"], {ImageColor3 = "InactiveText"})
        
        if instances["contentContainer"] ~= oldInstances["contentContainer"] then
            instances["contentContainer"].Position = Dim2New(1, 0, 0, 0)
            Flux.Tween(oldInstances["contentContainer"], {Position = Dim2New(-1, 0, 0, 0)})
        end
    end
    
    --// Set ActivePage
    self.Window.ActivePage = self
end

--//========================================
--// Tab Construction
--//========================================

local TabMethods = {}
TabMethods.__index = TabMethods

function PageMethods:Tab(title: string): {}
    local tab = setmetatable({
        Instances = {},
        Page = self
    }, TabMethods)
    
    local instances = tab.Instances
    local active = self.ActiveTab == nil
    
    --// Topbar Title
    instances["topbarTitle"] = Solstice.Create("TextLabel", {
        Parent = self.Instances["topbarTabs"],
        Size = Dim2New(0, 1000, 0, 23),
        Text = title or "Tab",
        TextColor3 = "InactiveText",
        TextScaled = false,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    instances["topbarTitle"].Size = Dim2New(0, instances["topbarTitle"].TextBounds.X, 0, 23)

    --// Topbar Accent
    instances["topbarAccent"] = Solstice.Create("Frame", {
        Parent = instances["topbarTitle"],
        BackgroundColor3 = "Accent",
        Position = Dim2New(0.5, 0, 1, -2),
        Size = Dim2New(0, 0, 0, 2)
    })

    --// Content Container
    instances["contentContainer"] = Solstice.Create("Frame", {
        Parent = self.Instances["contentContainer"],
        BackgroundTransparency = 1,
        Position = Dim2New(1, 0, 0, 0),
        Size = Dim2New(1, 0, 1, 0),
        ClipsDescendants = true
    })

    instances["leftContainer"] = Solstice.Create("ScrollingFrame", {
        Parent = instances["contentContainer"],
        Size = Dim2New(0.5, -5, 1, 0)
    })
    Solstice.CreateListLayout(instances["leftContainer"], DimNew(0, 10))

    instances["rightContainer"] = Solstice.Create("ScrollingFrame", {
        Parent = instances["contentContainer"],
        Position = Dim2New(0.5, 5, 0, 0),
        Size = Dim2New(0.5, -5, 1, 0)
    })
    Solstice.CreateListLayout(instances["rightContainer"], DimNew(0, 10))
    
    --// Connections
    Flux.MouseEnter(instances["topbarTitle"], function()
        if self.ActiveTab == tab then
            return
        end
        
        self.Window._draggable = false
        Flux.Tween(instances["topbarTitle"], {TextColor3 = Solstice.CurrentTheme.Text})
    end)
    
    Flux.MouseLeave(instances["topbarTitle"], function()
        if self.ActiveTab == tab then
            return
        end

        self.Window._draggable = true
        Flux.Tween(instances["topbarTitle"], {TextColor3 = Solstice.CurrentTheme.InactiveText})
    end)
    
    Flux.InputBegan(instances["topbarTitle"], function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tab:Activate()
        end
    end)
    
    --// Behavior
    if active then
        tab:Activate()
    end
    
    --// Return
    return tab
end

--//========================================
--// Tab Methods
--//========================================

function TabMethods:Activate()
    --// Variables
    local previous = self.Page.ActiveTab
    if previous == self then
        return
    end
    
    local instances = self.Instances
    local theme = Solstice.CurrentTheme
    
    --// New Tab
    instances["contentContainer"].Position = Dim2New(1, 0, 0, 0)
    Flux.Tween(instances["contentContainer"], {Position = Dim2New(0, 0, 0, 0)})
    Flux.Tween(instances["topbarAccent"], {Size = Dim2New(0.8, 0, 0, 2)})
    Flux.Tween(instances["topbarAccent"], {Position = Dim2New(0.1, 0, 1, -2)})
    Flux.Tween(instances["topbarTitle"], {TextColor3 = theme.ActiveText})
    Solstice.RegisterThemeValue(instances["topbarTitle"], {TextColor3 = "ActiveText"})
    
    --// Old Tab
    if previous then
        local oldInstances = previous.Instances
        
        Flux.Tween(oldInstances["contentContainer"], {Position = Dim2New(-1, 0, 0, 0)})
        Flux.Tween(oldInstances["topbarAccent"], {Size = Dim2New(0, 0, 0, 2)})
        Flux.Tween(oldInstances["topbarAccent"], {Position = Dim2New(0.5, 0, 1, -2)})
        Flux.Tween(oldInstances["topbarTitle"], {TextColor3 = theme.InactiveText})
        Solstice.RegisterThemeValue(oldInstances["topbarTitle"], {TextColor3 = "InactiveText"})
    end
    
    -- Set ActiveTab
    self.Page.ActiveTab = self
end

--//========================================
--// Return Library
--//========================================

return Solstice
