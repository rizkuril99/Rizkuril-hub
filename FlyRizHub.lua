--// RIZKURIL HUB
--// Tab: Movement, Visual, World, Players, Settings
--// Keybind default: F = Fly | N = Noclip | RightShift = Hide (bisa diubah di tab Settings)
--// Tes di game buatan sendiri / Roblox Studio

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer

--------------------------------------------------------------------
-- GUI PARENT (CoreGui kalau bisa, kalau tidak PlayerGui)
--------------------------------------------------------------------
local function GetGuiParent()
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        local testOk = pcall(function()
            local t = Instance.new("Folder")
            t.Parent = core
            t:Destroy()
        end)
        if testOk then return core end
    end
    return Player:WaitForChild("PlayerGui")
end

local GuiParent = GetGuiParent()

pcall(function()
    local old = GuiParent:FindFirstChild("RizKurilHub")
    if old then old:Destroy() end
end)

local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local Connections = {}
local function Track(conn)
    table.insert(Connections, conn)
    return conn
end

local Theme = {
    Background = Color3.fromRGB(17, 17, 19),
    Panel = Color3.fromRGB(25, 25, 28),
    Element = Color3.fromRGB(34, 34, 37),
    Gold = Color3.fromRGB(197, 164, 109),
    Text = Color3.fromRGB(240, 235, 225),
    Muted = Color3.fromRGB(135, 130, 120)
}

--------------------------------------------------------------------
-- KEYBIND STATE
--------------------------------------------------------------------
local DefaultKeys = {
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    Hide = Enum.KeyCode.RightShift
}

local Keys = {}
for name, key in pairs(DefaultKeys) do
    Keys[name] = key
end

local KeyButtons = {}
local listeningFor = nil

--------------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------------
local FULL_WIDTH = 330
local FULL_HEIGHT = 400

local Gui = Create("ScreenGui", {
    Name = "RizKurilHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, GuiParent)

local Main = Create("Frame", {
    Size = UDim2.fromOffset(FULL_WIDTH, FULL_HEIGHT),
    Position = UDim2.new(0.5, -FULL_WIDTH / 2, 0.5, -FULL_HEIGHT / 2),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, Gui)

Create("UICorner", { CornerRadius = UDim.new(0, 12) }, Main)
Create("UIStroke", { Color = Color3.fromRGB(65, 56, 42), Thickness = 1 }, Main)

-- Header
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 65),
    BackgroundTransparency = 1
}, Main)

local Logo = Create("Frame", {
    Size = UDim2.fromOffset(38, 38),
    Position = UDim2.fromOffset(15, 13),
    BackgroundColor3 = Theme.Gold,
    BorderSizePixel = 0
}, Header)
Create("UICorner", { CornerRadius = UDim.new(0, 9) }, Logo)

Create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "RK",
    TextColor3 = Theme.Background,
    Font = Enum.Font.GothamBold,
    TextSize = 15
}, Logo)

Create("TextLabel", {
    Position = UDim2.fromOffset(62, 0),
    Size = UDim2.fromOffset(165, 65),
    BackgroundTransparency = 1,
    Text = "RizKuril Hub",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local function HeaderButton(text, pos)
    local btn = Create("TextButton", {
        Size = UDim2.fromOffset(25, 25),
        Position = pos,
        BackgroundColor3 = Theme.Panel,
        Text = text,
        TextColor3 = Theme.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        AutoButtonColor = false
    }, Header)
    Create("UICorner", { CornerRadius = UDim.new(0, 7) }, btn)
    return btn
end

local Minimize = HeaderButton("—", UDim2.new(1, -62, 0, 15))
local Close = HeaderButton("×", UDim2.new(1, -32, 0, 15))

-- Divider
Create("Frame", {
    Position = UDim2.fromOffset(15, 64),
    Size = UDim2.new(1, -30, 0, 1),
    BackgroundColor3 = Color3.fromRGB(55, 50, 42),
    BorderSizePixel = 0
}, Main)

-- Body
local Body = Create("Frame", {
    Position = UDim2.fromOffset(0, 65),
    Size = UDim2.new(1, 0, 1, -65),
    BackgroundTransparency = 1
}, Main)

-- Tab bar
local TabBar = Create("Frame", {
    Position = UDim2.fromOffset(15, 10),
    Size = UDim2.new(1, -30, 0, 28),
    BackgroundTransparency = 1
}, Body)

Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
}, TabBar)

