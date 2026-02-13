local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- CONFIG
local MAX_POSES = 5
local BASE_WIDTH = 390
local BASE_HEIGHT = 190
local ROW_HEIGHT = 55

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

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- Logo
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0,75,0,75)
logo.Position = UDim2.new(0,18,0,18)
logo.Text = "SKIZ"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 16
logo.TextColor3 = Color3.fromRGB(255,170,255)
logo.BackgroundColor3 = Color3.fromRGB(18,18,18)
logo.Parent = gui
Instance.new("UICorner",logo).CornerRadius = UDim.new(0,16)

local logoStroke = Instance.new("UIStroke",logo)
logoStroke.Color = Color3.fromRGB(200,0,255)
logoStroke.Thickness = 3
logoStroke.Transparency = 0.6

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

local stroke = Instance.new("UIStroke",main)
stroke.Color = Color3.fromRGB(200,0,255)
stroke.Transparency = 0.75

-- Resize
local function resize(height)
	TweenService:Create(main,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
		Size = UDim2.new(0,BASE_WIDTH,0,height)
	}):Play()
end

-- Open / Minimize
local function openUI()
	main.Visible = true
	main.Size = UDim2.new(0,0,0,0)
	resize(BASE_HEIGHT)
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

-- Tabs
local tabBar = Instance.new("Frame",main)
tabBar.Size = UDim2.new(1,-20,0,32)
tabBar.Position = UDim2.new(0,10,0,38)
tabBar.BackgroundTransparency = 1

local function makeTab(text,pos)
	local b = Instance.new("TextButton",tabBar)
	b.Size = UDim2.new(0.33,-6,1,0)
	b.Position = UDim2.new(pos,0,0,0)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(255,170,255)
	b.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
	return b
end

local tpTab = makeTab("TP To Pos",0)
local stealTab = makeTab("Stealing",0.33)
local quickTab = makeTab("Quick Panel",0.66)

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

-- Fly
local function flyTo(cf)
	TweenService:Create(getHRP(),TweenInfo.new(0.2),{CFrame = cf}):Play()
end

-- TP Boxes
local function updateTPSize()
	resize(BASE_HEIGHT + (poseCount * ROW_HEIGHT))
end

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
			flyTo(positions[i])
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
	updateTPSize()
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

createInput(stealFrame,"Speed (16-100)",16,function(v)
	getHum().WalkSpeed = math.clamp(v,16,100)
end)

createInput(stealFrame,"Gravity",196,function(v)
	workspace.Gravity = v
end)

-- Performance Mode
local perfButton = Instance.new("TextButton",stealFrame)
perfButton.Size = UDim2.new(1,0,0,40)
perfButton.Text = "Performance Mode: OFF"
perfButton.Font = Enum.Font.GothamBold
perfButton.TextSize = 12
perfButton.BackgroundColor3 = Color3.fromRGB(45,0,70)
perfButton.TextColor3 = Color3.new(1,1,1)
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
	perfButton.Text = "Performance Mode: "..(performanceEnabled and "ON" or "OFF")
end)

-- Quick Panel
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

quickButton("Reset Character",function()
	player.Character:BreakJoints()
end)

quickButton("Rejoin",function()
	TeleportService:Teleport(game.PlaceId,player)
end)

quickButton("Toggle GUI",function()
	main.Visible = not main.Visible
end)

-- Tab Switch
local function switchTab(tab)
	tpFrame.Visible = (tab=="tp")
	stealFrame.Visible = (tab=="steal")
	quickFrame.Visible = (tab=="quick")

	if tab=="tp" then
		updateTPSize()
	else
		resize(BASE_HEIGHT)
	end
end

tpTab.MouseButton1Click:Connect(function() switchTab("tp") end)
stealTab.MouseButton1Click:Connect(function() switchTab("steal") end)
quickTab.MouseButton1Click:Connect(function() switchTab("quick") end)

