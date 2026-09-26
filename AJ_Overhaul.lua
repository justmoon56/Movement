-- Global Services
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService('Lighting')
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local CAS = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local FluentModify = loadstring(game:HttpGet("https://raw.githubusercontent.com/justmoon56/FluentModify/refs/heads/main/CoreNotify/NewCustomNotify.lua"))()

if _G.FluentModifyIsAlreadyRunning then
    FluentModify:CustomNotify({
        Title = "Interface",
        Content = "Callback error", 
        SubContent = "Script is already running!",
        Type = "Error",
        Duration = 3
     })
    return
end

_G.FluentModifyIsAlreadyRunning = true

local Fluent = loadstring(game:HttpGet("https://github.com/justmoon56/FluentModify/releases/download/V1.4.1/FluentTesting"))()

local Window = Fluent:CreateWindow({
    Title = "Bhop",
    SubTitle = "Open Source",
    TabWidth = 160,
    Size = UDim2.fromOffset(540, 390),
    Acrylic = true,
    Theme = "Deep Ocean",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = false,
})

local Tabs = {
    Misc = Window:AddTab({ Title = "Movement", Icon = "rbxassetid://7734068321" })
}

local Options = Fluent.Options

-- Optimize (1)
local function GetAutoDuration()
    local dt = RunService.RenderStepped:Wait()
    local fps = 1 / dt
    local duration = 900 / math.clamp(fps, 5, 900)
    return math.clamp(duration, 1, 9)
end

local Duration = GetAutoDuration()
local AssetsIcon = "rbxassetid://98607076307819"

local function MakeDraggable(topbarobject, object, locked)
    local Dragging = false
    local DragInput, DragStart, StartPosition
    local Holding = false
    local HoldTime = 1.0
    local MoveCancelThreshold = 6
    local HoldToken = 0
    object:SetAttribute("Locked", locked or false)

    local function Update(input)
        if object:GetAttribute("Locked") then return end
        local delta = input.Position - DragStart
        object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
    end

    local function ToggleLock()
        local newState = not object:GetAttribute("Locked")
        object:SetAttribute("Locked", newState)
        Fluent:Notify({Title = newState and "Button Locked" or "Button Unlocked", Content = newState and "This button is now locked in place." or "This button can now be moved.", Duration = 2})
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        Dragging = not object:GetAttribute("Locked")
        Holding = true
        DragStart = input.Position
        StartPosition = object.Position
        HoldToken += 1
        local token = HoldToken
        task.delay(HoldTime, function() if Holding and token == HoldToken then ToggleLock() end end)
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false; Holding = false end end)
    end)

    topbarobject.InputChanged:Connect(function(input)
        if not DragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if (input.Position - DragStart).Magnitude > MoveCancelThreshold then Holding = false end
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then Update(input) end end)
end

local openGui = Instance.new("ScreenGui")
openGui.Name = "openGui"
openGui.Parent = CoreGui
openGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
openGui.ResetOnSpawn = false

local mainopen = Instance.new("TextButton")
mainopen.Name = "mainopen"
mainopen.Parent = openGui
mainopen.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainopen.BackgroundTransparency = 1
mainopen.Position = UDim2.new(0.101969875, 0, 0.110441767, 0)
mainopen.Size = UDim2.new(0, 64, 0, 42)
mainopen.Text = ""
mainopen.Visible = true

local mainopens = Instance.new("UICorner")
mainopens.Parent = mainopen

local frontImage = Instance.new("ImageLabel")
frontImage.Name = "StaticIcon"
frontImage.Parent = mainopen
frontImage.Size = UDim2.new(0.94, 0, 2, 0)
frontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
frontImage.AnchorPoint = Vector2.new(0.5, 0.5)
frontImage.BackgroundTransparency = 1
frontImage.Image = AssetsIcon
frontImage.ScaleType = Enum.ScaleType.Fit
frontImage.ZIndex = 2

local frontCorner = Instance.new("UICorner")
frontCorner.CornerRadius = UDim.new(0.2, 0)
frontCorner.Parent = frontImage

