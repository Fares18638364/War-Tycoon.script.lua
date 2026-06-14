local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService") -- للتحكم بالريسبون

local SKIP_URL = "https://raw.githubusercontent.com/Fares18638364/Skip.script.lua/refs/heads/main/Skip.Script.lua"

-- [القائمة والأزرار نفس الكود السابق تماماً...]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 220); Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0.15, 0); Title.Text = " سكربت و حقوق المطور فارس"
Title.TextColor3 = Color3.new(1, 1, 1); Title.BackgroundColor3 = Color3.new(0.3, 0, 0)
local AutoBtn = Instance.new("TextButton", Frame)
AutoBtn.Size = UDim2.new(0.9, 0, 0.2, 0); AutoBtn.Position = UDim2.new(0.05, 0, 0.2, 0); AutoBtn.Text = "تشغيل أوتو فارم"
local ResetBtn = Instance.new("TextButton", Frame)
ResetBtn.Size = UDim2.new(0.9, 0, 0.2, 0); ResetBtn.Position = UDim2.new(0.05, 0, 0.45, 0); ResetBtn.Text = "إعادة ضبط المواقع"
local BlockBtn = Instance.new("TextButton", Frame)
BlockBtn.Size = UDim2.new(0.9, 0, 0.2, 0); BlockBtn.Position = UDim2.new(0.05, 0, 0.7, 0); BlockBtn.Text = "حظر المكان"; BlockBtn.BackgroundColor3 = Color3.new(0.6, 0, 0)

local IsAutoRunning = false
local VisitedBarrels, ForbiddenZones = {}, {}

-- [نظام السحب]
local dragging, mousePos, framePos
Frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then dragging = true; mousePos = input.Position; framePos = Frame.Position end end)
UIS.InputChanged:Connect(function(input) if dragging then local delta = input.Position - mousePos; Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function() dragging = false end)

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

-- [نظام الموت والريسبون]
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if IsAutoRunning then -- إذا كان الأوتو فارم شغال، يكمل بعد الريسبون
        task.wait(1)
        -- إعادة ضبط الـ Noclip
        char:WaitForChild("HumanoidRootPart").CanCollide = false
    end
end)

AutoBtn.MouseButton1Click:Connect(function()
    IsAutoRunning = not IsAutoRunning
    AutoBtn.Text = IsAutoRunning and "إيقاف أوتو فارم" or "تشغيل أوتو فارم"
    
    if IsAutoRunning then
        local SavedPosition = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        
        while IsAutoRunning do
            local char = Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                IsAutoRunning = false -- إيقاف الأوتو
                task.wait(0.5)
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Dead) -- تفعيل الريسبون
                task.wait(2) -- انتظار للرسبون
                IsAutoRunning = true -- إعادة التشغيل
            end
            
            local Target = FindNewBarrel()
            if Target then
                table.insert(VisitedBarrels, Target.Position)
                local RootPart = char.HumanoidRootPart
                TweenService:Create(RootPart, TweenInfo.new(1), {CFrame = Target.CFrame + Vector3.new(0, 1, 0)}):Play()
                task.wait(1.1)
                loadstring(game:HttpGet(SKIP_URL))()
                if char:FindFirstChild("Humanoid") then char.Humanoid.Health = math.min(char.Humanoid.Health + 5, char.Humanoid.MaxHealth) end
                task.wait(0.5)
                TweenService:Create(RootPart, TweenInfo.new(1), {CFrame = SavedPosition}):Play()
                task.wait(1.1)
                loadstring(game:HttpGet(SKIP_URL))()
                task.wait(0.5)
            else
                task.wait(0.5)
            end
        end
    end
end)

-- [باقي الدوال]
ResetBtn.MouseButton1Click:Connect(function() VisitedBarrels = {}; AutoBtn.Text = "تم إعادة الضبط" task.wait(1); AutoBtn.Text = "تشغيل أوتو فارم" end)
BlockBtn.MouseButton1Click:Connect(function() table.insert(ForbiddenZones, Players.LocalPlayer.Character.HumanoidRootPart.Position); BlockBtn.Text = "تم الحظر" end)
RunService.Stepped:Connect(function() local char = Players.LocalPlayer.Character if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CanCollide = false end end)
