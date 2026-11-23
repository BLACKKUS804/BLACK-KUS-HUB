--==============================================================
-- BLACK KUS HUB
-- WindUI Edition • Liquid Black Glass
-- Main / Movement / Visuals / Appearance
--==============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

local SKY_Y = 500
local GROUP_URL = "https://t.me/BLACkKusStoer"

_G.autoSoul = false
_G.farmLevel = false
_G.isJumping = false
_G.playerLines = false
_G.playerHitboxes = false

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--==============================================================
-- CLEANUP
--==============================================================

if CoreGui:FindFirstChild("BLACK_KUS_OVERLAY") then
    CoreGui.BLACK_KUS_OVERLAY:Destroy()
end

pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("BLACK_KUS_OVERLAY") then
        pg.BLACK_KUS_OVERLAY:Destroy()
    end
end)

pcall(function()
    if typeof(gethui) == "function" then
        local h = gethui()
        if h and h:FindFirstChild("BLACK_KUS_OVERLAY") then
            h.BLACK_KUS_OVERLAY:Destroy()
        end
    end
end)

--==============================================================
-- WINDUI LOADER
--==============================================================

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
end)

if not success or not WindUI then
    warn("BLACK KUS: WindUI failed to load")
    return
end

local WHITE = Color3.fromRGB(255,255,255)
local GREEN = Color3.fromRGB(120,255,180)
local RED = Color3.fromRGB(255,120,130)
local PURPLE = Color3.fromRGB(170,80,255)

--==============================================================
-- TELEGRAM
--==============================================================

task.spawn(function()
    task.wait(1)
    local opened = pcall(function()
        GuiService:OpenBrowserWindow(GROUP_URL)
    end)
    if not opened then
        warn("BLACK KUS: Automatic Telegram opening was blocked.")
    end
end)

local function openGroupLink()

    local opened = pcall(function()
        GuiService:OpenBrowserWindow(GROUP_URL)
    end)

    if opened then
        return
    end

    local copied = false

    if typeof(setclipboard) == "function" then
        copied = pcall(function()
            setclipboard(GROUP_URL)
        end)
    end

    if copied then
        WindUI:Notify({
            Title = "RAINBOW GROUP",
            Content = "Link copied! Paste it into your browser.",
            Icon = "check",
            Duration = 4,
        })
    else
        WindUI:Notify({
            Title = "RAINBOW GROUP",
            Content = GROUP_URL,
            Icon = "alert-circle",
            Duration = 6,
        })
    end

end

--==============================================================
-- WINDOW
--==============================================================

local Window = WindUI:CreateWindow({
    Title = "BLACK KUS HUB",
    Author = "Original Liquid Black Glass",
    Icon = "wind",
    Folder = "BLACK_KUS_HUB",
    Theme = "Dark",
    Size = UDim2.fromOffset(580,440),
    MinSize = Vector2.new(320,300),
    Resizable = true,
    Transparent = true,
    SideBarWidth = 170,
    ScrollBarEnabled = true,
    HideSearchBar = false,
    ToggleKey = Enum.KeyCode.RightControl,
})

Window:Tag({
    Title = "BLACK KUS",
    Color = PURPLE,
})

local GroupTag = Window:Tag({
    Title = "RAINBOW GROUP",
    Color = Color3.fromRGB(255,60,100),
})

local rainbowRunning = true
local rainbowHue = 0

Window:OnDestroy(function()
    rainbowRunning = false
end)

task.spawn(function()
    while rainbowRunning do
        rainbowHue = (rainbowHue + 0.008) % 1
        local color = Color3.fromHSV(rainbowHue, 0.85, 1)
        pcall(function()
            GroupTag:SetColor(color)
        end)
        task.wait(0.06)
    end
end)

Window:CreateTopbarButton(
    "RainbowGroup",
    "rainbow",
    function()
        openGroupLink()
    end,
    990
)

--==============================================================
-- TABS
--==============================================================

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
})

