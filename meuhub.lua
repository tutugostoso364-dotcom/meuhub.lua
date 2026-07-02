-- FPS TEST HUB - MOBILE V4 (Sincronizado com Disparo)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB - MOBILE", LoadingTitle = "Configurando...", LoadingSubtitle = "Modo Combate"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local hitboxOn = false
local isFiring = false

------------------------------------------------
-- DETECÇÃO DE DISPARO NO MOBILE
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isFiring = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isFiring = false
    end
end)

------------------------------------------------
-- VISUAL: HITBOX RGB (Global)
------------------------------------------------
VisualTab:CreateToggle({
    Name = "🌈 RGB em Todos",
    CurrentValue = false,
    Callback = function(v)
        hitboxOn = v
    end
})

RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hl = p.Character:FindFirstChildOfClass("Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Adornee = p.Character
                    hl.FillTransparency = 0.5
                    hl.Parent = p.Character
                end
                local hue = (tick() % 5) / 5
                hl.FillColor = Color3.fromHSV(hue, 1, 1)
                hl.OutlineColor = Color3.fromHSV(hue, 1, 1)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChildOfClass("Highlight")
                if hl then hl:Destroy() end
            end
        end
    end
end)

------------------------------------------------
-- AIMBOT: Ativa SÓ QUANDO ATIRA
------------------------------------------------
AimTab:CreateToggle({
    Name = "🎯 Aim (Gruda ao Atirar)",
    CurrentValue = false,
    Callback = function(v)
        aimOn = v
    end
})

RunService.RenderStepped:Connect(function()
    -- Agora ele gruda APENAS se o toggle estiver ligado E você estiver apertando para atirar/mirar
    if aimOn and isFiring then
        local closest = nil
        local dist = math.huge
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChild("Humanoid")
                -- Só trava em quem está vivo
                if hum and hum.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                        if magnitude < dist then
                            closest = p.Character.HumanoidRootPart
                            dist = magnitude
                        end
                    end
                end
            end
        end
        
        if closest then
            -- Suaviza a mira para não parecer robótico
            local lerpSpeed = 0.2 
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), lerpSpeed)
        end
    end
end)

print("FPS HUB MOBILE V4 carregado!")
