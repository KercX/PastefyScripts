============================================================
--   PASTEFYSCRIPTS | STEAL A BRAINROT ULTIMATE HUB
--   Version: 4.0.0 (Linkvertise + Discord Key System)
--   Features: Auto Farm, Auto Steal (RemoteEvent), Trade System,
--             ESP, Teleports, Fly, Noclip, FPS Boost, Clock
-- ============================================================

-- ==================== CONFIGURATION ====================
local DISCORD_URL = "https://discord.gg/jkqdmGdu8"
local VALID_KEYS_URL = "https://direct-link.net/4811480/tvbrevdkvPIG"  -- Raw text with keys (one per line)
local GAME_PLACE_ID = 109983668079237  -- Change if needed

-- ==================== KEY SYSTEM ====================
local keyVerified = false
local validKeys = {}

-- Fetch keys from remote URL
local function fetchKeys()
    local success, result = pcall(function()
        return game:HttpGet(VALID_KEYS_URL)
    end)
    if success then
        for line in string.gmatch(result, "[^\r\n]+") do
            table.insert(validKeys, line)
        end
        return #validKeys > 0
    else
        warn("Failed to fetch keys, using fallback local keys")
        -- Fallback local keys (change these)
        validKeys = {"FREE2025", "PASTEFYVIP", "BRAINROT"}
        return true
    end
end

-- Send execution log to Discord
local function logToDiscord(key, username)
    local data = {
        content = string.format("**Script Executed**\nUser: %s\nKey: %s\nGame: Steal a Brainrot\nTime: %s", username, key, os.date("%Y-%m-%d %H:%M:%S"))
    }
    local body = game:GetService("HttpService"):JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    pcall(function()
        request({Url = DISCORD_WEBHOOK_URL, Method = "POST", Headers = headers, Body = body})
    end)
end

-- Prompt user for key
local function promptKey()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local key = Rayfield:Input({
        Title = "PastefyScripts | License Key",
        Content = "Enter your key (obtain from Linkvertise):",
        Placeholder = "XXXX-XXXX-XXXX"
    })
    if key and table.find(validKeys, key) then
        keyVerified = true
        logToDiscord(key, game.Players.LocalPlayer.Name)
        Rayfield:Notify({Title = "Success", Content = "Key accepted. Loading hub...", Duration = 3})
        return true
    else
        Rayfield:Notify({Title = "Error", Content = "Invalid key. Script will not run.", Duration = 5})
        return false
    end
end

-- Initialize key system
fetchKeys()
if not promptKey() then return end

-- ==================== LOAD RAYFIELD ====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "PastefyScripts | Brainrot Ultimate Hub",
    LoadingTitle = "PastefyScripts",
    LoadingSubtitle = "Key System Active",
    Theme = "AmberGlow",
    ConfigurationSaving = { Enabled = true, FileName = "Pastefy_Brainrot" },
    KeySystem = false
})

-- ==================== TABS ====================
local FarmTab = Window:CreateTab("Farm", nil)
local TradeTab = Window:CreateTab("Trade", nil)
local TeleportTab = Window:CreateTab("Teleports", nil)
local VisualTab = Window:CreateTab("Visuals", nil)
local PlayerTab = Window:CreateTab("Player", nil)
local UtilityTab = Window:CreateTab("Utility", nil)

-- ==================== GLOBAL VARIABLES ====================
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Toggles
local autoFarm = false
local autoSteal = false
local autoUpgrade = false
local espEnabled = false
local flyEnabled = false
local noclipEnabled = false
local infiniteJump = false
local fpsBoost = false
local showClock = false
local currentSpeed = 16

-- RemoteEvent references (REPLACE WITH ACTUAL REMOTE NAMES)
local tradeRemote = ReplicatedStorage:FindFirstChild("TradeRequest") or Instance.new("RemoteEvent")
local stealRemote = ReplicatedStorage:FindFirstChild("StealBrainrot") or Instance.new("RemoteEvent")
local upgradeRemote = ReplicatedStorage:FindFirstChild("UpgradeItem") or Instance.new("RemoteEvent")

-- ESP storage
local espHighlights = {}
local clockLabel = nil

-- ==================== UTILITY FUNCTIONS ====================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function teleportTo(position)
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(position)
        Rayfield:Notify({Title = "Teleport", Content = "Done", Duration = 2})
    end
end

local function updateMovement()
    local char = getCharacter()
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = currentSpeed end
end

