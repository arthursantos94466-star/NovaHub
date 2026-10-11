-- Rayfield Framework unificado para Delta Executor (Mobile)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

---------------------------------------------------
-- SISTEMA DE IDIOMAS & TRADUÇÃO CENTRALIZADA
---------------------------------------------------
local CurrentLanguage = "pt_br"
local Localization = {
    pt_br = {
        HubName = "Hashiras Hub", Loading = "Carregando...", EnterKey = "Insira a Chave", Note = "Hub está em beta, pode ter erros.",
        Combat = "Combat", Movement = "Movement", AutoFarm = "Auto Farm", Visual = "Visual", Teleport = "Teleport", Config = "Configuração", Extra = "Extra",
        AimbotExt = "Aimbot (External)", Hitbox = "Hitbox (V5 Universal)", WheelAim = "Aimbot Roda", WheelList = "Lista de Roda",
        WeaponList = "Lista de Armas", EquipWeap = "Equipar Arma", MedRegular = "Pegar Medkit Regular", MedCaro = "Pegar Medkit Caro",
        CarShop = "Loja de Carros", TurretESP = "Torre ESP", ESPDist = "Distância do ESP", Bright = "FullBright",
        CarList = "Lista de Carros", ResetList = "Reset Lista", TeleCar = "Teleporte ao Carro", TurretList = "Lista de Torre", TeleTurret = "Teleporte Torre",
        CarESP = "Carro ESP", LangSelect = "Selecionar Idioma", Performance = "Otimizar Desempenho (Reduzir FPS Lag)", ItemNotFound = "Item não encontrado",
        TourUse = "TORRE [USO]", TourFree = "TORRE",
    },
    en = {
        HubName = "Hashiras Hub", Loading = "Loading...", EnterKey = "Enter Key", Note = "Hub is in beta, may contain bugs.",
        Combat = "Combat", Movement = "Movement", AutoFarm = "Auto Farm", Visual = "Visual", Teleport = "Teleport", Config = "Configuration", Extra = "Extra",
        AimbotExt = "Aimbot (External)", Hitbox = "Hitbox (V5 Universal)", WheelAim = "Wheel Aimbot", WheelList = "Wheel List",
        WeaponList = "Weapon List", EquipWeap = "Equip Weapon", MedRegular = "Get Regular Medkit", MedCaro = "Get Expensive Medkit",
        CarShop = "Car Shop", TurretESP = "Turret ESP", ESPDist = "ESP Distance", Bright = "FullBright",
        CarList = "Car List", ResetList = "Reset List", TeleCar = "Teleport to Car", TurretList = "Turret List", TeleTurret = "Teleport to Turret",
        CarESP = "Car ESP", LangSelect = "Select Language", Performance = "Optimize Performance (Reduce Lag)", ItemNotFound = "Item not found",
        TourUse = "TURRET [IN USE]", TourFree = "TURRET",
    },
    es = {
        HubName = "Hashiras Hub", Loading = "Cargando...", EnterKey = "Ingresar Clave", Note = "Hub está en beta, puede tener errores.",
        Combat = "Combat", Movement = "Movement", AutoFarm = "Auto Farm", Visual = "Visual", Teleport = "Teleport", Config = "Configuración", Extra = "Extra",
        AimbotExt = "Aimbot (External)", Hitbox = "Hitbox (V5 Universal)", WheelAim = "Aimbot Rueda", WheelList = "Lista de Ruedas",
        WeaponList = "Lista de Armas", EquipWeap = "Equipar Arma", MedRegular = "Recoger Medkit Regular", MedCaro = "Recoger Medkit Caro",
        CarShop = "Tienda de Autos", TurretESP = "Torre ESP", ESPDist = "Distancia de ESP", Bright = "FullBright",
        CarList = "Lista de Autos", ReiniciarList = "Reiniciar Lista", TeleCar = "Teletransporte ao Auto", TurretList = "Lista de Torres", TeleTurret = "Teletransporte a Torre",
        CarESP = "ESP de Autos", LangSelect = "Seleccionar Idioma", Performance = "Optimizar Rendimiento (Menos Lag)", ItemNotFound = "Item no encontrado",
        TourUse = "TORRE [EN USO]", TourFree = "TORRE",
    }
}

local UI_Objects = {}

local function T(key)
    return Localization[CurrentLanguage][key] or Localization["pt_br"][key]
