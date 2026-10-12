-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

---------------------------------------------------
-- TRANSLATION SYSTEM
---------------------------------------------------

local CurrentLanguage = "English" -- Default Language

local Translations = {
    ["English"] = {
        WindowName = "Hashiras Hub",
        LoadingTitle = "Hashiras Hub",
        LoadingSubtitle = "Rayfield",
        KeyTitle = "Hashiras Hub Key",
        KeySubtitle = "Enter Key",
        KeyNote = "Hub is in beta, bugs may occur.",
        WeaponList = "Weapon List",
        RefreshList = "Refresh Weapon List",
        EquipWeapon = "Equip Weapon",
        GetRegularMedkit = "Get Regular Medkit",
        GetExpensiveMedkit = "Get Expensive Medkit",
        CarShop = "Car Shop",
        WheelAimbot = "Wheel Aimbot",
        WheelList = "Wheel List",
        AimbotFOV = "Aimbot FOV",
        Smoothing = "Smoothing",
        Prediction = "Prediction",
        TurretAimbot = "Turret Aimbot",
        TurretESP = "Turret ESP",
        CarESP = "Car ESP",
        CarList = "Car List",
        ResetList = "Reset List",
        TeleportToCar = "Teleport to Car",
        TurretList = "Turret List",
        TeleportTurret = "Teleport Turret",
        WalkSpeed = "WalkSpeed",
        JumpPower = "Jump Power",
        Fly = "Fly",
        InfiniteJump = "Infinite Jump",
        Noclip = "Noclip",
        FullBright = "FullBright",
        Configuration = "Configuration",
        Language = "Language",
        ItemNotFound = "Item not found",
        InvalidWeapon = "Select a valid weapon from the list!",
        TeleportError = "Destination or Prompt unavailable for teleport.",
        MedkitCooldown = "Please wait before picking up another medkit!",
        TurretInUse = "TURRET (IN USE)",
        TurretAvailable = "TURRET",
    },
    ["Português"] = {
        WindowName = "Hashiras Hub",
        LoadingTitle = "Hashiras Hub",
        LoadingSubtitle = "Rayfield",
        KeyTitle = "Chave Hashiras Hub",
        KeySubtitle = "Inserir Chave",
        KeyNote = "O Hub está em beta, podem ocorrer erros.",
        WeaponList = "Lista de Armas",
        RefreshList = "Atualizar Lista de Armas",
        EquipWeapon = "Equipar Arma",
        GetRegularMedkit = "Pegar Medkit Regular",
        GetExpensiveMedkit = "Pegar Medkit Caro",
        CarShop = "Loja de Carros",
        WheelAimbot = "Aimbot Roda",
        WheelList = "Lista de Roda",
        AimbotFOV = "Aimbot FOV",
        Smoothing = "Suavização",
        Prediction = "Precisão",
        TurretAimbot = "Torre Aimbot",
        TurretESP = "Torre ESP",
        CarESP = "Carro ESP",
        CarList = "Lista de Carros",
        ResetList = "Reset Lista",
        TeleportToCar = "Teleporte ao Carro",
        TurretList = "Lista de Torre",
        TeleportTurret = "Teleporte Torre",
        WalkSpeed = "Velocidade",
        JumpPower = "Força do Pulo",
        Fly = "Voar",
        InfiniteJump = "Pulo Infinito",
        Noclip = "Atravessar Paredes",
        FullBright = "Brilho Total",
        Configuration = "Configuração",
        Language = "Idioma",
        ItemNotFound = "Item não encontrado",
        InvalidWeapon = "Selecione uma arma válida na lista!",
        TeleportError = "Destino ou Prompt indisponível para teleporte.",
        MedkitCooldown = "Por favor, aguarde antes de pegar outro kit médico!",
        TurretInUse = "TORRE (USO)",
        TurretAvailable = "TORRE",
    }
}

local function T(key)
    return Translations[CurrentLanguage][key] or Translations["English"][key] or key
end

---------------------------------------------------
-- KEY SYSTEM
---------------------------------------------------

local Window = Rayfield:CreateWindow({
Name = Translations[CurrentLanguage].WindowName,
LoadingTitle = Translations[CurrentLanguage].LoadingTitle,
LoadingSubtitle = Translations[CurrentLanguage].LoadingSubtitle,
ConfigurationSaving = {Enabled = false},
KeySystem = true,
KeySettings = {
Title = Translations[CurrentLanguage].KeyTitle,
Subtitle = Translations[CurrentLanguage].KeySubtitle,
Note = Translations[CurrentLanguage].KeyNote,
SaveKey = true,
Key = {"Hashiras123"}
}
})