-- Footer hint (isi diperbarui sesuai keybind)
local HintLabel = Create("TextLabel", {
    Position = UDim2.new(0, 15, 1, -22),
    Size = UDim2.new(1, -30, 0, 16),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 9
}, Body)

local function KeyLabel(key)
    if key == Enum.KeyCode.Unknown then
        return "None"
    end
    return key.Name
end

local function ShortKey(key)
    local n = KeyLabel(key)
    n = n:gsub("^Right", "R")
    n = n:gsub("^Left", "L")
    return n
end

local function UpdateKeyUI()
    for name, btn in pairs(KeyButtons) do
        btn.Text = (listeningFor == name) and "..." or KeyLabel(Keys[name])
    end

    local parts = {}
    if Keys.Fly ~= Enum.KeyCode.Unknown then table.insert(parts, ShortKey(Keys.Fly) .. " Fly") end
    if Keys.Noclip ~= Enum.KeyCode.Unknown then table.insert(parts, ShortKey(Keys.Noclip) .. " Noclip") end
    if Keys.Hide ~= Enum.KeyCode.Unknown then table.insert(parts, ShortKey(Keys.Hide) .. " Hide") end
    HintLabel.Text = table.concat(parts, "  •  ")
end

--------------------------------------------------------------------
-- DRAG HELPER
--------------------------------------------------------------------
local function MakeDraggable(handle, target)
    local state = { moved = false }
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            state.moved = false
            dragStart = input.Position
            startPos = target.Position
        end
    end)

    Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 4 then
                state.moved = true
            end
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))

    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    return state
end

MakeDraggable(Header, Main)

--------------------------------------------------------------------
-- TAB SYSTEM
--------------------------------------------------------------------
local Pages, TabButtons = {}, {}
local tabCount = 0
local uiOrder = 0

local function NextOrder()
    uiOrder += 1
    return uiOrder
end

local function SelectTab(name)
    for n, page in pairs(Pages) do
        page.Visible = (n == name)
    end
    for n, btn in pairs(TabButtons) do
        local active = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = active and Theme.Gold or Theme.Panel,
            TextColor3 = active and Theme.Background or Theme.Muted
        }):Play()
    end
end

local function CreateTab(name)
    tabCount += 1

    local btn = Create("TextButton", {
        Size = UDim2.new(1 / 5, -5, 1, 0),
        BackgroundColor3 = Theme.Panel,
        Text = name,
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 9,
        AutoButtonColor = false,
        LayoutOrder = tabCount
    }, TabBar)
    Create("UICorner", { CornerRadius = UDim.new(0, 7) }, btn)

    local page = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(15, 48),
        Size = UDim2.new(1, -30, 1, -76),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Gold,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Body)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Create("UIPadding", { PaddingRight = UDim.new(0, 6) }, page)

    btn.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)

    Pages[name] = page
    TabButtons[name] = btn
    return page
end

--------------------------------------------------------------------
-- ELEMENT BUILDERS
--------------------------------------------------------------------
local function Section(page, text)
    return Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Gold,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = NextOrder()
    }, page)
end

local function CreateInput(page, label, placeholder)
    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        LayoutOrder = NextOrder()
    }, page)
    Create("UICorner", { CornerRadius = UDim.new(0, 8) }, holder)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0.55, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    local input = Create("TextBox", {
        Position = UDim2.new(1, -95, 0, 7),
        Size = UDim2.fromOffset(83, 29),
        BackgroundColor3 = Theme.Element,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Gold,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        ClearTextOnFocus = false
    }, holder)
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, input)

    return input
end

