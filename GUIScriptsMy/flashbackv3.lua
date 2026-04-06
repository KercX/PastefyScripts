-- [[ FLASHBACK V3 ]] --

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- SETTINGS
local lastPos = root.CFrame
local autoBack = true
local fallLimit = 40
local ghostEnabled = true
local speedVal = 16

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Flashback_V5_Ultimate"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Main.Position = UDim2.new(0.1, 0, 0.25, 0)
Main.Size = UDim2.new(0, 260, 0, 340)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 18)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.5
Stroke.Color = Color3.fromRGB(130, 0, 255)

-- TITLE & GLOW
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "FLASHBACK V5 ELITE"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- GHOST MARKER LOGIC
local Ghost = Instance.new("Part")
Ghost.Name = "Flashback_Ghost"
Ghost.Size = Vector3.new(2, 2, 1)
Ghost.Anchored = true
Ghost.CanCollide = false
Ghost.Transparency = 0.7
Ghost.Material = Enum.Material.ForceField
Ghost.Color = Color3.fromRGB(130, 0, 255)
Ghost.Parent = workspace

-- BUTTON GENERATOR
local function CreateBtn(name, text, pos, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Name = name
    b.Size = UDim2.new(0.85, 0, 0, 42)
    b.Position = pos
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- 1. MANUAL RECALL
local Recall = CreateBtn("Recall", "RECALL POSITION ↩️", UDim2.new(0.075, 0, 0.18, 0), Color3.fromRGB(70, 0, 180), function()
    root.Velocity = Vector3.new(0,0,0)
    root.CFrame = lastPos
end)

-- 2. AUTO TOGGLE
local AutoBtn = CreateBtn("Auto", "AUTO RESCUE: ON ✅", UDim2.new(0.075, 0, 0.33, 0), Color3.fromRGB(0, 140, 80), function(self)
    autoBack = not autoBack
    AutoBtn.Text = autoBack and "AUTO RESCUE: ON ✅" or "AUTO RESCUE: OFF ❌"
    AutoBtn.BackgroundColor3 = autoBack and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(140, 40, 40)
end)

-- 3. SLIDER FOR FALL DISTANCE
local SliderFrame = Instance.new("Frame", Main)
SliderFrame.Size = UDim2.new(0.85, 0, 0, 50)
SliderFrame.Position = UDim2.new(0.075, 0, 0.48, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
SliderLabel.Text = "Fall Sensitivity: 40"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.BackgroundTransparency = 1

local SliderBtn = Instance.new("TextButton", SliderFrame)
SliderBtn.Size = UDim2.new(0.9, 0, 0.2, 0)
SliderBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
SliderBtn.Text = ""
Instance.new("UICorner", SliderBtn)

SliderBtn.MouseButton1Click:Connect(function()
    fallLimit = (fallLimit == 40) and 20 or (fallLimit == 20 and 80 or 40)
    SliderLabel.Text = "Fall Sensitivity: " .. fallLimit
end)

-- 4. SPEED HACK
local SpeedBtn = CreateBtn("Speed", "SPEED: NORMAL", UDim2.new(0.075, 0, 0.68, 0), Color3.fromRGB(50, 50, 60), function()
    speedVal = (speedVal == 16) and 100 or 16
    humanoid.WalkSpeed = speedVal
    SpeedBtn.Text = (speedVal == 100) and "SPEED: BLUR ⚡" or "SPEED: NORMAL"
    SpeedBtn.BackgroundColor3 = (speedVal == 100) and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(50, 50, 60)
end)

-- 5. CLOSE
local Close = CreateBtn("Close", "DESTROY GUI", UDim2.new(0.075, 0, 0.83, 0), Color3.fromRGB(20, 20, 25), function()
    ScreenGui:Destroy()
    Ghost:Destroy()
end)

-- CORE LOOP
task.spawn(function()
    while task.wait(0.05) do
        if character and root and humanoid then
            -- Update safe spot
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                lastPos = root.CFrame
                Ghost.CFrame = lastPos * CFrame.new(0, -2.5, 0)
            end
            
            -- Detect Fall
            local currentFall = lastPos.Position.Y - root.Position.Y
            if autoBack and currentFall > fallLimit then
                root.Velocity = Vector3.new(0,0,0)
                root.CFrame = lastPos
                
                -- Flash effect
                Main.UIStroke.Color = Color3.fromRGB(255, 255, 255)
                task.wait(0.1)
                Main.UIStroke.Color = Color3.fromRGB(130, 0, 255)
            end
        end
    end
end)

print("Flashback v4 load!")
