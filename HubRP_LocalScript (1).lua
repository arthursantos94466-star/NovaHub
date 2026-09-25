--[[
    ============================================================
    HUB RP - LocalScript
    ------------------------------------------------------------
    Hub móvel para Roblox (compatível com celular), com visual
    futurista (fundo escuro + bordas neon azul/ciano).

    COMO USAR:
    1) Coloque este script como um LocalScript dentro de
       StarterPlayer > StarterPlayerScripts (recomendado)
       ou dentro de StarterGui.
    2) Ele cria toda a interface via código (não precisa montar
       nada manualmente no Studio).

    OBSERVAÇÃO SOBRE ENVIO AUTOMÁTICO NO CHAT:
    O envio direto usa o TextChatService oficial do Roblox
    (TextChannel:SendAsync). Isso só funciona em jogos que usam
    o chat moderno (TextChatService habilitado). Se o jogo usar
    o chat legado (BubbleChat/LegacyChatService), o envio
    automático não é suportado pelo cliente por segurança do
    próprio Roblox — nesse caso o hub avisa a limitação e mostra
    a frase para cópia manual, em vez de tentar burlar o sistema.
    Nenhum exploit/executor/hook é usado.
    ============================================================
]]

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- 1) CORES E ESTILO (tema futurista escuro / neon ciano)
-- ============================================================
local COR_FUNDO        = Color3.fromRGB(10, 14, 22)
local COR_PAINEL       = Color3.fromRGB(15, 20, 32)
local COR_CARTAO       = Color3.fromRGB(20, 27, 42)
local COR_NEON         = Color3.fromRGB(0, 225, 255)
local COR_NEON_FRACO   = Color3.fromRGB(0, 140, 170)
local COR_TEXTO        = Color3.fromRGB(225, 245, 255)
local COR_TEXTO_FRACO  = Color3.fromRGB(140, 175, 190)
local COR_SUCESSO      = Color3.fromRGB(90, 255, 170)
local COR_ALERTA       = Color3.fromRGB(255, 120, 90)
local COR_LIGADO       = Color3.fromRGB(0, 200, 130)
local COR_DESLIGADO    = Color3.fromRGB(90, 100, 115)

local FONTE = Enum.Font.GothamBold
local FONTE_NORMAL = Enum.Font.Gotham

-- ============================================================
-- 2) FUNÇÕES AUXILIARES DE CRIAÇÃO DE UI
-- ============================================================

-- Cria um Instance rapidamente com propriedades em tabela
local function criar(classe, props)
    local obj = Instance.new(classe)
    for propriedade, valor in pairs(props) do
        obj[propriedade] = valor
    end
    return obj
end

-- Adiciona cantos arredondados
local function arredondar(pai, raio)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = raio or UDim.new(0, 12)
    corner.Parent = pai
    return corner
end

-- Adiciona borda neon (UIStroke)
local function bordaNeon(pai, cor, espessura, transparencia)
    local stroke = Instance.new("UIStroke")
    stroke.Color = cor or COR_NEON
    stroke.Thickness = espessura or 2
    stroke.Transparency = transparencia or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = pai
    return stroke
end

-- Adiciona um leve gradiente vertical para dar profundidade
local function gradiente(pai, corTopo, corBase)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, corTopo),
        ColorSequenceKeypoint.new(1, corBase),
    })
    grad.Rotation = 90
    grad.Parent = pai
    return grad
end

-- Efeito rápido de "pulso" na borda para indicar seleção
local function piscarBorda(stroke, corOriginal)
    local corDestaque = COR_SUCESSO
    local tweenIda = TweenService:Create(stroke, TweenInfo.new(0.12), {Color = corDestaque, Thickness = 3})
    local tweenVolta = TweenService:Create(stroke, TweenInfo.new(0.35), {Color = corOriginal, Thickness = 2})
    tweenIda:Play()
    tweenIda.Completed:Connect(function()
        tweenVolta:Play()
    end)
end

