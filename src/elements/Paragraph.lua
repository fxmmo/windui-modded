local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

local CreateButton = require("../components/ui/Button").New
local CreateViewport = require("./Viewport")

function Element:New(ElementConfig)
	ElementConfig.Hover = false
	ElementConfig.TextOffset = 0
	ElementConfig.ParentConfig = ElementConfig
	ElementConfig.IsButtons = ElementConfig.Buttons and #ElementConfig.Buttons > 0 and true or false

	local ParagraphModule = {
		__type = "Paragraph",
		Title = ElementConfig.Title or "Paragraph",
		Desc = ElementConfig.Desc or nil,
		--Color = ElementConfig.Color,
		Locked = ElementConfig.Locked or false,
	}
	local Paragraph = require("../components/window/Element")(ElementConfig)

		ParagraphModule.ParagraphFrame = Paragraph
		local ViewportConfig = ElementConfig.Viewport or ElementConfig.ViewportConfig
		if typeof(ViewportConfig) == "table" and ViewportConfig.Object then
			local Config = {}
			for key, value in pairs(ViewportConfig) do
				Config[key] = value
			end
			Config.Parent = Paragraph.UIElements.Container
			Config.Window = ElementConfig.Window
			Config.WindUI = ElementConfig.WindUI
			Config.Tab = ElementConfig.Tab
			Config.UIScale = ElementConfig.UIScale
			local _, Viewport = CreateViewport:New(Config)
			ParagraphModule.Viewport = Viewport
			ParagraphModule.ViewportFrame = Viewport.Main
		end
		if ElementConfig.Buttons and #ElementConfig.Buttons > 0 then
		local ButtonsContainer = New("Frame", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundTransparency = 1,
			AutomaticSize = "Y",
			Parent = Paragraph.UIElements.Container,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = "Vertical",
			}),
		})

		for _, Button in next, ElementConfig.Buttons do
			local ButtonFrame = CreateButton(
				Button.Title,
				Button.Icon,
				Button.Callback,
				Button.Variant or "White",
				ButtonsContainer,
				nil,
				nil,
				ElementConfig.Window.NewElements and 999 or 10
			)
			ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
			--ButtonFrame.AutomaticSize = "X"
		end
	end

	return ParagraphModule.__type, ParagraphModule
end

return Element
