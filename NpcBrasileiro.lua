
-- HUB NPC POLITICO - VERSAO COMPACTA
-- O X fecha a interface sem parar o teleporte

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")

local jogador = Players.LocalPlayer
local playerGui = jogador:WaitForChild("PlayerGui")

local AMARELO = Color3.fromRGB(255, 220, 90)
local BRANCO = Color3.fromRGB(245, 245, 245)
local FUNDO = Color3.fromRGB(24, 27, 34)
local BOTAO = Color3.fromRGB(48, 55, 69)

local Roupas = {
    {Nome = "Classico", Shirt = 99683565132175, Pants = 91634614464374},
    {Nome = "Cerimonial", Shirt = 102071860494915, Pants = 91634614464374},
    {Nome = "Vermelho", Shirt = 118386970714667, Pants = 96041661769522},
    {Nome = "Azul", Shirt = 84327993886063, Pants = 121298618625389}
}

local Cargos = {
    {Texto = "PRESIDENTE"},
    {Texto = "SENADOR"},
    {Texto = "DEPUTADO"},
    {Texto = "ASSESSOR"},
    {Texto = "MINISTRO DO STF"},
    {Texto = "CANDIDATO"}
}

local indiceCargo = 1
local indiceRoupa = 1
local npcSpawnado
local nomeOriginal = "Jogador"
local partidoAtual = ""
local vipAtivo = false

local teleporteAtivo = false
local intervaloTeleporte = 2.5
local cicloTeleporte = 0

-- LIMPAR INTERFACE ANTIGA
local antiga = playerGui:FindFirstChild("PoliticaCompactSpawnerUI")
if antiga then
    antiga:Destroy()
end

local function ocultarNomePadrao(modelo)
    local humanoid = modelo:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType =
            Enum.HumanoidDisplayDistanceType.None
        humanoid.NameDisplayDistance = 0
        humanoid.HealthDisplayType =
            Enum.HumanoidHealthDisplayType.AlwaysOff
        humanoid.DisplayName = ""
    end
end

-- INTERFACE
local gui = Instance.new("ScreenGui")
gui.Name = "PoliticaCompactSpawnerUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = playerGui

local painel = Instance.new("Frame")
painel.Name = "Painel"
painel.Size = UDim2.fromOffset(265, 430)
painel.Position = UDim2.new(0, 12, 0.2, 0)
painel.BackgroundColor3 = FUNDO
painel.BorderSizePixel = 0
painel.Parent = gui
Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 9)

local borda = Instance.new("UIStroke")
borda.Color = Color3.fromRGB(65, 73, 90)
borda.Parent = painel

local cabecalho = Instance.new("Frame")
cabecalho.Size = UDim2.new(1, 0, 0, 36)
cabecalho.BackgroundColor3 = Color3.fromRGB(33, 37, 47)
cabecalho.BorderSizePixel = 0
cabecalho.Parent = painel
Instance.new("UICorner", cabecalho).CornerRadius = UDim.new(0, 9)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -85, 1, 0)
titulo.Position = UDim2.fromOffset(10, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "NPC POLITICO"
titulo.TextColor3 = AMARELO
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 13
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = cabecalho

local function botaoCabecalho(texto, posicao, cor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(25, 25)
    b.Position = UDim2.new(1, posicao, 0, 5)
    b.BackgroundColor3 = cor or BOTAO
    b.BorderSizePixel = 0
    b.Text = texto
    b.TextColor3 = BRANCO
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = cabecalho
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local minimizar = botaoCabecalho("—", -57)
local fechar = botaoCabecalho(
    "X", -29, Color3.fromRGB(130, 48, 48)
)

local reabrir = Instance.new("TextButton")
reabrir.Size = UDim2.fromOffset(110, 34)
reabrir.Position = UDim2.new(0, 12, 0.2, 0)
reabrir.BackgroundColor3 = Color3.fromRGB(33, 37, 47)
reabrir.Text = "Abrir Hub"
reabrir.TextColor3 = AMARELO
reabrir.Font = Enum.Font.GothamBold
reabrir.TextSize = 12
reabrir.Visible = false
reabrir.Parent = gui
Instance.new("UICorner", reabrir).CornerRadius = UDim.new(0, 7)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(8, 43)
scroll.Size = UDim2.new(1, -16, 1, -51)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = AMARELO
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = painel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function label(texto, altura)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, altura or 20)
    l.BackgroundTransparency = 1
    l.Text = texto
    l.TextColor3 = Color3.fromRGB(210, 215, 225)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 11
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scroll
    return l
end

local function criarBotao(texto)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -2, 0, 29)
    b.BackgroundColor3 = BOTAO
    b.BorderSizePixel = 0
    b.Text = texto
    b.TextColor3 = BRANCO
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local function criarEntrada(placeholder)
    local e = Instance.new("TextBox")
    e.Size = UDim2.new(1, -2, 0, 30)
    e.BackgroundColor3 = Color3.fromRGB(38, 43, 53)
    e.BorderSizePixel = 0
    e.PlaceholderText = placeholder
    e.Text = ""
    e.TextColor3 = BRANCO
    e.PlaceholderColor3 = Color3.fromRGB(150, 155, 165)
    e.Font = Enum.Font.Gotham
    e.TextSize = 11
    e.ClearTextOnFocus = false
    e.Parent = scroll
    Instance.new("UICorner", e).CornerRadius = UDim.new(0, 5)
    return e