local function CreateAction(page, label, btnText, callback)
    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        LayoutOrder = NextOrder()
    }, page)
    Create("UICorner", { CornerRadius = UDim.new(0, 8) }, holder)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0.55, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -95, 0, 7),
        Size = UDim2.fromOffset(83, 29),
        BackgroundColor3 = Theme.Element,
        Text = btnText,
        TextColor3 = Theme.Gold,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        AutoButtonColor = false
    }, holder)
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

    btn.MouseButton1Click:Connect(function()
        if callback then callback(btn) end
    end)

    return btn
end

local function CreateKeybind(page, label, actionName)
    local btn = CreateAction(page, label, "", function()
        listeningFor = actionName
        UpdateKeyUI()
    end)
    KeyButtons[actionName] = btn
    return btn
end

local AllToggles = {}

local function CreateToggle(page, label, callback)
    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        LayoutOrder = NextOrder()
    }, page)
    Create("UICorner", { CornerRadius = UDim.new(0, 8) }, holder)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -65, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    local switch = Create("TextButton", {
        Position = UDim2.new(1, -49, 0.5, -10),
        Size = UDim2.fromOffset(37, 20),
        BackgroundColor3 = Theme.Element,
        Text = "",
        AutoButtonColor = false
    }, holder)
    Create("UICorner", { CornerRadius = UDim.new(1, 0) }, switch)

    local dot = Create("Frame", {
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.fromRGB(240, 240, 240),
        BorderSizePixel = 0
    }, switch)
    Create("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

    local enabled = false
    local api = {}

    function api.Set(state)
        enabled = state

        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Theme.Gold or Theme.Element
        }):Play()

        TweenService:Create(dot, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -17, 0, 3) or UDim2.fromOffset(3, 3)
        }):Play()

        if callback then callback(enabled) end
    end

    function api.Get()
        return enabled
    end

    switch.MouseButton1Click:Connect(function()
        api.Set(not enabled)
    end)

    table.insert(AllToggles, api)
    return api
end

--------------------------------------------------------------------
-- BUAT TAB & ELEMEN UI
--------------------------------------------------------------------
local RefreshPlayers -- diisi nanti
local StopSpectate -- diisi nanti

local MoveTab = CreateTab("Movement")
local VisualTab = CreateTab("Visual")
local WorldTab = CreateTab("World")
local PlayersTab = CreateTab("Players")
local SettingsTab = CreateTab("Settings")

-- Movement
Section(MoveTab, "SPEED & JUMP")
local WalkInput = CreateInput(MoveTab, "WalkSpeed", "16")
local JumpInput = CreateInput(MoveTab, "JumpPower", "50")
local FlyInput = CreateInput(MoveTab, "FlySpeed", "50")
local GravityInput = CreateInput(MoveTab, "Gravity", "196")
Section(MoveTab, "MODE")

-- Visual
Section(VisualTab, "CAMERA")
local FovInput = CreateInput(VisualTab, "FOV", "70")
Section(VisualTab, "EFEK KARAKTER")

-- World
Section(WorldTab, "LINGKUNGAN")
local ClockInput = CreateInput(WorldTab, "Jam (0-24)", "14")

-- Players
local PlayersLabel = Section(PlayersTab, "PLAYER LAIN")
local SearchInput = CreateInput(PlayersTab, "Cari player", "nama")
CreateAction(PlayersTab, "Daftar player", "Refresh", function()
    RefreshPlayers()
end)
CreateAction(PlayersTab, "Spectate", "Stop", function()
    StopSpectate()
    RefreshPlayers()
end)

-- Settings
Section(SettingsTab, "KEYBIND (klik lalu tekan tombol)")
CreateKeybind(SettingsTab, "Fly", "Fly")
CreateKeybind(SettingsTab, "Noclip", "Noclip")
CreateKeybind(SettingsTab, "Sembunyikan GUI", "Hide")
CreateAction(SettingsTab, "Keybind", "Reset", function()
    for name, key in pairs(DefaultKeys) do
        Keys[name] = key
    end
    listeningFor = nil
    UpdateKeyUI()
end)
Section(SettingsTab, "TAMPILAN")

UpdateKeyUI()

