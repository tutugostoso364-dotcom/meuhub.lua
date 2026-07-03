-- BRAYAN HUB - MOBILE PRO (Versão v13.5 - Dual Aimbot & Proteção de Loop)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v13.5"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local Aim2Tab = Window:CreateTab("Aim v2 (FOV)", 4483362458) -- Nova Aba Exclusiva Criada!

local aimOn = false
local visualsOn = false
local magicBulletOn = false

-- Variáveis do Novo Aimbot 2
local aim2On = false
local aim2FOV = 150
local showFOV = false

-- Variável global do Aimbot 1 / Bala Mágica
local globalClosestHead = nil

-- Tabelas para armazenar os desenhos do ESP
local boxes = {}
local lines = {}

-- Inicialização Segura do Círculo do FOV (Blindado contra bugs do Executor)
local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
    FOVCircle.Radius = aim2FOV
end)

------------------------------------------------
-- FUNÇÕES AUXILIARES DE LIMPEZA E CRIAÇÃO DO ESP
------------------------------------------------
local function clearVisuals(p)
    if boxes[p] then pcall(function() boxes[p]:Destroy() end); boxes[p] = nil end
    if lines[p] then pcall(function() lines[p]:Destroy() end); lines[p] = nil end
    if p.Character then
        local h = p.Character:FindFirstChild("Brayan_Hub_Highlight")
        if h then h:Destroy() end
    end
end

local function createESP(p)
    pcall(function()
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
    end)
end

Players.PlayerRemoving:Connect(clearVisuals)

------------------------------------------------
-- INTERFACE GRÁFICA (VISUAL & AIM 1)
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
    Name = "🧱 Bala Mágica (Atravessar Obstáculos)",
    CurrentValue = false,
    Callback = function(v) magicBulletOn = v end
})

------------------------------------------------
-- INTERFACE GRÁFICA (NOVA ABA: AIM v2 DETALHADO)
------------------------------------------------
Aim2Tab:CreateToggle({
    Name = "⚡ Ativar Aimbot v2 (Foco em FOV Inteligente)",
    CurrentValue = false,
    Callback = function(v) aim2On = v end
})

Aim2Tab:CreateToggle({
    Name = "⭕ Mostrar Círculo de FOV na Tela",
    CurrentValue = false,
    Callback = function(v) 
        showFOV = v 
        if FOVCircle then FOVCircle.Visible = v end
    end
})

Aim2Tab:CreateSlider({
    Name = "📐 Tamanho do Campo de Visão (FOV)",
    Min = 30,
    Max = 400,
    Default = 150,
    Color = Color3.fromRGB(255, 80, 80),
    Increment = 5,
    ValueName = "Pixels",
    Callback = function(v) 
        aim2FOV = v
        if FOVCircle then FOVCircle.Radius = v end
    end
})

------------------------------------------------
-- HOOK DE BALA MÁGICA (SPOOF DE MOUSE/TIRO)
------------------------------------------------
local gmt = getrawmetatable(game)
local oldNamecall = gmt.__namecall
local oldIndex = gmt.__index
setreadonly(gmt, false)

gmt.__index = newcclosure(function(self, key)
    if magicBulletOn and globalClosestHead and tostring(self) == "Mouse" then
        if key == "Hit" then return globalClosestHead.CFrame
        elseif key == "Target" then return globalClosestHead end
    end
    return oldIndex(self, key)
end)

gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if magicBulletOn and globalClosestHead and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        return globalClosestHead, globalClosestHead.Position, Vector3.new(0,1,0), globalClosestHead.Material
    end
    return oldNamecall(self, ...)
end)
setreadonly(gmt, true)

------------------------------------------------
-- LOOP PRINCIPAL UNIFICADO SEGURO (RenderStepped)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    
    -- Renderização Dinâmica e Segura do Círculo
    if FOVCircle then
        FOVCircle.Position = center
        FOVCircle.Color = dynamicColor -- Faz o círculo de FOV também acompanhar o efeito RGB do Hub
        FOVCircle.Visible = showFOV
    end
    
    -- Distâncias e Alvos separados para que os dois sistemas não quebrem
    local shortestDist1 = math.huge
    local shortestDist2 = aim2FOV -- Limita o Aimbot 2 estritamente ao raio configurado no Slider
    
    local closestHead1 = nil
    local closestHead2 = nil

    ------------------------------------------------
    -- LOOP DE JOGADORES (PROCESSAMENTO)
    ------------------------------------------------
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")

            -- 1. SISTEMA VISUAL ORIGINAL
            if visualsOn and hum and head and root then
                local hl = p.Character:FindFirstChild("Brayan_Hub_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Brayan_Hub_Highlight"
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.Parent = p.Character
                end
                hl.Adornee = p.Character
                hl.FillColor = dynamicColor
                hl.OutlineColor = dynamicColor

                createESP(p)
                local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local rootPos = camera:WorldToViewportPoint(root.Position)
                    local boxSize = Vector2.new(viewport.X / rootPos.Z * 2, viewport.Y / rootPos.Z * 3)
                    
                    if boxes[p] then
                        boxes[p].Size = boxSize
                        boxes[p].Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                        boxes[p].Color = dynamicColor
                        boxes[p].Visible = true
                    end

                    if lines[p] then
                        lines[p].From = Vector2.new(viewport.X / 2, viewport.Y)
                        lines[p].To = Vector2.new(rootPos.X, rootPos.Y)
                        lines[p].Color = dynamicColor
                        lines[p].Visible = true
                    end
                else
                    if boxes[p] then boxes[p].Visible = false end
                    if lines[p] then lines[p].Visible = false end
                end
            else
                if boxes[p] then boxes[p].Visible = false end
                if lines[p] then lines[p].Visible = false end
            end

            -- 2. COLETA DE ALVOS INDEPENDENTE (Aimbot 1 vs Aimbot 2)
            if hum and hum.Health > 0 and head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                
                -- Lógica Original do Aimbot 1 / Bala Mágica
                if magicBulletOn then
                    local dist3D = (head.Position - camera.CFrame.Position).Magnitude
                    if dist3D < shortestDist1 then
                        closestHead1 = head
                        shortestDist1 = dist3D
                    end
                elseif aimOn and onScreen then
                    if magnitude < 300 and magnitude < shortestDist1 then
                        closestHead1 = head
                        shortestDist1 = magnitude
                    end
                end

                -- LÓGICA FILTRADA DO AIMBOT 2 (Baseada restritamente dentro do Círculo de FOV)
                if aim2On and onScreen then
                    if magnitude < shortestDist2 then
                        closestHead2 = head
                        shortestDist2 = magnitude
                    end
                end
            end
        end
    end

    -- Sincroniza a variável da Bala Mágica com o Alvo 1 encontrado
    globalClosestHead = closestHead1

    ------------------------------------------------
    -- 3. EXECUÇÃO PRIORITÁRIA DAS MIRAS
    ------------------------------------------------
    if aimOn and closestHead1 then
        -- Mantém a execução da trava original estável do v13.0
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closestHead1.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
        
    elseif aim2On and closestHead2 then
        -- Executa o Novo Aimbot Filtrado por FOV e de forma suave (Smoothness balanceado para Mobile)
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closestHead2.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.22)
    end
end)

print("Brayan Hub v13.5 Carregado - Nova aba de FOV Isolada com Sucesso!")
