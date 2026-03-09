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
Note = "Key: Hashiras123",
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
local Stats = game:GetService("Stats")

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
Name="Hitbox (External)",
Callback=function()

for _,v in pairs(Players:GetPlayers()) do
if v~=LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
v.Character.HumanoidRootPart.Size = Vector3.new(10,10,10)
v.Character.HumanoidRootPart.Transparency = 0.7
v.Character.HumanoidRootPart.CanCollide = false
end
end

end
})

---------------------------------------------------
-- MOVEMENT
---------------------------------------------------

MovementTab:CreateSlider({
Name="WalkSpeed",
Range={0,200},
Increment=1,
CurrentValue=16,
Callback=function(Value)

local hum = GetCharacter():FindFirstChildOfClass("Humanoid")

if hum then
hum.WalkSpeed = Value
end

end
})

---------------------------------------------------
-- JUMP POWER CORRIGIDO
---------------------------------------------------

MovementTab:CreateSlider({
Name="Jump Power",
Range={0,200},
Increment=1,
CurrentValue=50,
Callback=function(Value)

local hum = GetCharacter():FindFirstChildOfClass("Humanoid")

if hum then
hum.UseJumpPower = true
hum.JumpPower = Value
end

end
})

---------------------------------------------------
-- FLY
---------------------------------------------------

MovementTab:CreateButton({
Name="Fly (External)",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end
})

---------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------

local InfiniteJump=false

MovementTab:CreateToggle({
Name="Infinite Jump",
CurrentValue=false,
Callback=function(v)
InfiniteJump=v
end
})

UIS.JumpRequest:Connect(function()

if InfiniteJump then

local hum = GetCharacter():FindFirstChildOfClass("Humanoid")

if hum then
hum:ChangeState("Jumping")
end

end

end)

---------------------------------------------------
-- NOCLIP
---------------------------------------------------

local noclip=false

MovementTab:CreateToggle({
Name="Noclip",
CurrentValue=false,
Callback=function(v)
noclip=v
end
})

RunService.Stepped:Connect(function()

if noclip then

for _,v in pairs(GetCharacter():GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end

end

end)

---------------------------------------------------
-- DASH ESTILO ANIME (CORRIGIDO)
---------------------------------------------------

local dashCooldown=false

local dashGui = Instance.new("ScreenGui")
dashGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local dashButton = Instance.new("TextButton")
dashButton.Parent = dashGui
dashButton.Size = UDim2.new(0,110,0,40)
dashButton.Position = UDim2.new(0.45,0,0.80,0)
dashButton.Text = "⚡ DASH"
dashButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
dashButton.TextColor3 = Color3.new(1,1,1)
dashButton.TextScaled = true
dashButton.Active = true
dashButton.Draggable = true

dashButton.MouseButton1Click:Connect(function()

if dashCooldown then return end
dashCooldown=true

local char = GetCharacter()
local hrp = char:FindFirstChild("HumanoidRootPart")

if hrp then

local dir = workspace.CurrentCamera.CFrame.LookVector
hrp.AssemblyLinearVelocity = dir * 120

end

task.wait(0.35)
dashCooldown=false

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

Lighting.Brightness = 5
Lighting.ClockTime = 14
Lighting.FogEnd = 1000000
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.fromRGB(255,255,255)
Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
Lighting.ExposureCompensation = 1

else

Lighting.Brightness = 1
Lighting.FogEnd = 100000
Lighting.GlobalShadows = true

end

end
})

---------------------------------------------------
-- TELEPORT
---------------------------------------------------

local selectedPlayer=nil

local dropdown = TeleportTab:CreateDropdown({
Name="Player List",
Options={},
CurrentOption=nil,
Callback=function(v)
selectedPlayer=v
end
})

local function refreshPlayers()

local list={}

for _,v in pairs(Players:GetPlayers()) do
if v~=LocalPlayer then
table.insert(list,v.Name)
end
end

