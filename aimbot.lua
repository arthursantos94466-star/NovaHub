--[[
╔══════════════════════════════════════════════╗
║         PAINEL AIMBOT + ESP — RO BLOX        ║
║  Menu Circular Arrastável · Mobile/PC        ║
║  + Wall Check · Team Check · Kill Check      ║
╚══════════════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variáveis globais do painel
local PanelAberto = false
local AbaAtual = "AIMBOT"
local AimEnabled = false
local ESPEnabled = false
local FOV = 90
local AimPart = "Head"
local ESP_Aura = false
local ESP_Nome = false
local ESP_Distancia = false
local ESP_Esqueleto = false
local DistanciaMaxima = 300

-- NOVAS VARIÁVEIS
local WallCheck = false
local TeamCheck = false
local KillCheck = false
local JogadoresMatados = {}

-- Cores por distância
local CorPerto = Color3.fromRGB(255, 0, 0)
local CorLonge = Color3.fromRGB(0, 100, 255)
local DistanciaTrocaCor = 80

-- =============================================
-- CRIAÇÃO DA GUI
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerPanel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- =============================================
-- BOTÃO CIRCULAR (ABRIR/FECHAR)
-- =============================================
local BotaoCircular = Instance.new("ImageButton")
BotaoCircular.Name = "BotaoCircular"
BotaoCircular.Size = UDim2.new(0, 55, 0, 55)
BotaoCircular.Position = UDim2.new(0.5, -27, 0.85, 0)
BotaoCircular.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BotaoCircular.BackgroundTransparency = 0.15
BotaoCircular.BorderSizePixel = 0
BotaoCircular.Image = "rbxassetid://3570695787"
BotaoCircular.ImageColor3 = Color3.fromRGB(0, 170, 255)
BotaoCircular.ImageTransparency = 0.2
BotaoCircular.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = BotaoCircular

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
})
UIGradient.Rotation = 45
UIGradient.Parent = BotaoCircular

local IconeLabel = Instance.new("TextLabel")
IconeLabel.Name = "Icone"
IconeLabel.Size = UDim2.new(1, 0, 1, 0)
IconeLabel.BackgroundTransparency = 1
IconeLabel.Text = "⚡"
IconeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IconeLabel.TextSize = 24
IconeLabel.Font = Enum.Font.GothamBold
IconeLabel.Parent = BotaoCircular

-- =============================================
-- PAINEL PRINCIPAL
-- =============================================
local Painel = Instance.new("Frame")
Painel.Name = "PainelPrincipal"
Painel.Size = UDim2.new(0, 340, 0, 520)
Painel.Position = UDim2.new(0.5, -170, 0.2, 0)
Painel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Painel.BackgroundTransparency = 0.08
Painel.BorderSizePixel = 0
Painel.Visible = false
Painel.Parent = ScreenGui

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 12)
UIPadding.PaddingBottom = UDim.new(0, 12)
UIPadding.PaddingLeft = UDim.new(0, 12)
UIPadding.PaddingRight = UDim.new(0, 12)
UIPadding.Parent = Painel

local UICornerPainel = Instance.new("UICorner")
UICornerPainel.CornerRadius = UDim.new(0, 12)
UICornerPainel.Parent = Painel

local StrokePainel = Instance.new("UIStroke")
StrokePainel.Color = Color3.fromRGB(0, 170, 255)
StrokePainel.Thickness = 1.5
StrokePainel.Transparency = 0.3
StrokePainel.Parent = Painel

local Titulo = Instance.new("TextLabel")
Titulo.Name = "Titulo"
Titulo.Size = UDim2.new(1, 0, 0, 35)
Titulo.BackgroundTransparency = 1
Titulo.Text = "🎯 PAINEL HACK v3"
Titulo.TextColor3 = Color3.fromRGB(0, 170, 255)
Titulo.TextSize = 18
Titulo.Font = Enum.Font.GothamBold
Titulo.Parent = Painel

