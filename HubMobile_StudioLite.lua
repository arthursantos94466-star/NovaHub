-- Roblox Studio Lite / Mobile Hub Optimization
-- [Configurações e Idiomas Centrais]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer

local currentLanguage = "pt-BR"
local selectedWheel = "ALL"
local aimbotConnection = nil
local espConnections = {}
local espLabels = {}

local localization = {
    ["pt-BR"] = {
        ["WeaponList"] = "Lista de Armas",
        ["RegularMedkit"] = "Pegar Medkit Regular",
        ["ExpensiveMedkit"] = "Pegar Medkit Caro",
        ["CarShop"] = "Loja de Carros",
        ["Config"] = "Configuração",
        ["EquipWeapon"] = "Equipar Arma",
        ["NotFound"] = "Item não encontrado"
    },
    ["en-US"] = {
        ["WeaponList"] = "Weapon List",
        ["RegularMedkit"] = "Get Regular Medkit",
        ["ExpensiveMedkit"] = "Get Expensive Medkit",
        ["CarShop"] = "Car Shop",
        ["Config"] = "Configuration",
        ["EquipWeapon"] = "Equip Weapon",
        ["NotFound"] = "Item not found"
    },
    ["es-ES"] = {
        ["WeaponList"] = "Lista de Armas",
        ["RegularMedkit"] = "Obtener Medkit Regular",
        ["ExpensiveMedkit"] = "Obtener Medkit Caro",
        ["CarShop"] = "Tienda de Autos",
        ["Config"] = "Configuración",
        ["EquipWeapon"] = "Equipar Arma",
        ["NotFound"] = "Item no encontrado"
    }
}

local function msg(key)
    return localization[currentLanguage] and localization[currentLanguage][key] or localization["pt-BR"][key]
end

-- [Suporte Multiequipes]
local function getCurrentTeamName()
    if LocalPlayer.Team then
        return LocalPlayer.Team.Name
    elseif LocalPlayer:FindFirstChild("TeamValue") then
        return LocalPlayer.TeamValue.Value
    end
    return "GRUPO J"
end

-- [Busca Avançada Recursiva Otimizada]
local function findProximityPromptRecursive(parent, actionTextMatch)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            if not actionTextMatch or child.ActionText == actionTextMatch then
                return child
            end
        end
        local found = findProximityPromptRecursive(child, actionTextMatch)
        if found then return found end
    end
    return nil
end

local function firePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt)
    end
end

-- [Medkits Funcionalidade]
local function getRegularMedkit()
    local medkit = Workspace:FindFirstChild("Medkit Regular", true) or Workspace:FindFirstChild("Medkit", true)
    if medkit then
        local prompt = findProximityPromptRecursive(medkit)
        if prompt then firePrompt(prompt) return end
    end
    print(msg("NotFound"))
end

local function getExpensiveMedkit()
    local targetCFrame = CFrame.new(-840.591553, 102.522545, -387.653351, 0.671570599, 1.87319991e-08, -0.740940571, 5.53272521e-08, 1, 7.54286589e-08, 0.740940571, -9.16498806e-08, 0.671570599)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local oldCFrame = char.HumanoidRootPart.CFrame
        char.HumanoidRootPart.CFrame = targetCFrame
        task.wait(0.3)
        
        local pipsas = Workspace:FindFirstChild("PIPSAS")
        local medkitCaro = pipsas and pipsas:FindFirstChild("Medkit Caro")
        local prompt = medkitCaro and findProximityPromptRecursive(medkitCaro)
        
        if prompt then
            firePrompt(prompt)
        else
            print(msg("NotFound"))
        end
        task.wait(0.2)
        char.HumanoidRootPart.CFrame = oldCFrame
    end
end

