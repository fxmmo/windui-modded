# Paragraph

O `Paragraph` continua disponível e agora aceita um `Viewport` opcional, além de imagem, thumbnail e botões.

```lua
local paragraph = window:Tab({ Title = "Preview" }):Paragraph({
    Title = "Modelo 3D",
    Desc = "Arraste para girar e use a roda do mouse para aproximar.",
    Viewport = {
        Object = workspace.Modelo,
        Interactive = true,
        Height = 220,
        Focused = true,
        -- Camera = workspace.CameraOpcional,
    },
    Buttons = {
        {
            Title = "Recarregar",
            Icon = "refresh-cw",
            Callback = function() end,
        },
    },
})
```

O `Viewport` aceita `Object`, `Camera`, `Interactive`, `Height` e `Focused`. A instância retornada em `paragraph.Viewport` possui `SetObject`, `SetHeight`, `Focus`, `SetCamera` e `SetInteractive`.
