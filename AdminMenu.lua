-- AdminV2 Menu with Fly, Invisible, Noclip, and Color Changer

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local flying = false
local invisible = false
local noclip = false
local menuOpen = false
local flySpeed = 50

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 260)
frame.Position = UDim2.new(0.5, -120, 0.5, -130)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local function createButton(text, yPosition)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 40)
	button.Position = UDim2.new(0, 10, 0, yPosition)
	button.BackgroundColor3 = Color3.new(0, 0, 0)
	button.BackgroundTransparency = 0.5
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextScaled = true
	button.Text = text
	button.Parent = frame
	return button
end

local flyButton = createButton("Fly: Off", 10)
local invisButton = createButton("Invisible: Off", 60)
local noclipButton = createButton("Noclip: Off", 110)

-- Color dropdown
local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, -20, 0, 25)
colorLabel.Position = UDim2.new(0, 10, 0, 165)
colorLabel.BackgroundTransparency = 1
colorLabel.TextColor3 = Color3.new(1, 1, 1)
colorLabel.Font = Enum.Font.SourceSansBold
colorLabel.TextScaled = true
colorLabel.Text = "Menu Color:"
colorLabel.Parent = frame

local colorDropdown = Instance.new("TextButton")
colorDropdown.Size = UDim2.new(1, -20, 0, 40)
colorDropdown.Position = UDim2.new(0, 10, 0, 195)
colorDropdown.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
colorDropdown.TextColor3 = Color3.new(1, 1, 1)
colorDropdown.TextScaled = true
colorDropdown.Font = Enum.Font.SourceSansBold
colorDropdown.Text = "Black"
colorDropdown.Parent = frame

local colors = {
	["Red"] = Color3.fromRGB(170, 0, 0),
	["Green"] = Color3.fromRGB(0, 170, 0),
	["Blue"] = Color3.fromRGB(0, 85, 255),
	["Purple"] = Color3.fromRGB(85, 0, 127),
	["Black"] = Color3.fromRGB(0, 0, 0)
}
local colorList = {"Red", "Green", "Blue", "Purple", "Black"}
local currentIndex = 5

colorDropdown.MouseButton1Click:Connect(function()
	currentIndex = currentIndex + 1
	if currentIndex > #colorList then currentIndex = 1 end
	local name = colorList[currentIndex]
	colorDropdown.Text = name
	frame.BackgroundColor3 = colors[name]
end)

-- Flight setup
local bodyGyro
local bodyVelocity
local flyingConnection
local control = { Forward = 0, Backward = 0, Left = 0, Right = 0, Up = 0, Down = 0 }

local function startFlying()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:WaitForChild("HumanoidRootPart")

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Parent = root

	flyingConnection = RunService.RenderStepped:Connect(function()
		local moveDir = Vector3.new(
			control.Right - control.Left,
			control.Up - control.Down,
			control.Forward - control.Backward
		)

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit
		end

		local cam = workspace.CurrentCamera.CFrame
		local vec = (cam.RightVector * moveDir.X + cam.UpVector * moveDir.Y + cam.LookVector * moveDir.Z)
		bodyGyro.CFrame = cam
		bodyVelocity.Velocity = vec * flySpeed
	end)
end

local function stopFlying()
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
	if flyingConnection then flyingConnection:Disconnect() end
end

-- Noclip loop
RunService.Stepped:Connect(function()
	if noclip then
		local char = LocalPlayer.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- Invisibility toggle
local function setInvisible(state)
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			part.Transparency = state and 1 or 0
		end
	end
end

-- Controls
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.W then control.Forward = 1
	elseif input.KeyCode == Enum.KeyCode.S then control.Backward = 1
	elseif input.KeyCode == Enum.KeyCode.A then control.Left = 1
	elseif input.KeyCode == Enum.KeyCode.D then control.Right = 1
	elseif input.KeyCode == Enum.KeyCode.Space then control.Up = 1
	elseif input.KeyCode == Enum.KeyCode.LeftControl then control.Down = 1
	elseif input.KeyCode == Enum.KeyCode.Q then
		menuOpen = not menuOpen
		frame.Visible = menuOpen
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then control.Forward = 0
	elseif input.KeyCode == Enum.KeyCode.S then control.Backward = 0
	elseif input.KeyCode == Enum.KeyCode.A then control.Left = 0
	elseif input.KeyCode == Enum.KeyCode.D then control.Right = 0
	elseif input.KeyCode == Enum.KeyCode.Space then control.Up = 0
	elseif input.KeyCode == Enum.KeyCode.LeftControl then control.Down = 0
	end
end)

-- Button actions
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	flyButton.Text = "Fly: " .. (flying and "On" or "Off")
	if flying then startFlying() else stopFlying() end
end)

invisButton.MouseButton1Click:Connect(function()
	invisible = not invisible
	invisButton.Text = "Invisible: " .. (invisible and "On" or "Off")
	setInvisible(invisible)
end)

noclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipButton.Text = "Noclip: " .. (noclip and "On" or "Off")
end)