-- ============================================================
-- 3) DADOS: CATEGORIAS E FRASES
-- ============================================================
local categorias = {
    {
        id = "defesa",
        nome = "🛡️ DEFESA",
        frases = {
            "Meu cliente exercerá seu direito de permanecer em silêncio.",
            "Protesto!",
            "Tenho provas para sustentar minha alegação.",
            "A acusação deverá apresentar provas.",
            "Não há elementos suficientes para essa acusação.",
            "Meu cliente não responderá a perguntas sem a devida orientação jurídica.",
            "Não aceito essa acusação sem provas.",
            "Solicito respeito ao direito de defesa.",
            "A defesa tem o direito de se manifestar.",
            "Essa acusação precisa ser devidamente fundamentada.",
            "Peço que a acusação seja esclarecida.",
        },
    },
    {
        id = "ataque",
        nome = "⚔️ ATAQUE / ACUSAÇÃO",
        frases = {
            "Tenho provas para sustentar minha alegação.",
            "A acusação deverá apresentar provas.",
            "Não há elementos suficientes para essa acusação.",
            "Essa acusação precisa ser devidamente fundamentada.",
            "Peço que a acusação seja esclarecida.",
        },
    },
    {
        id = "apresentar",
        nome = "🤝 APRESENTAR AO CLIENTE",
        frases = {
            "Boa tarde, sou seu advogado e vou cuidar do seu caso.",
            "Pode me explicar o que aconteceu?",
            "Estou aqui para representar seus interesses.",
            "Vou analisar o caso antes de tomar qualquer medida.",
            "Pode contar comigo durante o processo.",
        },
    },
    {
        id = "buscar",
        nome = "🔍 BUSCAR CLIENTE",
        frases = {
            "Você precisa de assistência jurídica?",
            "Está procurando um advogado?",
            "Posso ajudá-lo com seu caso.",
            "Gostaria de conversar sobre sua situação?",
            "Se precisar de representação jurídica, estou à disposição.",
        },
    },
    {
        id = "seg_min",
        nome = "🟢 SEGURANÇA MÍNIMA",
        frases = {
            "Por qual motivo você está classificado na segurança mínima?",
            "Você sabe por que foi colocado na segurança mínima?",
            "Qual foi o motivo da sua classificação?",
        },
    },
    {
        id = "seg_med",
        nome = "🟡 SEGURANÇA MÉDIA",
        frases = {
            "Por que você está na segurança média?",
            "O que levou à sua classificação na segurança média?",
            "Você pode explicar o motivo da sua classificação?",
        },
    },
    {
        id = "seg_max",
        nome = "🔴 SEGURANÇA MÁXIMA",
        frases = {
            "Por que você está classificado na segurança máxima?",
            "Qual foi o motivo para você estar na segurança máxima?",
            "Você pode explicar o que levou à sua classificação?",
        },
    },
    {
        id = "config",
        nome = "⚙️ CONFIGURAÇÕES",
        ehConfiguracao = true,
    },
}

-- ============================================================
-- 4) ESTADO / CONFIGURAÇÕES DO JOGADOR
-- ============================================================
local config = {
    copiarFrase = true,   -- "📋 COPIAR FRASE"
    enviarDireto = false, -- "💬 ENVIAR DIRETAMENTE"
}

-- ============================================================
-- 5) SCREENGUI PRINCIPAL
-- ============================================================
local screenGui = criar("ScreenGui", {
    Name = "HubRP",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 50,
    Parent = playerGui,
})

-- ------------------------------------------------------------
-- 5.1) Botão flutuante (abre o menu)
-- ------------------------------------------------------------
local botaoFlutuante = criar("ImageButton", {
    Name = "BotaoFlutuante",
    Parent = screenGui,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -110),
    Size = UDim2.new(0, 58, 0, 58),
    BackgroundColor3 = COR_PAINEL,
    AutoButtonColor = false,
    Image = "",
    ZIndex = 10,
})
arredondar(botaoFlutuante, UDim.new(1, 0))
local strokeFlutuante = bordaNeon(botaoFlutuante, COR_NEON, 2)
gradiente(botaoFlutuante, COR_PAINEL, COR_FUNDO)