end

local status = label("Status: aguardando", 26)
local entradaNick = criarEntrada("Nick ou UserId do jogador")
local criarNPCBotao = criarBotao("Criar NPC")
local removerNPCBotao = criarBotao("Remover NPC")
local cargoBotao = criarBotao("Cargo: PRESIDENTE")
local roupaBotao = criarBotao("Traje: Classico")
local partidoEntrada = criarEntrada("Sigla do partido (opcional)")
local vipBotao = criarBotao("VIP: DESLIGADO")
local teleporteBotao = criarBotao("Teleporte NPCs: OFF")

label("MENSAGEM DO NPC", 18)
local entradaMensagem = criarEntrada("Escreva a mensagem...")
local enviarBotao = criarBotao("Enviar mensagem")

label("HISTORICO LOCAL", 18)

local historico = Instance.new("Frame")
historico.Size = UDim2.new(1, -2, 0, 105)
historico.BackgroundColor3 = Color3.fromRGB(17, 19, 24)
historico.BorderSizePixel = 0
historico.ClipsDescendants = true
historico.Parent = scroll
Instance.new("UICorner", historico).CornerRadius = UDim.new(0, 5)

local historicoScroll = Instance.new("ScrollingFrame")
historicoScroll.Size = UDim2.new(1, -8, 1, -8)
historicoScroll.Position = UDim2.fromOffset(4, 4)
historicoScroll.BackgroundTransparency = 1
historicoScroll.BorderSizePixel = 0
historicoScroll.ScrollBarThickness = 3
historicoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
historicoScroll.CanvasSize = UDim2.new()
historicoScroll.Parent = historico

local historicoLayout = Instance.new("UIListLayout")
historicoLayout.Padding = UDim.new(0, 3)
historicoLayout.SortOrder = Enum.SortOrder.LayoutOrder
historicoLayout.Parent = historicoScroll

