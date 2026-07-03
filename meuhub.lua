-- FPS TEST HUB - MOBILE PRO (Versão V7.0 - Infinite RGB & Head Tracker)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "FPS HUB MOBILE PRO", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v7.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local hitboxOn = false
local currentTarget = nil -- Guarda o alvo atual do aimbot para o painel de coordenadas

------------------------------------------------
-- CRIAÇÃO DO PAINEL DE COORDENADAS (UI)
------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CoordLabel = Instance.new("TextLabel")

ScreenGui.Name = "HeadTrackerGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.75, 0, 0.05, 0) -- Canto superior direito
MainFrame.Size = UDim2.new(0, 220, 0, 80)
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar o painel pelo celular

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(1, 0, 0.35, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "📍 COORDENADAS DO ALVO"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold

CoordLabel.Name = "CoordLabel"
CoordLabel.Parent = MainFrame
CoordLabel.Position = UDim2.new(0, 0, 0.35, 0)
CoordLabel.Size = UDim2.new(1, 0, 0.65, 0)
CoordLabel.BackgroundTransparency = 1
CoordLabel.Text = "X: 0.00\nY: 0.00\nZ: 0.00"
CoordLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
CoordLabel.TextSize = 13
CoordLabel.Font = Enum.Font.Code

-- Aba de Controle do Painel
VisualTab:CreateToggle({
    Name = "📍 Mostrar Painel de Coordenadas",
    CurrentValue = true,
    Callback = function(v)
        MainFrame.Visible = v
    end
})

------------------------------------------------
-- SISTEMA DE HITBOX CORRIGIDO (RGB Infinito e Centralizado)
------------------------------------------------
local function forceHighlight(char)
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    
    local currentHl = char:FindFirstChild("FPS_Hub_Highlight")
    
    if not currentHl then
        local hl = Instance.new("Highlight")
        hl.Name = "FPS_Hub_Highlight"
        hl.Adornee = char
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = char
    end
end

VisualTab:CreateToggle({
    Name = "🌈 RGB em Todos os Players",
    CurrentValue = false,
    Callback = function(v)
        hitboxOn = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do 
                if p.Character then 
                    local h = p.Character:FindFirstChild("FPS_Hub_Highlight") 
                    if h then h:Destroy() end 
                end 
            end
        end
    end
})

------------------------------------------------
-- AIMBOT (Automático ao mirar)
------------------------------------------------
AimTab:CreateToggle({
    Name = "🎯 Aimbot Automático",
    CurrentValue = false,
    Callback = function(v)
        aimOn = v
    end
})

------------------------------------------------
-- LOOP PRINCIPAL (RenderStepped Unificado)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- 1. LOOP INFINITO DO RGB CENTRALIZADO
    if hitboxOn then
        local hue = tick() % 5 / 5 -- Geração do ciclo de cor baseado no relógio do jogo
        local dynamicColor = Color3.fromHSV(hue, 1, 1)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                forceHighlight(p.Character) -- Garante auto-correção se sumir
                
                local hl = p.Character:FindFirstChild("FPS_Hub_Highlight")
                if hl then
                    hl.FillColor = dynamicColor
                    hl.OutlineColor = dynamicColor
                end
            end
        end
    end

    -- 2. LÓGICA DO AIMBOT
    currentTarget = nil -- Reseta a cada frame para validação do painel
    if aimOn then
        local closest = nil
        local dist = math.huge
        local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    
                    if onScreen and magnitude < 300 then 
                        if magnitude < dist then
                            closest = p.Character -- Guarda o personagem completo
                            dist = magnitude
                        end
                    end
                end
            end
        end
        
        if closest then
            currentTarget = closest
            local root = closest:FindFirstChild("HumanoidRootPart")
            if root then
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, root.Position), 0.15)
            end
        end
    end

    -- 3. ATUALIZAÇÃO DO PAINEL DE COORDENADAS (Da cabeça do Humanoid focado)
    if MainFrame.Visible then
        if currentTarget and currentTarget:FindFirstChild("Head") then
            local headPos = currentTarget.Head.Position
            -- Formata strings com apenas 2 casas decimais para ficar limpo
            CoordLabel.Text = string.format("X: %.2f\nY: %.2f\nZ: %.2f", headPos.X, headPos.Y, headPos.Z)
            CoordLabel.TextColor3 = Color3.fromRGB(0, 255, 127) -- Verde se tiver rastreando
        else
            CoordLabel.Text = "NENHUM ALVO\nFOCADO NO\nMOMENTO"
            CoordLabel.TextColor3 = Color3.fromRGB(255, 65, 65) -- Vermelho se estiver sem alvo
        end
    end
end)

print("FPS HUB MOBILE PRO V7.0 Carregado!")
