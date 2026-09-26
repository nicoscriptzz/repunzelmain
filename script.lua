game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Notification",
    Text = "Script has been executed.",
    Duration = 5
})

local handler = require(game:GetService("ReplicatedStorage").Modules.GunHandler)
local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = me:GetMouse()
local aimPart = "Head"
local oldFunc = handler.getAim

local function playStartupJump()
    local char = me.Character or me.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = char:WaitForChild("Humanoid", 5)
    end
    if humanoid then
        humanoid.Jump = true
    end
end

task.spawn(playStartupJump)

_G.FOV_RADIUS = 1000
_G.ShowFOV = false
_G.RevolverBypass = false
_G.WallCheck = false

_G.ESP_Boxes = false
_G.ESP_Names = false
_G.ESP_Color = Color3.fromRGB(255, 153, 170)

_G.Speed_Enabled = false
_G.Speed_Value = 50
_G.Speed_Key = Enum.KeyCode.X
_G.Speed_ToggleEnabled = true

_G.Camlock_Enabled = false
_G.Camlock_Smoothness = 0.2
_G.Camlock_Key = Enum.KeyCode.C
_G.Camlock_ToggleEnabled = false

_G.Headless_Enabled = false

_G.UI_Toggle_Key = Enum.KeyCode.RightShift

_G.Fog_Color = Color3.fromRGB(255, 255, 255)
_G.Fog_Density = 0.5
_G.Fog_Start = 100
_G.Fog_End = 1000

local whitelist = {}
local damageConnection

local function getDamageAttacker(humanoid)
    local tags = {"creator", "creatorTag", "creatorPlayer", "creator_value", "creator_tag"}
    for _, tagName in ipairs(tags) do
        local tag = humanoid:FindFirstChild(tagName)
        if tag and tag.Value and tag.Value:IsA("Player") then
            return tag.Value
        end
    end
    for _, obj in ipairs(humanoid:GetChildren()) do
        if obj:IsA("ObjectValue") and obj.Name:lower():find("creator") and obj.Value and obj.Value:IsA("Player") then
            return obj.Value
        end
    end
end

local function monitorDamage(humanoid)
    if damageConnection then
        damageConnection:Disconnect()
        damageConnection = nil
    end
    if not humanoid then
        return
    end

    local previousHealth = humanoid.Health
    damageConnection = humanoid.HealthChanged:Connect(function(currentHealth)
        if currentHealth < previousHealth then
            local attacker = getDamageAttacker(humanoid)
            if attacker and whitelist[attacker] then
                humanoid.Health = previousHealth
            end
        end
        previousHealth = humanoid.Health
    end)
end

local _0xn1 = 100 local _0xn8 = 1 local _0xn9 = 0 local _0xn11 = 2 local _0xn14 = 0.05 local _0xn15 = -0.1 local _0xn16 = -0.05
local _0x52a0d5 = { BulletSpread = { Enabled = true, Amount = 100 } }
local _0x9ba38e

_0x9ba38e = hookfunction(math.random, function(...)
    local _0x5e1a0d = { ... }
    if checkcaller() then return _0x9ba38e(...) end
    if (#_0x5e1a0d == _0xn9) or (_0x5e1a0d[_0xn8] == _0xn16 and _0x5e1a0d[_0xn11] == _0xn14) or (_0x5e1a0d[_0xn8] == _0xn15) or (_0x5e1a0d[_0xn8] == _0xn16) then
        if _0x52a0d5.BulletSpread.Enabled then
            return _0x9ba38e(...) * (_0x52a0d5.BulletSpread.Amount / _0xn1)
        end
    end
    return _0x9ba38e(...)
end)

local function getClosestPart(char)
    local closest = nil
    local shortestDist = math.huge
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local parts = {"Head", "HumanoidRootPart", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand"}
    for _, partName in pairs(parts) do
        local p = char:FindFirstChild(partName)
        if p then
            local screenPos, onScreen = cam:WorldToScreenPoint(p.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDist then shortestDist = dist closest = p end
            end
        end
    end
    return closest or char:FindFirstChild("Head")
end

local function getClosest()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local best = nil
    local bestDist = _G.FOV_RADIUS
    for i, v in pairs(plrs:GetPlayers()) do
        if v ~= me and not whitelist[v] and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local part
            if aimPart == "Closest Part" then part = getClosestPart(v.Character)
            elseif aimPart == "Body" then part = v.Character:FindFirstChild("HumanoidRootPart")
            elseif aimPart == "Left Leg" then part = v.Character:FindFirstChild("LeftUpperLeg") or v.Character:FindFirstChild("LeftLeg")
            elseif aimPart == "Right Leg" then part = v.Character:FindFirstChild("RightUpperLeg") or v.Character:FindFirstChild("RightLeg")
            elseif aimPart == "Left Arm" then part = v.Character:FindFirstChild("LeftUpperArm") or v.Character:FindFirstChild("LeftArm")
            elseif aimPart == "Right Arm" then part = v.Character:FindFirstChild("RightUpperArm") or v.Character:FindFirstChild("RightArm")
            else part = v.Character:FindFirstChild("Head") end
            if part then
                local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenVec - mousePos).Magnitude
                    if dist < bestDist then
                        if _G.WallCheck then
                            local ray = Ray.new(cam.CFrame.Position, (part.Position - cam.CFrame.Position).Unit * 500)
                            local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {me.Character, cam})
                            if hit and hit:IsDescendantOf(v.Character) then bestDist = dist best = part end
                        else bestDist = dist best = part end
                    end
                end
            end
        end
    end
    return best
end

handler.getAim = function(origin, maxDist)
    if _G.RevolverBypass then
        local currentTool = me.Character and me.Character:FindFirstChildOfClass("Tool")
        if currentTool and (currentTool.Name == "[Revolver]" or currentTool.Name == "Revolver") then return oldFunc(origin, maxDist) end
    end
    local target = getClosest()
    if target then
        local dir = (target.Position - origin).Unit
        local dist = (target.Position - origin).Magnitude
        return dir, math.min(dist, maxDist or 200)
    end
    return oldFunc(origin, maxDist)
end

local function setHeadlessState(enabled)
    local char = me.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local function applyTransparency(part)
        if part and part:IsA("BasePart") then
            part.Transparency = enabled and 1 or 0
            part.LocalTransparencyModifier = enabled and 1 or 0
            part.CanCollide = not enabled
        end
    end

    applyTransparency(head)
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("BasePart") then
            applyTransparency(child)
        elseif child:IsA("Decal") or child:IsA("Texture") then
            child.Transparency = enabled and 1 or 0
        end
    end
end

local function applyHeadlessEffect()
    if _G.Headless_Enabled then
        setHeadlessState(true)
    else
        setHeadlessState(false)
    end
end

me.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    applyHeadlessEffect()
end)

