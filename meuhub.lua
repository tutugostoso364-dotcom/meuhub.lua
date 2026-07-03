-- BRAYAN HUB - MOBILE PRO (Versão v14.6 - ESP Restaurado + Aimbot 0.65)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v14.6"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local aim2On = false
local visualsOn = false
local magicBulletOn = false

local globalClosestHead = nil
local globalClosestHead2 = nil

local boxes = {}
local lines = {}

------------------------------------------------
-- FUNÇÕES DE ESP E LIMPEZA
------------------------------------------------
local function clearVisuals(p)
    if boxes[p] then boxes[p]:Destroy(); boxes[p] = nil end
    if lines[p] then lines[p]:Destroy(); lines[p] = nil end
end

-- Limpa os Highlights de todos os modelos
local function cleanupHighlights()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "Brayan_Hub_Highlight" then
            obj:Destroy()
        end
    end
end

Players.PlayerRemoving:Connect(clearVisuals)

------------------------------------------------
-- INTERFACE GRÁFICA
------------------------------------------------
VisualTab:CreateToggle({
    Name = "🌈 Hitbox RGB + ESP (Box/Lines)",
    CurrentValue = false,
    Callback = function(v)
        visualsOn = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do clearVisuals(p) end
            cleanupHighlights()
        end
    end
})

AimTab:CreateToggle({
    Name = "🎯 Aimbot 1 (Grudar na Cabeça)",
    CurrentValue = false,
    Callback = function(v) aimOn = v end
})

AimTab:CreateToggle({
    Name = "⚡ Aimbot 2 (Grudar Rápido - 0.65)",
    CurrentValue = false,
    Callback = function(v) aim2On = v end
})

AimTab:CreateToggle({
    Name = "🧱 Bala Mágica (Atravessar Obstáculos)",
    CurrentValue = false,
    Callback = function(v) magicBulletOn = v end
})

------------------------------------------------
-- LOOP PRINCIPAL
------------------------------------------------
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    local shortestDist = math.huge
    local shortestDist2 = math.huge
    globalClosestHead = nil 
    globalClosestHead2 = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local head = obj:FindFirstChild("Head")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            
            if head and hum and root and hum.Health > 0 then
                local targetPlayer = Players:GetPlayerFromCharacter(obj) or obj.Name
                
                -- 1. SISTEMA VISUAL (ESP + HIGHLIGHT)
                if visualsOn then
                    -- Highlight RGB
                    local hl = obj:FindFirstChild("Brayan_Hub_Highlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "Brayan_Hub_Highlight"
                        hl.Parent = obj
                    end
                    hl.FillColor = dynamicColor
                    hl.OutlineColor = dynamicColor

                    -- ESP BOX E LINES
                    if not boxes[targetPlayer] then
                        boxes[targetPlayer] = Drawing.new("Square")
                        boxes[targetPlayer].Filled = false
                        boxes[targetPlayer].Thickness = 2
                        lines[targetPlayer] = Drawing.new("Line")
                        lines[targetPlayer].Thickness = 1.5
                    end

                    local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local rootPos = camera:WorldToViewportPoint(root.Position)
                        local boxSize = Vector2.new(1000 / rootPos.Z, 1500 / rootPos.Z)
                        boxes[targetPlayer].Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                        boxes[targetPlayer].Size = boxSize
                        boxes[targetPlayer].Color = dynamicColor
                        boxes[targetPlayer].Visible = true
                        
                        lines[targetPlayer].From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        lines[targetPlayer].To = Vector2.new(rootPos.X, rootPos.Y)
                        lines[targetPlayer].Color = dynamicColor
                        lines[targetPlayer].Visible = true
                    else
                        boxes[targetPlayer].Visible = false
                        lines[targetPlayer].Visible = false
                    end
                else
                    if boxes[targetPlayer] then boxes[targetPlayer].Visible = false end
                    if lines[targetPlayer] then lines[targetPlayer].Visible = false end
                end

                -- 2. LÓGICA DO AIMBOT
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if aimOn and mag < 300 and mag < shortestDist then
                        globalClosestHead = head
                        shortestDist = mag
                    end
                    if aim2On and mag < shortestDist2 then
                        globalClosestHead2 = head
                        shortestDist2 = mag
                    end
                end
            end
        end
    end

    -- 3. EXECUÇÃO DA MIRA
    if aimOn and globalClosestHead then
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position), 0.16)
    elseif aim2On and globalClosestHead2 then
        -- Acelerado para 0.65 como pedido
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, globalClosestHead2.Position), 0.65)
    end
end)

print("Brayan Hub v14.6 Carregado - ESP Restaurado e Aimbot 2 em 0.65!")
