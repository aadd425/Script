-- =============================================
-- DOOMHUB | ✅ 十字クロスヘア + 効果音 + Desync統合 + Fly追加
-- ✅ クロスヘア：画面中央固定・虹色アニメーション
-- ✅ ヒット音ID: rbxassetid://143666878
-- ✅ 発射音ID: rbxassetid://13510352
-- ✅ Fly機能 追加
-- =============================================

-- ==== LinoriaLib 読み込み ====
local genv = getgenv()
local _5 = loadstring(game:HttpGet('https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua'))()
local _9 = loadstring(game:HttpGet('https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/ThemeManager.lua'))()
local _13 = loadstring(game:HttpGet('https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/SaveManager.lua'))()
local _Options14 = _5.Options
local _Toggles15 = _5.Toggles

_5.ShowToggleFrameInKeybinds = true
_5.ShowCustomCursor = true
_5.NotifySide = 'Left'

-- ==== ウインドウ作成（起動時は非表示）====
local Window = _5:CreateWindow({
    AutoShow = false,
    Title = '            DOOMHUB',
    MenuFadeTime = 0,
    TabPadding = 8,
    Center = true,
})
local TabMain = Window:AddTab('Main')
local TabVisuals = Window:AddTab('Visuals')
local TabSettings = Window:AddTab('Settings')

-- ==== 設定保存・テーマ ====
_9:SetLibrary(_5)
_13:SetLibrary(_5)
_13:IgnoreThemeSettings()
_13:SetIgnoreIndexes({})
_9:SetFolder('DOOMHUB')
_13:SetFolder('DOOMHUB/Config')
_13:BuildConfigSection(TabSettings)
_9:ApplyToTab(TabSettings)

-- =============================================
-- 🖼️ 画像ボタン：押すとメニューが開く
-- =============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Gui = Instance.new("ScreenGui")
Gui.Name = "MenuToggleButton"
Gui.Parent = game.CoreGui
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MenuButton = Instance.new("ImageButton")
MenuButton.Name = "OpenMenuBtn"
MenuButton.Size = UDim2.new(0, 70, 0, 70)
MenuButton.Position = UDim2.new(0.015, 0, 0.5, -35)
MenuButton.BackgroundTransparency = 0
MenuButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MenuButton.BorderSizePixel = 2
MenuButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
MenuButton.Image = "rbxassetid://135072536597653"
MenuButton.ScaleType = Enum.ScaleType.Fit
MenuButton.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MenuButton

MenuButton.MouseButton1Click:Connect(function()
    Window.Visible = not Window.Visible
end)

-- =============================================
-- 🔊 効果音設定
-- =============================================
local PlayHitSound = true
local PlayGunSound = true
local HitSoundId = "rbxassetid://143666878"
local GunSoundId = "rbxassetid://13510352"

local HitSound = Instance.new("Sound")
HitSound.Name = "HitSoundEffect"
HitSound.SoundId = HitSoundId
HitSound.Volume = 0.7
HitSound.Looped = false
HitSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function PlayHitEffect()
    if not PlayHitSound then return end
    HitSound:Stop()
    HitSound.TimePosition = 0
    HitSound:Play()
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local function PlayGunEffect()
    if not PlayGunSound then return end
    local GunSound = Instance.new("Sound")
    GunSound.SoundId = GunSoundId
    GunSound.Parent = HumanoidRootPart
    GunSound.Volume = 1
    GunSound.Pitch = 1
    GunSound:Play()
    game.Debris:AddItem(GunSound, GunSound.TimeLength + 0.1)
end

-- =============================================
-- ✈️ Fly 機能 追加
-- =============================================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local FlyEnabled = false
local FlySpeed = 50
local FlyConnection = nil

local function UpdateFly()
    if not FlyEnabled then return end
    local Char = LocalPlayer.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChild("Humanoid")
    if not HRP or not Hum then return end

    Hum.PlatformStand = true
    Hum.GravityScale = 0
    Hum.SetNetworkOwner(LocalPlayer)

    local MoveDir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDir += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDir -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDir -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDir += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then MoveDir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then MoveDir -= Vector3.new(0, 1, 0) end

    MoveDir = MoveDir.Unit * FlySpeed
    HRP.Velocity = MoveDir
end

