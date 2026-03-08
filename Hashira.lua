--[[ 
    Hashiras Hub - Em beta
]]

repeat task.wait() until game:IsLoaded()

---------------------------------------------------
-- SERVICES
---------------------------------------------------

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
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
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local Combat = Window:CreateTab("Combat")
local Movement = Window:CreateTab("Movement")
local Visuals = Window:CreateTab("Visuals")
local TeleportTab = Window:CreateTab("Teleport")
local ServerTab = Window:CreateTab("Server")

---------------------------------------------------
-- COMBAT
---------------------------------------------------

Combat:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v)
        Vars.Hitbox = v
        if v then
            loadstring(game:HttpGet("https://github.com/RectangularObject/UniversalHBE/releases/latest/download/main.lua",true))()
        end
    end
})

Combat:CreateToggle({
    Name = "Universal Aimbot",
    CurrentValue = false,
    Callback = function(v)
        if v then
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

Movement:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(Value)
      Vars.Fly = Value
      if Value then
         loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
      end
   end
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
-- TELEPORT (Players / Cars / Saved)
---------------------------------------------------

-- PLAYER TELEPORT
local SelectedPlayer = nil
local PlayerList = {}
local function GetPlayerNames()
    PlayerList = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(PlayerList,p.Name)
        end
    end
    return PlayerList
end

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selecionar Jogador",
    Options = GetPlayerNames(),
    CurrentOption = nil,
    MultipleOptions = false,
    Callback = function(opt)
        SelectedPlayer = type(opt) == "table" and opt[1] or opt
    end
})

TeleportTab:CreateButton({
    Name = "Atualizar Lista",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerNames(),true)
    end
})

TeleportTab:CreateButton({
    Name = "Teleportar para Jogador",
    Callback = function()
        if SelectedPlayer then
            local target = Players:FindFirstChild(SelectedPlayer)
            local root = GetRoot()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,7,0)
            end
        end
    end
})

-- CAR TELEPORT
local CarList = {}
local CarObjects = {}
local SelectedCar = nil

local function GetCarDetails(seat)
    local model = seat:FindFirstAncestorOfClass("Model")
    local owner = "Desconhecido"
    local name = model and model.Name or "Carro"
    if model then
        local attr = model:GetAttribute("Owner") or model:GetAttribute("Dono")
        local val = model:FindFirstChild("Owner") or model:FindFirstChild("Dono")
        if attr then owner = tostring(attr)
        elseif val and val:IsA("StringValue") then owner = val.Value end
    end
    return name, owner
end

local function UpdateCarList()
    CarList = {}
    CarObjects = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") then
            local name, owner = GetCarDetails(v)
            local label = "🚗 "..name.." ["..owner.."]"
            table.insert(CarList,label)
            CarObjects[label] = v
        end
    end
end

UpdateCarList()

local CarDropdown = TeleportTab:CreateDropdown({
    Name = "Selecionar Carro",
    Options = CarList,
    CurrentOption = nil,
    Callback = function(opt)
        SelectedCar = opt
    end
})

TeleportTab:CreateButton({
    Name = "Atualizar Carros",
    Callback = function()
        UpdateCarList()
        CarDropdown:Refresh(CarList,true)
    end
})

TeleportTab:CreateButton({
    Name = "Teleportar para Carro",
    Callback = function()
        if SelectedCar then
            local seat = CarObjects[SelectedCar]
            local root = GetRoot()
            if seat and root then
                root.CFrame = seat.CFrame * CFrame.new(0,3,0)
            end
        end
    end
})

-- SAVED POSITION
TeleportTab:CreateButton({
    Name = "Save Position",
    Callback = function()
        local root = GetRoot()
        if root then Vars.SavedPosition = root.CFrame end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport Saved Position",
    Callback = function()
        local root = GetRoot()
        if root and Vars.SavedPosition then root.CFrame = Vars.SavedPosition end
    end
})

---------------------------------------------------
-- SERVER TAB (Avançado)
---------------------------------------------------

local ServerList = {}
local ServerIDs = {}
local SelectedServer = nil
local AutoHop = false

-- CONTADOR DE PLAYERS
ServerTab:CreateParagraph({
    Title = "Server Info",
    Content = "Players: "..#Players:GetPlayers().." / "..Players.MaxPlayers
})

-- REJOIN
ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LP)
    end
})

-- MOSTRAR PING
ServerTab:CreateButton({
    Name = "Mostrar Ping",
    Callback = function()
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Rayfield:Notify({
            Title = "Ping do Servidor",
            Content = ping.." ms",
            Duration = 5
        })
    end
})

-- SERVER HOP NORMAL
local function ServerHop()
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)
    for _,server in pairs(data.data) do
        if server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LP)
            break
        end
    end
end

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function() ServerHop() end
})

-- SERVER HOP QUASE VAZIO
local function LowServerHop()
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)
    for _,server in pairs(data.data) do
        if server.playing <= 3 and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LP)
            break
        end
    end
end

ServerTab:CreateButton({
    Name = "Server Hop (Quase vazio)",
    Callback = function() LowServerHop() end
})

-- AUTO SERVER HOP
ServerTab:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = false,
    Callback = function(v)
        AutoHop = v
        if v then
            task.spawn(function()
                while AutoHop do
                    task.wait(30)
                    ServerHop()
                end
            end)
        end
    end
})

-- LISTA DE SERVIDORES
local function UpdateServerList()
    ServerList = {}
    ServerIDs = {}
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)
    for _,server in pairs(data.data) do
        local label = "Players "..server.playing.."/"..server.maxPlayers
        table.insert(ServerList,label)
        ServerIDs[label] = server.id
    end
end

UpdateServerList()

local ServerDropdown = ServerTab:CreateDropdown({
    Name = "Lista de Servidores",
    Options = ServerList,
    CurrentOption = nil,
    MultipleOptions = false,
    Callback = function(opt)
        SelectedServer = opt
    end
})

ServerTab:CreateButton({
    Name = "Atualizar Lista de Servidores",
    Callback = function()
        UpdateServerList()
        ServerDropdown:Refresh(ServerList,true)
    end
})

ServerTab:CreateButton({
    Name = "Entrar no Servidor Selecionado",
    Callback = function()
        if SelectedServer then
            local id = ServerIDs[SelectedServer]
            if id then
                TeleportService:TeleportToPlaceInstance(game.PlaceId,id,LP)
            end
        end
    end
})

-- COPY JOB ID
ServerTab:CreateButton({
    Name = "Copiar JobId",
    Callback = function() setclipboard(game.JobId) end
})

-- COPY PLACE ID
ServerTab:CreateButton({
    Name = "Copiar PlaceId",
    Callback = function() setclipboard(game.PlaceId) end
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
                -- Player ESP
                if Vars.ESPEnabled and not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255,0,0)
                    h.Parent = p.Character
                elseif not Vars.ESPEnabled then
                    local h = p.Character:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
                -- Hitbox
                if Vars.Hitbox and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(8,8,8)
                    hrp.Transparency = 0.5
                    hrp.Massless = true
                end
            end
        end
        -- Car ESP
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
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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
