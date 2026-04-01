task.wait(0.1)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local ChatService = game:GetService("TextChatService") or game:GetService("Chat")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiScale = isMobile and 0.55 or 1

local sg = Instance.new("ScreenGui")
sg.Name = "KingHubDuels"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = Player:WaitForChild("PlayerGui")

local W, H = 560 * guiScale, 600 * guiScale

local Features = {
    SpeedBoost = false,
    AntiRagdoll = false,
    AutoSteal  = false,
    BatAimbot = false,
    SpeedWhileStealing = false,
    MeleeAimbot = false,
    SpinBot = false,
    InfJump = false,
    Unwalk = false,
    Optimizer = false,
    XRay = false,
    Float = false,
    RightSteal = false,
    LeftSteal = false,
    WalkFling = false,
    TPRightAuto = false,
    TPLeftAuto  = false,
    AutoPathRight = false,
    AutoPathLeft = false,
    QuickTPRight = false,
    QuickTPLeft = false,
}

local Values = {
    BoostSpeed           = 30,
    SpinSpeed            = 10,
    StealingSpeedValue   = 29,
    STEAL_RADIUS         = 8,
}

local AutoStealValues = {
    STEAL_RADIUS   = 8,
    STEAL_DURATION = 0.20,
}

local speedKeybind = Enum.KeyCode.E
local floatKeybind = Enum.KeyCode.F
local rightKeybind = Enum.KeyCode.E
local leftKeybind = Enum.KeyCode.Q
local batKeybind = Enum.KeyCode.G
local meleeKeybind = Enum.KeyCode.H
local autoPathRightKeybind = Enum.KeyCode.C
local autoPathLeftKeybind = Enum.KeyCode.Z
local quickTPRightKeybind = Enum.KeyCode.X
local quickTPLeftKeybind = Enum.KeyCode.V
local taughtKeybind = Enum.KeyCode.T

local HttpService = game:GetService("HttpService")
local configFile = "KingHubDuels_config.json"
if isfile(configFile) then
    local success, loaded = pcall(HttpService.JSONDecode, HttpService, readfile(configFile))
    if success then
        for k, v in pairs(loaded.features or {}) do Features[k] = v end
        for k, v in pairs(loaded.values or {}) do Values[k] = v end
        if loaded.keybinds then
            if loaded.keybinds.speedBoost then speedKeybind = Enum.KeyCode[loaded.keybinds.speedBoost] end
            if loaded.keybinds.float then floatKeybind = Enum.KeyCode[loaded.keybinds.float] end
            if loaded.keybinds.rightSteal then rightKeybind = Enum.KeyCode[loaded.keybinds.rightSteal] end
            if loaded.keybinds.leftSteal then leftKeybind = Enum.KeyCode[loaded.keybinds.leftSteal] end
            if loaded.keybinds.batAimbot then batKeybind = Enum.KeyCode[loaded.keybinds.batAimbot] end
            if loaded.keybinds.meleeAimbot then meleeKeybind = Enum.KeyCode[loaded.keybinds.meleeAimbot] end
            if loaded.keybinds.autoPathRight then autoPathRightKeybind = Enum.KeyCode[loaded.keybinds.autoPathRight] end
            if loaded.keybinds.autoPathLeft then autoPathLeftKeybind = Enum.KeyCode[loaded.keybinds.autoPathLeft] end
            if loaded.keybinds.quickTPRight then quickTPRightKeybind = Enum.KeyCode[loaded.keybinds.quickTPRight] end
            if loaded.keybinds.quickTPLeft then quickTPLeftKeybind = Enum.KeyCode[loaded.keybinds.quickTPLeft] end
            if loaded.keybinds.taught then taughtKeybind = Enum.KeyCode[loaded.keybinds.taught] end
        end
    end
end
AutoStealValues.STEAL_RADIUS = Values.STEAL_RADIUS

-- Color scheme
local GOLD = Color3.fromRGB(255, 215, 0)
local DARK_GOLD = Color3.fromRGB(184, 134, 11)
local BLACK = Color3.fromRGB(0, 0, 0)
local DARK_GRAY = Color3.fromRGB(20, 20, 20)
local COMPACT_BG = Color3.fromRGB(15, 15, 15)

-- Crown Menu Button (always visible)
local menuButton = Instance.new("TextButton", sg)
menuButton.Name = "MenuButton"
menuButton.Size = UDim2.new(0, 70 * guiScale, 0, 70 * guiScale)
menuButton.Position = UDim2.new(0, 15, 1, -85)
menuButton.BackgroundColor3 = BLACK
menuButton.BackgroundTransparency = 0.2
menuButton.Text = "ðŸ‘‘"
menuButton.TextColor3 = GOLD
menuButton.Font = Enum.Font.GothamBlack
menuButton.TextSize = 45 * guiScale
menuButton.BorderSizePixel = 0
menuButton.ZIndex = 100
menuButton.Visible = true

local menuCorner = Instance.new("UICorner", menuButton)
menuCorner.CornerRadius = UDim.new(0, 35 * guiScale)

local menuStroke = Instance.new("UIStroke", menuButton)
menuStroke.Thickness = 3 * guiScale
menuStroke.Color = GOLD
menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local menuGlow = Instance.new("ImageLabel", menuButton)
menuGlow.Size = UDim2.new(1.3, 0, 1.3, 0)
menuGlow.Position = UDim2.new(-0.15, 0, -0.15, 0)
menuGlow.BackgroundTransparency = 1
menuGlow.Image = "rbxassetid://5025667403"
menuGlow.ImageColor3 = GOLD
menuGlow.ImageTransparency = 0.6
menuGlow.ZIndex = 99
menuGlow.Visible = true

-- Progress Bar
local ProgressBarFill   = nil
local ProgressLabel     = nil
local ProgressPercentLabel = nil
local progressConn      = nil
local stealStartTime    = nil

local function resetProgressBar()
    if ProgressLabel        then ProgressLabel.Text = "READY" end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "0%" end
    if ProgressBarFill      then ProgressBarFill.Size = UDim2.new(0, 0, 1, 0) end
end

local PB_W = 260 * guiScale
local PB_H = 28 * guiScale

local progressBar = Instance.new("Frame", sg)
progressBar.Size = UDim2.new(0, PB_W, 0, PB_H)
progressBar.Position = UDim2.new(0.5, -PB_W / 2, 1, -90 * guiScale)
progressBar.BackgroundColor3 = BLACK
progressBar.BackgroundTransparency = 0.2
progressBar.BorderSizePixel = 0
progressBar.ClipsDescendants = false
progressBar.ZIndex = 10
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

local pStroke = Instance.new("UIStroke", progressBar)
pStroke.Thickness = 2 * guiScale
pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pStroke.Color = GOLD

local pGradient = Instance.new("UIGradient", pStroke)
pGradient.Color = ColorSequence.new(GOLD, DARK_GOLD)

local pTrack = Instance.new("Frame", progressBar)
pTrack.Size = UDim2.new(1, -8 * guiScale, 0, 6 * guiScale)
pTrack.Position = UDim2.new(0, 4 * guiScale, 1, -9 * guiScale)
pTrack.BackgroundColor3 = DARK_GRAY
pTrack.BorderSizePixel = 0
pTrack.ZIndex = 11
Instance.new("UICorner", pTrack).CornerRadius = UDim.new(1, 0)

ProgressBarFill = Instance.new("Frame", pTrack)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = GOLD
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 12
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)

local fillGradient = Instance.new("UIGradient", ProgressBarFill)
fillGradient.Color = ColorSequence.new(GOLD, DARK_GOLD)

ProgressPercentLabel = Instance.new("TextLabel", progressBar)
ProgressPercentLabel.Size = UDim2.new(1, 0, 1, -8 * guiScale)
ProgressPercentLabel.Position = UDim2.new(0, 0, 0, 0)
ProgressPercentLabel.BackgroundTransparency = 1
ProgressPercentLabel.Text = "0%"
ProgressPercentLabel.Font = Enum.Font.GothamBlack
ProgressPercentLabel.TextSize = 13 * guiScale
ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Center
ProgressPercentLabel.TextYAlignment = Enum.TextYAlignment.Center
ProgressPercentLabel.TextColor3 = GOLD
ProgressPercentLabel.ZIndex = 13

ProgressLabel = Instance.new("TextLabel", progressBar)
ProgressLabel.Size = UDim2.new(0, 0, 0, 0)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "READY"
ProgressLabel.TextColor3 = Color3.fromRGB(255,255,255)
ProgressLabel.Font = Enum.Font.GothamBlack
ProgressLabel.TextSize = 1
ProgressLabel.ZIndex = 1
ProgressLabel.Visible = false