--------------------------------------------------------------------
-- TOMBOL FLOATING (untuk hide/show GUI, cocok di HP)
--------------------------------------------------------------------
local FloatBtn = Create("TextButton", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.new(0, 15, 0.4, 0),
    BackgroundColor3 = Theme.Gold,
    Text = "RK",
    TextColor3 = Theme.Background,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 10
}, Gui)
Create("UICorner", { CornerRadius = UDim.new(1, 0) }, FloatBtn)
Create("UIStroke", { Color = Color3.fromRGB(65, 56, 42), Thickness = 1 }, FloatBtn)

local FloatDrag = MakeDraggable(FloatBtn, FloatBtn)

FloatBtn.MouseButton1Click:Connect(function()
    if FloatDrag.moved then return end
    Main.Visible = not Main.Visible
end)

--------------------------------------------------------------------
-- HELPER KARAKTER
--------------------------------------------------------------------
local function GetChar()
    local char = Player.Character
    return char,
        char and char:FindFirstChildOfClass("Humanoid"),
        char and char:FindFirstChild("HumanoidRootPart")
end

local function GetCamera()
    return workspace.CurrentCamera
end

local Controls
pcall(function()
    Controls = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
end)

local function GetMoveVector()
    if Controls then
        return Controls:GetMoveVector()
    end
    local x, z = 0, 0
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then x += 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then x -= 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then z += 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then z -= 1 end
    return Vector3.new(x, 0, z)
end

local function Bind(input, onValue)
    Track(input.FocusLost:Connect(function()
        onValue(tonumber(input.Text))
    end))
end

--------------------------------------------------------------------
-- MOVEMENT: WALKSPEED, JUMPPOWER, GRAVITY
--------------------------------------------------------------------
local walkSpeed, jumpPower
local DefaultGravity = workspace.Gravity

local function ApplyHumanoidStats()
    local _, hum = GetChar()
    if not hum then return end
    if walkSpeed then hum.WalkSpeed = walkSpeed end
    if jumpPower then
        hum.UseJumpPower = true
        hum.JumpPower = jumpPower
    end
end

Bind(WalkInput, function(v)
    walkSpeed = v and math.clamp(v, 0, 500) or nil
    local _, hum = GetChar()
    if hum then hum.WalkSpeed = walkSpeed or 16 end
end)

Bind(JumpInput, function(v)
    jumpPower = v and math.clamp(v, 0, 500) or nil
    local _, hum = GetChar()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = jumpPower or 50
    end
end)

Bind(GravityInput, function(v)
    workspace.Gravity = v and math.clamp(v, 0, 1000) or DefaultGravity
end)

--------------------------------------------------------------------
-- FLY
--------------------------------------------------------------------
local spinning = false
local flyConn, flyVel, flyGyro

local function SetFly(on)
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyVel then flyVel:Destroy() flyVel = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end

    local _, hum, hrp = GetChar()
    if not (hum and hrp) then return end

    if on then
        hum.PlatformStand = true

        flyVel = Instance.new("BodyVelocity")
        flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyVel.Velocity = Vector3.zero
        flyVel.Parent = hrp

        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyGyro.P = 9e4
        flyGyro.CFrame = hrp.CFrame
        flyGyro.Parent = hrp

        flyConn = RunService.RenderStepped:Connect(function()
            local speed = tonumber(FlyInput.Text) or 50
            local move = GetMoveVector()
            local cf = GetCamera().CFrame

            flyVel.Velocity = (cf.RightVector * move.X - cf.LookVector * move.Z) * speed

            if spinning then
                flyGyro.MaxTorque = Vector3.zero
            else
                flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                flyGyro.CFrame = cf
            end
        end)
    else
        hum.PlatformStand = false
    end
end

--------------------------------------------------------------------
-- NOCLIP
--------------------------------------------------------------------
local noclipConn

local function SetNoclip(on)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end

    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local char = GetChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    end
end

--------------------------------------------------------------------
-- INFINITE JUMP, SPIN, CLICK TELEPORT
--------------------------------------------------------------------
local infJump = false
local clickTP = false