local MovementTab = Window:Tab({
    Title = "Movement",
    Icon = "footprints",
})

local VisualTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

local AppearanceTab = Window:Tab({
    Title = "Appearance",
    Icon = "palette",
})

--==============================================================
-- VISUAL COLORS
--==============================================================

local VisualColors = {
    { name = "Cyan",   color = Color3.fromRGB(0,220,255) },
    { name = "Red",    color = Color3.fromRGB(255,65,65) },
    { name = "Green",  color = Color3.fromRGB(70,255,100) },
    { name = "Purple", color = Color3.fromRGB(190,80,255) },
    { name = "Yellow", color = Color3.fromRGB(255,220,50) },
    { name = "White",  color = Color3.fromRGB(255,255,255) },
}

local lineColorIndex = 1
local hitboxColorIndex = 4

local function getColorNames()
    local names = {}
    for _,v in ipairs(VisualColors) do
        table.insert(names,v.name)
    end
    return names
end

local function findColorIndex(name)
    for i,v in ipairs(VisualColors) do
        if v.name == name then
            return i
        end
    end
    return 1
end

--==============================================================
-- OVERLAY GUI
--==============================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "BLACK_KUS_OVERLAY"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

local okParent = pcall(function()
    ScreenGui.Parent =
        (typeof(gethui) == "function" and gethui())
        or CoreGui
end)

if not okParent or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--==============================================================
-- DRAGGABLE
--==============================================================

local function makeDraggable(gui, canDrag)

    local dragging = false
    local dragged = false
    local dragStart
    local startPos

    gui.InputBegan:Connect(function(input)

        dragged = false

        if canDrag and not canDrag() then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart

            if delta.Magnitude > 8 then
                dragged = true
            end

            if dragged then
                gui.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end

        end

    end)

    return function()
        return dragged
    end

end

--==============================================================
-- JUMP BUTTON (locked until "Unlock Jump")
--==============================================================

local jumpUnlocked = false

local jumpBtn = Instance.new("TextButton")

jumpBtn.Name = "JumpButton"
jumpBtn.Size = UDim2.new(0,110,0,42)
jumpBtn.Position = UDim2.new(0.8,0,0.4,0)
jumpBtn.Visible = false
jumpBtn.Text = "JUMP [OFF]"
jumpBtn.TextColor3 = RED
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 14
jumpBtn.BackgroundColor3 = Color3.fromRGB(15,15,20)
jumpBtn.BackgroundTransparency = 0.1
jumpBtn.BorderSizePixel = 0
jumpBtn.ZIndex = 100
jumpBtn.Parent = ScreenGui

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0,14)
jumpCorner.Parent = jumpBtn

local jumpStroke = Instance.new("UIStroke")
jumpStroke.Color = PURPLE
jumpStroke.Transparency = 0.2
jumpStroke.Thickness = 1.5
jumpStroke.Parent = jumpBtn

local jumpDragged = makeDraggable(jumpBtn, function()
    return jumpUnlocked
end)

jumpBtn.MouseButton1Click:Connect(function()

    if jumpDragged() then
        return
    end

    _G.isJumping = not _G.isJumping

    jumpBtn.Text = _G.isJumping and "JUMP [ON]" or "JUMP [OFF]"
    jumpBtn.TextColor3 = _G.isJumping and GREEN or RED

end)

--==============================================================
-- FPS COUNTER
--==============================================================

local fpsLabel = Instance.new("TextLabel")

fpsLabel.Name = "FPSCounter"
fpsLabel.Size = UDim2.new(0,110,0,34)
fpsLabel.Position = UDim2.new(0.5,-55,0,10)
fpsLabel.Visible = false
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = WHITE
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.BackgroundColor3 = Color3.fromRGB(15,15,20)
fpsLabel.BackgroundTransparency = 0.1
fpsLabel.BorderSizePixel = 0
fpsLabel.ZIndex = 100
fpsLabel.Active = true
fpsLabel.Parent = ScreenGui

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0,10)
fpsCorner.Parent = fpsLabel

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = PURPLE
fpsStroke.Transparency = 0.2
fpsStroke.Parent = fpsLabel