-- Main GUI Frame
local main = Instance.new("Frame", sg)
main.Name = "Main"
main.Size = UDim2.new(0, W, 0, H)
main.Position = isMobile
    and UDim2.new(0.5, -W/2, 0.5, -H/2)
    or  UDim2.new(1, -W - 20, 0, 20)
main.BackgroundColor3 = BLACK
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = false
main.ClipsDescendants = true
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12 * guiScale)

local headerH = 54 * guiScale
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, headerH)
header.BackgroundColor3 = BLACK
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.ZIndex = 4
header.Active = true
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12 * guiScale)

local headerBottom = Instance.new("Frame", header)
headerBottom.Size = UDim2.new(1, 0, 0.5, 0)
headerBottom.Position = UDim2.new(0, 0, 0.5, 0)
headerBottom.BackgroundColor3 = BLACK
headerBottom.BackgroundTransparency = 0.2
headerBottom.BorderSizePixel = 0
headerBottom.ZIndex = 3

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, 0, 0.55, 0)
title.Position = UDim2.new(0, 0, 0.05, 0)
title.BackgroundTransparency = 1
title.Text = "KING HUB DUELS"
title.Font = Enum.Font.GothamBlack
title.TextSize = 15 * guiScale
title.TextColor3 = GOLD
title.ZIndex = 6

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, 0, 0.35, 0)
subtitle.Position = UDim2.new(0, 0, 0.6, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "discord.gg/mFZHq5XxmX"
subtitle.TextColor3 = DARK_GOLD
subtitle.Font = Enum.Font.GothamBlack
subtitle.TextSize = 10 * guiScale
subtitle.ZIndex = 6

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 28 * guiScale, 0, 28 * guiScale)
closeBtn.Position = UDim2.new(1, -36 * guiScale, 0.5, -14 * guiScale)
closeBtn.BackgroundColor3 = DARK_GRAY
closeBtn.Text = "âœ•"
closeBtn.TextColor3 = GOLD
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 13 * guiScale
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 7
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6 * guiScale)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 40, 20)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = DARK_GRAY}):Play()
end)

-- Crown menu button click handler
menuButton.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        TweenService:Create(menuButton, TweenInfo.new(0.2), {BackgroundColor3 = DARK_GOLD, TextSize = 50 * guiScale}):Play()
        TweenService:Create(menuStroke, TweenInfo.new(0.2), {Color = DARK_GOLD}):Play()
        TweenService:Create(menuGlow, TweenInfo.new(0.2), {ImageTransparency = 0.3}):Play()
    else
        TweenService:Create(menuButton, TweenInfo.new(0.2), {BackgroundColor3 = BLACK, TextSize = 45 * guiScale}):Play()
        TweenService:Create(menuStroke, TweenInfo.new(0.2), {Color = GOLD}):Play()
        TweenService:Create(menuGlow, TweenInfo.new(0.2), {ImageTransparency = 0.6}):Play()
    end
end)

-- Dragging for main menu
do
    local dragging = false
    local dragStart, startPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local function onInputChanged(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end

    header.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
end

local goldSliders = {}
local goldBoxes = {}

local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, 0, 1, -headerH)
contentArea.Position = UDim2.new(0, 0, 0, headerH)
contentArea.BackgroundColor3 = BLACK
contentArea.BackgroundTransparency = 0.2
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.ZIndex = 3

-- Create three columns for better organization
local leftColumn = Instance.new("Frame", contentArea)
leftColumn.Size = UDim2.new(0.31, 0, 1, -10 * guiScale)
leftColumn.Position = UDim2.new(0.02, 0, 0, 5 * guiScale)
leftColumn.BackgroundColor3 = BLACK
leftColumn.BackgroundTransparency = 0.2
leftColumn.BorderSizePixel = 0
leftColumn.ClipsDescendants = true

local leftScroll = Instance.new("ScrollingFrame", leftColumn)
leftScroll.Size = UDim2.new(1, 0, 1, 0)
leftScroll.BackgroundColor3 = BLACK
leftScroll.BackgroundTransparency = 0.2
leftScroll.BorderSizePixel = 0
leftScroll.ScrollBarThickness = 6 * guiScale
leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
leftScroll.ZIndex = 3
leftScroll.ScrollBarImageColor3 = GOLD

local middleColumn = Instance.new("Frame", contentArea)
middleColumn.Size = UDim2.new(0.31, 0, 1, -10 * guiScale)
middleColumn.Position = UDim2.new(0.345, 0, 0, 5 * guiScale)
middleColumn.BackgroundColor3 = BLACK
middleColumn.BackgroundTransparency = 0.2
middleColumn.BorderSizePixel = 0
middleColumn.ClipsDescendants = true

local middleScroll = Instance.new("ScrollingFrame", middleColumn)
middleScroll.Size = UDim2.new(1, 0, 1, 0)
middleScroll.BackgroundColor3 = BLACK
middleScroll.BackgroundTransparency = 0.2
middleScroll.BorderSizePixel = 0
middleScroll.ScrollBarThickness = 6 * guiScale
middleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
middleScroll.ZIndex = 3
middleScroll.ScrollBarImageColor3 = GOLD

local rightColumn = Instance.new("Frame", contentArea)
rightColumn.Size = UDim2.new(0.31, 0, 1, -10 * guiScale)
rightColumn.Position = UDim2.new(0.67, 0, 0, 5 * guiScale)
rightColumn.BackgroundColor3 = BLACK
rightColumn.BackgroundTransparency = 0.2
rightColumn.BorderSizePixel = 0
rightColumn.ClipsDescendants = true

local rightScroll = Instance.new("ScrollingFrame", rightColumn)
rightScroll.Size = UDim2.new(1, 0, 1, 0)
rightScroll.BackgroundColor3 = BLACK
rightScroll.BackgroundTransparency = 0.2
rightScroll.BorderSizePixel = 0
rightScroll.ScrollBarThickness = 6 * guiScale
rightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
rightScroll.ZIndex = 3
rightScroll.ScrollBarImageColor3 = GOLD

local Connections = {}

-- Movement Functions
local function getMovementDirection()
    local c = Player.Character
    if not c then return Vector3.zero end
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end

-- Speed Boost
local function startSpeedBoost()
    if Connections.speed then return end
    Connections.speed = RunService.Heartbeat:Connect(function()
        if not Features.SpeedBoost then return end
        pcall(function()
            local c = Player.Character
            if not c then return end
            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local md = getMovementDirection()
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(
                    md.X * Values.BoostSpeed,
                    h.AssemblyLinearVelocity.Y,
                    md.Z * Values.BoostSpeed
                )
            end
        end)
    end)
end

local function stopSpeedBoost()
    if Connections.speed then
        Connections.speed:Disconnect()
        Connections.speed = nil
    end
end

-- Anti Ragdoll
local antiRagdollConnection = nil

local function startAntiRagdoll()
    if antiRagdollConnection then return end
    antiRagdollConnection = RunService.Heartbeat:Connect(function()
        local char = Player.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or humState == Enum.HumanoidStateType.Ragdoll or humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if Player.Character then
                        local PlayerModule = Player.PlayerScripts:FindFirstChild("PlayerModule")
                        if PlayerModule then
                            local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
                            Controls:Enable()
                        end
                    end
                end)
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end)
end

local function stopAntiRagdoll()
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
        antiRagdollConnection = nil
    end
end

-- Melee Aimbot (Hit Circle)
local Cebo = { Conn = nil, Circle = nil, Align = nil, Attach = nil }

local function startMeleeAimbot()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    Cebo.Attach = Instance.new("Attachment", hrp)
    Cebo.Align = Instance.new("AlignOrientation", hrp)
    Cebo.Align.Attachment0 = Cebo.Attach
    Cebo.Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    Cebo.Align.RigidityEnabled = true
    Cebo.Circle = Instance.new("Part")
    Cebo.Circle.Shape = Enum.PartType.Cylinder
    Cebo.Circle.Material = Enum.Material.Neon
    Cebo.Circle.Size = Vector3.new(0.05, 14.5, 14.5)
    Cebo.Circle.Color = GOLD
    Cebo.Circle.CanCollide = false
    Cebo.Circle.Massless = true
    Cebo.Circle.Parent = workspace
    local weld = Instance.new("Weld")
    weld.Part0 = hrp
    weld.Part1 = Cebo.Circle
    weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))
    weld.Parent = Cebo.Circle
    Cebo.Conn = RunService.RenderStepped:Connect(function()
        local target, dmin = nil, 7.25
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d <= dmin then target, dmin = p.Character.HumanoidRootPart, d end
            end
        end
        if target then
            char.Humanoid.AutoRotate = false
            Cebo.Align.Enabled = true
            Cebo.Align.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
            local t = char:FindFirstChild("Bat") or char:FindFirstChild("Medusa")
            if t then t:Activate() end
        else
            Cebo.Align.Enabled = false
            char.Humanoid.AutoRotate = true
        end
    end)
