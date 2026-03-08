--[[ 
    Hashiras Hub - Fixed & Improved
]]

---------------------------------------------------
-- SERVICES
---------------------------------------------------

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------
-- VARS
---------------------------------------------------

local Vars = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    Hitbox = false,
    ESPEnabled = false,
    CarESP = false,
    SavedPosition = nil
}

---------------------------------------------------
-- CHARACTER FUNCTIONS
---------------------------------------------------

local function GetCharacter()
    return LP.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

---------------------------------------------------
-- UI
---------------------------------------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Hashiras Hub",
    LoadingTitle = "Hashiras Hub",
    LoadingSubtitle = "Hub em atualização",
    ConfigurationSaving = {Enabled = false}
})

local Combat = Window:CreateTab("Combat")
local Movement = Window:CreateTab("Movement")
local Visuals = Window:CreateTab("Visuals")
local TeleportTab = Window:CreateTab("Teleport")
local ServerTab = Window:CreateTab("Server")

---------------------------------------------------
-- COMBAT
---------------------------------------------------

-- Toggle para Hitbox
Combat:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(v)
        Vars.Hitbox = v
        if v then
            -- Script focado em Hitbox (Exemplo Universal)
            loadstring(game:HttpGet("https://github.com/RectangularObject/UniversalHBE/releases/latest/download/main.lua", true))()
        end
    end
})

-- Toggle para Aimbot
Combat:CreateToggle({
    Name = "Universal Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(v)
        Vars.Aimbot = v
        if v then
            -- O script que você enviou (Aimbot Universal)
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-universal-111551"))()
        end
    end
})


---------------------------------------------------
-- MOVEMENT
---------------------------------------------------

Movement:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        Vars.WalkSpeed = v
    end
})

Movement:CreateSlider({
    Name = "JumpPower",
    Range = {50,200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        Vars.JumpPower = v
    end
})

Movement:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        Vars.InfiniteJump = v
    end
})

Movement:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        Vars.Noclip = v
    end
})

---------------------------------------------------
-- FLY
---------------------------------------------------

local FlyToggle = Movement:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle", -- Identificador único
   Callback = function(Value)
      Vars.Fly = Value
      if Value then
         -- Carrega o script de Fly quando ativado
         loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
      else
         -- Nota: A maioria dos scripts de Fly externos exige o reset do personagem 
         -- ou um comando específico para desligar totalmente.
         print("Fly Desativado")
      end
   end,
})

---------------------------------------------------
-- VISUALS
---------------------------------------------------

Visuals:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Callback = function(v)

        if v then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(127,127,127)
        end

    end
})

Visuals:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(v)
        Vars.ESPEnabled = v
    end
})

Visuals:CreateToggle({
    Name = "Car ESP",
    CurrentValue = false,
    Callback = function(v)
        Vars.CarESP = v
    end
})

---------------------------------------------------
-- TELEPORT PLAYERS
---------------------------------------------------

local SelectedPlayer = nil
local PlayerList = {}

-- Função para atualizar a tabela de jogadores
local function GetPlayerNames()
    PlayerList = {}
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= game:GetService("Players").LocalPlayer then
            table.insert(PlayerList, p.Name)
        end
    end
    return PlayerList
end

-- Criar o Dropdown de Jogadores
local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selecionar Jogador",
    Options = GetPlayerNames(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "TargetPlayer",
    Callback = function(Option)
        -- No Rayfield V2/V3 a Option vem como uma tabela ou string dependendo da versão
        SelectedPlayer = type(Option) == "table" and Option[1] or Option
    end,
})

-- Botão para Atualizar a Lista
TeleportTab:CreateButton({
    Name = "Atualizar Lista de Jogadores",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerNames(), true) -- Atualiza e limpa a seleção atual
    end,
})

