-- BRAYAN HUB - MOBILE PRO (Versão v14.0 - Wallbang Pro + Fly Mobile)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v14.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local MoveTab = Window:CreateTab("Movement", 4483362458) -- Nova aba para o Fly

local aimOn = false
local visualsOn = false
local magicBulletOn = false
local flyOn = false
local flySpeed = 50

-- Variáveis globais de controle
local globalClosestHead = nil
local boxes = {}
local lines = {}
local flyBodyVelocity = nil
local flyBodyGyro = nil

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
-- INTERFACE GRÁFICA
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

-- Controles de Voo na nova aba
MoveTab:CreateToggle({
    Name = "✈️ Ativar Fly (Voo de Câmera)",
    CurrentValue = false,
    Callback = function(v) 
        flyOn = v 
        if not v then
            -- Limpa as forças físicas ao desligar o Fly
            if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
})

MoveTab:CreateSlider({
    Name = "⚡ Velocidade do Voo",
    Min = 20,
    Max = 150,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 120),
    Increment = 5,
    ValueName = "Studs",
    Callback = function(v) flySpeed = v end
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
    local shortestDist = math.huge
    globalClosestHead = nil

    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    ------------------------------------------------
    -- LÓGICA DO FLY MOBILE INTELIGENTE
    ------------------------------------------------
    if flyOn and myRoot and myHum then
        myHum.PlatformStand = true -- Desativa as animações de queda do Roblox para não bugar

        -- Cria ou atualiza as forças físicas estáveis para segurar o boneco no ar
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBodyVelocity.Parent = myRoot
        end

        if not flyBodyGyro then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyBodyGyro.Parent = myRoot
        end

        -- Alinha a rotação do corpo com a inclinação da sua câmera do celular
        flyBodyGyro.CFrame = camera.CFrame

        -- Verifica a direção que o direcional virtual do Mobile está mandando andar
        local moveDirection = myHum.MoveDirection
        if moveDirection.Magnitude > 0 then
            -- Voa na direção para onde a Câmera aponta (Voo Direcional Completo)
            flyBodyVelocity.Velocity = camera.CFrame.LookVector * (moveDirection.Magnitude * flySpeed)
        else
            -- Se soltar o analógico, o boneco trava perfeitamente estático no ar
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
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

            -- 2. COLETA DE INIMIGOS (AIMBOT)
            if hum and hum.Health > 0 and head then
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
            end
        end
    end

    -- 3. EXECUÇÃO DO AIMBOT
    if aimOn and globalClosestHead then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
    end
end)

print("Brayan Hub v14.0 Carregado - Aba Movement e Fly Injetados!")
