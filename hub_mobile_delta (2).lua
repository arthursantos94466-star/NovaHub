-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

---------------------------------------------------
-- IDIOMA / TRANSLATION SYSTEM (PADRÃO PT-BR)
---------------------------------------------------

local CurrentLanguage = "Português" -- Padrão alterado para Português por solicitação do usuário

local Translations = {
    ["English"] = {
        HubName = "Hashiras Hub",
        BetaNote = "Hub is in beta, bugs may occur.",
        KeyTitle = "Hashiras Hub Key",
        KeySubtitle = "Enter Key",
        Combat = "Combat",
        Movement = "Movement",
        AutoFarm = "Auto Farm",
        Visual = "Visual",
        Teleport = "Teleport",
        Config = "Configuration",
        WheelAimbot = "Wheel Aimbot",
        WheelList = "Wheel List",
        WheelFOV = "Aimbot FOV",
        WheelSmooth = "Aimbot Smoothing",
        WheelPred = "Precision",
        TurretAimbot = "Turret Aimbot",
        TurretESP = "Turret ESP",
        CarESP = "Car ESP",
        CarList = "Car List",
        ResetList = "Reset List",
        TeleportCar = "Teleport to Car",
        TurretList = "Turret List",
        TeleportTurret = "Teleport Turret",
        WeaponList = "Weapon List",
        RefreshWeapons = "Refresh Weapon List",
        EquipWeapon = "Equip Weapon",
        GetRegularMedkit = "Get Regular Medkit",
        GetExpensiveMedkit = "Get Expensive Medkit",
        CarShop = "Car Shop",
        Language = "Language",
        ItemNotFound = "Item not found",
        Error = "Error",
        SelectValidWeapon = "Select a valid weapon from the list!",
        DestinationUnavailable = "Destination or Prompt unavailable for teleport.",
        MedkitCooldown = "Wait %.1f seconds before grabbing another medkit!",
        RobRegisters = "Rob Cash Register",
        RegisterList = "Register List",
        RobButton = "ROB",
        RobCooldown = "Wait %d seconds before robbing again!",
        RobSuccess = "Robbery completed! Cooldown activated.",
        SelectRegister = "Select a valid register first!",
        Register1 = "Register 1",
        Register2 = "Register 2",
        NoCharacter = "Character not loaded.",
        ActiveCooldown = "Active Cooldown: %ds"
    },
    ["Português"] = {
        HubName = "Hashiras Hub",
        BetaNote = "Hub está em beta, pode ter erros.",
        KeyTitle = "Chave Hashiras Hub",
        KeySubtitle = "Insira a Chave",
        Combat = "Combate",
        Movement = "Movimentação",
        AutoFarm = "Auto Farm",
        Visual = "Visual",
        Teleport = "Teleporte",
        Config = "Configuração",
        WheelAimbot = "Aimbot Roda",
        WheelList = "Lista de Roda",
        WheelFOV = "Aimbot FOV",
        WheelSmooth = "Aimbot Suavização",
        WheelPred = "Precisão",
        TurretAimbot = "Torre Aimbot",
        TurretESP = "Torre ESP",
        CarESP = "Carro ESP",
        CarList = "Lista de Carros",
        ResetList = "Reset Lista",
        TeleportCar = "Teleporte ao Carro",
        TurretList = "Lista de Torre",
        TeleportTurret = "Teleporte Torre",
        WeaponList = "Lista de Armas",
        RefreshWeapons = "Atualizar Lista de Armas",
        EquipWeapon = "Equipar Arma",
        GetRegularMedkit = "Pegar Medkit Regular",
        GetExpensiveMedkit = "Pegar Medkit Caro",
        CarShop = "Loja de Carros",
        Language = "Idioma",
        ItemNotFound = "Item não encontrado",
        Error = "Erro",
        SelectValidWeapon = "Selecione uma arma válida na lista!",
        DestinationUnavailable = "Destino ou Prompt indisponível para teleporte.",
        MedkitCooldown = "Aguarde %.1f segundos antes de pegar outro medkit!",
        RobRegisters = "Roubar Caixa Registradora",
        RegisterList = "Lista de Caixas",
        RobButton = "ROUBAR",
        RobCooldown = "Aguarde %d segundos antes de roubar novamente!",
        RobSuccess = "Roubo concluído! Tempo de espera ativado.",
        SelectRegister = "Selecione um caixa válido primeiro!",
        Register1 = "Caixa 1",
        Register2 = "Caixa 2",
        NoCharacter = "Personagem não carregado.",
        ActiveCooldown = "Tempo de Espera: %ds"
    }
}