-- =============================================
-- ABAS
-- =============================================
local AbasFrame = Instance.new("Frame")
AbasFrame.Name = "Abas"
AbasFrame.Size = UDim2.new(1, 0, 0, 40)
AbasFrame.Position = UDim2.new(0, 0, 0, 38)
AbasFrame.BackgroundTransparency = 1
AbasFrame.Parent = Painel

local AbaAimbot = Instance.new("TextButton")
AbaAimbot.Name = "AbaAimbot"
AbaAimbot.Size = UDim2.new(0.33, -4, 1, 0)
AbaAimbot.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
AbaAimbot.BackgroundTransparency = 0.6
AbaAimbot.Text = "🎯 AIMBOT"
AbaAimbot.TextColor3 = Color3.fromRGB(255, 255, 255)
AbaAimbot.TextSize = 13
AbaAimbot.Font = Enum.Font.GothamBold
AbaAimbot.BorderSizePixel = 0
AbaAimbot.Parent = AbasFrame

local UICornerAba1 = Instance.new("UICorner")
UICornerAba1.CornerRadius = UDim.new(0, 8)
UICornerAba1.Parent = AbaAimbot

local AbaESP = Instance.new("TextButton")
AbaESP.Name = "AbaESP"
AbaESP.Size = UDim2.new(0.33, -4, 1, 0)
AbaESP.Position = UDim2.new(0.33, 4, 0, 0)
AbaESP.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AbaESP.BackgroundTransparency = 0.4
AbaESP.Text = "👁️ ESP"
AbaESP.TextColor3 = Color3.fromRGB(180, 180, 180)
AbaESP.TextSize = 13
AbaESP.Font = Enum.Font.GothamBold
AbaESP.BorderSizePixel = 0
AbaESP.Parent = AbasFrame

local UICornerAba2 = Instance.new("UICorner")
UICornerAba2.CornerRadius = UDim.new(0, 8)
UICornerAba2.Parent = AbaESP

local AbaChecks = Instance.new("TextButton")
AbaChecks.Name = "AbaChecks"
AbaChecks.Size = UDim2.new(0.33, -4, 1, 0)
AbaChecks.Position = UDim2.new(0.66, 8, 0, 0)
AbaChecks.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AbaChecks.BackgroundTransparency = 0.4
AbaChecks.Text = "🔧 CHECKS"
AbaChecks.TextColor3 = Color3.fromRGB(180, 180, 180)
AbaChecks.TextSize = 13
AbaChecks.Font = Enum.Font.GothamBold
AbaChecks.BorderSizePixel = 0
AbaChecks.Parent = AbasFrame

local UICornerAba3 = Instance.new("UICorner")
UICornerAba3.CornerRadius = UDim.new(0, 8)
UICornerAba3.Parent = AbaChecks

-- =============================================
-- SCROLLING FRAME
-- =============================================
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "Conteudo"
ScrollingFrame.Size = UDim2.new(1, 0, 1, -85)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 82)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = Painel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

