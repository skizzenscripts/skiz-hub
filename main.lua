local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local poseCount = 0
local positions = {}
local performanceEnabled = false
local originalLighting = {}

-- Helpers
local function getHum()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
end

local function getHRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- Add TextStroke (Glow effect)
logo.TextStrokeTransparency = 0.4  -- Controls the glow intensity (lower = stronger glow)
logo.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)  -- Set stroke color to purple (or any color)

-- Main Window
local main = Instance.new("Frame")
main.Size = UDim2.new(0,BASE_WIDTH,0,BASE_HEIGHT)
main.Position = UDim2.new(0.5,-BASE_WIDTH/2,0.5,-BASE_HEIGHT/2)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.Visible = false
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,18)

-- Add the second TextLabel at the top of the 'main' UI (above the tabs)
local textLabelSecond = Instance.new("TextLabel")
textLabelSecond.Size = UDim2.new(0, BASE_WIDTH, 0, 30)  -- Set the size of the label
textLabelSecond.Position = UDim2.new(0, 0, 0, 0)  -- Stick to the top of the 'main' frame
textLabelSecond.Text = "Skizzen's TP Hub V1"  -- Set the text
textLabelSecond.Font = Enum.Font.GothamBold
textLabelSecond.TextSize = 18
textLabelSecond.TextColor3 = Color3.fromRGB(255, 170, 255)
textLabelSecond.BackgroundTransparency = 1  -- Make the background transparent
textLabelSecond.Parent = main  -- Attach to the 'main' frame

-- First TextLabel at the top of the screen (with glow effect)
local textLabelTop = Instance.new("TextLabel")
textLabelTop.Size = UDim2.new(0, BASE_WIDTH, 0, 30)  -- Set the size of the label
textLabelTop.Position = UDim2.new(0.5, -BASE_WIDTH / 2, 0, 20)  -- Stick to the top of the screen
textLabelTop.Text = "OUR DISCORD : https://discord.gg/2fvrGx2u"  -- Set the text
textLabelTop.Font = Enum.Font.GothamBold
textLabelTop.TextSize = 30
textLabelTop.TextColor3 = Color3.fromRGB(128, 128, 128)
textLabelTop.BackgroundTransparency = 1  -- Make the background transparent
textLabelTop.Parent = gui  -- Attach to the main GUI (screen, not inside the 'main' frame)

-- Add Glow Effect to the first TextLabel
textLabelTop.TextStrokeTransparency = 0.4  -- Controls the glow intensity (lower = stronger glow)
textLabelTop.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)  -- Set stroke color to purple (or any color)


-- Rainbow Gradient Outline
local rainbowOutline = Instance.new("UIStroke", main)
rainbowOutline.Thickness = 4  -- Adjust the thickness of the outline
rainbowOutline.Transparency = 0  -- No transparency for the outline
rainbowOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border  -- Apply only to the border

-- Create the rainbow gradient
local rainbowGradient = Instance.new("UIGradient")
rainbowGradient.Parent = rainbowOutline
rainbowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),     -- Red
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 127, 0)),  -- Orange
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 255, 0)),  -- Yellow
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(0, 255, 0)),    -- Green
    ColorSequenceKeypoint.new(0.57, Color3.fromRGB(0, 0, 255)),    -- Blue
    ColorSequenceKeypoint.new(0.71, Color3.fromRGB(75, 0, 130)),   -- Indigo
    ColorSequenceKeypoint.new(0.85, Color3.fromRGB(148, 0, 211)),  -- Violet
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))        -- Back to Red
})

rainbowGradient.Rotation = 90  -- Rotate the gradient to make it horizontal

local stroke = Instance.new("UIStroke",main)
stroke.Color = Color3.fromRGB(200,0,255)
stroke.Transparency = 0.75

-- Resize (no longer used for TP to Pos tab)
local function resize(height)
    TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, BASE_WIDTH, 0, height)
    }):Play()
end

local function minimizeUI()
    TweenService:Create(main,TweenInfo.new(0.2),{
        Size = UDim2.new(0,0,0,0)
    }):Play()
    task.wait(0.2)
    main.Visible = false
    logo.Visible = true
end

logo.MouseButton1Click:Connect(function()
    logo.Visible = false
    openUI()
end)

-- Close & Minimize Buttons
local function makeTopButton(text,pos)
    local b = Instance.new("TextButton",main)
    b.Size = UDim2.new(0,22,0,22)
    b.Position = UDim2.new(1,pos,0,8)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BackgroundColor3 = Color3.fromRGB(45,0,70)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
    return b
end

local closeBtn = makeTopButton("X",-28)
local minBtn = makeTopButton("_",-55)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

