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
local Lighting = game:GetService("Lighting")

local Vars = {
    EspBox = false,
    Ws = 16,
    Jp = 50,
    InfJump = false,
    NoClip = false
}

--------------------------------------------------
-- TELEPORT TOOL
--------------------------------------------------

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

--------------------------------------------------
-- ESP MELHORADO
--------------------------------------------------

local function CreateESP(p)

    local box = Drawing.new("Square")
    local outline = Drawing.new("Square")
    local healthBar = Drawing.new("Line")
    local info = Drawing.new("Text")

    RS.RenderStepped:Connect(function()

        if Vars.EspBox and p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then

            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then

                local pos, visible = Camera:WorldToViewportPoint(root.Position)

                if visible then

                    local sizeX = 2000 / pos.Z
                    local sizeY = 3000 / pos.Z

                    local x = pos.X - sizeX/2
                    local y = pos.Y - sizeY/2

                    -- Outline
                    outline.Visible = true
                    outline.Size = Vector2.new(sizeX+2,sizeY+2)
                    outline.Position = Vector2.new(x-1,y-1)
                    outline.Color = Color3.new(0,0,0)
                    outline.Thickness = 3
                    outline.Filled = false

                    -- Box
                    box.Visible = true
                    box.Size = Vector2.new(sizeX,sizeY)
                    box.Position = Vector2.new(x,y)
                    box.Color = Color3.fromRGB(0,255,120)
                    box.Thickness = 2
                    box.Filled = false

                    -- Health bar
                    healthBar.Visible = true
                    healthBar.Thickness = 3

                    local hpPercent = hum.Health / hum.MaxHealth

                    local r = 255 - (hpPercent * 255)
                    local g = hpPercent * 255

                    healthBar.Color = Color3.fromRGB(r,g,0)

                    healthBar.From = Vector2.new(x-6,y+sizeY)
                    healthBar.To = Vector2.new(x-6,y+sizeY-(sizeY*hpPercent))

                    -- Info
                    local dist = math.floor(
                        (LP.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    )

                    info.Visible = true
                    info.Center = true
                    info.Outline = true
                    info.Size = 14
                    info.Color = Color3.fromRGB(255,255,255)
                    info.Text = p.Name.." | "..dist.."m"
                    info.Position = Vector2.new(pos.X,y-15)

                else

                    box.Visible = false
                    outline.Visible = false
                    healthBar.Visible = false
                    info.Visible = false

                end
            end
        else

            box.Visible = false
            outline.Visible = false
            healthBar.Visible = false
            info.Visible = false

        end
    end)
end

--------------------------------------------------
-- INTERFACE
--------------------------------------------------

local TabCombat = Window:CreateTab("Combat")

TabCombat:CreateButton({
    Name = "Universal Aimbot",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-universal-111551"))()
    end
})

--------------------------------------------------

local TabVisuals = Window:CreateTab("Visuals")

TabVisuals:CreateToggle({
    Name = "ESP Box Melhorado",
    CurrentValue = false,
    Callback = function(v)
        Vars.EspBox = v
    end
})

TabVisuals:CreateButton({
    Name = "ESP Universal (Externo)",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Esp-universal-49905"))()
    end
})

TabVisuals:CreateButton({
    Name = "FullBright",
    Callback = function()

        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1,1,1)

    end
})

--------------------------------------------------

local TabUtil = Window:CreateTab("Utility")

TabUtil:CreateButton({
    Name = "Teleport Tool",
    Callback = function()
        CreateTPTool()
    end
})

TabUtil:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        Vars.Ws = v
    end
})

TabUtil:CreateSlider({
    Name = "JumpPower",
    Range = {50,500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        Vars.Jp = v
    end
})

TabUtil:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        Vars.InfJump = v
    end
})

TabUtil:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        Vars.NoClip = v
    end
})

TabUtil:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

--------------------------------------------------
-- LOOP
--------------------------------------------------

RS.RenderStepped:Connect(function()

    if LP.Character and LP.Character:FindFirstChild("Humanoid") then

        LP.Character.Humanoid.WalkSpeed = Vars.Ws
        LP.Character.Humanoid.JumpPower = Vars.Jp

    end

    if Vars.NoClip and LP.Character then

        for _,v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end

    end

end)

--------------------------------------------------
-- INFINITE JUMP
--------------------------------------------------

UIS.JumpRequest:Connect(function()

    if Vars.InfJump then

        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid:ChangeState("Jumping")
        end

    end

end)

--------------------------------------------------
-- ESP INIT
--------------------------------------------------

for _,p in pairs(Players:GetPlayers()) do
    CreateESP(p)
end

Players.PlayerAdded:Connect(CreateESP)

--------------------------------------------------
-- ANTI AFK
--------------------------------------------------

LP.Idled:Connect(function()

    local vu = game:GetService("VirtualUser")

    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)

end)

Rayfield:Notify({
    Title = "Nebula Hub V6",
    Content = "Sistemas Prontos!",
    Duration = 5
})