-- FPS Booster
local function setFPSBoost(state)
    if state then
        settings().Rendering.QualityLevel = 1
        Workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("ParticleEmitter") then
                desc:Destroy()
            end
        end)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then
                v:Destroy()
            end
        end
        Rayfield:Notify({Title = "FPS Boost", Content = "Enabled"})
    else
        settings().Rendering.QualityLevel = 21
        Rayfield:Notify({Title = "FPS Boost", Content = "Disabled"})
    end
end

-- Clock
local function createClock()
    if clockLabel then clockLabel:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PastefyClock"
    screenGui.Parent = player.PlayerGui
    clockLabel = Instance.new("TextLabel")
    clockLabel.Size = UDim2.new(0, 150, 0, 30)
    clockLabel.Position = UDim2.new(1, -160, 0, 10)
    clockLabel.BackgroundTransparency = 0.5
    clockLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    clockLabel.TextColor3 = Color3.new(1, 1, 1)
    clockLabel.Font = Enum.Font.GothamBold
    clockLabel.TextSize = 18
    clockLabel.Parent = screenGui
    spawn(function()
        while showClock and task.wait(1) do
            clockLabel.Text = os.date("%H:%M:%S")
        end
        if not showClock and clockLabel then clockLabel:Destroy() end
    end)
end

-- ==================== REMOTE EVENT TRADE SYSTEM ====================
local function sendTradeRequest(targetPlayer)
    if not targetPlayer then return end
    tradeRemote:FireServer(targetPlayer, "request")
    Rayfield:Notify({Title = "Trade", Content = "Request sent to " .. targetPlayer.Name})
end

-- ==================== FARM TAB ====================
FarmTab:CreateSection("Automation")

FarmTab:CreateToggle({
    Name = "Auto Farm Brainrots",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(v)
        autoFarm = v
        if v then
            spawn(function()
                while autoFarm and task.wait(0.5) do
                    local brainrots = Workspace:FindFirstChild("Drops") or Workspace:FindFirstChild("BrainrotItems")
                    if brainrots then
                        for _, item in pairs(brainrots:GetChildren()) do
                            if item:IsA("BasePart") and not item:FindFirstChild("HumanoidRootPart") then
                                teleportTo(item.Position)
                                task.wait(0.2)
                                local click = item:FindFirstChild("ClickDetector")
                                if click then fireclickdetector(click) end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Steal (RemoteEvent)",
    CurrentValue = false,
    Flag = "AutoSteal",
    Callback = function(v)
        autoSteal = v
        if v then
            spawn(function()
                while autoSteal and task.wait(0.3) do
                    for _, other in pairs(Players:GetPlayers()) do
                        if other ~= player and other.Character then
                            stealRemote:FireServer(other)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(v)
        autoUpgrade = v
        if v then
            spawn(function()
                while autoUpgrade and task.wait(2) do
                    upgradeRemote:FireServer()
                end
            end)
        end
    end
})

-- ==================== TRADE TAB ====================
TradeTab:CreateSection("Player Trading (RemoteEvent)")

TradeTab:CreateButton({
    Name = "Send Trade Request",
    Callback = function()
        local players = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then table.insert(players, p.Name) end
        end
        if #players == 0 then
            Rayfield:Notify({Title = "Error", Content = "No other players"})
            return
        end
        local targetName = Rayfield:Input({
            Title = "Trade",
            Content = "Enter player name:",
            Placeholder = players[1]
        })
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == targetName:lower() then
                sendTradeRequest(p)
                return
            end
        end
        Rayfield:Notify({Title = "Error", Content = "Player not found"})
    end
})

-- ==================== TELEPORT TAB ====================
TeleportTab:CreateSection("Quick Teleports")
local locations = {
    {"Brainrot Spawn", Vector3.new(0, 10, 0)},
    {"Safe Zone", Vector3.new(50, 5, 50)},
    {"Upgrades Area", Vector3.new(-50, 5, -50)},
    {"Your Base", Vector3.new(0, 5, 100)},
    {"Shop", Vector3.new(100, 5, 0)}
}
for _, loc in ipairs(locations) do
    TeleportTab:CreateButton({ Name = loc[1], Callback = function() teleportTo(loc[2]) end })
end

TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        local players = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then table.insert(players, p.Name) end
        end
        if #players == 0 then return end
        local target = Rayfield:Input({ Title = "Teleport", Content = "Player name:" })
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == target:lower() and p.Character then
                teleportTo(p.Character.HumanoidRootPart.Position)
                return
            end
        end
    end
})

local savedPos = nil
TeleportTab:CreateButton({ Name = "Save Position", Callback = function()
    local char = getCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPos = char.HumanoidRootPart.Position
        Rayfield:Notify({Title = "Saved", Content = "Position saved"})
    end
end })
TeleportTab:CreateButton({ Name = "Load Saved Position", Callback = function()
    if savedPos then teleportTo(savedPos) end
end })