local function SetFly(State)
    FlyEnabled = State
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChild("Humanoid")
    if not Hum then return end

    if State then
        Hum.GravityScale = 0
        Hum.PlatformStand = true
        if not FlyConnection then
            FlyConnection = RunService.RenderStepped:Connect(UpdateFly)
        end
    else
        Hum.GravityScale = 1
        Hum.PlatformStand = false
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
    end
end

-- =============================================
-- 🎯 カスタム十字クロスヘア：画面中央固定
-- =============================================

local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "CustomCrosshairGui"
CrosshairGui.ResetOnSpawn = false
CrosshairGui.IgnoreGuiInset = true
CrosshairGui.Parent = LocalPlayer.PlayerGui

local CenterFrame = Instance.new("Frame")
CenterFrame.Name = "CenterFrame"
CenterFrame.Size = UDim2.new(0, 0, 0, 0)
CenterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CenterFrame.BackgroundTransparency = 1
CenterFrame.Parent = CrosshairGui

-- 上
local LineTop = Instance.new("Frame")
LineTop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LineTop.BackgroundTransparency = 0.2
LineTop.BorderSizePixel = 0
LineTop.Size = UDim2.new(0, 4, 0, 40)
LineTop.Position = UDim2.new(0.5, -2, 0.5, -52)
LineTop.Parent = CenterFrame
local LineTopInner = Instance.new("Frame")
LineTopInner.Name = "MainLine"
LineTopInner.Size = UDim2.new(1, -2, 1, -2)
LineTopInner.Position = UDim2.new(0, 1, 0, 1)
LineTopInner.BackgroundTransparency = 0.2
LineTopInner.BorderSizePixel = 0
LineTopInner.Parent = LineTop

-- 右
local LineRight = Instance.new("Frame")
LineRight.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LineRight.BackgroundTransparency = 0.2
LineRight.BorderSizePixel = 0
LineRight.Size = UDim2.new(0, 40, 0, 4)
LineRight.Position = UDim2.new(0.5, 12, 0.5, -2)
LineRight.Parent = CenterFrame
local LineRightInner = Instance.new("Frame")
LineRightInner.Name = "MainLine"
LineRightInner.Size = UDim2.new(1, -2, 1, -2)
LineRightInner.Position = UDim2.new(0, 1, 0, 1)
LineRightInner.BackgroundTransparency = 0.2
LineRightInner.BorderSizePixel = 0
LineRightInner.Parent = LineRight

-- 左
local LineLeft = Instance.new("Frame")
LineLeft.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LineLeft.BackgroundTransparency = 0.2
LineLeft.BorderSizePixel = 0
LineLeft.Size = UDim2.new(0, 40, 0, 4)
LineLeft.Position = UDim2.new(0.5, -52, 0.5, -2)
LineLeft.Parent = CenterFrame
local LineLeftInner = Instance.new("Frame")
LineLeftInner.Name = "MainLine"
LineLeftInner.Size = UDim2.new(1, -2, 1, -2)
LineLeftInner.Position = UDim2.new(0, 1, 0, 1)
LineLeftInner.BackgroundTransparency = 0.2
LineLeftInner.BorderSizePixel = 0
LineLeftInner.Parent = LineLeft

-- 下
local LineBottom = Instance.new("Frame")
LineBottom.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LineBottom.BackgroundTransparency = 0.2
LineBottom.BorderSizePixel = 0
LineBottom.Size = UDim2.new(0, 4, 0, 40)
LineBottom.Position = UDim2.new(0.5, -2, 0.5, 12)
LineBottom.Parent = CenterFrame
local LineBottomInner = Instance.new("Frame")
LineBottomInner.Name = "MainLine"
LineBottomInner.Size = UDim2.new(1, -2, 1, -2)
LineBottomInner.Position = UDim2.new(0, 1, 0, 1)
LineBottomInner.BackgroundTransparency = 0.2
LineBottomInner.BorderSizePixel = 0
LineBottomInner.Parent = LineBottom

