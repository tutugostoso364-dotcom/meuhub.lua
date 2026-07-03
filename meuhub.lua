-- FPS TEST HUB - MOBILE PRO (Versão Definitiva)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local hitboxOn = false

------------------------------------------------
-- SISTEMA DE HITBOX (Sempre On para novos players)
------------------------------------------------
local function applyHighlight(char)
    if char and not char:FindFirstChild("Highlight") then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = char
        
        -- Loop para o efeito RGB contínuo
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

-- Monitorar quem entra e quem spawna
local function setupPlayer(p)
    if p ~= player then
        p.CharacterAdded:Connect(function(char)
            if hitboxOn then task.wait(0.5); applyHighlight(char) end
        end)
        if p.Character then applyHighlight(p.Character) end
    end
end

-- Rodar em todos os jogadores atuais
Players.PlayerAdded:Connect(setupPlayer)
for _, p in pairs(Players:GetPlayers()) do setupPlayer(p) end

VisualTab:CreateToggle({
    Name = "🌈 RGB em Todos os Players",
    CurrentValue = false,
    Callback = function(v)
        hitboxOn = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do if p.Character then applyHighlight(p.Character) end end
        else
            for _, p in pairs(Players:GetPlayers()) do if p.Character then local h = p.Character:FindFirstChild("Highlight") if h then h:Destroy() end end end
        end
    end
})

------------------------------------------------
-- AIMBOT (Automático ao mirar)
------------------------------------------------
AimTab:CreateToggle({
    Name = "🎯 Aimbot Automático",
    CurrentValue = false,
    Callback = function(v)
        aimOn = v
    end
})

RunService.RenderStepped:Connect(function()
    if aimOn then
        local closest = nil
        local dist = math.huge
        local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    
                    -- Se o jogador estiver na tela e for o mais próximo do centro
                    if onScreen and magnitude < 300 then -- 300 é o tamanho do seu "campo de visão"
                        if magnitude < dist then
                            closest = p.Character.HumanoidRootPart
                            dist = magnitude
                        end
                    end
                end
            end
        end
        
        if closest then
            -- Faz o puxão suave para o alvo
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15)
        end
    end
end)

print("FPS HUB MOBILE PRO carregado!")