local iconeFlutuante = criar("TextLabel", {
    Parent = botaoFlutuante,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "⚖",
    TextColor3 = COR_NEON,
    TextScaled = true,
    Font = FONTE,
    ZIndex = 11,
})

-- ------------------------------------------------------------
-- 5.2) Painel principal (centralizado, adaptado para celular)
-- ------------------------------------------------------------
local painelPrincipal = criar("Frame", {
    Name = "PainelPrincipal",
    Parent = screenGui,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0.92, 0, 0.8, 0),
    BackgroundColor3 = COR_PAINEL,
    Visible = false,
    ZIndex = 20,
})
arredondar(painelPrincipal, UDim.new(0, 18))
local strokePainel = bordaNeon(painelPrincipal, COR_NEON, 2)
gradiente(painelPrincipal, COR_PAINEL, COR_FUNDO)

-- Cabeçalho do painel
local cabecalho = criar("Frame", {
    Name = "Cabecalho",
    Parent = painelPrincipal,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 54),
    Position = UDim2.new(0, 0, 0, 0),
    ZIndex = 21,
})

local botaoVoltar = criar("TextButton", {
    Name = "BotaoVoltar",
    Parent = cabecalho,
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.new(0, 40, 0, 40),
    BackgroundColor3 = COR_CARTAO,
    Text = "‹",
    TextColor3 = COR_NEON,
    TextScaled = true,
    Font = FONTE,
    Visible = false,
    ZIndex = 22,
})
arredondar(botaoVoltar, UDim.new(0, 10))
bordaNeon(botaoVoltar, COR_NEON_FRACO, 1.5)

local tituloPainel = criar("TextLabel", {
    Name = "Titulo",
    Parent = cabecalho,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, -120, 1, -10),
    BackgroundTransparency = 1,
    Text = "HUB RP",
    TextColor3 = COR_TEXTO,
    Font = FONTE,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 21,
})

local botaoFechar = criar("TextButton", {
    Name = "BotaoFechar",
    Parent = cabecalho,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0, 40, 0, 40),
    BackgroundColor3 = COR_CARTAO,
    Text = "×",
    TextColor3 = COR_ALERTA,
    TextScaled = true,
    Font = FONTE,
    ZIndex = 22,
})
arredondar(botaoFechar, UDim.new(0, 10))
bordaNeon(botaoFechar, COR_ALERTA, 1.5)

-- Linha divisória neon abaixo do cabeçalho
local linhaDivisoria = criar("Frame", {
    Parent = painelPrincipal,
    Position = UDim2.new(0, 0, 0, 54),
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = COR_NEON,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 21,
})

-- Área de conteúdo (troca entre lista de categorias / lista de frases / config)
local areaConteudo = criar("Frame", {
    Name = "AreaConteudo",
    Parent = painelPrincipal,
    Position = UDim2.new(0, 0, 0, 60),
    Size = UDim2.new(1, 0, 1, -66),
    BackgroundTransparency = 1,
    ZIndex = 21,
})

-- ------------------------------------------------------------
-- 5.3) Lista de categorias (ScrollingFrame)
-- ------------------------------------------------------------
local listaCategorias = criar("ScrollingFrame", {
    Name = "ListaCategorias",
    Parent = areaConteudo,
    Size = UDim2.new(1, -16, 1, -12),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = COR_NEON,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = true,
    ZIndex = 21,
})

local layoutCategorias = criar("UIListLayout", {
    Parent = listaCategorias,
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
})

-- ------------------------------------------------------------
-- 5.4) Lista de frases (ScrollingFrame) — oculta inicialmente
-- ------------------------------------------------------------
local listaFrases = criar("ScrollingFrame", {
    Name = "ListaFrases",
    Parent = areaConteudo,
    Size = UDim2.new(1, -16, 1, -12),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = COR_NEON,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
    ZIndex = 21,
})

local layoutFrases = criar("UIListLayout", {
    Parent = listaFrases,
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
})

