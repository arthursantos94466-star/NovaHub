--[[
██╗███████╗██╗   ██╗██╗   ██╗██████╗     █████╗ ██╗   ██╗████████╗ ██████╗
██║██╔════╝██║   ██║██║   ██║██╔══██╗   ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗
██║█████╗  ██║   ██║██║   ██║██████╔╝   ███████║██║   ██║   ██║   ██║   ██║
██║██╔══╝  ██║   ██║██║   ██║██╔══██╗   ██╔══██║██║   ██║   ██║   ██║   ██║
██║██║     ╚██████╔╝╚██████╔╝██║  ██║   ██║  ██║╚██████╔╝   ██║   ╚██████╔╝
╚═╝╚═╝      ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Módulos e referências
local IfuudRemotes = ReplicatedStorage:WaitForChild("Remotes")
local IfuudEvent = IfuudRemotes:WaitForChild("IfuudEvent")
local IfuudCoordinates = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("IfuudCoordinates"))
local GPSBill = ReplicatedStorage:WaitForChild("BilboardGui"):WaitForChild("GPSBil")

-- Interface do script
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IfuudAutoFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Arredondar cantos
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(232, 29, 43)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🍔 Ifuud Auto Farm"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextScaled = true
TitleLabel.Parent = TitleBar

-- Botão fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Scroll Frame para os controles
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(232, 29, 43)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- ============ VARIÁVEIS DE ESTADO ============

local AutoFarm = {
    Ativo = false,
    PreferenciaLonge = false,
    Modo = "Normal", -- "Normal", "Turbo"
    
    -- Estado da missão
    EmMissao = false,
    Fase = "Ocioso", -- Ocioso, Localizando, IndoColeta, Coletando, IndoEntrega, Codigo, Entregando
    
    -- Referências
    PedidoAtual = nil,
    PosicaoColeta = nil,
    PosicaoEntrega = nil,
    CodigoSeguranca = "",
    NPCDialogo = nil,
    
    -- Stats
    TotalEntregas = 0,
    TotalGanho = 0,
    TempoInicio = 0,
}

-- Conexões para limpeza
local Conexoes = {}
local HeartbeatConn = nil

-- ============ FUNÇÕES DE UTILIDADE ============

local function TeleportTo(position)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local hrp = character.HumanoidRootPart
    hrp.CFrame = CFrame.new(position)
    return true
end

local function GetDistanceTo(position)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (character.HumanoidRootPart.Position - position).Magnitude
end

local function Esperar(segundos)
    if not AutoFarm.Ativo then return false end
    task.wait(segundos)
    return AutoFarm.Ativo
end

-- ============ SISTEMA DE GPS ============

local GPSAttachment = nil
local GPSBillboard = nil

local function CriarGPS(posicao)
    if GPSAttachment then
        GPSAttachment:Destroy()
        GPSAttachment = nil
    end
    if GPSBillboard then
        GPSBillboard:Destroy()
        GPSBillboard = nil
    end
    
    GPSAttachment = Instance.new("Attachment")
    GPSAttachment.Name = "AutoFarm_GPS"
    GPSAttachment.WorldPosition = posicao
    GPSAttachment.Parent = workspace:WaitForChild("Terrain")
    
    GPSBillboard = GPSBill:Clone()
    GPSBillboard.Adornee = GPSAttachment
    GPSBillboard.Enabled = true
    GPSBillboard.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function RemoverGPS()
    if GPSBillboard then
        GPSBillboard:Destroy()
        GPSBillboard = nil
    end
    if GPSAttachment then
        GPSAttachment:Destroy()
        GPSAttachment = nil
    end
end

-- ============ SISTEMA DE MOVIMENTO AUTOMÁTICO ============

local function MoverPara(posicao, tolerance)
    tolerance = tolerance or 5
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    -- Tenta teleportar diretamente se estiver em modo turbo ou se a distância for grande
    if AutoFarm.Modo == "Turbo" or GetDistanceTo(posicao) > 500 then
        TeleportTo(posicao)
        return Esperar(0.3)
    end
    
    -- Movimento caminhando com tween
    while AutoFarm.Ativo and GetDistanceTo(posicao) > tolerance do
        local direction = (posicao - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
        humanoid:Move(direction, true)
        RunService.Heartbeat:Wait()
    end
    
    humanoid:Move(Vector3.new(0,0,0), false)
    return AutoFarm.Ativo
end

-- ============ SISTEMA DE AUTO-COMPLETAR CÓDIGO ============

local function InserirCodigo(codigo)
    if not codigo or #codigo ~= 4 then return false end
    
    -- Encontra o frame de código
    local CodeIfuud = LocalPlayer.PlayerGui:FindFirstChild("CodeIfuud")
    if not CodeIfuud then return false end
    
    local DialogoFrame = CodeIfuud:FindFirstChild("DialogoFrame")
    if not DialogoFrame or not DialogoFrame.Visible then return false end
    
    -- Encontra o campo de texto
    local CodigoTxt = nil
    for _, child in ipairs(CodeIfuud:GetDescendants()) do
        if child:IsA("TextBox") and child.Name == "CodigoTxt" then
            CodigoTxt = child
            break
        end
    end
    
    if not CodigoTxt then return false end
    
    -- Foca e insere o código
    CodigoTxt:CaptureFocus()
    task.wait(0.1)
    CodigoTxt.Text = ""
    task.wait(0.05)
    CodigoTxt.Text = codigo
    task.wait(0.1)
    CodigoTxt:ReleaseFocus()
    
    -- Procura o botão Confirmar
    for _, child in ipairs(CodeIfuud:GetDescendants()) do
        if child:IsA("TextButton") and child.Name == "Confirmar" and child.Interactable then
            task.wait(0.2)
            -- Simula clique
            local pos = child.AbsolutePosition
            local size = child.AbsoluteSize
            VirtualInputManager:SendMouseButtonEvent(
                pos.X + size.X/2,
                pos.Y + size.Y/2,
                0, true, game, 0
            )
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(
                pos.X + size.X/2,
                pos.Y + size.Y/2,
                0, false, game, 0
            )
            return true
        end
    end
    
    return false
end

-- ============ SISTEMA DE AUTO-INTERAÇÃO COM PROMPTS ============

local function InteragirComPrompt(nomePrompt)
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Name == nomePrompt and desc.Enabled then
            local holdDuration = desc.HoldDuration
            local part = desc.Parent
            if part and part:IsA("BasePart") then
                -- Teleporta para perto do prompt
                TeleportTo(part.Position + Vector3.new(0, 2, 0))
                task.wait(0.3)
                
                -- Pressiona E para interagir
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(holdDuration + 0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(0.2)
                return true
            end
        end
    end
    return false
end

-- ============ FUNÇÃO PRINCIPAL DE AUTO FARM ============

local function ProcessoAutoFarm()
    while AutoFarm.Ativo do
        -- Verifica se está na fase correta
        if not AutoFarm.Ativo then break end
        
        -- ===== FASE 1: LOCALIZAR PEDIDO =====
        AutoFarm.Fase = "Localizando"
        AtualizarStatus()
        
        -- Ativa preferência (próximo ou longe)
        IfuudEvent:FireServer("AtualizarPreferenca", {["PrefLonge"] = AutoFarm.PreferenciaLonge})
        task.wait(0.2)
        
        -- Localiza pedido
        IfuudEvent:FireServer("LocalizarPedido")
        task.wait(2)
        
        if not AutoFarm.Ativo then break end
        
        -- ===== FASE 2: IR ATÉ A COLETA =====
        AutoFarm.Fase = "IndoColeta"
        AtualizarStatus()
        
        -- Espera o GPS aparecer
        local tempoEspera = 0
        while tempoEspera < 8 and AutoFarm.Ativo do
            -- Tenta encontrar o marcador do pedido
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "GetOrders" or obj.Name == "Pedidos" then
                    -- Encontrou a estrutura, agora procura o pedido
                end
            end
            
            -- Verifica se já tem o prompt PegarPedido disponível
            local promptEncontrado = false
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Name == "PegarPedido" and desc.Enabled then
                    promptEncontrado = true
                    break
                end
            end
            
            if promptEncontrado then break end
            task.wait(0.5)
            tempoEspera = tempoEspera + 0.5
        end
        
        if not AutoFarm.Ativo then break end
        
        -- ===== FASE 3: PEGAR PEDIDO =====
        AutoFarm.Fase = "Coletando"
        AtualizarStatus()
        
        -- Interage com o prompt PegarPedido
        InteragirComPrompt("PegarPedido")
        task.wait(2)
        
        if not AutoFarm.Ativo then break end
        
        -- ===== FASE 4: IR ATÉ A ENTREGA =====
        AutoFarm.Fase = "IndoEntrega"
        AtualizarStatus()
        
        -- Aguarda o GPS da entrega aparecer
        tempoEspera = 0
        while tempoEspera < 8 and AutoFarm.Ativo do
            local promptEncontrado = false
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Name == "Entregar" and desc.Enabled then
                    promptEncontrado = true
                    break
                end
            end
            
            if promptEncontrado then break end
            task.wait(0.5)
            tempoEspera = tempoEspera + 0.5
        end
        
        if not AutoFarm.Ativo then break end
        
        -- ===== FASE 5: INSERIR CÓDIGO =====
        AutoFarm.Fase = "Codigo"
        AtualizarStatus()
        
        -- Espera o diálogo do código aparecer
        tempoEspera = 0
        local codigoInserido = false
        while tempoEspera < 5 and AutoFarm.Ativo and not codigoInserido do
            -- Procura o código na interface
            local CodeIfuud = LocalPlayer.PlayerGui:FindFirstChild("CodeIfuud")
            if CodeIfuud then
                local DialogoFrame = CodeIfuud:FindFirstChild("DialogoFrame")
                if DialogoFrame and DialogoFrame.Visible then
                    -- Tenta extrair o código do texto do diálogo
                    local Assunto = DialogoFrame:FindFirstChild("Assunto")
                    if Assunto then
                        local texto = Assunto.Text
                        -- Procura por 4 dígitos no texto
                        local codigo = string.match(texto, "(%d%d%d%d)")
                        if codigo then
                            AutoFarm.CodigoSeguranca = codigo
                            InserirCodigo(codigo)
                            codigoInserido = true
                            task.wait(1)
                            break
                        end
                    end
                end
            end
            task.wait(0.3)
            tempoEspera = tempoEspera + 0.3
        end
        
        if not AutoFarm.Ativo then break end
        
        -- Tenta inserir de novo se falhou
        if not codigoInserido then
            local CodeIfuud = LocalPlayer.PlayerGui:FindFirstChild("CodeIfuud")
            if CodeIfuud then
                local DialogoFrame = CodeIfuud:FindFirstChild("DialogoFrame")
                if DialogoFrame and DialogoFrame.Visible then
                    local Assunto = DialogoFrame:FindFirstChild("Assunto")
                    if Assunto then
                        local codigo = string.match(Assunto.Text, "(%d%d%d%d)")
                        if codigo then
                            InserirCodigo(codigo)
                            task.wait(1)
                        end
                    end
                end
            end
        end
        
        -- ===== FASE 6: ENTREGAR =====
        AutoFarm.Fase = "Entregando"
        AtualizarStatus()
        
        InteragirComPrompt("Entregar")
        task.wait(3)
        
        if not AutoFarm.Ativo then break end
        
        -- ===== FASE 7: FINALIZAR =====
        AutoFarm.Fase = "Ocioso"
        
        -- Atualiza stats
        AutoFarm.TotalEntregas = AutoFarm.TotalEntregas + 1
        
        -- Espera um pouco antes de começar a próxima
        AtualizarStatus()
        task.wait(1)
    end
    
    -- Limpeza
    AutoFarm.Fase = "Ocioso"
    if HeartbeatConn then
        HeartbeatConn:Disconnect()
        HeartbeatConn = nil
    end
    AtualizarStatus()
end

-- ============ ATUALIZAR STATUS NA UI ============

local StatusLabel = nil
local StatsLabel = nil

local function AtualizarStatus()
    if not StatusLabel then return end
    
    local faseText = AutoFarm.Fase
    local faseDisplay = {
        Ocioso = "🟢 Parado",
        Localizando = "🔍 Localizando pedido...",
        IndoColeta = "📍 Indo para coleta...",
        Coletando = "📦 Coletando pedido...",
        IndoEntrega = "📍 Indo para entrega...",
        Codigo = "🔑 Inserindo código...",
        Entregando = "✅ Entregando...",
    }
    
    local status = faseDisplay[faseText] or "⏳ Aguardando..."
    if AutoFarm.Ativo then
        StatusLabel.Text = "🟢 ATIVO - " .. status
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "🔴 DESATIVADO"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    end
    
    if StatsLabel then
        StatsLabel.Text = string.format("Entregas: %d | Modo: %s", 
            AutoFarm.TotalEntregas,
            AutoFarm.Modo
        )
    end
end

-- ============ CRIAR INTERFACE ============

function CriarBotao(texto, descricao, cor, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Container.BorderSizePixel = 0
    Container.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Container
    
    local Botao = Instance.new("TextButton")
    Botao.Size = UDim2.new(1, -5, 1, -5)
    Botao.Position = UDim2.new(0, 3, 0, 3)
    Botao.BackgroundColor3 = cor
    Botao.Text = texto
    Botao.TextColor3 = Color3.fromRGB(255, 255, 255)
    Botao.Font = Enum.Font.GothamBold
    Botao.TextSize = 14
    Botao.Parent = Container
    
    local BtnCorner2 = Instance.new("UICorner")
    BtnCorner2.CornerRadius = UDim.new(0, 4)
    BtnCorner2.Parent = Botao
    
    Botao.MouseButton1Click:Connect(callback)
    
    return Botao, Container
end

-- Título de seção
function CriarSecao(texto)
    local Secao = Instance.new("TextLabel")
    Secao.Size = UDim2.new(1, 0, 0, 25)
    Secao.BackgroundTransparency = 1
    Secao.Text = texto
    Secao.TextColor3 = Color3.fromRGB(232, 29, 43)
    Secao.Font = Enum.Font.GothamBold
    Secao.TextSize = 14
    Secao.TextXAlignment = Enum.TextXAlignment.Left
    Secao.Parent = ScrollFrame
    
    return Secao
end

-- Status
local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, 0, 0, 70)
StatusContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
StatusContainer.BorderSizePixel = 0
StatusContainer.Parent = ScrollFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusContainer

StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0.5, 0)
StatusLabel.Position = UDim2.new(0, 5, 0, 5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "🔴 DESATIVADO"
StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusContainer

StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -10, 0.5, -5)
StatsLabel.Position = UDim2.new(0, 5, 0.5, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "Entregas: 0 | Modo: Normal"
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = StatusContainer

-- Seção: Controles
CriarSecao("=== CONTROLES ===")

-- Botão Ativar/Desativar
local BtnAtivar, CtrlAtivar = CriarBotao("▶ INICIAR AUTO FARM", "Iniciar o farm automático", Color3.fromRGB(0, 180, 50), function()
    if AutoFarm.Ativo then
        AutoFarm.Ativo = false
        BtnAtivar.Text = "▶ INICIAR AUTO FARM"
        BtnAtivar.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
        RemoverGPS()
        AtualizarStatus()
    else
        AutoFarm.Ativo = true
        AutoFarm.TotalEntregas = 0
        BtnAtivar.Text = "⏹ PARAR AUTO FARM"
        BtnAtivar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        AtualizarStatus()
        task.spawn(ProcessoAutoFarm)
    end
end)

-- Seção: Configurações
CriarSecao("=== CONFIGURAÇÕES ===")

-- Botão Preferência
local prefLonge = false
local BtnPref, CtrlPref = CriarBotao("📍 ENTREGAS PRÓXIMAS", "Alternar entre entregas próximas e distantes", Color3.fromRGB(50, 50, 150), function()
    prefLonge = not prefLonge
    AutoFarm.PreferenciaLonge = prefLonge
    if prefLonge then
        BtnPref.Text = "📍 ENTREGAS DISTANTES"
        BtnPref.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        BtnPref.Text = "📍 ENTREGAS PRÓXIMAS"
        BtnPref.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    end
end)

-- Botão Modo
local BtnModo, CtrlModo = CriarBotao("⚡ MODO: NORMAL", "Alternar entre modo normal e turbo (teleporte)", Color3.fromRGB(100, 50, 100), function()
    if AutoFarm.Modo == "Normal" then
        AutoFarm.Modo = "Turbo"
        BtnModo.Text = "⚡ MODO: TURBO"
        BtnModo.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    else
        AutoFarm.Modo = "Normal"
        BtnModo.Text = "⚡ MODO: NORMAL"
        BtnModo.BackgroundColor3 = Color3.fromRGB(100, 50, 100)
    end
end)

-- Botão Resetar
CriarSecao("=== AÇÕES ===")

local BtnReset, CtrlReset = CriarBotao("🔄 RESETAR MISSÃO", "Cancela a missão atual", Color3.fromRGB(150, 60, 60), function()
    IfuudEvent:FireServer("ResetarMissao")
    RemoverGPS()
end)

-- Botão Teleporte para Entrega
local BtnTeleport, CtrlTeleport = CriarBotao("📌 GPS ÚLTIMA ENTREGA", "Teleporta para o último ponto de entrega", Color3.fromRGB(60, 60, 150), function()
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Name == "Entregar" and desc.Enabled then
            local part = desc.Parent
            if part and part:IsA("BasePart") then
                TeleportTo(part.Position + Vector3.new(0, 3, 0))
                break
            end
        end
    end
end)

-- Atualizar CanvasSize
local function AtualizarCanvasSize()
    local totalHeight = 0
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            totalHeight = totalHeight + child.Size.Y.Offset + UIListLayout.Padding.Offset
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
end

task.wait(0.1)
AtualizarCanvasSize()

-- Conectar fechar
CloseButton.MouseButton1Click:Connect(function()
    AutoFarm.Ativo = false
    ScreenGui:Destroy()
    RemoverGPS()
end)

-- ============ SISTEMA DE DRAG ============

local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Mensagem inicial
print("🍔 Ifuud Auto Farm carregado!")
print("📌 Pressione INICIAR para começar o farm automático.")

-- Notificação na tela
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 300, 0, 40)
Notification.Position = UDim2.new(0.5, -150, 0.8, 0)
Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Notification.BackgroundTransparency = 0.2
Notification.Text = "🍔 Ifuud Auto Farm carregado!"
Notification.TextColor3 = Color3.fromRGB(0, 255, 100)
Notification.Font = Enum.Font.GothamBold
Notification.TextSize = 14
Notification.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 6)
NotifCorner.Parent = Notification

task.delay(3, function()
    if Notification then
        TweenService:Create(Notification, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.5)
        Notification:Destroy()
    end
end)
