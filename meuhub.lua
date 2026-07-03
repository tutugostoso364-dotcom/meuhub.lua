-- FPS TEST HUB - MOBILE PRO (Versão Definitiva Corrigida)
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
-- SISTEMA DE HITBOX INQUEBRÁVEL (Auto-Correção)
------------------------------------------------
local function forceHighlight(char)
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    
    -- Busca se já existe um Highlight criado por nós
    local currentHl = char:FindFirstChild("FPS_Hub_Highlight")
    
    -- SISTEMA DE DETECÇÃO E CORREÇÃO: Se não existir, cria e força a existência
    if not currentHl then
        local hl = Instance.new("Highlight")
        hl.Name = "FPS_Hub_Highlight"
        hl.Adornee = char
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = char
        
        -- Loop independente para manter o RGB piscando neste objeto
        task.spawn(function()
            while hl and hl.Parent do
                local hue = tick() % 5 / 5
                hl.FillColor = Color3.fromHSV(hue, 1, 1)
                hl.OutlineColor = Color3.fromHSV(hue, 1, 1)
                task.wait(0.05) -- Frequência mais rápida para evitar atrasos visuais
            end
        end)
    end
end

-- Monitoramento Frame-a-Frame em tempo real para Forçar a Hitbox
RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                forceHighlight(p.Character)
            end
        end
    end
end)

VisualTab:CreateToggle({
    Name = "🌈 RGB em Todos os Players",
    CurrentValue = false,
    Callback = function(v)
        hitboxOn = v
        if not v then
            -- Se desligar, limpa rigorosamente todas as nossas hitboxes do mapa
            for _, p in pairs(Players:GetPlayers()) do 
                if p.Character then 
                    local h = p.Character:FindFirstChild("FPS_Hub_Highlight") 
                    if h then h:Destroy() end 
                end 
            end
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
                    if onScreen and magnitude < 300 then 
                        if magnitude < dist then
                            closest = p.Character.HumanoidRootPart
                            dist = magnitude
                        end
                    end
                end
            end
        end
        
        if closest then
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15)
        end
    end
end)

print("FPS HUB MOBILE PRO carregado com Auto-Correção de Hitbox!")
