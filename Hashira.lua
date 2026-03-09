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

-- Infinite Jump
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

-- Noclip
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
-- DASH
---------------------------------------------------

local dashCooldown=false

local dashGui=Instance.new("ScreenGui",LocalPlayer:WaitForChild("PlayerGui"))
local dashButton=Instance.new("TextButton",dashGui)

dashButton.Size=UDim2.new(0,110,0,40)
dashButton.Position=UDim2.new(0.45,0,0.80,0)
dashButton.Text="⚡ DASH"
dashButton.BackgroundColor3=Color3.fromRGB(30,30,30)
dashButton.TextColor3=Color3.new(1,1,1)
dashButton.TextScaled=true
dashButton.Active=true
dashButton.Draggable=true

dashButton.MouseButton1Click:Connect(function()

if dashCooldown then return end
dashCooldown=true

local hrp=GetCharacter():FindFirstChild("HumanoidRootPart")

if hrp then
local dir=workspace.CurrentCamera.CFrame.LookVector
hrp.AssemblyLinearVelocity=dir*120
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

-- FullBright reduzido
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
-- TELEPORT (RAYFIELD)
---------------------------------------------------

local selectedPlayer=nil

local dropdown=TeleportTab:CreateDropdown({
Name="Player List",
Options={},
CurrentOption=nil,
Callback=function(v) selectedPlayer=v end
})

local function refreshPlayers()
local list={}
for _,v in pairs(Players:GetPlayers()) do
if v~=LocalPlayer then table.insert(list,v.Name) end
end
dropdown:Refresh(list)
end

task.spawn(function()
while true do
refreshPlayers()
task.wait(3)
end
end)

TeleportTab:CreateButton({
Name="Teleport To Player",
Callback=function()

if selectedPlayer then

local target=Players:FindFirstChild(selectedPlayer)

if target and target.Character then
local myhrp=GetCharacter():FindFirstChild("HumanoidRootPart")
local hrp=target.Character:FindFirstChild("HumanoidRootPart")

if myhrp and hrp then
myhrp.CFrame=hrp.CFrame*CFrame.new(0,5,0)
end

end

end

end
})

TeleportTab:CreateButton({
Name="Teleport Behind Player",
Callback=function()

if selectedPlayer then

local target=Players:FindFirstChild(selectedPlayer)

if target and target.Character then

local myhrp=GetCharacter():FindFirstChild("HumanoidRootPart")
local hrp=target.Character:FindFirstChild("HumanoidRootPart")

if myhrp and hrp then
myhrp.CFrame=hrp.CFrame*CFrame.new(0,0,3)
end

end

end

end
})

---------------------------------------------------
-- XSAT TELEPORT GUI (FUNCIONANDO)
---------------------------------------------------

local P=Players
local lp=P.LocalPlayer

local function C()

if lp:WaitForChild("PlayerGui"):FindFirstChild("XsatTeleportUI") then return end

local S=Instance.new("ScreenGui",lp.PlayerGui)
S.Name="XsatTeleportUI"
S.ResetOnSpawn=false

local F=Instance.new("Frame",S)
F.Size=UDim2.new(0,200,0,270)
F.Position=UDim2.new(0.5,-100,0.5,-135)
F.BackgroundColor3=Color3.new(0,0,0)
F.Active=true
F.Draggable=true

local TBar=Instance.new("Frame",F)
TBar.Size=UDim2.new(1,0,0,30)
TBar.BackgroundColor3=Color3.fromRGB(45,45,45)

local Title=Instance.new("TextLabel",TBar)
Title.Size=UDim2.new(1,0,1,0)
Title.Text="Xsat-Teleport"
Title.TextColor3=Color3.new(1,1,1)
Title.BackgroundTransparency=1
Title.Font=Enum.Font.SourceSansBold

local X=Instance.new("TextButton",TBar)
X.Size=UDim2.new(0,30,0,30)
X.Position=UDim2.new(1,-30,0,0)
X.Text="X"
X.BackgroundColor3=Color3.new(0.6,0,0)
X.TextColor3=Color3.new(1,1,1)

local O=Instance.new("TextButton",S)
O.Size=UDim2.new(0,120,0,35)
O.Position=UDim2.new(0.5,-60,0,50)
O.Text="Xsat Teleport"
O.Visible=false
O.Draggable=true
O.Active=true

local Inp=Instance.new("TextBox",F)
Inp.Size=UDim2.new(1,-20,0,30)
Inp.Position=UDim2.new(0,10,0,40)
Inp.PlaceholderText="Click player..."

local Scrol=Instance.new("ScrollingFrame",F)
Scrol.Size=UDim2.new(1,-20,0,140)
Scrol.Position=UDim2.new(0,10,0,80)
Scrol.BackgroundColor3=Color3.new(0.1,0.1,0.1)

Instance.new("UIListLayout",Scrol)

local Btn=Instance.new("TextButton",F)
Btn.Size=UDim2.new(1,-20,0,30)
Btn.Position=UDim2.new(0,10,0,230)
Btn.Text="TELEPORT"
Btn.BackgroundColor3=Color3.new(0,0.5,0)
Btn.TextColor3=Color3.new(1,1,1)

X.MouseButton1Click:Connect(function()
F.Visible=false
O.Visible=true
end)

O.MouseButton1Click:Connect(function()
F.Visible=true
O.Visible=false
end)

local function U()

for _,v in pairs(Scrol:GetChildren()) do
if v:IsA("TextButton") then v:Destroy() end
end

for _,p in pairs(P:GetPlayers()) do
if p~=lp then
local b=Instance.new("TextButton",Scrol)
b.Size=UDim2.new(1,0,0,25)
b.Text=p.Name
b.MouseButton1Click:Connect(function()
Inp.Text=p.Name
end)
end
end

end

U()

P.PlayerAdded:Connect(U)
P.PlayerRemoving:Connect(U)

Btn.MouseButton1Click:Connect(function()

local t=P:FindFirstChild(Inp.Text)

if t and t.Character and lp.Character then
local hrp=lp.Character:FindFirstChild("HumanoidRootPart")
local thrp=t.Character:FindFirstChild("HumanoidRootPart")

if hrp and thrp then
hrp.CFrame=thrp.CFrame*CFrame.new(0,7,0)
end
end

end)

end

C()
lp.CharacterAdded:Connect(function()
task.wait(1)
C()
end)

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
