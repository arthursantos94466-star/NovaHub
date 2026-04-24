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
Name="Hitbox (off)",
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
    Name = "Aimbot Roda",
    CurrentValue = false,
    Callback = function(v)
        WheelAimbot = v
        LockedWheel = nil
    end
})

CombatTab:CreateDropdown({
    Name = "Lista de Roda",
    Options = {"All","FE","FD","TE","TD"},
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
    Name = "Aimbot (Suavização)",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(v) Smoothing = v/100 end
})

CombatTab:CreateSlider({
    Name = "Precisão",
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
Name="Torre Aimbot",
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
-- TURRET ESP PRO (CORRIGIDO)
---------------------------------------------------

local TurretESP = false
local Camera = workspace.CurrentCamera

local DrawingLines = {}
local BillboardCache = {}

local function ClearTurretESP()

    for _,bill in pairs(BillboardCache) do
        if bill then
            bill:Destroy()
        end
    end

    for _,line in pairs(DrawingLines) do
        if line then
            line:Remove()
        end
    end

    BillboardCache = {}
    DrawingLines = {}

end


local function CreateBillboard(seat)

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,120,0,40)
    bill.AlwaysOnTop = true
    bill.Adornee = seat
    bill.StudsOffset = Vector3.new(0,3,0)
    bill.Name = "TurretESP"

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = bill

    bill.Parent = seat

    return bill

end


local function GetTurrets()

    local list = {}

    for _,v in pairs(workspace:GetDescendants()) do
        if (v:IsA("Seat") or v:IsA("VehicleSeat")) and v.Name == "TurretSeat" then
            table.insert(list,v)
        end
    end

    return list
end


RunService.RenderStepped:Connect(function()

    if not TurretESP then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local turrets = GetTurrets()

    for i,seat in pairs(turrets) do

        if not BillboardCache[seat] then
            BillboardCache[seat] = CreateBillboard(seat)
        end

        local bill = BillboardCache[seat]
        local label = bill:FindFirstChild("Label")

        if seat.Occupant then
            label.Text = "TORRE (USO)"
            label.TextColor3 = Color3.fromRGB(0,255,0)
        else
            label.Text = "TORRE"
            label.TextColor3 = Color3.fromRGB(255,0,0)
        end


        local pos,visible = Camera:WorldToViewportPoint(seat.Position)

        if visible then

            if not DrawingLines[i] then
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255,0,0)
                line.Thickness = 2
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
Name = "Torre ESP",
CurrentValue = false,
Callback = function(v)

    TurretESP = v

    if not v then
        ClearTurretESP()
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
Name = "Lista de Carros",
Options = GetCars(),
CurrentOption = nil,
Callback = function(v)
SelectedCar = v[1]
end
})

TeleportTab:CreateButton({
Name = "Reset Lista",
Callback = function()
CarDropdown:Refresh(GetCars())
end
})

