--// MOBILE BRAINROT FARM GUI

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local autoFarm = false
local farming = false

-- PASTAS
local selectedFolders = {
	Common = true,
	Uncommon = true,
	Rare = true,
	Epic = true,
	Legendary = true,
	Mythical = true,
	Secret = true,
	Celestial = true,
	Cosmic = true,
	God = true
}

-- ENTREGA
local deliverPosition = CFrame.new(
	14.61732292175293,
	3.674546957015991,
	15.138176918029785
)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotFarm"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- MAIN
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,270,0,430)
frame.Position = UDim2.new(0.5,-135,0.5,-215)

frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame)
	.CornerRadius = UDim.new(0,16)

local stroke = Instance.new("UIStroke")
stroke.Parent = frame
stroke.Color = Color3.fromRGB(50,50,50)

-- TITLE
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,35)

title.BackgroundTransparency = 1
title.Text = "Brainrot Farm"

title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)

-- CLOSE
local close = Instance.new("TextButton")
close.Parent = frame

close.Size = UDim2.new(0,24,0,24)
close.Position = UDim2.new(1,-30,0,6)

close.Text = "✕"

close.Font = Enum.Font.GothamBold
close.TextSize = 14

close.BackgroundColor3 =
	Color3.fromRGB(35,35,35)

close.TextColor3 = Color3.new(1,1,1)
close.BorderSizePixel = 0

Instance.new("UICorner", close)
	.CornerRadius = UDim.new(1,0)

-- STATUS
local status = Instance.new("TextLabel")
status.Parent = frame

status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,0,35)

status.BackgroundTransparency = 1
status.Text = "Status: OFF"

status.Font = Enum.Font.Gotham
status.TextSize = 13

status.TextColor3 =
	Color3.fromRGB(170,170,170)

-- ON
local on = Instance.new("TextButton")
on.Parent = frame

on.Size = UDim2.new(0.4,0,0,32)
on.Position = UDim2.new(0.08,0,0.16,0)

on.Text = "ON"

on.Font = Enum.Font.GothamBold
on.TextSize = 14

on.BackgroundColor3 =
	Color3.fromRGB(40,150,70)

on.TextColor3 = Color3.new(1,1,1)
on.BorderSizePixel = 0

Instance.new("UICorner", on)
	.CornerRadius = UDim.new(0,10)

-- OFF
local off = Instance.new("TextButton")
off.Parent = frame

off.Size = UDim2.new(0.4,0,0,32)
off.Position = UDim2.new(0.52,0,0.16,0)

off.Text = "OFF"

off.Font = Enum.Font.GothamBold
off.TextSize = 14

off.BackgroundColor3 =
	Color3.fromRGB(170,50,50)

off.TextColor3 = Color3.new(1,1,1)
off.BorderSizePixel = 0

Instance.new("UICorner", off)
	.CornerRadius = UDim.new(0,10)

-- OPEN LIST
local openList = Instance.new("TextButton")
openList.Parent = frame

openList.Size = UDim2.new(0.84,0,0,32)
openList.Position = UDim2.new(0.08,0,0.28,0)

openList.Text = "Open Brainrot List"

openList.Font = Enum.Font.GothamBold
openList.TextSize = 13

openList.BackgroundColor3 =
	Color3.fromRGB(50,90,170)

openList.TextColor3 =
	Color3.new(1,1,1)

openList.BorderSizePixel = 0

Instance.new("UICorner", openList)
	.CornerRadius = UDim.new(0,10)

-- LABEL
local folderLabel = Instance.new("TextLabel")
folderLabel.Parent = frame

folderLabel.Size = UDim2.new(1,0,0,25)
folderLabel.Position = UDim2.new(0,0,0.49,0)

folderLabel.BackgroundTransparency = 1
folderLabel.Text = "Selected Folders"

folderLabel.Font = Enum.Font.GothamBold
folderLabel.TextSize = 14

folderLabel.TextColor3 =
	Color3.new(1,1,1)

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame

scroll.Size = UDim2.new(0.84,0,0,150)
scroll.Position = UDim2.new(0.08,0,0.58,0)

scroll.BackgroundColor3 =
	Color3.fromRGB(25,25,25)

scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4

Instance.new("UICorner", scroll)
	.CornerRadius = UDim.new(0,10)

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0,6)

-- FOLDERS
local folderNames = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"Mythical",
	"Secret",
	"Celestial",
	"Cosmic",
	"God"
	}

