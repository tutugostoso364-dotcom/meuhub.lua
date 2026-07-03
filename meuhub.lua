-- FPS HUB MOBILE PRO - VERSÃO COMPLETA E ATUALIZADA
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Inicializando...", LoadingSubtitle = "V6 - Full Features"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

local aimOn = false
local aimLockOn = false -- Nova variável para o Lock Instantâneo
local hitboxOn = false
local flingOn = false

------------------------------------------------
-- VISUAL: HITBOX RGB
------------------------------------------------
local function applyHighlight(char)
    if char and not char:FindFirstChild("Highlight") then
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

VisualTab:CreateToggle({Name = "🌈 RGB em Todos", CurrentValue = false, Callback = function(v) 
    hitboxOn = v 
    if v then for _, p in pairs(Players:GetPlayers()) do if p.Character then applyHighlight(p.Character) end end end
end})

------------------------------------------------
-- AIMBOT: Opções de Suavização e Lock
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Aimbot Suave (Original)", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "🔒 Lock Automático (Grudar)", CurrentValue = false, Callback = function(v) aimLockOn = v end})

RunService.RenderStepped:Connect(function()
    local closest, dist = nil, 500
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                if onScreen and mag < dist then closest = p.Character.HumanoidRootPart; dist = mag end
            end
        end
    end

    if closest then
        -- Função 1: Aimbot Suave (Original)
        if aimOn then
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15)
        end
        -- Função 2: Lock Instantâneo (Nova)
        if aimLockOn then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, closest.Position)
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
                    local att = Instance.new("Attachment", root)
                    local vel = Instance.new("LinearVelocity", root)
                    vel.MaxForce = Vector3.new(1,1,1) * 999999999
                    vel.VectorVelocity = (root.Position - player.Character.HumanoidRootPart.Position).Unit * 200 + Vector3.new(0, 75, 0)
                    vel.Attachment0 = att
                    game:GetService("Debris"):AddItem(vel, 0.4)
                    game:GetService("Debris"):AddItem(att, 0.4)
                    p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end
    end
end)

print("FPS HUB MOBILE PRO V6.1 Carregado!")
