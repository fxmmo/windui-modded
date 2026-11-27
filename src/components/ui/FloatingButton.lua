local FloatingButton = {}
local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween
local UserInputService = game:GetService("UserInputService")

local function resolvePosition(position)
	if typeof(position) == "UDim2" then
		return position
	end
	if typeof(position) == "Vector2" then
		return UDim2.fromOffset(position.X, position.Y)
	end
	return UDim2.new(1, -72, 1, -72)
end

local function resolveSize(size, width, height)
	if typeof(size) == "UDim2" then
		return size
	end
	if typeof(size) == "Vector2" then
		return UDim2.fromOffset(size.X, size.Y)
	end
	local defaultSize = type(size) == "number" and size or 52
	return UDim2.fromOffset(width or defaultSize, height or defaultSize)
end

local function clampToViewport(position, button)
	local Camera = workspace.CurrentCamera
	if not Camera then
		return position
	end

	local ViewportSize = Camera.ViewportSize
	local ButtonSize = button.AbsoluteSize
	local AnchorPoint = button.AnchorPoint
	local TargetPosition = Vector2.new(
		position.X.Scale * ViewportSize.X + position.X.Offset,
		position.Y.Scale * ViewportSize.Y + position.Y.Offset
	)
	local Minimum = Vector2.new(
		ButtonSize.X * AnchorPoint.X,
		ButtonSize.Y * AnchorPoint.Y
	)
	local Maximum = Vector2.new(
		ViewportSize.X - ButtonSize.X * (1 - AnchorPoint.X),
		ViewportSize.Y - ButtonSize.Y * (1 - AnchorPoint.Y)
	)

	return UDim2.fromOffset(
		math.clamp(TargetPosition.X, Minimum.X, math.max(Minimum.X, Maximum.X)),
		math.clamp(TargetPosition.Y, Minimum.Y, math.max(Minimum.Y, Maximum.Y))
	)
end

