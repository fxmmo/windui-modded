# Card

O elemento `Paragraph` foi substituído por `Card`. O Card pode conter vários elementos WindUI no mesmo painel, com posicionamento individual dentro da área do card.

```lua
local card = window:Tab({ Title = "Home" }):Card({
    Title = "Perfil",
    Desc = "Ações rápidas",
    Size = UDim2.new(1, 0, 0, 220),
    Elements = {
        {
            Type = "Image",
            Image = "rbxassetid://123456",
            AspectRatio = "16:9",
            Position = UDim2.new(0, 0, 0, 0),
            ElementSize = UDim2.new(0.35, 0, 0, 90),
        },
        {
            Type = "Toggle",
            Title = "Ativar recurso",
            Position = UDim2.new(0.4, 0, 0, 8),
            ElementSize = UDim2.new(0.6, 0, 0, 48),
            Callback = function(value) end,
        },
        {
            Type = "Input",
            Title = "Nome",
            Position = UDim2.new(0, 0, 0, 105),
            ElementSize = UDim2.new(0.55, 0, 0, 48),
            Callback = function(value) end,
        },
        {
            Type = "Button",
            Title = "Salvar",
            Icon = "save",
            Position = UDim2.new(0.62, 0, 0, 105),
            ElementSize = UDim2.new(0.38, 0, 0, 42),
            Callback = function() end,
        },
    },
})
```

Tipos disponíveis incluem `Button`, `Toggle`, `Input`, `Dropdown`, `Slider`, `ProgressBar`, `Keybind`, `Colorpicker`, `Code`, `Image`, `Divider`, `Space` e `Section`.

Cada item aceita `Position`, `AnchorPoint`, `ElementSize` e `ZIndex`. Para adicionar depois da criação:

```lua
card:Add({
    Type = "Button",
    Title = "Ajuda",
    Position = UDim2.new(0, 12, 1, -48),
    ElementSize = UDim2.new(0, 100, 0, 36),
    Callback = function() end,
})
```

O Card também possui `SetTitle`, `SetDesc` e `Destroy`. As opções antigas `Image`, `Thumbnail` e `Buttons` continuam aceitas como atalhos e são convertidas em elementos internos do Card.
