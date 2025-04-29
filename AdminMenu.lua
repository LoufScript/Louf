-- LocalScript (lägg i StarterPlayerScripts)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local flying = false
local invisible = false
local menuOpen = false
local flySpeed = 50

-- Skapa GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.5, -110, 0.5, -75)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Visible = false
frame.Parent = screenGui

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, -20, 0, 50)
flyButton.Position = UDim2.new(0, 10, 0, 10)
flyButton.BackgroundColor3 = Color3.new(0, 0, 0)
flyButton.BackgroundTransparency = 0.5
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.Text = "Fly: Off"
flyButton.TextScaled = true
flyButton.Parent = frame

local invisButton = Instance.new("TextButton")
invisButton.Size = UDim2.new(1, -20, 0, 50)
invisButton.Position = UDim2.new(0, 10, 0, 70)
invisButton.BackgroundColor3 = Color3.new(0, 0, 0)
invisButton.BackgroundTransparency = 0.5
invisButton.TextColor3 = Color3.new(1, 1, 1)
invisButton.Font = Enum.Font.SourceSansBold
invisButton.Text = "Invisible: Off"
invisButton.TextScaled = true
invisButton.Parent = frame

-- Variabler för flygning
local bodyGyro
local bodyVelocity
local flyingConnection

local control = {
    Forward = 0,
    Backward = 0,
    Left = 0,
    Right = 0,
    Up = 0,
    Down = 0
}

-- Hantera flygkontroller
UserInputService.InputBegan:Connect(function(input, isTyping)
    if isTyping then return end
    if input.KeyCode == Enum.KeyCode.W then
        control.Forward = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        control.Backward = 1
    elseif input.KeyCode == Enum.KeyCode.A then
        control.Left = 1
    elseif input.KeyCode == Enum.KeyCode.D then
        control.Right = 1
    elseif input.KeyCode == Enum.KeyCode.Space then
        control.Up = 1
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        control.Down = 1
    elseif input.KeyCode == Enum.KeyCode.Q then
        menuOpen = not menuOpen
        frame.Visible = menuOpen
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        control.Forward = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        control.Backward = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        control.Left = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        control.Right = 0
    elseif input.KeyCode == Enum.KeyCode.Space then
        control.Up = 0
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        control.Down = 0
    end
end)

-- Flyg-funktion
local function startFlying()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = humanoidRootPart

    flyingConnection = RunService.RenderStepped:Connect(function()
        local moveDirection = Vector3.new(
            control.Right - control.Left,
            control.Up - control.Down,
            control.Forward - control.Backward
        )

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end

        local cameraCFrame = workspace.CurrentCamera.CFrame
        local moveVector = (cameraCFrame.RightVector * moveDirection.X + cameraCFrame.UpVector * moveDirection.Y + cameraCFrame.LookVector * moveDirection.Z)

        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        bodyVelocity.Velocity = moveVector * flySpeed
    end)
end

local function stopFlying()
    if bodyGyro then
        bodyGyro:Destroy()
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
    if flyingConnection then
        flyingConnection:Disconnect()
    end
end

-- Gör spelaren osynlig
local function setInvisible(state)
    local character = LocalPlayer.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = state and 1 or 0
        end
    end
end

-- Klick på flyg-knappen
flyButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyButton.Text = "Fly: On"
        startFlying()
    else
        flyButton.Text = "Fly: Off"
        stopFlying()
    end
end)

-- Klick på osynlig-knappen
invisButton.MouseButton1Click:Connect(function()
    invisible = not invisible
    if invisible then
        invisButton.Text = "Invisible: On"
        setInvisible(true)
    else
        invisButton.Text = "Invisible: Off"
        setInvisible(false)
    end
end)