end

local function stopMeleeAimbot()
    if Cebo.Conn   then Cebo.Conn:Disconnect()   Cebo.Conn   = nil end
    if Cebo.Circle then Cebo.Circle:Destroy()     Cebo.Circle = nil end
    if Cebo.Align  then Cebo.Align:Destroy()      Cebo.Align  = nil end
    if Cebo.Attach then Cebo.Attach:Destroy()     Cebo.Attach = nil end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.AutoRotate = true
    end
end

-- SpinBot
local helicopterSpinBAV = nil

local function applySpinBotSpeed()
    if helicopterSpinBAV then
        helicopterSpinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    end
end

local function startSpinBot()
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if helicopterSpinBAV then helicopterSpinBAV:Destroy() helicopterSpinBAV = nil end
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "SpinBotBAV" then v:Destroy() end
    end
    helicopterSpinBAV = Instance.new("BodyAngularVelocity")
    helicopterSpinBAV.Name            = "SpinBotBAV"
    helicopterSpinBAV.MaxTorque       = Vector3.new(0, math.huge, 0)
    helicopterSpinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    helicopterSpinBAV.Parent          = hrp
end

local function stopSpinBot()
    if helicopterSpinBAV then helicopterSpinBAV:Destroy() helicopterSpinBAV = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "SpinBotBAV" then v:Destroy() end
            end
        end
    end
end

-- Infinite Jump
local infJumpConn1 = nil
local infJumpConn2 = nil
local jumpForce = 50
local clampFallSpeed = 80

local function startInfJump()
    infJumpConn1 = RunService.Heartbeat:Connect(function()
        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Velocity.Y < -clampFallSpeed then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -clampFallSpeed, hrp.Velocity.Z)
        end
    end)

    infJumpConn2 = UserInputService.JumpRequest:Connect(function()
        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpForce, hrp.Velocity.Z)
        end
    end)
end

local function stopInfJump()
    if infJumpConn1 then
        infJumpConn1:Disconnect()
        infJumpConn1 = nil
    end
    if infJumpConn2 then
        infJumpConn2:Disconnect()
        infJumpConn2 = nil
    end
end

-- Auto Steal
local isStealing = false
local StealData = {}

local function getHRP()
    local char = Player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local myHrp = getHRP()
    if not myHrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - myHrp.Position).Magnitude
                    if dist < nd and dist <= AutoStealValues.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then
                                    np, nd, nn = ch, dist, pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    stealStartTime = tick()
    if ProgressLabel then ProgressLabel.Text = name or "STEALING..." end
    if progressConn then progressConn:Disconnect() end
    progressConn = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect() return end
        local prog = math.clamp((tick() - stealStartTime) / AutoStealValues.STEAL_DURATION, 0, 1)
        if ProgressBarFill      then ProgressBarFill.Size = UDim2.new(prog, 0, 1, 0) end
        if ProgressPercentLabel then ProgressPercentLabel.Text = math.floor(prog * 100) .. "%" end
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(AutoStealValues.STEAL_DURATION)
        if progressConn then progressConn:Disconnect() progressConn = nil end
        resetProgressBar()
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        data.ready = true
        isStealing = false
    end)
end

local autoStealConn = nil

local function startAutoSteal()
    if autoStealConn then return end
    autoStealConn = RunService.Heartbeat:Connect(function()
        if not Features.AutoSteal or isStealing then return end
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect() autoStealConn = nil end
    if progressConn   then progressConn:Disconnect()   progressConn  = nil end
    isStealing = false
    resetProgressBar()
end

-- Thief Speed
local speedWhileStealingConn = nil

local function startSpeedWhileStealing()
    if speedWhileStealingConn then return end
    speedWhileStealingConn = RunService.Heartbeat:Connect(function()
        if not Features.SpeedWhileStealing or not Player:GetAttribute("Stealing") then return end
        local c = Player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local md = hum and hum.MoveDirection or Vector3.zero
        if md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(
                md.X * Values.StealingSpeedValue,
                h.AssemblyLinearVelocity.Y,
                md.Z * Values.StealingSpeedValue
            )
        end
    end)
end

local function stopSpeedWhileStealing()
    if speedWhileStealingConn then
        speedWhileStealingConn:Disconnect()
        speedWhileStealingConn = nil
    end
end

-- Bat Aimbot
local function getNearestPlayer()
    local character = Player.Character
    if not character then return nil end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    local nearestPlayer = nil
    local nearestDistance = math.huge
    local myPos = humanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = p
            end
        end
    end

    return nearestPlayer
end

local function startBatAimbot()
    Connections.bat = RunService.Heartbeat:Connect(function()
        if not Features.BatAimbot then return end
        local character = Player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart then return end

        local nearestPlayer = getNearestPlayer()
        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
            local direction = (targetPos - humanoidRootPart.Position).Unit
            local FLY_SPEED = 55
            humanoidRootPart.AssemblyLinearVelocity = direction * FLY_SPEED
            humanoid.PlatformStand = true
        end
    end)
    task.spawn(function()
        while Features.BatAimbot do
            local character = Player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local bat = character:FindFirstChild("Bat") or Player.Backpack:FindFirstChild("Bat")
                    if bat then
                        if bat.Parent == Player.Backpack then
                            humanoid:EquipTool(bat)
                            task.wait(0.1)
                        end
                        local equippedBat = character:FindFirstChild("Bat")
                        if equippedBat then
                            equippedBat:Activate()
                        end
                    end
                end
            end
            task.wait(0.15)
        end
    end)
end

local function stopBatAimbot()
    if Connections.bat then Connections.bat:Disconnect() Connections.bat = nil end
    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

-- Unwalk
local savedAnimations = {}

local function startUnwalk()
    local c = Player.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            t:Stop()
        end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        savedAnimations.Animate = anim:Clone()
        anim:Destroy()
    end
end

local function stopUnwalk()
    local c = Player.Character
    if c and savedAnimations.Animate then
        savedAnimations.Animate:Clone().Parent = c
        savedAnimations.Animate = nil
    end
end

-- Optimizer
local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.Brightness = 3
        Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                end
            end)
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
end

-- XRay
local originalTransparency = {}
local xrayActive = false

local function enableXRay()
    xrayActive = true
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
end

local function disableXRay()
    xrayActive = false
    for part, value in pairs(originalTransparency) do
        if part then part.LocalTransparencyModifier = value end
    end
    originalTransparency = {}
end

-- Float
local floatConn = nil
local floatBV = nil
local floatBP = nil

local FLOAT_TARGET_HEIGHT = 10
local floatOriginY = nil

local function startFloat()
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = c:FindFirstChildOfClass("Humanoid")

    if floatBV  then floatBV:Destroy()  floatBV  = nil end
    if floatBP  then floatBP:Destroy()  floatBP  = nil end
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "FloatBV" or v.Name == "FloatBP" then v:Destroy() end
    end

    floatOriginY = hrp.Position.Y + FLOAT_TARGET_HEIGHT
    local floatStartTime = tick()
    local floatDescending = false

    floatConn = RunService.Heartbeat:Connect(function()
        if not Features.Float then return end
        local c2 = Player.Character
        if not c2 then return end
        local h = c2:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local hum2 = c2:FindFirstChildOfClass("Humanoid")

        local isStealing = Player:GetAttribute("Stealing")
        local moveSpeed = isStealing and Values.StealingSpeedValue or Values.BoostSpeed
        local moveDir = hum2 and hum2.MoveDirection or Vector3.zero

        if tick() - floatStartTime >= 4 then
            floatDescending = true
        end

        local currentY = h.Position.Y
        local vertVel

        if floatDescending then
            vertVel = -20
            if currentY <= floatOriginY - FLOAT_TARGET_HEIGHT + 0.5 then
                h.AssemblyLinearVelocity = Vector3.zero
                Features.Float = false
                if floatConn then floatConn:Disconnect() floatConn = nil end
                if _G.stopFloatVisual then _G.stopFloatVisual() end
                return
            end
        else
            local diff = floatOriginY - currentY
            if diff > 0.3 then
                vertVel = math.clamp(diff * 8, 5, 50)
            elseif diff < -0.3 then
                vertVel = math.clamp(diff * 8, -50, -5)
            else
                vertVel = 0
            end
        end

        local horizX = moveDir.Magnitude > 0.1 and moveDir.X * moveSpeed or 0
        local horizZ = moveDir.Magnitude > 0.1 and moveDir.Z * moveSpeed or 0

        h.AssemblyLinearVelocity = Vector3.new(horizX, vertVel, horizZ)
    end)
