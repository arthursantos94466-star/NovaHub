local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local IfuudEvent = Remotes:WaitForChild("IfuudEvent")

-- GUI - APENAS UM BOTÃO
local Gui = Instance.new("ScreenGui")
Gui.Name = "IfuudFarm"
Gui.ResetOnSpawn = false
Gui.Parent = LP:WaitForChild("PlayerGui")

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 200, 0, 50)
Btn.Position = UDim2.new(0.5, -100, 0.85, -25)
Btn.BackgroundColor3 = Color3.fromRGB(232, 29, 43)
Btn.Text = "🍔 AUTO FARM"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 16
Btn.BorderSizePixel = 0
Btn.Draggable = true
Btn.Active = true
Btn.Parent = Gui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = Btn

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.5
Stroke.Parent = Btn

-- Variáveis
local Ativo = false
local EntregasCount = 0
local Heartbeat = nil
local EventConn = nil

-- Referências da interface (cache)
local function GetRefs()
    local CodeIfuud = LP.PlayerGui:FindFirstChild("CodeIfuud")
    if not CodeIfuud then return nil, nil, nil end
    
    local MainPage = CodeIfuud:FindFirstChild("MainPage")
    if not MainPage then return nil, nil, nil end
    
    local StartMission = MainPage:FindFirstChild("StartMission")
    if not StartMission then return nil, nil, nil end
    
    local EtapasUI = StartMission:FindFirstChild("EtapasUI")
    if not EtapasUI then return nil, nil, nil end
    
    local Meio = EtapasUI:FindFirstChild("Meio")
    if not Meio then return nil, nil, nil end
    
    local Codigo = Meio:FindFirstChild("Codigo")
    if not Codigo then return nil, nil, nil end
    
    local CodigoTxt = Codigo:FindFirstChild("CodigoTxt")
    local Confirmar = Meio:FindFirstChild("Confirmar")
    
    return CodigoTxt, Confirmar, CodeIfuud
end

function TP(pos)
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

function FirePrompt(nome)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == nome and obj.Enabled then
            fireproximityprompt(obj)
            return true
        end
    end
    return false
end

function GetPromptPos(nome)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == nome and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                return part.Position
            end
        end
    end
    return nil
end

-- ============================================================
// FUNÇÃO CORRETA PARA MOBILE - APENAS PREENCHE O TEXTO E CHAMA O EVENTO
-- ============================================================
function InserirCodigo(codigo)
    if not codigo or #codigo ~= 4 then
        print("[Farm] Código inválido: " .. tostring(codigo))
        return false
    end
    
    print("[Farm] Inserindo código: " .. codigo)
    
    local CodigoTxt, Confirmar = GetRefs()
    
    if not CodigoTxt then
        print("[Farm] Campo CodigoTxt não encontrado!")
        return false
    end
    
    -- PASSO 1: Preenche o texto diretamente (funciona no mobile)
    CodigoTxt.Text = codigo
    task.wait(0.1)
    
    -- Verifica se preencheu
    print("[Farm] Texto no campo: '" .. CodigoTxt.Text .. "'")
    
    -- PASSO 2: Chama o evento do servidor IGUALZINHO o jogo faz
    -- O jogo original: IfuudEvent:FireServer("VerificarCodigoFinal", v57)
    print("[Farm] Chamando VerificarCodigoFinal...")
    IfuudEvent:FireServer("VerificarCodigoFinal", codigo)
    
    print("[Farm] Código " .. codigo .. " enviado!")
    return true
end

-- ============================================================
// FUNÇÃO PARA PEGAR O CÓDIGO
-- ============================================================
function GetCodigo()
    -- Tenta pegar do DialogoFrame (que o jogo atualiza com o código)
    local _, _, CodeIfuud = GetRefs()
    if not CodeIfuud then return nil end
    
    local Dialogo = CodeIfuud:FindFirstChild("DialogoFrame")
    if Dialogo and Dialogo.Visible then
        local Assunto = Dialogo:FindFirstChild("Assunto")
        if Assunto then
            local cod = string.match(Assunto.Text, "(%d%d%d%d)")
            if cod then
                print("[Farm] Código do diálogo: " .. cod)
                return cod
            end
        end
    end
    
    -- Se já tiver algo no CodigoTxt, usa
    local CodigoTxt = GetRefs()
    if CodigoTxt and CodigoTxt.Text and #CodigoTxt.Text == 4 then
        print("[Farm] Código do campo: " .. CodigoTxt.Text)
        return CodigoTxt.Text
    end
    
    return nil