makeDraggable(fpsLabel)

do
    local frames = 0
    local last = os.clock()

    RunService.RenderStepped:Connect(function()

        frames += 1

        local now = os.clock()

        if now-last >= 0.5 then

            if fpsLabel.Visible then
                fpsLabel.Text = "FPS: "..math.floor(frames/(now-last)+0.5)
            end

            frames = 0
            last = now

        end

    end)
end

--==============================================================
-- MOVEMENT STATE
--==============================================================

local Movement = {
    jumpOn = false,
    jumpValue = 50,       -- % (1-100)
    noclip = false,
    infJump = false,
    doubleJump = false,
    fly = false,
    flySpeed = 50,        -- % (1-100)
}

local DEFAULT_JUMP = 50
local MAX_JUMP = 250      -- 100% = 250 jump power

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function applyWalkJump()

    local hum = getHumanoid()

    if not hum then
        return
    end

    if Movement.jumpOn then
        hum.UseJumpPower = true
        hum.JumpPower = math.max(1, MAX_JUMP * Movement.jumpValue / 100)
    end

end

local function resetJump()
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = DEFAULT_JUMP
    end
end

--==============================================================
-- FLY
--==============================================================

local flyBV, flyBG

local function stopFly()

    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end

    local hum = getHumanoid()

    if hum then
        hum.PlatformStand = false
    end

end

local function startFly()

    local root = getRoot()
    local hum = getHumanoid()

    if not root or not hum then
        return
    end

    stopFly()

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBG.P = 9e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root

    hum.PlatformStand = true

end

--==============================================================
-- MAIN TAB
--==============================================================

MainTab:Section({
    Title = "Main Features",
})

MainTab:Toggle({
    Title = "Sky Farm Mode",
    Desc = "Enable or disable Sky Farm",
    Value = false,
    Callback = function(state)
        _G.farmLevel = state
    end,
})

MainTab:Toggle({
    Title = "Auto Collect Souls",
    Desc = "Automatically search for souls",
    Value = false,
    Callback = function(state)
        _G.autoSoul = state
    end,
})

MainTab:Toggle({
    Title = "Show Jump Button",
    Desc = "Show the auto jump button (fixed in place)",
    Value = false,
    Callback = function(state)
        jumpBtn.Visible = state
    end,
})

MainTab:Toggle({
    Title = "Unlock Jump",
    Desc = "ON = drag the jump button. OFF = locked in place",
    Value = false,
    Callback = function(state)
        jumpUnlocked = state
    end,
})

MainTab:Toggle({
    Title = "Show FPS",
    Desc = "Display draggable FPS counter",
    Value = false,
    Callback = function(state)
        fpsLabel.Visible = state
    end,
})

--==============================================================
-- MOVEMENT TAB
--==============================================================

MovementTab:Section({
    Title = "Speed & Jump",
})

MovementTab:Toggle({
    Title = "Power Jump",
    Desc = "Boost your jump height",
    Value = false,
    Callback = function(state)
        Movement.jumpOn = state
        if state then applyWalkJump() else resetJump() end
    end,
})

MovementTab:Slider({
    Title = "Jump Power",
    Desc = "1% - 100%",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 50 },
    Callback = function(value)
        Movement.jumpValue = value
        if Movement.jumpOn then applyWalkJump() end
    end,
})

MovementTab:Section({
    Title = "Extra Movement",
})

MovementTab:Toggle({
    Title = "Double Jump",
    Desc = "Jump one extra time in the air",
    Value = false,
    Callback = function(state)
        Movement.doubleJump = state
    end,
})

MovementTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump again while in the air",
    Value = false,
    Callback = function(state)
        Movement.infJump = state
    end,
})

MovementTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(state)
        Movement.noclip = state
    end,
})