-- ==================== VISUAL TAB ====================
VisualTab:CreateSection("ESP & Graphics")
VisualTab:CreateToggle({
    Name = "ESP Players & Items",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v)
        espEnabled = v
        if v then
            local function addHighlight(obj, color)
                local h = Instance.new("Highlight")
                h.FillColor = color
                h.OutlineColor = Color3.new(1,1,1)
                h.FillTransparency = 0.5
                h.Parent = obj
                table.insert(espHighlights, h)
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then addHighlight(p.Character, Color3.new(1,0,0)) end
            end
            local items = Workspace:FindFirstChild("Drops")
            if items then
                for _, it in pairs(items:GetChildren()) do addHighlight(it, Color3.new(0,1,0)) end
            end
        else
            for _, h in pairs(espHighlights) do h:Destroy() end
            espHighlights = {}
        end
    end
})
VisualTab:CreateSlider({ Name = "Field of View", Range = {70, 120}, Increment = 1, Suffix = "deg", CurrentValue = 70, Callback = function(v) Workspace.CurrentCamera.FieldOfView = v end })

-- ==================== PLAYER TAB ====================
PlayerTab:CreateSection("Movement")
PlayerTab:CreateSlider({ Name = "Walk Speed", Range = {16, 350}, Increment = 1, Suffix = "", CurrentValue = 16, Callback = function(v) currentSpeed = v; updateMovement() end })
PlayerTab:CreateSlider({ Name = "Jump Power", Range = {50, 350}, Increment = 5, Suffix = "", CurrentValue = 50, Callback = function(v) local hum = getCharacter():FindFirstChild("Humanoid"); if hum then hum.JumpPower = v end end })
PlayerTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump", Callback = function(v)
    infiniteJump = v
    if v then
        local conn
        conn = UserInputService.JumpRequest:Connect(function()
            if infiniteJump and player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        _G.InfJumpConn = conn
    else if _G.InfJumpConn then _G.InfJumpConn:Disconnect() end end
end })
PlayerTab:CreateToggle({ Name = "Fly Mode (WASD + Space/Shift)", CurrentValue = false, Flag = "Fly", Callback = function(v)
    flyEnabled = v
    local char = getCharacter()
    if char then
        if v then
            char.Humanoid.PlatformStand = true
            local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = char.HumanoidRootPart
            local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.Parent = char.HumanoidRootPart
            _G.FlyBV, _G.FlyBG = bv, bg
            RunService.RenderStepped:Connect(function()
                if not flyEnabled then return end
                local cam = Workspace.CurrentCamera
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then _G.FlyBV.Velocity = dir.Unit * 80 else _G.FlyBV.Velocity = Vector3.new(0,0,0) end
                _G.FlyBG.CFrame = CFrame.new(char.HumanoidRootPart.Position, char.HumanoidRootPart.Position + cam.CFrame.LookVector)
            end)
        else
            char.Humanoid.PlatformStand = false
            if _G.FlyBV then _G.FlyBV:Destroy() end; if _G.FlyBG then _G.FlyBG:Destroy() end
        end
    end
end })
PlayerTab:CreateToggle({ Name = "NoClip (Walk through walls)", CurrentValue = false, Flag = "Noclip", Callback = function(v)
    noclipEnabled = v
    if v then
        RunService.Stepped:Connect(function()
            if noclipEnabled and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end
    end
end })

-- ==================== UTILITY TAB ====================
UtilityTab:CreateSection("Performance & Info")
UtilityTab:CreateToggle({ Name = "FPS Boost (Low Graphics)", CurrentValue = false, Flag = "FPSBoost", Callback = function(v) setFPSBoost(v) end })
UtilityTab:CreateToggle({ Name = "Show Clock (HH:MM:SS)", CurrentValue = false, Flag = "Clock", Callback = function(v) showClock = v; if v then createClock() elseif clockLabel then clockLabel:Destroy() end end })
UtilityTab:CreateButton({ Name = "Get Current FPS", Callback = function() local fps = math.floor(1 / RunService.RenderStepped:Wait()); Rayfield:Notify({Title = "FPS", Content = tostring(fps)}) end })
UtilityTab:CreateButton({ Name = "Show My Coordinates", Callback = function()
    local char = getCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        Rayfield:Notify({Title = "Coordinates", Content = string.format("X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z)})
    end
end })
UtilityTab:CreateButton({ Name = "Rejoin Game", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end })