-- ------------------------------------------------------------
-- 5.5) Painel de configurações — oculto inicialmente
-- ------------------------------------------------------------
local painelConfig = criar("Frame", {
    Name = "PainelConfig",
    Parent = areaConteudo,
    Size = UDim2.new(1, -16, 1, -12),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 21,
})

local layoutConfig = criar("UIListLayout", {
    Parent = painelConfig,
    Padding = UDim.new(0, 14),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
})

-- ============================================================
-- 6) POPUP DE CÓPIA (TextBox selecionável) + NOTIFICAÇÃO
-- ============================================================
local fundoModal = criar("TextButton", { -- TextButton "vazio" só para bloquear cliques atrás
    Name = "FundoModal",
    Parent = screenGui,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.5,
    Text = "",
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 29,
})

local popupCopia = criar("Frame", {
    Name = "PopupCopia",
    Parent = screenGui,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0.85, 0, 0, 190),
    BackgroundColor3 = COR_PAINEL,
    Visible = false,
    ZIndex = 30,
})
arredondar(popupCopia, UDim.new(0, 16))
bordaNeon(popupCopia, COR_NEON, 2)
gradiente(popupCopia, COR_PAINEL, COR_FUNDO)

local tituloPopup = criar("TextLabel", {
    Parent = popupCopia,
    Position = UDim2.new(0, 14, 0, 10),
    Size = UDim2.new(1, -28, 0, 24),
    BackgroundTransparency = 1,
    Text = "📋 Toque e segure para copiar",
    TextColor3 = COR_NEON,
    Font = FONTE,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 31,
})

local caixaTextoPopup = criar("TextBox", {
    Name = "CaixaTexto",
    Parent = popupCopia,
    Position = UDim2.new(0, 14, 0, 42),
    Size = UDim2.new(1, -28, 0, 100),
    BackgroundColor3 = COR_CARTAO,
    TextColor3 = COR_TEXTO,
    Font = FONTE_NORMAL,
    TextSize = 16,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ClearTextOnFocus = false,
    MultiLine = true,
    Text = "",
    ZIndex = 31,
})
arredondar(caixaTextoPopup, UDim.new(0, 10))
bordaNeon(caixaTextoPopup, COR_NEON_FRACO, 1.5)

local botaoFecharPopup = criar("TextButton", {
    Parent = popupCopia,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -12),
    Size = UDim2.new(0, 140, 0, 34),
    BackgroundColor3 = COR_CARTAO,
    Text = "FECHAR",
    TextColor3 = COR_NEON,
    Font = FONTE,
    TextScaled = true,
    ZIndex = 31,
})
arredondar(botaoFecharPopup, UDim.new(0, 10))
bordaNeon(botaoFecharPopup, COR_NEON, 1.5)

local function abrirPopupCopia(frase)
    caixaTextoPopup.Text = frase
    popupCopia.Visible = true
    fundoModal.Visible = true
end

local function fecharPopupCopia()
    popupCopia.Visible = false
    fundoModal.Visible = false
end

botaoFecharPopup.MouseButton1Click:Connect(fecharPopupCopia)
fundoModal.MouseButton1Click:Connect(fecharPopupCopia)

-- Notificação simples (para avisos, ex.: limitação do envio automático)
local notificacao = criar("TextLabel", {
    Name = "Notificacao",
    Parent = screenGui,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.06, 0),
    Size = UDim2.new(0.85, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = COR_PAINEL,
    TextColor3 = COR_ALERTA,
    Font = FONTE,
    TextWrapped = true,
    TextSize = 15,
    Text = "",
    Visible = false,
    ZIndex = 40,
})
arredondar(notificacao, UDim.new(0, 12))
bordaNeon(notificacao, COR_ALERTA, 2)
local paddingNotif = criar("UIPadding", {
    Parent = notificacao,
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
})

local function mostrarNotificacao(texto, duracao)
    notificacao.Text = texto
    notificacao.Visible = true
    task.delay(duracao or 3.5, function()
        notificacao.Visible = false
    end)
end