local UIS = game:GetService('UserInputService')
local CoreGui = game:GetService('CoreGui')

local uiLight = Color3.fromRGB(24, 24, 24)
local uiAccent = Color3.fromRGB(20, 20, 20)
local uiText = Color3.fromRGB(245, 245, 245)

local gui = Instance.new('ScreenGui')
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Name = 'SilentAimUI'
gui.DisplayOrder = 10
gui.Parent = CoreGui

local frame = Instance.new('Frame')
frame.Size = UDim2.new(0, 780, 0, 560)
frame.Position = UDim2.new(0.5, -390, 0.5, -280)
frame.BackgroundColor3 = uiLight
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 16)

-- FOV display (visual only)
local fovGui = Instance.new('ScreenGui')
fovGui.Name = 'FOVDisplay'
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 5
fovGui.ResetOnSpawn = false
fovGui.Parent = CoreGui

local fovCircle = Instance.new('Frame')
fovCircle.Name = 'FOVCircle'
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.ZIndex = 1
fovCircle.Parent = fovGui

local fovCorner = Instance.new('UICorner')
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new('UIStroke')
fovStroke.Color = Color3.fromRGB(170, 90, 255)
fovStroke.Thickness = 2
fovStroke.Transparency = 0.15
fovStroke.Parent = fovCircle

local RunService = game:GetService('RunService')

local function updateFOVCircle()
    local radius = math.max(_G.FOV_RADIUS, 1)
    fovCircle.Size = UDim2.fromOffset(radius * 2, radius * 2)
    fovCircle.Position = UDim2.fromOffset(mouse.X - radius, mouse.Y - radius)
    fovCircle.Visible = _G.ShowFOV
end

RunService.RenderStepped:Connect(updateFOVCircle)

local auroraStroke = Instance.new('UIStroke', frame)
auroraStroke.Color = Color3.fromRGB(170, 90, 255)
auroraStroke.Thickness = 3
auroraStroke.Transparency = 0.3

local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = frame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local sidebar = Instance.new('Frame')
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.BackgroundColor3 = uiAccent
sidebar.BorderSizePixel = 0
sidebar.Parent = frame
local sideCorner = Instance.new('UICorner', sidebar)
sideCorner.CornerRadius = UDim.new(0, 16)

local sideCover = Instance.new('Frame')
sideCover.Size = UDim2.new(0, 20, 1, 0)
sideCover.Position = UDim2.new(1, -20, 0, 0)
sideCover.BackgroundColor3 = uiAccent
sideCover.BorderSizePixel = 0
sideCover.Parent = sidebar

local sideTitle = Instance.new('TextLabel')
sideTitle.Size = UDim2.new(1, -20, 0, 40)
sideTitle.Position = UDim2.new(0, 15, 0, 20)
sideTitle.Text = 'Repunzels main'
sideTitle.TextColor3 = uiText
sideTitle.TextSize = 22
sideTitle.Font = Enum.Font.GothamBold
sideTitle.BackgroundTransparency = 1
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar
local sidebar = Instance.new('Frame')
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.BackgroundColor3 = uiAccent
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

local sideCorner = Instance.new('UICorner', sidebar)
sideCorner.CornerRadius = UDim.new(0, 16)

local sideCover = Instance.new('Frame')
sideCover.Size = UDim2.new(0, 20, 1, 0)
sideCover.Position = UDim2.new(1, -20, 0, 0)
sideCover.BackgroundColor3 = uiAccent
sideCover.BorderSizePixel = 0
sideCover.Parent = sidebar

local sideTitle = Instance.new('TextLabel')
sideTitle.Size = UDim2.new(1, -20, 0, 40)
sideTitle.Position = UDim2.new(0, 15, 0, 20)
sideTitle.Text = 'Repunzels main'
sideTitle.TextColor3 = uiText
sideTitle.TextSize = 22
sideTitle.Font = Enum.Font.GothamBold
sideTitle.BackgroundTransparency = 1
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

-- Greeting
local welcomeLabel = Instance.new('TextLabel')
welcomeLabel.Size = UDim2.new(0, 450, 0, 50)
welcomeLabel.Position = UDim2.new(0, 235, 0, 25)
welcomeLabel.Text = 'Greetings, ' .. me.Name
welcomeLabel.TextColor3 = uiText
welcomeLabel.TextSize = 28
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = frame

-- Larger avatar preview
local avatarImage = Instance.new('ImageLabel')
avatarImage.Name = 'AvatarPreview'
avatarImage.Size = UDim2.fromOffset(50, 50)
avatarImage.Position = UDim2.new(1, -70, 0, 15)
avatarImage.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
avatarImage.BorderSizePixel = 0
avatarImage.ScaleType = Enum.ScaleType.Crop
avatarImage.Parent = frame

local avatarCorner = Instance.new('UICorner')
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarImage

local avatarStroke = Instance.new('UIStroke')
avatarStroke.Color = Color3.fromRGB(170, 90, 255)
avatarStroke.Thickness = 3
avatarStroke.Transparency = 0.2
avatarStroke.Parent = avatarImage

task.spawn(function()
    local success, imageUrl = pcall(function()
        return plrs:GetUserThumbnailAsync(
            me.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size180x180
        )
    end)

    if success and imageUrl then
        avatarImage.Image = imageUrl
    end
end)


local tabContainer = Instance.new('Frame')
tabContainer.Size = UDim2.new(0, 500, 0, 400)
tabContainer.Position = UDim2.new(0, 235, 0, 85)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local tabs = {
    SilentAim = Instance.new('Frame'),
    ESP = Instance.new('Frame'),
    Speed = Instance.new('Frame'),
    Camlock = Instance.new('Frame'),
    Headless = Instance.new('Frame'),
    Teleport = Instance.new('Frame'),
    Whitelist = Instance.new('Frame'),
    Settings = Instance.new('Frame')
}

for name, page in pairs(tabs) do
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    page.BorderSizePixel = 0
    page.Visible = (name == "SilentAim")
    page.Parent = tabContainer
    Instance.new('UICorner', page).CornerRadius = UDim.new(0, 12)
end

local tabButtons = {}
local tabNames = {"Silent Aim", "ESP", "Speed", "Camlock", "Headless", "Teleport", "Whitelist", "Settings"}
local tabKeys = {"SilentAim", "ESP", "Speed", "Camlock", "Headless", "Teleport", "Whitelist", "Settings"}

local function switchTab(targetKey)
    for key, page in pairs(tabs) do
        page.Visible = (key == targetKey)
    end
    for key, btn in pairs(tabButtons) do
        if key == targetKey then
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
            btn.TextColor3 = Color3.fromRGB(235, 235, 235)
        end
    end
