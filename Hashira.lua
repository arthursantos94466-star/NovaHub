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
-- WHEEL AIMBOT PRO (VRim + Prediction + Detection)
---------------------------------------------------

local WheelAimbot = false
local WheelTarget = "All"
local FOV = 250
local MaxDistance = 500
local Prediction = 0.12
local Smoothing = 0.15 

local LockedWheel = nil
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

---------------------------------------------------
-- FUNÇÕES DE SUPORTE (CORRIGIDAS)
---------------------------------------------------

-- Verifica se o carro está ocupado
local function IsVehicleOccupied(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if not model then return false end

    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant then
            return true
        end
    end
    return false
end

-- ESSENCIAL: Verifica se o alvo ainda é válido (Faz soltar a mira)
local function IsValidTarget(part)
    if not part or not part.Parent then return false end
    
    local pos, visible = camera:WorldToViewportPoint(part.Position)
    if not visible then return false end
    
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local dist2D = (center - Vector2.new(pos.X, pos.Y)).Magnitude
    local dist3D = (camera.CFrame.Position - part.Position).Magnitude
    
    return dist2D <= FOV and dist3D <= MaxDistance
end

-- Pegar a roda mais próxima
local function GetClosestWheel()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "VRim" and v:IsA("BasePart") then
            local wheelFolder = v.Parent
            local wheelName = wheelFolder and wheelFolder.Parent and wheelFolder.Parent.Name

            if (WheelTarget == "All" or wheelName == WheelTarget) then
                local dist3D = (camera.CFrame.Position - v.Position).Magnitude
                if dist3D <= MaxDistance then
                    local pos, visible = camera:WorldToViewportPoint(v.Position)
                    if visible then
                        local dist2D = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist2D <= FOV then
                            local priority = IsVehicleOccupied(v) and 0.5 or 1
                            local finalDist = dist2D * priority

                            if finalDist < closestDist then
                                closestDist = finalDist
                                closest = v
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

---------------------------------------------------
-- CONTROLES RAYFIELD
---------------------------------------------------

-- Certifique-se de que 'CombatTab' já foi criado acima no seu script principal
CombatTab:CreateToggle({
    Name = "Wheel Aimbot",
    CurrentValue = false,
    Callback = function(v)
        WheelAimbot = v
        LockedWheel = nil
    end
})

CombatTab:CreateDropdown({
    Name = "Wheel Target",
    Options = {"All","FL","FR","RL","RR"},
    CurrentOption = {"All"},
    Callback = function(opt)
        -- Rayfield retorna uma tabela ou string dependendo da versão, tratamos aqui:
        WheelTarget = type(opt) == "table" and opt[1] or opt
        LockedWheel = nil
    end
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 600},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) FOV = v end
})

CombatTab:CreateSlider({
    Name = "Aimbot Smooth (Suavização)",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(v) Smoothing = v/100 end
})

CombatTab:CreateSlider({
    Name = "Prediction",
    Range = {0, 30},
    Increment = 1,
    CurrentValue = 12,
    Callback = function(v) Prediction = v/100 end
})

---------------------------------------------------
-- LOOP DO AIMBOT (FINAL)
---------------------------------------------------

RunService.RenderStepped:Connect(function()
    if not WheelAimbot then 
        LockedWheel = nil 
        return 
    end

    -- Se o alvo atual não for mais válido, procura um novo
    if not LockedWheel or not IsValidTarget(LockedWheel) then
        LockedWheel = GetClosestWheel()
    end

    if LockedWheel then
        -- Cálculo de Predição baseado na velocidade da roda
        local velocity = LockedWheel.AssemblyLinearVelocity
        local predictedPos = LockedWheel.Position + (velocity * Prediction)
        
        local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        
        -- Lerp permite que a mira seja fluida no Mobile
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, Smoothing)
    end
end)

---------------------------------------------------
-- TURRET AIMBOT PRO
---------------------------------------------------

local TurretAimbot=false
local TeamCheck=true
local Smoothness=0.15

local function GetTarget()

    local closest=nil
    local dist=math.huge

    for _,p in pairs(Players:GetPlayers()) do

        if p~=LocalPlayer and p.Character then

            if TeamCheck and p.Team==LocalPlayer.Team then
                continue
            end

            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            local head=p.Character:FindFirstChild("Head")

            if hum and head then

                if hum.Sit and hum.SeatPart and hum.SeatPart.Name=="TurretSeat" then

                    local d=(Camera.CFrame.Position-head.Position).Magnitude

                    if d<dist then
                        dist=d
                        closest=head
                    end

                end

            end

        end

    end

    return closest