minBtn.MouseButton1Click:Connect(minimizeUI)

-- Content
local content = Instance.new("Frame",main)
content.Position = UDim2.new(0,10,0,75)
content.Size = UDim2.new(1,-20,1,-85)
content.BackgroundTransparency = 1

local tpFrame = Instance.new("Frame",content)
tpFrame.Size = UDim2.new(1,0,1,0)
tpFrame.BackgroundTransparency = 1

local stealFrame = tpFrame:Clone()
stealFrame.Parent = content
stealFrame.Visible = false

local quickFrame = tpFrame:Clone()
quickFrame.Parent = content
quickFrame.Visible = false

local tpLayout = Instance.new("UIListLayout",tpFrame)
tpLayout.Padding = UDim.new(0,6)

local stealLayout = Instance.new("UIListLayout",stealFrame)
stealLayout.Padding = UDim.new(0,10)

local quickLayout = Instance.new("UIListLayout",quickFrame)
quickLayout.Padding = UDim.new(0,10)

-- TP Forward Button (Teleport based on where you're looking)
local tpForwardBtn = Instance.new("TextButton",stealScrollingFrame)
tpForwardBtn.Size = UDim2.new(1,0,0,40)
tpForwardBtn.Text = "TP Forward (10 studs)"
tpForwardBtn.Font = Enum.Font.GothamBold
tpForwardBtn.TextSize = 12
tpForwardBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
tpForwardBtn.TextColor3 = Color3.fromRGB(255,170,255)
Instance.new("UICorner",tpForwardBtn).CornerRadius = UDim.new(0,10)

tpForwardBtn.MouseButton1Click:Connect(function()
    local direction = getHRP().CFrame.LookVector
    local newPosition = getHRP().Position + (direction * 10)  -- Teleport 10 studs forward
    getHRP().CFrame = CFrame.new(newPosition)
end)

-- TP Boxes
local function createPositionBox(i)
    local box = Instance.new("Frame",tpFrame)
    box.Size = UDim2.new(1,0,0,45)
    box.BackgroundColor3 = Color3.fromRGB(28,28,28)
    Instance.new("UICorner",box).CornerRadius = UDim.new(0,10)

    local label = Instance.new("TextLabel",box)
    label.Size = UDim2.new(0.5,0,1,0)
    label.Text = "Position "..i
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255,170,255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0.05,0,0,0)

    local function makeBtn(txt,x)
        local b = Instance.new("TextButton",box)
        b.Size = UDim2.new(0,50,0,24)
        b.Position = UDim2.new(x,0,0.5,-12)
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BackgroundColor3 = Color3.fromRGB(45,0,70)
        b.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
        return b
    end

    local save = makeBtn("Save",0.6)
    local fly = makeBtn("Fly",0.78)

    save.MouseButton1Click:Connect(function()
        positions[i] = getHRP().CFrame
    end)

    fly.MouseButton1Click:Connect(function()
        if positions[i] then
            -- Smooth teleport to saved position
            local targetPos = positions[i].Position
            local targetCFrame = CFrame.new(targetPos)

            -- Create a tween to fly smoothly to the target position
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(getHRP(), tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        end
    end)
end

local addBtn = Instance.new("TextButton",tpFrame)
addBtn.Size = UDim2.new(0,34,0,34)
addBtn.Text = "+"
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 16
addBtn.BackgroundColor3 = Color3.fromRGB(55,0,80)
addBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",addBtn).CornerRadius = UDim.new(1,0)

addBtn.MouseButton1Click:Connect(function()
    if poseCount >= MAX_POSES then return end
    poseCount += 1
    createPositionBox(poseCount)
    if poseCount >= MAX_POSES then addBtn.Visible = false end
end)

-- Stealing (Speed + Gravity)
local function createInput(parent,text,default,callback)
    local box = Instance.new("TextBox",parent)
    box.Size = UDim2.new(1,0,0,40)
    box.Text = text.." : "..default
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.BackgroundColor3 = Color3.fromRGB(28,28,28)
    box.TextColor3 = Color3.fromRGB(255,170,255)
    Instance.new("UICorner",box).CornerRadius = UDim.new(0,10)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text:match("%d+"))
        if num then callback(num) end
    end)
end

createInput(stealScrollingFrame,"Speed (16-100)",16,function(v)
    getHum().WalkSpeed = math.clamp(v,16,100)
end)

createInput(stealScrollingFrame,"Gravity",196,function(v)
    workspace.Gravity = v
end)