end

---------------------------------------------------
-- SERVICES & CONSTANTS
---------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MEDKIT_SHOP_CFRAME = CFrame.new(
    -840.591553, 102.522545, -387.653351,
    0.671570599, 1.87319991e-08, -0.740940571,
    5.53272521e-08, 1, 7.54286589e-08,
    0.740940571, -9.16498806e-08, 0.671570599
)

local SupportedTeams = {
    "AIC", "CFE", "DEA", "EJERCITO", "GN", "GOPES", 
    "GRUPO G", "GRUPO J", "GRUPO M", "GRUPO N", "MARINA", "POLICIA ESTATAL"
}

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function ShowErrorNotification()
    Rayfield:Notify({
        Title = "Info",
        Content = T("ItemNotFound"),
        Duration = 3,
        Image = 4483362458,
    })
end

local function FirePromptAt(instance, teleportBack)
    if not instance or not instance:IsA("ProximityPrompt") then 
        ShowErrorNotification()
        return 
    end
    
    local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local originalPos = hrp.CFrame
    local targetPart = instance:FindFirstAncestorOfClass("BasePart") or instance.Parent:FindFirstChildOfClass("BasePart")

    if targetPart then
        hrp.CFrame = targetPart.CFrame
        task.wait(0.2)
        fireproximityprompt(instance)
        
        if teleportBack then
            task.wait(0.1)
            hrp.CFrame = originalPos
        end
    else
        ShowErrorNotification()
    end
end

local function GetCurrentTeamName()
    if LocalPlayer.Team then
        local teamName = LocalPlayer.Team.Name
        if table.find(SupportedTeams, teamName) then
            return teamName
        end
    end
    return "GRUPO J"
end

---------------------------------------------------
-- CRIAÇÃO DA JANELA PRINCIPAL
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = T("HubName"), LoadingTitle = T("HubName"), LoadingSubtitle = "Rayfield Mobile",
    ConfigurationSaving = {Enabled = false}, KeySystem = true,
    KeySettings = {
        Title = T("HubName"), Subtitle = T("EnterKey"), Note = T("Note"), SaveKey = true, Key = {"Hashiras123"}
    }
})

local CombatTab = Window:CreateTab(T("Combat"), 4483362458)
local MovementTab = Window:CreateTab(T("Movement"), 4483362458)
local AutoFarmTab = Window:CreateTab(T("Auto Farm"), 4483362458)
local VisualTab = Window:CreateTab(T("Visual"), 4483362458)
local TeleportTab = Window:CreateTab(T("Teleport"), 4483362458)
local ConfigTab = Window:CreateTab(T("Config"), 4483362458)
local ExtraTab = Window:CreateTab(T("Extra"), 4483362458)

---------------------------------------------------
-- CORREÇÃO: AIMBOT DE RODAS
---------------------------------------------------
local WheelAimbot = false
local WheelTarget = "ALL"
local FOV = 250
local MaxDistance = 500
local Prediction = 0.12
local Smoothing = 0.15 

local LockedWheel = nil
local camera = workspace.CurrentCamera

local function IsVisibleWithWallCheck(part)
    if not part then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    
    local origin = camera.CFrame.Position
    local destination = part.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, camera}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if not raycastResult or raycastResult.Instance:IsAncestorOf(part.Parent) then
        return true
    end
    return false
end

local function IsValidTarget(part)
    if not part or not part.Parent then return false end
    
    local pos, visible = camera:WorldToViewportPoint(part.Position)
    if not visible then return false end
    if not IsVisibleWithWallCheck(part) then return false end
    
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local dist2D = (center - Vector2.new(pos.X, pos.Y)).Magnitude
    local dist3D = (camera.CFrame.Position - part.Position).Magnitude
    
    return dist2D <= FOV and dist3D <= MaxDistance
end

local function GetClosestWheel()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    local vehiclesFolder = workspace:FindFirstChild("vehicles")
    if not vehiclesFolder then return nil end

    for _, car in pairs(vehiclesFolder:GetChildren()) do
        local wheels = car:FindFirstChild("Wheels")
        if wheels then
            for _, wPart in pairs(wheels:GetChildren()) do
                if wPart:IsA("BasePart") then
                    local matchTarget = (WheelTarget == "ALL" or wPart.Name == WheelTarget)
                    if matchTarget and IsValidTarget(wPart) then
                        local pos = camera:WorldToViewportPoint(wPart.Position)
                        local dist2D = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                        
                        if dist2D < closestDist then
                            closestDist = dist2D
                            closest = wPart
                        end
                    end
                end
            end
        end
    end
    return closest