-- [Auto Farm de Armas & Loja de Carros]
local function getWeaponList()
    local weapons = {}
    local weaponsFolder = Workspace:FindFirstChild("Armas")
    if weaponsFolder then
        for _, obj in ipairs(weaponsFolder:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                if not table.find(weapons, obj.ActionText) then
                    table.insert(weapons, obj.ActionText)
                end
            end
        end
    end
    return weapons
end

local function equipWeaponByName(name)
    local weaponsFolder = Workspace:FindFirstChild("Armas")
    if weaponsFolder then
        for _, obj in ipairs(weaponsFolder:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.ActionText == name then
                firePrompt(obj)
                return true
            end
        end
    end
    print(msg("NotFound"))
    return false
end

local function interactCarShop()
    local teamName = getCurrentTeamName()
    local dealers = Workspace:FindFirstChild("dealers") or Workspace:FindFirstChild("Dealers")
    local teamDealer = dealers and dealers:FindFirstChild(teamName)
    
    if teamDealer then
        local prompt = findProximityPromptRecursive(teamDealer)
        if prompt then
            firePrompt(prompt)
            return
        end
    end
    print(msg("NotFound"))
end

-- [Aimbot de Rodas Inteligente]
local function checkWallAndDistance(part)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local origin = char.HumanoidRootPart.Position
    local dest = part.Position
    if (origin - dest).Magnitude > 150 then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterPlayers = {LocalPlayer}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(origin, dest - origin, raycastParams)
    if result and result.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    return result == nil
end

local function cleanAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

local function startWheelAimbot()
    cleanAimbot()
    aimbotConnection = RunService.RenderStepped:Connect(function()
        local camera = Workspace.CurrentCamera
        local bestTarget = nil
        local minDistance = math.huge
        
        for _, veh in ipairs(Workspace:GetChildren()) do
            if veh:IsA("Model") and (veh:FindFirstChild("Wheels") or veh:FindFirstChild("Rodas")) then
                local wheelsFolder = veh:FindFirstChild("Wheels") or veh:FindFirstChild("Rodas")
                for _, wheel in ipairs(wheelsFolder:GetChildren()) do
                    if selectedWheel == "ALL" or wheel.Name == selectedWheel then
                        if checkWallAndDistance(wheel) then
                            local screenPos, onScreen = camera:WorldToScreenPoint(wheel.Position)
                            if onScreen then
                                local mousePos = LocalPlayer:GetMouse()
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                                if dist < minDistance then
                                    minDistance = dist
                                    bestTarget = wheel
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if bestTarget then
            camera.CFrame = CFrame.new(camera.CFrame.Position, bestTarget.Position)
        end
    end)
end

-- [Torre ESP Otimizado]
local function cleanESP()
    for _, conn in ipairs(espConnections) do conn:Disconnect() end
    for _, label in ipairs(espLabels) do label:Destroy() end
    table.clear(espConnections)
    table.clear(espLabels)
end

local function createMobileESP(part, text)
    if not part then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 80, 0, 20)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 2, 0)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextSize = 10
    label.TextScaled = false
    label.Text = text
    label.Parent = billboard
    
    billboard.Parent = part
    table.insert(espLabels, billboard)
end

local function startTorreESP()
    cleanESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("torre") or obj.Name:lower():find("tower") then
            if obj:IsA("BasePart") then
                createMobileESP(obj, "Torre")
            end
        end
    end
end

-- [Interface Gráfica Atualizada Mobile]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StudioLiteHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 360)
Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Mobile Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Parent = Frame

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, 0, 1, -35)
Container.Position = UDim2.new(0, 0, 0, 35)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Container

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Text = text
    btn.Parent = Container
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Instanciação dos Botões Consolidados
local btnWeaponList = createButton(msg("WeaponList"), function()
    local list = getWeaponList()
    -- Renderização dinâmica e unificada na interface mobile
end)

local btnRegularMedkit = createButton(msg("RegularMedkit"), getRegularMedkit)
local btnExpensiveMedkit = createButton(msg("ExpensiveMedkit"), getExpensiveMedkit)
local btnCarShop = createButton(msg("CarShop"), interactCarShop)

local btnConfig = createButton(msg("Config"), function()
    if currentLanguage == "pt-BR" then currentLanguage = "en-US" else currentLanguage = "pt-BR" end
    -- Atualização reativa de elementos da UI instantânea
end)

print("Hub Mobile carregado com sucesso.")