-- PLACA PERSONALIZADA
local function atualizarPlaca()
    if not npcSpawnado or not npcSpawnado.Parent then
        return
    end

    ocultarNomePadrao(npcSpawnado)

    local cabeca = npcSpawnado:FindFirstChild("Head")
    if not cabeca then
        return
    end

    local velha = npcSpawnado:FindFirstChild("CargoBillboard")
    if velha then
        velha:Destroy()
    end

    local placa = Instance.new("BillboardGui")
    placa.Name = "CargoBillboard"
    placa.Adornee = cabeca
    placa.Size = UDim2.fromOffset(240, 40)
    placa.StudsOffset = Vector3.new(0, 2.45, 0)
    placa.AlwaysOnTop = true
    placa.MaxDistance = 45
    placa.LightInfluence = 0
    placa.Parent = npcSpawnado

    local cargo = Instance.new("TextLabel")
    cargo.Size = UDim2.new(1, 0, 0, 18)
    cargo.BackgroundTransparency = 1
    cargo.Text = Cargos[indiceCargo].Texto
    cargo.TextColor3 = AMARELO
    cargo.Font = Enum.Font.GothamBold
    cargo.TextSize = 14
    cargo.TextStrokeTransparency = 0.45
    cargo.Parent = placa

    local nome = Instance.new("TextLabel")
    nome.Name = "Nome"
    nome.Position = UDim2.fromOffset(0, 18)
    nome.Size = UDim2.new(1, 0, 0, 20)
    nome.BackgroundTransparency = 1
    nome.RichText = true
    nome.Font = Enum.Font.GothamMedium
    nome.TextSize = 15
    nome.TextColor3 = BRANCO
    nome.TextStrokeTransparency = 0.45
    nome.TextTruncate = Enum.TextTruncate.AtEnd

    local exibicao = "Sr. " .. nomeOriginal

    if partidoAtual ~= "" then
        exibicao ..= " [" .. partidoAtual .. "]"
    end

    if vipAtivo then
        exibicao ..= ' <font color="#FFD75A">★ VIP</font>'
    end

    nome.Text = exibicao
    nome.Parent = placa
end

local function atualizarBotoes()
    cargoBotao.Text = "Cargo: " .. Cargos[indiceCargo].Texto
    roupaBotao.Text = "Traje: " .. Roupas[indiceRoupa].Nome
    vipBotao.Text = vipAtivo and "VIP: LIGADO" or "VIP: DESLIGADO"
end

-- APLICAR ROUPA
local function aplicarRoupa()
    if not npcSpawnado or not npcSpawnado.Parent then
        return
    end

    local roupa = Roupas[indiceRoupa]

    local camisa = npcSpawnado:FindFirstChildOfClass("Shirt")
    if not camisa then
        camisa = Instance.new("Shirt")
        camisa.Parent = npcSpawnado
    end
    camisa.ShirtTemplate = "rbxassetid://" .. roupa.Shirt

    local calca = npcSpawnado:FindFirstChildOfClass("Pants")
    if not calca then
        calca = Instance.new("Pants")
        calca.Parent = npcSpawnado
    end
    calca.PantsTemplate = "rbxassetid://" .. roupa.Pants
end

-- BALÃO DE MENSAGEM
local function mostrarBalao(texto)
    if not npcSpawnado or not npcSpawnado.Parent then
        return false
    end

    local cabeca = npcSpawnado:FindFirstChild("Head")
    if not cabeca then
        return false
    end

    local configuracao = TextChatService:FindFirstChild(
        "BubbleChatConfiguration"
    )

    if configuracao and not configuracao.Enabled then
        status.Text = "O balao de chat esta desativado."
        return false
    end

    local sucesso, erro = pcall(function()
        TextChatService:DisplayBubble(cabeca, texto)
    end)

    if not sucesso then
        warn("Erro ao mostrar balao:", erro)
        status.Text = "O jogo nao permitiu exibir o balao."
        return false
    end

    return true
end

local function adicionarHistorico(texto)
    local linha = Instance.new("TextLabel")
    linha.Size = UDim2.new(1, -2, 0, 34)
    linha.BackgroundTransparency = 1
    linha.TextColor3 = BRANCO
    linha.TextXAlignment = Enum.TextXAlignment.Left
    linha.TextYAlignment = Enum.TextYAlignment.Top
    linha.TextWrapped = true
    linha.Font = Enum.Font.Gotham
    linha.TextSize = 11
    linha.Text = "Sr. " .. nomeOriginal .. ": " .. texto
    linha.Parent = historicoScroll

    task.defer(function()
        historicoScroll.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                historicoScroll.AbsoluteCanvasSize.Y
                    - historicoScroll.AbsoluteSize.Y
            )
        )
    end)
end

local function enviarMensagem()
    local texto = entradaMensagem.Text:match("^%s*(.-)%s*$")

    if texto == "" then
        status.Text = "Digite uma mensagem."
        return
    end

    if not npcSpawnado or not npcSpawnado.Parent then
        status.Text = "Crie o NPC primeiro."
        return
    end

    if mostrarBalao(texto) then
        adicionarHistorico(texto)
        entradaMensagem.Text = ""
        status.Text = "Mensagem enviada."
    end