end

local function stopFloat()
    if floatConn then floatConn:Disconnect() floatConn = nil end
    if floatBV   then floatBV:Destroy()      floatBV   = nil end
    if floatBP   then floatBP:Destroy()      floatBP   = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "FloatBV" or v.Name == "FloatBP" then v:Destroy() end
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

-- Walk Fling
connections = connections or {}
connections.FreezePlayer = connections.FreezePlayer or {}
featureStates = featureStates or {}
featureStates.FreezePlayer = featureStates.FreezePlayer or false

local function walkfling(enabled)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local walkflinging = false

    if enabled then
        featureStates.FreezePlayer = true

        local function disablePlayerCollisions()
            local conn = RunService.Stepped:Connect(function()
                if not featureStates.FreezePlayer then
                    conn:Disconnect()
                    return
                end
                local myChar = LocalPlayer.Character
                if myChar then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            for _, part in ipairs(plr.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
            table.insert(connections.FreezePlayer, conn)
        end

        local function stopWalkFling()
            walkflinging = false
        end

        local function startWalkFling()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                local diedConn = humanoid.Died:Connect(function()
                    stopWalkFling()
                end)
                table.insert(connections.FreezePlayer, diedConn)
            end

            walkflinging = true
            local flingConn = coroutine.create(function()
                repeat
                    RunService.Heartbeat:Wait()
                    if not featureStates.FreezePlayer then
                        break
                    end
                    character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local vel, movel = nil, 0.1

                    while not (character and character.Parent and root and root.Parent) do
                        RunService.Heartbeat:Wait()
                        if not featureStates.FreezePlayer then
                            break
                        end
                        character = LocalPlayer.Character
                        root = character and character:FindFirstChild("HumanoidRootPart")
                    end

                    if not featureStates.FreezePlayer then
                        break
                    end

                    vel = root.Velocity
                    root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

                    RunService.RenderStepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.Velocity = vel
                    end

                    RunService.Stepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = movel * -1
                    end
                until walkflinging == false or not featureStates.FreezePlayer
            end)
            coroutine.resume(flingConn)
            table.insert(connections.FreezePlayer, flingConn)
        end

        disablePlayerCollisions()
        startWalkFling()
    else
        featureStates.FreezePlayer = false
        for _, conn in ipairs(connections.FreezePlayer) do
            if conn then
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                elseif typeof(conn) == "thread" then
                    task.cancel(conn)
                end
            end
        end
        connections.FreezePlayer = {}
        walkflinging = false
    end
end

-- Teleport Functions
local tpFinalRight = Vector3.new(-483.51, -5.10, 18.89)
local tpFinalLeft  = Vector3.new(-483.59, -5.04, 104.24)
local tpCheckA     = Vector3.new(-472.60, -7.00, 57.52)
local tpCheckRight = Vector3.new(-471.76, -7.00, 26.22)
local tpCheckLeft  = Vector3.new(-472.65, -7.00, 95.69)

local lastTpSide       = "none"
local ragdollWasActive = false
local ragdollAutoActiveRight = false
local ragdollAutoActiveLeft  = false
local ragdollDetectorConn = nil

local function tpMove(pos)
    local char = Player.Character
    if not char then return end
    char:PivotTo(CFrame.new(pos))
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

local function doTPRight()
    tpMove(tpCheckA);     task.wait(0.1)
    tpMove(tpCheckRight); task.wait(0.1)
    tpMove(tpFinalRight)
    lastTpSide = "right"
end

local function doTPLeft()
    tpMove(tpCheckA);    task.wait(0.1)
    tpMove(tpCheckLeft); task.wait(0.1)
    tpMove(tpFinalLeft)
    lastTpSide = "left"
end

local function isRagdolled(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum:GetState() == Enum.HumanoidStateType.Ragdoll then return true end
    local ragVal = char:FindFirstChild("Ragdoll") or char:FindFirstChild("IsRagdoll")
    if ragVal and ragVal:IsA("BoolValue") and ragVal.Value then return true end
    return false
end

local function startRagdollDetector()
    if ragdollDetectorConn then return end
    ragdollDetectorConn = RunService.Heartbeat:Connect(function()
        local char = Player.Character
        if not char then return end
        local nowRagdolled = isRagdolled(char)
        if nowRagdolled and not ragdollWasActive then
            ragdollWasActive = true
            task.spawn(function()
                task.wait(0.15)
                if lastTpSide == "right" and ragdollAutoActiveRight then
                    doTPRight()
                elseif lastTpSide == "left" and ragdollAutoActiveLeft then
                    doTPLeft()
                end
            end)
        elseif not nowRagdolled then
            ragdollWasActive = false
        end
    end)
end

local function stopRagdollDetector()
    if ragdollDetectorConn then
        ragdollDetectorConn:Disconnect()
        ragdollDetectorConn = nil
    end
    ragdollWasActive = false
end

-- Auto Path System (from second script)
local rightWaypoints = {
    Vector3.new(-473.04,-6.99,29.71), Vector3.new(-483.57,-5.10,18.74),
    Vector3.new(-475.00,-6.99,26.43), Vector3.new(-474.67,-6.94,105.48),
}
local leftWaypoints = {
    Vector3.new(-472.49,-7.00,90.62), Vector3.new(-484.62,-5.10,100.37),
    Vector3.new(-475.08,-7.00,93.29), Vector3.new(-474.22,-6.96,16.18),
}
local patrolMode = "none"
local currentWaypoint = 1
local autoPathHeartbeat = nil
local waitingForCountdownLeft = false
local waitingForCountdownRight = false
local AUTO_START_DELAY = 0.7

local function isCountdownNumber(text)
    local num = tonumber(text)
    if num and num >= 1 and num <= 5 then return true, num end
    return false
end

local function isTimerInCountdown(label)
    if not label then return false end
    local ok, num = isCountdownNumber(label.Text)
    return ok and num >= 1 and num <= 5
end

local function getCurrentSpeed()
    if patrolMode == "right" then return currentWaypoint >= 3 and 29.4 or 60
    elseif patrolMode == "left" then return currentWaypoint >= 3 and 29.4 or 60 end
    return 0
end

local function getCurrentWaypoints()
    if patrolMode == "right" then return rightWaypoints
    elseif patrolMode == "left" then return leftWaypoints end
    return {}
end

local function updateAutoPathWalking()
    local char = Player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    
    if patrolMode ~= "none" then
        local waypoints = getCurrentWaypoints()
        local targetPos = waypoints[currentWaypoint]
        local currentPos = root.Position
        local targetXZ  = Vector3.new(targetPos.X, 0, targetPos.Z)
        local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
        local distanceXZ = (targetXZ - currentXZ).Magnitude
        
        if distanceXZ > 3 then
            local moveDir = (targetXZ - currentXZ).Unit
            local spd = getCurrentSpeed()
            root.AssemblyLinearVelocity = Vector3.new(moveDir.X*spd, root.AssemblyLinearVelocity.Y, moveDir.Z*spd)
        else
            if currentWaypoint == #waypoints then
                currentWaypoint = 1
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            else
                currentWaypoint = currentWaypoint + 1
            end
        end
    end
end

local function startAutoPath(mode)
    -- Stop any existing auto path
    if Features.AutoPathRight or Features.AutoPathLeft then
        if mode == "right" and Features.AutoPathLeft then
            Features.AutoPathLeft = false
            if CompactButtons and CompactButtons.AutoPathLeft then
                CompactButtons.AutoPathLeft.setVisual(false)
            end
        elseif mode == "left" and Features.AutoPathRight then
            Features.AutoPathRight = false
            if CompactButtons and CompactButtons.AutoPathRight then
                CompactButtons.AutoPathRight.setVisual(false)
            end
        end
    end
    
    patrolMode = mode
    currentWaypoint = 1
    if not autoPathHeartbeat then
        autoPathHeartbeat = RunService.Heartbeat:Connect(updateAutoPathWalking)
    end
end

local function stopAutoPath()
    patrolMode = "none"
    currentWaypoint = 1
    waitingForCountdownLeft = false
    waitingForCountdownRight = false
    if autoPathHeartbeat then
        autoPathHeartbeat:Disconnect()
        autoPathHeartbeat = nil
    end
    local char = Player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
    end
end

-- Chat function for Taught button
local function sendKingHubMessage()
    local message = "/king hub on top"
    
    -- Try different chat methods
    local success = pcall(function()
        if ChatService and ChatService:IsA("TextChatService") then
            -- New chat system
            local textChannel = ChatService.TextChannels:FindFirstChild("RBXGeneral")
            if textChannel then
                textChannel:SendAsync(message)
            else
                -- Fallback to old chat
                game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(message, "All")
            end
        else
            -- Old chat system
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(message, "All")
        end
    end)
    
    if not success then
        -- Ultimate fallback - try to find chat remote
        pcall(function()
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("chat") then
                    v:FireServer(message)
                    break
                end
            end
        end)
    end
end

-- UI Helper Functions
local toggleSliderOrder = 0

-- Function to create compact buttons outside menu (BIGGER SIZE)
local function createCompactButton(parent, labelText, bindKey, position, isWide)
    local width = isWide and 180 * guiScale or 140 * guiScale
    local height = 45 * guiScale
    
    local frame = Instance.new("Frame", parent)
    frame.Name = "CompactButton_" .. labelText:gsub("%s+", "")
    frame.Size = UDim2.new(0, width, 0, height)
    frame.Position = position
    frame.BackgroundColor3 = COMPACT_BG
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.ZIndex = 50
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10 * guiScale)

    local fStroke = Instance.new("UIStroke", frame)
    fStroke.Thickness = 2.5 * guiScale
    fStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    fStroke.Color = GOLD
    fStroke.Transparency = 0.3

    local statusDot = Instance.new("Frame", frame)
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 9 * guiScale, 0, 9 * guiScale)
    statusDot.Position = UDim2.new(0, 10 * guiScale, 0.5, -4.5 * guiScale)
    statusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 51
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Name = "Label"
    lbl.Size = UDim2.new(0.7, -15, 1, 0)
    lbl.Position = UDim2.new(0, 28 * guiScale, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. " [" .. bindKey .. "]"
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 12 * guiScale
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 51

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 52

    -- Make draggable
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    return {
        frame = frame,
        btn = btn,
        lbl = lbl,
        statusDot = statusDot,
        setVisual = function(state)
            statusDot.BackgroundColor3 = state and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(60, 60, 60)
        end,
        setWaiting = function(waiting)
            statusDot.BackgroundColor3 = waiting and Color3.fromRGB(220, 180, 50) or Color3.fromRGB(60, 60, 60)
            if waiting then
                lbl.Text = "Waiting..."
            else
                lbl.Text = labelText .. " [" .. bindKey .. "]"
            end
        end,
        flash = function()
            statusDot.BackgroundColor3 = GOLD
            task.wait(0.3)
            statusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end,
        pulse = function()
            -- Pulse effect for Taught button
            local originalColor = statusDot.BackgroundColor3
            for i = 1, 3 do
                statusDot.BackgroundColor3 = GOLD
                task.wait(0.1)
                statusDot.BackgroundColor3 = originalColor
                task.wait(0.1)
            end
        end
    }
end

local function makeToggleHeader(parent, labelText)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10 * guiScale, 0, 40 * guiScale)
    frame.BackgroundColor3 = BLACK
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.LayoutOrder = toggleSliderOrder
    toggleSliderOrder = toggleSliderOrder + 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8 * guiScale)

    local fStroke = Instance.new("UIStroke", frame)
    fStroke.Thickness = 2 * guiScale
    fStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    fStroke.Color = GOLD

    table.insert(goldBoxes, fStroke)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 12 * guiScale
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(0, 44 * guiScale, 0, 22 * guiScale)
    bg.Position = UDim2.new(1, -50 * guiScale, 0.5, -11 * guiScale)
    bg.BackgroundColor3 = DARK_GRAY
    bg.ZIndex = 4
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", bg)
    circle.Size = UDim2.new(0, 18 * guiScale, 0, 18 * guiScale)
    circle.Position = UDim2.new(0, 2 * guiScale, 0.5, -9 * guiScale)
    circle.BackgroundColor3 = GOLD
    circle.ZIndex = 5
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6

    local isOn = false

    local function updateVisual()
        if isOn then
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = GOLD}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1,-20*guiScale,0.5,-9*guiScale), BackgroundColor3 = Color3.new(1,1,1)}):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = DARK_GRAY}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0,2*guiScale,0.5,-9*guiScale), BackgroundColor3 = GOLD}):Play()
        end
    end

    return btn, function(state)
        isOn = state
        updateVisual()
    end, function() return isOn end
