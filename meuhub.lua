-- BRAYAN HUB - MOBILE PRO (Versão v15.0 - Otimização Extrema)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v15.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn, aim2On, visualsOn, magicBulletOn = false, false, false, false
local globalClosestHead, globalClosestHead2 = nil, nil

-- Configurações da GUI
VisualTab:CreateToggle({Name = "🌈 Hitbox RGB (Players)", CurrentValue = false, Callback = function(v) visualsOn = v end})
AimTab:CreateToggle({Name = "🎯 Aimbot 1 (Original)", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "⚡ Aimbot 2 (Suave)", CurrentValue = false, Callback = function(v) aim2On = v end})
AimTab:CreateToggle({Name = "🧱 Bala Mágica", CurrentValue = false, Callback = function(v) magicBulletOn = v end})

-- Loop Otimizado (Varredura Lenta para não crashar)
local targets = {}
task.spawn(function()
    while task.wait(0.5) do -- Varre o mapa só 2x por segundo
        local newTargets = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= player.Character and obj:FindFirstChild("Head") and obj:FindFirstChild("Humanoid") then
                table.insert(newTargets, obj)
            end
        end
        targets = newTargets
    end
end)

-- Hook de Bala Mágica Otimizado
local gmt = getrawmetatable(game)
local oldNamecall = gmt.__namecall
setreadonly(gmt, false)
gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if magicBulletOn and globalClosestHead and (method == "FindPartOnRay" or method == "Raycast") then
        return globalClosestHead, globalClosestHead.Position, Vector3.new(0,1,0), globalClosestHead.Material
    end
    return oldNamecall(self, ...)
end)
setreadonly(gmt, true)

-- Loop de Renderização (Leve)
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    local dist1, dist2 = math.huge, math.huge
    globalClosestHead, globalClosestHead2 = nil, nil

    for _, obj in pairs(targets) do
        local head = obj.Head
        local hum = obj.Humanoid
        
        if hum.Health > 0 then
            -- Visual RGB
            if visualsOn then
                local hl = obj:FindFirstChild("Brayan_Hub_Highlight") or Instance.new("Highlight", obj)
                hl.Name = "Brayan_Hub_Highlight"
                hl.FillColor, hl.OutlineColor = dynamicColor, dynamicColor
            else
                local hl = obj:FindFirstChild("Brayan_Hub_Highlight")
                if hl then hl:Destroy() end
            end

            -- Lógica de Mira
            local pos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if aimOn and mag < 300 and mag < dist1 then globalClosestHead = head; dist1 = mag end
                if aim2On and mag < dist2 then globalClosestHead2 = head; dist2 = mag end
            end
        end
    end

    -- Execução da Mira
    if aimOn and globalClosestHead then
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position), 0.16)
    elseif aim2On and globalClosestHead2 then
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, globalClosestHead2.Position), 0.40)
    end
end)

print("Brayan Hub v15.0 - Otimizado para Mobile!")
