-- FPS HUB MOBILE PRO - V6.5 (Advanced Lock + Collision Bypass)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Ajustando...", LoadingSubtitle = "V6.5 - Pro Logic"})
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
        hl.Parent = char
    end
end

RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                applyHighlight(p.Character)
                local hl = p.Character:FindFirstChild("Highlight")
                if hl then
                    local hue = tick() % 5 / 5
                    hl.FillColor = Color3.fromHSV(hue, 1, 1)
                end
            end
        end
    end
end)

VisualTab:CreateToggle({Name = "🌈 RGB Permanente", CurrentValue = false, Callback = function(v) hitboxOn = v end})

------------------------------------------------
-- AIMBOT: SUAVE + LOCK AUTOMÁTICO
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Lock Suave Automático", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "🧱 Balas Mágicas (No Floor Damage)", CurrentValue = false, Callback = function(v) wallBangOn = v end})

RunService.RenderStepped:Connect(function()
    if not aimOn then return end
    
    local closest, dist = nil, 9999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local mag = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then closest = root; dist = mag end
        end
    end

    if closest then
        -- Lógica: Suavização (Lerp) para não bugar as balas
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closest.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.2) -- 0.2 é o equilíbrio entre rapidez e suavidade
    end
end)

------------------------------------------------
-- BALAS MÁGICAS (Wall Penetration)
------------------------------------------------
-- Esta lógica altera o RaycastParams para ignorar objetos que não são o chão
RunService.RenderStepped:Connect(function()
    if wallBangOn then
        for _, obj in pairs(workspace:GetDescendants()) do
            -- Se for uma parede ou obstáculo (BasePart) mas não for o Chão (Floor/Ground)
            if obj:IsA("BasePart") and obj.CanCollide == true then
                if not string.match(obj.Name:lower(), "floor") and not string.match(obj.Name:lower(), "ground") and not string.match(obj.Name:lower(), "baseplate") then
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
-- ... (mantida a lógica de arremesso anterior)

print("FPS HUB MOBILE PRO V6.5 Carregado!")