end

for idx, labelText in ipairs(tabNames) do
    local key = tabKeys[idx]
    local btn = Instance.new('TextButton')
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 75 + (idx - 1) * 42)
    btn.Text = '   ' .. labelText
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    btn.TextColor3 = Color3.fromRGB(235, 235, 235)
    btn.Parent = sidebar
    Instance.new('UICorner', btn).CornerRadius = UDim.new(0, 8)
    tabButtons[key] = btn
    
    btn.MouseButton1Click:Connect(function()
        switchTab(key)
    end)
end
switchTab("SilentAim")

local function createPageHeader(pageFrame, titleText)
    local title = Instance.new('TextLabel')
    title.Size = UDim2.new(1, -30, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Text = titleText
    title.TextColor3 = uiText
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = pageFrame

    local line = Instance.new('Frame')
    line.Size = UDim2.new(1, -30, 0, 1)
    line.Position = UDim2.new(0, 15, 0, 40)
    line.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    line.BorderSizePixel = 0
    line.Parent = pageFrame
end

createPageHeader(tabs.SilentAim, "Silent Aim Settings")
createPageHeader(tabs.ESP, "ESP Settings")
createPageHeader(tabs.Speed, "Speed Hack Settings")
createPageHeader(tabs.Camlock, "Camlock Settings")
createPageHeader(tabs.Headless, "Headless Settings")
createPageHeader(tabs.Teleport, "Teleport System")
createPageHeader(tabs.Whitelist, "Whitelist Settings")
createPageHeader(tabs.Settings, "Settings")

local headlessToggleLabel = Instance.new('TextLabel')
headlessToggleLabel.Size = UDim2.new(0, 150, 0, 30)
headlessToggleLabel.Position = UDim2.new(0, 15, 0, 55)
headlessToggleLabel.Text = 'Headless Enabled'
headlessToggleLabel.TextColor3 = uiText
headlessToggleLabel.TextSize = 13
headlessToggleLabel.Font = Enum.Font.Gotham
headlessToggleLabel.BackgroundTransparency = 1
headlessToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
headlessToggleLabel.Parent = tabs.Headless

local headlessToggleBtn = Instance.new('TextButton')
headlessToggleBtn.Size = UDim2.new(0, 50, 0, 22)
headlessToggleBtn.Position = UDim2.new(1, -65, 0, 59)
headlessToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
headlessToggleBtn.Text = 'OFF'
headlessToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
headlessToggleBtn.Font = Enum.Font.GothamBold
headlessToggleBtn.TextSize = 11
headlessToggleBtn.Parent = tabs.Headless
Instance.new('UICorner', headlessToggleBtn).CornerRadius = UDim.new(0, 6)

headlessToggleBtn.MouseButton1Click:Connect(function()
    _G.Headless_Enabled = not _G.Headless_Enabled
    headlessToggleBtn.Text = _G.Headless_Enabled and 'ON' or 'OFF'
    headlessToggleBtn.BackgroundColor3 = _G.Headless_Enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(55, 55, 55)
    applyHeadlessEffect()
end)

local toggleLabel = Instance.new('TextLabel')
toggleLabel.Size = UDim2.new(0, 150, 0, 30)
toggleLabel.Position = UDim2.new(0, 15, 0, 55)
toggleLabel.Text = 'Revolver Bypass'
toggleLabel.TextColor3 = uiText
toggleLabel.TextSize = 13
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.BackgroundTransparency = 1
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = tabs.SilentAim

local toggleBtn = Instance.new('TextButton')
toggleBtn.Size = UDim2.new(0, 50, 0, 22)
toggleBtn.Position = UDim2.new(1, -65, 0, 59)
toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
toggleBtn.Text = 'OFF'
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 11
toggleBtn.Parent = tabs.SilentAim
Instance.new('UICorner', toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    _G.RevolverBypass = not _G.RevolverBypass
    if _G.RevolverBypass then
        toggleBtn.Text = 'ON'
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        toggleBtn.Text = 'OFF'
        toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

local wallLabel = Instance.new('TextLabel')
wallLabel.Size = UDim2.new(0, 150, 0, 30)
wallLabel.Position = UDim2.new(0, 15, 0, 95)
wallLabel.Text = 'Wall Check'
wallLabel.TextColor3 = uiText
wallLabel.TextSize = 13
wallLabel.Font = Enum.Font.Gotham
wallLabel.BackgroundTransparency = 1
wallLabel.TextXAlignment = Enum.TextXAlignment.Left
wallLabel.Parent = tabs.SilentAim

local wallBtn = Instance.new('TextButton')
wallBtn.Size = UDim2.new(0, 50, 0, 22)
wallBtn.Position = UDim2.new(1, -65, 0, 99)
wallBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
wallBtn.Text = 'OFF'
wallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wallBtn.Font = Enum.Font.GothamBold
wallBtn.TextSize = 11
wallBtn.Parent = tabs.SilentAim
Instance.new('UICorner', wallBtn).CornerRadius = UDim.new(0, 6)

wallBtn.MouseButton1Click:Connect(function()
    _G.WallCheck = not _G.WallCheck
    if _G.WallCheck then
        wallBtn.Text = 'ON'
        wallBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 200)
    else
        wallBtn.Text = 'OFF'
        wallBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

local valueLabel = Instance.new('TextLabel')
valueLabel.Size = UDim2.new(1, -30, 0, 20)
valueLabel.Position = UDim2.new(0, 15, 0, 175)
valueLabel.Text = 'FOV Radius: 1000'
valueLabel.TextColor3 = uiText
valueLabel.TextSize = 13
valueLabel.Font = Enum.Font.Gotham
valueLabel.BackgroundTransparency = 1
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.Parent = tabs.SilentAim

local showFOVLabel = Instance.new('TextLabel')
showFOVLabel.Size = UDim2.new(0, 150, 0, 30)
showFOVLabel.Position = UDim2.new(0, 15, 0, 135)
showFOVLabel.Text = 'Show FOV'
showFOVLabel.TextColor3 = uiText
showFOVLabel.TextSize = 13
showFOVLabel.Font = Enum.Font.Gotham
showFOVLabel.BackgroundTransparency = 1
showFOVLabel.TextXAlignment = Enum.TextXAlignment.Left
showFOVLabel.Parent = tabs.SilentAim

local showFOVBtn = Instance.new('TextButton')
showFOVBtn.Size = UDim2.new(0, 50, 0, 22)
showFOVBtn.Position = UDim2.new(1, -65, 0, 134)
showFOVBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
showFOVBtn.Text = 'OFF'
showFOVBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showFOVBtn.Font = Enum.Font.GothamBold
showFOVBtn.TextSize = 11
showFOVBtn.Parent = tabs.SilentAim
Instance.new('UICorner', showFOVBtn).CornerRadius = UDim.new(0, 6)

showFOVBtn.MouseButton1Click:Connect(function()
    _G.ShowFOV = not _G.ShowFOV
    showFOVBtn.Text = _G.ShowFOV and 'ON' or 'OFF'
    showFOVBtn.BackgroundColor3 = _G.ShowFOV
        and Color3.fromRGB(100, 200, 100)
        or Color3.fromRGB(55, 55, 55)
    fovCircle.Visible = _G.ShowFOV
end)

local slider = Instance.new('Frame')
slider.Size = UDim2.new(1, -30, 0, 6)
slider.Position = UDim2.new(0, 15, 0, 205)
slider.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
slider.BorderSizePixel = 0
slider.Parent = tabs.SilentAim
Instance.new('UICorner', slider).CornerRadius = UDim.new(1, 0)

local button = Instance.new('TextButton')
button.Size = UDim2.new(0, 14, 0, 14)
button.Position = UDim2.new(1, -7, 0.5, -7)
button.BackgroundColor3 = Color3.fromRGB(145, 90, 255)
button.BorderSizePixel = 0
button.Text = ""
button.Parent = slider
Instance.new('UICorner', button).CornerRadius = UDim.new(1, 0)

local spreadLabel = Instance.new('TextLabel')
spreadLabel.Size = UDim2.new(1, -30, 0, 20)
spreadLabel.Position = UDim2.new(0, 15, 0, 225)
spreadLabel.Text = 'Bullet Spread: 100'
spreadLabel.TextColor3 = uiText
spreadLabel.TextSize = 13
spreadLabel.Font = Enum.Font.Gotham
spreadLabel.BackgroundTransparency = 1
spreadLabel.TextXAlignment = Enum.TextXAlignment.Left
spreadLabel.Parent = tabs.SilentAim

local spreadSlider = Instance.new('Frame')
spreadSlider.Size = UDim2.new(1, -30, 0, 6)
spreadSlider.Position = UDim2.new(0, 15, 0, 255)
spreadSlider.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
spreadSlider.BorderSizePixel = 0
spreadSlider.Parent = tabs.SilentAim
Instance.new('UICorner', spreadSlider).CornerRadius = UDim.new(1, 0)

local spreadBtn = Instance.new('TextButton')
spreadBtn.Size = UDim2.new(0, 14, 0, 14)
spreadBtn.Position = UDim2.new(1, -7, 0.5, -7)
spreadBtn.BackgroundColor3 = Color3.fromRGB(145, 90, 255)
spreadBtn.BorderSizePixel = 0
spreadBtn.Text = ""
spreadBtn.Parent = spreadSlider
Instance.new('UICorner', spreadBtn).CornerRadius = UDim.new(1, 0)

local hitLabel = Instance.new('TextLabel')
hitLabel.Size = UDim2.new(0, 100, 0, 30)
hitLabel.Position = UDim2.new(0, 15, 0, 280)
hitLabel.Text = 'Aim Part'
hitLabel.TextColor3 = uiText
hitLabel.TextSize = 13
hitLabel.Font = Enum.Font.Gotham
hitLabel.BackgroundTransparency = 1
hitLabel.TextXAlignment = Enum.TextXAlignment.Left
hitLabel.Parent = tabs.SilentAim

local dropMain = Instance.new('TextButton')
dropMain.Size = UDim2.new(0, 130, 0, 26)
dropMain.Position = UDim2.new(1, -145, 0, 282)
dropMain.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
dropMain.Text = 'Head v'
dropMain.TextColor3 = Color3.fromRGB(255, 255, 255)
dropMain.Font = Enum.Font.GothamBold
dropMain.TextSize = 12
dropMain.ZIndex = 5
dropMain.Parent = tabs.SilentAim
Instance.new('UICorner', dropMain).CornerRadius = UDim.new(0, 6)

local dropScroll = Instance.new('ScrollingFrame')
dropScroll.Size = UDim2.new(0, 130, 0, 100)
dropScroll.Position = UDim2.new(1, -145, 0, 312)
dropScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropScroll.BorderSizePixel = 0
dropScroll.Visible = false
dropScroll.ZIndex = 6
dropScroll.CanvasSize = UDim2.new(0, 0, 0, 215)
dropScroll.ScrollBarThickness = 3
dropScroll.Parent = tabs.SilentAim
Instance.new('UICorner', dropScroll).CornerRadius = UDim.new(0, 6)

local partsList = {"Head", "Body", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "Closest Part"}
for idx, partName in ipairs(partsList) do
    local partBtn = Instance.new('TextButton')
    partBtn.Size = UDim2.new(1, -8, 0, 26)
    partBtn.Position = UDim2.new(0, 4, 0, (idx-1) * 28 + 4)
    partBtn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    partBtn.Text = partName
    partBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    partBtn.Font = Enum.Font.Gotham
    partBtn.TextSize = 11
    partBtn.ZIndex = 7
    partBtn.Parent = dropScroll
    Instance.new('UICorner', partBtn).CornerRadius = UDim.new(0, 4)
    
    partBtn.MouseButton1Click:Connect(function()
        aimPart = partName
        dropMain.Text = partName .. ' v'
        dropScroll.Visible = false
    end)
end

dropMain.MouseButton1Click:Connect(function()
    dropScroll.Visible = not dropScroll.Visible
end)
local espBoxLabel = Instance.new('TextLabel')
espBoxLabel.Size = UDim2.new(0, 150, 0, 30)
espBoxLabel.Position = UDim2.new(0, 15, 0, 55)
espBoxLabel.Text = 'ESP Boxes'
espBoxLabel.TextColor3 = uiText
espBoxLabel.TextSize = 13
espBoxLabel.Font = Enum.Font.Gotham
espBoxLabel.BackgroundTransparency = 1
espBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
espBoxLabel.Parent = tabs.ESP

local espBoxBtn = Instance.new('TextButton')
espBoxBtn.Size = UDim2.new(0, 50, 0, 22)
espBoxBtn.Position = UDim2.new(1, -65, 0, 59)
espBoxBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
espBoxBtn.Text = 'OFF'
espBoxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBoxBtn.Font = Enum.Font.GothamBold
espBoxBtn.TextSize = 11
espBoxBtn.Parent = tabs.ESP
Instance.new('UICorner', espBoxBtn).CornerRadius = UDim.new(0, 6)

espBoxBtn.MouseButton1Click:Connect(function()
    _G.ESP_Boxes = not _G.ESP_Boxes
    espBoxBtn.Text = _G.ESP_Boxes and 'ON' or 'OFF'
    espBoxBtn.BackgroundColor3 = _G.ESP_Boxes and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(55, 55, 55)
end)

local espNameLabel = Instance.new('TextLabel')
espNameLabel.Size = UDim2.new(0, 150, 0, 30)
espNameLabel.Position = UDim2.new(0, 15, 0, 95)
espNameLabel.Text = 'ESP Names'
espNameLabel.TextColor3 = uiText
espNameLabel.TextSize = 13
espNameLabel.Font = Enum.Font.Gotham
espNameLabel.BackgroundTransparency = 1
espNameLabel.TextXAlignment = Enum.TextXAlignment.Left
espNameLabel.Parent = tabs.ESP

local espNameBtn = Instance.new('TextButton')
espNameBtn.Size = UDim2.new(0, 50, 0, 22)
espNameBtn.Position = UDim2.new(1, -65, 0, 99)
espNameBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
espNameBtn.Text = 'OFF'
espNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espNameBtn.Font = Enum.Font.GothamBold
espNameBtn.TextSize = 11
espNameBtn.Parent = tabs.ESP
Instance.new('UICorner', espNameBtn).CornerRadius = UDim.new(0, 6)

espNameBtn.MouseButton1Click:Connect(function()
    _G.ESP_Names = not _G.ESP_Names
    espNameBtn.Text = _G.ESP_Names and 'ON' or 'OFF'
    espNameBtn.BackgroundColor3 = _G.ESP_Names and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(55, 55, 55)
end)

local paletteLabel = Instance.new('TextLabel')
paletteLabel.Size = UDim2.new(1, -30, 0, 20)
paletteLabel.Position = UDim2.new(0, 15, 0, 135)
paletteLabel.Text = 'Select ESP Color'
paletteLabel.TextColor3 = uiText
paletteLabel.TextSize = 13
paletteLabel.Font = Enum.Font.Gotham
paletteLabel.BackgroundTransparency = 1
paletteLabel.TextXAlignment = Enum.TextXAlignment.Left
paletteLabel.Parent = tabs.ESP

local colorColors = {
    Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 130, 30), Color3.fromRGB(255, 215, 0),
    Color3.fromRGB(50, 220, 50), Color3.fromRGB(50, 150, 255), Color3.fromRGB(30, 30, 150),
    Color3.fromRGB(160, 50, 215), Color3.fromRGB(20, 20, 20), Color3.fromRGB(255, 255, 255)
}

for idx, colorHex in ipairs(colorColors) do
    local cBtn = Instance.new('TextButton')
    cBtn.Size = UDim2.new(0, 26, 0, 26)
    cBtn.Position = UDim2.new(0, 15 + ((idx-1) % 5) * 34, 0, 165 + math.floor((idx-1) / 5) * 34)
    cBtn.BackgroundColor3 = colorHex
    cBtn.Text = ""
    cBtn.Parent = tabs.ESP
    Instance.new('UICorner', cBtn).CornerRadius = UDim.new(0, 6)
    if colorHex == Color3.fromRGB(20, 20, 20) then
        Instance.new('UIStroke', cBtn).Color = Color3.fromRGB(255, 255, 255)
    else
        local strk = Instance.new('UIStroke', cBtn)
        strk.Color = Color3.fromRGB(255, 255, 255)
        strk.Transparency = 0.6
    end
    cBtn.MouseButton1Click:Connect(function() _G.ESP_Color = colorHex end)
end

local speedToggleLabel = Instance.new('TextLabel')
speedToggleLabel.Size = UDim2.new(0, 150, 0, 30)
speedToggleLabel.Position = UDim2.new(0, 15, 0, 55)
speedToggleLabel.Text = 'Speed Enabled'
speedToggleLabel.TextColor3 = uiText
speedToggleLabel.TextSize = 13
speedToggleLabel.Font = Enum.Font.Gotham
speedToggleLabel.BackgroundTransparency = 1
speedToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
speedToggleLabel.Parent = tabs.Speed

local speedToggleBtn = Instance.new('TextButton')
speedToggleBtn.Size = UDim2.new(0, 50, 0, 22)
speedToggleBtn.Position = UDim2.new(1, -65, 0, 59)
speedToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
speedToggleBtn.Text = 'OFF'
speedToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedToggleBtn.Font = Enum.Font.GothamBold
speedToggleBtn.TextSize = 11
speedToggleBtn.Parent = tabs.Speed
Instance.new('UICorner', speedToggleBtn).CornerRadius = UDim.new(0, 6)

speedToggleBtn.MouseButton1Click:Connect(function()
    _G.Speed_Enabled = not _G.Speed_Enabled
    speedToggleBtn.Text = _G.Speed_Enabled and 'ON' or 'OFF'
    speedToggleBtn.BackgroundColor3 = _G.Speed_Enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(55, 55, 55)
    updateSpeedBinding()
end)

local keyLabel = Instance.new('TextLabel')
keyLabel.Size = UDim2.new(0, 150, 0, 30)
keyLabel.Position = UDim2.new(0, 15, 0, 95)
keyLabel.Text = 'Speed Bind'
keyLabel.TextColor3 = uiText
keyLabel.TextSize = 13
keyLabel.Font = Enum.Font.Gotham
keyLabel.BackgroundTransparency = 1
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = tabs.Speed

local bindBtn = Instance.new('TextButton')
bindBtn.Size = UDim2.new(0, 70, 0, 22)
bindBtn.Position = UDim2.new(1, -85, 0, 99)
bindBtn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
bindBtn.Text = 'Key: X'
bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bindBtn.Font = Enum.Font.GothamBold
bindBtn.TextSize = 11
bindBtn.Parent = tabs.Speed
Instance.new('UICorner', bindBtn).CornerRadius = UDim.new(0, 6)

local isBinding = false
bindBtn.MouseButton1Click:Connect(function()
    isBinding = true
    bindBtn.Text = '...'
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        _G.Speed_Key = input.KeyCode
        bindBtn.Text = 'Key: ' .. input.KeyCode.Name
        isBinding = false
    end
end)

local speedValLabel = Instance.new('TextLabel')
speedValLabel.Size = UDim2.new(1, -30, 0, 20)
speedValLabel.Position = UDim2.new(0, 15, 0, 135)
speedValLabel.Text = 'Speed Value: 50'
speedValLabel.TextColor3 = uiText
speedValLabel.TextSize = 13
speedValLabel.Font = Enum.Font.Gotham
speedValLabel.BackgroundTransparency = 1
speedValLabel.TextXAlignment = Enum.TextXAlignment.Left
speedValLabel.Parent = tabs.Speed

local speedSlider = Instance.new('Frame')
speedSlider.Size = UDim2.new(1, -30, 0, 6)
speedSlider.Position = UDim2.new(0, 15, 0, 165)
speedSlider.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = tabs.Speed
Instance.new('UICorner', speedSlider).CornerRadius = UDim.new(1, 0)

local speedSliderBtn = Instance.new('TextButton')
speedSliderBtn.Size = UDim2.new(0, 14, 0, 14)
speedSliderBtn.Position = UDim2.new(math.clamp((_G.Speed_Value - 50) / 950, 0, 1), -7, 0.5, -7)
speedSliderBtn.BackgroundColor3 = Color3.fromRGB(145, 90, 255)
speedSliderBtn.BorderSizePixel = 0
speedSliderBtn.Text = ""
speedSliderBtn.Parent = speedSlider
Instance.new('UICorner', speedSliderBtn).CornerRadius = UDim.new(1, 0)

local camlockToggleLabel = Instance.new('TextLabel')
camlockToggleLabel.Size = UDim2.new(0, 150, 0, 30)
camlockToggleLabel.Position = UDim2.new(0, 15, 0, 55)
camlockToggleLabel.Text = 'Camlock Enabled'
camlockToggleLabel.TextColor3 = uiText
camlockToggleLabel.TextSize = 13
camlockToggleLabel.Font = Enum.Font.Gotham
camlockToggleLabel.BackgroundTransparency = 1
camlockToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
camlockToggleLabel.Parent = tabs.Camlock

local camlockToggleBtn = Instance.new('TextButton')
camlockToggleBtn.Size = UDim2.new(0, 50, 0, 22)
camlockToggleBtn.Position = UDim2.new(1, -65, 0, 59)
camlockToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
camlockToggleBtn.Text = 'OFF'
camlockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
camlockToggleBtn.Font = Enum.Font.GothamBold
camlockToggleBtn.TextSize = 11
camlockToggleBtn.Parent = tabs.Camlock
Instance.new('UICorner', camlockToggleBtn).CornerRadius = UDim.new(0, 6)

camlockToggleBtn.MouseButton1Click:Connect(function()
    _G.Camlock_ToggleEnabled = not _G.Camlock_ToggleEnabled
    camlockToggleBtn.Text = _G.Camlock_ToggleEnabled and 'ON' or 'OFF'
    camlockToggleBtn.BackgroundColor3 = _G.Camlock_ToggleEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(55, 55, 55)
    if not _G.Camlock_ToggleEnabled then
        _G.Camlock_Enabled = false
    end
end)

local camlockKeyLabel = Instance.new('TextLabel')
camlockKeyLabel.Size = UDim2.new(0, 150, 0, 30)
camlockKeyLabel.Position = UDim2.new(0, 15, 0, 95)
camlockKeyLabel.Text = 'Camlock Bind'
camlockKeyLabel.TextColor3 = uiText
camlockKeyLabel.TextSize = 13
camlockKeyLabel.Font = Enum.Font.Gotham
camlockKeyLabel.BackgroundTransparency = 1
camlockKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
camlockKeyLabel.Parent = tabs.Camlock

local camlockBindBtn = Instance.new('TextButton')
camlockBindBtn.Size = UDim2.new(0, 70, 0, 22)
camlockBindBtn.Position = UDim2.new(1, -85, 0, 99)
camlockBindBtn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
camlockBindBtn.Text = 'Key: C'
camlockBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
camlockBindBtn.Font = Enum.Font.GothamBold
camlockBindBtn.TextSize = 11
camlockBindBtn.Parent = tabs.Camlock
Instance.new('UICorner', camlockBindBtn).CornerRadius = UDim.new(0, 6)

local isCamlockBinding = false
camlockBindBtn.MouseButton1Click:Connect(function()
    isCamlockBinding = true
    camlockBindBtn.Text = '...'
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isCamlockBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        _G.Camlock_Key = input.KeyCode
        camlockBindBtn.Text = 'Key: ' .. input.KeyCode.Name
        isCamlockBinding = false
    end
end)

local camlockSmoothLabel = Instance.new('TextLabel')
camlockSmoothLabel.Size = UDim2.new(1, -30, 0, 20)
camlockSmoothLabel.Position = UDim2.new(0, 15, 0, 135)
camlockSmoothLabel.Text = 'Smoothness: 0.2'
camlockSmoothLabel.TextColor3 = uiText
camlockSmoothLabel.TextSize = 13
camlockSmoothLabel.Font = Enum.Font.Gotham
camlockSmoothLabel.BackgroundTransparency = 1
camlockSmoothLabel.TextXAlignment = Enum.TextXAlignment.Left
camlockSmoothLabel.Parent = tabs.Camlock

local camlockSmoothSlider = Instance.new('Frame')
camlockSmoothSlider.Size = UDim2.new(1, -30, 0, 6)
camlockSmoothSlider.Position = UDim2.new(0, 15, 0, 165)
camlockSmoothSlider.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
camlockSmoothSlider.BorderSizePixel = 0
camlockSmoothSlider.Parent = tabs.Camlock
Instance.new('UICorner', camlockSmoothSlider).CornerRadius = UDim.new(1, 0)

local camlockSmoothBtn = Instance.new('TextButton')
camlockSmoothBtn.Size = UDim2.new(0, 14, 0, 14)
camlockSmoothBtn.Position = UDim2.new(0.2, -7, 0.5, -7)
camlockSmoothBtn.BackgroundColor3 = Color3.fromRGB(145, 90, 255)
camlockSmoothBtn.BorderSizePixel = 0
camlockSmoothBtn.Text = ""
camlockSmoothBtn.Parent = camlockSmoothSlider
Instance.new('UICorner', camlockSmoothBtn).CornerRadius = UDim.new(1, 0)

local moveConnection3
local function updateCamlockSlider(input)
    local percentage = math.clamp((input.Position.X - camlockSmoothSlider.AbsolutePosition.X) / camlockSmoothSlider.AbsoluteSize.X, 0, 1)
    camlockSmoothBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
    local finalValue = math.round(percentage * 100) / 100
    camlockSmoothLabel.Text = 'Smoothness: ' .. tostring(finalValue)
    _G.Camlock_Smoothness = finalValue
end

camlockSmoothBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        moveConnection3 = UIS.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                updateCamlockSlider(moveInput)
            end
        end)
    end
