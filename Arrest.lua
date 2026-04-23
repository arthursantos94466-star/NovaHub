local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local ArrestRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Arrest"):WaitForChild("Arrest")
local JailRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Arrest"):WaitForChild("Jail")

local jailPos = Vector3.new(173,4,12)
local blockedTools = {["Handcuffs"] = true, ["Malestin"] = true, ["Martilo"] = true}
local arrestedPlayers, skippedPlayers, attemptCooldown = {}, {}, {}
local selectedPlayer, autoMode, arrestAll, busy = nil, false, false, false

-- // LÓGICA ORIGINAL //
local function countTable(t) local n=0 for _ in pairs(t) do n+=1 end return n end
local function hasBlockedTool(plr)
    local function check(c) if not c then return false end for _,v in pairs(c:GetChildren()) do if blockedTools[v.Name] then return true end end end
    return check(plr:FindFirstChild("Backpack")) or check(plr.Character)
end
local function canAttempt(plr)
    attemptCooldown[plr] = attemptCooldown[plr] or 0
    if tick() - attemptCooldown[plr] > 1 then attemptCooldown[plr] = tick() return true end
end
local function getHandle(char)
    for _,v in pairs(char:GetChildren()) do if v:IsA("Accessory") then local h=v:FindFirstChild("Handle") if h then return h end end end
end
local function tp(cf)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cf
    end
end

local function arrest(plr)
    if busy or not plr or arrestedPlayers[plr] or skippedPlayers[plr] then return end
    if hasBlockedTool(plr) then skippedPlayers[plr]=true return end
    if not canAttempt(plr) then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local handle = getHandle(char)
    if not handle then skippedPlayers[plr]=true return end

    busy = true
    tp(char.HumanoidRootPart.CFrame * CFrame.new(0,0,2))
    task.wait(0.15)
    ArrestRemote:FireServer(handle)
    task.wait(0.25)
    tp(CFrame.new(jailPos))
    task.wait(0.35)
    JailRemote:FireServer()
    arrestedPlayers[plr] = true
    busy = false
end

local function getNextPlayer()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not arrestedPlayers[plr] and not skippedPlayers[plr] then return plr end
    end
end

-- // UI SETUP //
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "Arrest_Hub"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 340)
main.Position = UDim2.new(0.5, -130, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

-- Botão de Reabrir (Inicia invisível)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 80, 0, 35)
openBtn.Position = UDim2.new(0, 10, 0.5, -17)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
openBtn.Text = "ABRIR"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 12
openBtn.Visible = false
Instance.new("UICorner", openBtn)

-- Barra Superior
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "ARREST"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 30, 0, 25)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn)

-- Info e Botoes Principais
local info = Instance.new("TextLabel", main)
info.Size = UDim2.new(1, 0, 0, 20)
info.Position = UDim2.new(0, 0, 0, 40)
info.Text = "Presos: 0"
info.TextColor3 = Color3.fromRGB(150, 150, 150)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.BackgroundTransparency = 1

local allBtn = Instance.new("TextButton", main)
allBtn.Size = UDim2.new(0.45, 0, 0, 35)
allBtn.Position = UDim2.new(0, 10, 0, 65)
allBtn.Text = "ARREST ALL"
allBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 50)
allBtn.TextColor3 = Color3.new(1,1,1)
allBtn.Font = Enum.Font.GothamBold
allBtn.TextSize = 11
Instance.new("UICorner", allBtn)

local resetBtn = Instance.new("TextButton", main)
resetBtn.Size = UDim2.new(0.45, 0, 0, 35)
resetBtn.Position = UDim2.new(0.5, 5, 0, 65)
resetBtn.Text = "RESET LIST"
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 11
Instance.new("UICorner", resetBtn)

-- Scrolling List
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 0, 210)
scroll.Position = UDim2.new(0, 10, 0, 110)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)

-- // REFRESH LIST COM FEEDBACK "SUCCESS" //
local function refreshList()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local card = Instance.new("Frame", scroll)
            card.Size = UDim2.new(1, -5, 0, 35)
            card.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Instance.new("UICorner", card)

            local pName = Instance.new("TextLabel", card)
            pName.Size = UDim2.new(0.65, 0, 1, 0)
            pName.Position = UDim2.new(0, 10, 0, 0)
            pName.Text = plr.DisplayName
            pName.TextColor3 = Color3.new(1,1,1)
            pName.Font = Enum.Font.Gotham
            pName.TextSize = 11
            pName.BackgroundTransparency = 1
            pName.TextXAlignment = Enum.TextXAlignment.Left

            local arrestBtn = Instance.new("TextButton", card)
            arrestBtn.Size = UDim2.new(0.3, -5, 0.7, 0)
            arrestBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
            arrestBtn.Text = "ARREST"
            arrestBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 130)
            arrestBtn.TextColor3 = Color3.new(1,1,1)
            arrestBtn.Font = Enum.Font.GothamBold
            arrestBtn.TextSize = 9
            Instance.new("UICorner", arrestBtn)

            arrestBtn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                autoMode = true
                arrestAll = false
                arrestBtn.Text = "SUCCESS"
                arrestBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
                task.wait(1.5)
                arrestBtn.Text = "ARREST"
                arrestBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 130)
            end)
        end
    end
end

-- // CONTROLES //
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true openBtn.Visible = false end)

allBtn.MouseButton1Click:Connect(function()
    arrestAll = not arrestAll
    autoMode = false
    allBtn.Text = arrestAll and "STOP ALL" or "ARREST ALL"
    allBtn.BackgroundColor3 = arrestAll and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(40, 100, 50)
end)

resetBtn.MouseButton1Click:Connect(function()
    arrestedPlayers, skippedPlayers = {}, {}
    refreshList()
end)

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
refreshList()

task.spawn(function()
    while task.wait(0.3) do
        info.Text = "Presos: " .. countTable(arrestedPlayers)
        if autoMode and selectedPlayer then
            arrest(selectedPlayer)
        elseif arrestAll then
            arrest(getNextPlayer())
        end
    end
end)