-- ============================================================
-- 7) ENVIO DIRETO PELO CHAT OFICIAL (TextChatService)
-- ============================================================
-- Retorna true/false conforme o envio foi bem-sucedido.
local function enviarMensagemChat(texto)
    -- Verifica se o jogo está usando o chat moderno (TextChatService)
    if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
        return false, "Este jogo usa o chat legado do Roblox. O envio automático não é suportado pelo cliente neste caso."
    end

    local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if not canal then
        return false, "Não foi possível encontrar o canal de chat oficial deste jogo."
    end

    local sucesso, erro = pcall(function()
        canal:SendAsync(texto)
    end)

    if not sucesso then
        return false, "Não foi possível enviar a mensagem automaticamente (limite de envio ou permissão do jogo)."
    end

    return true
end

-- ============================================================
-- 8) MONTAGEM DAS CATEGORIAS (lista principal)
-- ============================================================

local function mostrarListaCategorias()
    listaCategorias.Visible = true
    listaFrases.Visible = false
    painelConfig.Visible = false
    botaoVoltar.Visible = false
    tituloPainel.Text = "HUB RP"
end

local function mostrarListaFrases(categoria)
    -- limpa botões antigos
    for _, filho in ipairs(listaFrases:GetChildren()) do
        if filho:IsA("Frame") then
            filho:Destroy()
        end
    end

    for indice, frase in ipairs(categoria.frases) do
        local cartaoFrase = criar("Frame", {
            Name = "Frase" .. indice,
            Parent = listaFrases,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = COR_CARTAO,
            LayoutOrder = indice,
            ZIndex = 22,
        })
        arredondar(cartaoFrase, UDim.new(0, 12))
        local strokeFrase = bordaNeon(cartaoFrase, COR_NEON_FRACO, 1.5)

        local paddingFrase = criar("UIPadding", {
            Parent = cartaoFrase,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        })

        local textoFrase = criar("TextLabel", {
            Parent = cartaoFrase,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = frase,
            TextColor3 = COR_TEXTO,
            Font = FONTE_NORMAL,
            TextSize = 15,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 23,
        })

        local botaoInvisivel = criar("TextButton", {
            Parent = cartaoFrase,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 24,
        })

        botaoInvisivel.MouseButton1Click:Connect(function()
            -- indicador visual de seleção
            piscarBorda(strokeFrase, COR_NEON_FRACO)

            if config.enviarDireto then
                local sucesso, mensagemErro = enviarMensagemChat(frase)
                if not sucesso then
                    mostrarNotificacao("⚠ " .. mensagemErro, 4)
                    abrirPopupCopia(frase) -- fallback: mostra para cópia manual
                elseif not config.copiarFrase then
                    mostrarNotificacao("✅ Frase enviada no chat!", 2)
                end
            end

            if config.copiarFrase then
                abrirPopupCopia(frase)
            end

            -- Caso nenhuma das duas opções esteja ativa, mostra a cópia
            -- por padrão para o jogador nunca ficar sem opção.
            if not config.enviarDireto and not config.copiarFrase then
                abrirPopupCopia(frase)
            end
        end)
    end

    listaCategorias.Visible = false
    listaFrases.Visible = true
    painelConfig.Visible = false
    botaoVoltar.Visible = true
    tituloPainel.Text = categoria.nome
end

