-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

---------------------------------------------------
-- KEY SYSTEM
---------------------------------------------------

local Window = Rayfield:CreateWindow({
Name = "Hashiras Hub",
LoadingTitle = "Hashiras Hub",
LoadingSubtitle = "Rayfield",
ConfigurationSaving = {Enabled = false},
KeySystem = true,
KeySettings = {
Title = "Hashiras Hub Key",
Subtitle = "Enter Key",
Note = "Hub está em beta, pode ter erros.",
SaveKey = true,
Key = {"Hashiras123"}
}
})

---------------------------------------------------
-- SERVICES
---------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local function GetCharacter()
return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

---------------------------------------------------
-- TABS
---------------------------------------------------

local CombatTab = Window:CreateTab("Combat",4483362458)
local MovementTab = Window:CreateTab("Movement",4483362458)
local VisualTab = Window:CreateTab("Visual",4483362458)
local TeleportTab = Window:CreateTab("Teleport",4483362458)
local ServerTab = Window:CreateTab("Server",4483362458)
local ExtraTab = Window:CreateTab("Extra",4483362458)

---------------------------------------------------
-- COMBAT
---------------------------------------------------

CombatTab:CreateButton({
Name="Aimbot (External)",
Callback=function()
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-universal-111551"))()
end
})

CombatTab:CreateButton({
Name="Hitbox",
Callback=function()
for _,v in pairs(Players:GetPlayers()) do
if v~=LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
v.Character.HumanoidRootPart.Size=Vector3.new(10,10,10)
v.Character.HumanoidRootPart.Transparency=0.7
v.Character.HumanoidRootPart.CanCollide=false
end
end
end
})

---------------------------------------------------
-- WHEEL AIMBOT
---------------------------------------------------

local WheelAimbot = false
local wheels = {"FL","FR","RL","RR"}

local camera = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()
local VirtualInputManager = game:GetService("VirtualInputManager")

CombatTab:CreateToggle({
Name = "Wheel Aimbot",
CurrentValue = false,
Callback = function(v)
WheelAimbot = v
end
})

local function GetClosestWheel()

local closest
local distance = math.huge

for _,v in pairs(workspace:GetDescendants()) do

for _,wheel in pairs(wheels) do

if v.Name == wheel and v:IsA("BasePart") then

local screenPos, visible = camera:WorldToViewportPoint(v.Position)

if visible then