end


RunService.RenderStepped:Connect(function()

    if not TurretAimbot then return end

    local target=GetTarget()
    if not target then return end

    local camPos=Camera.CFrame.Position
    local aimCF=CFrame.new(camPos,target.Position)

    Camera.CFrame=Camera.CFrame:Lerp(aimCF,Smoothness)

end)


CombatTab:CreateToggle({
Name="Turret Aimbot PRO",
CurrentValue=false,
Callback=function(v)
TurretAimbot=v
end
})

---------------------------------------------------
-- MOVEMENT
---------------------------------------------------

local WalkSpeedValue = 16
local WalkSpeedEnabled = false

MovementTab:CreateSlider({
Name = "WalkSpeed",
Range = {0,200},
Increment = 1,
CurrentValue = 16,
Callback = function(Value)
WalkSpeedValue = Value
WalkSpeedEnabled = true
end
})

task.spawn(function()
while task.wait() do
if WalkSpeedEnabled then
local char = game.Players.LocalPlayer.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum and hum.WalkSpeed ~= WalkSpeedValue then
hum.WalkSpeed = WalkSpeedValue
end
end
end
end
end)

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

-- Garantir tabela
getgenv().EspSettings = getgenv().EspSettings or {}

EspSettings.Names = EspSettings.Names or {Enabled = false}
EspSettings.Tracers = EspSettings.Tracers or {Enabled = false}
EspSettings.Skeletons = EspSettings.Skeletons or {Enabled = false}
EspSettings.HealthBars = EspSettings.HealthBars or {Enabled = false}

-------------------------------------------------
-- ESP Nome
-------------------------------------------------

VisualTab:CreateToggle({
    Name = "ESP Nome",
    CurrentValue = EspSettings.Names.Enabled,
    Callback = function(Value)
        EspSettings.Names.Enabled = Value
    end
})

-------------------------------------------------
-- ESP Tool Equipada
-------------------------------------------------

VisualTab:CreateToggle({
    Name = "ESP Tool Equipada",
    CurrentValue = false,
    Callback = function(Value)
        EspSettings.Names.ShowTool = Value
    end
})

-------------------------------------------------
-- ESP Health Bar
-------------------------------------------------

VisualTab:CreateToggle({
    Name = "ESP Health Bar",
    CurrentValue = EspSettings.HealthBars.Enabled,
    Callback = function(Value)
        EspSettings.HealthBars.Enabled = Value
    end
})

-------------------------------------------------
-- ESP Esqueleto
-------------------------------------------------

VisualTab:CreateToggle({
    Name = "ESP Esqueleto",
    CurrentValue = EspSettings.Skeletons.Enabled,
    Callback = function(Value)
        EspSettings.Skeletons.Enabled = Value
    end
})

-------------------------------------------------
-- Tracer
-------------------------------------------------

VisualTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = EspSettings.Tracers.Enabled,
    Callback = function(Value)
        EspSettings.Tracers.Enabled = Value
    end
})

---------------------------------------------------
-- FULLBRIGHT
---------------------------------------------------

VisualTab:CreateToggle({
Name = "FullBright",
CurrentValue = false,
Callback = function(Value)

if Value then
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.FogEnd = 500000
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.fromRGB(180,180,180)
Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
Lighting.ExposureCompensation = 0.3
else
Lighting.Brightness = 1
Lighting.GlobalShadows = true
Lighting.ExposureCompensation = 0
end

end
})

---------------------------------------------------
-- TURRET ESP PRO
---------------------------------------------------

local TurretESP = false
local Camera = workspace.CurrentCamera

local DrawingLines = {}
local BillboardCache = {}

