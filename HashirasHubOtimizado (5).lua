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

-- Função utilitária para disparar ProximityPrompt com segurança e teleportar
local function FirePromptAt(instance, teleportBack)
    if not instance or not instance:IsA("ProximityPrompt") then return false end
    local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local originalPos = hrp.CFrame
    local targetParent = instance:FindFirstAncestorOfClass("BasePart") or instance.Parent

    if targetParent and targetParent:IsA("BasePart") then
        hrp.CFrame = targetParent.CFrame
    elseif targetParent and targetParent:FindFirstChildOfClass("BasePart") then
        hrp.CFrame = targetParent:FindFirstChildOfClass("BasePart").CFrame
    else
        return false
    end

    task.wait(0.25) -- Delay seguro para Mobile Studio Lite computar a física
    fireproximityprompt(instance)

    if teleportBack then
        task.wait(0.15)
        hrp.CFrame = originalPos
    end
    return true
end

---------------------------------------------------
-- TABS
---------------------------------------------------

local CombatTab = Window:CreateTab("Combat",4483362458)
local MovementTab = Window:CreateTab("Movement",4483362458)
local AutoFarmTab = Window:CreateTab("Auto Farm",4483362458)
local VisualTab = Window:CreateTab("Visual",4483362458)
local TeleportTab = Window:CreateTab("Teleport",4483362458)
local ServerTab = Window:CreateTab("Server",4483362458)
local ExtraTab = Window:CreateTab("Extra",4483362458)

---------------------------------------------------
-- COMBAT
---------------------------------------------------

CombatTab:CreateButton({
    Name = "Aimbot (External)", 
    Callback = function()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Aimbot-universal-111551"))()
    end
})

CombatTab:CreateButton({
   Name = "Hitbox (V5 Universal)",
   Callback = function()
       loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Hitbox-V5-108660"))()
   end
})

---------------------------------------------------
-- REQUISITO 1: WHEEL AIMBOT PRO (CORRIGIDO E OTIMIZADO)
---------------------------------------------------

local WheelAimbot = false
local WheelTarget = "ALL" -- Usa as opções do seletor nativo: "ALL", "FL", "FR", "RL", "RR"
local FOV = 250
local MaxDistance = 500
local Prediction = 0.12
local Smoothing = 0.15 

local LockedWheel = nil
local camera = workspace.CurrentCamera

-- Verifica se a linha de visão está livre até a roda (Wall Check)
local function IsVisibleWithWallCheck(part)
    if not part then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    
    local pos, visible = camera:WorldToViewportPoint(part.Position)
    if not visible then return false end

    -- Raycast para checar obstruções físicas entre a câmera e a roda
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, part.Parent}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance and not result.Instance:IsDescendantOf(part.Parent) then
        return false -- Bloqueado por parede ou objeto externo
    end
    return true
end