for _, folderName in pairs(folderNames) do

	local button = Instance.new("TextButton")
	button.Parent = scroll

	button.Size = UDim2.new(1,-8,0,32)

	button.Text = folderName.." : ON"

	button.Font = Enum.Font.GothamBold
	button.TextSize = 13

	button.BackgroundColor3 =
		Color3.fromRGB(40,140,70)

	button.TextColor3 =
		Color3.new(1,1,1)

	button.BorderSizePixel = 0

	Instance.new("UICorner", button)
		.CornerRadius = UDim.new(0,8)

	button.MouseButton1Click:Connect(function()

		selectedFolders[folderName] =
			not selectedFolders[folderName]

		if selectedFolders[folderName] then

			button.Text =
				folderName.." : ON"

			button.BackgroundColor3 =
				Color3.fromRGB(40,140,70)

		else

			button.Text =
				folderName.." : OFF"

			button.BackgroundColor3 =
				Color3.fromRGB(150,50,50)
		end
	end)
end

task.wait()

scroll.CanvasSize = UDim2.new(
	0,
	0,
	0,
	layout.AbsoluteContentSize.Y + 10
)

-- OPEN BUTTON
local open = Instance.new("TextButton")
open.Parent = gui

open.Size = UDim2.new(0,52,0,52)
open.Position = UDim2.new(0,15,0.5,-26)

open.Text = "☰"

open.Font = Enum.Font.GothamBold
open.TextSize = 22

open.BackgroundColor3 =
	Color3.fromRGB(20,20,20)

open.TextColor3 = Color3.new(1,1,1)

open.Visible = false
open.Active = true
open.Draggable = true
open.BorderSizePixel = 0

Instance.new("UICorner", open)
	.CornerRadius = UDim.new(1,0)

local openStroke = Instance.new("UIStroke")
openStroke.Parent = open
openStroke.Color = Color3.fromRGB(50,50,50)

-- GUI LIST
local listGui = Instance.new("Frame")
listGui.Parent = gui

listGui.Size = UDim2.new(0,280,0,320)
listGui.Position = UDim2.new(0.5,-140,0.5,-160)

listGui.BackgroundColor3 =
	Color3.fromRGB(20,20,20)

listGui.BorderSizePixel = 0
listGui.Visible = false
listGui.Active = true
listGui.Draggable = true

Instance.new("UICorner", listGui)
	.CornerRadius = UDim.new(0,16)

local listStroke = Instance.new("UIStroke")
listStroke.Parent = listGui
listStroke.Color = Color3.fromRGB(50,50,50)

-- TITLE
local listTitle = Instance.new("TextLabel")
listTitle.Parent = listGui

listTitle.Size = UDim2.new(1,0,0,35)

listTitle.BackgroundTransparency = 1
listTitle.Text = "Brainrot List"

listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 17

listTitle.TextColor3 =
	Color3.new(1,1,1)

-- CLOSE LIST
local closeList = Instance.new("TextButton")
closeList.Parent = listGui

closeList.Size = UDim2.new(0,24,0,24)
closeList.Position = UDim2.new(1,-30,0,6)

closeList.Text = "✕"

closeList.Font = Enum.Font.GothamBold
closeList.TextSize = 14

closeList.BackgroundColor3 =
	Color3.fromRGB(35,35,35)

closeList.TextColor3 =
	Color3.new(1,1,1)

closeList.BorderSizePixel = 0

Instance.new("UICorner", closeList)
	.CornerRadius = UDim.new(1,0)

-- LIST SCROLL
local listScroll = Instance.new("ScrollingFrame")
listScroll.Parent = listGui

listScroll.Size = UDim2.new(0.9,0,0.82,0)
listScroll.Position = UDim2.new(0.05,0,0.12,0)

listScroll.BackgroundColor3 =
	Color3.fromRGB(25,25,25)

listScroll.BorderSizePixel = 0
listScroll.ScrollBarThickness = 4

Instance.new("UICorner", listScroll)
	.CornerRadius = UDim.new(0,10)

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = listScroll
listLayout.Padding = UDim.new(0,6)

