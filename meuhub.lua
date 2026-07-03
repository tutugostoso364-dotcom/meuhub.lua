-- FPS HUB MOBILE PRO - V6.7 (Foco: Aimbot Humanoid Suave)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Inicializando...", LoadingSubtitle = "V6.7 - Humanoid Focus"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local hitboxOn = false

------------------------------------------------
-- 1. HITBOX RGB (FIXO)
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
                p.Character.Highlight.FillColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            end
        end
    end
end)

------------------------------------------------
-- 2. AIMBOT (Detector de Humanoid + Suavização)
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Aimbot Humanoid (Lock Suave)", CurrentValue = false, Callback = function(v) aimOn = v end})

RunService.RenderStepped:Connect(function()
    if not aimOn then return end
    
    local closest, dist = nil, 9999
    
    for _, p in pairs(Players:GetPlayers()) do
        -- Verifica se o jogador tem Humanoid e se está vivo
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        closest = root
                        dist = mag
                    end
                end
            end
        end
    end

    if closest then
        -- Suavização constante (0.15 é o ponto ideal para não bugar tiros)
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closest.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.15)
    end
end)

print("FPS HUB MOBILE PRO V6.7 (Humanoid Focus) Carregado!")