function FloatingButton.New(Config, Parent, WindUI)
	Config = Config or {}
	local Style = Config.Style or {}
	local function option(name, fallback)
		if Config[name] ~= nil then return Config[name] end
		if Style[name] ~= nil then return Style[name] end
		return fallback
	end
	local Variant = Config.Variant or "Primary"
	local Radius = option("Radius", option("CornerRadius", Config.FullRounded == false and 12 or 999))
	local Shape = option("Shape", "Squircle")
	local Size = option("Size", 52)
	local ButtonSize = resolveSize(Size, option("Width"), option("Height"))
	local BackgroundColor = option("BackgroundColor3", Variant == "White" and Color3.new(1, 1, 1) or nil)
	local BackgroundTransparency = option("BackgroundTransparency", Variant == "Secondary" and 0.08 or 0)
	local OutlineColor = option("OutlineColor3")
	local OutlineTransparency = option("OutlineTransparency", 0.86)
	local ShadowColor = option("ShadowColor3", Color3.new(0, 0, 0))
	local ShadowTransparency = option("ShadowTransparency", 0.78)
	local HoverTransparency = option("HoverTransparency", Variant == "Secondary" and 0.18 or 0.08)
	local HoverScale = option("HoverScale", 1.04)
	local IconData = Creator.Icon(Config.Icon)
	local IconSize = option("IconSize", 22)
	local IconColor = option("IconColor3", Variant == "White" and Color3.new(0, 0, 0) or nil)
	local IconTransparency = option("IconTransparency", Variant == "White" and 0.35 or 0)
	local TextColor = option("TextColor3", Variant == "White" and Color3.new(0, 0, 0) or nil)
	local TextSize = option("TextSize", 14)
	local Padding = option("Padding", 6)
		-- Keep floating buttons behind the window by default. Users can override this with Config.ZIndex.
		local ZIndex = Config.ZIndex ~= nil and Config.ZIndex or -100
	local InitialPosition = resolvePosition(Config.Position)

	local IconFrame
	if IconData then
		IconFrame = New("ImageLabel", {
			Name = "Icon",
			Image = IconData[1],
			ImageRectSize = IconData[2].ImageRectSize,
			ImageRectOffset = IconData[2].ImageRectPosition,
				Size = typeof(IconSize) == "Vector2" and UDim2.fromOffset(IconSize.X, IconSize.Y)
					or UDim2.fromOffset(IconSize, IconSize),
				BackgroundTransparency = 1,
				ThemeTag = IconColor and nil or { ImageColor3 = "Icon" },
				ImageColor3 = IconColor,
				ImageTransparency = IconTransparency,
		})
	end

	local Button = New("TextButton", {
		Name = Config.Name or "FloatingButton",
		Parent = Parent,
			Size = ButtonSize,
		Position = InitialPosition,
		AnchorPoint = Config.AnchorPoint or Vector2.new(0.5, 0.5),
			ZIndex = ZIndex,
		BackgroundTransparency = 1,
		Text = "",
		Active = true,
	}, {
		New("UIScale", {
			Scale = 1,
		}),
		Creator.NewRoundFrame(Radius, "Squircle", {
			Name = "Shadow",
			Size = UDim2.new(1, 5, 1, 5),
			AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageColor3 = ShadowColor,
				ImageTransparency = ShadowTransparency,
				ZIndex = ZIndex - 2,
		}),
		Creator.NewRoundFrame(Radius, "Squircle", {
			Name = "Background",
			Size = UDim2.fromScale(1, 1),
				ThemeTag = BackgroundColor and nil or { ImageColor3 = "Button" },
				ImageColor3 = BackgroundColor,
				ImageTransparency = BackgroundTransparency,
				ZIndex = ZIndex - 1,
		}),
			Creator.NewRoundFrame(Radius, option("OutlineShape", "SquircleGlass"), {
			Name = "Outline",
			Size = UDim2.new(1, 1, 1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
				ThemeTag = OutlineColor and nil or { ImageColor3 = "White" },
				ImageColor3 = OutlineColor,
				ImageTransparency = OutlineTransparency,
			ZIndex = ZIndex,
		}),
		New("Frame", {
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
				ZIndex = ZIndex + 1,
		}, {
			New("UIListLayout", {
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Center",
				Padding = UDim.new(0, Padding),
		}),
			IconFrame,
			Config.Title and New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				AutomaticSize = "XY",
				FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
				Text = tostring(Config.Title),
					TextSize = TextSize,
					ThemeTag = TextColor and nil or { TextColor3 = Variant == "Primary" and "White" or "Text" },
					TextColor3 = TextColor,
					ZIndex = ZIndex + 2,
			}) or nil,
		}),
	})

	local Floating = {
		Button = Button,
		Destroyed = false,
		Dragging = false,
	}
	local PressedInput = nil
	local PressStart = nil
	local PressMoved = false
	local CLICK_TOLERANCE = 8

	local DragModule = Creator.Drag(Button, nil, function(dragging)
		Floating.Dragging = dragging
	end, clampToViewport)
	Floating.DragModule = DragModule

	Creator.AddSignal(Button.MouseEnter, function()
		Tween(Button.Background, 0.12, { ImageTransparency = HoverTransparency }):Play()
		Tween(Button.UIScale, 0.12, { Scale = HoverScale }):Play()
	end)
	Creator.AddSignal(Button.MouseLeave, function()
		Tween(Button.Background, 0.12, { ImageTransparency = BackgroundTransparency }):Play()
		Tween(Button.UIScale, 0.12, { Scale = 1 }):Play()
	end)
	Creator.AddSignal(Button.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			PressedInput = input
			PressStart = input.Position
			PressMoved = false
		end
	end)
	Creator.AddSignal(UserInputService.InputChanged, function(input)
		if not PressedInput or PressMoved then
			return
		end
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch)
			and (input == PressedInput or PressedInput.UserInputType == Enum.UserInputType.MouseButton1)
		then
			PressMoved = (input.Position - PressStart).Magnitude >= CLICK_TOLERANCE
		end
	end)
	Creator.AddSignal(UserInputService.InputEnded, function(input)
		if not PressedInput then
			return
		end
		local sameInput = input == PressedInput
			or (PressedInput.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1)
		if sameInput then
			local ShouldCallback = not PressMoved
			PressedInput = nil
			PressStart = nil
			PressMoved = false
			if ShouldCallback and Config.Callback and not Floating.Destroyed then
				Creator.SafeCallback(Config.Callback, Floating)
			end
		end
	end)

	function Floating:SetPosition(position)
		if self.Destroyed then return self end
		Button.Position = resolvePosition(position)
		return self
	end
	function Floating:GetPosition()
		return Button.Position
	end
	function Floating:SetSize(size, height)
		if not self.Destroyed then
			Button.Size = resolveSize(size, typeof(size) == "number" and size or nil, height)
		end
		return self
	end
	function Floating:SetVisible(value)
		if not self.Destroyed then Button.Visible = value ~= false end
		return self
	end
	function Floating:SetDraggable(value)
		DragModule:Set(value ~= false)
		return self
	end
	function Floating:Edit(values)
		values = values or {}
		if values.Position then self:SetPosition(values.Position) end
		if values.Size then self:SetSize(values.Size, values.Height) end
		if values.Width or values.Height then
			local currentSize = Button.AbsoluteSize
			Button.Size = UDim2.fromOffset(values.Width or currentSize.X, values.Height or currentSize.Y)
		end
		if values.Visible ~= nil then self:SetVisible(values.Visible) end
		if values.Callback then Config.Callback = values.Callback end
		if values.Title and Button.Content.Title then Button.Content.Title.Text = tostring(values.Title) end
		return self
	end
	function Floating:Destroy()
		if self.Destroyed then return end
		self.Destroyed = true
		Button:Destroy()
	end

	return Floating
end

return FloatingButton