MovementTab:Toggle({
    Title = "Fly",
    Desc = "Fly in the direction you move / look",
    Value = false,
    Callback = function(state)
        Movement.fly = state
        if state then startFly() else stopFly() end
    end,
})

MovementTab:Slider({
    Title = "Fly Speed",
    Desc = "1% - 100%",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 50 },
    Callback = function(value)
        Movement.flySpeed = value
    end,
})

--==============================================================
-- MOVEMENT LOGIC
--==============================================================

-- Infinite jump
local usedDouble = false

UserInputService.JumpRequest:Connect(function()

    local hum = getHumanoid()

    if not hum then
        return
    end

    local inAir = hum.FloorMaterial == Enum.Material.Air

    if Movement.infJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        return
    end

    if Movement.doubleJump and inAir and not usedDouble then
        usedDouble = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

end)

-- reset double jump when back on the ground
RunService.Heartbeat:Connect(function()

    local hum = getHumanoid()

    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        usedDouble = false
    end

end)

-- Noclip + keep speed/jump applied + fly steering
RunService.Stepped:Connect(function()

    if Movement.noclip then

        local char = LocalPlayer.Character

        if char then
            for _,part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

    end

end)

RunService.RenderStepped:Connect(function()

    if Movement.jumpOn then
        applyWalkJump()
    end

    if Movement.fly and flyBV and flyBG then

        local camera = workspace.CurrentCamera
        local hum = getHumanoid()
        local root = getRoot()

        if camera and hum and root then

            local move = hum.MoveDirection
            local speed = math.max(1, 200 * Movement.flySpeed / 100)

            local vel = Vector3.zero

            if move.Magnitude > 0 then
                -- move relative to where the camera looks (includes up/down)
                local look = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local fwd = move:Dot(Vector3.new(look.X,0,look.Z).Unit)
                local side = move:Dot(Vector3.new(right.X,0,right.Z).Unit)
                vel = (look * fwd + right * side) * speed
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel += Vector3.new(0,speed,0)
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel -= Vector3.new(0,speed,0)
            end

            flyBV.Velocity = vel
            flyBG.CFrame = camera.CFrame

        end

    end

end)

-- Re-apply after respawn
LocalPlayer.CharacterAdded:Connect(function()

    task.wait(0.5)

    if Movement.fly then
        startFly()
    end

    applyWalkJump()

end)

-- Clean up when window closes
Window:OnDestroy(function()
    Movement.doubleJump = false
    Movement.jumpOn = false
    Movement.noclip = false
    Movement.infJump = false
    Movement.fly = false
    stopFly()
    resetJump()
end)

--==============================================================
-- GAME FOLDER (Anti Push + Pause Notice)
--==============================================================

local GameFolder = Window:Section({
    Title = "Game",
    Icon = "folder",
    Opened = true,
})

local GameTab = GameFolder:Tab({
    Title = "Anti Push",
    Icon = "shield",
})

local GameState = {
    antiPush = false,
    noCollide = true,
}

GameTab:Section({
    Title = "Anti Push",
})

GameTab:Toggle({
    Title = "Anti Push",
    Desc = "Other players can't push or fling you",
    Value = false,
    Callback = function(state)
        GameState.antiPush = state
    end,
})

GameTab:Toggle({
    Title = "Walk Through Players",
    Desc = "Turns off collision with other players (part of Anti Push)",
    Value = true,
    Callback = function(state)
        GameState.noCollide = state
    end,
})

GameTab:Section({
    Title = "Game",
})

local function setPausedNotice(disabled)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not disabled)
    end)
end

-- hide the "gameplay paused" notification on load
setPausedNotice(true)

GameTab:Toggle({
    Title = "Hide Paused Notice",
    Desc = "Disable the gameplay paused notification",
    Value = true,
    Callback = function(state)
        setPausedNotice(state)
    end,
})

-- Anti Push logic
RunService.Stepped:Connect(function()

    if not GameState.antiPush then
        return
    end

    -- no collision with other players
    if GameState.noCollide then
        for _,plr in ipairs(Players:GetPlayers