local frame = Instance.new("Frame")
frame.Name = "GradientFrame"
frame.Size = frontImage.Size
frame.Position = frontImage.Position
frame.AnchorPoint = frontImage.AnchorPoint
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.7
frame.Parent = mainopen

local aspectConstraint = Instance.new("UIAspectRatioConstraint")
aspectConstraint.AspectRatio = 1
aspectConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
aspectConstraint.DominantAxis = Enum.DominantAxis.Width
aspectConstraint.Parent = frame

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = frontCorner.CornerRadius
frameCorner.Parent = frame

-- Gradient Variables Fallback
getgenv().ButtonGradients = getgenv().ButtonGradients or {
    Background = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(20, 20, 20)),
    Stroke = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(100, 100, 100))
}

local gradient = Instance.new("UIGradient")
gradient.Color = getgenv().ButtonGradients.Background
gradient.Parent = frame

task.spawn(function()
    while frame.Parent do
        gradient.Rotation = (gradient.Rotation + 1) % 360
        gradient.Color = getgenv().ButtonGradients.Background
        task.wait(0.03)
    end
end)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Color = Color3.new(1, 1, 1)
Stroke.Parent = frame

local gradientstroke = Instance.new("UIGradient")
gradientstroke.Color = getgenv().ButtonGradients.Stroke
gradientstroke.Rotation = 0
gradientstroke.Parent = Stroke

task.spawn(function()
    while frame.Parent do
       gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
       gradientstroke.Color = getgenv().ButtonGradients.Stroke
       task.wait()
    end
end)

MakeDraggable(mainopen, mainopen, false)

mainopen.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local DFunctions = {}
local CurrentAdjustment = {}
local DConfiguration = {
    Misc = {
        PlayerAdjustment = {
            Default = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },
            Update = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },
            Saved = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },
            Tick = {
                Speed = 0,
                JumpHeight = 0,
                JumpCap = 0,
                JumpAcceleration = 0,
                AirStrafe = 0,
                GroundAcceleration = 0,
            },
            Debounce = {
                Speed = false,
                JumpHeight = false,
                JumpCap = false,
                JumpAcceleration = false,
                AirStrafe = false,
                GroundAcceleration = false,
            },
        },
        Humanoids = {
            WalkspeedCF = false,
            OriginalJumpHeight = false,
            CF = 5,
            JP = 20,
        },
        Utilities = {
            GetCurrentSpeed = 0,
            BounceModification = {
                Enabled = false,
                DefaultBounce = 80,
                EmoteBounce = 120,
                SuperBounce = false,
                SuperBounceStrength = -50,
            },
            EdgeTrimpModification = {
                Enabled = false,
                HeightMultiplier = 1.5,
                DownThreshold = 4.5
            },
            LagSwitch = {
                MSDelay = 200,
                Mode = "Normal",
            },
        },
        CameraAdjustment = {
            StretchX = 1,
            StretchY = 1,
        },
        GunAdjustment = {
            v = nil,
        },
        GameAutomation = {
            Revive = {
                Enabled = false,
                FloatingButton = false,
                Keybind = false,
                WhileEmote = false,
                Delay = 0.1,
            },
            Carry = {
                Enabled = false,
                FloatingButton = false,
                Keybind = false,
                WhileEmote = false,
            },
            Macro = {
                SelectedEmote = "BoldMarch",
                FloatingButton = false,
                Keybind = false,
            },
        },
        MovementModification = {
            AggressiveEmoteDash = {
                Enabled = false,
                Type = "Blatant",
                Speed = 3000,
                Acceleration = -2,
            },
            SlideModification = {
                FloatingButton = false,
                Enabled = false,
                Acceleration = -3,
            },
            Gravity = {
                FloatingButton = false,
                Keybind = false,
                Value = 10,
            },
            BHOP = {
                Enabled = false,
                Keybind = false,
                FloatingButton = false,
                AutoAcceleration = false,
                MaxSpeed = 70,
                SpiderHop = false,
                Backwards = false,
                JumpButton = false,
                HipHeight1 = 0,
                HipHeight2 = 0,
                Type = "Acceleration",
                JumpType = "Simulated",
                Acceleration = -0.1,
                lastTick = 0.01,
            },
        },
    },
    Visual = {
        OriginalCosmetics = {
            Cosmetics1 = "", Cosmetics2 = "", Cosmetics3 = "", Cosmetics4 = "",
        },
        ModifyCosmetics = {
            Cosmetics1 = "", Cosmetics2 = "", Cosmetics3 = "", Cosmetics4 = "",
        },
        OriginalEmotes = {
            Emote1 = "", Emote2 = "", Emote3 = "", Emote4 = "", Emote5 = "", Emote6 = "",
            Emote7 = "", Emote8 = "", Emote9 = "", Emote10 = "", Emote11 = "", Emote12 = "",
        },
        ModifyEmotes = {
            Emote1 = "", Emote2 = "", Emote3 = "", Emote4 = "", Emote5 = "", Emote6 = "",
            Emote7 = "", Emote8 = "", Emote9 = "", Emote10 = "", Emote11 = "", Emote12 = "",
        },
    },
    Settings = {
        GuiScale = {
            Respawn = 0, SuperBounce = 0, AutoCarry = 0, InstantRevive = 0, AutoEmoteDash = 0,
            Gravity = 0, InfiniteSlide = 0, AutoJump = 0, AutoCrouch = 0, LagSwitch = 0,
        },
    },
}