end

local function createSlider(parent, labelText, minVal, maxVal, valueKey, onChange)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -10 * guiScale, 0, 50 * guiScale)
    container.BackgroundColor3 = BLACK
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.LayoutOrder = toggleSliderOrder
    toggleSliderOrder = toggleSliderOrder + 1
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8 * guiScale)

    local cStroke = Instance.new("UIStroke", container)
    cStroke.Thickness = 2 * guiScale
    cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cStroke.Color = GOLD

    table.insert(goldBoxes, cStroke)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 18 * guiScale)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(1, 0, 0, 6 * guiScale)
    sliderBg.Position = UDim2.new(0, 0, 0, 24 * guiScale)
    sliderBg.BackgroundColor3 = DARK_GRAY
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = GOLD
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", sliderBg)
    thumb.Size = UDim2.new(0, 12 * guiScale, 0, 12 * guiScale)
    thumb.Position = UDim2.new(0.5, -6 * guiScale, 0.5, -6 * guiScale)
    thumb.BackgroundColor3 = GOLD
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Size = UDim2.new(0, 40 * guiScale, 0, 18 * guiScale)
    valueLabel.Position = UDim2.new(1, -42 * guiScale, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Values[valueKey])
    valueLabel.TextColor3 = GOLD
    valueLabel.Font = Enum.Font.GothamBlack
    valueLabel.TextSize = 11 * guiScale

    table.insert(goldSliders, {sliderFill = sliderFill, thumb = thumb, valueLabel = valueLabel})

    local dragging = false

    local function updateSlider(relative)
        relative = math.clamp(relative, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * relative)
        Values[valueKey] = value
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(relative, 0, 1, 0)
        thumb.Position = UDim2.new(relative, -6 * guiScale, 0.5, -6 * guiScale)
        if onChange then onChange(value) end
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local relative = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(relative)
        end
    end)

    local initialRelative = (Values[valueKey] - minVal) / (maxVal - minVal)
    updateSlider(initialRelative)

    return container
end

local leftLayout = Instance.new("UIListLayout", leftScroll)
leftLayout.Padding = UDim.new(0, 8 * guiScale)
leftLayout.FillDirection = Enum.FillDirection.Vertical
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local middleLayout = Instance.new("UIListLayout", middleScroll)
middleLayout.Padding = UDim.new(0, 8 * guiScale)
middleLayout.FillDirection = Enum.FillDirection.Vertical
middleLayout.SortOrder = Enum.SortOrder.LayoutOrder
middleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local rightLayout = Instance.new("UIListLayout", rightScroll)
rightLayout.Padding = UDim.new(0, 8 * guiScale)
rightLayout.FillDirection = Enum.FillDirection.Vertical
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleControls = {}

-- Create Compact Buttons outside menu (BIGGER)
local CompactButtons = {}

-- Position compact buttons in a vertical stack on the left side
local buttonX = 15
local buttonY = 120  -- Starting Y position
local buttonSpacing = 55 * guiScale  -- Spacing for bigger buttons

-- Taught button at the top (wider)
CompactButtons.Taught = createCompactButton(sg, "Taught", taughtKeybind.Name, UDim2.new(0, buttonX, 0, buttonY - buttonSpacing), true)

-- Auto Path buttons
CompactButtons.AutoPathRight = createCompactButton(sg, "Auto Right", autoPathRightKeybind.Name, UDim2.new(0, buttonX, 0, buttonY), false)
CompactButtons.AutoPathLeft = createCompactButton(sg, "Auto Left", autoPathLeftKeybind.Name, UDim2.new(0, buttonX, 0, buttonY + buttonSpacing), false)

-- Quick TP buttons (RENAMED)
CompactButtons.QuickTPRight = createCompactButton(sg, "TP Right", quickTPRightKeybind.Name, UDim2.new(0, buttonX, 0, buttonY + buttonSpacing * 2), false)
CompactButtons.QuickTPLeft = createCompactButton(sg, "TP Left", quickTPLeftKeybind.Name, UDim2.new(0, buttonX, 0, buttonY + buttonSpacing * 3), false)