-- VALUE LIST
local function checkBrainrotValues()

	for _, child in pairs(
		listScroll:GetChildren()
	) do

		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local brainrots = {}

	for _, tool in pairs(
		player.Backpack:GetChildren()
	) do

		if tool:IsA("Tool") then

			local earnings =
				tool:FindFirstChild(
					"Earnings",
					true
				)

			if earnings
			and earnings:IsA("TextLabel") then

				local text =
					earnings.ContentText

				if text == ""
				or text == nil then

					text = earnings.Text
				end

				text =
					tostring(text):upper()

				local number, suffix =
					text:match(
						"([%d%.]+)%s*([KMBT]?)"
					)

				number = tonumber(number)

				local value = 0

				if number then

					if suffix == "K" then
						value = number * 1000

					elseif suffix == "M" then
						value = number * 1000000

					elseif suffix == "B" then
						value = number * 1000000000

					elseif suffix == "T" then
						value = number * 1000000000000

					else
						value = number
					end

					table.insert(brainrots,{
						Tool = tool,
						Name = tool.Name,
						Value = value,
						Display = text
					})
				end
			end
		end
	end

	table.sort(brainrots,function(a,b)
		return a.Value > b.Value
	end)

	for index, brainrot in ipairs(brainrots) do

		local item =
			Instance.new("TextButton")

		item.Parent = listScroll

		item.Size =
			UDim2.new(1,-8,0,32)

		item.Text =
			index..
			". "..brainrot.Name..
			" | "..brainrot.Display

		item.Font =
			Enum.Font.GothamBold

		item.TextSize = 12

		item.BackgroundColor3 =
			Color3.fromRGB(35,35,35)

		item.TextColor3 =
			Color3.new(1,1,1)

		item.BorderSizePixel = 0

		Instance.new("UICorner", item)
			.CornerRadius = UDim.new(0,8)

		item.MouseButton1Click:Connect(function()

			local character =
				player.Character
				or player.CharacterAdded:Wait()

			local humanoid =
				character:WaitForChild(
					"Humanoid"
				)

			humanoid:EquipTool(
				brainrot.Tool
			)
		end)
	end

	task.wait()

	listScroll.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			listLayout.AbsoluteContentSize.Y + 10
		)
end

-- PEGAR
local function grabBrainrot(model)

	local prompt =
		model:FindFirstChildWhichIsA(
			"ProximityPrompt",
			true
		)

	local part =
		model:FindFirstChildWhichIsA(
			"BasePart"
		)

	if prompt and part then

		local character =
			player.Character
			or player.CharacterAdded:Wait()

		local hrp =
			character:WaitForChild(
				"HumanoidRootPart"
			)

		local humanoid =
			character:WaitForChild(
				"Humanoid"
			)

		hrp.CFrame =
			part.CFrame + Vector3.new(0,2,0)

		task.wait(0.18)

		fireproximityprompt(prompt)

		task.wait(0.3)

		humanoid:UnequipTools()

		task.wait(0.1)

		hrp.CFrame = deliverPosition

		task.wait(0.45)

		humanoid:UnequipTools()
	end
end

-- FARM
local function startFarm()

	if farming then
		return
	end

	farming = true

	task.spawn(function()

		while autoFarm do

			status.Text = "Status: ON"

			local spawners =
				workspace:FindFirstChild(
					"ItemSpawners"
				)

			if spawners then

				for _, rarityFolder in pairs(
					spawners:GetChildren()
				) do

					if selectedFolders[
						rarityFolder.Name
					] then

						for _, brainrot in pairs(
							rarityFolder:GetChildren()
						) do

							if not autoFarm then
								break
							end

							if brainrot:IsA("Model") then
								grabBrainrot(brainrot)
							end
						end
					end
				end
			end

			local godSpawn =
				workspace:FindFirstChild(
					"GOD_BRAINROT_SPAWN"
				)

			if godSpawn then

				for _, brainrot in pairs(
					godSpawn:GetDescendants()
				) do

					if not autoFarm then
						break
					end

					if brainrot:IsA("Model") then
						grabBrainrot(brainrot)
					end
				end
			end

			task.wait(0.15)
		end

		farming = false
	end)
end

-- BUTTONS
on.MouseButton1Click:Connect(function()

	autoFarm = true
	status.Text = "Status: ON"

	startFarm()
end)

off.MouseButton1Click:Connect(function()

	autoFarm = false
	status.Text = "Status: OFF"
end)

openList.MouseButton1Click:Connect(function()

	listGui.Visible = true

	checkBrainrotValues()
end)

closeList.MouseButton1Click:Connect(function()

	listGui.Visible = false
end)

close.MouseButton1Click:Connect(function()

	frame.Visible = false
	open.Visible = true
end)

open.MouseButton1Click:Connect(function()

	frame.Visible = true
	open.Visible = false
end)