-- Functions

function DFunctions.CreateButton(ButtonName, Name, Size1, Size2, ScriptLogic, CircleMode)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = ButtonName
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = ButtonName
    frame.Size = UDim2.new(Size1, 0, Size2, 0)
    frame.Position = UDim2.new(0.5 - Size1 / 2, 0, 0.5 - Size2 / 2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.7
    frame.Parent = screenGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = getgenv().ButtonGradients.Background
    gradient.Parent = frame

    task.spawn(function()
        while frame and frame.Parent do
            gradient.Rotation = (gradient.Rotation + 1) % 360
            gradient.Color = getgenv().ButtonGradients.Background
            task.wait(0.03)
        end
    end)

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Color = Color3.new(1, 1, 1)
    Stroke.Parent = frame

    local gradientstroke = Instance.new("UIGradient")
    gradientstroke.Color = getgenv().ButtonGradients.Stroke
    gradientstroke.Rotation = 0
    gradientstroke.Parent = Stroke

    task.spawn(function()
        while frame and frame.Parent do
           gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
           gradientstroke.Color = getgenv().ButtonGradients.Stroke
           task.wait(0.05)
        end
    end)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = Name
    button.Font = Enum.Font.SourceSansBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Name = "CircleToggle"
    toggle.Size = UDim2.new(0, 28, 0, 28)
    toggle.Position = UDim2.new(1, 6, 0.5, -14)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.Text = "○"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Visible = false
    toggle.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggle

    local transToggle = Instance.new("ImageButton")
    transToggle.Name = "TransparencyToggle"
    transToggle.Size = UDim2.new(0, 28, 0, 28)
    transToggle.Position = UDim2.new(0, -34, 0.5, -14)
    transToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    transToggle.Image = "rbxassetid://90339998542392"
    transToggle.ScaleType = Enum.ScaleType.Fit
    transToggle.Visible = false
    transToggle.Parent = frame

    local transCorner = Instance.new("UICorner")
    transCorner.CornerRadius = UDim.new(1, 0)
    transCorner.Parent = transToggle

    local originalSize = UDim2.new(Size1, 0, Size2, 0)
    local holding = false
    local holdStart = 0
    local hideAt = 0

    frame:SetAttribute("IsCircle", false)
    frame:SetAttribute("IsTransparency", false)

    local isCircle = (CircleMode ~= nil) and CircleMode or frame:GetAttribute("IsCircle")

    local function applyShape(circle)
        frame:SetAttribute("IsCircle", circle)
        local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
        if circle then
            frame.Size = UDim2.new(0, s, 0, s)
            button.TextWrapped = true
            button.TextScaled = true
            button.TextSize = math.floor(s * 0.45)
            corner.CornerRadius = UDim.new(1, 0)
            toggle.Text = "▢"
        else
            frame.Size = originalSize
            button.TextWrapped = false
            button.TextScaled = false
            button.TextSize = 24
            corner.CornerRadius = UDim.new(0, 15)
            toggle.Text = "○"
        end
    end

    local function applyTransparency(transparent)
        frame:SetAttribute("IsTransparency", transparent)
        if transparent then
            frame.BackgroundTransparency = 1
            Stroke.Enabled = false
            button.TextTransparency = 1
        else
            frame.BackgroundTransparency = 0.7
            Stroke.Enabled = true
            button.TextTransparency = 0
        end
    end

    applyShape(isCircle)
    applyTransparency(false)

    task.spawn(function()
        while frame and frame.Parent do
            if (toggle.Visible or transToggle.Visible) and os.clock() - hideAt >= 10 then
                toggle.Visible = false
                transToggle.Visible = false
            end
            task.wait(0.25)
        end
    end)

    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            holding = true
            holdStart = os.clock()
        end
    end)

    button.InputEnded:Connect(function(i)
        if holding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            holding = false
            if os.clock() - holdStart >= 0.6 then
                toggle.Visible = true
                transToggle.Visible = true
                hideAt = os.clock()
            end
        end
    end)

    toggle.MouseButton1Click:Connect(function()
        hideAt = os.clock()
        applyShape(not frame:GetAttribute("IsCircle"))
    end)

    transToggle.MouseButton1Click:Connect(function()
        hideAt = os.clock()
        applyTransparency(not frame:GetAttribute("IsTransparency"))
    end)

    button.Activated:Connect(function()
        if ScriptLogic then
            ScriptLogic(button)
        end
    end)

    MakeDraggable(button, frame, false)

    return button
