# Botões flutuantes

O WindUI Modded adiciona botões flutuantes arrastáveis que usam os mesmos shapes, temas e animações dos botões da UI.

```lua
local ActionButton = WindUI:AddFloatingButton({
    Name = "ActionButton",
    Icon = "zap",
    Title = nil,
    Variant = "Primary",
    Position = UDim2.new(1, -42, 1, -42),
    Callback = function(button)
        WindUI:Notify({
            Title = "Ação executada",
            Content = "O botão flutuante foi pressionado.",
            Duration = 3,
        })
    end,
})
```

`Position` aceita `UDim2` ou `Vector2`. O botão pode ser arrastado com mouse e toque. O callback recebe a instância de controle do botão, que oferece:

```lua
ActionButton:SetPosition(UDim2.new(1, -42, 1, -100))
ActionButton:SetVisible(false)
ActionButton:SetDraggable(true)
ActionButton:Edit({ Title = "Novo título", Callback = function() end })
ActionButton:Destroy()
```

Também existe o alias `WindUI:CreateFloatingButton(config)`.
