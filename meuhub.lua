-- FPS HUB MOBILE - VERSÃO COMPACTA E DIRETA (Sem erro de menu)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variáveis de controle (Você pode mudar para 'true' para ativar manualmente sem o menu)
local hitboxOn = true 
local aimOn = true
local voidFlingOn = true

------------------------------------------------
-- 1. HITBOX RGB AUTOMÁTICA
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

-- Monitoramento contínuo
RunService.RenderStepped:Connect(function()
    if hitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then applyHighlight(p.Character) end
        end
    end
end)

------------------------------------------------
-- 2. AIMBOT AUTOMÁTICO
------------------------------------------------
RunService.RenderStepped:Connect(function()
    if aimOn then
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
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, closest.Position), 0.15)
        end
    end
end)

------------------------------------------------
-- 3. VOID KILL FLING (Ao atacar)
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if not voidFlingOn or gpe then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                
                if dist < 25 then
                    local voidHeight = Workspace.FallenPartsDestroyHeight
                    local targetPos = Vector3.new(root.Position.X, voidHeight - 50, root.Position.Z)
                    local direction = (targetPos - root.Position).Unit
                    
                    local att = Instance.new("Attachment", root)
                    local vel = Instance.new("LinearVelocity", root)
                    vel.MaxForce = Vector3.new(1,1,1) * 999999999
                    vel.VectorVelocity = direction * 500
                    vel.Attachment0 = att
                    
                    game:GetService("Debris"):AddItem(vel, 0.5)
                    game:GetService("Debris"):AddItem(att, 0.5)
                    p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end
    end
end)

print("FPS HUB MOBILE V7 (Sem Rayfield) Carregado!")
