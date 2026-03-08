-- [[ NEBULA HUB V6 - DEFINITIVE EDITION ]] --
if not game:IsLoaded() then game.Loaded:Wait() end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Nebula Hub | V6 FINAL",
    LoadingTitle = "Carregando Sistemas...",
    LoadingSubtitle = "ESP Style & Touch TP",
    ConfigurationSaving = {Enabled = false}
})

-- SERVIÇOS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Vars = {
    Aimbot = false, Smoothness = 0.2, Fov = 100, FovVis = false,
    EspBox = false, EspInfo = false, 
    Ws = 16, Jp = 50, Fly = false, FlySpeed = 2
}

-- [[ SISTEMA DE TELEPORTE POR TOQUE (ITEM NO INVENTÁRIO) ]] --
local function CreateTPTool()
    local tool = Instance.new("Tool")
    tool.Name = "Teleport Tool"
    tool.RequiresHandle = false
    tool.Parent = LP.Backpack

    tool.Activated:Connect(function()
        local mouse = LP:GetMouse()
        if mouse.Target and LP.Character then
            LP.Character:MoveTo(mouse.Hit.p)
        end
    end)
end

-- [[ FUNÇÃO PARA CALCULAR O ALVO MAIS PRÓXIMO ]] --
local function GetClosest()
    local target = nil
    local dist = Vars.Fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health <= 0 then continue end
            local pos, screen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if screen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    target = p.Character.HumanoidRootPart
                    dist = mag
                end
            end
        end
    end
    return target
end

-- [[ SISTEMA DE ESP (BOX, VIDA E DISTÂNCIA) ]] --
local function CreateESP(p)
    local box = Drawing.new("Square")
    local healthBar = Drawing.new("Line")
    local info = Drawing.new("Text")
    
    local function Update()
        local c = RS.RenderStepped:Connect(function()
            if Vars.EspBox and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= LP then
                local root = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local pos, screen = Camera:WorldToViewportPoint(root.Position)
                
                if screen then
                    local sizeX = 2000 / pos.Z
                    local sizeY = 3000 / pos.Z
                    local x = pos.X - sizeX / 2
                    local y = pos.Y - sizeY / 2
                    
                    -- Retângulo Branco (Box)
                    box.Visible = true
                    box.Color = Color3.new(1, 1, 1)
                    box.Size = Vector2.new(sizeX, sizeY)
                    box.Position = Vector2.new(x, y)
                    box.Thickness = 1
                    
                    -- Barra de Vida Verde (Lateral)
                    healthBar.Visible = true
                    healthBar.Color = Color3.fromRGB(0, 255, 0)
                    healthBar.Thickness = 2
                    healthBar.From = Vector2.new(x - 5, y + sizeY)
                    healthBar.To = Vector2.new(x - 5, y + sizeY - (sizeY * (hum.Health / hum.MaxHealth)))
                    
                    -- Informações (Metros e Nome)
                    local dist = math.floor((LP.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    info.Visible = true
                    info.Text = string.format("%s\n[%d m]", p.Name, dist)
                    info.Size = 14
                    info.Center = true
                    info.Outline = true
                    info.Position = Vector2.new(pos.X, y + sizeY + 5)
                else
                    box.Visible = false
                    healthBar.Visible = false
                    info.Visible = false
                end
            else
                box.Visible = false
                healthBar.Visible = false
                info.Visible = false
                if not p.Parent then box:Remove() healthBar:Remove() info:Remove() end
            end
        end)
    end
    coroutine.wrap(Update)()
end

----------------------------------------------------------------
-- INTERFACE RAYFIELD
----------------------------------------------------------------
local TabCombat = Window:CreateTab("Combat")
TabCombat:CreateToggle({Name = "Aimbot (Mira Suave)", CurrentValue = false, Callback = function(v) Vars.Aimbot = v end})
TabCombat:CreateSlider({Name = "Suavidade (Aimbot)", Range = {0, 1}, Increment = 0.1, CurrentValue = 0.2, Callback = function(v) Vars.Smoothness = v end})

local TabVisuals = Window:CreateTab("Visuals")
TabVisuals:CreateToggle({Name = "ESP Box Completo", CurrentValue = false, Callback = function(v) Vars.EspBox = v end})

local TabUtil = Window:CreateTab("Utility")
TabUtil:CreateButton({Name = "Pegar Item de Teleporte", Callback = function() CreateTPTool() end})
TabUtil:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com'))() end})

-- LOOP PRINCIPAL
RS.RenderStepped:Connect(function()
    if Vars.Aimbot then
        local target = GetClosest()
        if target then
            local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, Vars.Smoothness)
        end
    end
    
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Vars.Ws
    end
end)

-- Inicializa ESP para todos
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

Rayfield:Notify({Title = "Nebula V6", Content = "Script Atualizado!", Duration = 5})