local function IsVehicleOccupied(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if not model then return false end
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant then return true end
    end
    return false
end

local function IsValidTarget(part)
    if not part or not part.Parent or not part:IsA("BasePart") then return false end
    
    -- Seletor específico de nome de roda
    if WheelTarget ~= "ALL" and part.Name ~= WheelTarget then return false end
    
    local pos, visible = camera:WorldToViewportPoint(part.Position)
    if not visible then return false end
    
    if not IsVisibleWithWallCheck(part) then return false end
    
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local dist2D = (center - Vector2.new(pos.X, pos.Y)).Magnitude
    local dist3D = (camera.CFrame.Position - part.Position).Magnitude
    
    return dist2D <= FOV and dist3D <= MaxDistance
end

-- Busca a roda válida mais próxima baseada nos filtros ativos
local function GetClosestWheel()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    -- Varre os veículos do workspace respeitando a estrutura do jogo
    local vehiclesFolder = workspace:FindFirstChild("vehicles")
    if vehiclesFolder then
        for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
            local wheels = vehicle:FindFirstChild("Wheels")
            if wheels then
                for _, wheel in pairs(wheels:GetChildren()) do
                    if wheel:IsA("BasePart") then
                        -- Valida se corresponde ao filtro do dropdown ("ALL" ou nome exato "FL", "FR" etc.)
                        if WheelTarget == "ALL" or wheel.Name == WheelTarget then
                            if IsValidTarget(wheel) then
                                local pos = camera:WorldToViewportPoint(wheel.Position)
                                local dist2D = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                                
                                local priority = IsVehicleOccupied(wheel) and 0.5 or 1
                                local finalDist = dist2D * priority

                                if finalDist < closestDist then
                                    closestDist = finalDist
                                    closest = wheel
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

CombatTab:CreateToggle({
    Name = "Aimbot Roda",
    CurrentValue = false,
    Callback = function(v)
        WheelAimbot = v
        LockedWheel = nil
    end
})

-- Modificado para aceitar exatamente os parâmetros solicitados usando o dropdown existente
CombatTab:CreateDropdown({
    Name = "Lista de Roda",
    Options = {"ALL", "FL", "FR", "RL", "RR"},
    CurrentOption = {"ALL"},
    Callback = function(opt)
        WheelTarget = type(opt) == "table" and opt[1] or opt
        LockedWheel = nil
    end
})

CombatTab:CreateSlider({ Name = "Aimbot FOV", Range = {50, 600}, Increment = 10, CurrentValue = 250, Callback = function(v) FOV = v end })
CombatTab:CreateSlider({ Name = "Aimbot (Suavização)", Range = {1, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) Smoothing = v/100 end })
CombatTab:CreateSlider({ Name = "Precisão", Range = {0, 30}, Increment = 1, CurrentValue = 12, Callback = function(v) Prediction = v/100 end })

RunService.RenderStepped:Connect(function()
    if not WheelAimbot then 
        LockedWheel = nil 
        return 
    end

    if not LockedWheel or not IsValidTarget(LockedWheel) then
        LockedWheel = GetClosestWheel()
    end

    if LockedWheel then
        local velocity = LockedWheel.AssemblyLinearVelocity or Vector3.zero
        local predictedPos = LockedWheel.Position + (velocity * Prediction)
        local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPos)
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
            if TeamCheck and p.Team==LocalPlayer.Team then continue end
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            local head=p.Character:FindFirstChild("Head")
            if hum and head then
                if hum.Sit and hum.SeatPart and hum.SeatPart.Name=="TurretSeat" then
                    local d=(camera.CFrame.Position-head.Position).Magnitude
                    if d<dist then dist=d closest=head end
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
    local camPos=camera.CFrame.Position
    local aimCF=CFrame.new(camPos,target.Position)
    camera.CFrame=camera.CFrame:Lerp(aimCF,Smoothness)
end)

CombatTab:CreateToggle({ Name="Torre Aimbot", CurrentValue=false, Callback=function(v) TurretAimbot=v end })

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
-- REQUISITO 2: AUTO FARM DE ARMAS DINÂMICO
---------------------------------------------------

local SelectedWeaponName = ""
local WeaponDataMap = {} -- Guarda a referência { [Nome] = InstanciaProximityPrompt }

local WeaponDropdown = AutoFarmTab:CreateDropdown({
    Name = "Lista de Armas [GRUPO J]",
    Options = {"Carregando..."},
    CurrentOption = nil,
    Callback = function(v)
        SelectedWeaponName = type(v) == "table" and v[1] or v
    end
})