-- Botão para Teleportar
TeleportTab:CreateButton({
    Name = "Teleportar para o Jogador",
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "" then
            local target = game:GetService("Players"):FindFirstChild(SelectedPlayer)
            local lp = game:GetService("Players").LocalPlayer
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    -- Teleporta 7 studs acima (como no seu script original Xsat)
                    lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                end
            else
                Rayfield:Notify({
                    Title = "Erro",
                    Content = "Jogador não encontrado ou sem personagem.",
                    Duration = 3,
                    Image = 4483362458,
                })
            end
        else
            Rayfield:Notify({
                Title = "Aviso",
                Content = "Por favor, selecione um jogador primeiro!",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

---------------------------------------------------
-- TELEPORT CARS
---------------------------------------------------

local CarList = {}
local CarObjects = {}
local SelectedCar = nil

-- Função para identificar o dono do carro
local function GetCarOwner(seat)
    local model = seat:FindFirstAncestorOfClass("Model")
    if model then
        -- Tenta encontrar o dono por Atributo, Valor ou Nome do Modelo
        local owner = model:GetAttribute("Owner") or model:FindFirstChild("Owner")
        if owner then return tostring(owner) end
        
        -- Fallback: verifica se o nome do modelo contém o nome de algum jogador
        for _, player in pairs(game.Players:GetPlayers()) do
            if model.Name:find(player.Name) then return player.Name end
        end
    end
    return "Desconhecido"
end

local function UpdateCarList()
    CarList = {}
    CarObjects = {}

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") then
            local ownerName = GetCarOwner(v)
            local displayName = "🚗 " .. v.Name .. " [" .. ownerName .. "]"
            
            table.insert(CarList, displayName)
            CarObjects[displayName] = v
        end
    end
end

-- Inicializa a lista
UpdateCarList()

-- UI Elements
local CarDropdown = TeleportTab:CreateDropdown({
    Name = "Selecionar Veículo",
    Options = CarList,
    CurrentOption = nil,
    Callback = function(opt)
        SelectedCar = opt
    end
})

TeleportTab:CreateButton({
    Name = "🔄 Atualizar Lista de Carros",
    Callback = function()
        UpdateCarList()
        CarDropdown:Refresh(CarList, true) -- True para resetar a seleção se necessário
    end
})

TeleportTab:CreateButton({
    Name = "📍 Teleportar para o Carro",
    Callback = function()
        if not SelectedCar then return end
        
        local seat = CarObjects[SelectedCar]
        if seat and seat.Parent then
            local root = GetRoot()
            if root then
                -- Teleporta um pouco acima para não bugar no teto
                root.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
            end
        else
            print("Carro não encontrado ou foi deletado.")
        end
    end
})

---------------------------------------------------
-- SAVE POSITION
---------------------------------------------------

TeleportTab:CreateButton({
    Name = "Save Position",
    Callback = function()

        local root = GetRoot()

        if root then
            Vars.SavedPosition = root.CFrame
        end

    end
})

TeleportTab:CreateButton({
    Name = "Teleport Saved Position",
    Callback = function()

        local root = GetRoot()

        if root and Vars.SavedPosition then
            root.CFrame = Vars.SavedPosition
        end

    end
})

---------------------------------------------------
-- SERVER
---------------------------------------------------

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId,LP)
    end
})

---------------------------------------------------
-- MAIN LOOP
---------------------------------------------------

RunService.Heartbeat:Connect(function()

    local char = GetCharacter()
    local hum = GetHumanoid()

    if hum then

        hum.WalkSpeed = Vars.WalkSpeed
        hum.JumpPower = Vars.JumpPower
        hum.UseJumpPower = true

    end

    if char then

        for _,v in pairs(char:GetDescendants()) do

            if v:IsA("BasePart") then
                v.CanCollide = not Vars.Noclip
            end

        end

    end

end)

---------------------------------------------------
-- ESP LOOP
---------------------------------------------------

task.spawn(function()

    while task.wait(0.3) do

        for _,p in pairs(Players:GetPlayers()) do

            if p ~= LP and p.Character then

                if Vars.ESPEnabled then

                    if not p.Character:FindFirstChild("Highlight") then

                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(255,0,0)
                        h.Parent = p.Character

                    end

                else

                    local h = p.Character:FindFirstChild("Highlight")

                    if h then
                        h:Destroy()
                    end

                end

                if Vars.Hitbox and p.Character:FindFirstChild("HumanoidRootPart") then

                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(8,8,8)
                    hrp.Transparency = 0.5
                    hrp.Massless = true

                end

            end

        end

        if Vars.CarESP then

            for _,v in pairs(workspace:GetDescendants()) do

                if v:IsA("VehicleSeat") and not v:FindFirstChild("CarESP") then

                    local h = Instance.new("Highlight")
                    h.Name = "CarESP"
                    h.FillColor = Color3.fromRGB(0,255,255)
                    h.Parent = v

                end

            end

        end

    end

end)

---------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------

UIS.JumpRequest:Connect(function()

    if Vars.InfiniteJump then

        local hum = GetHumanoid()

        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

    end

end)

---------------------------------------------------
-- NOTIFY
---------------------------------------------------

Rayfield:Notify({
    Title = "Hashiras Hub",
    Content = "Script Loaded Successfully!",
    Duration = 5
})