end

-- MONITORAMENTO
function Iniciar()
    EntregasCount = 0
    Ativo = true
    Btn.Text = "⏹ PARAR"
    Btn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    
    local fase = "parado"
    local codigoJaInserido = false
    local ultimoCodigo = ""
    
    -- CONECTA NO EVENTO DO JOGO PARA CAPTURAR O CÓDIGO NA HORA
    EventConn = IfuudEvent.OnClientEvent:Connect(function(evento, dado)
        if evento == "AbrirPainelCodigo" and dado then
            -- O jogo faz: v_u_26 = p_u_70 (dado é o código!)
            print("[Farm] 🎯 Código recebido do servidor: " .. dado)
            ultimoCodigo = dado
            codigoJaInserido = false
            
            -- Já insere na hora!
            if not codigoJaInserido then
                task.wait(0.3) -- Espera a interface atualizar
                InserirCodigo(dado)
                codigoJaInserido = true
                Btn.Text = "🔑 Código: " .. dado
            end
        elseif evento == "CodigoErrado" then
            print("[Farm] ❌ Código errado! Tentando novamente...")
            codigoJaInserido = false
        elseif evento == "EntregaConcluida" then
            print("[Farm] ✅ Entrega concluída pelo servidor!")
            EntregasCount = EntregasCount + 1
            Btn.Text = "🍔 (" .. EntregasCount .. ")"
        end
    end)
    
    Heartbeat = RunService.Heartbeat:Connect(function()
        if not Ativo then return end
        
        -- Só age a cada 0.5s pra não sobrecarregar
        task.wait(0.5)
        
        -- DETECTOU PROMPT DE PEGAR PEDIDO
        if fase == "parado" then
            local pos = GetPromptPos("PegarPedido")
            if pos then
                fase = "coleta"
                Btn.Text = "📦 Coletando..."
                codigoJaInserido = false
                
                TP(pos + Vector3.new(0, 3, 0))
                task.wait(0.3)
                
                FirePrompt("PegarPedido")
                task.wait(1)
                fase = "coletou"
                Btn.Text = "📥 Pegou"
                print("[Farm] Pedido coletado!")
            end
        end
        
        -- DETECTOU PROMPT DE ENTREGAR
        if fase == "coletou" or fase == "codigo_feito" then
            local pos = GetPromptPos("Entregar")
            if pos then
                fase = "entrega"
                Btn.Text = "📍 Entregando..."
                
                TP(pos + Vector3.new(0, 3, 0))
                task.wait(0.3)
                
                -- Tenta inserir código se não foi inserido ainda
                if not codigoJaInserido and ultimoCodigo ~= "" then
                    InserirCodigo(ultimoCodigo)
                    codigoJaInserido = true
                    task.wait(0.3)
                end
                
                FirePrompt("Entregar")
                print("[Farm] FirePrompt Entregar disparado!")
                task.wait(2)
                
                fase = "parado"
                Btn.Text = "🍔 (" .. EntregasCount .. ")"
            end
        end
    end)
end

function Parar()
    Ativo = false
    if Heartbeat then
        Heartbeat:Disconnect()
        Heartbeat = nil
    end
    if EventConn then
        EventConn:Disconnect()
        EventConn = nil
    end
    Btn.Text = "🍔 AUTO FARM"
    Btn.BackgroundColor3 = Color3.fromRGB(232, 29, 43)
    print("[Farm] Desativado. Total: " .. EntregasCount)
end

-- Clique no botão
Btn.MouseButton1Click:Connect(function()
    if Ativo then
        Parar()
    else
        Iniciar()
    end
end)

print("🍔 Ifuud Auto Farm carregado!")
print("📌 Funciona no MOBILE!")
print("📌 Clique no botão para iniciar.")