end

enviarBotao.MouseButton1Click:Connect(enviarMensagem)

entradaMensagem.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        enviarMensagem()
    end
end)

-- CRIAR NPC
criarNPCBotao.MouseButton1Click:Connect(function()
    local texto = entradaNick.Text:match("^%s*(.-)%s*$")

    if texto == "" then
        status.Text = "Informe um nick ou UserId."
        return
    end

    status.Text = "Carregando avatar..."

    task.spawn(function()
        local userId

        if tonumber(texto) then
            userId = tonumber(texto)
        else
            local ok, resultado = pcall(function()
                return Players:GetUserIdFromNameAsync(texto)
            end)

            if not ok then
                status.Text = "Nick nao encontrado."
                warn("Erro ao buscar usuario:", resultado)
                return
            end

            userId = resultado
        end

        local ok, resultado = pcall(function()
            local descricao =
                Players:GetHumanoidDescriptionFromUserIdAsync(userId)

            return Players:CreateHumanoidModelFromDescriptionAsync(
                descricao,
                Enum.HumanoidRigType.R15
            )
        end)

        if not ok or not resultado then
            status.Text = "Falha ao carregar avatar."
            warn("Erro ao criar avatar:", resultado)
            return
        end

        local npc = resultado
        npc.Name = "NPCVisualPolitico"

        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        local raiz = npc:FindFirstChild("HumanoidRootPart")

        if not humanoid or not raiz then
            npc:Destroy()
            status.Text = "Avatar invalido."
            return
        end

        ocultarNomePadrao(npc)

        local okNome, nome = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        nomeOriginal = okNome and nome or texto

        local personagem = jogador.Character
        local raizJogador = personagem
            and personagem:FindFirstChild("HumanoidRootPart")

        if not raizJogador then
            npc:Destroy()
            status.Text = "Seu personagem nao foi encontrado."
            return
        end

        npc:PivotTo(raizJogador.CFrame * CFrame.new(4, 0, -6))

        for _, objeto in ipairs(npc:GetDescendants()) do
            if objeto:IsA("BasePart") then
                objeto.Anchored = true
                objeto.CanCollide = false
            elseif objeto:IsA("Script")
                or objeto:IsA("LocalScript") then
                objeto:Destroy()
            end
        end

        ocultarNomePadrao(npc)
        npc.Parent = Workspace

        if npcSpawnado and npcSpawnado.Parent then
            npcSpawnado:Destroy()
        end

        npcSpawnado = npc

        aplicarRoupa()
        atualizarPlaca()
        atualizarBotoes()

        status.Text = "NPC criado: Sr. " .. nomeOriginal
    end)
end)

-- REMOVER NPC
removerNPCBotao.MouseButton1Click:Connect(function()
    teleporteAtivo = false
    cicloTeleporte = cicloTeleporte + 1
    teleporteBotao.Text = "Teleporte NPCs: OFF"

    if npcSpawnado then
        npcSpawnado:Destroy()
        npcSpawnado = nil
    end

    status.Text = "NPC removido."
end)

cargoBotao.MouseButton1Click:Connect(function()
    indiceCargo = indiceCargo % #Cargos + 1
    atualizarBotoes()
    atualizarPlaca()
end)

roupaBotao.MouseButton1Click:Connect(function()
    indiceRoupa = indiceRoupa % #Roupas + 1
    atualizarBotoes()
    aplicarRoupa()
end)

partidoEntrada.FocusLost:Connect(function()
    partidoAtual = string.upper(
        partidoEntrada.Text:match("^%s*(.-)%s*$") or ""
    )
    atualizarPlaca()
end)

vipBotao.MouseButton1Click:Connect(function()
    vipAtivo = not vipAtivo
    atualizarBotoes()
    atualizarPlaca()
end)