-- 常に画面中央に固定 + 虹色アニメーション
RunService.RenderStepped:Connect(function(DeltaTime)
    local CenterPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    CenterFrame.Position = UDim2.fromOffset(CenterPos.X, CenterPos.Y)

    local Hue = (os.clock() * 0.5) % 1
    local Color = Color3.fromHSV(Hue, 1, 1)
    local Length = 28 + math.sin(os.clock() * 4) * 12

    LineTop.Size = UDim2.new(0, 4, 0, Length + 2)
    LineTop.Position = UDim2.new(0.5, -2, 0.5, -Length - 2)
    LineTopInner.BackgroundColor3 = Color

    LineRight.Size = UDim2.new(0, Length + 2, 0, 4)
    LineRight.Position = UDim2.new(0.5, 12, 0.5, -2)
    LineRightInner.BackgroundColor3 = Color

    LineLeft.Size = UDim2.new(0, Length + 2, 0, 4)
    LineLeft.Position = UDim2.new(0.5, -Length - 14, 0.5, -2)
    LineLeftInner.BackgroundColor3 = Color

    LineBottom.Size = UDim2.new(0, 4, 0, Length + 2)
    LineBottom.Position = UDim2.new(0.5, -2, 0.5, 12)
    LineBottomInner.BackgroundColor3 = Color
end)

-- =============================================
-- ⚡ メインAimbot処理
-- =============================================

-- Script Settings
local AimbotEnabled = false
local SilentAimEnabled = false
local TeamCheck = true
local FovRadius = 100
local MaxDistance = 500
local AimSmoothness = 0.08

-- ★ 設定エリア
local ESP_Enabled = true
local ESP_ShowName = true
local SilentAimPart = "Head"
local ShowTargetLine = true
local AimLineColor = Color3.fromRGB(50, 255, 50)
local TP_Active = false
local BodyFollow_Active = false

-- FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = true
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(255, 0, 0)
FovCircle.Filled = false
FovCircle.Radius = FovRadius
FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- ESP描画
local ESP_Drawings = {}
local SelectedTarget = nil

local AimLine = Drawing.new("Line")
AimLine.Thickness = 2
AimLine.Color = AimLineColor
AimLine.Transparency = 1
AimLine.Visible = true

local function ClampLineToScreen(sPos, ePos)
    local minX, minY = 0, 0
    local maxX, maxY = Camera.ViewportSize.X, Camera.ViewportSize.Y
    local function ClampPoint(a, b)
        if a.X >= minX and a.X <= maxX and a.Y >= minY and a.Y <= maxY then return a end
        local dir = (b - a).Unit
        local t = math.huge
        if dir.X ~= 0 then t = math.min(t, (minX - a.X)/dir.X, (maxX - a.X)/dir.X) end
        if dir.Y ~= 0 then t = math.min(t, (minY - a.Y)/dir.Y, (maxY - a.Y)/dir.Y) end
        return a + dir * math.max(t, 0.001)
    end
    return ClampPoint(sPos, ePos), ClampPoint(ePos, sPos)
end

local function CreateESP(target)
    local Box = Drawing.new("Square")
    Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1
    local Name = Drawing.new("Text")
    Name.Center = true; Name.Outline = true; Name.Font = 2; Name.Size = 14
    ESP_Drawings[target] = {Box = Box, Name = Name}
end

local function RemoveESP(target)
    if ESP_Drawings[target] then ESP_Drawings[target].Box:Remove(); ESP_Drawings[target].Name:Remove(); ESP_Drawings[target] = nil end
end

Players.PlayerAdded:Connect(function(v) v.CharacterAdded:Connect(function() task.wait(0.2) CreateESP(v) end); v.CharacterRemoving:Connect(RemoveESP) end)
for _, v in next, Players:GetPlayers() do if v ~= LocalPlayer then task.spawn(CreateESP, v) end end
Players.PlayerRemoving:Connect(RemoveESP)

-- 最も近い敵を探す
local function GetClosestPlayer()
    local BestTarget = nil
    local BestDistance = math.huge
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local MeRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not MeRoot then SelectedTarget = nil return end

    for _, Plr in pairs(Players:GetPlayers()) do
        if Plr == LocalPlayer then continue end
        if not Plr.Character then continue end
        local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
        local Human = Plr.Character:FindFirstChild("Humanoid")
        if not Root or not Human or Human.Health <= 0 then continue end
        if TeamCheck and Plr.Team == LocalPlayer.Team then continue end
        local AimPart = Plr.Character:FindFirstChild(SilentAimPart)
        if not AimPart then continue end

        local ScrPos, OnScreen = Camera:WorldToViewportPoint(AimPart.Position)
        if not OnScreen then continue end
        local Offset = (Vector2.new(ScrPos.X, ScrPos.Y) - ScreenCenter).Magnitude
        if Offset > FovRadius then continue end

        local RealDist = (MeRoot.Position - AimPart.Position).Magnitude
        if RealDist <= MaxDistance and Offset < BestDistance then
            BestDistance = Offset
            BestTarget = Plr
        end
    end
    SelectedTarget = BestTarget
