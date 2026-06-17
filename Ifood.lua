local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local IfuudEvent = Remotes:WaitForChild("IfuudEvent")

-- GUI - APENAS UM BOTÃO
local Gui = Instance.new("ScreenGui")
Gui.Name =