-- Aimbot buttons (new row to the right)
local aimbotButtonX = 180  -- Position to the right of the first column

-- Bat Aimbot button
CompactButtons.BatAimbot = createCompactButton(sg, "Bat Aimbot", batKeybind.Name, UDim2.new(0, aimbotButtonX, 0, buttonY), false)

-- Melee Aimbot (Hit Circle) button
CompactButtons.MeleeAimbot = createCompactButton(sg, "Hit Circle", meleeKeybind.Name, UDim2.new(0, aimbotButtonX, 0, buttonY + buttonSpacing), false)

-- Taught button logic
do
    local listeningForKey = false
    local btnData = CompactButtons.Taught
    local originalText = "Taught [" .. taughtKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "Taught [" .. taughtKeybind.Name .. "]"
            originalText = "Taught [" .. taughtKeybind.Name .. "]"
        end
    end

    -- Keybind changer button (gear icon)
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            taughtKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleTaught()
        if listeningForKey then return end
        
        -- Pulse effect for feedback
        btnData.pulse()
        
        -- Send the message
        sendKingHubMessage()
    end

    btnData.btn.MouseButton1Click:Connect(toggleTaught)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == taughtKeybind then
            toggleTaught()
        end
    end)

    ToggleControls.Taught = {setVisual = function() end}
end

-- Auto Path Right button logic
do
    local listeningForKey = false
    local btnData = CompactButtons.AutoPathRight
    local originalText = "Auto Right [" .. autoPathRightKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "Auto Right [" .. autoPathRightKeybind.Name .. "]"
            originalText = "Auto Right [" .. autoPathRightKeybind.Name .. "]"
        end
    end

    -- Keybind changer button
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            autoPathRightKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleAutoRight()
        if listeningForKey then return end
        
        if Features.AutoPathRight then
            -- Turn off
            Features.AutoPathRight = false
            if patrolMode == "right" then
                stopAutoPath()
            end
            waitingForCountdownRight = false
            btnData.setVisual(false)
            btnData.lbl.Text = originalText
        else
            -- Check for countdown
            local ok, label = pcall(function()
                return player.PlayerGui:FindFirstChild("DuelsMachineTopFrame")
                    and player.PlayerGui.DuelsMachineTopFrame:FindFirstChild("DuelsMachineTopFrame")
                    and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame:FindFirstChild("Timer")
                    and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer:FindFirstChild("Label")
            end)
            
            if ok and label and isTimerInCountdown(label) then
                waitingForCountdownRight = true
                btnData.setWaiting(true)
            else
                -- Turn on
                if Features.AutoPathLeft then
                    Features.AutoPathLeft = false
                    CompactButtons.AutoPathLeft.setVisual(false)
                    CompactButtons.AutoPathLeft.lbl.Text = "Auto Left [" .. autoPathLeftKeybind.Name .. "]"
                end
                Features.AutoPathRight = true
                startAutoPath("right")
                btnData.setVisual(true)
                btnData.lbl.Text = originalText
            end
        end
    end

    btnData.btn.MouseButton1Click:Connect(toggleAutoRight)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == autoPathRightKeybind then
            toggleAutoRight()
        end
    end)

    ToggleControls.AutoPathRight = {setVisual = function(state)
        Features.AutoPathRight = state
        btnData.setVisual(state)
    end}
end

-- Auto Path Left button logic
do
    local listeningForKey = false
    local btnData = CompactButtons.AutoPathLeft
    local originalText = "Auto Left [" .. autoPathLeftKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "Auto Left [" .. autoPathLeftKeybind.Name .. "]"
            originalText = "Auto Left [" .. autoPathLeftKeybind.Name .. "]"
        end
    end

    -- Keybind changer button
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            autoPathLeftKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleAutoLeft()
        if listeningForKey then return end
        
        if Features.AutoPathLeft then
            -- Turn off
            Features.AutoPathLeft = false
            if patrolMode == "left" then
                stopAutoPath()
            end
            waitingForCountdownLeft = false
            btnData.setVisual(false)
            btnData.lbl.Text = originalText
        else
            -- Check for countdown
            local ok, label = pcall(function()
                return player.PlayerGui:FindFirstChild("DuelsMachineTopFrame")
                    and player.PlayerGui.DuelsMachineTopFrame:FindFirstChild("DuelsMachineTopFrame")
                    and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame:FindFirstChild("Timer")
                    and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer:FindFirstChild("Label")
            end)
            
            if ok and label and isTimerInCountdown(label) then
                waitingForCountdownLeft = true
                btnData.setWaiting(true)
            else
                -- Turn on
                if Features.AutoPathRight then
                    Features.AutoPathRight = false
                    CompactButtons.AutoPathRight.setVisual(false)
                    CompactButtons.AutoPathRight.lbl.Text = "Auto Right [" .. autoPathRightKeybind.Name .. "]"
                end
                Features.AutoPathLeft = true
                startAutoPath("left")
                btnData.setVisual(true)
                btnData.lbl.Text = originalText
            end
        end
    end

    btnData.btn.MouseButton1Click:Connect(toggleAutoLeft)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == autoPathLeftKeybind then
            toggleAutoLeft()
        end
    end)

    ToggleControls.AutoPathLeft = {setVisual = function(state)
        Features.AutoPathLeft = state
        btnData.setVisual(state)
    end}
end

-- Quick TP Right button logic (RENAMED)
do
    local listeningForKey = false
    local btnData = CompactButtons.QuickTPRight
    local originalText = "TP Right [" .. quickTPRightKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "TP Right [" .. quickTPRightKeybind.Name .. "]"
            originalText = "TP Right [" .. quickTPRightKeybind.Name .. "]"
        end
    end

    -- Keybind changer button
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            quickTPRightKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleQuickTPRight()
        if listeningForKey then return end
        
        -- Flash visual feedback
        btnData.flash()
        
        -- Perform the teleport
        doTPRight()
        
        -- Auto-start auto path if desired
        task.wait(0.2)
        if not Features.AutoPathRight and not Features.AutoPathLeft then
            -- Activate auto right
            Features.AutoPathRight = true
            CompactButtons.AutoPathRight.setVisual(true)
            startAutoPath("right")
        end
    end

    btnData.btn.MouseButton1Click:Connect(toggleQuickTPRight)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == quickTPRightKeybind then
            toggleQuickTPRight()
        end
    end)

    ToggleControls.QuickTPRight = {setVisual = function() end}
end

-- Quick TP Left button logic (RENAMED)
do
    local listeningForKey = false
    local btnData = CompactButtons.QuickTPLeft
    local originalText = "TP Left [" .. quickTPLeftKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "TP Left [" .. quickTPLeftKeybind.Name .. "]"
            originalText = "TP Left [" .. quickTPLeftKeybind.Name .. "]"
        end
    end

    -- Keybind changer button
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            quickTPLeftKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleQuickTPLeft()
        if listeningForKey then return end
        
        -- Flash visual feedback
        btnData.flash()
        
        -- Perform the teleport
        doTPLeft()
        
        -- Auto-start auto path if desired
        task.wait(0.2)
        if not Features.AutoPathRight and not Features.AutoPathLeft then
            -- Activate auto left
            Features.AutoPathLeft = true
            CompactButtons.AutoPathLeft.setVisual(true)
            startAutoPath("left")
        end
    end

    btnData.btn.MouseButton1Click:Connect(toggleQuickTPLeft)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == quickTPLeftKeybind then
            toggleQuickTPLeft()
        end
    end)

    ToggleControls.QuickTPLeft = {setVisual = function() end}
end

-- Bat Aimbot button logic
do
    local listeningForKey = false
    local btnData = CompactButtons.BatAimbot
    local originalText = "Bat Aimbot [" .. batKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "Bat Aimbot [" .. batKeybind.Name .. "]"
            originalText = "Bat Aimbot [" .. batKeybind.Name .. "]"
        end
    end
    updateLabel()

    -- Keybind changer button (gear icon)
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            batKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleBatAimbot()
        if listeningForKey then return end
        
        local newState = not Features.BatAimbot
        Features.BatAimbot = newState
        btnData.setVisual(newState)
        
        if newState then
            startBatAimbot()
        else
            stopBatAimbot()
        end
    end

    btnData.btn.MouseButton1Click:Connect(toggleBatAimbot)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == batKeybind then
            toggleBatAimbot()
        end
    end)

    ToggleControls.BatAimbot = {
        setVisual = function(state)
            Features.BatAimbot = state
            btnData.setVisual(state)
        end,
        start = startBatAimbot,
        stop = stopBatAimbot
    }
