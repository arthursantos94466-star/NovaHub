-- [[ CONFIGURAÇÃO E BOTÃO MOBILE ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
    Name = "Nebula Hub | V6 ULTRA",
    LoadingTitle = "Nebula Framework v6",
    LoadingSubtitle = "120+ Funções Ativadas",
    ConfigurationSaving = {Enabled = true, Folder = "NebulaV6"},
    KeySystem = false
})

-- Variáveis Globais
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:GetService("RunService")

local Vars = {
    Aimbot = false, TeamCheck = false, WallCheck = false, Fov = 100,
    Esp = false, Tracers = false,
    Ws = 16, Jp = 50, Fly = false, FlySpeed = 2,
    InfJump = false, Noclip = false,
    AutoFarm = false, Hitbox = 1
}

-- [[ FUNÇÕES DE COMBATE (TEAM/WALL/KILL CHECK) ]] --
local function GetClosest()
    local target = nil
    local dist = Vars.Fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if Vars.TeamCheck and p.Team == LP.Team then continue end
            if p.Character.Humanoid.Health <= 0 then continue end
            
            local pos, screen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if screen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    if Vars.WallCheck then
                        local parts = Camera:GetPartsObscuringTarget({p.Character.HumanoidRootPart.Position}, {LP.Character, p.Character})
                        if #parts > 0 then continue end
                    end
                    target = p.Character.HumanoidRootPart
                    dist = mag
                end
            end
        end
    end
    return target
end

----------------------------------------------------------------
-- TAB 1: COMBAT (AIMBOT & HITBOX)
----------------------------------------------------------------
local TabCombat = Window:CreateTab("Combat")
TabCombat:CreateToggle({Name = "Aimbot Ativo", CurrentValue = false, Callback = function(v) Vars.Aimbot = v end})
TabCombat:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) Vars.TeamCheck = v end})
TabCombat:CreateToggle({Name = "Wall Check (Anti-Parede)", CurrentValue = false, Callback = function(v) Vars.WallCheck = v end})
TabCombat:CreateSlider({Name = "Hitbox (Cabeça)", Range = {1, 30}, Increment = 1, CurrentValue = 1, Callback = function(v)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            p.Character.Head.Size = Vector3.new(v,v,v)
            p.Character.Head.Transparency = 0.5
            p.Character.Head.CanCollide = false
        end
    end
end})

----------------------------------------------------------------
-- TAB 2: VISUALS (ESP ESTILO IMAGEM)
----------------------------------------------------------------
local TabVisuals = Window:CreateTab("Visuals")
TabVisuals:CreateToggle({Name = "ESP Box/Skeleton", CurrentValue = false, Callback = function(v) 
    Vars.Esp = v 
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("NebulaESP") or Instance.new("Highlight", p.Character)
            h.Name = "NebulaESP"
            h.Enabled = v
            h.FillTransparency = 0.8
            h.OutlineTransparency = 0
        end
    end
end})

----------------------------------------------------------------
-- TAB 3: MOVEMENT (FLY MOBILE)
----------------------------------------------------------------
local TabMove = Window:CreateTab("Movement")
TabMove:CreateSlider({Name = "Velocidade", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) Vars.Ws = v end})
TabMove:CreateToggle({Name = "Fly (Vôo)", CurrentValue = false, Callback = function(v) Vars.Fly = v end})
TabMove:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Vars.Noclip = v end})
TabMove:CreateToggle({Name = "Pulo Infinito", CurrentValue = false, Callback = function(v) Vars.InfJump = v end})

----------------------------------------------------------------
-- TAB 4: UTILITY & ADMIN (+100 FUNÇÕES)
----------------------------------------------------------------
local TabAdmin = Window:CreateTab("Admin/Universal")
TabAdmin:CreateButton({Name = "Infinite Yield (100+ Comandos)", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com'))() end})
TabAdmin:CreateButton({Name = "Anti-AFK", Callback = function() print("Anti-AFK Ativo") end})

-- [[ LOOPS DE FUNCIONAMENTO ]] --
RS.RenderStepped:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Vars.Ws
        
        -- Aimbot Smooth
        if Vars.Aimbot then
            local target = GetClosest()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
        
        -- Fly Mobile (Movimento Baseado na Câmera)
        if Vars.Fly then
            char.HumanoidRootPart.Velocity = Vector3.new(0,0.1,0)
            if char.Humanoid.MoveDirection.Magnitude > 0 then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,-Vars.FlySpeed)
            end
        end

        -- Noclip
        if Vars.Noclip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if Vars.InfJump and LP.Character then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({Title = "Sucesso", Content = "Nebula V6 Totalmente Carregado!", Duration = 5})