local function CreateBillboard(part,text,color)

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,120,0,40)
    bill.AlwaysOnTop = true
    bill.Adornee = part
    bill.StudsOffset = Vector3.new(0,3,0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = bill

    bill.Parent = part

    return bill

end


local function GetTurrets()

    local list = {}

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Seat") or v:IsA("VehicleSeat") then
            if v.Name == "TurretSeat" then
                table.insert(list,v)
            end
        end
    end

    return list
end


RunService.RenderStepped:Connect(function()

    if not TurretESP then
        for _,l in pairs(DrawingLines) do
            l.Visible=false
        end
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local turrets = GetTurrets()

    for i,turret in pairs(turrets) do

        local color = Color3.fromRGB(255,0,0)
        local text = "TORRE"

        if turret.Occupant then
            color = Color3.fromRGB(0,255,0)
            text = "TORRE (USO)"
        end

        if not BillboardCache[turret] then
            BillboardCache[turret] = CreateBillboard(turret,text,color)
        end

        local bill = BillboardCache[turret]
        bill.TextLabel.Text = text
        bill.TextLabel.TextColor3 = color

        local pos,onscreen = Camera:WorldToViewportPoint(turret.Position)

        if onscreen then

            if not DrawingLines[i] then
                local line = Drawing.new("Line")
                line.Thickness = 2
                line.Color = Color3.fromRGB(255,0,0)
                DrawingLines[i] = line
            end

            local mypos = Camera:WorldToViewportPoint(hrp.Position)

            DrawingLines[i].From = Vector2.new(mypos.X,mypos.Y)
            DrawingLines[i].To = Vector2.new(pos.X,pos.Y)
            DrawingLines[i].Visible = true

        else

            if DrawingLines[i] then
                DrawingLines[i].Visible = false
            end

        end

    end

end)


VisualTab:CreateToggle({
Name="Turret ESP PRO",
CurrentValue=false,
Callback=function(v)
TurretESP=v
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
-- TELEPORT TURRET SEAT
---------------------------------------------------

local SelectedTurret
local TurretSeats = {}
local TurretDropdown

local function GetTurretSeats()
    local turrets = {}
    TurretSeats = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:match("TurretSeat") then
            local model = v:FindFirstAncestorOfClass("Model")
            local name = model and model.Name or v.Name
            if not table.find(turrets, name) then
                table.insert(turrets, name)
                TurretSeats[name] = v
            end
        end
    end
    return turrets
end

TurretDropdown = TeleportTab:CreateDropdown({
    Name = "TurretSeat List",
    Options = GetTurretSeats(),
    CurrentOption = nil,
    Callback = function(v)
        SelectedTurret = v[1]
    end
})

-- Atualização automática da lista
task.spawn(function()
    while task.wait(3) do
        local current = SelectedTurret
        local options = GetTurretSeats()
        
        -- Só atualiza se houver mudança na lista
        local changed = false
        if #options ~= #TurretDropdown.Options then
            changed = true
        else
            for i = 1, #options do
                if options[i] ~= TurretDropdown.Options[i] then
                    changed = true
                    break
                end
            end
        end
        
        if changed then
            TurretDropdown:Refresh(options)
            if current and table.find(options, current) then
                TurretDropdown:SetValue(current)
            end
        end
    end
end)

TeleportTab:CreateButton({
    Name = "Teleport To TurretSeat",
    Callback = function()
        if not SelectedTurret then return end
        local seat = TurretSeats[SelectedTurret]
        if seat then
            local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = seat.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

---------------------------------------------------
-- CAR ESP + TRACER (CORRIGIDO)
---------------------------------------------------

local CarESP = false
local CarESPObjects = {}

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

VisualTab:CreateToggle({
Name = "Car ESP",
CurrentValue = false,
Callback = function(v)

CarESP = v

if v then

for _,obj in pairs(workspace:GetDescendants()) do

if obj:IsA("VehicleSeat") or obj.Name == "DriveSeat" then

local model = obj:FindFirstAncestorOfClass("Model")

if model and not CarESPObjects[model] then
CreateCarESP(model,obj)
end

end

end

else

for _,data in pairs(CarESPObjects) do
if data.Gui then data.Gui:Destroy() end
if data.Line then data.Line:Remove() end
end

CarESPObjects = {}

end

end
})

local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()

if not CarESP then return end

local char = GetCharacter()
local hrp = char:FindFirstChild("HumanoidRootPart")

if not hrp then return end

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

local fromPos,fromVisible = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2,0))
local toPos,toVisible = camera:WorldToViewportPoint(seat.Position)

if fromVisible and toVisible then

line.Visible = true
line.From = Vector2.new(fromPos.X,fromPos.Y)
line.To = Vector2.new(toPos.X,toPos.Y)

else

line.Visible = false

end

end

end

end)