end

-- メインループ
RunService.RenderStepped:Connect(function()
    -- 照準線
    if ShowTargetLine and SelectedTarget and SelectedTarget.Character then
        local MeRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local AimPart = SelectedTarget.Character:FindFirstChild(SilentAimPart)
        if MeRoot and AimPart then
            local Start2D = Vector2.new(Camera:WorldToViewportPoint(MeRoot.Position).X, Camera:WorldToViewportPoint(MeRoot.Position).Y)
            local End2D = Vector2.new(Camera:WorldToViewportPoint(AimPart.Position).X, Camera:WorldToViewportPoint(AimPart.Position).Y)
            AimLine.From, AimLine.To = ClampLineToScreen(Start2D, End2D)
            AimLine.Visible = true
        else
            AimLine.Visible = false
        end
    else
        AimLine.Visible = false
    end

    -- ESP描画
    for Plr, Draw in pairs(ESP_Drawings) do
        Draw.Box.Visible = false; Draw.Name.Visible = false
        if not ESP_Enabled then continue end
        local Char = Plr.Character
        if not Char or not Char:FindFirstChild("HumanoidRootPart") or Char.Humanoid.Health <= 0 then continue end
        local RootScr = Camera:WorldToViewportPoint(Char.HumanoidRootPart.Position)
        local HeadScr = Camera:WorldToViewportPoint(Char.Head.Position)
        local BoxH = math.abs(RootScr.Y - HeadScr.Y) * 2.05
        local BoxW = BoxH / 2.1
        Draw.Box.Position = Vector2.new(HeadScr.X - BoxW/2, HeadScr.Y - BoxH/2)
        Draw.Box.Size = Vector2.new(BoxW, BoxH)
        Draw.Box.Color = TeamCheck and (Plr.Team ~= LocalPlayer.Team and Color3.fromRGB(255,40,40) or Color3.fromRGB(40,255,40)) or Color3.fromRGB(255,255,255)
        Draw.Box.Visible = true
        if ESP_ShowName then
            Draw.Name.Position = Vector2.new(HeadScr.X, Draw.Box.Position.Y - 16)
            Draw.Name.Color = Draw.Box.Color
            Draw.Name.Text = Plr.Name.." | "..math.floor((LocalPlayer.Character.HumanoidRootPart.Position - Char.Head.Position).Magnitude).."m"
            Draw.Name.Visible = true
        end
    end
end)

-- 入力：発射音 + ヒット音 + SilentAim
UserInputService.InputBegan:Connect(function(Input, Proc)
    if Proc then return end
    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
    PlayGunEffect()
    if not SilentAimEnabled or not SelectedTarget then return end
    local AimPart = SelectedTarget.Character and SelectedTarget.Character:FindFirstChild(SilentAimPart)
    if not AimPart then return end
    PlayHitEffect()
    local OriginalCam = Camera.CFrame
    Camera.CFrame = CFrame.new(OriginalCam.Position, AimPart.Position)
    task.wait(0.0001)
    Camera.CFrame = OriginalCam
end)

-- Aimbot追従
RunService:BindToRenderStep("DeltaAimbotLock", Enum.RenderPriority.Camera.Value+3, function()
    GetClosestPlayer()
    local MeChar = LocalPlayer.Character
    local MeRoot = MeChar and MeChar:FindFirstChild("HumanoidRootPart")
    if not MeRoot then return end
    local TargetChar = SelectedTarget and SelectedTarget.Character
    if not TargetChar then return end
    if AimbotEnabled then
        local AimPart = TargetChar:FindFirstChild(SilentAimPart)
        if AimPart then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, AimPart.Position), 1 - AimSmoothness)
        end
    end
end)
-- =============================================
-- 🎨 LinoriaLib UI
-- =============================================

local MainBox = TabMain:AddLeftGroupbox('Aimbot Settings')

MainBox:AddToggle('AimbotToggle', {
    Text = 'Aimbot',
    Default = false,
    Callback = function(State) AimbotEnabled = State end
})

MainBox:AddToggle('SilentAimToggle', {
    Text = 'Silent Aim',
    Default = false,
    Callback = function(State) SilentAimEnabled = State end
})

MainBox:AddToggle('TeamCheckToggle', {
    Text = 'Team Check',
    Default = true,
    Callback = function(State) TeamCheck = State end
})