end

CombatTab:CreateButton({ Name = T("AimbotExt"), Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Aimbot-universal-111551"))() end })
CombatTab:CreateButton({ Name = T("Hitbox"), Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Hitbox-V5-108660"))() end })

UI_Objects.WheelAim = CombatTab:CreateToggle({
    Name = T("WheelAim"), CurrentValue = false, Callback = function(v) WheelAimbot = v LockedWheel = nil end
})

CombatTab:CreateDropdown({
    Name = T("WheelList"), Options = {"ALL", "FL", "FR", "RL", "RR"}, CurrentOption = {"ALL"},
    Callback = function(opt)
        WheelTarget = type(opt) == "table" and opt[1] or opt
        LockedWheel = nil
    end
})

CombatTab:CreateSlider({ Name = "Aimbot FOV", Range = {50, 600}, Increment = 10, CurrentValue = 250, Callback = function(v) FOV = v end })
CombatTab:CreateSlider({ Name = "Aimbot (Suavização)", Range = {1, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) Smoothing = v/100 end })

RunService.RenderStepped:Connect(function()
    if not WheelAimbot then LockedWheel = nil return end
    if not LockedWheel or not IsValidTarget(LockedWheel) then LockedWheel = GetClosestWheel() end
    if LockedWheel then
        local velocity = LockedWheel.AssemblyLinearVelocity
        local predictedPos = LockedWheel.Position + (velocity * Prediction)
        local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, Smoothing)
    end
end)

---------------------------------------------------
-- TURRET AIMBOT PRO
---------------------------------------------------
local TurretAimbot = false
local TeamCheck = true
local Smoothness = 0.15

local function GetTurretTarget()
    local closest = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if TeamCheck and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            if hum and head then
                if hum.Sit and hum.SeatPart and hum.SeatPart.Name == "TurretSeat" then
                    local d = (camera.CFrame.Position - head.Position).Magnitude
                    if d < dist then dist = d closest = head end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not TurretAimbot then return end
    local target = GetTurretTarget()
    if target then
        local aimCF = CFrame.new(camera.CFrame.Position, target.Position)
        camera.CFrame = camera.CFrame:Lerp(aimCF, Smoothness)
    end
end)

CombatTab:CreateToggle({ Name = T("TurretAimbot") or "Torre Aimbot", CurrentValue = false, Callback = function(v) TurretAimbot = v end })

---------------------------------------------------
-- MOVEMENT
---------------------------------------------------
local WalkSpeedValue = 16
local WalkSpeedEnabled = false

MovementTab:CreateSlider({
    Name = "WalkSpeed", Range = {0,200}, Increment = 1, CurrentValue = 16,
    Callback = function(v) WalkSpeedValue = v WalkSpeedEnabled = true end
})

task.spawn(function()
    while task.wait(0.5) do
        if WalkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= WalkSpeedValue then hum.WalkSpeed = WalkSpeedValue end
        end
    end
end)

---------------------------------------------------
-- AUTO FARM
---------------------------------------------------
local SelectedWeapon = ""
local WeaponMap = {}

local WeaponDropdown = AutoFarmTab:CreateDropdown({
    Name = T("WeaponList"), Options = {T("Loading")}, CurrentOption = nil,
    Callback = function(v) SelectedWeapon = type(v) == "table" and v[1] or v end
})

local function RefreshWeaponList()
    local options = {}
    WeaponMap = {}
    local weaponsFolder = workspace:FindFirstChild("Armas")
    
    if weaponsFolder then
        for _, descendant in pairs(weaponsFolder:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.ActionText ~= "" then
                local weaponName = descendant.ActionText
                if not WeaponMap[weaponName] then
                    table.insert(options, weaponName)
                    WeaponMap[weaponName] = descendant
                end
            end
        end
    end
    if #options == 0 then table.insert(options, T("ItemNotFound")) end
    WeaponDropdown:Refresh(options)
end

task.spawn(RefreshWeaponList)

workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") and desc:IsDescendantOf(workspace:FindFirstChild("Armas")) then
        task.wait(0.5)
        RefreshWeaponList()
    end
end)

AutoFarmTab:CreateButton({
    Name = T("EquipWeap"),
    Callback = function()
        if SelectedWeapon ~= "" and WeaponMap[SelectedWeapon] then
            FirePromptAt(WeaponMap[SelectedWeapon], false)
        else
            ShowErrorNotification()
        end
    end
})

AutoFarmTab:CreateButton({
    Name = T("MedRegular"),
    Callback = function()
        local pipsas = workspace:FindFirstChild("PIPSAS")
        local medkitFolder = pipsas and pipsas:FindFirstChild("Medkit Regular")
        local foundPrompt = medkitFolder and medkitFolder:FindFirstChild("ShopPrompt", true)
        
        if foundPrompt and foundPrompt:IsA("ProximityPrompt") then
            FirePromptAt(foundPrompt, true)
        else
            ShowErrorNotification()
        end
    end
})

AutoFarmTab:CreateButton({
    Name = T("MedCaro"),
    Callback = function()
        local pipsas = workspace:FindFirstChild("PIPSAS")
        local medkitCaro = pipsas and pipsas:FindFirstChild("Medkit Caro")
        local targetPrompt = medkitCaro and medkitCaro:FindFirstChild("ShopPrompt", true)

        if targetPrompt and targetPrompt:IsA("ProximityPrompt") then
            FirePromptAt(targetPrompt, true)
        else
            local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
            if hrp then
                local originalCFrame = hrp.CFrame
                hrp.CFrame = MEDKIT_SHOP_CFRAME
                
                local timeout = 0
                while timeout < 20 and not (pipsas and pipsas:FindFirstChild("Medkit Caro") and pipsas["Medkit Caro"]:FindFirstChild("ShopPrompt", true)) do
                    task.wait(0.1)
                    pipsas = workspace:FindFirstChild("PIPSAS")
                    timeout = timeout + 1
                end

                medkitCaro = pipsas and pipsas:FindFirstChild("Medkit Caro")
                targetPrompt = medkitCaro and medkitCaro:FindFirstChild("ShopPrompt", true)

                if targetPrompt and targetPrompt:IsA("ProximityPrompt") then
                    fireproximityprompt(targetPrompt)
                    task.wait(0.1)
                    hrp.CFrame = originalCFrame
                else
                    hrp.CFrame = originalCFrame
                    ShowErrorNotification()
                end
            else
                ShowErrorNotification()
            end
        end
    end
})

AutoFarmTab:CreateButton({
    Name = T("CarShop"),
    Callback = function()
        local currentTeam = GetCurrentTeamName()
        local dealers = workspace:FindFirstChild("dealers")
        local teamDealer = dealers and dealers:FindFirstChild(currentTeam)
        local interaction = teamDealer and (teamDealer:FindFirstChild("Interaction") or teamDealer:FindFirstChildOfClass("BasePart"))
        
        local prompt = interaction and (interaction:IsA("ProximityPrompt") and interaction or interaction:FindFirstChildOfClass("ProximityPrompt"))
        if prompt then
            FirePromptAt(prompt, false)
        else
            ShowErrorNotification()
        end
    end
})

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    RefreshWeaponList()
end)

---------------------------------------------------
-- OTIMIZAÇÃO: TORRE ESP
---------------------------------------------------
local TurretESP = false
local ESPDistance = 400
local LowPerformanceMode = false

local DrawingLines = {}
local BillboardCache = {}

local function ClearTurretESP()
    for _, bill in pairs(BillboardCache) do if bill then bill:Destroy() end end
    for _, line in pairs(DrawingLines) do if line then line:Remove() end end
    BillboardCache = {}
    DrawingLines = {}
end

local function CreateCompactBillboard(seat)
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 70, 0, 20)
    bill.AlwaysOnTop = true
    bill.Adornee = seat
    bill.StudsOffset = Vector3.new(0, 1.8, 0)
    bill.Name = "M_TESP"

    local label = Instance.new("TextLabel")
    label.Name = "L"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.6
    label.TextSize = 10
    label.Font = Enum.Font.SourceSansBold
    label.Parent = bill

    bill.Parent = seat
    return bill
