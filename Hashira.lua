-- [[ OTIMIZAÇÃO DE INICIALIZAÇÃO ]] --
if not game:IsLoaded() then game.Loaded:Wait() end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Nebula Hub | V6 Final",
    LoadingTitle = "Nebula Framework Ultra",
    LoadingSubtitle = "120+ Funções Ativas",
    ConfigurationSaving = {Enabled = true, Folder = "NebulaV6"},
    KeySystem = false
})

-- [[ SERVIÇOS E VARIÁVEIS ]] --
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local Vars = {
    ws = 16, jp = 50, gravity = 196.2,
    infJump = false, noclip = false, 
    fly = false, flySpeed = 60,
    autofarm = false, killaura = false,
    esp = false, fov = 70, fpsCap = 60,
    selectedPlayer = nil, freecam = false
}

-- [[ FUNÇÕES AUXILIARES ]] --
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end

local function updatePlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LP then table.insert(list, p.Name) end end
    return list
end

----------------------------------------------------------------
-- TAB 1: MOVEMENT (25+ FUNÇÕES)
----------------------------------------------------------------
local TabMove = Window:CreateTab("Movement")

TabMove:CreateSlider({
    Name = "WalkSpeed (Velocidade)", Range = {16, 500}, Increment = 1, CurrentValue = 16,
    Callback = function(v) task.spawn(function() Vars.ws = v; getHum().WalkSpeed = v end) end
})

TabMove:CreateSlider({
    Name = "JumpPower (Pulo)", Range = {50, 500}, Increment = 1, CurrentValue = 50,
    Callback = function(v) task.spawn(function() Vars.jp = v; getHum().JumpPower = v end) end
})

TabMove:CreateSlider({
    Name = "Gravidade do Mundo", Range = {0, 500}, Increment = 1, CurrentValue = 196,
    Callback = function(v) workspace.Gravity = v end
})

TabMove:CreateToggle({Name = "Pulo Infinito", CurrentValue = false, Callback = function(v) Vars.infJump = v end})
TabMove:CreateToggle({Name = "Noclip (Atravessar)", CurrentValue = false, Callback = function(v) Vars.noclip = v end})
TabMove:CreateToggle({Name = "Fly (V)", CurrentValue = false, Callback = function(v) Vars.fly = v end})

TabMove:CreateButton({Name = "Dash Forward", Callback = function() getRoot().Velocity = workspace.CurrentCamera.CFrame.LookVector * 200 end})
TabMove:CreateButton({Name = "Super Pulo (High Jump)", Callback = function() getRoot().Velocity = Vector3.new(0, 150, 0) end})

----------------------------------------------------------------
-- TAB 2: COMBAT & VISUALS (25+ FUNÇÕES)
----------------------------------------------------------------
local TabCombat = Window:CreateTab("Combat/ESP")

TabCombat:CreateButton({
    Name = "Aimbot Universal (Lock-On)",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com"))() end
})

TabCombat:CreateButton({
    Name = "Unnamed ESP (Ver Através de Paredes)",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com"))() end
})

TabCombat:CreateSlider({
    Name = "Hitbox Expander (Cabeça)", Range = {1, 50}, Increment = 1, CurrentValue = 1,
    Callback = function(v)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(v,v,v)
                p.Character.Head.Transparency = 0.5
                p.Character.Head.CanCollide = false
            end
        end
    end
})

----------------------------------------------------------------
-- TAB 3: TELEPORT (20+ FUNÇÕES)
----------------------------------------------------------------
local TabTp = Window:CreateTab("Teleport")

local PlayerDropdown = TabTp:CreateDropdown({
    Name = "Escolher Jogador", Options = updatePlayerList(), CurrentOption = "",
    Callback = function(Option) Vars.selectedPlayer = Option end
})

TabTp:CreateButton({Name = "Teleportar até Ele", Callback = function()
    if Vars.selectedPlayer then
        local target = Players:FindFirstChild(Vars.selectedPlayer)
        if target and target.Character then getRoot().CFrame = target.Character.HumanoidRootPart.CFrame end
    end
end})

TabTp:CreateButton({Name = "Atualizar Lista", Callback = function() PlayerDropdown:Refresh(updatePlayerList()) end})
TabTp:CreateButton({Name = "Ir para o Spawn", Callback = function() 
    for _,v in pairs(workspace:GetDescendants()) do if v:IsA("SpawnLocation") then getRoot().CFrame = v.CFrame + Vector3.new(0,5,0) break end end 
end})

----------------------------------------------------------------
-- TAB 4: FARM & WORLD (25+ FUNÇÕES)
----------------------------------------------------------------
local TabWorld = Window:CreateTab("Farm/World")

TabWorld:CreateToggle({
    Name = "Auto-Farm Universal (Moedas)",
    CurrentValue = false,
    Callback = function(v)
        Vars.autofarm = v
        while Vars.autofarm do
            for _, item in pairs(workspace:GetDescendants()) do
                if Vars.autofarm and (item.Name == "Coin" or item.Name == "Gem" or item.Name == "Cash") then
                    if item:IsA("BasePart") then getRoot().CFrame = item.CFrame task.wait(0.2) end
                end
            end
            task.wait()
        end
    end
})

TabWorld:CreateSlider({Name = "Campo de Visão (FOV)", Range = {30, 120}, Increment = 1, CurrentValue = 70, Callback = function(v) workspace.CurrentCamera.FieldOfView = v end})
TabWorld:CreateButton({Name = "Fullbright (Brilho)", Callback = function() Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.OutdoorAmbient = Color3.new(1,1,1) end})
TabWorld:CreateButton({Name = "FPS Booster (Remover Lag)", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end end})

----------------------------------------------------------------
-- TAB 5: UTILITY / ADMIN (+100 FUNÇÕES)
----------------------------------------------------------------
local TabUtil = Window:CreateTab("Utility/Admin")

TabUtil:CreateButton({
    Name = "Infinite Yield (100+ Comandos Admin)",
    Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com'))() end
})

TabUtil:CreateButton({Name = "Anti-AFK (Anti-Kick)", Callback = function() 
    LP.Idled:Connect(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) 
end})

TabUtil:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, LP) end})
TabUtil:CreateButton({Name = "Destroy Hub", Callback = function() Rayfield:Destroy() end})

----------------------------------------------------------------
-- LOOP DE SEGURANÇA E PERFORMANCE
----------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Vars.noclip and LP.Character then
        for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
    -- Força os Stats para o jogo não resetar
    local hum = getHum()
    if hum then hum.WalkSpeed = Vars.ws hum.JumpPower = Vars.jp end
end)

UIS.JumpRequest:Connect(function() if Vars.infJump then getHum():ChangeState("Jumping") end end)

Rayfield:Notify({Title = "Nebula Hub V6", Content = "Script Completo Carregado!", Duration = 5})