end)

local tpLabel = Instance.new('TextLabel')
tpLabel.Size = UDim2.new(1, -30, 0, 30)
tpLabel.Position = UDim2.new(0, 15, 0, 55)
tpLabel.Text = 'Teleport to Player'
tpLabel.TextColor3 = uiText
tpLabel.TextSize = 13
tpLabel.Font = Enum.Font.Gotham
tpLabel.BackgroundTransparency = 1
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.Parent = tabs.Teleport

local tpList = Instance.new('ScrollingFrame')
tpList.Size = UDim2.new(1, -30, 0, 240)
tpList.Position = UDim2.new(0, 15, 0, 90)
tpList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpList.BorderSizePixel = 0
tpList.Visible = false
tpList.CanvasSize = UDim2.new(0, 0, 0, 0)
tpList.ScrollBarThickness = 4
tpList.Parent = tabs.Teleport
Instance.new('UICorner', tpList).CornerRadius = UDim.new(0, 6)

local tpListExpanded = false

local function refreshTeleportList()
    tpList:ClearAllChildren()
    local playerCount = 0
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= me then
            playerCount = playerCount + 1
            local playerBtn = Instance.new('TextButton')
            playerBtn.Size = UDim2.new(1, -8, 0, 26)
            playerBtn.Position = UDim2.new(0, 4, 0, (playerCount - 1) * 30 + 4)
            playerBtn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
            playerBtn.Text = p.Name
            playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextSize = 11
            playerBtn.Parent = tpList
            Instance.new('UICorner', playerBtn).CornerRadius = UDim.new(0, 4)

            playerBtn.MouseButton1Click:Connect(function()
                local targetChar = p.Character
                local targetRoot = targetChar and targetChar:FindFirstChild('HumanoidRootPart')
                local localRoot = me.Character and me.Character:FindFirstChild('HumanoidRootPart')
                if targetRoot and localRoot then
                    localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end
    tpList.CanvasSize = UDim2.new(0, 0, 0, math.max(30, playerCount * 30))
end

local tpActionBtn = Instance.new('TextButton')
tpActionBtn.Size = UDim2.new(0, 120, 0, 30)
tpActionBtn.Position = UDim2.new(0, 15, 0, 90)
tpActionBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
tpActionBtn.Text = 'Show All'
tpActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpActionBtn.Font = Enum.Font.GothamBold
tpActionBtn.TextSize = 13
tpActionBtn.Parent = tabs.Teleport
Instance.new('UICorner', tpActionBtn).CornerRadius = UDim.new(0, 6)

tpActionBtn.MouseButton1Click:Connect(function()
    tpListExpanded = not tpListExpanded
    if tpListExpanded then
        tpActionBtn.Text = 'Hide All'
        refreshTeleportList()
        tpList.Visible = true
    else
        tpActionBtn.Text = 'Show All'
        tpList.Visible = false
    end
end)

local whitelistLabel = Instance.new('TextLabel')
whitelistLabel.Size = UDim2.new(1, -30, 0, 30)
whitelistLabel.Position = UDim2.new(0, 15, 0, 55)
whitelistLabel.Text = 'Whitelist'
whitelistLabel.TextColor3 = uiText
whitelistLabel.TextSize = 13
whitelistLabel.Font = Enum.Font.Gotham
whitelistLabel.BackgroundTransparency = 1
whitelistLabel.TextXAlignment = Enum.TextXAlignment.Left
whitelistLabel.Parent = tabs.Whitelist

local whitelistList = Instance.new('ScrollingFrame')
whitelistList.Size = UDim2.new(1, -30, 0, 240)
whitelistList.Position = UDim2.new(0, 15, 0, 90)
whitelistList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
whitelistList.BorderSizePixel = 0
whitelistList.Visible = false
whitelistList.CanvasSize = UDim2.new(0, 0, 0, 0)
whitelistList.ScrollBarThickness = 4
whitelistList.Parent = tabs.Whitelist
Instance.new('UICorner', whitelistList).CornerRadius = UDim.new(0, 6)

local whitelistExpanded = false

local function updateWhitelistButton(btn, player)
    if whitelist[player] then
        btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        btn.Text = player.Name .. " ✓"
    else
        btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
        btn.Text = player.Name
    end
end

local function refreshWhitelistList()
    whitelistList:ClearAllChildren()
    local playerCount = 0
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= me then
            playerCount = playerCount + 1
            local playerBtn = Instance.new('TextButton')
            playerBtn.Size = UDim2.new(1, -8, 0, 26)
            playerBtn.Position = UDim2.new(0, 4, 0, (playerCount - 1) * 30 + 4)
            playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextSize = 11
            playerBtn.AutoButtonColor = true
            playerBtn.Parent = whitelistList
            Instance.new('UICorner', playerBtn).CornerRadius = UDim.new(0, 4)

            updateWhitelistButton(playerBtn, p)

            playerBtn.MouseButton1Click:Connect(function()
                whitelist[p] = not whitelist[p]
                updateWhitelistButton(playerBtn, p)
            end)
        end
    end
    whitelistList.CanvasSize = UDim2.new(0, 0, 0, math.max(30, playerCount * 30))
end

local whitelistActionBtn = Instance.new('TextButton')
whitelistActionBtn.Size = UDim2.new(0, 120, 0, 30)
whitelistActionBtn.Position = UDim2.new(0, 15, 0, 90)
whitelistActionBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
whitelistActionBtn.Text = 'Show All'
whitelistActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
whitelistActionBtn.Font = Enum.Font.GothamBold
whitelistActionBtn.TextSize = 13
whitelistActionBtn.Parent = tabs.Whitelist
Instance.new('UICorner', whitelistActionBtn).CornerRadius = UDim.new(0, 6)

whitelistActionBtn.MouseButton1Click:Connect(function()
    whitelistExpanded = not whitelistExpanded
    if whitelistExpanded then
        whitelistActionBtn.Text = 'Hide All'
        refreshWhitelistList()
        whitelistList.Visible = true
    else
        whitelistActionBtn.Text = 'Show All'
        whitelistList.Visible = false
    end
end)

-- Settings tab: UI Toggle Key
local uiToggleKeyLabel = Instance.new('TextLabel')
uiToggleKeyLabel.Size = UDim2.new(0, 150, 0, 30)
uiToggleKeyLabel.Position = UDim2.new(0, 15, 0, 55)
uiToggleKeyLabel.Text = 'UI Toggle Key'
uiToggleKeyLabel.TextColor3 = uiText
uiToggleKeyLabel.TextSize = 13
uiToggleKeyLabel.Font = Enum.Font.Gotham
uiToggleKeyLabel.BackgroundTransparency = 1
uiToggleKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
uiToggleKeyLabel.Parent = tabs.Settings

local uiToggleBindBtn = Instance.new('TextButton')
uiToggleBindBtn.Size = UDim2.new(0, 100, 0, 22)
uiToggleBindBtn.Position = UDim2.new(1, -115, 0, 59)
uiToggleBindBtn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
uiToggleBindBtn.Text = 'Key: RightShift'
uiToggleBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
uiToggleBindBtn.Font = Enum.Font.GothamBold
uiToggleBindBtn.TextSize = 11
uiToggleBindBtn.Parent = tabs.Settings
Instance.new('UICorner', uiToggleBindBtn).CornerRadius = UDim.new(0, 6)

local isUIToggleBinding = false
uiToggleBindBtn.MouseButton1Click:Connect(function()
    isUIToggleBinding = true
    uiToggleBindBtn.Text = '...'
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isUIToggleBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        _G.UI_Toggle_Key = input.KeyCode
        uiToggleBindBtn.Text = 'Key: ' .. input.KeyCode.Name
        isUIToggleBinding = false
    end
end)

local moveConnection1
local function updateSlider1(input)
    local percentage = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
    button.Position = UDim2.new(percentage, -7, 0.5, -7)
    local finalValue = math.round(percentage * 1000)
    valueLabel.Text = 'FOV Radius: ' .. tostring(finalValue)
    _G.FOV_RADIUS = finalValue
    updateFOVCircle()
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        moveConnection1 = UIS.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                updateSlider1(moveInput)
            end
        end)
    end