-- Faz uma varredura recursiva de filhos buscando os ProximityPrompts válidos
local function ScanWeaponsRecursively()
    local options = {}
    WeaponDataMap = {}
    
    local grupoJ = workspace:FindFirstChild("Armas") and workspace.Armas:FindFirstChild("GRUPO J")
    if grupoJ then
        for _, descendant in pairs(grupoJ:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local nameText = descendant.ActionText
                if nameText and nameText ~= "" and not WeaponDataMap[nameText] then
                    table.insert(options, nameText)
                    WeaponDataMap[nameText] = descendant
                end
            end
        end
    end
    
    if #options == 0 then 
        table.insert(options, "Nenhuma Arma Encontrada") 
    end
    WeaponDropdown:Refresh(options)
end

AutoFarmTab:CreateButton({
    Name = "Atualizar Lista de Armas",
    Callback = function() 
        ScanWeaponsRecursively() 
    end
})

AutoFarmTab:CreateButton({
    Name = "Equipar Arma",
    Callback = function()
        if SelectedWeaponName == "" or SelectedWeaponName == "Nenhuma Arma Encontrada" then
            Rayfield:Notify({Title = "Erro", Content = "Selecione uma arma válida na lista!", Duration = 3})
            return 
        end
        
        local prompt = WeaponDataMap[SelectedWeaponName]
        if prompt and prompt.Parent then
            local success = FirePromptAt(prompt, false)
            if not success then
                Rayfield:Notify({Title = "Erro", Content = "Destino ou Prompt indisponível para teleporte.", Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Erro", Content = "Arma não encontrada ou indisponível no momento.", Duration = 3})
        end
    end
})

---------------------------------------------------
-- REQUISITO 3: AUTO FARM DE KITS MÉDICOS (CORRIGIDO)
---------------------------------------------------

AutoFarmTab:CreateButton({
    Name = "Pegar Medkit Regular (Volta ao Lugar)",
    Callback = function()
        local medkitFolder = workspace:FindFirstChild("PIPSAS") and workspace.PIPSAS:FindFirstChild("Medkit Regular")
        local foundPrompt = nil
        
        if medkitFolder then
            -- Busca prioritária pelo nome do prompt ao invés de índice fixo
            foundPrompt = medkitFolder:FindFirstChild("ShopPrompt", true)
            if not foundPrompt then
                -- Fallback recursivo seguro se o índice mudou mas o objeto existe
                for _, child in pairs(medkitFolder:GetChildren()) do
                    local p = child:FindFirstChild("ShopPrompt") or (child:IsA("ProximityPrompt") and child.Name == "ShopPrompt" and child)
                    if p then foundPrompt = p break end
                end
            end
        end

        if foundPrompt then
            FirePromptAt(foundPrompt, true)
        else
            Rayfield:Notify({Title = "Erro de Carregamento", Content = "Não foi possível localizar o ShopPrompt do Medkit Regular.", Duration = 3})
        end
    end
})

AutoFarmTab:CreateButton({
    Name = "Pegar Medkit Caro Rojo (Volta ao Lugar)",
    Callback = function()
        local medkitCaro = workspace:FindFirstChild("PIPSAS") and workspace.PIPSAS:FindFirstChild("Medkit Caro")
        local rojo = medkitCaro and medkitCaro:FindFirstChild("Rojo")
        local foundPrompt = rojo and rojo:FindFirstChild("ShopPrompt")
        
        if not foundPrompt and medkitCaro then
            -- Procura redundante caso a estrutura sofra alterações dinâmicas de hierarquia
            foundPrompt = medkitCaro:FindFirstChild("ShopPrompt", true)
        end

        if foundPrompt then
            FirePromptAt(foundPrompt, true)
        else
            Rayfield:Notify({Title = "Erro de Carregamento", Content = "Não foi possível localizar o ShopPrompt do Medkit Caro.", Duration = 3})
        end
    end
})

AutoFarmTab:CreateButton({
    Name = "Disparar Dealers [GRUPO J] (Interaction)",
    Callback = function()
        local dealer = workspace:FindFirstChild("dealers") and workspace.dealers:FindFirstChild("GRUPO J")
        if dealer and dealer:FindFirstChild("Interaction") then
            local prompt = dealer.Interaction:FindFirstChildOfClass("ProximityPrompt") or dealer.Interaction
            if prompt:IsA("ProximityPrompt") then
                FirePromptAt(prompt, false)
            else
                Rayfield:Notify({Title = "Erro", Content = "Interaction não possui ProximityPrompt válido.", Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Erro", Content = "Dealer ou Interaction indisponível.", Duration = 3})
        end
    end
})

-- Inicializa a lista de armas dinamicamente ao carregar o script
task.spawn(ScanWeaponsRecursively)

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
local DrawingLines = {}
local BillboardCache = {}

local function ClearTurretESP()
    for _,bill in pairs(BillboardCache) do if bill then bill:Destroy() end end
    for _,line in pairs(DrawingLines) do if line then line:Remove() end end
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
        if (v:IsA("Seat") or v:IsA("VehicleSeat")) and v.Name == "TurretSeat" then table.insert(list,v) end
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
        if not BillboardCache[seat] then BillboardCache[seat] = CreateBillboard(seat) end
        local bill = BillboardCache[seat]
        local label = bill:FindFirstChild("Label")

        if seat.Occupant then
            label.Text = "TORRE (USO)"
            label.TextColor3 = Color3.fromRGB(0,255,0)
        else
            label.Text = "TORRE"
            label.TextColor3 = Color3.fromRGB(255,0,0)
        end

        local pos,visible = camera:WorldToViewportPoint(seat.Position)
        if visible then
            if not DrawingLines[i] then
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255,0,0)
                line.Thickness = 2
                DrawingLines[i] = line
            end
            local mypos = camera:WorldToViewportPoint(hrp.Position)
            DrawingLines[i].From = Vector2.new(mypos.X,mypos.Y)
            DrawingLines[i].To = Vector2.new(pos.X,pos.Y)
            DrawingLines[i].Visible = true
        else
            if DrawingLines[i] then DrawingLines[i].Visible = false end
        end
    end
end)

VisualTab:CreateToggle({ Name = "Torre ESP", CurrentValue = false, Callback = function(v) TurretESP = v if not v then ClearTurretESP() end end })

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
            if not table.find(cars, carName) then table.insert(cars, carName) CarSeats[carName] = v end
        end
    end
end
return cars
end

local CarDropdown = TeleportTab:CreateDropdown({
Name = "Lista de Carros",
Options = GetCars(),
CurrentOption = nil,
Callback = function(v) SelectedCar = type(v) == "table" and v[1] or v end
})

TeleportTab:CreateButton({ Name = "Reset Lista", Callback = function() CarDropdown:Refresh(GetCars()) end })
TeleportTab:CreateButton({
Name = "Teleporte ao Carro",
Callback = function()
if not SelectedCar then return end
local seat = CarSeats[SelectedCar]
if seat then
local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
if hrp then hrp.CFrame = seat.CFrame + Vector3.new(0,3,0) end
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
            if not table.find(turrets, name) then table.insert(turrets, name) TurretSeats[name] = v end
        end
    end
    return turrets
end

TurretDropdown = TeleportTab:CreateDropdown({
    Name = "Lista de Torre",
    Options = GetTurretSeats(),
    CurrentOption = nil,
    Callback = function(v) SelectedTurret = type(v) == "table" and v[1] or v end
})

task.spawn(function()
    while task.wait(3) do
        local current = SelectedTurret
        local options = GetTurretSeats()
        local changed = false
        if #options ~= #TurretDropdown.Options then changed = true else
            for i = 1, #options do if options[i] ~= TurretDropdown.Options[i] then changed = true break end end
        end
        if changed then
            TurretDropdown:Refresh(options)
            if current and table.find(options, current) then TurretDropdown:SetValue(current) end
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
            if hrp then hrp.CFrame = seat.CFrame + Vector3.new(0, 3, 0) end
        end
    end
})

---------------------------------------------------
-- CAR ESP + TRACER
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

CarESPObjects[model] = { Gui = billboard, Text = text, Seat = seat, Line = line }
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
if model and not CarESPObjects[model] then CreateCarESP(model,obj) end
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
if occupied then text.TextColor3 = Color3.fromRGB(255,60,60) else text.TextColor3 = Color3.fromRGB(60,255,60) end
text.Text = model.Name.." ["..distance.."m]"
local fromPos,fromVisible = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2,0))
local toPos,toVisible = camera:WorldToViewportPoint(seat.Position)
if fromVisible and toVisible then
line.Visible = true line.From = Vector2.new(fromPos.X,fromPos.Y) line.To = Vector2.new(toPos.X,toPos.Y)
else line.Visible = false end
end
end
end)
