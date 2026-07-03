-- FPS HUB MOBILE PRO - V7.0 (Aimbot Smooth Lock + Wall-Bypass)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Otimizando...", LoadingSubtitle = "V7.0 - Smooth Lock"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

local aimOn, lockOn, wallBangOn, hitboxOn, flingOn = false, false, false, false, false

------------------------------------------------
-- VISUAL: HITBOX RGB
------------------------------------------------
VisualTab:CreateToggle({Name = "🌈 RGB Permanente", CurrentValue = false, Callback = function(v) hitboxOn = v end})

RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.FillTransparency = 0.4
                end
                local hl = p.Character.Highlight
                local hue = tick() % 5 / 5
                hl.FillColor = Color3.fromHSV(hue, 1, 1)
                hl.OutlineColor = Color3.fromHSV(hue, 1, 1)
            end
        end
    end
end)

------------------------------------------------
-- AIMBOT: Suave & Lock + Wall Bypass
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Aimbot Suave (Lock Automático)", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "🧱 Balas Atravessam Paredes", CurrentValue = false, Callback = function(v) wallBangOn = v end})

RunService.RenderStepped:Connect(function()
    if not aimOn then return end
    
    local closest, dist = nil, 9999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
            
            if (onScreen or wallBangOn) and mag < dist then 
                closest = root; dist = mag 
            end
        end
    end

    if closest then
        -- Mira Suave que Gruda (Sem tremer, para não bugar as balas)
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closest.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.1) -- 0.1 é a suavidade ideal
        
        -- Bypass de Colisão (Wallbang)
        if wallBangOn then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide and obj.Name ~= "Terrain" and not obj:IsDescendantOf(player.Character) then
                    obj.CanCollide = false
                end
            end
        end
    end
end)

------------------------------------------------
-- COMBAT: ARREMESSO EXTREMO
------------------------------------------------
CombatTab:CreateToggle({Name = "🥊 Arremessar Extremo", CurrentValue = false, Callback = function(v) flingOn = v end})

UserInputService.InputBegan:Connect(function(input, gpe)
    if not flingOn or gpe then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                if (root.Position - player.Character.HumanoidRootPart.Position).Magnitude < 25 then
                    local vel = Instance.new("LinearVelocity", root)
                    vel.MaxForce = Vector3.new(1,1,1) * 999999999
                    vel.VectorVelocity = Vector3.new(0, -500, 0)
                    game:GetService("Debris"):AddItem(vel, 0.5)
                    p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end
    end
end)

print("FPS HUB MOBILE PRO V7.0 Carregado!")