end

local cachedTurretsList = {}
local lastCacheUpdate = 0
local function GetCachedTurrets()
    local now = os.clock()
    if now - lastCacheUpdate > 3 then
        cachedTurretsList = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "TurretSeat" then
                table.insert(cachedTurretsList, v)
            end
        end
        lastCacheUpdate = now
    end
    return cachedTurretsList
end

local frameCounter = 0
RunService.RenderStepped:Connect(function()
    if not TurretESP then return end
    frameCounter = frameCounter + 1
    
    local dynamicSkip = LowPerformanceMode and 4 or 2
    if frameCounter % dynamicSkip ~= 0 then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local turrets = GetCachedTurrets()
    
    for i, seat in pairs(turrets) do
        if seat and seat.Parent then
            local dist3D = (hrp.Position - seat.Position).Magnitude
            
            if dist3D <= ESPDistance then
                if not BillboardCache[seat] then BillboardCache[seat] = CreateCompactBillboard(seat) end
                local bill = BillboardCache[seat]
                local label = bill:FindFirstChild("L")

                if label then
                    if seat:FindFirstChild("Occupant") and seat.Occupant ~= nil then
                        label.Text = T("TourUse")
                        label.TextColor3 = Color3.fromRGB(255, 50, 50)
                    else
                        label.Text = T("TourFree")
                        label.TextColor3 = Color3.fromRGB(50, 255, 50)
                    end
                end

                local pos, visible = camera:WorldToViewportPoint(seat.Position)
                if visible then
                    if not DrawingLines[i] then
                        local line = Drawing.new("Line")
                        line.Color = Color3.fromRGB(200, 200, 200)
                        line.Thickness = 1
                        DrawingLines[i] = line
                    end
                    local mypos = camera:WorldToViewportPoint(hrp.Position)
                    DrawingLines[i].From = Vector2.new(mypos.X, mypos.Y)
                    DrawingLines[i].To = Vector2.new(pos.X, pos.Y)
                    DrawingLines[i].Visible = true
                else
                    if DrawingLines[i] then DrawingLines[i].Visible = false end
                end
            else
                if BillboardCache[seat] then BillboardCache[seat]:Destroy() BillboardCache[seat] = nil end
                if DrawingLines[i] then DrawingLines[i].Visible = false end
            end
        end
    end
end)

