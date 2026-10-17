-- HUB NPC POLITICO - VERSAO COMPACTA
-- O X fecha a interface sem parar o teleporte
-- v2: avatar carrega por completo antes de congelar + Clone andar + Clone velocidade

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local ContentProvider = game:GetService("ContentProvider")

local jogador = Players.LocalPlayer
local playerGui = jogador:WaitForChild("PlayerGui")

local AMARELO = Color3.fromRGB(255, 220, 90)
local BRANCO = Color3.fromRGB(245, 245, 245)
local FUNDO = Color3.fromRGB(24, 27, 34)
local BOTAO = Color3.fromRGB(48, 55, 69)

local Roupas = {
    {Nome = "Original", Original = true}, -- roupa do proprio jogador
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

-- Animacoes padrao do R15 (usadas se o avatar nao tiver as dele)
local ANIM_ANDAR_PADRAO = 507777826
local ANIM_PARADO_PADRAO = 507766388

-- Modos do "Clone andar"
local MODOS_ANDAR = {"OFF", "ALEATORIO", "SEGUIR", "SEGUIR NPC"}

local indiceCargo = 1
local indiceRoupa = 1
local npcSpawnado
local nomeOriginal = "Jogador"
local partidoAtual = ""
local vipAtivo = false

local teleporteAtivo = false
local intervaloTeleporte = 2.5
local cicloTeleporte = 0

-- Clone andar / velocidade
local modoAndar = 1 -- indice em MODOS_ANDAR (1 = OFF)
local cicloAndar = 0
local velocidadeClone = 16
local centroAndar = nil
local trilhaAndar, trilhaParado
local camisaOriginal = ""
local calcaOriginal = ""

-- Ancoragem: false = so a HumanoidRootPart; true = corpo inteiro
local ancoraCorpo = false

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
painel.Size = UDim2.fromOffset(265, 500)
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
local andarBotao = criarBotao("Clone andar: OFF")
local velocidadeEntrada = criarEntrada("Velocidade do clone (padrao 16)")
local ancoraBotao = criarBotao("Ancorar: SO RAIZ")

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
    andarBotao.Text = "Clone andar: " .. MODOS_ANDAR[modoAndar]
    ancoraBotao.Text = ancoraCorpo
        and "Ancorar: CORPO INTEIRO"
        or "Ancorar: SO RAIZ"
end

-- guarda a camisa/calca que o avatar do jogador ja tinha
local function guardarRoupaOriginal(npc)
    local camisa = npc:FindFirstChildOfClass("Shirt")
    local calca = npc:FindFirstChildOfClass("Pants")

    camisaOriginal = camisa and camisa.ShirtTemplate or ""
    calcaOriginal = calca and calca.PantsTemplate or ""
end

-- APLICAR ROUPA
local function aplicarRoupa()
    if not npcSpawnado or not npcSpawnado.Parent then
        return
    end

    local roupa = Roupas[indiceRoupa]
    local camisaId, calcaId

    if roupa.Original then
        camisaId = camisaOriginal
        calcaId = calcaOriginal
    else
        camisaId = "rbxassetid://" .. roupa.Shirt
        calcaId = "rbxassetid://" .. roupa.Pants
    end

    local camisa = npcSpawnado:FindFirstChildOfClass("Shirt")
    if not camisa and camisaId ~= "" then
        camisa = Instance.new("Shirt")
        camisa.Parent = npcSpawnado
    end
    if camisa then
        camisa.ShirtTemplate = camisaId
    end

    local calca = npcSpawnado:FindFirstChildOfClass("Pants")
    if not calca and calcaId ~= "" then
        calca = Instance.new("Pants")
        calca.Parent = npcSpawnado
    end
    if calca then
        calca.PantsTemplate = calcaId
    end
end

-- BALÃO DE MENSAGEM
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

-- ============================================================
-- CARREGAMENTO COMPLETO DO AVATAR (corrige skin bugada)
-- ============================================================
-- O modelo precisa ficar SOLTO (sem Anchored) dentro do Workspace
-- ate que cabecas dinamicas, acessorios, pacotes de corpo e roupas
-- em camadas terminem de baixar e se ajustar ao esqueleto.
local function aguardarCarregamento(npc)
    -- 1) baixa texturas/malhas de tudo que ja existe no modelo
    pcall(function()
        ContentProvider:PreloadAsync(npc:GetDescendants())
    end)

    -- 2) espera o numero de descendentes estabilizar
    --    (acessorios e roupas em camadas surgem aos poucos)
    local ultimo = -1
    local estavel = 0
    local inicio = os.clock()

    while os.clock() - inicio < 6 do
        local total = #npc:GetDescendants()

        if total == ultimo then
            estavel += 1
        else
            estavel = 0
            ultimo = total
        end

        if estavel >= 5 then
            break
        end

        task.wait(0.15)
    end

    -- 3) preload final do que apareceu depois
    pcall(function()
        ContentProvider:PreloadAsync(npc:GetDescendants())
    end)

    task.wait(0.2)