local function T(key)
    return Translations[CurrentLanguage][key] or key
end

---------------------------------------------------
-- WINDOW SETUP WITH KEY SYSTEM
---------------------------------------------------

local Window = Rayfield:CreateWindow({
    Name = T("HubName"),
    LoadingTitle = T("HubName"),
    LoadingSubtitle = "Rayfield",
    ConfigurationSaving = {Enabled = false},
    KeySystem = true,
    KeySettings = {
        Title = T("KeyTitle"),
        Subtitle = T("KeySubtitle"),
        Note = T("BetaNote"),
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

-- Função utilitária para disparar ProximityPrompt com segurança e retornar
local function FirePromptAt(instance, teleportBack)
    if not instance or not instance:IsA("ProximityPrompt") then return false end
    local char = GetCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
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

    task.wait(0.25) -- Delay de física seguro
    fireproximityprompt(instance)

    if teleportBack then
        task.wait(0.15)
        hrp.CFrame = originalPos
    end
    return true
end

---------------------------------------------------
-- TABS CORES
---------------------------------------------------

local CombatTab = Window:CreateTab(T("Combat"), 4483362458)
local MovementTab = Window:CreateTab(T("Movement"), 4483362458)
local AutoFarmTab = Window:CreateTab(T("Auto Farm"), 4483362458)
local VisualTab = Window:CreateTab(T("Visual"), 4483362458)
local TeleportTab = Window:CreateTab(T("Teleport"), 4483362458)
local ConfigTab = Window:CreateTab(T("Config"), 4483362458)

---------------------------------------------------
-- COMBAT SECTIONS
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
-- WHEEL AIMBOT PRO WITH WALL CHECK & LERP
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

CombatTab:CreateToggle({
    Name = T("WheelAimbot"),
    CurrentValue = false,
    Callback = function(v)
        WheelAimbot = v
        LockedWheel = nil
    end
})

CombatTab:CreateDropdown({
    Name = T("WheelList"),
    Options = {"ALL", "FL", "FR", "RL", "RR"},
    CurrentOption = {"ALL"},
    Callback = function(opt)
        WheelTarget = type(opt) == "table" and opt[1] or opt
        LockedWheel = nil
    end
})

CombatTab:CreateSlider({ Name = T("WheelFOV"), Range = {50, 600}, Increment = 10, CurrentValue = 250, Callback = function(v) FOV = v end })
CombatTab:CreateSlider({ Name = T("WheelSmooth"), Range = {1, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) Smoothing = v/100 end })
CombatTab:CreateSlider({ Name = T("WheelPred"), Range = {0, 30}, Increment = 1, CurrentValue = 12, Callback = function(v) Prediction = v/100 end })

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

local TurretAimbot = false
local TeamCheck = true
local Smoothness = 0.15

local function GetTurretTarget()
    local closest = nil
    local dist = math.huge
    for _,p in pairs(Players:GetPlayers()) do
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
    if not target then return end
    local camPos = camera.CFrame.Position
    local aimCF = CFrame.new(camPos, target.Position)
    camera.CFrame = camera.CFrame:Lerp(aimCF, Smoothness)
end)

CombatTab:CreateToggle({ Name = T("TurretAimbot"), CurrentValue = false, Callback = function(v) TurretAimbot = v end })

---------------------------------------------------
-- MOVEMENT SECTION
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
    Name = "Jump Power",
    Range = {0,200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        local hum = GetCharacter():FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
    end
})

MovementTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})