MainBox:AddSlider('FOVSlider', {
    Text = 'FOV Radius',
    Min = 10, Max = 500, Default = 100, Rounding = 0,
    Callback = function(Value) FovRadius = Value; FovCircle.Radius = Value end
})

MainBox:AddSlider('MaxDistanceSlider', {
    Text = 'Max Distance',
    Min = 50, Max = 2000, Default = 500, Rounding = 0,
    Callback = function(Value) MaxDistance = Value end
})

MainBox:AddSlider('SmoothnessSlider', {
    Text = 'Aim Smoothness',
    Min = 0, Max = 1, Default = 0.08, Rounding = 2,
    Callback = function(Value) AimSmoothness = Value end
})

local ExtraBox = TabMain:AddRightGroupbox('Extra Functions')

ExtraBox:AddToggle('FlyToggle', {
    Text = '✈️ Fly / 飛行',
    Default = false,
    Callback = function(State) SetFly(State) end
})

ExtraBox:AddSlider('FlySpeedSlider', {
    Text = 'Fly Speed',
    Min = 10, Max = 200, Default = 50, Rounding = 0,
    Callback = function(Value) FlySpeed = Value end
})

ExtraBox:AddToggle('TPToggle', {
    Text = 'TP & Rotate Around Target (DISABLED)', Default = false,
    Callback = function() end
})

ExtraBox:AddToggle('BodyFollowToggle', {
    Text = 'Body Follow Target (DISABLED)', Default = false,
    Callback = function() end
})

ExtraBox:AddInput('AimPartInput', {
    Text = 'Aim Part (Head/Torso/Legs...)', Default = 'Head', Finished = true,
    Callback = function(Text) SilentAimPart = Text end
})

local VisualBox = TabVisuals:AddLeftGroupbox('ESP & Visuals')

VisualBox:AddToggle('ESPToggle', {
    Text = 'Box ESP', Default = true,
    Callback = function(State) ESP_Enabled = State end
})

VisualBox:AddToggle('ESPNameToggle', {
    Text = 'Show Player Name & Distance', Default = true,
    Callback = function(State) ESP_ShowName = State end
})

VisualBox:AddToggle('TargetLineToggle', {
    Text = 'Green Aim Line', Default = true,
    Callback = function(State) ShowTargetLine = State; AimLine.Visible = State end
})

VisualBox:AddToggle('HitSoundToggle', {
    Text = 'Hit Sound Effect', Default = true,
    Callback = function(State) PlayHitSound = State end
})

VisualBox:AddToggle('GunSoundToggle', {
    Text = 'Gun Fire Sound', Default = true,
    Callback = function(State) PlayGunSound = State end
})

local SettingsBox = TabSettings:AddLeftGroupbox('Menu Settings')
SettingsBox:AddToggle('ShowKeybindMenu', {
    Text = 'Show Keybind Menu', Default = false,
    Callback = function(State) _5.KeybindFrame.Visible = State end
})

-- =============================================
-- 🔒 Desync / ガンモード 統合コード
-- =============================================
local __a1b2c3 = setmetatable({}, {
    __index = function(__d4e5f6, __g7h8i9)
        local __j0k1l2, __m3n4o5 = pcall(function() return game:GetService(__g7h8i9) end)
        if __m3n4o5 then return cloneref(__m3n4o5) end
        return nil
    end
})

local __p6q7r8 = getgenv()
if __p6q7r8.__s9t0u1 then __p6q7r8.__s9t0u1:Shutdown() end

local __v2w3x4 = __a1b2c3.Players
local __y5z6a7 = __a1b2c3.RunService
local __b8c9d0 = __a1b2c3.ReplicatedStorage
local __k7l8m9 = __v2w3x4.LocalPlayer
local __q3r4s5 = __k7l8m9.PlayerScripts
local __t6u7v8 = require(__q3r4s5.Modules.ItemTypes.Gun)
local __w9x0y1 = require(__b8c9d0.Modules.Utility)

__p6q7r8.__s9t0u1 = {}