dropdown:Refresh(list)

end

task.spawn(function()

while true do
refreshPlayers()
task.wait(3)
end

end)

---------------------------------------------------
-- TELEPORT TO PLAYER
---------------------------------------------------

TeleportTab:CreateButton({
Name="Teleport To Player",
Callback=function()

if selectedPlayer then

local target = Players:FindFirstChild(selectedPlayer)

if target and target.Character then

local myhrp = GetCharacter():FindFirstChild("HumanoidRootPart")
local hrp = target.Character:FindFirstChild("HumanoidRootPart")

if myhrp and hrp then
myhrp.CFrame = hrp.CFrame * CFrame.new(0,5,0)
end

end

end

end
})

---------------------------------------------------
-- TELEPORT BEHIND PLAYER
---------------------------------------------------

TeleportTab:CreateButton({
Name="Teleport Behind Player",
Callback=function()

if selectedPlayer then

local target = Players:FindFirstChild(selectedPlayer)

if target and target.Character then

local myhrp = GetCharacter():FindFirstChild("HumanoidRootPart")
local hrp = target.Character:FindFirstChild("HumanoidRootPart")

if myhrp and hrp then
myhrp.CFrame = hrp.CFrame * CFrame.new(0,0,3)
end

end

end

end
})

---------------------------------------------------
-- SPECTATE
---------------------------------------------------

TeleportTab:CreateButton({
Name="Spectate Player",
Callback=function()

if selectedPlayer then

local target = Players:FindFirstChild(selectedPlayer)

if target and target.Character then
workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChild("Humanoid")
end

end

end
})

---------------------------------------------------
-- CLICK TELEPORT
---------------------------------------------------

local clicktp=false
local mouse = LocalPlayer:GetMouse()

TeleportTab:CreateToggle({
Name="Click Teleport",
CurrentValue=false,
Callback=function(v)
clicktp=v
end
})

mouse.Button1Down:Connect(function()

if clicktp then

local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then
hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
end

end

end)

---------------------------------------------------
-- PLATFORM
---------------------------------------------------

TeleportTab:CreateButton({
Name="Create Platform",
Callback=function()

local part = Instance.new("Part")
part.Size = Vector3.new(20,1,20)
part.Anchored=true
part.Position = GetCharacter().HumanoidRootPart.Position - Vector3.new(0,3,0)
part.Parent = workspace

end
})

---------------------------------------------------
-- SKY / DOWN
---------------------------------------------------

TeleportTab:CreateButton({
Name="Go Up",
Callback=function()

local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then
hrp.CFrame = hrp.CFrame + Vector3.new(0,50,0)
end

end
})

TeleportTab:CreateButton({
Name="Go Down",
Callback=function()

local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then
hrp.CFrame = hrp.CFrame - Vector3.new(0,50,0)
end

end
})

---------------------------------------------------
-- SERVER
---------------------------------------------------

ServerTab:CreateButton({
Name="Rejoin",
Callback=function()
TeleportService:Teleport(game.PlaceId,LocalPlayer)
end
})

ServerTab:CreateButton({
Name="Server Hop",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Infinity2346/Tect-Menu/main/ServerHop"))()
end
})

ServerTab:CreateInput({
Name="Join Server (JobId)",
PlaceholderText="Paste JobId",
RemoveTextAfterFocusLost=false,
Callback=function(text)

TeleportService:TeleportToPlaceInstance(
game.PlaceId,
text,
LocalPlayer
)

end
})

---------------------------------------------------
-- SERVER INFO
---------------------------------------------------

task.spawn(function()

while true do

local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
local players = #Players:GetPlayers()

Rayfield:Notify({
Title="Server Info",
Content="Players: "..players.." | Ping: "..ping,
Duration=4
})

task.wait(10)

end

end)

---------------------------------------------------
-- EXTRA
---------------------------------------------------

ExtraTab:CreateButton({
Name="Infinite Yield",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end
})
