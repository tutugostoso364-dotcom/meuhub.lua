-- FPS HUB MOBILE PRO - V6.4 (FIXED: RGB, LOCK, WALLBANG)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Corrigindo...", LoadingSubtitle = "V6.4 - Final Fix"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

local aimOn, gunLockOn, wallBangOn, hitboxOn, flingOn = false, false, false, false, false

------------------------------------------------
-- VISUAL: HITBOX RGB (FIXO)
------------------------------------------------
local function applyHighlight(char)
    if not char:FindFirstChild("Highlight") then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = char
    end
end

RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                applyHighlight(p.Character)
                -- Garante o efeito RGB constante
                local hl = p.Character:FindFirstChild("Highlight")
                if hl then
                    local hue = tick() % 5 / 5
                    hl.FillColor = Color3.fromHSV(hue, 1, 1)
                    hl.OutlineColor = Color3.fromHSV(hue, 1, 1)
                end
            end
        end
    end
end)

VisualTab:CreateToggle({Name = "🌈 RGB Permanente", CurrentValue = false, Callback = function(v) hitboxOn = v end})

------------------------------------------------
-- AIMBOT: GUN LOCK & WALLBANG
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Aimbot Suave", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "🔒 Lock Automático (Grudar)", CurrentValue = false, Callback = function(v) gunLockOn = v end})
AimTab:CreateToggle({Name = "🧱 Balas Atravessam Paredes", CurrentValue = false, Callback = function(v) wallBangOn = v end})

RunService.RenderStepped:Connect(function()
    local closest, dist = nil, 9999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            
            -- Se WallBang estiver on, ignoramos barreira visual
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
            if (onScreen or wallBangOn) and mag < dist then 
                closest = root; dist = mag 
            end
        end
    end

    if closest and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if aimOn then
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15)
        end
        -- O GunLock agora força o seu personagem a girar instantaneamente
        if gunLockOn then
            local targetPos = Vector3.new(closest.Position.X, player.Character.HumanoidRootPart.Position.Y, closest.Position.Z)
            player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.Position, targetPos)
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
                    vel.VectorVelocity = Vector3.new(0, -500, 0) -- Força bruta para o Void
                    game:GetService("Debris"):AddItem(vel, 0.5)
                    p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end
    end
end)

print("FPS HUB MOBILE PRO V6.4 Carregado!")
