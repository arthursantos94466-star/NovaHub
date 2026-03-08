--[[
    Hashiras Hub - Beta
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------
-- VARIÁVEIS DE ESTADO
---------------------------------------------------

local Vars = {
    KillAura = false,
    Hitbox = false,
    InfiniteJump = false,
    Noclip = false,
    Float = false,
    ESPEnabled = false,
    RadarEnabled = false,
    SavedPosition = nil,
    WalkSpeed = 16,
    JumpPower = 50
}

---------------------------------------------------
-- FUNÇÕES AUXILIARES
---------------------------------------------------

local function GetCharacter() return LP.Character end

local function GetRoot() 
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

---------------------------------------------------
-- UI SETUP
---------------------------------------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Nebula Hub Reworked",
    LoadingTitle = "Nebula Hub",
    LoadingSubtitle = "Stable Edition",
    ConfigurationSaving = {Enabled = false}
})

-- Abas
local Combat = Window:CreateTab("Combat")
local Movement = Window:CreateTab("Movement")
local Visuals = Window:CreateTab("Visuals")
local PlayerTab = Window:CreateTab("Player")
local ServerTab = Window:CreateTab("Server")

---------------------------------------------------
-- COMBAT
---------------------------------------------------

Combat:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(v) Vars.KillAura = v end
})

Combat:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) Vars.Hitbox = v end
})

Combat:CreateButton({
    Name = "Aim Closest Player",
    Callback = function()
        local root = GetRoot()
        if not root then return end
        
        local closest, dist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; closest = p end
            end
        end
        if closest then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
        end
    end
})

---------------------------------------------------
-- MOVEMENT
---------------------------------------------------

Movement:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) Vars.WalkSpeed = v end
})

Movement:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) Vars.JumpPower = v end
})

Movement:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) Vars.InfiniteJump = v end
})

Movement:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v) Vars.Noclip = v end
})

Movement:CreateButton({
    Name = "Anti Void",
    Callback = function()
        local root = GetRoot()
        if root then root.CFrame = CFrame.new(0, 100, 0) end
    end
})

---------------------------------------------------
-- VISUALS & RADAR
---------------------------------------------------

Visuals:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.Brightness = 1
        end
    end
})

Visuals:CreateToggle({
    Name = "Player ESP (Highlights)",
    CurrentValue = false,
    Callback = function(v)
        Vars.ESPEnabled = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Highlight") then
                    p.Character.Highlight:Destroy()
                end
            end
        end
    end
})

-- Radar 2D Simplificado
local RadarGui = Instance.new("ScreenGui", game.CoreGui)
local RadarFrame = Instance.new("Frame", RadarGui)
RadarFrame.Size = UDim2.new(0, 150, 0, 150)
RadarFrame.Position = UDim2.new(0, 50, 0.5, -75)
RadarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RadarFrame.Visible = false

Visuals:CreateToggle({
    Name = "Radar 2D",
    CurrentValue = false,
    Callback = function(v)
        Vars.RadarEnabled = v
        RadarFrame.Visible = v
    end
})

---------------------------------------------------
-- PLAYER & SERVER
---------------------------------------------------

PlayerTab:CreateButton({
    Name = "Save Position",
    Callback = function() Vars.SavedPosition = GetRoot() and GetRoot().Position end
})

PlayerTab:CreateButton({
    Name = "Teleport Saved",
    Callback = function()
        if Vars.SavedPosition then GetRoot().CFrame = CFrame.new(Vars.SavedPosition) end
    end
})

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function() TeleportService:Teleport(game.PlaceId, LP) end
})

---------------------------------------------------
-- LOOPS (SISTEMAS)
---------------------------------------------------

-- Loop de Atributos e Noclip (High Frequency)
RunService.Stepped:Connect(function()
    local char = GetCharacter()
    local hum = GetHumanoid()
    local root = GetRoot()
    
    if hum then
        hum.WalkSpeed = Vars.WalkSpeed
        hum.JumpPower = Vars.JumpPower
    end

    if char and Vars.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Loop de Combate e ESP (Medium Frequency)
task.spawn(function()
    while task.wait(0.1) do
        local root = GetRoot()
        if not root then continue end

        -- Kill Aura & Hitbox
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                local e_root = p.Character:FindFirstChild("HumanoidRootPart")
                if e_root then
                    -- Hitbox
                    if Vars.Hitbox then
                        e_root.Size = Vector3.new(10, 10, 10)
                        e_root.Transparency = 0.7
                    else
                        e_root.Size = Vector3.new(2, 2, 1)
                        e_root.Transparency = 0
                    end

                    -- Kill Aura
                    if Vars.KillAura and (root.Position - e_root.Position).Magnitude < 15 then
                        -- Nota: Em muitos jogos p.Character.Humanoid.Health = 0 é client-side.
                        -- Geralmente usa-se um RemoteEvent de ataque aqui.
                        p.Character.Humanoid.Health = 0 
                    end
                end

                -- ESP Highlight
                if Vars.ESPEnabled and not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end)

-- Input para Infinite Jump
UIS.JumpRequest:Connect(function()
    local hum = GetHumanoid()
    if Vars.InfiniteJump and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Rayfield:Notify({Title = "Nebula Hub", Content = "Script Carregado com Sucesso!", Duration = 5})