VisualTab:CreateToggle({
    Name = T("TurretESP"), CurrentValue = false,
    Callback = function(v) TurretESP = v if not v then ClearTurretESP() end end
})

VisualTab:CreateSlider({ Name = T("ESPDist"), Range = {100, 1200}, Increment = 50, CurrentValue = 400, Callback = function(v) ESPDistance = v end })

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
-- TELEPORT CAR
---------------------------------------------------
local SelectedCar, CarSeats = nil, {}
local function GetCars()
    local cars = {} CarSeats = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") or v.Name == "DriveSeat" then
            local model = v:FindFirstAncestorOfClass("Model")
            if model and not table.find(cars, model.Name) then table.insert(cars, model.Name) CarSeats[model.Name] = v end
        end
    end
    return cars
end

local CarDropdown = TeleportTab:CreateDropdown({
    Name = T("CarList"), Options = GetCars(), CurrentOption = nil, Callback = function(v) SelectedCar = type(v) == "table" and v[1] or v end
})
TeleportTab:CreateButton({ Name = T("ResetList"), Callback = function() CarDropdown:Refresh(GetCars()) end })
TeleportTab:CreateButton({
    Name = T("TeleCar"), Callback = function()
        if SelectedCar and CarSeats[SelectedCar] then
            local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CarSeats[SelectedCar].CFrame + Vector3.new(0,3,0) end
        end
    end
})

---------------------------------------------------
-- ABA CONFIGURAÇÃO
---------------------------------------------------
ConfigTab:CreateDropdown({
    Name = T("LangSelect"),
    Options = {"Português (Brasil)", "English", "Español"},
    CurrentOption = {"Português (Brasil)"},
    Callback = function(selected)
        local choice = type(selected) == "table" and selected[1] or selected
        if choice == "Português (Brasil)" then CurrentLanguage = "pt_br"
        elseif choice == "English" then CurrentLanguage = "en"
        elseif choice == "Español" then CurrentLanguage = "es" end
        Rayfield:Notify({Title = "Language", Content = "Idioma atualizado com sucesso!", Duration = 2})
    end
})

ConfigTab:CreateToggle({
    Name = T("Performance"),
    CurrentValue = false,
    Callback = function(v) LowPerformanceMode = v end
})
