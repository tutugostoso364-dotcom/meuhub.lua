-- BRAYAN HUB - MOBILE PRO (Versão v10.0 - Auto Head Lock + ESP + Safe Bullet Bypass)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v10.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local visualsOn = false
local magicBulletOn = false

-- Tabelas para armazenar os desenhos do ESP
local boxes = {}
local lines = {}

------------------------------------------------
-- FUNÇÕES AUXILIARES DE LIMPEZA E CRIAÇÃO DO ESP
------------------------------------------------
local function clearVisuals(p)
    if boxes[p] then boxes[p]:Destroy(); boxes[p] = nil end
    if lines[p] then lines[p]:Destroy(); lines[p] = nil end
    if p.Character then
        local h = p.Character:FindFirstChild("Brayan_Hub_Highlight")
        if h then h:Destroy() end
    end
end

local function createESP(p)
    if not boxes[p] then
        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled = false
        box.Visible = false
        boxes[p] = box
    end
    if not lines[p] then
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Visible = false
        lines[p] = line
    end
end

Players.PlayerRemoving:Connect(clearVisuals)

------------------------------------------------
-- INTERFACE GRÁFICA (VISUAL & AIM)
------------------------------------------------
VisualTab:CreateToggle({
    Name = "🌈 Hitbox RGB + ESP (Box/Lines)",
    CurrentValue = false,
    Callback = function(v)
        visualsOn = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do clearVisuals(p) end
        end
    end
})

AimTab:CreateToggle({
    Name = "🎯 Aimbot Automático (Grudar na Cabeça)",
    CurrentValue = false,
    Callback = function(v) aimOn = v end
})

AimTab:CreateToggle({
    Name = "🧱 Bala Mágicas (Atravessar Sem Cair)",
    CurrentValue = false,
    Callback = function(v) magicBulletOn = v end
})

------------------------------------------------
-- LOOP PRINCIPAL UNIFICADO (RenderStepped)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closestHead = nil
    local shortestDist = math.huge

    -- Coleta o personagem local para o sistema anti-queda da Bala Mágica
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    ------------------------------------------------
    -- LÓGICA DA BALA MÁGICA INTELIGENTE (ANTI-QUEDA)
    ------------------------------------------------
    if magicBulletOn and myRoot then
        -- Procura por objetos ao redor do mapa
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                -- Proteção básica para o chão principal do mapa não sumir nunca
                if not name:find("floor") and not name:find("ground") and not name:find("baseplate") and not name:find("terrain") then
                    
                    -- Calcula a distância entre o objeto e o pé/base do seu jogador
                    local distanceToMe = (obj.Position - myRoot.Position).Magnitude
                    
                    if distanceToMe < 6 then
                        -- Se estiver colado em você ou no seu pé, mantém sólido para você não cair ou bugar nas paredes
                        obj.CanCollide = true
                    else
                        -- Se estiver longe de você, fica sem colisão para a sua bala passar direto!
                        obj.CanCollide = false
                    end
                end
            end
        end
    elseif not magicBulletOn then
        -- Se desligar a bala mágica, o script restaura a física padrão do mapa imediatamente
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" then
                -- Restaura apenas o que não for do sistema nativo para evitar lags
                if obj:GetAttribute("OriginalCollide") ~= nil then
                    obj.CanCollide = obj:GetAttribute("OriginalCollide")
                end
            end
        end
    end

    ------------------------------------------------
    -- LOOP DE JOGADORES (AIMBOT, RGB E ESP)
    ------------------------------------------------
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")

            -- 1. SISTEMA VISUAL: HITBOX RGB INFINITA + ESP
            if visualsOn and hum and head and root then
                local hl = p.Character:FindFirstChild("Brayan_Hub_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Brayan_Hub_Highlight"
                    hl.Adornee = p.Character
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.Parent = p.Character
                end
                hl.FillColor = dynamicColor
                hl.OutlineColor = dynamicColor

                createESP(p)
                local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local rootPos = camera:WorldToViewportPoint(root.Position)
                    local boxSize = Vector2.new(camera.ViewportSize.X / rootPos.Z * 2, camera.ViewportSize.Y / rootPos.Z * 3)
                    
                    boxes[p].Size = boxSize
                    boxes[p].Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                    boxes[p].Color = dynamicColor
                    boxes[p].Visible = true

                    lines[p].From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    lines[p].To = Vector2.new(rootPos.X, rootPos.Y)
                    lines[p].Color = dynamicColor
                    lines[p].Visible = true
                else
                    if boxes[p] then boxes[p].Visible = false end
                    if lines[p] then lines[p].Visible = false end
                end
            else
                if boxes[p] then boxes[p].Visible = false end
                if lines[p] then lines[p].Visible = false end
            end

            -- 2. COLETA DE DADOS PARA O AIMBOT (Foco na Cabeça)
            if aimOn and hum and hum.Health > 0 and head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magnitude < 300 and magnitude < shortestDist then
                        closestHead = head
                        shortestDist = magnitude
                    end
                end
            end
        end
    end

    -- 3. EXECUÇÃO DO AIMBOT
    if aimOn and closestHead then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
    end
end)

print("Brayan Hub v10.0 Carregado - Bala Mágica Avançada Injetada!")