local InfiniteJump = false
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) InfiniteJump = v end
})

UIS.JumpRequest:Connect(function()
    if InfiniteJump then
        local hum = GetCharacter():FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

local noclip = false
MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) noclip = v end
})

RunService.Stepped:Connect(function()
    if noclip then
        local char = GetCharacter()
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

---------------------------------------------------
-- COMPATIBILIDADE MULTI-EQUIPES GLOBAL
---------------------------------------------------

local AllowedTeams = {
    "AIC", "CFE", "DEA", "EJERCITO", "GN", "GOPES", 
    "GRUPO G", "GRUPO J", "GRUPO M", "GRUPO N", "MARINA", "POLICIA ESTATAL"
}

local function GetCurrentTeamName()
    if LocalPlayer.Team then
        return LocalPlayer.Team.Name
    end
    return "GRUPO J" -- Fallback seguro
end

---------------------------------------------------
-- ARMAS AUTO FARM DINÂMICO
---------------------------------------------------

local SelectedWeaponName = ""
local WeaponDataMap = {}

local WeaponDropdown = AutoFarmTab:CreateDropdown({
    Name = T("WeaponList"),
    Options = {"Carregando..."},
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

AutoFarmTab:CreateButton({
    Name = T("RefreshWeapons"),
    Callback = function() 
        ScanWeaponsRecursively() 
    end
})

AutoFarmTab:CreateButton({
    Name = T("EquipWeapon"),
    Callback = function()
        if SelectedWeaponName == "" or SelectedWeaponName == T("ItemNotFound") then
            Rayfield:Notify({Title = T("Error"), Content = T("SelectValidWeapon"), Duration = 3})
            return 
        end
        
        local prompt = WeaponDataMap[SelectedWeaponName]
        if prompt and prompt.Parent then
            local success = FirePromptAt(prompt, false)
            if not success then
                Rayfield:Notify({Title = T("Error"), Content = T("DestinationUnavailable"), Duration = 3})
            end
        else
            Rayfield:Notify({Title = T("Error"), Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

---------------------------------------------------
-- MEDKITS COM INTERVALO DE TEMPO (COOLDOWN)
---------------------------------------------------

local LastMedkitTime = 0
local MedkitCooldownDuration = 3.5

local function CheckMedkitCooldown()
    local currentTime = os.clock()
    if currentTime - LastMedkitTime < MedkitCooldownDuration then
        local remaining = MedkitCooldownDuration - (currentTime - LastMedkitTime)
        Rayfield:Notify({
            Title = T("Error"), 
            Content = string.format(T("MedkitCooldown"), remaining), 
            Duration = 2
        })
        return false
    end
    return true
end

AutoFarmTab:CreateButton({
    Name = T("GetRegularMedkit"),
    Callback = function()
        if not CheckMedkitCooldown() then return end
        
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
            Rayfield:Notify({Title = T("ItemNotFound"), Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

AutoFarmTab:CreateButton({
    Name = T("GetExpensiveMedkit"),
    Callback = function()
        if not CheckMedkitCooldown() then return end
        
        local targetCF = CFrame.new(-840.591553, 102.522545, -387.653351, 0.671570599, 1.87319991e-08, -0.740940571, 5.53272521e-08, 1, 7.54286589e-08, 0.740940571, -9.16498806e-08, 0.671570599)
        local char = GetCharacter()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if not hrp then 
            Rayfield:Notify({Title = T("Error"), Content = T("NoCharacter"), Duration = 3})
            return 
        end
        
        local originalPos = hrp.CFrame
        hrp.CFrame = targetCF
        task.wait(0.35) -- Tempo estendido para streaming e replicação do Rojo.ShopPrompt no Mobile
        
        local medkitCaro = workspace:FindFirstChild("PIPSAS") and workspace.PIPSAS:FindFirstChild("Medkit Caro")
        local foundPrompt = medkitCaro and medkitCaro:FindFirstChild("ShopPrompt", true)
        
        if foundPrompt then
            fireproximityprompt(foundPrompt)
            LastMedkitTime = os.clock()
            task.wait(0.15)
            hrp.CFrame = originalPos
        else
            hrp.CFrame = originalPos
            Rayfield:Notify({Title = T("ItemNotFound"), Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

---------------------------------------------------
-- ROUBAR CAIXA REGISTRADORA (30S TIMER + DISTÂNCIA)
---------------------------------------------------

local SelectedRegister = ""
local RobCooldownTime = 0
local RobDuration = 30

local function GetRegisterPrompt(id)
    local mapaGen = workspace:FindFirstChild("MAPA") and workspace.MAPA:FindFirstChild("Mapa- general")
    if not mapaGen then return nil end
    
    local children = mapaGen:GetChildren()
    if id == "Caixa 1" or id == "Register 1" then
        local node21 = children[21]
        local node52 = node21 and node21:GetChildren()[52]
        local meshPart = node52 and node52:FindFirstChild("MeshPart")
        return meshPart and meshPart:FindFirstChildOfClass("ProximityPrompt")
    elseif id == "Caixa 2" or id == "Register 2" then
        local node127 = children[127]
        local node53 = node127 and node127:GetChildren()[53]
        local meshPart = node53 and node53:FindFirstChild("MeshPart")
        return meshPart and meshPart:FindFirstChildOfClass("ProximityPrompt")
    end
    return nil
end

local function GetDistanceToRegister(id)
    local prompt = GetRegisterPrompt(id)
    local char = GetCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if prompt and prompt.Parent and hrp then
        return math.floor((hrp.Position - prompt.Parent.Position).Magnitude)
    end
    return nil
end

local RegisterDropdown = AutoFarmTab:CreateDropdown({
    Name = T("RegisterList"),
    Options = {T("Register1") .. " [0m]", T("Register2") .. " [0m]"},
    CurrentOption = nil,
    Callback = function(v)
        local selection = type(v) == "table" and v[1] or v
        if selection then
            if selection:find(T("Register1")) then
                SelectedRegister = "Caixa 1"
            elseif selection:find(T("Register2")) then
                SelectedRegister = "Caixa 2"
            end
        end
    end
})

-- Loop para atualizar as distâncias em tempo real no Dropdown
task.spawn(function()
    while task.wait(1) do
        local dist1 = GetDistanceToRegister("Caixa 1") or "N/A"
        local dist2 = GetDistanceToRegister("Caixa 2") or "N/A"
        
        local opt1 = string.format("%s [%sstuds]", T("Register1"), tostring(dist1))
        local opt2 = string.format("%s [%sstuds]", T("Register2"), tostring(dist2))
        
        RegisterDropdown:Refresh({opt1, opt2})
    end
end)

AutoFarmTab:CreateButton({
    Name = T("RobButton"),
    Callback = function()
        local currentTime = os.time()
        if currentTime < RobCooldownTime then
            local remaining = RobCooldownTime - currentTime
            Rayfield:Notify({
                Title = T("Error"), 
                Content = string.format(T("RobCooldown"), remaining), 
                Duration = 3
            })
            return
        end
        
        if SelectedRegister == "" then
            Rayfield:Notify({Title = T("Error"), Content = T("SelectRegister"), Duration = 3})
            return
        end
        
        local prompt = GetRegisterPrompt(SelectedRegister)
        if prompt then
            local success = FirePromptAt(prompt, false)
            if success then
                RobCooldownTime = os.time() + RobDuration
                Rayfield:Notify({Title = "Sucesso", Content = T("RobSuccess"), Duration = 4})
                
                -- Exibe mensagens de status dinâmicas durante os 30 segundos
                task.spawn(function()
                    while os.time() < RobCooldownTime do
                        local rem = RobCooldownTime - os.time()
                        -- Atualiza via notificações secundárias sem quebrar a UI
                        task.wait(5)
                    end
                end)
            else
                Rayfield:Notify({Title = T("Error"), Content = T("DestinationUnavailable"), Duration = 3})
            end
        else
            Rayfield:Notify({Title = T("ItemNotFound"), Content = T("ItemNotFound"), Duration = 3})
        end
    end
})

---------------------------------------------------
-- LOJA DE CARROS ADAPTÁVEL MULTI-EQUIPE
---------------------------------------------------

AutoFarmTab:CreateButton({
    Name = T("CarShop"),
    Callback = function()
        local currentTeam = GetCurrentTeamName()
        local dealersFolder = workspace:FindFirstChild("dealers")
        local teamDealer = dealersFolder and dealersFolder:FindFirstChild(currentTeam)
        
        if teamDealer and teamDealer:FindFirstChild("Interaction") then
            local prompt = teamDealer.Interaction:FindFirstChildOfClass("ProximityPrompt") or teamDealer.Interaction
            if prompt:IsA("ProximityPrompt") then
                FirePromptAt(prompt, false)
            else
                Rayfield:Notify({Title = T("Error"), Content = T("ItemNotFound"), Duration = 3})
            end
        else
            Rayfield:Notify({Title = T("ItemNotFound"), Content = T("ItemNotFound"), Duration = 3})
        end
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
-- TORRE ESP PRO (OTIMIZADO MOBILE)
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
    bill.Size = UDim2.new(0,90,0,30) -- Compactado para telas mobile
    bill.AlwaysOnTop = true
    bill.Adornee = seat
    bill.StudsOffset = Vector3.new(0,2.5,0)
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
            table.insert(list, v) 
        end
    end
    return list
end

RunService.RenderStepped:Connect(function()
    if not TurretESP then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local turrets = GetTurrets()
    for i, seat in pairs(turrets) do
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

        local pos, visible = camera:WorldToViewportPoint(seat.Position)
        if visible then
            if not DrawingLines[i] then
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255,0,0)
                line.Thickness = 1.5
                DrawingLines[i] = line
            end
            local mypos = camera:WorldToViewportPoint(hrp.Position)
            DrawingLines[i].From = Vector2.new(mypos.X, mypos.Y)
            DrawingLines[i].To = Vector2.new(pos.X, pos.Y)
            DrawingLines[i].Visible = true
        else
            if DrawingLines[i] then DrawingLines[i].Visible = false end
        end
    end
end)

VisualTab:CreateToggle({ Name = T("TurretESP"), CurrentValue = false, Callback = function(v) TurretESP = v if not v then ClearTurretESP() end end })

---------------------------------------------------
-- CARREGA CARROS TELEPORTE
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
    Name = T("CarList"),
    Options = GetCars(),
    CurrentOption = nil,
    Callback = function(v) SelectedCar = type(v) == "table" and v[1] or v end
})

TeleportTab:CreateButton({ Name = T("ResetList"), Callback = function() CarDropdown:Refresh(GetCars()) end })
TeleportTab:CreateButton({
    Name = T("TeleportCar"),
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
-- TELEPORTE TURRET SEAT
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
    Name = T("TurretList"),
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
    Name = T("TeleportTurret"),
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
    billboard.Size = UDim2.new(0,130,0,35)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0,2.5,0)
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
    line.Thickness = 1.5
    line.Visible = false

    CarESPObjects[model] = { Gui = billboard, Text = text, Seat = seat, Line = line }
end

VisualTab:CreateToggle({
    Name = T("CarESP"),
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
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
-- SEÇÃO CONFIGURAÇÃO & SELETOR DE IDIOMA DINÂMICO
---------------------------------------------------

ConfigTab:CreateDropdown({
    Name = "Idioma / Language",
    Options = {"Português", "English"},
    CurrentOption = {"Português"},
    Callback = function(v)
        local targetLang = type(v) == "table" and v[1] or v
        if targetLang and targetLang ~= CurrentLanguage then
            CurrentLanguage = targetLang
            Rayfield:Notify({
                Title = "Idioma Alterado / Language Changed",
                Content = CurrentLanguage == "Português" and "Interface atualizada para Português!" or "Interface updated to English! Restart script if elements do not update immediately.",
                Duration = 3
            })
        end
    end
})

-- Inicialização Recursiva das Armas
task.spawn(ScanWeaponsRecursively)
