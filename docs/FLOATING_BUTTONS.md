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
ActionButton:SetSize(Vector2.new(64, 64))
ActionButton:SetVisible(false)
ActionButton:SetDraggable(true)
ActionButton:Edit({ Title = "Novo título", Callback = function() end })
ActionButton:Destroy()
```

## Tamanho e estilo

`Size` pode ser um número, `Vector2` ou `UDim2`. Também é possível usar `Width` e `Height` separadamente. As opções podem ser passadas diretamente na configuração ou dentro de `Style`:

```lua
local StyledButton = WindUI:AddFloatingButton({
    Icon = "star",
    Title = "Favorito",
    Size = Vector2.new(150, 48),
    Style = {
        BackgroundColor3 = Color3.fromRGB(92, 53, 210),
        BackgroundTransparency = 0.05,
        OutlineColor3 = Color3.fromRGB(190, 160, 255),
        OutlineTransparency = 0.25,
        ShadowColor3 = Color3.fromRGB(20, 10, 45),
        ShadowTransparency = 0.35,
        Radius = 16,
        Padding = 12,
        IconColor3 = Color3.fromRGB(255, 235, 120),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        HoverTransparency = 0.15,
        HoverScale = 1.06,
    },
    Callback = function() end,
})
```

Também estão disponíveis `CornerRadius`, `Shape`, `OutlineShape`, `IconSize`, `IconTransparency`, `ZIndex`, `FullRounded`, `Variant`, `Width` e `Height`. Por padrão, o botão usa `ZIndex = -100` e fica atrás da janela. Para colocá-lo acima de outros elementos, defina um `ZIndex` maior manualmente.

Também existe o alias `WindUI:CreateFloatingButton(config)`.
