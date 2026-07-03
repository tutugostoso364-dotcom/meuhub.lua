-- BRAYAN HUB - MOBILE PRO (Versão v18.0 - Edição Ultra Compatível)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v18.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local advancedAimOn = false
local advancedAimFOV = 150
local visualsOn = false

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
    Name = "⚡ Aimbot 2 (Predição por Distância de Tela)",
    CurrentValue = false,
    Callback = function(v) advancedAimOn = v end
})

AimTab:CreateSlider({
    Name = "⭕ Limite de Alcance (Aimbot 2)",
    Min = 50,
    Max = 400,
    Default = 150,
    Color = Color3.fromRGB(255, 50, 50),
    Increment = 10,
    ValueName = "Pixels",
    Callback = function(v) advancedAimFOV = v end
})

------------------------------------------------
-- LOOP PRINCIPAL COMPATÍVEL (RenderStepped)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    
    local shortestDist1 = math.huge
    local shortestDist2 = advancedAimFOV -- Usa o valor do Slider direto na matemática
    
    local targetAimbot1 = nil
    local targetAimbot2 = nil

    -- Varredura Simples e Direta de Jogadores
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if head and root and hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                
                -- 1. VISUAL (Apenas Highlight, que roda em qualquer celular)
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

                -- 2. FILTRAGEM DE ALVOS (Sem travar o código se não estiver na tela)
                if onScreen then
                    -- Lógica do Aimbot 1 (Raio Fixo de 300)
                    if aimOn and magnitude < 300 and magnitude < shortestDist1 then
                        targetAimbot1 = head
                        shortestDist1 = magnitude
                    end
                    
                    -- Lógica do Aimbot 2 (Raio Dinâmico do Slider)
                    if advancedAimOn and magnitude < shortestDist2 then
                        targetAimbot2 = head
                        shortestDist2 = magnitude
                    end
                end
            else
                removeHighlight(p.Character)
            end
        end
    end

    ------------------------------------------------
    -- 3. EXECUÇÃO PURA DA CÂMERA
    ------------------------------------------------
    if aimOn and targetAimbot1 then
        -- Aimbot 1: Trava Seca Direta na cabeça
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetAimbot1.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.16)
        
    elseif advancedAimOn and targetAimbot2 then
        -- Aimbot 2: Predição matemática sem usar metatables pesadas
        local targetVelocity = Vector3.new(0, 0, 0)
        local targetRoot = targetAimbot2.Parent:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            targetVelocity = targetRoot.Velocity
        end
        
        local predictedPosition = targetAimbot2.Position + (targetVelocity * 0.12)
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, predictedPosition)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.20)
    end
end)

print("Brayan Hub v18.0 - Edição Ultra Light Carregada!")
