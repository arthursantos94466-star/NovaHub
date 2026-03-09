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
-- TELEPORT TOOL
---------------------------------------------------

TeleportTab:CreateButton({
Name="Teleport Tool",
Callback=function()

local tool=Instance.new("Tool")
tool.Name="Teleport Tool"
tool.RequiresHandle=false
tool.Parent=LocalPlayer.Backpack

tool.Activated:Connect(function()

local mouse=LocalPlayer:GetMouse()
local char=GetCharacter()
local hrp=char:FindFirstChild("HumanoidRootPart")

if hrp and mouse.Hit then
hrp.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,5,0))
end

end)

end
})

---------------------------------------------------
-- GO TO SKY
---------------------------------------------------

TeleportTab:CreateButton({
Name="Go To Sky",
Callback=function()

local hrp=GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then
hrp.CFrame=hrp.CFrame+Vector3.new(0,300,0)
end

end
})

---------------------------------------------------
-- CREATE PLATFORM
---------------------------------------------------

TeleportTab:CreateButton({
Name="Create Platform",
Callback=function()

local hrp=GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then

local part=Instance.new("Part")
part.Size=Vector3.new(20,1,20)
part.Anchored=true
part.Position=hrp.Position-Vector3.new(0,3,0)
part.Parent=workspace

end

end
})

---------------------------------------------------
-- SPECTATE PLAYER
---------------------------------------------------

ExtraTab:CreateButton({
Name="Open Spectate",
Callback=function()

local screenGui=Instance.new("ScreenGui")
screenGui.Parent=LocalPlayer.PlayerGui

local toggleButton=Instance.new("TextButton",screenGui)
toggleButton.Size=UDim2.new(0,120,0,40)
toggleButton.Position=UDim2.new(0,10,0,10)
toggleButton.Text="Spectate: OFF"

local nextButton=Instance.new("TextButton",screenGui)
nextButton.Size=UDim2.new(0,60,0,40)
nextButton.Position=UDim2.new(0,140,0,10)
nextButton.Text="Next"

local prevButton=Instance.new("TextButton",screenGui)
prevButton.Size=UDim2.new(0,60,0,40)
prevButton.Position=UDim2.new(0,210,0,10)
prevButton.Text="Prev"

local playerLabel=Instance.new("TextLabel",screenGui)
playerLabel.Size=UDim2.new(0,200,0,30)
playerLabel.Position=UDim2.new(0,10,0,60)
playerLabel.Text="Spectating: None"
playerLabel.BackgroundTransparency=1
playerLabel.TextColor3=Color3.new(1,1,1)

local spectateEnabled=false
local spectateIndex=1
local playerList={}

local function updatePlayerList()
playerList={}
for _,player in pairs(Players:GetPlayers()) do
if player~=LocalPlayer then
table.insert(playerList,player)
end
end
end

local function setCamera()

if spectateEnabled and #playerList>0 then

local target=playerList[spectateIndex]

if target.Character and target.Character:FindFirstChild("Humanoid") then
Workspace.CurrentCamera.CameraSubject=target.Character.Humanoid
end

else

if LocalPlayer.Character then
Workspace.CurrentCamera.CameraSubject=LocalPlayer.Character:FindFirstChild("Humanoid")
end

end

end

toggleButton.MouseButton1Click:Connect(function()

spectateEnabled=not spectateEnabled

if spectateEnabled then
toggleButton.Text="Spectate: ON"
updatePlayerList()
setCamera()
else
toggleButton.Text="Spectate: OFF"
setCamera()
end

end)

nextButton.MouseButton1Click:Connect(function()

if #playerList>0 then
spectateIndex=spectateIndex+1
if spectateIndex>#playerList then
spectateIndex=1
end
setCamera()
end

end)

prevButton.MouseButton1Click:Connect(function()

if #playerList>0 then
spectateIndex=spectateIndex-1
if spectateIndex<1 then
spectateIndex=#playerList
end
setCamera()
end

end)

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

---------------------------------------------------
-- EXTRA
---------------------------------------------------

ExtraTab:CreateButton({
Name="Infinite Yield",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end
})
