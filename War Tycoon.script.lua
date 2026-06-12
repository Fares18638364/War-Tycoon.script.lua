local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- إنشاء القائمة
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 260)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

-- عنوان الحقوق
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Text = "المطور فارس"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.new(0.3, 0, 0)

-- الأزرار
local function CreateButton(text, pos)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0.15, 0); btn.Position = pos
    btn.Text = text; return btn
end

local FlyBtn = CreateButton("الطيران للبرميل الجديد", UDim2.new(0.05, 0, 0.15, 0))
local BackBtn = CreateButton("العودة للمكان الأصلي", UDim2.new(0.05, 0, 0.35, 0))
local ResetBtn = CreateButton("إعادة ضبط المواقع", UDim2.new(0.05, 0, 0.55, 0))
local BlockBtn = CreateButton("حظر المكان الحالي", UDim2.new(0.05, 0, 0.75, 0))
BlockBtn.BackgroundColor3 = Color3.new(0.6, 0, 0)

-- نظام السحب للموبايل
local dragging, dragInput, mousePos, framePos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; mousePos = input.Position; framePos = Frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - mousePos
        Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- المتغيرات
local SavedPosition = nil
local VisitedBarrels = {}
local ForbiddenZones = {}

-- دالة البحث
local function FindNewBarrel()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "MainPart" and obj:IsA("BasePart") and obj:FindFirstChild("Drop") and obj:FindFirstChild("Pickup") then
            local AlreadyVisited = false
            for _, pos in pairs(VisitedBarrels) do if (obj.Position - pos).Magnitude < 10 then AlreadyVisited = true; break end end
            local IsForbidden = false
            for _, badPos in pairs(ForbiddenZones) do if (obj.Position - badPos).Magnitude < 20 then IsForbidden = true; break end end
            if not AlreadyVisited and not IsForbidden then return obj end
        end
    end
    return nil
end

-- الأزرار
FlyBtn.MouseButton1Click:Connect(function()
    local Target = FindNewBarrel()
    if Target then
        table.insert(VisitedBarrels, Target.Position)
        SavedPosition = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        local RootPart = Players.LocalPlayer.Character.HumanoidRootPart
        TweenService:Create(RootPart, TweenInfo.new(1), {CFrame = Target.CFrame + Vector3.new(0, 1, 0)}):Play()
        task.wait(1.1)
        TweenService:Create(RootPart, TweenInfo.new(0.5), {CFrame = Target.CFrame + Vector3.new(0, 11, 0)}):Play()
        task.wait(0.6)
        local Prompt = Target:FindFirstChildOfClass("ProximityPrompt")
        if Prompt then fireproximityprompt(Prompt) end
    else FlyBtn.Text = "لا توجد براميل جديدة!" task.wait(2); FlyBtn.Text = "الطيران للبرميل الجديد" end
end)

BackBtn.MouseButton1Click:Connect(function() if SavedPosition then Players.LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition end end)
ResetBtn.MouseButton1Click:Connect(function() VisitedBarrels = {}; FlyBtn.Text = "تم إعادة الضبط" task.wait(1); FlyBtn.Text = "الطيران للبرميل الجديد" end)
BlockBtn.MouseButton1Click:Connect(function()
    if #ForbiddenZones < 6 then table.insert(ForbiddenZones, Players.LocalPlayer.Character.HumanoidRootPart.Position) BlockBtn.Text = "تم الحظر (" .. #ForbiddenZones .. "/6)"
    else BlockBtn.Text = "وصلت للحد الأقصى!" end
end)

-- Noclip
RunService.Stepped:Connect(function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CanCollide = false end
end)

