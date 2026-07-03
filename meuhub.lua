-- BRAYAN HUB - MOBILE PRO (Versão v17.0 - Correção de Sintaxe e Estabilização)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v17.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local advancedAimOn = false
local advancedAimFOV = 150
local magicBulletOn = false
local visualsOn = false

local globalClosestHead = nil

-- Círculo FOV protegido
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false
FOVCircle.Radius = advancedAimFOV

-- Função segura para remover os Highlights visuais
local function removeHighlight(char)
    if char then
        local hl = char:FindFirstChild("Brayan_Hub_Highlight")
        if hl then hl:Destroy() end
    end
end

------------------------------------------------
-- INTERFACE GRÁFICA
------------------------------------------------
VisualTab:CreateToggle({
    Name = "🌈 Hitbox RGB Visual",
    CurrentValue = false,
    Callback = function(v)
        visualsOn = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then removeHighlight(p.Character) end
            end
        end
    end
})

AimTab:CreateToggle({
    Name = "🎯 Aimbot 1 (Grudar na Cabeça)",
    CurrentValue = false,
    Callback = function(v) aimOn = v end
})

AimTab:CreateToggle({
    Name = "⚡ Aimbot 2 (Predição + Círculo FOV)",
    CurrentValue = false,
    Callback = function(v) 
        advancedAimOn = v 
        FOVCircle.Visible = v
    end
})

AimTab:CreateSlider({
    Name = "⭕ Raio do Círculo FOV (Aimbot 2)",
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
-- LOOP PRINCIPAL (RenderStepped)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Centralização dinâmica corrigida para telas Mobile
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    FOVCircle.Position = center
    
    -- Efeito RGB Fluido
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    FOVCircle.Color = dynamicColor
    
    local shortestDist = math.huge
    local advancedClosestHead = nil
    local advancedShortestDist = advancedAimFOV 
    globalClosestHead = nil

    -- Varredura de Jogadores
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            -- Só processa se o inimigo estiver vivo e com o esqueleto carregado
            if head and root and hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                
                -- 1. SISTEMA VISUAL (Criação de Highlight Otimizada)
                if visualsOn then
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
                else
                    removeHighlight(p.Character)
                end

                -- 2. SELEÇÃO DE ALVOS (Miras Independentes)
                if magicBulletOn then
                    -- Bala mágica busca em 360 graus por proximidade 3D
                    local dist3D = (head.Position - camera.CFrame.Position).Magnitude
                    if dist3D < shortestDist then
                        globalClosestHead = head
                        shortestDist = dist3D
                    end
                else
                    if onScreen then
                        -- Aimbot 2: Predição dentro do Círculo de FOV
                        if advancedAimOn and magnitude < advancedShortestDist then
                            advancedClosestHead = head
                            advancedShortestDist = magnitude
                        end
                        
                        -- Aimbot 1: Trava tradicional por aproximação de tela (Raio fixo de 300)
                        if aimOn and magnitude < 300 and magnitude < shortestDist then
                            globalClosestHead = head
                            shortestDist = magnitude
                        end
                    end
                end
            else
                -- Remove os efeitos visuais se o jogador morrer
                removeHighlight(p.Character)
            end
        end
    end

    ------------------------------------------------
    -- 3. EXECUÇÃO DA TRAVA DE MIRA
    ------------------------------------------------
    -- Executa o Aimbot 1 (Se estiver ligado)
    if aimOn and globalClosestHead then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
        
    -- Executa o Aimbot 2 com Cálculo de Velocidade (Se o Aimbot 1 estiver desligado)
    elseif advancedAimOn and advancedClosestHead then
        local targetVelocity = Vector3.new(0, 0, 0)
        local targetRoot = advancedClosestHead.Parent:FindFirstChild("HumanoidRootPart")
        
        if targetRoot then
            targetVelocity = targetRoot.Velocity
        end
        
        -- Aplica a física de predição na cabeça do alvo
        local predictedPosition = advancedClosestHead.Position + (targetVelocity * 0.12)
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, predictedPosition)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.20)
    end
end)

print("Brayan Hub v17.0 - Executado sem erros de sintaxe!")