end

-- ============================================================
-- ANIMACOES, FISICA E MOVIMENTO DO CLONE
-- ============================================================
local function pararAnimacoes()
    if trilhaAndar then
        pcall(function() trilhaAndar:Stop(0.15) end)
    end
    if trilhaParado then
        pcall(function() trilhaParado:Stop(0.15) end)
    end
end

-- Le o ID da animacao do proprio mapa (script Animate do personagem)
local function lerAnimacaoDoMapa(grupo, nome)
    local fontes = {}

    local personagem = jogador.Character
    local animateAtual = personagem and personagem:FindFirstChild("Animate")
    if animateAtual then
        table.insert(fontes, animateAtual)
    end

    local starter = game:GetService("StarterPlayer")
        :FindFirstChild("StarterCharacterScripts")
    local animateStarter = starter and starter:FindFirstChild("Animate")
    if animateStarter then
        table.insert(fontes, animateStarter)
    end

    for _, fonte in ipairs(fontes) do
        local pasta = fonte:FindFirstChild(grupo)
        local anim = pasta and pasta:FindFirstChild(nome)

        if anim and anim:IsA("Animation") and anim.AnimationId ~= "" then
            return anim.AnimationId
        end
    end

    return nil
end

local function carregarTrilha(animator, idDoMapa, idPadrao)
    local anim = Instance.new("Animation")
    anim.AnimationId = idDoMapa or ("rbxassetid://" .. idPadrao)

    local ok, trilha = pcall(function()
        return animator:LoadAnimation(anim)
    end)

    if ok and trilha then
        trilha.Looped = true
        trilha.Priority = Enum.AnimationPriority.Movement
        return trilha
    end

    return nil
end

local function configurarAnimacoes(npc, descricao)
    trilhaAndar = nil
    trilhaParado = nil

    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    -- animacoes do mapa (walk.Walk e idle.Idle do script Animate)
    local idAndar = lerAnimacaoDoMapa("walk", "Walk")
    local idParado = lerAnimacaoDoMapa("idle", "Idle")

    trilhaAndar = carregarTrilha(animator, idAndar, ANIM_ANDAR_PADRAO)
    trilhaParado = carregarTrilha(animator, idParado, ANIM_PARADO_PADRAO)

    humanoid.Running:Connect(function(velocidade)
        if modoAndar == 1 then
            return
        end

        if velocidade > 0.5 then
            if trilhaParado and trilhaParado.IsPlaying then
                trilhaParado:Stop(0.2)
            end
            if trilhaAndar then
                if not trilhaAndar.IsPlaying then
                    trilhaAndar:Play(0.2)
                end
                trilhaAndar:AdjustSpeed(math.clamp(velocidade / 16, 0.3, 4))
            end
        else
            if trilhaAndar and trilhaAndar.IsPlaying then
                trilhaAndar:Stop(0.2)
            end
            if trilhaParado and not trilhaParado.IsPlaying then
                trilhaParado:Play(0.2)
            end
        end
    end)
end

-- Ajusta ancoragem/colisao/velocidade conforme o modo atual
local function aplicarFisica()
    local npc = npcSpawnado
    if not npc or not npc.Parent then
        return
    end

    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    local raiz = npc:FindFirstChild("HumanoidRootPart")

    if not humanoid or not raiz then
        return
    end

    for _, parte in ipairs(npc:GetDescendants()) do
        if parte:IsA("BasePart") then
            parte.CanCollide = false
        end
    end

    humanoid.WalkSpeed = velocidadeClone
    humanoid.BreakJointsOnDeath = false

    if modoAndar == 1 then
        -- parado: so a raiz fica ancorada (o resto segue pelas juntas)
        pcall(function() humanoid:MoveTo(raiz.Position) end)
        raiz.AssemblyLinearVelocity = Vector3.zero

        for _, parte in ipairs(npc:GetDescendants()) do
            if parte:IsA("BasePart") then
                if ancoraCorpo then
                    -- corpo inteiro congelado
                    parte.Anchored = true
                else
                    -- so a raiz fixa; membros e acessorios livres na fisica
                    parte.Anchored = (parte == raiz)
                end
            end
        end

        pararAnimacoes()
    else
        -- andando: nada ancorado
        for _, parte in ipairs(npc:GetDescendants()) do
            if parte:IsA("BasePart") then
                parte.Anchored = false
            end
        end

        if trilhaParado and not trilhaParado.IsPlaying then
            trilhaParado:Play(0.2)
        end
    end
