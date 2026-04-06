-- [[ ADVANCED FLASHBACK SYSTEM BY KERCX ]] --
-- Optimized for Delta Executor (Mobile/PC)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local lastSafePosition = root.CFrame
local isAutoRescueEnabled = true
local fallThreshold = -50 -- How many studs you fall before auto-teleport

-- UI CREATION
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local FlashbackBtn = Instance.new("TextButton")
local AutoToggle = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

-- ScreenGui Setup
ScreenGui.Name = "FlashbackSystemV2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (Draggable)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Parent = MainFrame

-- Title
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "FLASHBACK V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- Status Label
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextSize = 14

-- Flashback Button (Manual)
FlashbackBtn.Parent = MainFrame
FlashbackBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
FlashbackBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
FlashbackBtn.Size = UDim2.new(0.8, 0, 0, 40)
FlashbackBtn.Font = Enum.Font.GothamBold
FlashbackBtn.Text = "TELEPORT BACK"
FlashbackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlashbackBtn.TextSize = 14

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = FlashbackBtn

-- Auto-Rescue Toggle
AutoToggle.Parent = MainFrame
AutoToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoToggle.Position = UDim2.new(0.1, 0, 0.65, 0)
AutoToggle.Size = UDim2.new(0.8, 0, 0, 40)
AutoToggle.Font = Enum.Font.GothamBold
AutoToggle.Text = "AUTO RESCUE: ON"
AutoToggle.TextColor3 = Color3.fromRGB(0, 255, 127)
AutoToggle.TextSize = 14

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = AutoToggle

-- LOGIC --

-- Manual Flashback Function
FlashbackBtn.MouseButton1Click:Connect(function()
    root.CFrame = lastSafePosition
    StatusLabel.Text = "Status: Flashed Back!"
    task.wait(1)
    StatusLabel.Text = "Status: Ready"
end)

-- Toggle Auto-Rescue
AutoToggle.MouseButton1Click:Connect(function()
    isAutoRescueEnabled = not isAutoRescueEnabled
    if isAutoRescueEnabled then
        AutoToggle.Text = "AUTO RESCUE: ON"
        AutoToggle.TextColor3 = Color3.fromRGB(0, 255, 127)
    else
        AutoToggle.Text = "AUTO RESCUE: OFF"
        AutoToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Main Loop: Tracking Position & Falling
task.spawn(function()
    while true do
        if character and root and humanoid then
            -- Save position only if on ground
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                lastSafePosition = root.CFrame
            end
            
            -- Detect Fall (if character Y velocity is very low or falls below threshold)
            if isAutoRescueEnabled and root.Position.Y < (lastSafePosition.Position.Y + fallThreshold) then
                root.CFrame = lastSafePosition
                StatusLabel.Text = "Status: Auto-Saved!"
                task.wait(0.5)
            end
        end
        task.wait(0.1) -- High frequency tracking
    end
end)

print("Flashback System Loaded successfully!")