end

-- Melee Aimbot (Hit Circle) button logic
do
    local listeningForKey = false
    local btnData = CompactButtons.MeleeAimbot
    local originalText = "Hit Circle [" .. meleeKeybind.Name .. "]"

    local function updateLabel()
        if not listeningForKey then
            btnData.lbl.Text = "Hit Circle [" .. meleeKeybind.Name .. "]"
            originalText = "Hit Circle [" .. meleeKeybind.Name .. "]"
        end
    end
    updateLabel()

    -- Keybind changer button (gear icon)
    local kbBtn = Instance.new("TextButton", btnData.frame)
    kbBtn.Size = UDim2.new(0, 24 * guiScale, 0, 24 * guiScale)
    kbBtn.Position = UDim2.new(1, -32 * guiScale, 0.5, -12 * guiScale)
    kbBtn.BackgroundColor3 = DARK_GRAY
    kbBtn.TextColor3 = GOLD
    kbBtn.Font = Enum.Font.GothamBlack
    kbBtn.TextSize = 14 * guiScale
    kbBtn.Text = "âš™"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 53
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD

    kbBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            meleeKeybind = input.KeyCode
            listeningForKey = false
            kbBtn.Text = "âš™"
            kbBtn.TextColor3 = GOLD
            updateLabel()
        end)
    end)

    local function toggleMeleeAimbot()
        if listeningForKey then return end
        
        local newState = not Features.MeleeAimbot
        Features.MeleeAimbot = newState
        btnData.setVisual(newState)
        
        if newState then
            startMeleeAimbot()
        else
            stopMeleeAimbot()
        end
    end

    btnData.btn.MouseButton1Click:Connect(toggleMeleeAimbot)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == meleeKeybind then
            toggleMeleeAimbot()
        end
    end)

    ToggleControls.MeleeAimbot = {
        setVisual = function(state)
            Features.MeleeAimbot = state
            btnData.setVisual(state)
        end,
        start = startMeleeAimbot,
        stop = stopMeleeAimbot
    }
end

-- Create UI Elements (Left Column - Movement)
do
    local listeningForKey = false

    local btn, setVisual, getState = makeToggleHeader(leftScroll, "Speed Boost  [" .. speedKeybind.Name .. "]")

    local frame = btn.Parent
    local lbl = frame:FindFirstChildOfClass("TextLabel")

    local function updateSpeedLabel()
        if lbl then
            lbl.Text = "Speed Boost  [" .. speedKeybind.Name .. "]"
        end
    end
    updateSpeedLabel()

    local keybindBtn = Instance.new("TextButton", frame)
    keybindBtn.Size = UDim2.new(0, 36 * guiScale, 0, 20 * guiScale)
    keybindBtn.Position = UDim2.new(1, -92 * guiScale, 0.5, -10 * guiScale)
    keybindBtn.BackgroundColor3 = DARK_GRAY
    keybindBtn.TextColor3 = GOLD
    keybindBtn.Font = Enum.Font.GothamBlack
    keybindBtn.TextSize = 9 * guiScale
    keybindBtn.Text = "BIND"
    keybindBtn.BorderSizePixel = 0
    keybindBtn.ZIndex = 8
    Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 4 * guiScale)

    local kbStroke = Instance.new("UIStroke", keybindBtn)
    kbStroke.Thickness = 1.5 * guiScale
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Color = GOLD
    table.insert(goldBoxes, kbStroke)

    keybindBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        keybindBtn.Text = "..."
        keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            speedKeybind = input.KeyCode
            listeningForKey = false
            keybindBtn.Text = "BIND"
            keybindBtn.TextColor3 = GOLD
            updateSpeedLabel()
        end)
    end)

    local function toggleSpeedBoost()
        if listeningForKey then return end
        local on = not getState()
        setVisual(on)
        Features.SpeedBoost = on
        if on then startSpeedBoost() else stopSpeedBoost() end
    end

    btn.MouseButton1Click:Connect(toggleSpeedBoost)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == speedKeybind then
            toggleSpeedBoost()
        end
    end)

    ToggleControls.SpeedBoost = {setVisual = setVisual, start = startSpeedBoost, stop = stopSpeedBoost}
end

createSlider(leftScroll, "Speed Value", 1, 70, "BoostSpeed")

do
    local btn, setVisual, getState = makeToggleHeader(leftScroll, "Anti Ragdoll")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.AntiRagdoll = on
        if on then startAntiRagdoll() else stopAntiRagdoll() end
    end)
    ToggleControls.AntiRagdoll = {setVisual = setVisual, start = startAntiRagdoll, stop = stopAntiRagdoll}
end

do
    local btn, setVisual, getState = makeToggleHeader(leftScroll, "SpinBot")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.SpinBot = on
        if on then startSpinBot() else stopSpinBot() end
    end)
    ToggleControls.SpinBot = {setVisual = setVisual, start = startSpinBot, stop = stopSpinBot}
end

createSlider(leftScroll, "SpinBot Speed", 5, 50, "SpinSpeed", function(v)
    Values.SpinSpeed = v
    applySpinBotSpeed()
end)

do
    local btn, setVisual, getState = makeToggleHeader(leftScroll, "Inf Jump")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.InfJump = on
        if on then startInfJump() else stopInfJump() end
    end)
    ToggleControls.InfJump = {setVisual = setVisual, start = startInfJump, stop = stopInfJump}
end

-- Middle Column - Stealing/Combat
do
    local btn, setVisual, getState = makeToggleHeader(middleScroll, "Auto Steal")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.AutoSteal = on
        if on then startAutoSteal() else stopAutoSteal() end
    end)
    ToggleControls.AutoSteal = {setVisual = setVisual, start = startAutoSteal, stop = stopAutoSteal}
end

createSlider(middleScroll, "Steal Radius", 1, 30, "STEAL_RADIUS", function(v)
    AutoStealValues.STEAL_RADIUS = v
end)

do
    local btn, setVisual, getState = makeToggleHeader(middleScroll, "Thief Speed")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.SpeedWhileStealing = on
        if on then startSpeedWhileStealing() else stopSpeedWhileStealing() end
    end)
    ToggleControls.SpeedWhileStealing = {setVisual = setVisual, start = startSpeedWhileStealing, stop = stopSpeedWhileStealing}
end

createSlider(middleScroll, "Steal Speed", 10, 50, "StealingSpeedValue", function(v)
    Values.StealingSpeedValue = v
end)

-- Right Column - Utility/Misc (Regular Toggles)
do
    local listeningForKey = false

    local btn, setVisual, getState = makeToggleHeader(rightScroll, "Float  [" .. floatKeybind.Name .. "]")

    local frame = btn.Parent
    local lbl = frame:FindFirstChildOfClass("TextLabel")

    local function updateFloatLabel()
        if lbl then lbl.Text = "Float  [" .. floatKeybind.Name .. "]" end
    end
    updateFloatLabel()

    local kbBtnF = Instance.new("TextButton", frame)
    kbBtnF.Size = UDim2.new(0, 36 * guiScale, 0, 20 * guiScale)
    kbBtnF.Position = UDim2.new(1, -92 * guiScale, 0.5, -10 * guiScale)
    kbBtnF.BackgroundColor3 = DARK_GRAY
    kbBtnF.TextColor3 = GOLD
    kbBtnF.Font = Enum.Font.GothamBlack
    kbBtnF.TextSize = 9 * guiScale
    kbBtnF.Text = "BIND"
    kbBtnF.BorderSizePixel = 0
    kbBtnF.ZIndex = 8
    Instance.new("UICorner", kbBtnF).CornerRadius = UDim.new(0, 4 * guiScale)
    local kbStrokeF = Instance.new("UIStroke", kbBtnF)
    kbStrokeF.Thickness = 1.5 * guiScale
    kbStrokeF.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStrokeF.Color = GOLD
    table.insert(goldBoxes, kbStrokeF)

    kbBtnF.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        kbBtnF.Text = "..."
        kbBtnF.TextColor3 = Color3.fromRGB(255, 255, 255)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            floatKeybind = input.KeyCode
            listeningForKey = false
            kbBtnF.Text = "BIND"
            kbBtnF.TextColor3 = GOLD
            updateFloatLabel()
        end)
    end)

    local function toggleFloat()
        if listeningForKey then return end
        local on = not getState()
        setVisual(on)
        Features.Float = on
        if on then
            startFloat()
        else
            stopFloat()
        end
    end

    _G.stopFloatVisual = function()
        setVisual(false)
    end

    btn.MouseButton1Click:Connect(toggleFloat)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == floatKeybind then
            toggleFloat()
        end
    end)
    ToggleControls.Float = {setVisual = setVisual, start = startFloat, stop = stopFloat}