end

-- Escolhe o NPC mais proximo de workspace.PopulacaoNPC que ainda
-- nao foi visitado. Quando todos foram visitados, recomeca a lista.
local function proximoNPC(raiz, visitados)
    local pasta = Workspace:FindFirstChild("PopulacaoNPC")

    if not pasta then
        return nil, "Pasta PopulacaoNPC nao encontrada."
    end

    local function varrer()
        local melhor, melhorDistancia
        local total = 0

        for _, modelo in ipairs(pasta:GetChildren()) do
            if modelo:IsA("Model") and modelo ~= npcSpawnado then
                local raizModelo = modelo:FindFirstChild("HumanoidRootPart")
                    or modelo.PrimaryPart

                if raizModelo and raizModelo:IsA("BasePart") then
                    total += 1

                    if not visitados[modelo] then
                        local distancia = (
                            raizModelo.Position - raiz.Position
                        ).Magnitude

                        if not melhorDistancia
                            or distancia < melhorDistancia then
                            melhor = modelo
                            melhorDistancia = distancia
                        end
                    end
                end
            end
        end

        return melhor, total
    end

    local melhor, total = varrer()

    if not melhor and total > 0 then
        table.clear(visitados)
        melhor, total = varrer()
    end

    if not melhor then
        return nil, "Nenhum NPC valido encontrado."
    end

    return melhor
end

local function iniciarAndar()
    cicloAndar += 1
    local meuCiclo = cicloAndar

    task.spawn(function()
        local destino = nil
        local trocarEm = 0

        -- estado do modo SEGUIR NPC
        local alvoNPC = nil
        local inicioAlvo = 0
        local esperaAte = 0
        local visitados = {}
        local distanciaChegada = 5 -- studs para considerar "chegou"
        local pausaNoNPC = 2 -- segundos parado ao chegar no NPC

        while modoAndar ~= 1 and cicloAndar == meuCiclo do
            local npc = npcSpawnado
            local humanoid = npc and npc.Parent
                and npc:FindFirstChildOfClass("Humanoid")
            local raiz = npc and npc:FindFirstChild("HumanoidRootPart")

            -- o teleporte move o clone sozinho, entao pausamos o andar
            if humanoid and raiz and not teleporteAtivo then
                if raiz.Anchored then
                    raiz.Anchored = false
                end

                if modoAndar == 2 then
                    -- ALEATORIO: sorteia pontos perto do centro
                    centroAndar = centroAndar or raiz.Position

                    local chegou = destino
                        and (Vector3.new(raiz.Position.X, 0, raiz.Position.Z)
                            - Vector3.new(destino.X, 0, destino.Z)).Magnitude < 3

                    if not destino or chegou or os.clock() > trocarEm then
                        local angulo = math.random() * math.pi * 2
                        local distancia = math.random(8, 25)

                        destino = centroAndar + Vector3.new(
                            math.cos(angulo) * distancia,
                            0,
                            math.sin(angulo) * distancia
                        )
                        destino = Vector3.new(
                            destino.X, raiz.Position.Y, destino.Z
                        )
                        trocarEm = os.clock() + math.random(4, 8)
                    end

                    humanoid:MoveTo(destino)

                elseif modoAndar == 4 then
                    -- SEGUIR NPC: vai ate um NPC da PopulacaoNPC,
                    -- fica um instante com ele e parte para outro
                    if alvoNPC and not alvoNPC.Parent then
                        alvoNPC = nil
                    end

                    if not alvoNPC and os.clock() >= esperaAte then
                        local novo, motivo = proximoNPC(raiz, visitados)

                        if novo then
                            alvoNPC = novo
                            inicioAlvo = os.clock()
                            status.Text = "Seguindo NPC: " .. novo.Name
                        else
                            status.Text = motivo
                            esperaAte = os.clock() + 2
                        end
                    end

                    if alvoNPC then
                        local raizAlvo = alvoNPC:FindFirstChild(
                            "HumanoidRootPart"
                        ) or alvoNPC.PrimaryPart

                        if not raizAlvo then
                            alvoNPC = nil
                        else
                            local distancia = (
                                Vector3.new(
                                    raizAlvo.Position.X, 0, raizAlvo.Position.Z
                                ) - Vector3.new(
                                    raiz.Position.X, 0, raiz.Position.Z
                                )
                            ).Magnitude

                            if distancia <= distanciaChegada then
                                visitados[alvoNPC] = true
                                status.Text = "Chegou em: " .. alvoNPC.Name
                                alvoNPC = nil
                                esperaAte = os.clock() + pausaNoNPC
                                humanoid:MoveTo(raiz.Position)
                            elseif os.clock() - inicioAlvo > 20 then
                                -- travou no caminho: desiste e vai para outro
                                visitados[alvoNPC] = true
                                alvoNPC = nil
                            else
                                -- o NPC pode estar andando, entao atualiza o destino
                                humanoid:MoveTo(raizAlvo.Position)
                            end
                        end
                    end

                elseif modoAndar == 3 then
                    -- SEGUIR: vai ate o jogador e para perto dele
                    local personagem = jogador.Character
                    local raizJogador = personagem
                        and personagem:FindFirstChild("HumanoidRootPart")

                    if raizJogador then
                        local distancia = (
                            raizJogador.Position - raiz.Position
                        ).Magnitude

                        if distancia > 7 then
                            humanoid:MoveTo(raizJogador.Position)
                        else
                            humanoid:MoveTo(raiz.Position)
                        end
                    end
                end
            end

            task.wait(0.4)
        end
    end)