Track(UserInputService.JumpRequest:Connect(function()
    if infJump then
        local _, hum = GetChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

local spinConn

local function SetSpin(on)
    if spinConn then spinConn:Disconnect() spinConn = nil end
    spinning = on

    local _, hum = GetChar()
    if hum then hum.AutoRotate = not on end

    if on then
        spinConn = RunService.Heartbeat:Connect(function()
            local _, _, hrp = GetChar()
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(25), 0)
            end
        end)
    end
end

Track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not clickTP then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        local char, _, hrp = GetChar()
        if not hrp then return end

        local cam = GetCamera()
        local ray = cam:ScreenPointToRay(input.Position.X, input.Position.Y)

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }

        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if result then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end))

--------------------------------------------------------------------
-- TELEPORT KE PLAYER LAIN
--------------------------------------------------------------------
local function TeleportToPlayer(target)
    local _, _, myHrp = GetChar()
    local tChar = target and target.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not (myHrp and tHrp) then
        return false
    end

    myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 4)
    return true
end

local spectateTarget = nil
local specConn = nil

StopSpectate = function()
    if specConn then
        specConn:Disconnect()
        specConn = nil
    end
    spectateTarget = nil

    local _, hum = GetChar()
    if hum then
        GetCamera().CameraSubject = hum
    end
end

local function StartSpectate(plr)
    StopSpectate()
    spectateTarget = plr

    local function apply()
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            GetCamera().CameraSubject = hum
        end
    end

    apply()

    -- kalau target respawn, kamera ikut ke karakter barunya
    specConn = plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        if spectateTarget == plr then
            apply()
        end
    end)
end

local PlayerRows = {}

RefreshPlayers = function()
    if not Gui.Parent then return end

    for _, row in ipairs(PlayerRows) do
        row:Destroy()
    end
    PlayerRows = {}

    local filter = string.lower(SearchInput.Text or "")
    local list = Players:GetPlayers()
    table.sort(list, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)

    local others, shown = 0, 0

    for _, plr in ipairs(list) do
        if plr ~= Player then
            others += 1

            local match = filter == ""
                or string.find(string.lower(plr.Name), filter, 1, true)
                or string.find(string.lower(plr.DisplayName), filter, 1, true)

            if match then
                shown += 1

                local row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 43),
                    BackgroundColor3 = Theme.Panel,
                    BorderSizePixel = 0,
                    LayoutOrder = NextOrder()
                }, PlayersTab)
                Create("UICorner", { CornerRadius = UDim.new(0, 8) }, row)

                Create("TextLabel", {
                    Position = UDim2.fromOffset(12, 5),
                    Size = UDim2.new(1, -150, 0, 18),
                    BackgroundTransparency = 1,
                    Text = plr.DisplayName,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                }, row)

                Create("TextLabel", {
                    Position = UDim2.fromOffset(12, 23),
                    Size = UDim2.new(1, -150, 0, 14),
                    BackgroundTransparency = 1,
                    Text = "@" .. plr.Name,
                    TextColor3 = Theme.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                }, row)

                local tpBtn = Create("TextButton", {
                    Position = UDim2.new(1, -68, 0, 7),
                    Size = UDim2.fromOffset(56, 29),
                    BackgroundColor3 = Theme.Gold,
                    Text = "TP",
                    TextColor3 = Theme.Background,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    AutoButtonColor = false
                }, row)
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }, tpBtn)

                tpBtn.MouseButton1Click:Connect(function()
                    local ok = TeleportToPlayer(plr)
                    if not ok then
                        tpBtn.Text = "N/A"
                        task.delay(1, function()
                            if tpBtn.Parent then tpBtn.Text = "TP" end
                        end)
                    end
                end)

                local isSpec = (spectateTarget == plr)
                local specBtn = Create("TextButton", {
                    Position = UDim2.new(1, -130, 0, 7),
                    Size = UDim2.fromOffset(56, 29),
                    BackgroundColor3 = isSpec and Theme.Gold or Theme.Element,
                    Text = isSpec and "Stop" or "Spec",
                    TextColor3 = isSpec and Theme.Background or Theme.Gold,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    AutoButtonColor = false
                }, row)
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }, specBtn)

                specBtn.MouseButton1Click:Connect(function()
                    if spectateTarget == plr then
                        StopSpectate()
                    else
                        StartSpectate(plr)
                    end
                    RefreshPlayers()
                end)

                table.insert(PlayerRows, row)
            end
        end
    end

    if shown == 0 then
        local empty = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = others == 0 and "Tidak ada player lain di server" or "Tidak ada hasil",
            TextColor3 = Theme.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            LayoutOrder = NextOrder()
        }, PlayersTab)
        table.insert(PlayerRows, empty)
    end

    PlayersLabel.Text = string.format("PLAYER LAIN (%d)", others)