-- TELEPORTE PARA NPCs MAIS PROXIMOS DO JOGADOR
teleporteBotao.MouseButton1Click:Connect(function()
    teleporteAtivo = not teleporteAtivo
    cicloTeleporte = cicloTeleporte + 1

    local meuCiclo = cicloTeleporte

    teleporteBotao.Text = teleporteAtivo
        and "Teleporte NPCs: ON"
        or "Teleporte NPCs: OFF"

    if not teleporteAtivo then
        status.Text = "Teleporte desativado."
        return
    end

    task.spawn(function()
        while teleporteAtivo and cicloTeleporte == meuCiclo do
            if not npcSpawnado or not npcSpawnado.Parent then
                status.Text = "Crie o clone primeiro."
                break
            end

            local personagem = jogador.Character
            local raizJogador = personagem
                and personagem:FindFirstChild("HumanoidRootPart")

            local pasta = Workspace:FindFirstChild("PopulacaoNPC")

            if not raizJogador then
                status.Text = "Personagem nao encontrado."
                task.wait(1)
                continue
            end

            if not pasta then
                status.Text = "Pasta PopulacaoNPC nao encontrada."
                break
            end

            local lista = {}

            for _, npc in ipairs(pasta:GetChildren()) do
                if npc:IsA("Model") and npc ~= npcSpawnado then
                    local raiz = npc:FindFirstChild("HumanoidRootPart")
                        or npc.PrimaryPart

                    if raiz and raiz:IsA("BasePart") then
                        table.insert(lista, {
                            Modelo = npc,
                            Distancia = (
                                raiz.Position - raizJogador.Position
                            ).Magnitude
                        })
                    end
                end
            end

            table.sort(lista, function(a, b)
                return a.Distancia < b.Distancia
            end)

            if #lista == 0 then
                status.Text = "Nenhum NPC valido encontrado."
                task.wait(2)
            else
                for _, item in ipairs(lista) do
                    if not teleporteAtivo
                        or cicloTeleporte ~= meuCiclo then
                        break
                    end

                    personagem = jogador.Character
                    raizJogador = personagem
                        and personagem:FindFirstChild("HumanoidRootPart")

                    local npc = item.Modelo
                    local raiz = npc:FindFirstChild("HumanoidRootPart")
                        or npc.PrimaryPart

                    if raizJogador and npc.Parent
                        and raiz and raiz:IsA("BasePart")
                        and npcSpawnado and npcSpawnado.Parent then

                        local distancia = math.floor(
                            (raiz.Position - raizJogador.Position).Magnitude
                        )

                        local ok, erro = pcall(function()
                            npcSpawnado:PivotTo(
                                raiz.CFrame * CFrame.new(3, 0, 0)
                            )
                        end)

                        if ok then
                            status.Text = "NPC proximo: "
                                .. npc.Name .. " (" .. distancia .. " studs)"
                        else
                            warn("[HUB NPC] Erro no teleporte:", erro)
                        end

                        task.wait(intervaloTeleporte)
                    end
                end
            end
        end

        if cicloTeleporte == meuCiclo then
            teleporteAtivo = false
            teleporteBotao.Text = "Teleporte NPCs: OFF"
        end
    end)
end)

-- MINIMIZAR E REABRIR
minimizar.MouseButton1Click:Connect(function()
    painel.Visible = false
    reabrir.Visible = true
end)

reabrir.MouseButton1Click:Connect(function()
    painel.Visible = true
    reabrir.Visible = false
end)

-- X: OCULTAR A INTERFACE SEM PARAR O TELEPORTE
fechar.MouseButton1Click:Connect(function()
    painel.Visible = false
    reabrir.Visible = false

    -- Nao altere teleporteAtivo nem cicloTeleporte aqui.
    -- O ciclo continua enquanto a execucao deste script existir.
end)

-- ARRASTAR PELO CABECALHO
local arrastando = false
local inicioInput
local inicioPosicao

titulo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        arrastando = true
        inicioInput = input.Position
        inicioPosicao = painel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not arrastando or not inicioInput then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - inicioInput

        painel.Position = UDim2.new(
            inicioPosicao.X.Scale,
            inicioPosicao.X.Offset + delta.X,
            inicioPosicao.Y.Scale,
            inicioPosicao.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        arrastando = false
    end
end)

atualizarBotoes()
