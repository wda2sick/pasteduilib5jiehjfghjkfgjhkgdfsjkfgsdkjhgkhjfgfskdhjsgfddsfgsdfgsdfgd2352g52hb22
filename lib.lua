local Library = {}
Library.Tabs = {}
Library.ActiveToggles = {}
Library.AccentColor1 = Color3.fromRGB(137, 207, 240)
Library.AccentColor2 = Color3.fromRGB(0, 255, 255)
Library.ClickGuiEnabled = true
Library.ArrayListEnabled = true

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LibraryGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

local GradientFrame = Instance.new("Frame")
GradientFrame.Name = "BottomGradient"
GradientFrame.Size = UDim2.new(1, 0, 0.33, 0)
GradientFrame.Position = UDim2.new(0, 0, 0.67, 0)
GradientFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
GradientFrame.BorderSizePixel = 0
GradientFrame.ZIndex = 1
GradientFrame.Parent = ScreenGui

local GradientTransparency = Instance.new("UIGradient")
GradientTransparency.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.5),
    NumberSequenceKeypoint.new(1, 1)
})
GradientTransparency.Rotation = 90
GradientTransparency.Parent = GradientFrame

local ArrayListFrame = Instance.new("Frame")
ArrayListFrame.Name = "ArrayList"
ArrayListFrame.Size = UDim2.new(0, 200, 0, 0)
ArrayListFrame.Position = UDim2.new(1, -210, 0, 10)
ArrayListFrame.BackgroundTransparency = 1
ArrayListFrame.ZIndex = 10
ArrayListFrame.Parent = ScreenGui

local ArrayListLayout = Instance.new("UIListLayout")
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ArrayListLayout.Parent = ArrayListFrame

local function CreateGlow(parent)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.Image = "rbxasset://textures/ui/Glow.png"
    glow.ImageColor3 = Library.AccentColor1
    glow.ImageTransparency = 0.7
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

local function CreateDropShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.Image = "rbxasset://textures/ui/Shadow.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function TweenGradientFill(frame, duration, callback)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(Library.AccentColor1, Library.AccentColor2)
    gradient.Rotation = 0
    gradient.Offset = Vector2.new(-1, 0)
    gradient.Parent = frame
    
    local tween = TweenService:Create(gradient, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Offset = Vector2.new(0, 0)
    })
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
end