end

Track(SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    RefreshPlayers()
end))

Track(Players.PlayerAdded:Connect(function()
    task.delay(0.2, RefreshPlayers)
end))

Track(Players.PlayerRemoving:Connect(function(plr)
    if plr == spectateTarget then
        StopSpectate()
    end
    task.delay(0.2, RefreshPlayers)
end))

--------------------------------------------------------------------
-- EFEK VISUAL (api, asap, partikel, trail, neon)
--------------------------------------------------------------------
local activeFx = {}

local function HRPEffect(name, build)
    return function(on)
        if activeFx[name] then
            for _, inst in ipairs(activeFx[name]) do
                inst:Destroy()
            end
            activeFx[name] = nil
        end

        if not on then return end

        local _, _, hrp = GetChar()
        if not hrp then return end

        activeFx[name] = build(hrp)
    end
end

local SetFire = HRPEffect("Fire", function(hrp)
    local fire = Instance.new("Fire")
    fire.Size = 6
    fire.Heat = 8
    fire.Color = Color3.fromRGB(255, 170, 40)
    fire.SecondaryColor = Color3.fromRGB(255, 60, 20)
    fire.Parent = hrp
    return { fire }
end)

local SetSmoke = HRPEffect("Smoke", function(hrp)
    local smoke = Instance.new("Smoke")
    smoke.Size = 4
    smoke.Opacity = 0.35
    smoke.RiseVelocity = 3
    smoke.Color = Color3.fromRGB(150, 150, 150)
    smoke.Parent = hrp
    return { smoke }
end)

local SetSparkle = HRPEffect("Sparkle", function(hrp)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 40
    emitter.Lifetime = NumberRange.new(1, 2)
    emitter.Speed = NumberRange.new(2, 5)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.LightEmission = 1
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Color = ColorSequence.new(Theme.Gold, Color3.fromRGB(255, 240, 200))
    emitter.Parent = hrp
    return { emitter }
end)

local SetTrail = HRPEffect("Trail", function(hrp)
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 1, 0)
    a0.Parent = hrp

    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -1, 0)
    a1.Parent = hrp

    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = 0.7
    trail.LightEmission = 1
    trail.Transparency = NumberSequence.new(0, 1)
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
    trail.Parent = hrp

    return { trail, a0, a1 }
end)

local neonConn
local neonOriginals = {}

local function SetNeon(on)
    if neonConn then neonConn:Disconnect() neonConn = nil end

    if on then
        neonConn = RunService.Heartbeat:Connect(function()
            local char = GetChar()
            if not char then return end

            local color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    if not neonOriginals[p] then
                        neonOriginals[p] = { p.Material, p.Color }
                    end
                    p.Material = Enum.Material.Neon
                    p.Color = color
                end
            end
        end)
    else
        for p, orig in pairs(neonOriginals) do
            if p.Parent then
                p.Material = orig[1]
                p.Color = orig[2]
            end
        end
        neonOriginals = {}
    end
end

Bind(FovInput, function(v)
    GetCamera().FieldOfView = v and math.clamp(v, 1, 120) or 70
end)

--------------------------------------------------------------------
-- WORLD: FULLBRIGHT, JAM, ANTI-AFK
--------------------------------------------------------------------
local savedLight
local DefaultClock = Lighting.ClockTime

local function SetFullbright(on)
    if on then
        if not savedLight then
            savedLight = {
                Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows
            }
        end
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.FogEnd = 1e5
        Lighting.GlobalShadows = false
    elseif savedLight then
        for k, v in pairs(savedLight) do
            Lighting[k] = v
        end
        savedLight = nil
    end
end

Bind(ClockInput, function(v)
    Lighting.ClockTime = v and (v % 24) or DefaultClock
end)

