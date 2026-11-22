local Creator = require("../modules/Creator")
local New = Creator.New
local NewRoundFrame = Creator.NewRoundFrame

local Element = {}

local ElementModules = {
	Button = require("./Button"),
	Toggle = require("./Toggle"),
	Input = require("./Input"),
	Dropdown = require("./Dropdown"),
	Slider = require("./Slider"),
	ProgressBar = require("./ProgressBar"),
	Keybind = require("./Keybind"),
	Colorpicker = require("./Colorpicker"),
	Code = require("./Code"),
	Image = require("./Image"),
	Divider = require("./Divider"),
	Space = require("./Space"),
	Section = require("./Section"),
}

local function copyConfig(source)
	local result = {}
	for key, value in pairs(source or {}) do
		result[key] = value
	end
	return result
end

local function findElementFrame(content)
	if content.ImageFrame then
		return content.ImageFrame
	end
	for key, value in pairs(content) do
		if type(value) == "table" and key:match("Frame$") and value.UIElements and value.UIElements.Main then
			return value.UIElements.Main
		end
	end
	return nil
end

local function resolvePosition(position)
	if typeof(position) == "UDim2" then
		return position
	end
	if typeof(position) == "Vector2" then
		return UDim2.fromOffset(position.X, position.Y)
	end
	return UDim2.fromOffset(0, 0)
end

