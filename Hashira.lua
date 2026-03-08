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

Combat:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v)
        Vars.Hitbox = v
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

Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        Vars.Fly = v
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
-- TELEPORT PLAYERS
---------------------------------------------------

local PlayerList = {}
local SelectedPlayer = nil

local function UpdatePlayerList()

    PlayerList = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(PlayerList,p.Name)
        end
    end

end

UpdatePlayerList()

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Players",
    Options = PlayerList,
    CurrentOption = nil,
    Callback = function(opt)
        SelectedPlayer = opt
    end
})

TeleportTab:CreateButton({
    Name = "Update Player List",
    Callback = function()
        UpdatePlayerList()
        PlayerDropdown:Refresh(PlayerList)
    end
})

TeleportTab:CreateButton({
    Name = "Teleport To Player",
    Callback = function()

        if not SelectedPlayer then return end

        local target = nil

        for _,p in pairs(Players:GetPlayers()) do
            if p.Name == SelectedPlayer then
                target = p
                break
            end
        end

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

            local root = GetRoot()

            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end

        end

    end
})

---------------------------------------------------
-- TELEPORT CARS
---------------------------------------------------

local CarList = {}
local CarObjects = {}
local SelectedCar = nil

local function UpdateCarList()

    CarList = {}
    CarObjects = {}

    for _,v in pairs(workspace:GetDescendants()) do

        if v:IsA("VehicleSeat") then
            table.insert(CarList,v.Name)
            CarObjects[v.Name] = v
        end

    end

end

UpdateCarList()

local CarDropdown = TeleportTab:CreateDropdown({
    Name = "Cars",
    Options = CarList,
    CurrentOption = nil,
    Callback = function(opt)
        SelectedCar = opt
    end
})

TeleportTab:CreateButton({
    Name = "Update Car List",
    Callback = function()
        UpdateCarList()
        CarDropdown:Refresh(CarList)
    end
})

TeleportTab:CreateButton({
    Name = "Teleport Driver Seat",
    Callback = function()

        if not SelectedCar then return end

        local seat = CarObjects[SelectedCar]

        if seat then

            local root = GetRoot()

            if root then
                root.CFrame = seat.CFrame + Vector3.new(0,2,0)
            end

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