local function UpdateArrayList()
    if not Library.ArrayListEnabled then
        ArrayListFrame.Visible = false
        return
    end
    ArrayListFrame.Visible = true
    
    for _, child in pairs(ArrayListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local sortedToggles = {}
    for name, state in pairs(Library.ActiveToggles) do
        if state then
            table.insert(sortedToggles, name)
        end
    end
    
    table.sort(sortedToggles, function(a, b)
        return #a > #b
    end)
    
    for i, name in ipairs(sortedToggles) do
        local item = Instance.new("Frame")
        item.Name = name
        item.Size = UDim2.new(1, 0, 0, 25)
        item.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        item.BorderSizePixel = 0
        item.LayoutOrder = i
        item.Parent = ArrayListFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = item
        
        CreateGlow(item)
        CreateDropShadow(item)
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new(Library.AccentColor1, Library.AccentColor2)
        gradient.Rotation = 0
        gradient.Parent = item
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = item
    end
end

function Library:Notify(name, content, duration)
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(1, -310, 1, -90)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notif.BackgroundTransparency = 0.3
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    notif.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    CreateDropShadow(notif)
    
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "Fill"
    fillFrame.Size = UDim2.new(0, 0, 1, 0)
    fillFrame.BackgroundColor3 = Library.AccentColor1
    fillFrame.BorderSizePixel = 0
    fillFrame.ZIndex = 101
    fillFrame.Parent = notif
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 8)
    fillCorner.Parent = fillFrame
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new(Library.AccentColor1, Library.AccentColor2)
    fillGradient.Rotation = 0
    fillGradient.Parent = fillFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 102
    titleLabel.Parent = notif
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -10, 1, -30)
    contentLabel.Position = UDim2.new(0, 5, 0, 25)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 13
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.ZIndex = 102
    contentLabel.Parent = notif
    
    local fillTween = TweenService:Create(fillFrame, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, 0, 1, 0)
    })
    fillTween:Play()
    
    fillTween.Completed:Connect(function()
        local fadeOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

function Library:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name
    tabFrame.Size = UDim2.new(0, 400, 0, 500)
    tabFrame.Position = UDim2.new(0.5, -200 + (#Library.Tabs * 50), 0.5, -250)
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabFrame.BorderSizePixel = 0
    tabFrame.ZIndex = 5
    tabFrame.ClipsDescendants = true
    tabFrame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = tabFrame
    
    CreateDropShadow(tabFrame)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Parent = tabFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 10)
    headerBottom.Position = UDim2.new(0, 0, 1, -10)
    headerBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    headerBottom.BorderSizePixel = 0
    headerBottom.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = tabFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = content
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = tabFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            tabFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    tabFrame.Scale = 0
    tabFrame.Size = UDim2.new(0, 0, 0, 0)
    tabFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(tabFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 500),
        Position = UDim2.new(0.5, -200 + (#Library.Tabs * 50), 0.5, -250)
    })
    
    local blurTween = TweenService:Create(BlurEffect, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = 15
    })
    
    openTween:Play()
    blurTween:Play()
    
    tab.Frame = tabFrame
    tab.Content = content
    
    function tab:AddToggle(config)
        local toggleName = config.Name or "Toggle"
        local default = config.Default or false
        local callback = config.Callback or function() end
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = toggleName
        toggleFrame.Size = UDim2.new(1, 0, 0, 35)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = content
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(1, 0, 0, 35)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -50, 1, 0)
        toggleLabel.Position = UDim2.new(0, 10, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = toggleName
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.TextSize = 14
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Name = "Indicator"
        toggleIndicator.Size = UDim2.new(0, 30, 0, 15)
        toggleIndicator.Position = UDim2.new(1, -40, 0.5, -7.5)
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleIndicator.BorderSizePixel = 0
        toggleIndicator.Parent = toggleFrame
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 8)
        indicatorCorner.Parent = toggleIndicator
        
        local expandFrame = Instance.new("Frame")
        expandFrame.Name = "Expand"
        expandFrame.Size = UDim2.new(1, 0, 0, 0)
        expandFrame.Position = UDim2.new(0, 0, 1, 0)
        expandFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        expandFrame.BorderSizePixel = 0
        expandFrame.ClipsDescendants = true
        expandFrame.Visible = false
        expandFrame.Parent = toggleFrame
        
        local expandLayout = Instance.new("UIListLayout")
        expandLayout.SortOrder = Enum.SortOrder.LayoutOrder
        expandLayout.Padding = UDim.new(0, 5)
        expandLayout.Parent = expandFrame
        
        local expanded = false
        local state = default
        
        if default then
            toggleIndicator.BackgroundColor3 = Library.AccentColor1
            TweenGradientFill(toggleIndicator, 0.5)
            Library.ActiveToggles[toggleName] = true
            UpdateArrayList()
        end
        
        local function updateToggle(newState)
            state = newState
            callback(state)
            
            if state then
                toggleIndicator.BackgroundColor3 = Library.AccentColor1
                TweenGradientFill(toggleIndicator, 0.5)
                Library.ActiveToggles[toggleName] = true
            else
                for _, child in pairs(toggleIndicator:GetChildren()) do
                    if child:IsA("UIGradient") then
                        child:Destroy()
                    end
                end
                TweenService:Create(toggleIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                }):Play()
                Library.ActiveToggles[toggleName] = false
            end
            UpdateArrayList()
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            updateToggle(not state)
        end)
        
        toggleButton.MouseButton2Click:Connect(function()
            expanded = not expanded
            expandFrame.Visible = expanded
            
            if expanded then
                expandLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    expandFrame.Size = UDim2.new(1, 0, 0, expandLayout.AbsoluteContentSize.Y + 10)
                    toggleFrame.Size = UDim2.new(1, 0, 0, 35 + expandLayout.AbsoluteContentSize.Y + 10)
                end)
                expandFrame.Size = UDim2.new(1, 0, 0, expandLayout.AbsoluteContentSize.Y + 10)
                toggleFrame.Size = UDim2.new(1, 0, 0, 35 + expandLayout.AbsoluteContentSize.Y + 10)
            else
                expandFrame.Size = UDim2.new(1, 0, 0, 0)
                toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            end
        end)
        
        local toggleObj = {
            Frame = toggleFrame,
            ExpandFrame = expandFrame,
            State = state,
            UpdateToggle = updateToggle
        }
        
        function toggleObj:AddSlider(sliderConfig)
            local sliderName = sliderConfig.Name or "Slider"
            local sliderDefault = sliderConfig.Default or 0
            local sliderMin = sliderConfig.Min or 0
            local sliderMax = sliderConfig.Max or 100
            local sliderCallback = sliderConfig.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -10, 0, 40)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = expandFrame
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, -10, 0, 15)
            sliderLabel.Position = UDim2.new(0, 5, 0, 2)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName .. ": " .. sliderDefault
            sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sliderLabel.TextSize = 12
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, -10, 0, 6)
            sliderBar.Position = UDim2.new(0, 5, 1, -12)
            sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderFrame
            
            local sliderBarCorner = Instance.new("UICorner")
            sliderBarCorner.CornerRadius = UDim.new(0, 3)
            sliderBarCorner.Parent = sliderBar
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
            sliderFill.BackgroundColor3 = Library.AccentColor1
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(0, 3)
            sliderFillCorner.Parent = sliderFill
            
            local sliderFillGradient = Instance.new("UIGradient")
            sliderFillGradient.Color = ColorSequence.new(Library.AccentColor1, Library.AccentColor2)
            sliderFillGradient.Rotation = 0
            sliderFillGradient.Parent = sliderFill
            
            local draggingSlider = false
            local currentValue = sliderDefault
            
            local function updateSlider(input)
                local pos = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                pos = math.clamp(pos, 0, 1)
                currentValue = math.floor(sliderMin + (sliderMax - sliderMin) * pos)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                sliderLabel.Text = sliderName .. ": " .. currentValue
                sliderCallback(currentValue)
            end
            
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    updateSlider(input)
                end
            end)
            
            sliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
        end
        
        function toggleObj:AddColorPicker(pickerConfig)
            local pickerName = pickerConfig.Name or "Color"
            local pickerDefault = pickerConfig.Default or Color3.fromRGB(255, 255, 255)
            local pickerCallback = pickerConfig.Callback or function() end
            
            local pickerFrame = Instance.new("Frame")
            pickerFrame.Size = UDim2.new(1, -10, 0, 30)
            pickerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            pickerFrame.BorderSizePixel = 0
            pickerFrame.Parent = expandFrame
            
            local pickerCorner = Instance.new("UICorner")
            pickerCorner.CornerRadius = UDim.new(0, 6)
            pickerCorner.Parent = pickerFrame
            
            local pickerLabel = Instance.new("TextLabel")
            pickerLabel.Size = UDim2.new(1, -40, 1, 0)
            pickerLabel.Position = UDim2.new(0, 5, 0, 0)
            pickerLabel.BackgroundTransparency = 1
            pickerLabel.Text = pickerName
            pickerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            pickerLabel.TextSize = 12
            pickerLabel.Font = Enum.Font.Gotham
            pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
            pickerLabel.Parent = pickerFrame
            
            local colorDisplay = Instance.new("Frame")
            colorDisplay.Size = UDim2.new(0, 25, 0, 20)
            colorDisplay.Position = UDim2.new(1, -30, 0.5, -10)
            colorDisplay.BackgroundColor3 = pickerDefault
            colorDisplay.BorderSizePixel = 0
            colorDisplay.Parent = pickerFrame
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 4)
            colorCorner.Parent = colorDisplay
            
            local colorButton = Instance.new("TextButton")
            colorButton.Size = UDim2.new(1, 0, 1, 0)
            colorButton.BackgroundTransparency = 1
            colorButton.Text = ""
            colorButton.Parent = pickerFrame
            
            colorButton.MouseButton1Click:Connect(function()
                local h, s, v = pickerDefault:ToHSV()
                local newColor = Color3.fromHSV(math.random(), 1, 1)
                colorDisplay.BackgroundColor3 = newColor
                pickerCallback(newColor)
            end)
        end
        
        function toggleObj:AddSubToggle(subConfig)
            local subName = subConfig.Name or "SubToggle"
            local subDefault = subConfig.Default or false
            local subCallback = subConfig.Callback or function() end
            
            local subFrame = Instance.new("Frame")
            subFrame.Size = UDim2.new(1, -10, 0, 30)
            subFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            subFrame.BorderSizePixel = 0
            subFrame.Parent = expandFrame
            
            local subCorner = Instance.new("UICorner")
            subCorner.CornerRadius = UDim.new(0, 6)
            subCorner.Parent = subFrame
            
            local subButton = Instance.new("TextButton")
            subButton.Size = UDim2.new(1, 0, 1, 0)
            subButton.BackgroundTransparency = 1
            subButton.Text = ""
            subButton.Parent = subFrame
            
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(1, -40, 1, 0)
            subLabel.Position = UDim2.new(0, 5, 0, 0)
            subLabel.BackgroundTransparency = 1
            subLabel.Text = subName
            subLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            subLabel.TextSize = 12
            subLabel.Font = Enum.Font.Gotham
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.Parent = subFrame
            
            local subIndicator = Instance.new("Frame")
            subIndicator.Name = "Indicator"
            subIndicator.Size = UDim2.new(0, 25, 0, 12)
            subIndicator.Position = UDim2.new(1, -30, 0.5, -6)
            subIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            subIndicator.BorderSizePixel = 0
            subIndicator.Parent = subFrame
            
            local subIndicatorCorner = Instance.new("UICorner")
            subIndicatorCorner.CornerRadius = UDim.new(0, 6)
            subIndicatorCorner.Parent = subIndicator
            
            local subState = subDefault
            
            if subDefault then
                subIndicator.BackgroundColor3 = Library.AccentColor1
                TweenGradientFill(subIndicator, 0.5)
            end
            
            subButton.MouseButton1Click:Connect(function()
                subState = not subState
                subCallback(subState)
                
                if subState then
                    subIndicator.BackgroundColor3 = Library.AccentColor1
                    TweenGradientFill(subIndicator, 0.5)
                else
                    for _, child in pairs(subIndicator:GetChildren()) do
                        if child:IsA("UIGradient") then
                            child:Destroy()
                        end
                    end
                    TweenService:Create(subIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    }):Play()
                end
            end)
        end
        
        return toggleObj
    end
    
    table.insert(Library.Tabs, tab)
    return tab
