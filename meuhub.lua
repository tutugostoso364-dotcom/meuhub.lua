-- BRAYAN HUB - MOBILE PRO (Versão Definitiva: Auto Head Lock + ESP + Infinite RGB)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v9.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local visualsOn = false

-- Tabelas para armazenar os desenhos do ESP (Garante que limpe ao desligar)
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

-- Monitorar saída de jogadores para limpar a memória do celular
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
    Callback = function(v)
        aimOn = v
    end
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

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")

            -- 1. SISTEMA VISUAL: HITBOX RGB INFINITA + ESP (Apenas se o jogador tiver um Humanoid)
            if visualsOn and hum and head and root then
                -- Injeção e Auto-Correção do Highlight RGB
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

                -- Lógica do ESP (Box e Linhas) usando as ferramentas do executor
                createESP(p)
                local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Desenhar a Box (Caixa) ao redor do jogador
                    local rootPos = camera:WorldToViewportPoint(root.Position)
                    local boxSize = Vector2.new(camera.ViewportSize.X / rootPos.Z * 2, camera.ViewportSize.Y / rootPos.Z * 3)
                    
                    boxes[p].Size = boxSize
                    boxes[p].Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                    boxes[p].Color = dynamicColor
                    boxes[p].Visible = true

                    -- Desenhar a Linha (Snapline) vindo de baixo da tela até o jogador
                    lines[p].From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    lines[p].To = Vector2.new(rootPos.X, rootPos.Y)
                    lines[p].Color = dynamicColor
                    lines[p].Visible = true
                else
                    if boxes[p] then boxes[p].Visible = false end
                    if lines[p] then lines[p].Visible = false end
                end
            else
                -- Esconde se a função geral estiver desligada ou jogador inválido
                if boxes[p] then boxes[p].Visible = false end
                if lines[p] then lines[p].Visible = false end
            end

            -- 2. COLETA DE DADOS PARA O AIMBOT (Acha a cabeça do jogador mais próximo do centro da tela)
            if aimOn and hum and hum.Health > 0 and head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magnitude < 300 and magnitude < shortestDist then -- 300 é o tamanho do raio de alcance
                        closestHead = head
                        shortestDist = magnitude
                    end
                end
            end
        end
    end

    -- 3. EXECUÇÃO DO AIMBOT (Trava e segue a cabeça dinamicamente)
    if aimOn and closestHead then
        -- O CFrame calcula a direção exata da cabeça do jogador a cada milissegundo
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, closestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16) -- 0.16 mantém a mira grudada sem tremer o disparo
    end
end)

print("Brayan Hub v9.0 Carregado - Foco Total na Cabeça!")