TeleportTab:CreateButton({
Name = "Teleporte ao Carro",
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
    Name = "Lista de Torre",
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
    Name = "Teleporte Torre",
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
Name = "Carro ESP",
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

---------------------------------------------------
-- EXTRA
---------------------------------------------------

ExtraTab:CreateButton({
    Name = "Lanterna",
    Callback = function()
        -- Executa o script externo da lanterna
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Universal-Flashlight-Script-122146"))()
    end
})

-- =========================
-- DRONE PRO+ NA ABA "Extra"
-- =========================
do
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local Players = game:GetService("Players")

    local ativo = false
    local dronePos = Vector3.new()
    local lastPos = Vector3.new()
    local speedReal = 0
    local moveVector = Vector3.new()
    local lookX, lookY = 0, 0
    local zoom = 70
    local gui, light

    local color = Instance.new("ColorCorrectionEffect", game.Lighting)
    color.Enabled = false

    local function toggleNightVision()
        color.Enabled = not color.Enabled
        if color.Enabled then
            color.TintColor = Color3.fromRGB(100,255,100)
            color.Brightness = 0.2
        end
    end

    local function iniciarDrone()
        dronePos = player.Character.HumanoidRootPart.Position + Vector3.new(0,10,0)
        lastPos = dronePos

        light = Instance.new("PointLight")
        light.Brightness = 2
        light.Range = 25
        light.Enabled = false
        light.Parent = workspace.Terrain
    end

    local function criarGUI()
        gui = Instance.new("ScreenGui", player.PlayerGui)

        -- HUD TEXTO
        local hud = Instance.new("TextLabel", gui)
        hud.Size = UDim2.new(0,250,0,60)
        hud.Position = UDim2.new(0.02,0,0.02,0)
        hud.BackgroundTransparency = 1
        hud.TextColor3 = Color3.new(1,1,1)
        hud.TextXAlignment = Enum.TextXAlignment.Left

        -- BOTÕES
        local function btn(txt, pos)
            local b = Instance.new("TextButton", gui)
            b.Size = UDim2.new(0,60,0,60)
            b.Position = pos
            b.Text = txt
            b.BackgroundColor3 = Color3.fromRGB(30,30,30)
            return b
        end

        local up = btn("⬆", UDim2.new(0.85,0,0.6,0))
        local down = btn("⬇", UDim2.new(0.85,0,0.75,0))
        local lightBtn = btn("🔦", UDim2.new(0.85,0,0.88,0))
        local nightBtn = btn("🌙", UDim2.new(0.75,0,0.88,0))

        up.MouseButton1Down:Connect(function()
            moveVector += Vector3.new(0,1,0)
        end)
        down.MouseButton1Down:Connect(function()
            moveVector += Vector3.new(0,-1,0)
        end)
        lightBtn.MouseButton1Click:Connect(function()
            if light then light.Enabled = not light.Enabled end
        end)
        nightBtn.MouseButton1Click:Connect(toggleNightVision)

        -- JOYSTICK
        local base = Instance.new("Frame", gui)
        base.Size = UDim2.new(0,120,0,120)
        base.Position = UDim2.new(0.1,0,0.7,0)
        base.BackgroundColor3 = Color3.fromRGB(40,40,40)

        local stick = Instance.new("Frame", base)
        stick.Size = UDim2.new(0,50,0,50)
        stick.Position = UDim2.new(0.5,-25,0.5,-25)

        local dragging = false

        base.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then dragging = true end
        end)
        base.InputEnded:Connect(function(input)
            dragging = false
            stick.Position = UDim2.new(0.5,-25,0.5,-25)
            moveVector = Vector3.new()
        end)
        base.InputChanged:Connect(function(input)
            if dragging then
                local pos = input.Position
                local center = base.AbsolutePosition + base.AbsoluteSize/2
                local offset = (pos - center)
                local max = 40
                local clamped = Vector2.new(
                    math.clamp(offset.X,-max,max),
                    math.clamp(offset.Y,-max,max)
                )
                stick.Position = UDim2.new(0.5,clamped.X-25,0.5,clamped.Y-25)
                moveVector = Vector3.new(clamped.X/max,0,clamped.Y/max)
            end
        end)

        -- =========================
        -- MINI MAPA
        -- =========================
        local map = Instance.new("Frame", gui)
        map.Size = UDim2.new(0,150,0,150)
        map.Position = UDim2.new(0.8,0,0.02,0)
        map.BackgroundColor3 = Color3.fromRGB(20,20,20)

        local points = {}
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local dot = Instance.new("Frame", map)
                dot.Size = UDim2.new(0,5,0,5)
                dot.BackgroundColor3 = Color3.new(1,0,0)
                points[p] = dot
            end
        end
        Players.PlayerAdded:Connect(function(p)
            local dot = Instance.new("Frame", map)
            dot.Size = UDim2.new(0,5,0,5)
            dot.BackgroundColor3 = Color3.new(1,0,0)
            points[p] = dot
        end)

        -- LOOP HUD + MAPA
        RunService.RenderStepped:Connect(function(dt)
            if ativo then
                local altitude = math.floor(dronePos.Y)
                speedReal = (dronePos - lastPos).Magnitude / dt
                lastPos = dronePos
                hud.Text = "ALT: "..altitude.." | SPD: "..math.floor(speedReal)

                for p,dot in pairs(points) do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = p.Character.HumanoidRootPart.Position
                        local rel = (pos - dronePos)/10
                        dot.Position = UDim2.new(0.5 + rel.X/100,0,0.5 + rel.Z/100,0)
                    end
                end
            end
        end)
    end

    -- =========================
    -- ATIVAR / DESATIVAR
    -- =========================
    local function ativar()
        ativo = true
        iniciarDrone()
        criarGUI()
        camera.CameraType = Enum.CameraType.Scriptable
    end

    local function desativar()
        ativo = false
        camera.CameraType = Enum.CameraType.Custom
        if gui then gui:Destroy() gui = nil end
        if light then light:Destroy() light = nil end
        color.Enabled = false
    end

    -- =========================
    -- CONTROLE DE CÂMERA
    -- =========================
    UIS.InputChanged:Connect(function(input)
        if ativo and input.UserInputType == Enum.UserInputType.Touch then
            lookX -= input.Delta.X * 0.2
            lookY = math.clamp(lookY - input.Delta.Y * 0.2, -80, 80)
        end
    end)

    -- =========================
    -- LOOP PRINCIPAL
    -- =========================
    RunService.RenderStepped:Connect(function()
        if ativo then
            local rot = CFrame.Angles(0, math.rad(lookX), 0) * CFrame.Angles(math.rad(lookY),0,0)
            dronePos += rot:VectorToWorldSpace(moveVector)
            camera.CFrame = CFrame.new(dronePos) * rot
            camera.FieldOfView = zoom
            if light then light.Position = dronePos end
        end
    end)

    -- =========================
    -- BOTÃO NA ABA "Extra"
    -- =========================
    ExtraTab:CreateButton({
        Name = "Drone (Atualizando)",
        Callback = function()
            if ativo then
                desativar()
            else
                ativar()
            end
        end
    })
end

---------------------------------------------------
-- ABA ADMIN EXCLUSIVA PARA MOBILE (yFrost)
---------------------------------------------------

-- Trava de segurança para seu ID
if game:GetService("Players").LocalPlayer.UserId == 2980742903 then
    
    -- Criação da Tab Admin
    local AdminTab = Window:CreateTab("🛡️ Master Admin", 4483345998)
    local TargetID = "" 

    -- GESTÃO DE KEYS
    AdminTab:CreateSection("🔑 Keys")
    AdminTab:CreateInput({
        Name = "UserID do Player",
        PlaceholderText = "Digite o ID aqui...",
        Callback = function(v) TargetID = v end
    })
    AdminTab:CreateButton({Name = "Gerar Key", Callback = function() print("Gerar: "..TargetID) end})
    AdminTab:CreateButton({Name = "Validar Key", Callback = function() end})
    AdminTab:CreateButton({Name = "Remover Key", Callback = function() end})
    AdminTab:CreateButton({Name = "Resetar Keys", Callback = function() end})
    AdminTab:CreateButton({Name = "Listar Keys", Callback = function() end})
    AdminTab:CreateButton({Name = "Definir Tempo Key", Callback = function() end})

    -- SEGURANÇA & DATABASE
    AdminTab:CreateSection("🚫 Segurança")
    AdminTab:CreateButton({
        Name = "Criar Usuário (Copia Código)",
        Callback = function()
            local code = '["'..TargetID..'"] = {["Nick"]="N/A",["Display"]="N/A",["Status"]="Active",["Level"]="User",["Expires"]="Never",["ResetRequired"]=false}'
            setclipboard(code)
            Rayfield:Notify({Title="Copiado!", Content="Cole no database do GitHub.", Duration=5})
        end
    })
    AdminTab:CreateButton({Name = "Adicionar Whitelist", Callback = function() end})
    AdminTab:CreateButton({Name = "Remover Whitelist", Callback = function() end})
    AdminTab:CreateButton({Name = "Adicionar Blacklist", Callback = function() end})
    AdminTab:CreateButton({Name = "Remover Blacklist", Callback = function() end})

    -- STAFF
    AdminTab:CreateSection("👑 Staff")
    AdminTab:CreateButton({Name = "Definir Admin", Callback = function() end})
    AdminTab:CreateButton({Name = "Remover Admin", Callback = function() end})
    AdminTab:CreateButton({Name = "Ver Admins", Callback = function() end})
    AdminTab:CreateButton({Name = "Ver Online", Callback = function() 
        Rayfield:Notify({Title="Online", Content="Total: "..#game.Players:GetPlayers(), Duration=3}) 
    end})

    -- FUNÇÕES DO HUB
    AdminTab:CreateSection("⚙️ Controle")
    AdminTab:CreateButton({Name = "Ativar Função", Callback = function() end})
    AdminTab:CreateButton({Name = "Desativar Função", Callback = function() end})
    AdminTab:CreateButton({Name = "Ver Funções", Callback = function() end})
    AdminTab:CreateButton({Name = "Resetar Funções", Callback = function() end})

    -- SISTEMA
    AdminTab:CreateSection("📑 Sistema")
    AdminTab:CreateButton({Name = "Ver Logs (F9)", Callback = function() end})
    AdminTab:CreateButton({Name = "Limpar Logs", Callback = function() print("\14") end})
    AdminTab:CreateButton({Name = "Abrir Painel", Callback = function() end})
    AdminTab:CreateButton({Name = "Fechar Painel", Callback = function() Rayfield:Destroy() end})
    AdminTab:CreateButton({Name = "Minimizar Painel", Callback = function() end})
    AdminTab:CreateButton({
        Name = "Sincronizar Cloud",
        Callback = function()
            loadstring(game:HttpGet("https://githubusercontent.com"))()
            Rayfield:Notify({Title="Sincronizado", Content="Cloud OK!", Duration=3})
        end
    })

    ---------------------------------------------------
    -- BOTÃO FLUTUANTE (MÓVEL)
    ---------------------------------------------------
    local ScreenGui = Instance.new("ScreenGui")
    local OpenBtn = Instance.new("ImageButton")
    ScreenGui.Parent = game:GetService("CoreGui")
    OpenBtn.Parent = ScreenGui
    OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    OpenBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Image = "rbxassetid://4483345998"
    OpenBtn.Draggable = true
    OpenBtn.Active = true
    local UICorner = Instance.new("UICorner", OpenBtn)
    UICorner.CornerRadius = UDim.new(0, 10)
end