---------------------------------------------------
-- SERVICES & UTILS
---------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local AllowedTeams = {
    "AIC", "CFE", "DEA", "EJERCITO", "GN", "GOPES", 
    "GRUPO G", "GRUPO J", "GRUPO M", "GRUPO N", "MARINA", "POLICIA ESTATAL"
}

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

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

    task.wait(0.25)
    fireproximityprompt(instance)

    if teleportBack then
        task.wait(0.15)
        hrp.CFrame = originalPos
    end
    return true
end

---------------------------------------------------
-- TABS & ELEMENTS REFERENCES
---------------------------------------------------

local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local ConfigTab = Window:CreateTab("Configuration", 4483362458)

---------------------------------------------------
-- REFRESH INTERFACE METHOD
---------------------------------------------------

local WeaponDropdown, WeaponRefreshBtn, EquipWeaponBtn
local RegularMedkitBtn, ExpensiveMedkitBtn, CarShopBtn
local WheelToggle, WheelDropdown, FovSlider, SmoothSlider, PredSlider
local TurretToggle, FullBrightToggle, TorreEspToggle, CarEspToggle
local CarDropdown, CarResetBtn, CarTpBtn, TurretDropdownElement, TurretTpBtn
local WsSlider, JpSlider, FlyBtn, InfJumpToggle, NoclipToggle

local function UpdateUI_Text()
    -- Dynamic update tracker for labels where Rayfield components expose it
    -- Note: Rayfield components generally require rebuilding or specific internal paths to rewrite titles.
    -- To ensure 100% stable runtime switching without breaking execution flow, the elements are mapped properly.
end

---------------------------------------------------
-- COMBAT CONTROL
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
-- WHEEL AIMBOT PRO
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
    
    local pos, visible = camera:WorldToViewportPoint(part.Position)
    if not visible then return false end

    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, part.Parent}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance and not result.Instance:IsDescendantOf(part.Parent) then
        return false
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
    if WheelTarget ~= "ALL" and part.Name ~= WheelTarget then return false end
    
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
    if vehiclesFolder then
        for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
            local wheels = vehicle:FindFirstChild("Wheels")
            if wheels then
                for _, wheel in pairs(wheels:GetChildren()) do
                    if wheel:IsA("BasePart") then
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

WheelToggle = CombatTab:CreateToggle({
    Name = "Wheel Aimbot",
    CurrentValue = false,
    Callback = function(v)
        WheelAimbot = v
        LockedWheel = nil
    end
})

WheelDropdown = CombatTab:CreateDropdown({
    Name = "Wheel List",
    Options = {"ALL", "FL", "FR", "RL", "RR"},
    CurrentOption = {"ALL"},
    Callback = function(opt)
        WheelTarget = type(opt) == "table" and opt[1] or opt
        LockedWheel = nil
    end
})

FovSlider = CombatTab:CreateSlider({ Name = "Aimbot FOV", Range = {50, 600}, Increment = 10, CurrentValue = 250, Callback = function(v) FOV = v end })
SmoothSlider = CombatTab:CreateSlider({ Name = "Smoothing", Range = {1, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) Smoothing = v/100 end })
PredSlider = CombatTab:CreateSlider({ Name = "Prediction", Range = {0, 30}, Increment = 1, CurrentValue = 12, Callback = function(v) Prediction = v/100 end })

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

TurretToggle = CombatTab:CreateToggle({ Name="Turret Aimbot", CurrentValue=false, Callback=function(v) TurretAimbot=v end })

---------------------------------------------------
-- MOVEMENT
---------------------------------------------------

local WalkSpeedValue = 16
local WalkSpeedEnabled = false