end

function DFunctions.UpdateButton(Name, Size1, Size2)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui and gui:FindFirstChild(Name) then
        gui[Name].Size = UDim2.new(Size1, 0, Size2, 0)
    end
end

function DFunctions.DestroyButton(Name)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui then
        gui:Destroy()
    end
end

function DFunctions.GetAdjustments()
    table.clear(CurrentAdjustment)
    local character = LocalPlayer.Character
    if not character then return end

    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local char = rawget(v, "Character")
                local moveStats = rawget(v, "MoveStats")

                if typeof(char) == "Instance" and char == character then
                    if type(moveStats) == "table" then
                        if not table.find(CurrentAdjustment, moveStats) then
                            table.insert(CurrentAdjustment, moveStats)
                        end
                    end
                end
            end
        end
    end
end

function DFunctions.setTFriction(newFriction)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration ~= newFriction and now - (DConfiguration.Misc.PlayerAdjustment.Tick.GroundAcceleration or 0) >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration = newFriction
        DConfiguration.Misc.PlayerAdjustment.Tick.GroundAcceleration = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "Friction") then
                rawset(stats, "Friction", newFriction)
            end
        end
    end
end

function DFunctions.setBhopEnabled(bool)
    DConfiguration.Misc.MovementModification.BHOP.Enabled = bool

    for i = 1, #CurrentAdjustment do
        local stats = CurrentAdjustment[i]
        if rawget(stats, "BhopEnabled") ~= nil then rawset(stats, "BhopEnabled", bool) end
        if rawget(stats, "AutoBhop") ~= nil then rawset(stats, "AutoBhop", bool) end
        if rawget(stats, "EndJump") ~= nil then rawset(stats, "EndJump", bool) end
        if rawget(stats, "JumpReact") ~= nil then rawset(stats, "JumpReact", bool) end
    end
end

function DFunctions.GetSpeedometer()
    local pcallSuccess, speedometer = pcall(function()
        local shared = LocalPlayer.PlayerGui:WaitForChild("Shared", 2)
        return shared.HUD.Overlay.Default.CharacterInfo.Item:WaitForChild("Speedometer", 2).Players
    end)

    if pcallSuccess and speedometer then
        return speedometer
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local vel = char.HumanoidRootPart.AssemblyLinearVelocity
        local spd = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)
        return { Text = tostring(spd) }
    end

    return { Text = "0" }
end

