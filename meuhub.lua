-- FPS TEST HUB - MOBILE PRO V5 (Com Sistema de Fling)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

local aimOn = false
local hitboxOn = false
local flingOn = false

------------------------------------------------
-- SISTEMA DE HITBOX (Igual ao anterior)
------------------------------------------------
local function applyHighlight(char)
    if char and not char:FindFirstChild("Highlight") then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 0.4
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

local function setupPlayer(p)
    p.CharacterAdded:Connect(function(char) if hitboxOn then task.wait(0.5); applyHighlight(char) end end)
    if p.Character then applyHighlight(p.Character) end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, p in pairs(Players:GetPlayers()) do setupPlayer(p) end

VisualTab:CreateToggle({Name = "🌈 RGB em Todos", CurrentValue = false, Callback = function(v) hitboxOn = v end})

------------------------------------------------
-- COMBAT: ARREMESSAR (FLING)
------------------------------------------------
CombatTab:CreateToggle({
    Name = "🥊 Arremessar ao Atacar",
    CurrentValue = false,
    Callback = function(v)
        flingOn = v
    end
})

-- Detecta o toque (ataque) para arremessar
UserInputService.InputBegan:Connect(function(input, gpe)
    if not flingOn or gpe then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Tenta encontrar o jogador mais próximo para arremessar
        local mousePos = player:GetMouse().Hit.Position
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < 15 then -- Se estiver perto (distancia de ataque)
                    local root = p.Character.HumanoidRootPart
                    -- Aplica força para longe
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
                    bodyVelocity.Velocity = (root.Position - player.Character.HumanoidRootPart.Position).Unit * 100 + Vector3.new(0, 50, 0)
                    bodyVelocity.Parent = root
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.5) -- Remove a força após 0.5s
                end
            end
        end
    end
end)

------------------------------------------------
-- AIMBOT (Automático)
------------------------------------------------
AimTab:CreateToggle({Name = "🎯 Aimbot Automático", CurrentValue = false, Callback = function(v) aimOn = v end})

RunService.RenderStepped:Connect(function()
    if aimOn then
        local closest, dist = nil, 300
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                if onScreen and mag < dist then closest = p.Character.HumanoidRootPart; dist = mag end
            end
        end
        if closest then camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15) end
    end
end)
