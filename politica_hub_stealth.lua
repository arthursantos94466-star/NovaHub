-- [[ CONFIGURAÇÃO DO MENU HUB COMPLEMENTE MÓVEL PARA DELTA ]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Destruir interface antiga se já tiver sido injetada antes
local antigoHub = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("PoliticaHubMobile")
if antigoHub then antigoHub:Destroy() end

-- Criar ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PoliticaHubMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- VARIÁVEIS DE CONTROLE
local loopRemote3 = false

-- [[ FUNÇÕES AUXILIARES DE MOVIMENTAÇÃO E INTERAÇÃO ]]

local function dispararPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.1)
            prompt:InputHoldEnd()
        end
    end
end

-- Teleporte Normal (Para o centro/topo do bloco)
local function teleportarPara(objeto)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart and objeto:IsA("BasePart") then
        rootPart.CFrame = objeto.CFrame
        task.wait(0.15) -- Delay exato do arquivo funcional
    end
end

-- Teleporte Furtivo (Abaixo do Chão) para o Farm de Apoio
local function teleportarAbaixoDe(objeto)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart and objeto:IsA("BasePart") then
        -- Desloca o CFrame do personagem 3.5 studs para baixo do púlpito
        rootPart.CFrame = objeto.CFrame * CFrame.new(0, -3.5, 0)
        task.wait(0.15)
    end
end

-- [[ LÓGICAS OPERACIONAIS ]]

-- Função 1: Iniciar Teleport + Conversar NPCs
local function ExecutarRemote1()
    local populacaoNPC = Workspace:FindFirstChild("PopulacaoNPC")
    if not populacaoNPC then return end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        for _, npc in ipairs(populacaoNPC:GetChildren()) do
            local npcRoot = npc:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                rootPart.CFrame = npcRoot.CFrame
                task.wait(0.15)
                
                local prompt = npcRoot:FindFirstChild("ConversarPrompt")
                if prompt and prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
                task.wait(0.3)
            end
        end
    end
end

-- Função 2: Teleporte + Debate
local function ExecutarRemote2()
    local ponto = Workspace:FindFirstChild("PontosInteracao") and Workspace.PontosInteracao:FindFirstChild("EstudoDebate")
    if ponto then
        teleportarPara(ponto)
        local prompt = ponto:FindFirstChild("DebateEstudoPrompt")
        dispararPrompt(prompt)
    end
end

-- Função 3: Farm Apoio (Com Teleporte Subterrâneo Otimizado)
local function ExecutarRemote3(estado)
    loopRemote3 = estado
    if not loopRemote3 then return end
    
    local localTeleporte = Workspace:FindFirstChild("Manifestacao") 
        and Workspace.Manifestacao:FindFirstChild("PalcoManifestacao") 
        and Workspace.Manifestacao.PalcoManifestacao:FindFirstChild("Pulpito") 
        and Workspace.Manifestacao.PalcoManifestacao.Pulpito:FindFirstChild("CorpoPulpito")
        
    local localPrompt = Workspace:FindFirstChild("PontosInteracao") 
        and Workspace.PontosInteracao:FindFirstChild("ManifestacaoDeclararApoio") 
        and Workspace.PontosInteracao.ManifestacaoDeclararApoio:FindFirstChild("ManifestacaoPrompt")
    
    if localTeleporte and localPrompt then
        task.spawn(function()
            while loopRemote3 do
                if localTeleporte.CanCollide == true then
                    -- Teleporta para baixo do chão do púlpito de forma invisível para os outros
                    teleportarAbaixoDe(localTeleporte)
                    
                    if not loopRemote3 then break end
                    dispararPrompt(localPrompt)
                end
                task.wait(0.5)
            end
        end)
    end
end

-- Função 4: Teleporte + Mesa Parlamentar
local function ExecutarRemote4()
    local mesa = Workspace:FindFirstChild("MesaParlamentar")
    if mesa then
        teleportarPara(mesa)
        local prompt = mesa:FindFirstChild("PropostaParlamentarPrompt")
        dispararPrompt(prompt)
    end
end

-- Função 5: Teleporte + Ponto Candidatura
local function ExecutarRemote5()
    local ponto = Workspace:FindFirstChild("PontoCandidatura")
    if ponto then
        teleportarPara(ponto)
        local prompt = ponto:FindFirstChild("CandidaturaPrompt")
        dispararPrompt(prompt)
    end
end

-- [[ CONSTRUÇÃO DA INTERFACE VISUAL MÓVEL ]]

-- Botão Flutuante para Abrir (Posicionado no alto da tela)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.2, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
OpenBtn.Text = "HUB"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 14
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenBtn

-- Frame Principal do Menu
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Título do Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA - POLITICA SIMULATOR v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Botão de Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(240, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

-- Container de Rolagem dos Botões
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 260)
Container.ScrollBarThickness = 3
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- Função Criadora de Botões internos
local function criarBotao(texto, layoutOrder, cliqueCallback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -5, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Btn.Text = texto
    Btn.TextColor3 = Color3.fromRGB(245, 245, 245)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.LayoutOrder = layoutOrder
    Btn.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(cliqueCallback)
    return Btn
end

-- [[ CONFIGURAÇÃO E NOMENCLATURA DOS BOTÕES ]]

criarBotao("Teleporte PopulacaoNPC", 1, ExecutarRemote1)
criarBotao("Teleporte EstudoDebate", 2, ExecutarRemote2)

local toggleR3 = false
local btnR3 = criarBotao("Farm Apoio [OFF]", 3, function() end)
btnR3.MouseButton1Click:Connect(function()
    toggleR3 = not toggleR3
    if toggleR3 then
        btnR3.Text = "Farm Apoio [ON]"
        btnR3.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ExecutarRemote3(true)
    else
        btnR3.Text = "Farm Apoio [OFF]"
        btnR3.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        ExecutarRemote3(false)
    end
end)

criarBotao("Teleporte MesaParlamentar", 4, ExecutarRemote4)
criarBotao("Teleporte PontoCandidatura", 5, ExecutarRemote5)

-- [[ SISTEMA DE ALTERNÂNCIA (ABRIR / FECHAR) ]]

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true, function()
        MainFrame.Visible = false
        OpenBtn.Visible = true
    end)
end)

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    MainFrame.Visible = true
    MainFrame:TweenSize(UDim2.new(0, 340, 0, 260), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
end)

-- [[ FUNÇÃO REUTILIZÁVEL PARA ARRASTAR ELEMENTOS (MOBILE TOUCH) ]]

local function configurarMovimento(instanciaFrame)
    local dragging, dragInput, dragStart, startPos

    instanciaFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = instanciaFrame.Position
        end
    end)

    instanciaFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            instanciaFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    instanciaFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
end

configurarMovimento(OpenBtn)
configurarMovimento(MainFrame)