local antiAfk = false

Track(Player.Idled:Connect(function()
    if not antiAfk then return end
    local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
    if ok and vu then
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end))

--------------------------------------------------------------------
-- TOGGLE (diurutkan sesuai tab)
--------------------------------------------------------------------
-- Movement
local FlyToggle = CreateToggle(MoveTab, "Fly Mode", SetFly)
local NoclipToggle = CreateToggle(MoveTab, "Noclip", SetNoclip)
CreateToggle(MoveTab, "Infinite Jump", function(on) infJump = on end)
local SpinToggle = CreateToggle(MoveTab, "Spin", SetSpin)
CreateToggle(MoveTab, "Click Teleport", function(on) clickTP = on end)

-- Visual
local FireToggle = CreateToggle(VisualTab, "Aura Api", SetFire)
local SmokeToggle = CreateToggle(VisualTab, "Aura Asap", SetSmoke)
local SparkleToggle = CreateToggle(VisualTab, "Percikan Partikel", SetSparkle)
local TrailToggle = CreateToggle(VisualTab, "Trail Rainbow", SetTrail)
CreateToggle(VisualTab, "Karakter Neon Rainbow", SetNeon)

-- World
CreateToggle(WorldTab, "Fullbright", SetFullbright)
CreateToggle(WorldTab, "Anti-AFK", function(on) antiAfk = on end)

-- Settings
CreateToggle(SettingsTab, "Tombol Floating (RK)", function(on)
    FloatBtn.Visible = on
end)

--------------------------------------------------------------------
-- RESPAWN
--------------------------------------------------------------------
Track(Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    char:WaitForChild("Humanoid")
    task.wait(0.3)

    if FlyToggle.Get() then FlyToggle.Set(false) end

    if spectateTarget then
        StopSpectate()
        RefreshPlayers()
    end

    ApplyHumanoidStats()
    SetSpin(SpinToggle.Get())
    SetFire(FireToggle.Get())
    SetSmoke(SmokeToggle.Get())
    SetSparkle(SparkleToggle.Get())
    SetTrail(TrailToggle.Get())
end))

--------------------------------------------------------------------
-- KEYBIND HANDLER (bisa diubah di tab Settings)
--------------------------------------------------------------------
local Actions = {
    Fly = function() FlyToggle.Set(not FlyToggle.Get()) end,
    Noclip = function() NoclipToggle.Set(not NoclipToggle.Get()) end,
    Hide = function() Main.Visible = not Main.Visible end
}

Track(UserInputService.InputBegan:Connect(function(input, gp)
    -- mode merekam tombol baru
    if listeningFor then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode ~= Enum.KeyCode.Escape then
                -- kalau tombol sudah dipakai fitur lain, lepaskan dari fitur itu
                for name, key in pairs(Keys) do
                    if name ~= listeningFor and key == input.KeyCode then
                        Keys[name] = Enum.KeyCode.Unknown
                    end
                end
                Keys[listeningFor] = input.KeyCode
            end
            listeningFor = nil
            UpdateKeyUI()
        end
        return
    end

    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    for name, key in pairs(Keys) do
        if key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
            Actions[name]()
        end
    end
end))

--------------------------------------------------------------------
-- MINIMIZE & CLOSE
--------------------------------------------------------------------
local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    TweenService:Create(Main, TweenInfo.new(0.25), {
        Size = minimized and UDim2.fromOffset(FULL_WIDTH, 65) or UDim2.fromOffset(FULL_WIDTH, FULL_HEIGHT)
    }):Play()

    Body.Visible = not minimized
end)

Close.MouseButton1Click:Connect(function()
    StopSpectate()

    for _, t in ipairs(AllToggles) do
        t.Set(false)
    end

    workspace.Gravity = DefaultGravity
    Lighting.ClockTime = DefaultClock
    GetCamera().FieldOfView = 70

    local _, hum = GetChar()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.AutoRotate = true
    end

    for _, c in ipairs(Connections) do
        c:Disconnect()
    end

    Gui:Destroy()
end)

SelectTab("Movement")
RefreshPlayers()
print("RizKuril Hub loaded!")