local dist = (Vector2.new(screenPos.X,screenPos.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude

if dist < distance then
distance = dist
closest = v
end

end

end

end

end

return closest
end

RunService.RenderStepped:Connect(function()

if not WheelAimbot then return end

local wheel = GetClosestWheel()

if wheel then

local pos, visible = camera:WorldToViewportPoint(wheel.Position)

if visible then

VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)

end

end

end)

---------------------------------------------------
-- MOVEMENT
---------------------------------------------------

MovementTab:CreateSlider({
Name="WalkSpeed",
Range={0,200},
Increment=1,
CurrentValue=16,
Callback=function(Value)
local hum=GetCharacter():FindFirstChildOfClass("Humanoid")
if hum then hum.WalkSpeed=Value end
end
})

MovementTab:CreateSlider({
Name="Jump Power",
Range={0,200},
Increment=1,
CurrentValue=50,
Callback=function(Value)
local hum=GetCharacter():FindFirstChildOfClass("Humanoid")
if hum then
hum.UseJumpPower=true
hum.JumpPower=Value
end
end
})

MovementTab:CreateButton({
Name="Fly",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end
})

local InfiniteJump=false
MovementTab:CreateToggle({
Name="Infinite Jump",
CurrentValue=false,
Callback=function(v) InfiniteJump=v end
})

UIS.JumpRequest:Connect(function()
if InfiniteJump then
local hum=GetCharacter():FindFirstChildOfClass("Humanoid")
if hum then hum:ChangeState("Jumping") end
end
end)

local noclip=false
MovementTab:CreateToggle({
Name="Noclip",
CurrentValue=false,
Callback=function(v) noclip=v end
})

RunService.Stepped:Connect(function()
if noclip then
for _,v in pairs(GetCharacter():GetDescendants()) do
if v:IsA("BasePart") then v.CanCollide=false end
end
end
end)

---------------------------------------------------
-- VISUAL
---------------------------------------------------

VisualTab:CreateToggle({
Name="ESP",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/ESP-Script/refs/heads/main/ESP.lua"))()
end
})

VisualTab:CreateToggle({
Name="FullBright",
CurrentValue=false,
Callback=function(Value)

if Value then
Lighting.Brightness=2
Lighting.ClockTime=14
Lighting.FogEnd=500000
Lighting.GlobalShadows=false
Lighting.Ambient=Color3.fromRGB(180,180,180)
Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
Lighting.ExposureCompensation=0.3
else
Lighting.Brightness=1
Lighting.GlobalShadows=true
Lighting.ExposureCompensation=0
end

end
})

---------------------------------------------------
-- TELEPORT PLAYER
---------------------------------------------------

local SelectedPlayerName

local function GetPlayers()
local t={}
for _,p in ipairs(Players:GetPlayers()) do
if p~=LocalPlayer then
table.insert(t,p.Name)
end
end
return t
end

local dropdown=TeleportTab:CreateDropdown({
Name="Player List",
Options=GetPlayers(),
CurrentOption=nil,
Callback=function(v)
SelectedPlayerName=v[1]
end
})

task.spawn(function()
while task.wait(3) do
dropdown:Refresh(GetPlayers())
end
end)

TeleportTab:CreateButton({
Name="Teleport To Player",
Callback=function()

if not SelectedPlayerName then return end

local target=Players:FindFirstChild(SelectedPlayerName)
if not target then return end
if not LocalPlayer.Character or not target.Character then return end

local hrp=LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local thrp=target.Character:FindFirstChild("HumanoidRootPart")

if hrp and thrp then
hrp.CFrame=thrp.CFrame+Vector3.new(0,3,0)
end

end
})

---------------------------------------------------
-- TELEPORT CAR
---------------------------------------------------

local SelectedCar
local CarSeats = {}

local function GetCars()

local cars = {}
CarSeats = {}

for _,v in pairs(workspace:GetDescendants()) do

    if v:IsA("VehicleSeat") or v.Name == "DriveSeat" then

        local model = v:FindFirstAncestorOfClass("Model")

        if model then

            local carName = model.Name

            if not table.find(cars, carName) then
                table.insert(cars, carName)
                CarSeats[carName] = v
            end

        end

    end

end

return cars
end

local CarDropdown = TeleportTab:CreateDropdown({
Name = "Car List",
Options = GetCars(),
CurrentOption = nil,
Callback = function(v)
SelectedCar = v[1]
end
})

TeleportTab:CreateButton({
Name = "Refresh Car List",
Callback = function()
CarDropdown:Refresh(GetCars())
end
})

TeleportTab:CreateButton({
Name = "Teleport To Car",
Callback = function()

if not SelectedCar then return end

local seat = CarSeats[SelectedCar]

if seat then

local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then
hrp.CFrame = seat.CFrame + Vector3.new(0,3,0)
end

end

end
})

---------------------------------------------------
-- CAR ESP + TRACER
---------------------------------------------------

local CarESP = false
local CarESPObjects = {}

VisualTab:CreateToggle({
Name = "Car ESP",
CurrentValue = false,
Callback = function(v)

CarESP = v

if not v then

for _,data in pairs(CarESPObjects) do
if data.Gui then data.Gui:Destroy() end
if data.Line then data.Line:Remove() end
end

CarESPObjects = {}

end

end
})

local function CreateCarESP(model, seat)

local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0,150,0,40)
billboard.AlwaysOnTop = true
billboard.StudsOffset = Vector3.new(0,3,0)
billboard.Parent = seat

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.TextStrokeTransparency = 0
text.TextScaled = true
text.Font = Enum.Font.SourceSansBold
text.Parent = billboard

local line = Drawing.new("Line")
line.Color = Color3.fromRGB(255,0,0)
line.Thickness = 2
line.Visible = false

CarESPObjects[model] = {
Gui = billboard,
Text = text,
Seat = seat,
Line = line
}

end

-- escaneia carros
for _,v in pairs(workspace:GetDescendants()) do

if v:IsA("VehicleSeat") or v.Name == "DriveSeat" then

local model = v:FindFirstAncestorOfClass("Model")

if model and not CarESPObjects[model] then
CreateCarESP(model,v)
end

end

end

-- atualiza
task.spawn(function()

while true do
task.wait(0.25)

if not CarESP then continue end

local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
if not hrp then continue end

local camera = workspace.CurrentCamera
local viewport = camera.ViewportSize

for model,data in pairs(CarESPObjects) do

local seat = data.Seat
local text = data.Text
local line = data.Line

if seat and seat.Parent then

local distance = math.floor((hrp.Position - seat.Position).Magnitude)
local occupied = seat.Occupant ~= nil

if occupied then
text.TextColor3 = Color3.fromRGB(255,60,60)
else
text.TextColor3 = Color3.fromRGB(60,255,60)
end

text.Text = model.Name.." ["..distance.."m]"

local screenPos, visible = camera:WorldToViewportPoint(seat.Position)

if visible then

line.Visible = true
line.From = Vector2.new(viewport.X/2, viewport.Y)
line.To = Vector2.new(screenPos.X, screenPos.Y)

else
line.Visible = false
end

end

end

end

end)
