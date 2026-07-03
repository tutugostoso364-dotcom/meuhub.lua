-- FPS HUB MOBILE PRO - VERSÃO 6.2 (Gun Lock + Hitbox Permanente)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Inicializando...", LoadingSubtitle = "V6.2 - Precision"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

local aimOn = false
local gunLockOn = false
local hitboxOn = false
local flingOn = false

------------------------------------------------
-- VISUAL: HITBOX RGB (PERMANENTE)
------------------------------------------------
local function applyHighlight(char)
    if not char:FindFirstChild("Highlight") then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = char
        task.spawn(function()
            while hl.Parent do
                local hue = tick() % 5 / 5
                hl.FillColor = Color3.fromHSV(hue, 1, 1)
                hl.OutlineColor = Color3.fromHSV(hue, 1, 1)
                task.wait(0.1)
            end
        end)
    end
end

VisualTab:CreateToggle({Name = "🌈 RGB Permanente", CurrentValue = false, Callback = function(v) hitboxOn = v end})

-- Loop de verificação constante para nunca perder a hitbox
RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                applyHighlight(p.Character)
            end
        end
    end
end)

------------------------------------------------
-- AIMBOT & GUN LOCK
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Aimbot Suave", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "🔫 Gun Lock (Mira da Arma)", CurrentValue = false, Callback = function(v) gunLockOn = v end})

RunService.RenderStepped:Connect(function()
    local closest, dist = nil, 500
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
            if onScreen and mag < dist then closest = p.Character.HumanoidRootPart; dist = mag end
        end
    end

    if closest then
        if aimOn then
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15)
        end
        -- Força o seu personagem (e a arma) a olhar para o inimigo
        if gunLockOn and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.Position, Vector3.new(closest.Position.X, player.Character.HumanoidRootPart.Position.Y, closest.Position.Z))
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
                local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    local voidHeight = workspace.FallenPartsDestroyHeight
                    local targetPos = Vector3.new(root.Position.X, voidHeight - 50, root.Position.Z)
                    local direction = (targetPos - root.Position).Unit
                    local att = Instance.new("Attachment", root)
                    local vel = Instance.new("LinearVelocity", root)
                    vel.MaxForce = Vector3.new(1,1,1) * 999999999
                    vel.VectorVelocity = direction * 500
                    vel.Attachment0 = att
                    game:GetService("Debris"):AddItem(vel, 0.4)
                    game:GetService("Debris"):AddItem(att, 0.4)
                    p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end
    end
end)

print("FPS HUB MOBILE PRO V6.2 Carregado!")