end

-- ============================================================
-- CRIAR NPC
-- ============================================================
-- O mapa usa um corpo R15 Blocky fixo: o filtro atua SOMENTE no
-- torso, bracos e pernas (e nas escalas do corpo). A cabeca
-- (incluindo cabecas dinamicas e rostos da loja), cabelo,
-- acessorios e roupas do jogador sao mantidos como estao.
local function forcarCorpoPadrao(descricao)
    descricao.Torso = 0
    descricao.LeftArm = 0
    descricao.RightArm = 0
    descricao.LeftLeg = 0
    descricao.RightLeg = 0

    descricao.BodyTypeScale = 0
    descricao.ProportionScale = 0
    descricao.HeightScale = 1
    descricao.WidthScale = 1
    descricao.DepthScale = 1
    -- HeadScale nao e alterado: a cabeca segue fiel ao jogador
end

local criandoNPC = false

criarNPCBotao.MouseButton1Click:Connect(function()
    if criandoNPC then
        status.Text = "Aguarde, ainda carregando..."
        return
    end

    local texto = entradaNick.Text:match("^%s*(.-)%s*$")

    if texto == "" then
        status.Text = "Informe um nick ou UserId."
        return
    end

    criandoNPC = true
    status.Text = "Carregando avatar..."

    task.spawn(function()
        local function terminar(mensagem)
            status.Text = mensagem
            criandoNPC = false
        end

        local userId

        if tonumber(texto) then
            userId = tonumber(texto)
        else
            local ok, resultado = pcall(function()
                return Players:GetUserIdFromNameAsync(texto)
            end)

            if not ok then
                warn("Erro ao buscar usuario:", resultado)
                terminar("Nick nao encontrado.")
                return
            end

            userId = resultado
        end

        local descricao
        local ok, resultado = pcall(function()
            descricao = Players:GetHumanoidDescriptionFromUserIdAsync(userId)
            forcarCorpoPadrao(descricao)

            return Players:CreateHumanoidModelFromDescriptionAsync(
                descricao,
                Enum.HumanoidRigType.R15
            )
        end)

        if not ok or not resultado then
            warn("Erro ao criar avatar:", resultado)
            terminar("Falha ao carregar avatar.")
            return
        end

        local npc = resultado
        npc.Name = "NPCVisualPolitico"

        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        local raiz = npc:FindFirstChild("HumanoidRootPart")

        if not humanoid or not raiz then
            npc:Destroy()
            terminar("Avatar invalido.")
            return
        end

        ocultarNomePadrao(npc)

        local okNome, nome = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        local nomeNovo = okNome and nome or texto

        local personagem = jogador.Character
        local raizJogador = personagem
            and personagem:FindFirstChild("HumanoidRootPart")

        if not raizJogador then
            npc:Destroy()
            terminar("Seu personagem nao foi encontrado.")
            return
        end

        local posicaoInicial = raizJogador.CFrame * CFrame.new(4, 0, -6)
        npc:PivotTo(posicaoInicial)

        -- remove scripts do modelo (nao mexe em partes/acessorios)
        for _, objeto in ipairs(npc:GetDescendants()) do
            if objeto:IsA("Script") or objeto:IsA("LocalScript") then
                objeto:Destroy()
            end
        end

        -- entra no Workspace SOLTO para o Roblox montar o avatar
        npc.Parent = Workspace

        status.Text = "Montando acessorios e roupas..."
        aguardarCarregamento(npc)

        if not npc.Parent then
            terminar("O avatar foi removido durante o carregamento.")
            return
        end

        -- agora sim: troca o NPC antigo e congela/solta conforme o modo
        if npcSpawnado and npcSpawnado.Parent then
            npcSpawnado:Destroy()
        end

        npcSpawnado = npc
        nomeOriginal = nomeNovo
        centroAndar = nil

        npc:PivotTo(posicaoInicial)

        configurarAnimacoes(npc, descricao)
        guardarRoupaOriginal(npc)
        aplicarRoupa()
        atualizarPlaca()
        atualizarBotoes()
        aplicarFisica()

        criandoNPC = false
        status.Text = "NPC criado: Sr. " .. nomeOriginal
    end)
end)