function DFunctions.BHOPFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidrootpart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local debounce

    if not char or not humanoidrootpart or not humanoid then return end

    if DConfiguration.Misc.MovementModification.BHOP.SpiderHop and char:GetAttribute("State") == "Wallrunning" then
        pcall(function()
            LocalPlayer.PlayerScripts.PlayerScriptLoader.EndJump:Fire()
            LocalPlayer.PlayerScripts.PlayerScriptLoader.JumpReact:Fire()
        end)
    end

    local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)
    local speedNum = tonumber(speedometer.Text) or 0

    if DConfiguration.Misc.MovementModification.BHOP.Type == "Acceleration" then
        if speedNum > 60 then
            DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = isR15 and 2.1 or 0
        else
            DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = isR15 and 1.9 or 0
        end

        debounce = 0.01
        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight2

    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "Ground Acceleration" then
        DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = isR15 and 1.5 or 0
        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight2
        debounce = 0.01      

    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "No Acceleration" then
        debounce = 0.125
    end

    local CanBHOPBackwards = true

    if DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration then
        local Threshold = math.clamp(speedNum, 25, 50)
        local Devisor = math.clamp(speedNum / Threshold, 0, 6) 
        local Decrease = math.clamp(5 - (Devisor * 1.7), 0.01, 2)

        if speedNum < DConfiguration.Misc.MovementModification.BHOP.MaxSpeed then
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
            CanBHOPBackwards = true
        else 
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = Decrease
            CanBHOPBackwards = false
        end
    else
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
    end

    local now = tick()
    local lastGrounded = 0

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        lastGrounded = now
    end

    local grounded = (now - lastGrounded) < 0.06

    if DConfiguration.Misc.MovementModification.BHOP.JumpType == "Simulated" then
        if grounded and (now - DConfiguration.Misc.MovementModification.BHOP.lastTick) > debounce then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            DConfiguration.Misc.MovementModification.BHOP.lastTick = now
        end
    elseif DConfiguration.Misc.MovementModification.BHOP.JumpType == "Realistic" then
        if grounded and (now - DConfiguration.Misc.MovementModification.BHOP.lastTick) > debounce then
            pcall(function()
                LocalPlayer.PlayerScripts.PlayerScriptLoader.EndJump:Fire()
                LocalPlayer.PlayerScripts.PlayerScriptLoader.JumpReact:Fire()
            end)
            DConfiguration.Misc.MovementModification.BHOP.lastTick = now
        end
    end

    if DConfiguration.Misc.MovementModification.BHOP.Backwards then
        local look = humanoidrootpart.CFrame.LookVector
        local vel = humanoidrootpart.AssemblyLinearVelocity

        local movingBackwards = (vel.Magnitude > 0 and look:Dot(vel.Unit) < -0.45)

        if movingBackwards then
            DFunctions.setBhopEnabled(CanBHOPBackwards)
            RunService.Heartbeat:Wait()
            DFunctions.setBhopEnabled(false)
        end
    end
end

function DFunctions.ResetBHOP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)

        if isR15 then
            DConfiguration.Misc.MovementModification.BHOP.HipHeight1 = 2.0
            DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = 2.0
        else
            DConfiguration.Misc.MovementModification.BHOP.HipHeight1 = 0
            DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = 0
        end

        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight1
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        task.wait(0.3)
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        DFunctions.setBhopEnabled(false)
    end
end

local Toggle = Tabs.Misc:AddToggle("BHOPToggle", { Title = "BHOP (Button)", Default = false })

Toggle:OnChanged(function(State)
    if State then
        DFunctions.CreateButton("BHOPGui", "Auto Jump: OFF", 0.15 + DConfiguration.Settings.GuiScale.AutoJump, 0.1 + DConfiguration.Settings.GuiScale.AutoJump, function(btn)
            local currentStatus = not DConfiguration.Misc.MovementModification.BHOP.FloatingButton
            DConfiguration.Misc.MovementModification.BHOP.FloatingButton = currentStatus
            
            if currentStatus then
                btn.Text = "Auto Jump: ON"
                btn.TextColor3 = Color3.fromRGB(100, 255, 100)
                DFunctions.setBhopEnabled(true)
                DFunctions.BHOPFunction()
            else
                btn.Text = "Auto Jump: OFF"
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                DFunctions.ResetBHOP()
            end
        end)
    else
        DFunctions.DestroyButton("BHOPGui")
        DFunctions.ResetBHOP()
    end
end)

