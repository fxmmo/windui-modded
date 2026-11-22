local FloatingButton = {}
local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local function resolvePosition(position)
	if typeof(position) == "UDim2" then
		return position
	end
	if typeof(position) == "Vector2" then
		return UDim2.fromOffset(position.X, position.Y)
	end
	return UDim2.new(1, -72, 1, -72)
end

function FloatingButton.New(Config, Parent, WindUI)
	Config = Config or {}
	local Variant = Config.Variant or "Primary"
	local Radius = Config.Radius or (Config.FullRounded == false and 12 or 999)
	local Size = Config.Size or 52
	local IconData = Creator.Icon(Config.Icon)
	local IconSize = Config.IconSize or 22
	local InitialPosition = resolvePosition(Config.Position)

	local IconFrame
	if IconData then
		IconFrame = New("ImageLabel", {
			Name = "Icon",
			Image = IconData[1],
			ImageRectSize = IconData[2].ImageRectSize,
			ImageRectOffset = IconData[2].ImageRectPosition,
			Size = UDim2.fromOffset(IconSize, IconSize),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = Variant == "White" and nil or "Icon",
			},
			ImageColor3 = Variant == "White" and Color3.new(0, 0, 0) or nil,
			ImageTransparency = Variant == "White" and 0.35 or 0,
		})
	end

	local Button = New("TextButton", {
		Name = Config.Name or "FloatingButton",
		Parent = Parent,
		Size = UDim2.fromOffset(Size, Size),
		Position = InitialPosition,
		AnchorPoint = Config.AnchorPoint or Vector2.new(0.5, 0.5),
		ZIndex = Config.ZIndex or 100,
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
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.78,
			ZIndex = (Config.ZIndex or 100) - 2,
		}),
		Creator.NewRoundFrame(Radius, "Squircle", {
			Name = "Background",
			Size = UDim2.fromScale(1, 1),
			ThemeTag = {
				ImageColor3 = Variant == "White" and nil or "Button",
			},
			ImageColor3 = Variant == "White" and Color3.new(1, 1, 1) or nil,
			ImageTransparency = Variant == "Secondary" and 0.08 or 0,
			ZIndex = (Config.ZIndex or 100) - 1,
		}),
		Creator.NewRoundFrame(Radius, "SquircleGlass", {
			Name = "Outline",
			Size = UDim2.new(1, 1, 1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ThemeTag = { ImageColor3 = "White" },
			ImageTransparency = 0.86,
			ZIndex = Config.ZIndex or 100,
		}),
		New("Frame", {
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = (Config.ZIndex or 100) + 1,
		}, {
			New("UIListLayout", {
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Center",
			Padding = UDim.new(0, 6),
		}),
			IconFrame,
			Config.Title and New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				AutomaticSize = "XY",
				FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
				Text = tostring(Config.Title),
				TextSize = Config.TextSize or 14,
				ThemeTag = { TextColor3 = Variant == "Primary" and "White" or "Text" },
				TextColor3 = Variant == "White" and Color3.new(0, 0, 0) or nil,
				ZIndex = (Config.ZIndex or 100) + 2,
			}) or nil,
		}),
	})

	local Floating = {
		Button = Button,
		Destroyed = false,
		Dragging = false,
	}

	local DragModule = Creator.Drag(Button, nil, function(dragging)
		Floating.Dragging = dragging
	end)
	Floating.DragModule = DragModule

	Creator.AddSignal(Button.MouseEnter, function()
		Tween(Button.Background, 0.12, { ImageTransparency = Variant == "Secondary" and 0.18 or 0.08 }):Play()
		Tween(Button.UIScale, 0.12, { Scale = 1.04 }):Play()
	end)
	Creator.AddSignal(Button.MouseLeave, function()
		Tween(Button.Background, 0.12, { ImageTransparency = Variant == "Secondary" and 0.08 or 0 }):Play()
		Tween(Button.UIScale, 0.12, { Scale = 1 }):Play()
	end)
	Creator.AddSignal(Button.MouseButton1Click, function()
		if not Floating.Dragging and Config.Callback then
			Creator.SafeCallback(Config.Callback, Floating)
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