-- REMOVER NPC
removerNPCBotao.MouseButton1Click:Connect(function()
    teleporteAtivo = false
    cicloTeleporte = cicloTeleporte + 1
    teleporteBotao.Text = "Teleporte NPCs: OFF"

    modoAndar = 1
    cicloAndar = cicloAndar + 1
    centroAndar = nil
    trilhaAndar = nil
    trilhaParado = nil

    if npcSpawnado then
        npcSpawnado:Destroy()
        npcSpawnado = nil
    end

    atualizarBotoes()
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

-- CLONE ANDAR (OFF -> ALEATORIO -> SEGUIR)
andarBotao.MouseButton1Click:Connect(function()
    if not npcSpawnado or not npcSpawnado.Parent then
        status.Text = "Crie o NPC primeiro."
        return
    end

    modoAndar = modoAndar % #MODOS_ANDAR + 1
    cicloAndar = cicloAndar + 1
    centroAndar = nil

    local raiz = npcSpawnado:FindFirstChild("HumanoidRootPart")
    if raiz then
        centroAndar = raiz.Position
    end

    aplicarFisica()
    atualizarBotoes()

    if modoAndar ~= 1 then
        iniciarAndar()
    end

    status.Text = "Clone andar: " .. MODOS_ANDAR[modoAndar]
end)

-- ANCORAGEM: SO RAIZ <-> CORPO INTEIRO
ancoraBotao.MouseButton1Click:Connect(function()
    ancoraCorpo = not ancoraCorpo

    aplicarFisica()
    atualizarBotoes()

    status.Text = ancoraCorpo
        and "Ancoragem: corpo inteiro."
        or "Ancoragem: so a HumanoidRootPart."
end)

-- CLONE VELOCIDADE
velocidadeEntrada.FocusLost:Connect(function()
    local valor = tonumber(velocidadeEntrada.Text)

    if not valor then
        status.Text = "Digite um numero para a velocidade."
        return
    end

    velocidadeClone = math.clamp(valor, 0, 200)
    velocidadeEntrada.Text = tostring(velocidadeClone)

    if npcSpawnado and npcSpawnado.Parent then
        local humanoid = npcSpawnado:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = velocidadeClone
        end
    end

    status.Text = "Velocidade do clone: " .. velocidadeClone
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

                            local raizClone = npcSpawnado:FindFirstChild(
                                "HumanoidRootPart"
                            )
                            if raizClone then
                                raizClone.AssemblyLinearVelocity = Vector3.zero
                            end
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

    -- Nao altere teleporteAtivo, modoAndar nem os ciclos aqui.
    -- Teleporte e caminhada continuam enquanto o script existir.
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