-- Performance Mode
local perfButton = Instance.new("TextButton",stealScrollingFrame)
perfButton.Size = UDim2.new(1,0,0,40)
perfButton.Text = "Shitty Mode: OFF"
perfButton.Font = Enum.Font.GothamBold
perfButton.TextSize = 12
perfButton.BackgroundColor3 = Color3.fromRGB(45,0,70)
perfButton.TextColor3 = Color3.fromRGB(255,170,255)
Instance.new("UICorner",perfButton).CornerRadius = UDim.new(0,10)

local function setPerformance(state)
    performanceEnabled = state
    
    if state then
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Color = Color3.fromRGB(130,130,130)
            elseif v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        Lighting.GlobalShadows = true
    end
end

perfButton.MouseButton1Click:Connect(function()
    setPerformance(not performanceEnabled)
    perfButton.Text = "??? Mode: "..(performanceEnabled and "ON" or "OFF")
end)

local UserInputService = game:GetService("UserInputService")

-- Quick Panel (fixed)
local function quickButton(text,callback)
    local b = Instance.new("TextButton",quickFrame)
    b.Size = UDim2.new(1,0,0,40)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BackgroundColor3 = Color3.fromRGB(60,30,100)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(callback)
end

quickButton("Force Reset",function()
    player.Character:BreakJoints()
end)

quickButton("Rejoin",function()
    TeleportService:Teleport(game.PlaceId,player)
end)

quickButton("Kill UI💀",function()
    main.Visible = not main.Visible
end)

-- Tab Switch
local function switchTab(tab)
    tpFrame.Visible = (tab=="tp")
    stealFrame.Visible = (tab=="steal")
    quickFrame.Visible = (tab=="quick")

    if tab=="tp" then
        -- No resizing required here now
    else
        resize(BASE_HEIGHT)
    end
end

tpTab.MouseButton1Click:Connect(function() switchTab("tp") end)
stealTab.MouseButton1Click:Connect(function() switchTab("steal") end)
quickTab.MouseButton1Click:Connect(function() switchTab("quick") end)

-- Add the Teleport to Pos 1, 2, and 3 button to the Stealing tab
local tpPosButton = Instance.new("TextButton", stealScrollingFrame)
tpPosButton.Size = UDim2.new(1, 0, 0, 40)
tpPosButton.Text = "Insta Steal⚡"
tpPosButton.Font = Enum.Font.GothamBold
tpPosButton.TextSize = 12
tpPosButton.BackgroundColor3 = Color3.fromRGB(45, 0, 70)
tpPosButton.TextColor3 = Color3.fromRGB(255, 170, 255)
Instance.new("UICorner", tpPosButton).CornerRadius = UDim.new(0, 10)

tpPosButton.MouseButton1Click:Connect(function()
    -- Check if positions 3, 2, and 1 exist
    if positions[3] then
        -- Teleport to Position 3
        getHRP().CFrame = positions[1]
        wait(0.35)  -- Wait before teleporting to the next position
    end
    if positions[2] then
        -- Teleport to Position 2
        getHRP().CFrame = positions[2]
        wait(0.35)  -- Wait before teleporting to the next position
    end
    if positions[3] then
        -- Teleport to Position 1
        getHRP().CFrame = positions[3]
    end
end)

-- Ctrl-TP Code
local isCtrlTpEnabled = false

-- Create the Ctrl-TP button
local ctrlTpButton = Instance.new("TextButton", stealScrollingFrame)
ctrlTpButton.Size = UDim2.new(1, 0, 0, 40)
ctrlTpButton.Text = "Ctrl-TP"
ctrlTpButton.Font = Enum.Font.GothamBold
ctrlTpButton.TextSize = 12
ctrlTpButton.BackgroundColor3 = Color3.fromRGB(45, 0, 70)
ctrlTpButton.TextColor3 = Color3.fromRGB(255, 170, 255)
Instance.new("UICorner", ctrlTpButton).CornerRadius = UDim.new(0, 10)

ctrlTpButton.MouseButton1Click:Connect(function()
    isCtrlTpEnabled = not isCtrlTpEnabled
    ctrlTpButton.Text = "Ctrl-TP: " .. (isCtrlTpEnabled and "ON" or "OFF")
end)

-- Detect key press
local isCtrlPressed = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        isCtrlPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        isCtrlPressed = false
    end
end)

-- Teleport to click position if Ctrl-TP is enabled
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Check if Ctrl-TP is enabled and the user clicked with the mouse
    if isCtrlTpEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Get the position where the user clicked
        local mousePos = UserInputService:GetMouseLocation()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000)

        -- Teleport if the raycast hits something
        if hit then
            getHRP().CFrame = CFrame.new(hit.Position)
        end
    end
end)
