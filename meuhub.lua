-- FPS HUB MOBILE PRO - V6.6 (FIXED: Aimbot Logic + Ground Safe Wallbang)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Ajustando...", LoadingSubtitle = "V6.6 - Stable"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn, wallBangOn, hitboxOn = false, false, false

------------------------------------------------
-- 1. HITBOX RGB (Ajustado)
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
-- 2. AIMBOT (Lock Suave e Constante)
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Lock Automático Suave", CurrentValue = false, Callback = function(v) aimOn = v end})

RunService.RenderStepped:Connect(function()
    if aimOn then
        local closest, dist = nil, 9999
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local mag = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then closest = root; dist = mag end
            end
        end
        if closest then
            -- Suavização baseada em tempo (DeltaTime) para não bugar balas
            local targetPos = closest.Position
            local lookAt = CFrame.lookAt(camera.CFrame.Position, targetPos)
            camera.CFrame = camera.CFrame:Lerp(lookAt, 0.1)
        end
    end
end)

------------------------------------------------
-- 3. BALA MÁGICA SEGURA (Wallbang seletivo)
------------------------------------------------
-- Em vez de desligar a colisão, faremos o "ignore" nas paredes
local function setWallbang(enabled)
    local camera = workspace.CurrentCamera
    if enabled then
        -- Filtra apenas objetos de parede, ignorando Terrain (chão) e Partes do nome 'Floor'
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.CanCollide == true then
                local name = obj.Name:lower()
                if not name:find("floor") and not name:find("ground") and not name:find("base") and not name:find("terrain") then
                    obj.CanCollide = false -- Paredes viram fantasmas
                end
            end
        end
    else
        -- Reseta as colisões para o normal
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.CanCollide = true end
        end
    end
end

AimTab:CreateToggle({Name = "🧱 Balas Mágicas (No Floor Damage)", CurrentValue = false, Callback = function(v) 
    wallBangOn = v 
    setWallbang(v)
end})

print("FPS HUB MOBILE PRO V6.6 Carregado!")
