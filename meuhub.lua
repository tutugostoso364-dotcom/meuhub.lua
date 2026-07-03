-- BRAYAN HUB - MOBILE PRO (Versão v13.8 - Varredura Global de Partida)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v13.8"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local aim2On = false
local visualsOn = false
local magicBulletOn = false

-- Variáveis globais para guardar os alvos de forma independente
local globalClosestHead = nil
local globalClosestHead2 = nil

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
    Name = "🎯 Aimbot 1 (Grudar na Cabeça - Original)",
    CurrentValue = false,
    Callback = function(v) aimOn = v end
})

AimTab:CreateToggle({
    Name = "👁️ Aimbot 2 (Foco Total na Tela)",
    CurrentValue = false,
    Callback = function(v) aim2On = v end
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
-- FUNÇÃO DE VERIFICAÇÃO DE JOGADOR REAL
------------------------------------------------
-- Associa um modelo encontrado no Workspace a um jogador real para evitar mirar em NPCs ou aliados
local function getPlayerFromCharacter(char)
    local p = Players:GetPlayerFromCharacter(char)
    if p then return p end
    
    -- Segunda tentativa caso o jogo clone o boneco separadamente
    for _, pl in pairs(Players:GetPlayers()) do
        if pl.Name == char.Name then
            return pl
        end
    end
    return nil
end

------------------------------------------------
-- LOOP PRINCIPAL UNIFICADO (RenderStepped)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    local shortestDist = math.huge
    local shortestDist2 = math.huge
    
    globalClosestHead = nil 
    globalClosestHead2 = nil

    ------------------------------------------------
    -- NOVO LOOP DETECTOR: PROCURA EM TODO O ESPAÇO DO JOGO
    ------------------------------------------------
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Verifica se o objeto se comporta como um personagem e não é você mesmo
        if obj:IsA("Model") and obj ~= player.Character then
            local head = obj:FindFirstChild("Head")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            
            if head and hum and root and hum.Health > 0 then
                -- Descobre quem é o dono desse boneco na partida
                local targetPlayer = getPlayerFromCharacter(obj)
                
                -- 1. SISTEMA VISUAL (ESP e Highlight adaptáveis)
                if visualsOn then
                    local hl = obj:FindFirstChild("Brayan_Hub_Highlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "Brayan_Hub_Highlight"
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = obj
                    end
                    hl.Adornee = obj
                    hl.FillColor = dynamicColor
                    hl.OutlineColor = dynamicColor

                    if targetPlayer then
                        createESP(targetPlayer)
                        local _, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local rootPos = camera:WorldToViewportPoint(root.Position)
                            local boxSize = Vector2.new(camera.ViewportSize.X / rootPos.Z * 2, camera.ViewportSize.Y / rootPos.Z * 3)
                            
                            boxes[targetPlayer].Size = boxSize
                            boxes[targetPlayer].Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                            boxes[targetPlayer].Color = dynamicColor
                            boxes[targetPlayer].Visible = true

                            lines[targetPlayer].From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            lines[targetPlayer].To = Vector2.new(rootPos.X, rootPos.Y)
                            lines[targetPlayer].Color = dynamicColor
                            lines[targetPlayer].Visible = true
                        else
                            if boxes[targetPlayer] then boxes[targetPlayer].Visible = false end
                            if lines[targetPlayer] then lines[targetPlayer].Visible = false end
                        end
                    end
                else
                    local hl = obj:FindFirstChild("Brayan_Hub_Highlight")
                    if hl then hl:Destroy() end
                    if targetPlayer then
                        if boxes[targetPlayer] then boxes[targetPlayer].Visible = false end
                        if lines[targetPlayer] then lines[targetPlayer].Visible = false end
                    end
                end

                -- 2. AJUSTE DE MIRA EM PARTIDA
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if magicBulletOn then
                    local dist3D = (head.Position - camera.CFrame.Position).Magnitude
                    if dist3D < shortestDist then
                        globalClosestHead = head
                        shortestDist = dist3D
                    end
                elseif aimOn and onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magnitude < 300 and magnitude < shortestDist then
                        globalClosestHead = head
                        shortestDist = magnitude
                    end
                end

                if aim2On and onScreen then
                    local magnitude2 = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magnitude2 < shortestDist2 then
                        globalClosestHead2 = head
                        shortestDist2 = magnitude2
                    end
                end
            end
        end
    end

    ------------------------------------------------
    -- 3. EXECUÇÃO DOS AIMBOTS
    ------------------------------------------------
    if aimOn and globalClosestHead then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
    elseif aim2On and globalClosestHead2 then
        local targetCFrame2 = CFrame.lookAt(camera.CFrame.Position, globalClosestHead2.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame2, 0.16)
    end
end)

print("Brayan Hub v13.8 Carregado - Bypass de Pasta de Partida Ativo!")
