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
local advancedAimOn = false -- Nova variável para o Aimbot 2
local advancedAimFOV = 150   -- Tamanho padrão do FOV
local visualsOn = false
local magicBulletOn = false

-- Variável global para guardar o alvo do Aimbot 1 / Bala Mágica
local globalClosestHead = nil

-- Tabelas para armazenar os desenhos do ESP
local boxes = {}
local lines = {}

-- Criação do Círculo de FOV para o Aimbot Novo
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
    Name = "🎯 Aimbot 1 (Grudar na Cabeça - Original)",
    CurrentValue = false,
    Callback = function(v) aimOn = v end
})

-- ADICIONADO: Controles do Novo Aimbot com FOV
AimTab:CreateToggle({
    Name = "⚡ Aimbot 2 (Travar por Círculo de FOV)",
    CurrentValue = false,
    Callback = function(v) 
        advancedAimOn = v 
        FOVCircle.Visible = v
    end
})

AimTab:CreateSlider({
    Name = "⭕ Tamanho do Círculo do Aimbot 2",
    Min = 50,
    Max = 400,
    Default = 150,
    Color = Color3.fromRGB(255, 50, 50),
    Increment = 5,
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
    
    -- Recalcula o centro dinamicamente para telas Mobile não bugarem a posição
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    FOVCircle.Position = center
    FOVCircle.Color = dynamicColor -- Deixa o círculo acompanhando o RGB do Hub
    
    local shortestDist = math.huge
    globalClosestHead = nil 

    -- Variáveis exclusivas de alvo para o Aimbot 2
    local advancedClosestHead = nil
    local advancedShortestDist = advancedAimFOV

    ------------------------------------------------
    -- LOOP DE JOGADORES (AIMBOT, RGB E ESP)
    ------------------------------------------------
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")

            -- 1. SISTEMA VISUAL: HITBOX RGB INFINITA + ESP (Original Intacto)
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
                    local boxSize = Vector2.new(viewport.X / rootPos.Z * 2, viewport.Y / rootPos.Z * 3)
                    
                    boxes[p].Size = boxSize
                    boxes[p].Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                    boxes[p].Color = dynamicColor
                    boxes[p].Visible = true

                    lines[p].From = Vector2.new(viewport.X / 2, viewport.Y)
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

            -- 2. LOGICA DE SELEÇÃO DE ALVOS
            if hum and hum.Health > 0 and head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                local screenPos = Vector2.new(pos.X, pos.Y)
                local magnitude = (screenPos - center).Magnitude
                
                -- ALVO DO AIMBOT 1 (Original)
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

                -- ADICIONADO: ALVO DO AIMBOT 2 (Focado estritamente dentro do círculo de FOV)
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
    -- 3. EXECUÇÃO INDEPENDENTE DOS AIMBOTS
    ------------------------------------------------
    if aimOn and globalClosestHead then
        -- Executa a mira do Aimbot 1 original
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
        
    elseif advancedAimOn and advancedClosestHead then
        -- ADICIONADO: Executa a trava do Aimbot 2 apenas no alvo capturado dentro do círculo
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, advancedClosestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.20) -- Arraste ligeiramente mais firme
    end
end)

print("Brayan Hub v13.5 Carregado - Aimbot 1 e Aimbot 2 com FOV Operando Separados!")