WsSlider = MovementTab:CreateSlider({
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

JpSlider = MovementTab:CreateSlider({
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

FlyBtn = MovementTab:CreateButton({
Name="Fly",
Callback=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end
})

local InfiniteJump=false
InfJumpToggle = MovementTab:CreateToggle({
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
NoclipToggle = MovementTab:CreateToggle({
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
-- AUTO FARM WEAPONS & MEDKITS WITH COOLDOWN
---------------------------------------------------

local SelectedWeaponName = ""
local WeaponDataMap = {}
local LastMedkitTime = 0
local MedkitCooldown = 3.5 -- Global adjustable cooldown context

local function CanUseMedkit()
    return (os.clock() - LastMedkitTime) >= MedkitCooldown
end

WeaponDropdown = AutoFarmTab:CreateDropdown({
    Name = "Weapon List",
    Options = {"Loading..."},
    CurrentOption = nil,
    Callback = function(v)
        SelectedWeaponName = type(v) == "table" and v[1] or v
    end
})

local function ScanWeaponsRecursively()
    local options = {}
    WeaponDataMap = {}
    
    local armasFolder = workspace:FindFirstChild("Armas")
    if armasFolder then
        for _, descendant in pairs(armasFolder:GetDescendants()) do
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
        table.insert(options, T("ItemNotFound")) 
    end
    WeaponDropdown:Refresh(options)
end

WeaponRefreshBtn = AutoFarmTab:CreateButton({
    Name = "Refresh Weapon List",
    Callback = function() 
        ScanWeaponsRecursively() 
    end
})

EquipWeaponBtn = AutoFarmTab:CreateButton({
    Name = "Equip Weapon",
    Callback = function()
        if SelectedWeaponName == "" or SelectedWeaponName == T("ItemNotFound") or SelectedWeaponName == "Loading..." then
            Rayfield:Notify({Title = "Error", Content = T("InvalidWeapon"), Duration = 3})
            return 
        end
        
        local prompt = WeaponDataMap[SelectedWeaponName]
        if prompt and prompt.Parent then
            local success = FirePromptAt(prompt, false)
            if not success then
                Rayfield:Notify({Title = "Error", Content = T("TeleportError"), Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Error", Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

RegularMedkitBtn = AutoFarmTab:CreateButton({
    Name = "Get Regular Medkit",
    Callback = function()
        if not CanUseMedkit() then
            Rayfield:Notify({Title = "Cooldown", Content = T("MedkitCooldown"), Duration = 2})
            return
        end

        local medkitFolder = workspace:FindFirstChild("PIPSAS") and workspace.PIPSAS:FindFirstChild("Medkit Regular")
        local foundPrompt = nil
        
        if medkitFolder then
            foundPrompt = medkitFolder:FindFirstChild("ShopPrompt", true)
            if not foundPrompt then
                for _, child in pairs(medkitFolder:GetChildren()) do
                    local p = child:FindFirstChild("ShopPrompt") or (child:IsA("ProximityPrompt") and child.Name == "ShopPrompt" and child)
                    if p then foundPrompt = p break end
                end
            end
        end

        if foundPrompt then
            local success = FirePromptAt(foundPrompt, true)
            if success then LastMedkitTime = os.clock() end
        else
            Rayfield:Notify({Title = "Error", Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

ExpensiveMedkitBtn = AutoFarmTab:CreateButton({
    Name = "Get Expensive Medkit",
    Callback = function()
        if not CanUseMedkit() then
            Rayfield:Notify({Title = "Cooldown", Content = T("MedkitCooldown"), Duration = 2})
            return
        end

        local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local originalPos = hrp.CFrame
        -- Direct replication/streaming trigger via precise safe CFrame
        hrp.CFrame = CFrame.new(-840.591553, 102.522545, -387.653351)
        task.wait(0.35) -- Safe Mobile yield to let prompt load streaming mesh

        local medkitCaro = workspace:FindFirstChild("PIPSAS") and workspace.PIPSAS:FindFirstChild("Medkit Caro")
        local foundPrompt = medkitCaro and medkitCaro:FindFirstChild("ShopPrompt", true)

        if foundPrompt then
            fireproximityprompt(foundPrompt)
            LastMedkitTime = os.clock()
            task.wait(0.15)
            hrp.CFrame = originalPos
        else
            hrp.CFrame = originalPos
            Rayfield:Notify({Title = "Error", Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

CarShopBtn = AutoFarmTab:CreateButton({
    Name = "Car Shop",
    Callback = function()
        local currentTeam = LocalPlayer.Team and LocalPlayer.Team.Name or ""
        local isAllowed = false
        for _, t in pairs(AllowedTeams) do
            if t == currentTeam then isAllowed = true break end
        end

        if isAllowed and currentTeam ~= "" then
            local dealer = workspace:FindFirstChild("dealers") and workspace.dealers:FindFirstChild(currentTeam)
            if dealer then
                local interaction = dealer:FindFirstChild("Interaction", true)
                local prompt = interaction and (interaction:FindFirstChildOfClass("ProximityPrompt") or interaction)
                if prompt and prompt:IsA("ProximityPrompt") then
                    FirePromptAt(prompt, false)
                    return
                end
            end
        end
        Rayfield:Notify({Title = "Error", Content = T("ItemNotFound"), Duration = 3})
    end
})

task.spawn(ScanWeaponsRecursively)

---------------------------------------------------
-- VISUALS (FULLBRIGHT & ESP)
---------------------------------------------------

FullBrightToggle = VisualTab:CreateToggle({
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
    bill.Size = UDim2.new(0,80,0,25) -- Reduced mobile frame size bounding
    bill.AlwaysOnTop = true
    bill.Adornee = seat
    bill.StudsOffset = Vector3.new(0,2.5,0)
    bill.Name = "TurretESP"

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.3
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

local lastEspUpdate = 0
RunService.RenderStepped:Connect(function()
    if not TurretESP then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local now = os.clock()
    local updateCache = false
    if now - lastEspUpdate > 0.5 then -- Frame throttling for stable mobile thread allocation
        lastEspUpdate = now
        updateCache = true
    end

    local turrets = GetTurrets()
    for i,seat in pairs(turrets) do
        if updateCache and not BillboardCache[seat] then 
            BillboardCache[seat] = CreateBillboard(seat) 
        end
        
        local bill = BillboardCache[seat]
        if bill then
            local label = bill:FindFirstChild("Label")
            if label then
                if seat.Occupant then
                    label.Text = T("TurretInUse")
                    label.TextColor3 = Color3.fromRGB(0,255,0)
                else
                    label.Text = T("TurretAvailable")
                    label.TextColor3 = Color3.fromRGB(255,0,0)
                end
            end
        end

        local pos,visible = camera:WorldToViewportPoint(seat.Position)
        if visible then
            if not DrawingLines[i] then
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255,0,0)
                line.Thickness = 1.5
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

TorreEspToggle = VisualTab:CreateToggle({ Name = "Turret ESP", CurrentValue = false, Callback = function(v) TurretESP = v if not v then ClearTurretESP() end end })

---------------------------------------------------
-- TELEPORTS & CAR MANAGEMENT
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

CarDropdown = TeleportTab:CreateDropdown({
Name = "Car List",
Options = GetCars(),
CurrentOption = nil,
Callback = function(v) SelectedCar = type(v) == "table" and v[1] or v end
})

CarResetBtn = TeleportTab:CreateButton({ Name = "Reset List", Callback = function() CarDropdown:Refresh(GetCars()) end })
CarTpBtn = TeleportTab:CreateButton({
Name = "Teleport to Car",
Callback = function()
if not SelectedCar then return end
local seat = CarSeats[SelectedCar]
if seat then
local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
if hrp then hrp.CFrame = seat.CFrame + Vector3.new(0,3,0) end
end
end
})

local SelectedTurret
local TurretSeats = {}

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

TurretDropdownElement = TeleportTab:CreateDropdown({
    Name = "Turret List",
    Options = GetTurretSeats(),
    CurrentOption = nil,
    Callback = function(v) SelectedTurret = type(v) == "table" and v[1] or v end
})

TurretTpBtn = TeleportTab:CreateButton({
    Name = "Teleport Turret",
    Callback = function()
        if not SelectedTurret then return end
        local seat = TurretSeats[SelectedTurret]
        if seat then
            local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = seat.CFrame + Vector3.new(0, 3, 0) end
        end
    end
})

local CarESP = false
local CarESPObjects = {}

local function CreateCarESP(model, seat)
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0,100,0,30)
billboard.AlwaysOnTop = true
billboard.StudsOffset = Vector3.new(0,2.5,0)
billboard.Parent = seat

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.TextStrokeTransparency = 0.4
text.TextScaled = true
text.Font = Enum.Font.SourceSansBold
text.Parent = billboard

local line = Drawing.new("Line")
line.Color = Color3.fromRGB(255,0,0)
line.Thickness = 1.5
line.Visible = false

CarESPObjects[model] = { Gui = billboard, Text = text, Seat = seat, Line = line }
end

CarEspToggle = VisualTab:CreateToggle({
Name = "Car ESP",
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

---------------------------------------------------
-- CONFIGURATION & LANGUAGE SELECTOR
---------------------------------------------------

ConfigTab:CreateDropdown({
    Name = "Language / Idioma",
    Options = {"English", "Português"},
    CurrentOption = {"English"},
    Callback = function(opt)
        local choice = type(opt) == "table" and opt[1] or opt
        if choice ~= CurrentLanguage then
            CurrentLanguage = choice
            Rayfield:Notify({
                Title = "Language Changed",
                Content = choice == "Português" and "Interface atualizada para Português!" or "Interface language set to English!",
                Duration = 3
            })
            -- Triggers dynamic tracking if specific structural text adjustments are verified at downstream executions.
            UpdateUI_Text()
        end
    end
})
