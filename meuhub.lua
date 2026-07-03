-- BRAYAN HUB - MOBILE PRO (Versão v13.5 - Dual Aimbot Edition)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v13.5"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local advancedAimOn = false -- Nova variável para o Aimbot Novo
local advancedAimFOV = 150   -- Tamanho do círculo do novo Aimbot
local magicBulletOn = false
local visualsOn = false

-- Variável global para guardar o alvo atual
local globalClosestHead = nil

-- Tabelas para armazenar os desenhos do ESP
local boxes = {}
local lines = {}

-- Criação do Círculo de FOV para o Novo Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false
FOVCircle.Radius = advancedAimFOV

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
    Name = "🎯 Aimbot Automático (Grudar na Cabeça - Original)",
    CurrentValue = false,
    Callback = function(v) aimOn = v end
})

-- O NOVO AIMBOT QUE VOCÊ PEDIU (SEPARADO)
AimTab:CreateToggle({
    Name = "⚡ Aimbot Dinâmico (Predição + Círculo FOV)",
    CurrentValue = false,
    Callback = function(v) 
        advancedAimOn = v 
        FOVCircle.Visible = v
    end
})

AimTab:CreateSlider({
    Name = "⭕ Tamanho do Círculo do Aimbot Dinâmico",
    Min = 50,
    Max = 400,
    Default = 150,
    Color = Color3.fromRGB(255, 50, 50),
    Increment = 10,
    ValueName = "Pixels",
    Callback = function(v) 
        advancedAimFOV = v
        FOVCircle.Radius = v
    end
})

AimTab:CreateToggle({
    Name = "🧱 Bala Mágica (Atravessar Obstáculos)",
    CurrentValue = false,
    Callback = function(v) magicBulletOn = v end
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
-- LOOP PRINCIPAL UNIFICADO (RenderStepped)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Position = center
    FOVCircle.Color = dynamicColor -- Faz o círculo de FOV também acompanhar o efeito RGB do Hub
    
    local shortestDist = math.huge
    globalClosestHead = nil 

    local advancedClosestHead = nil
    local advancedShortestDist = advancedAimFOV -- Limita o alvo para ficar apenas dentro do raio do círculo

    ------------------------------------------------
    -- LOOP DE JOGADORES (AIMBOTS, RGB E ESP)
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

            -- 2. AJUSTE DO ALVO (Mecanismo Original & Mecanismo do Novo Aimbot)
            if hum and hum.Health > 0 and head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                local screenPos = Vector2.new(pos.X, pos.Y)
                local magnitude = (screenPos - center).Magnitude
                
                -- LOGICA DO AIMBOT ORIGINAL
                if magicBulletOn then
                    local dist3D = (head.Position - camera.CFrame.Position).Magnitude
                    if dist3D < shortestDist then
                        globalClosestHead = head
                        shortestDist = dist3D
                    end
                elseif aimOn and onScreen then
                    if magnitude < 300 and magnitude < shortestDist then
                        globalClosestHead = head
                        shortestDist = magnitude
                    end
                end

                -- LÓGICA DO NOVO AIMBOT DINÂMICO (Calculado Separadamente)
                if advancedAimOn and onScreen then
                    if magnitude < advancedShortestDist then
                        advancedClosestHead = head
                        advancedShortestDist = magnitude
                    end
                end
            end
        end
    end

    ------------------------------------------------
    -- 3. EXECUÇÃO DOS AIMBOTS
    ------------------------------------------------
    -- Execução do Aimbot Original
    if aimOn and globalClosestHead then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
        
    -- Execução do Novo Aimbot Dinâmico com Predição (Caso o original esteja desligado)
    elseif advancedAimOn and advancedClosestHead then
        local targetVelocity = Vector3.new(0, 0, 0)
        local targetRoot = advancedClosestHead.Parent:FindFirstChild("HumanoidRootPart")
        
        -- Pega a velocidade vetorial do oponente para calcular o desvio
        if targetRoot then
            targetVelocity = targetRoot.Velocity
        end
        
        -- Equação matemática básica de predição: Posição futura = Posição atual + (Velocidade * Tempo de resposta)
        local predictedPosition = advancedClosestHead.Position + (targetVelocity * 0.115)
        
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, predictedPosition)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.20) -- Força de arraste levemente mais rápida
    end
end)

print("Brayan Hub v13.5 Carregado - Novo Aimbot Dinâmico Adicionado com Sucesso!")