do
    local __i1j2k3 = __p6q7r8.__s9t0u1

    function __i1j2k3:__init()
        self.__active = true
        self.__target = nil
        self.__desync = false
        self.__conn1 = nil
        self.__conn2 = nil
        self.__task1 = nil
        self.__oldfunc = nil
        self:__setup()
    end

    function __i1j2k3:__setup()
        self.__conn1 = __y5z6a7.Heartbeat:Connect(function()
            if not self.__active then return end
            self.__target = self:__find()
        end)

        local __l4m5n6 = __t6u7v8.StartShooting
        self.__oldfunc = __l4m5n6
        __t6u7v8.StartShooting = function(__o7p8q9, ...)
            local __r0s1t2 = {__l4m5n6(__o7p8q9, ...)}
            if not __o7p8q9.ClientFighter or not __o7p8q9.ClientFighter.IsLocalPlayer then
                return unpack(__r0s1t2)
            end
            local __u3v4w5 = __r0s1t2[3]
            if not __u3v4w5 or typeof(__u3v4w5) ~= "table" then
                return unpack(__r0s1t2)
            end
            __r0s1t2[4] = true
            local __x6y7z8 = self.__target
            if not self.__active or not __x6y7z8 or not __x6y7z8.Character then
                return unpack(__r0s1t2)
            end
            if not self.__desync or self.__curr ~= __x6y7z8 then
                self:__desync_start(__x6y7z8)
                task.wait(0.1)
            end
            if self.__task1 then
                task.cancel(self.__task1)
                self.__task1 = nil
            end
            local __a9b0c1 = __x6y7z8.Character:FindFirstChild("Head")
            if not __a9b0c1 then return unpack(__r0s1t2) end
            local __d2e3f4 = __a9b0c1.Position
            local __g5h6i7 = __a9b0c1.CFrame
            local __j8k9l0 = __d2e3f4 - Vector3.new(0, 5, 0)
            local __m1n2o3 = CFrame.lookAt(__j8k9l0, __d2e3f4)
            local __p4q5r6 = __g5h6i7:ToObjectSpace(CFrame.new(__d2e3f4 + Vector3.new(math.random(), math.random(), math.random())))
            __u3v4w5[utf8.char(0)] = __w9x0y1:EncodeCFrame(CFrame.new(__j8k9l0, __d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
            __u3v4w5[utf8.char(1)] = __w9x0y1:EncodeCFrame(CFrame.new(__d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
            __u3v4w5[utf8.char(2)] = __a9b0c1
            __u3v4w5[utf8.char(3)] = __w9x0y1:EncodeCFrame(__p4q5r6)
            self.__task1 = task.delay(0.15, function() self:__desync_stop() end)
            return unpack(__r0s1t2)
        end
    end

    function __i1j2k3:__find()
        local myChar = __k7l8m9.Character
        if not myChar then return nil end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local closest = nil
        local closestDist = math.huge
        local MAX_DISTANCE = 200
        for _, player in next, __v2w3x4:GetPlayers() do
            if player == __k7l8m9 then continue end
            if player:GetAttribute("TeamID") == __k7l8m9:GetAttribute("TeamID") then continue end
            local char = player.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if not (root and head and hum and hum.Health > 0) then continue end
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist > MAX_DISTANCE then continue end
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
        return closest
    end

    function __i1j2k3:__desync_start(__c3d4e5)
        if self.__conn2 then self.__conn2:Disconnect() end
        self.__desync = true
        self.__curr = __c3d4e5
        self.__conn2 = __y5z6a7.Heartbeat:Connect(function()
            if not self.__desync then return end
            local myChar = __k7l8m9.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local targetRoot = __c3d4e5.Character and __c3d4e5.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then self:__desync_stop() return end
            local savedCFrame = myRoot.CFrame
            local savedVel = myRoot.Velocity
            local savedRotVel = myRoot.RotVelocity
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, -5, 0)
            __y5z6a7:BindToRenderStep("__restore", 101, function()
                myRoot.CFrame = savedCFrame
                myRoot.Velocity = savedVel
                myRoot.RotVelocity = savedRotVel
                __y5z6a7:UnbindFromRenderStep("__restore")
            end)
        end)
    end

    function __i1j2k3:__desync_stop()
        self.__desync = false
        self.__curr = nil
        if self.__conn2 then self.__conn2:Disconnect() self.__conn2 = nil end
    end

    function __i1j2k3:Shutdown()
        self.__active = false
        if self.__conn1 then self.__conn1:Disconnect() end
        if self.__conn2 then self.__conn2:Disconnect() end
        if self.__task1 then task.cancel(self.__task1) end
        if self.__oldfunc then __t6u7v8.StartShooting = self.__oldfunc end
    end

    __i1j2k3:__init()
end