function Element:New(Config)
	local Style = Config.Style or {}
	local function option(name, fallback)
		if Config[name] ~= nil then return Config[name] end
		if Style[name] ~= nil then return Style[name] end
		return fallback
	end

	local Card = {
		__type = "Card",
		Title = Config.Title or "",
		Desc = Config.Desc,
		Elements = {},
		UIElements = {},
	}
	local CardPadding = option("Padding", Config.Window.ElementConfig.UIPadding)
	local HeaderHeight = option("HeaderHeight", (Card.Title ~= "" or Card.Desc) and 48 or 0)
	local CardSize = typeof(Config.Size) == "number" and UDim2.new(1, 0, 0, Config.Size)
		or Config.Size
		or UDim2.new(1, 0, 0, option("Height", 220))
	local BackgroundColor = option("BackgroundColor3")
	local BackgroundTransparency = option("BackgroundTransparency", 0.08)
	local Radius = option("Radius", Config.Window.ElementConfig.UICorner)
	local ZIndex = option("ZIndex", 1)

	local Header = New("Frame", {
		Name = "Header",
		Size = UDim2.new(1, -CardPadding * 2, 0, HeaderHeight),
		Position = UDim2.fromOffset(CardPadding, CardPadding),
		BackgroundTransparency = 1,
		ZIndex = ZIndex + 2,
	}, {
		New("UIListLayout", {
			FillDirection = "Vertical",
			VerticalAlignment = "Center",
			Padding = UDim.new(0, 2),
		}),
		New("TextLabel", {
			Name = "Title",
			Text = Card.Title,
			TextSize = option("TitleSize", 17),
			FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
			TextXAlignment = "Left",
			TextWrapped = true,
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Name = "Desc",
			Text = Card.Desc or "",
			TextSize = option("DescSize", 14),
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			TextXAlignment = "Left",
			TextWrapped = true,
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			TextTransparency = 0.25,
			ThemeTag = { TextColor3 = "Text" },
		}),
	})

	local Content = New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -CardPadding * 2, 1, -(HeaderHeight + CardPadding * 2)),
		Position = UDim2.fromOffset(CardPadding, HeaderHeight + CardPadding),
		BackgroundTransparency = 1,
		ClipsDescendants = option("ClipsDescendants", false),
		ZIndex = ZIndex + 1,
	})
	local Main = NewRoundFrame(Radius, option("Shape", "Squircle"), {
		Name = "Main",
		Size = CardSize,
		AutomaticSize = Config.AutomaticSize and "Y" or nil,
		Parent = Config.Parent,
		ImageTransparency = BackgroundTransparency,
		ImageColor3 = BackgroundColor,
		ThemeTag = BackgroundColor and nil or { ImageColor3 = "Layer" },
		ZIndex = ZIndex,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, CardPadding),
			PaddingBottom = UDim.new(0, CardPadding),
			PaddingLeft = UDim.new(0, CardPadding),
			PaddingRight = UDim.new(0, CardPadding),
		}),
		Header,
		Content,
	})
	Card.CardFrame = {
		UIElements = { Main = Main, Container = Content, Header = Header },
		SetTitle = function(_, title) Header.Title.Text = title or "" end,
		SetDesc = function(_, desc) Header.Desc.Text = desc or "" end,
		Destroy = function() Main:Destroy() end,
	}
	Card.UIElements.Main = Main
	Card.UIElements.Content = Content
	Card.UIElements.Header = Header

	local Definitions = {}
	for _, definition in ipairs(Config.Elements or {}) do
		table.insert(Definitions, definition)
	end
	if Config.Image then
		table.insert(Definitions, 1, {
			Type = "Image", Image = Config.Image, AspectRatio = Config.ImageAspectRatio or "16:9",
			Position = Config.ImagePosition, ElementSize = Config.ImageSize,
		})
	end
	if Config.Thumbnail then
		table.insert(Definitions, 1, {
			Type = "Image", Image = Config.Thumbnail, AspectRatio = Config.ThumbnailAspectRatio or "3:1",
			Position = Config.ThumbnailPosition, ElementSize = Config.ThumbnailSize,
		})
	end
	for _, button in ipairs(Config.Buttons or {}) do
		table.insert(Definitions, {
			Type = "Button", Title = button.Title, Icon = button.Icon, Callback = button.Callback,
			Variant = button.Variant or "White", Position = button.Position, ElementSize = button.Size,
		})
	end

		local function addDefinition(definition, index)
			local Type = definition.Type or definition.Element or definition.Kind
		local Module = ElementModules[Type]
		if Module then
			local childConfig = copyConfig(definition)
			childConfig.Parent = Content
			childConfig.ParentType = "Card"
			childConfig.ParentTable = Card
			childConfig.Window = Config.Window
			childConfig.WindUI = Config.WindUI
			childConfig.Tab = Config.Tab
			childConfig.UIScale = Config.UIScale
			childConfig.Index = index
			childConfig.GlobalIndex = Config.GlobalIndex
			childConfig.ParentConfig = childConfig
			if typeof(childConfig.ElementSize) ~= "UDim2" and typeof(childConfig.ElementSize) ~= "Vector2" then
				childConfig.ElementSize = nil
			end
			local _, content = Module:New(childConfig)
			local frame = findElementFrame(content)
			if frame then
				frame.Position = resolvePosition(definition.Position)
				frame.AnchorPoint = definition.AnchorPoint or Vector2.new(0, 0)
				if typeof(definition.ElementSize) == "UDim2" then
					frame.Size = definition.ElementSize
				elseif typeof(definition.ElementSize) == "Vector2" then
					frame.Size = UDim2.fromOffset(definition.ElementSize.X, definition.ElementSize.Y)
				end
				frame.ZIndex = definition.ZIndex or (ZIndex + 3 + index)
			end
			table.insert(Card.Elements, content)
			else
				warn("[ WindUI ] Unknown Card element: " .. tostring(Type))
			end
		end
		for index, definition in ipairs(Definitions) do
			addDefinition(definition, index)
		end

	function Card:SetTitle(title)
		Card.Title = title or ""
		Header.Title.Text = Card.Title
		return Card
	end
	function Card:SetDesc(desc)
		Card.Desc = desc
		Header.Desc.Text = desc or ""
		return Card
	end
	function Card:Add(definition)
		addDefinition(definition, #Card.Elements + 1)
		return definition
	end
	function Card:Destroy()
		if Card.Destroyed then return end
		Card.Destroyed = true
		for _, content in ipairs(Card.Elements) do
			if content.Destroy then content:Destroy() end
		end
		Main:Destroy()
	end

	return Card.__type, Card
end

return Element