end)

local moveConnection2
local function updateSlider2(input)
    local percentage = math.clamp((input.Position.X - spreadSlider.AbsolutePosition.X) / spreadSlider.AbsoluteSize.X, 0, 1)
    spreadBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
    local finalValue = math.round(percentage * 100)
    spreadLabel.Text = 'Bullet Spread: ' .. tostring(finalValue)
    _0x52a0d5.BulletSpread.Amount = finalValue
end

spreadBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        moveConnection2 = UIS.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                updateSlider2(moveInput)
            end
        end)
    end
end)

local moveConnection4
local function updateSpeedSlider(input)
    local percentage = math.clamp((input.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
    speedSliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
    local finalValue = math.round(50 + (percentage * 950))
    speedValLabel.Text = 'Speed Value: ' .. tostring(finalValue)
    _G.Speed_Value = finalValue
end

speedSliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        moveConnection4 = UIS.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                updateSpeedSlider(moveInput)
            end
        end)
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == _G.Speed_Key and not isBinding and _G.Speed_ToggleEnabled then
        _G.Speed_Enabled = not _G.Speed_Enabled
        speedToggleBtn.Text = _G.Speed_Enabled and 'ON' or 'OFF'
        speedToggleBtn.BackgroundColor3 = _G.Speed_Enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(55, 55, 55)
        updateSpeedBinding()
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == _G.Camlock_Key and not isCamlockBinding and _G.Camlock_ToggleEnabled then
        _G.Camlock_Enabled = not _G.Camlock_Enabled
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Camlock_Enabled and _G.Camlock_ToggleEnabled then
        local target = getClosest()
        if target then
            local targetPos = target.Position
            local cameraPos = cam.CFrame.Position
            
            local newCFrame = CFrame.lookAt(cameraPos, targetPos)
            
            local smoothness = math.clamp(_G.Camlock_Smoothness, 0, 1)
            if smoothness >= 0.9 then
                cam.CFrame = newCFrame
            else
                cam.CFrame = cam.CFrame:Lerp(newCFrame, smoothness)
            end
        end
    end
end)