local ToggleJump = Tabs.Misc:AddToggle("BHOPJumpButton", {Title = "BHOP (Jump Button)", Default = false })

ToggleJump:OnChanged(function(State)
      DConfiguration.Misc.MovementModification.BHOP.JumpButton = State
end)

if UserInputService.TouchEnabled then
    local TouchGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TouchGui", 5)
    local TouchControlFrame = TouchGui and TouchGui:WaitForChild("TouchControlFrame", 5)
    local JumpButton = TouchControlFrame and TouchControlFrame:FindFirstChild("JumpButton")
    
    if JumpButton then
        local isJumping = false

        JumpButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and DConfiguration.Misc.MovementModification.BHOP.JumpButton then
                if not isJumping then
                    isJumping = true
                    DConfiguration.Misc.MovementModification.BHOP.Enabled = true
                end
            end
        end)

        JumpButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and DConfiguration.Misc.MovementModification.BHOP.JumpButton and not DConfiguration.Misc.MovementModification.BHOP.FloatingButton then
                if isJumping then
                    isJumping = false
                    DConfiguration.Misc.MovementModification.BHOP.Enabled = false
                    task.spawn(DFunctions.ResetBHOP)
                    task.wait(0.1)
                    task.spawn(DFunctions.ResetBHOP)
                end
            end
        end)
    end
end

Tabs.Misc:AddInput("BHOPButtonSize", {
    Title = "BHOP Gui Size",
    Default = tostring(DConfiguration.Settings.GuiScale.AutoJump),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.AutoJump = num * 0.01
        else
            DConfiguration.Settings.GuiScale.AutoJump = 0
        end
        
        DFunctions.UpdateButton("BHOPGui", 0.15 + DConfiguration.Settings.GuiScale.AutoJump, 0.1 + DConfiguration.Settings.GuiScale.AutoJump)
    end
})

local DropdownVersion = Tabs.Misc:AddDropdown("BHOPVersion", {
    Title = "Select BHOP Version",
    Values = {"Acceleration", "Ground Acceleration", "No Acceleration"},
    Multi = false,
    Default = 1,
})

DropdownVersion:OnChanged(function(Value)
    DConfiguration.Misc.MovementModification.BHOP.Type = Value
end)

local DropdownType = Tabs.Misc:AddDropdown("JumpType", {
    Title = "Select Jump Type",
    Values = {"Simulated", "Realistic"},
    Multi = false,
    Default = 1,
})

DropdownType:OnChanged(function(Value)
    DConfiguration.Misc.MovementModification.BHOP.JumpType = Value
end)

local ToggleBackward = Tabs.Misc:AddToggle("BackwardBHOP", {Title = "BHOP Backward", Default = false })

ToggleBackward:OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.Backwards = State
end)

local ToggleSpider = Tabs.Misc:AddToggle("SpiderHop", {Title = "Spider Hop V1", Default = false })

ToggleSpider:OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.SpiderHop = State
end)

Tabs.Misc:AddInput("BHOPAcceleration", {
    Title = "BHOP Acceleration",
    Description = "Negative Only",
    Default = "-0.1",
    Placeholder = "-1",
    Numeric = false, 
    Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.MovementModification.BHOP.Acceleration = tonumber(Value) or -0.1
    end
})

Tabs.Misc:AddParagraph({
    Title = " ",
    Content = ""
})

local ToggleAutoAcc = Tabs.Misc:AddToggle("BHOPAutoAccelerate", {Title = "Max Speed In Acceleration", Default = false })

ToggleAutoAcc:OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration = State
end)

Tabs.Misc:AddInput("BHOPMaxSpeedAcc", {
    Title = "Max Speed Acceleration",
    Default = "70",
    Placeholder = "70",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.MovementModification.BHOP.MaxSpeed = tonumber(Value) or 70
    end
})