-- ------------------------------------------------------------
-- 8.1) Painel de CONFIGURAÇÕES
-- ------------------------------------------------------------
local function criarLinhaConfig(rotulo, descricao, chaveConfig)
    local cartao = criar("Frame", {
        Parent = painelConfig,
        Size = UDim2.new(1, 0, 0, 78),
        BackgroundColor3 = COR_CARTAO,
        ZIndex = 22,
    })
    arredondar(cartao, UDim.new(0, 12))
    bordaNeon(cartao, COR_NEON_FRACO, 1.5)

    local paddingCartao = criar("UIPadding", {
        Parent = cartao,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })

    local labelTitulo = criar("TextLabel", {
        Parent = cartao,
        Size = UDim2.new(1, -90, 0, 22),
        BackgroundTransparency = 1,
        Text = rotulo,
        TextColor3 = COR_TEXTO,
        Font = FONTE,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
    })

    local labelDescricao = criar("TextLabel", {
        Parent = cartao,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, -90, 1, -24),
        BackgroundTransparency = 1,
        Text = descricao,
        TextColor3 = COR_TEXTO_FRACO,
        Font = FONTE_NORMAL,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 23,
    })

    local botaoToggle = criar("TextButton", {
        Parent = cartao,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 70, 0, 36),
        BackgroundColor3 = config[chaveConfig] and COR_LIGADO or COR_DESLIGADO,
        Text = config[chaveConfig] and "ON" or "OFF",
        TextColor3 = COR_TEXTO,
        Font = FONTE,
        TextScaled = true,
        ZIndex = 23,
    })
    arredondar(botaoToggle, UDim.new(1, 0))

    botaoToggle.MouseButton1Click:Connect(function()
        config[chaveConfig] = not config[chaveConfig]
        botaoToggle.BackgroundColor3 = config[chaveConfig] and COR_LIGADO or COR_DESLIGADO
        botaoToggle.Text = config[chaveConfig] and "ON" or "OFF"
    end)

    return cartao
end

local function montarPainelConfig()
    criarLinhaConfig(
        "📋 COPIAR FRASE",
        "Ao tocar em uma frase, ela aparece em uma caixa selecionável para copiar.",
        "copiarFrase"
    )
    criarLinhaConfig(
        "💬 ENVIAR DIRETAMENTE",
        "Ao tocar em uma frase, ela é enviada automaticamente pelo chat oficial do Roblox.",
        "enviarDireto"
    )

    local avisoIndependente = criar("TextLabel", {
        Parent = painelConfig,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "As duas opções funcionam de forma independente e podem ser usadas juntas ou separadas.",
        TextColor3 = COR_TEXTO_FRACO,
        Font = FONTE_NORMAL,
        TextSize = 12,
        TextWrapped = true,
        ZIndex = 22,
    })
end

local function mostrarConfig()
    listaCategorias.Visible = false
    listaFrases.Visible = false
    painelConfig.Visible = true
    botaoVoltar.Visible = true
    tituloPainel.Text = "⚙️ CONFIGURAÇÕES"
end

montarPainelConfig()

-- ------------------------------------------------------------
-- 8.2) Cria os botões de categoria na lista principal
-- ------------------------------------------------------------
for indice, categoria in ipairs(categorias) do
    local botaoCategoria = criar("TextButton", {
        Name = categoria.id,
        Parent = listaCategorias,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = COR_CARTAO,
        Text = "",
        LayoutOrder = indice,
        ZIndex = 22,
    })
    arredondar(botaoCategoria, UDim.new(0, 12))
    bordaNeon(botaoCategoria, COR_NEON, 1.5)

    local labelCategoria = criar("TextLabel", {
        Parent = botaoCategoria,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = categoria.nome,
        TextColor3 = COR_TEXTO,
        Font = FONTE,
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
    })

    botaoCategoria.MouseButton1Click:Connect(function()
        if categoria.ehConfiguracao then
            mostrarConfig()
        else
            mostrarListaFrases(categoria)
        end
    end)
end

-- ============================================================
-- 9) ABRIR / FECHAR O HUB
-- ============================================================
local function abrirHub()
    painelPrincipal.Visible = true
    mostrarListaCategorias()
end

local function fecharHub()
    painelPrincipal.Visible = false
end

botaoFlutuante.MouseButton1Click:Connect(abrirHub)
botaoFechar.MouseButton1Click:Connect(fecharHub)
botaoVoltar.MouseButton1Click:Connect(mostrarListaCategorias)

-- Fecha o popup de cópia automaticamente se o hub for fechado
botaoFechar.MouseButton1Click:Connect(fecharPopupCopia)

-- ============================================================
-- 10) FIM DO SCRIPT
-- ============================================================
-- O hub está pronto: botão flutuante -> painel com categorias,
-- rolagem, frases tocáveis, cópia/envio configuráveis e
-- indicador visual de seleção.