-- =============================================
-- FUNÇÕES AUXILIARES
-- =============================================
function CriarToggle(nome, descricao, cor, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = ScrollingFrame
    
    local UICornerF = Instance.new("UICorner")
    UICornerF.CornerRadius = UDim.new(0, 8)
    UICornerF.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = descricao
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = nome
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = frame
    
    local UICornerT = Instance.new("UICorner")
    UICornerT.CornerRadius = UDim.new(0, 13)
    UICornerT.Parent = toggleBtn
    
    local ativo = false
    toggleBtn.MouseButton1Click:Connect(function()
        ativo = not ativo
        if ativo then
            toggleBtn.BackgroundColor3 = cor or Color3.fromRGB(0, 170, 0)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            toggleBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
            toggleBtn.Text = "OFF"
        end
        if callback then callback(ativo) end
    end)
    
    return frame, toggleBtn
end

function CriarSlider(nome, descricao, min, max, padrao, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = ScrollingFrame
    
    local UICornerF = Instance.new("UICorner")
    UICornerF.CornerRadius = UDim.new(0, 8)
    UICornerF.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = descricao
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valorLabel = Instance.new("TextLabel")
    valorLabel.Size = UDim2.new(0.25, 0, 0, 22)
    valorLabel.Position = UDim2.new(0.75, 0, 0, 4)
    valorLabel.BackgroundTransparency = 1
    valorLabel.Text = tostring(padrao)
    valorLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    valorLabel.TextSize = 14
    valorLabel.Font = Enum.Font.GothamBold
    valorLabel.TextXAlignment = Enum.TextXAlignment.Right
    valorLabel.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 6)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 36)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame
    
    local UICornerS = Instance.new("UICorner")
    UICornerS.CornerRadius = UDim.new(1, 0)
    UICornerS.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((padrao - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local UICornerFill = Instance.new("UICorner")
    UICornerFill.CornerRadius = UDim.new(1, 0)
    UICornerFill.Parent = fill
    
    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 20, 0, 20)
    drag.Position = UDim2.new((padrao - min) / (max - min), -10, 0.5, -10)
    drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    drag.Text = ""
    drag.BorderSizePixel = 0
    drag.Parent = sliderFrame
    
    local UICornerDrag = Instance.new("UICorner")
    UICornerDrag.CornerRadius = UDim.new(1, 0)
    UICornerDrag.Parent = drag
    
    local dragging = false
    local valor = padrao
    
    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = sliderFrame.AbsolutePosition
            local absSize = sliderFrame.AbsoluteSize
            local relX = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            valor = math.floor(min + (max - min) * relX)
            valorLabel.Text = tostring(valor)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            drag.Position = UDim2.new(relX, -10, 0.5, -10)
            if callback then callback(valor) end
        end
    end)
    
    return frame
end

-- =============================================
-- FUNÇÃO: VERIFICAR SE TEM PAREDE NO MEIO (WALL CHECK)
-- =============================================
local function HasWallBetween(origin, target)
    if not WallCheck then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Parent}
    
    local direction = (target.Position - origin.Position)
    local distance = direction.Magnitude
    direction = direction.Unit
    
    local result = Workspace:Raycast(origin.Position, direction * distance, raycastParams)
    
    return result ~= nil
end

-- =============================================
-- FUNÇÃO: VERIFICAR SE É DO MESMO TIME (TEAM CHECK)
-- =============================================
local function IsSameTeam(player)
    if not TeamCheck then return false end
    
    local localChar = LocalPlayer.Character
    local targetChar = player.Character
    if not localChar or not targetChar then return true end
    
    local localTeam = localChar:FindFirstChild("TeamColor") or localChar:FindFirstChild("Team")
    local targetTeam = targetChar:FindFirstChild("TeamColor") or targetChar:FindFirstChild("Team")
    
    -- Verificar por cor de time
    if localTeam and targetTeam then
        if localTeam.Value == targetTeam.Value then
            return true
        end
    end
    
    -- Verificar por NPC/Inimigo tradicional
    local humanoid = targetChar:FindFirstChild("Humanoid")
    if humanoid then
        -- Se o alvo for um NPC (não player real), considerar como inimigo
        if not Players:GetPlayerFromCharacter(targetChar) then
            return false
        end
    end
    
    return false
end

-- =============================================
-- FUNÇÃO: VERIFICAR SE JÁ MATOU O JOGADOR (KILL CHECK)
-- =============================================
local function IsAlreadyKilled(player)
    if not KillCheck then return false end
    return JogadoresMatados[player.UserId] == true
end

-- =============================================
-- MONITORAR KILLS (DETECTAR QUANDO MATA ALGUÉM)
-- =============================================
local function MonitorarKills()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then
        -- Esperar o personagem carregar
        LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid")
            hum.Died:Connect(function()
                -- Não faz nada quando o próprio player morre
            end)
        end)
        return
    end
    
    -- Verificar dano causado
    local function onDamage(amount, source)
        if not source or not source.Parent then return end
        local victimChar = source.Parent
        local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
        
        if victimPlayer and victimPlayer ~= LocalPlayer then
            local victimHumanoid = victimChar:FindFirstChild("Humanoid")
            if victimHumanoid and victimHumanoid.Health <= 0 then
                JogadoresMatados[victimPlayer.UserId] = true
                print("💀 Kill Check: Matou " .. victimPlayer.DisplayName)
            end
        end
    end
    
    -- Conectar ao evento de dano
    if humanoid:FindFirstChild("DamageTaken") then
        humanoid.DamageTaken:Connect(onDamage)
    end
