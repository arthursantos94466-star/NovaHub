-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window
local Window = Rayfield:CreateWindow({
   Name = "Nebula Hub",
   LoadingTitle = "Nebula Hub",
   LoadingSubtitle = "by Arthur",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local WorldTab = Window:CreateTab("World", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

---------------------------------------------------
-- WALK SPEED
---------------------------------------------------

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

---------------------------------------------------
-- JUMP POWER
---------------------------------------------------

PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

---------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------

local InfiniteJump = false

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value)
      InfiniteJump = Value
   end,
})

game:GetService("UserInputService").JumpRequest:connect(function()
   if InfiniteJump then
      game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
   end
end)

---------------------------------------------------
-- NOCLIP
---------------------------------------------------

local noclip = false

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(Value)
      noclip = Value
   end,
})

game:GetService("RunService").Stepped:Connect(function()
   if noclip then
      for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
         if v:IsA("BasePart") then
            v.CanCollide = false
         end
      end
   end
end)

---------------------------------------------------
-- FLY (REAL)
---------------------------------------------------

local flying = false
local speed = 50

PlayerTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(Value)
      flying = Value

      if flying then
         local player = game.Players.LocalPlayer
         local char = player.Character
         local hrp = char:WaitForChild("HumanoidRootPart")

         local bv = Instance.new("BodyVelocity")
         bv.MaxForce = Vector3.new(9e9,9e9,9e9)
         bv.Parent = hrp

         while flying do
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
            task.wait()
         end

         bv:Destroy()
      end
   end,
})

---------------------------------------------------
-- TELEPORT CLICK
---------------------------------------------------

local clicktp = false

TeleportTab:CreateToggle({
   Name = "Click Teleport",
   CurrentValue = false,
   Callback = function(Value)
      clicktp = Value
   end,
})

local mouse = game.Players.LocalPlayer:GetMouse()

mouse.Button1Down:Connect(function()
   if clicktp then
      game.Players.LocalPlayer.Character:MoveTo(mouse.Hit.p)
   end
end)

---------------------------------------------------
-- CAMERA ZOOM
---------------------------------------------------

WorldTab:CreateSlider({
   Name = "Camera Zoom",
   Range = {20, 500},
   Increment = 5,
   CurrentValue = 20,
   Callback = function(Value)
      game.Players.LocalPlayer.CameraMaxZoomDistance = Value
   end,
})

---------------------------------------------------
-- RESET ZOOM
---------------------------------------------------

WorldTab:CreateButton({
   Name = "Reset Zoom",
   Callback = function()
      game.Players.LocalPlayer.CameraMaxZoomDistance = 20
   end,
})

---------------------------------------------------
-- FULLBRIGHT
---------------------------------------------------

WorldTab:CreateToggle({
   Name = "FullBright",
   CurrentValue = false,
   Callback = function(Value)

      if Value then
         game.Lighting.Brightness = 2
         game.Lighting.ClockTime = 14
         game.Lighting.FogEnd = 100000
         game.Lighting.GlobalShadows = false
      else
         game.Lighting.Brightness = 1
      end

   end,
})

---------------------------------------------------
-- FOV
---------------------------------------------------

WorldTab:CreateSlider({
   Name = "FOV",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(Value)
      workspace.CurrentCamera.FieldOfView = Value
   end,
})