local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.Font = Drawing.Fonts.UI

    local conn
    conn = game:GetService("RunService").RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head") or rootPart
            local rootPos, rootOnScreen = cam:WorldToViewportPoint(rootPart.Position)
            
            if rootOnScreen then
                local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = cam:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight / 2

                if _G.ESP_Boxes then
                    box.Size = Vector2.new(boxWidth, boxHeight)
                    box.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
                    box.Color = _G.ESP_Color
                    box.Visible = true
                else box.Visible = false end

                if _G.ESP_Names then
                    name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight / 2 - 18)
                    name.Text = player.Name
                    name.Color = _G.ESP_Color
                    name.Visible = true
                else name.Visible = false end
            else box.Visible = false name.Visible = false end
        else
            box.Visible = false name.Visible = false
            if not player or not player.Parent then box:Remove() name:Remove() conn:Disconnect() end
        end
    end)
end

for _, p in pairs(plrs:GetPlayers()) do if p ~= me then createESP(p) end end
plrs.PlayerAdded:Connect(function(p) if p ~= me then createESP(p) end end)

local speedHumanoidConnection

local function stopSpeedBinding()
    if speedHumanoidConnection then
        speedHumanoidConnection:Disconnect()
        speedHumanoidConnection = nil
    end
end

local function applySpeed()
    if not _G.Speed_Enabled then
        return
    end
    local char = me.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local targetSpeed = math.clamp(_G.Speed_Value, 16, 1000)
    if humanoid.WalkSpeed ~= targetSpeed then
        humanoid.WalkSpeed = targetSpeed
    end