end

-- Tentar monitorar kills quando o personagem carregar
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if hum then
        local conn
        conn = hum.ChildAdded:Connect(function(child)
            if child.Name == "DamageTaken" then
                child:Connect(function(amount, source)
                    if not source or not source.Parent then return end
                    local victimChar = source.Parent
                    local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
                    if victimPlayer and victimPlayer ~= LocalPlayer then
                        local victimHumanoid = victimChar:FindFirstChild("Humanoid")
                        if victimHumanoid and victimHumanoid.Health <= 0 then
                            JogadoresMatados[victimPlayer.UserId] = true
                        end
                    end
                end)
                conn:Disconnect()
            end
        end)
    end
end)

-- =============================================
-- CONSTRUIR ABAS
-- =============================================
function LimparConteudo()
    for _, v in pairs(ScrollingFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

function ConstruirAbaAimbot()
    LimparConteudo()
    
    CriarToggle("ToggleAim", "ATIVAR AIMBOT", Color3.fromRGB(0, 200, 80), function(v)
        AimEnabled = v
    end)
    
    CriarSlider("SliderFOV", "REGULAR FOV", 10, 360, FOV, function(v)
        FOV = v
    end)
    
    CriarToggle("ToggleWallAim", "WALL CHECK (AIM)", Color3.fromRGB(200, 100, 0), function(v)
        WallCheck = v
    end)
    
    CriarToggle("ToggleTeamAim", "TEAM CHECK (AIM)", Color3.fromRGB(200, 100, 0), function(v)
        TeamCheck = v
    end)
    
    CriarToggle("ToggleKillAim", "KILL CHECK (AIM)", Color3.fromRGB(200, 0, 100), function(v)
        KillCheck = v
    end)
    
    -- Dropdown parte do corpo
    local framePart = Instance.new("Frame")
    framePart.Size = UDim2.new(0.95, 0, 0, 42)
    framePart.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    framePart.BackgroundTransparency = 0.3
    framePart.BorderSizePixel = 0
    framePart.Parent = ScrollingFrame
    
    local UICornerFP = Instance.new("UICorner")
    UICornerFP.CornerRadius = UDim.new(0, 8)
    UICornerFP.Parent = framePart
    
    local labelPart = Instance.new("TextLabel")
    labelPart.Size = UDim2.new(0.5, -10, 1, 0)
    labelPart.Position = UDim2.new(0, 10, 0, 0)
    labelPart.BackgroundTransparency = 1
    labelPart.Text = "PARTE DO CORPO"
    labelPart.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelPart.TextSize = 14
    labelPart.Font = Enum.Font.Gotham
    labelPart.TextXAlignment = Enum.TextXAlignment.Left
    labelPart.Parent = framePart
    
    local btnPart = Instance.new("TextButton")
    btnPart.Size = UDim2.new(0.4, 0, 0, 28)
    btnPart.Position = UDim2.new(0.55, 0, 0.5, -14)
    btnPart.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btnPart.Text = "CABEÇA"
    btnPart.TextColor3 = Color3.fromRGB(0, 170, 255)
    btnPart.TextSize = 13
    btnPart.Font = Enum.Font.GothamBold
    btnPart.BorderSizePixel = 0
    btnPart.Parent = framePart
    
    local UICornerBP = Instance.new("UICorner")
    UICornerBP.CornerRadius = UDim.new(0, 8)
    UICornerBP.Parent = btnPart
    
    local partes = {"CABEÇA", "PEITO"}
    local idxPart = 1
    btnPart.MouseButton1Click:Connect(function()
        idxPart = idxPart % #partes + 1
        btnPart.Text = partes[idxPart]
        AimPart = partes[idxPart] == "CABEÇA" and "Head" or "UpperTorso"
    end)
    
    CriarSlider("SliderDistAim", "DIST. MÁXIMA", 50, 500, 300, function(v)
        DistanciaMaxima = v
    end)
end

function ConstruirAbaESP()
    LimparConteudo()
    
    CriarToggle("ToggleESP", "ATIVAR ESP", Color3.fromRGB(0, 200, 80), function(v)
        ESPEnabled = v
        if not v then
            for _, obj in pairs(CoreGui:GetChildren()) do
                if obj.Name == "ESPDrawing" then obj:Destroy() end
            end
        end
    end)
    
    CriarToggle("ToggleAura", "ESP AURA (CAIXA)", Color3.fromRGB(0, 170, 255), function(v)
        ESP_Aura = v
    end)
    
    CriarToggle("ToggleNome", "ESP NOME", Color3.fromRGB(0, 170, 255), function(v)
        ESP_Nome = v
    end)
    
    CriarToggle("ToggleDist", "ESP DISTÂNCIA", Color3.fromRGB(0, 170, 255), function(v)
        ESP_Distancia = v
    end)
    
    CriarToggle("ToggleSkeleton", "ESP ESQUELETO", Color3.fromRGB(255, 170, 0), function(v)
        ESP_Esqueleto = v
    end)
    
    CriarSlider("SliderDistCor", "DIST. TROCA COR (m)", 20, 200, DistanciaTrocaCor, function(v)
        DistanciaTrocaCor = v
    end)
end

function ConstruirAbaChecks()
    LimparConteudo()
    
    -- Título da seção
    local tituloChecks = Instance.new("TextLabel")
    tituloChecks.Size = UDim2.new(0.95, 0, 0, 30)
    tituloChecks.BackgroundTransparency = 1
    tituloChecks.Text = "⚙️ CONFIGURAÇÕES DE CHECKS"
    tituloChecks.TextColor3 = Color3.fromRGB(0, 170, 255)
    tituloChecks.TextSize = 14
    tituloChecks.Font = Enum.Font.GothamBold
    tituloChecks.Parent = ScrollingFrame
    
    CriarToggle("ToggleWallESP", "WALL CHECK", Color3.fromRGB(200, 100, 0), function(v)
        WallCheck = v
        print("🧱 Wall Check: " .. (v and "ON" or "OFF"))
    end)
    
    -- Descrição do Wall Check
    local descWall = Instance.new("TextLabel")
    descWall.Size = UDim2.new(0.85, 0, 0, 20)
    descWall.BackgroundTransparency = 1
    descWall.Text = "  → Só mira/ESP se NÃO tiver parede no meio"
    descWall.TextColor3 = Color3.fromRGB(150, 150, 150)
    descWall.TextSize = 11
    descWall.Font = Enum.Font.Gotham
    descWall.TextXAlignment = Enum.TextXAlignment.Left
    descWall.Parent = ScrollingFrame
    
    CriarToggle("ToggleTeamESP", "TEAM CHECK", Color3.fromRGB(200, 100, 0), function(v)
        TeamCheck = v
        print("👥 Team Check: " .. (v and "ON" or "OFF"))
    end)
    
    local descTeam = Instance.new("TextLabel")
    descTeam.Size = UDim2.new(0.85, 0, 0, 20)
    descTeam.BackgroundTransparency = 1
    descTeam.Text = "  → Ignora jogadores do mesmo time"
    descTeam.TextColor3 = Color3.fromRGB(150, 150, 150)
    descTeam.TextSize = 11
    descTeam.Font = Enum.Font.Gotham
    descTeam.TextXAlignment = Enum.TextXAlignment.Left
    descTeam.Parent = ScrollingFrame
    
    CriarToggle("ToggleKillESP", "KILL CHECK", Color3.fromRGB(200, 0, 100), function(v)
        KillCheck = v
        if not v then
            JogadoresMatados = {}
        end
        print("💀 Kill Check: " .. (v and "ON" or "OFF"))
    end)
    
    local descKill = Instance.new("TextLabel")
    descKill.Size = UDim2.new(0.85, 0, 0, 20)
    descKill.BackgroundTransparency = 1
    descKill.Text = "  → Ignora jogadores que já matou"
    descKill.TextColor3 = Color3.fromRGB(150, 150, 150)
    descKill.TextSize = 11
    descKill.Font = Enum.Font.Gotham
    descKill.TextXAlignment = Enum.TextXAlignment.Left
    descKill.Parent = ScrollingFrame
    
    -- Separador
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0.9, 0, 0, 1)
    sep.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sep.BorderSizePixel = 0
    sep.Parent = ScrollingFrame
    
    -- Botão para resetar kill list
    local botaoReset = Instance.new("TextButton")
    botaoReset.Size = UDim2.new(0.8, 0, 0, 35)
    botaoReset.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    botaoReset.Text = "🔄 RESETAR KILL LIST"
    botaoReset.TextColor3 = Color3.fromRGB(255, 255, 255)
    botaoReset.TextSize = 13
    botaoReset.Font = Enum.Font.GothamBold
    botaoReset.BorderSizePixel = 0
    botaoReset.Parent = ScrollingFrame
    
    local UICornerRS = Instance.new("UICorner")
    UICornerRS.CornerRadius = UDim.new(0, 8)
    UICornerRS.Parent = botaoReset
    
    botaoReset.MouseButton1Click:Connect(function()
        JogadoresMatados = {}
        print("🔄 Kill List resetada!")
    end)
    
    -- Kill counter
    local killCounter = Instance.new("TextLabel")
    killCounter.Size = UDim2.new(0.9, 0, 0, 25)
    killCounter.BackgroundTransparency = 1
    killCounter.Text = "Jogadores matados: 0"
    killCounter.TextColor3 = Color3.fromRGB(200, 200, 200)
    killCounter.TextSize = 13
    killCounter.Font = Enum.Font.Gotham
    killCounter.Parent = ScrollingFrame
    
    -- Atualizar contador
    task.spawn(function()
        while task.wait(1) do
            local count = 0
            for _ in pairs(JogadoresMatados) do
                count = count + 1
            end
            killCounter.Text = "Jogadores matados: " .. count
        end
    end)