end

function Library:BuildThemeSettings(tab)
    local clickGuiToggle = tab:AddToggle({
        Name = "Click GUI",
        Default = true,
        Callback = function(v)
            Library.ClickGuiEnabled = v
            for _, tabData in pairs(Library.Tabs) do
                tabData.Frame.Visible = v
            end
            if v then
                TweenService:Create(BlurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = 15}):Play()
                GradientFrame.Visible = true
            else
                TweenService:Create(BlurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = 0}):Play()
                GradientFrame.Visible = false
            end
        end
    })
    
    clickGuiToggle:AddColorPicker({
        Name = "Accent Color 1",
        Default = Library.AccentColor1,
        Callback = function(v)
            Library.AccentColor1 = v
            UpdateArrayList()
        end
    })
    
    clickGuiToggle:AddColorPicker({
        Name = "Accent Color 2",
        Default = Library.AccentColor2,
        Callback = function(v)
            Library.AccentColor2 = v
            UpdateArrayList()
        end
    })
    
    tab:AddToggle({
        Name = "ArrayList",
        Default = true,
        Callback = function(v)
            Library.ArrayListEnabled = v
            UpdateArrayList()
        end
    })
end

function Library:BuildKeybindSettings(tab)
    local keybindToggle = tab:AddToggle({
        Name = "Keybinds",
        Default = false,
        Callback = function(v)
            print("Keybinds:", v)
        end
    })
end

return Library