end

do
    local btn, setVisual, getState = makeToggleHeader(rightScroll, "Unwalk")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.Unwalk = on
        if on then startUnwalk() else stopUnwalk() end
    end)
    ToggleControls.Unwalk = {setVisual = setVisual, start = startUnwalk, stop = stopUnwalk}
end

do
    local btn, setVisual, getState = makeToggleHeader(rightScroll, "Optimizer")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.Optimizer = on
        if on then enableOptimizer() else disableOptimizer() end
    end)
    ToggleControls.Optimizer = {setVisual = setVisual, start = enableOptimizer, stop = disableOptimizer}
end

do
    local btn, setVisual, getState = makeToggleHeader(rightScroll, "XRay")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.XRay = on
        if on then enableXRay() else disableXRay() end
    end)
    ToggleControls.XRay = {setVisual = setVisual, start = enableXRay, stop = disableXRay}
end

do
    local btn, setVisual, getState = makeToggleHeader(rightScroll, "Walk Fling")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.WalkFling = on
        walkfling(on)
    end)
    ToggleControls.WalkFling = {setVisual = setVisual, start = function() walkfling(true) end, stop = function() walkfling(false) end}
end

-- TP Auto Features (Regular Toggles)
do
    local btn, setVisual, getState = makeToggleHeader(rightScroll, "TP Right + Auto")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.TPRightAuto = on
        ragdollAutoActiveRight = on
        if on then
            startRagdollDetector()
            task.spawn(function()
                doTPRight()
                task.wait(0.2)
            end)
        else
            if not ragdollAutoActiveLeft then
                stopRagdollDetector()
            end
        end
    end)
end

do
    local btn, setVisual, getState = makeToggleHeader(rightScroll, "TP Left + Auto")
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.TPLeftAuto = on
        ragdollAutoActiveLeft = on
        if on then
            startRagdollDetector()
            task.spawn(function()
                doTPLeft()
                task.wait(0.2)
            end)
        else
            if not ragdollAutoActiveRight then
                stopRagdollDetector()
            end
        end
    end)
end

-- Save Config Button
do
    local saveFrame = Instance.new("Frame", rightScroll)
    saveFrame.Size = UDim2.new(1, -10 * guiScale, 0, 40 * guiScale)
    saveFrame.BackgroundColor3 = BLACK
    saveFrame.BackgroundTransparency = 0.2
    saveFrame.BorderSizePixel = 0
    saveFrame.LayoutOrder = toggleSliderOrder
    toggleSliderOrder = toggleSliderOrder + 1
    Instance.new("UICorner", saveFrame).CornerRadius = UDim.new(0, 8 * guiScale)

    local sStroke = Instance.new("UIStroke", saveFrame)
    sStroke.Thickness = 2 * guiScale
    sStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sStroke.Color = GOLD
    table.insert(goldBoxes, sStroke)

    local saveBtn = Instance.new("TextButton", saveFrame)
    saveBtn.Size = UDim2.new(1, 0, 1, 0)
    saveBtn.BackgroundTransparency = 1
    saveBtn.Text = "Save Config"
    saveBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    saveBtn.Font = Enum.Font.GothamBlack
    saveBtn.TextSize = 12 * guiScale
    saveBtn.TextXAlignment = Enum.TextXAlignment.Center

    saveBtn.MouseButton1Click:Connect(function()
        local config = {
            features = Features,
            values = Values,
            keybinds = {
                speedBoost = speedKeybind.Name,
                float = floatKeybind.Name,
                rightSteal = rightKeybind.Name,
                leftSteal = leftKeybind.Name,
                batAimbot = batKeybind.Name,
                meleeAimbot = meleeKeybind.Name,
                autoPathRight = autoPathRightKeybind.Name,
                autoPathLeft = autoPathLeftKeybind.Name,
                quickTPRight = quickTPRightKeybind.Name,
                quickTPLeft = quickTPLeftKeybind.Name,
                taught = taughtKeybind.Name,
            }
        }
        local success, err = pcall(function()
            writefile(configFile, HttpService:JSONEncode(config))
        end)
        if success then
            saveBtn.Text = "Saved!!"
            saveBtn.TextColor3 = GOLD
            task.delay(1, function()
                saveBtn.Text = "Save Config"
                saveBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            end)
        else
            saveBtn.Text = "Failed: " .. (err or "Unknown error")
            saveBtn.TextColor3 = Color3.fromRGB(255,0,0)
            task.delay(2, function()
                saveBtn.Text = "Save Config"
                saveBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            end)
        end
    end)
end

-- Canvas size updates
leftLayout.Changed:Connect(function()
    leftScroll.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 16 * guiScale)
end)
middleLayout.Changed:Connect(function()
    middleScroll.CanvasSize = UDim2.new(0, 0, 0, middleLayout.AbsoluteContentSize.Y + 16 * guiScale)
end)
rightLayout.Changed:Connect(function()
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 16 * guiScale)
end)

-- Initialize saved states for menu toggles
for name, ctrl in pairs(ToggleControls) do
    if Features[name] then
        ctrl.setVisual(true)
        if ctrl.start then
            ctrl.start()
        end
    end
end

-- Initialize saved states for compact buttons
if Features.AutoPathRight then
    CompactButtons.AutoPathRight.setVisual(true)
    startAutoPath("right")
end
if Features.AutoPathLeft then
    CompactButtons.AutoPathLeft.setVisual(true)
    startAutoPath("left")
end
if Features.BatAimbot then
    CompactButtons.BatAimbot.setVisual(true)
    startBatAimbot()
end
if Features.MeleeAimbot then
    CompactButtons.MeleeAimbot.setVisual(true)
    startMeleeAimbot()
end

-- Countdown detection for auto path
spawn(function()
    local ok, label = pcall(function()
        return player.PlayerGui:FindFirstChild("DuelsMachineTopFrame")
            and player.PlayerGui.DuelsMachineTopFrame:FindFirstChild("DuelsMachineTopFrame")
            and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame:FindFirstChild("Timer")
            and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer:FindFirstChild("Label")
    end)
    if ok and label then
        local function onTextChanged()
            local ok, number = isCountdownNumber(label.Text)
            if ok and number == 1 then
                if waitingForCountdownLeft then
                    task.wait(AUTO_START_DELAY)
                    waitingForCountdownLeft = false
                    if not Features.AutoPathLeft then
                        CompactButtons.AutoPathLeft.setVisual(true)
                        Features.AutoPathLeft = true
                        startAutoPath("left")
                        CompactButtons.AutoPathLeft.lbl.Text = "Auto Left [" .. autoPathLeftKeybind.Name .. "]"
                    end
                end
                if waitingForCountdownRight then
                    task.wait(AUTO_START_DELAY)
                    waitingForCountdownRight = false
                    if not Features.AutoPathRight then
                        CompactButtons.AutoPathRight.setVisual(true)
                        Features.AutoPathRight = true
                        startAutoPath("right")
                        CompactButtons.AutoPathRight.lbl.Text = "Auto Right [" .. autoPathRightKeybind.Name .. "]"
                    end
                end
            end
        end
        onTextChanged()
        label:GetPropertyChangedSignal("Text"):Connect(onTextChanged)
    end
end)

-- Cleanup
sg.Destroying:Connect(function()
    if autoPathHeartbeat then autoPathHeartbeat:Disconnect() end
    if ragdollDetectorConn then ragdollDetectorConn:Disconnect() end
    if progressConn then progressConn:Disconnect() end
    if Connections.speed then Connections.speed:Disconnect() end
    if antiRagdollConnection then antiRagdollConnection:Disconnect() end
    if Cebo.Conn then Cebo.Conn:Disconnect() end
    if infJumpConn1 then infJumpConn1:Disconnect() end
    if infJumpConn2 then infJumpConn2:Disconnect() end
    if autoStealConn then autoStealConn:Disconnect() end
    if speedWhileStealingConn then speedWhileStealingConn:Disconnect() end
    if Connections.bat then Connections.bat:Disconnect() end
    if floatConn then floatConn:Disconnect() end
    stopSpinBot()
    stopUnwalk()
    disableOptimizer()
    disableXRay()
    walkfling(false)
end)
Affichage de 87P2aNQU.txt