end

-- =============================================
-- NAVEGAÇÃO ENTRE ABAS
-- =============================================
local function SelecionarAba(aba)
    AbaAimbot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    AbaAimbot.TextColor3 = Color3.fromRGB(180, 180, 180)
    AbaESP.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    AbaESP.TextColor3 = Color3.fromRGB(180, 180, 180)
    AbaChecks.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    AbaChecks.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    if aba == "AIMBOT" then
        AbaAtual = "AIMBOT"
        AbaAimbot.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        AbaAimbot.BackgroundTransparency = 0.6
        AbaAimbot.TextColor3 = Color3.fromRGB(255, 255, 255)
        ConstruirAbaAimbot()
    elseif aba == "ESP" then
        AbaAtual = "ESP"
        AbaESP.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        AbaESP.BackgroundTransparency = 0.6
        AbaESP.TextColor3 = Color3.fromRGB(255, 255, 255)
        ConstruirAbaESP()
    elseif aba == "CHECKS" then
        AbaAtual = "CHECKS"
        AbaChecks.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        AbaChecks.BackgroundTransparency = 0.6
        AbaChecks.TextColor3 = Color3.fromRGB(255, 255, 255)
        ConstruirAbaChecks()
    end
end

AbaAimbot.MouseButton1Click:Connect(function() SelecionarAba("AIMBOT") end)
AbaESP.MouseButton1Click:Connect(function() SelecionarAba("ESP") end)
AbaChecks.MouseButton1Click:Connect(function() SelecionarAba("CHECKS") end)