end

local function bindSpeedHumanoid(humanoid)
    stopSpeedBinding()
    if humanoid and _G.Speed_Enabled then
        speedHumanoidConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            local targetSpeed = math.clamp(_G.Speed_Value, 16, 1000)
            if humanoid.WalkSpeed ~= targetSpeed then
                humanoid.WalkSpeed = targetSpeed
            end
        end)
    end
end

local function updateSpeedBinding()
    local char = me.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    bindSpeedHumanoid(humanoid)
    applySpeed()
end

if me.Character then
    task.spawn(function()
        task.wait(0.1)
        updateSpeedBinding()
        local humanoid = me.Character:FindFirstChildOfClass("Humanoid")
        monitorDamage(humanoid)
    end)
end

me.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.1)
    updateSpeedBinding()
    monitorDamage(humanoid)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Speed_Enabled then
        applySpeed()
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    applySpeed()
    applyHeadlessEffect()
    
    local terrain = workspace.Terrain
    if terrain then
        terrain.Fog.Color = _G.Fog_Color
        terrain.Fog.Density = _G.Fog_Density
        terrain.Fog.Min = _G.Fog_Start
        terrain.Fog.Max = _G.Fog_End
    end
end)

local uiVisible = true
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == _G.UI_Toggle_Key and not isUIToggleBinding then
        uiVisible = not uiVisible
        frame.Visible = uiVisible
        if not uiVisible then dropScroll.Visible = false end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if moveConnection1 then moveConnection1:Disconnect() moveConnection1 = nil end
        if moveConnection2 then moveConnection2:Disconnect() moveConnection2 = nil end
        if moveConnection3 then moveConnection3:Disconnect() moveConnection3 = nil end
        if moveConnection4 then moveConnection4:Disconnect() moveConnection4 = nil end
        if moveConnection5 then moveConnection5:Disconnect() moveConnection5 = nil end
        if moveConnection6 then moveConnection6:Disconnect() moveConnection6 = nil end
        if moveConnection7 then moveConnection7:Disconnect() moveConnection7 = nil end
    end
end)