-- Iniciar com Aimbot
SelecionarAba("AIMBOT")

-- =============================================
-- ABRIR/FECHAR PAINEL
-- =============================================
BotaoCircular.MouseButton1Click:Connect(function()
    PanelAberto = not PanelAberto
    
    if PanelAberto then
        Painel.Visible = true
        Painel.BackgroundTransparency = 0.08
        local tween = TweenService:Create(Painel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.08,
            Position = UDim2.new(0.5, -170, 0.15, 0)
        })
        tween:Play()
    else
        local tween = TweenService:Create(Painel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        tween:Play()
        task.wait(0.2)
        Painel.Visible = false
        Painel.BackgroundTransparency = 0.08
    end
end)

-- =============================================
-- SISTEMA DE ARRASTO
-- =============================================
local dragging = false
local dragStart, startPos

BotaoCircular.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = BotaoCircular.Position
    end
end)

BotaoCircular.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            BotaoCircular.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- =============================================
-- WORLD TO SCREEN
-- =============================================
local function WorldToScreen(position)
    local vector, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(vector.X, vector.Y), onScreen
end

local function GetDistanceFromChar(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (char.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
end

-- Conexões do esqueleto
local BoneConnections = {
    {"Head", "Neck"},
    {"Neck", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- =============================================
-- FUNÇÃO PRINCIPAL DO ESP
-- =============================================
local function DrawESP()
    -- Limpar desenhos antigos
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name == "ESPDrawing" then obj:Destroy() end
    end
    
    if not ESPEnabled then return end
    
    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESPDrawing"
    ESPFolder.Parent = CoreGui
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        -- TEAM CHECK: Pular se for do mesmo time
        if TeamCheck and IsSameTeam(player) then continue end
        
        -- KILL CHECK: Pular se já matou
        if KillCheck and IsAlreadyKilled(player) then continue end
        
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local dist = GetDistanceFromChar(char)
        if dist > DistanciaMaxima then continue end
        
        -- WALL CHECK: Pular se tiver parede no meio
        if WallCheck and HasWallBetween(Camera, root) then continue end
        
        -- Determinar cor baseada na distância
        local ratio = math.clamp(dist / DistanciaTrocaCor, 0, 1)
        local espColor = Color3.new(
            CorPerto.R + (CorLonge.R - CorPerto.R) * ratio,
            CorPerto.G + (CorLonge.G - CorPerto.G) * ratio,
            CorPerto.B + (CorLonge.B - CorPerto.B) * ratio
        )
        
        local screenPos, onScreen = WorldToScreen(root.Position)
        if not onScreen then continue end
        
        local scale = 300 / math.max(dist, 10)
        local boxW = math.clamp(40 * scale, 15, 120)
        local boxH = math.clamp(80 * scale, 30, 250)
        
        -- Flag visual para mostrar que o checks estão filtrando
        local temFiltro = WallCheck or TeamCheck or KillCheck
        local corBorda = (WallCheck and HasWallBetween(Camera, root)) and Color3.fromRGB(255, 0, 0) or espColor
        
        -- ESP AURA
        if ESP_Aura then
            local box = Instance.new("Frame")
            box.Name = "Box_" .. player.Name
            box.Size = UDim2.new(0, boxW * 2, 0, boxH)
            box.Position = UDim2.new(0, screenPos.X - boxW, 0, screenPos.Y - boxH/2)
            box.BackgroundTransparency = 0.85
            box.BackgroundColor3 = espColor
            box.BorderSizePixel = 1
            box.BorderColor3 = corBorda
            box.Parent = ESPFolder
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = box
        end
        
        -- ESP NOME
        if ESP_Nome then
            local nome = Instance.new("TextLabel")
            nome.Name = "Nome_" .. player.Name
            nome.Size = UDim2.new(0, 150, 0, 20)
            nome.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - boxH/2 - 22)
            nome.BackgroundTransparency = 0.4
            nome.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            nome.Text = player.DisplayName
            nome.TextColor3 = espColor
            nome.TextSize = 14
            nome.Font = Enum.Font.GothamBold
            nome.Parent = ESPFolder
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = nome
        end
        
        -- ESP DISTÂNCIA
        if ESP_Distancia then
            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "Dist_" .. player.Name
            distLabel.Size = UDim2.new(0, 80, 0, 18)
            distLabel.Position = UDim2.new(0, screenPos.X - 40, 0, screenPos.Y + boxH/2 + 4)
            distLabel.BackgroundTransparency = 0.4
            distLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            distLabel.Text = math.floor(dist) .. "m"
            distLabel.TextColor3 = espColor
            distLabel.TextSize = 12
            distLabel.Font = Enum.Font.Gotham
            distLabel.Parent = ESPFolder
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = distLabel
        end
        
        -- ESP ESQUELETO
        if ESP_Esqueleto then
            local Drawing = Instance.new("Frame")
            Drawing.Name = "Skel_" .. player.Name
            Drawing.Size = UDim2.new(1, 0, 1, 0)
            Drawing.BackgroundTransparency = 1
            Drawing.Parent = ESPFolder
            
            local bonePositions = {}
            for _, boneName in pairs({"Head", "Neck", "UpperTorso", "LowerTorso",
                "LeftUpperArm", "LeftLowerArm", "LeftHand",
                "RightUpperArm", "RightLowerArm", "RightHand",
                "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
                "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
                local part = char:FindFirstChild(boneName)
                if part then
                    local pos, vis = WorldToScreen(part.Position)
                    bonePositions[boneName] = pos
                end
            end
            
            for _, conn in pairs(BoneConnections) do
                local p1 = bonePositions[conn[1]]
                local p2 = bonePositions[conn[2]]
                if p1 and p2 then
                    local mid = (p1 + p2) / 2
                    local dx = p2.X - p1.X
                    local dy = p2.Y - p1.Y
                    local len = math.sqrt(dx*dx + dy*dy)
                    local angle = math.atan2(dy, dx)
                    
                    local line = Instance.new("Frame")
                    line.Size = UDim2.new(0, math.max(len, 2), 0, 2)
                    line.Position = UDim2.new(0, mid.X - len/2, 0, mid.Y - 1)
                    line.BackgroundColor3 = espColor
                    line.BackgroundTransparency = 0.2
                    line.BorderSizePixel = 0
                    line.Rotation = math.deg(angle)
                    line.Parent = Drawing
                end
            end
        end
    end
end

-- =============================================
-- AIMBOT LOOP
-- =============================================
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        local closestPlayer = nil
        local closestDist = FOV
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            
            -- TEAM CHECK
            if TeamCheck and IsSameTeam(player) then continue end
            
            -- KILL CHECK
            if KillCheck and IsAlreadyKilled(player) then continue end
            
            local char = player.Character
            local targetPart = char:FindFirstChild(AimPart) or char:FindFirstChild("Head")
            if not targetPart then continue end
            
            local dist = GetDistanceFromChar(char)
            if dist > DistanciaMaxima then continue end
            
            -- WALL CHECK
            if WallCheck and HasWallBetween(Camera, targetPart) then continue end
            
            local screenPos, onScreen = WorldToScreen(targetPart.Position)
            if not onScreen then continue end
            
            local mousePos = UserInputService:GetMouseLocation()
            local delta = (screenPos - mousePos).Magnitude
            
            if delta < closestDist then
                closestDist = delta
                closestPlayer = player
            end
        end
        
        if closestPlayer and closestPlayer.Character then
            local char = closestPlayer.Character
            local targetPart = char:FindFirstChild(AimPart) or char:FindFirstChild("Head")
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
end)

-- =============================================
-- LOOP DO ESP
-- =============================================
task.spawn(function()
    while task.wait(0.1) do
        DrawESP()
    end
end)

-- =============================================
-- FIM
-- =============================================
print("✅ Painel Aimbot + ESP + Checks carregado!")
print("📱 Botão ⚡ para abrir/fechar")
print("🔧 Aba CHECKS: Wall Check · Team Check · Kill Check")
