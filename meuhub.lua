-- BRAYAN HUB - MOBILE PRO (Versão V7.5 - Fixed Head Tracker & Clipboard)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v7.5"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local hitboxOn = false
local currentTarget = nil 

-- Variáveis para o sistema de coordenada fixa
local fixedCoords = nil

------------------------------------------------
-- INTERFACE DO PAINEL DE COORDENADAS FIXAS
------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CoordLabel = Instance.new("TextLabel")
local FixButton = Instance.new("TextButton")
local CopyButton = Instance.new("TextButton")

ScreenGui.Name = "BrayanHub_FixedTrackerGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.70, 0, 0.10, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(1, 0, 0.2, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "📍 RASTREADOR DE CABEÇA"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.SourceSansBold

CoordLabel.Name = "CoordLabel"
CoordLabel.Parent = MainFrame
CoordLabel.Position = UDim2.new(0, 0, 0.2, 0)
CoordLabel.Size = UDim2.new(1, 0, 0.45, 0)
CoordLabel.BackgroundTransparency = 1
CoordLabel.Text = "NENHUMA COORDENADA\nFIXADA AINDA."
CoordLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
CoordLabel.TextSize = 12
CoordLabel.Font = Enum.Font.Code

-- Botão de Fixar/Travar a Posição Atual
FixButton.Name = "FixButton"
FixButton.Parent = MainFrame
FixButton.Position = UDim2.new(0.05, 0, 0.68, 0)
FixButton.Size = UDim2.new(0.42, 0, 0.24, 0)
FixButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
FixButton.Text = "🔓 Fixar"
FixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FixButton.TextSize = 12
FixButton.Font = Enum.Font.SourceSansBold

-- Botão de Copiar para o Clipboard
CopyButton.Name = "CopyButton"
CopyButton.Parent = MainFrame
CopyButton.Position = UDim2.new(0.53, 0, 0.68, 0)
CopyButton.Size = UDim2.new(0.42, 0, 0.24, 0)
CopyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CopyButton.Text = "📋 Copiar"
CopyButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CopyButton.TextSize = 12
CopyButton.Font = Enum.Font.SourceSansBold
CopyButton.Interactable = false

-- Ações dos botões da interface gráfica
FixButton.MouseButton1Click:Connect(function()
    if currentTarget and currentTarget:FindFirstChild("Head") then
        local pos = currentTarget.Head.Position
        fixedCoords = string.format("X: %.3f, Y: %.3f, Z: %.3f", pos.X, pos.Y, pos.Z)
        
        CoordLabel.Text = "🔒 FIXADO:\n" .. string.format("X: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
        CoordLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        
        CopyButton.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
        CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyButton.Interactable = true
        FixButton.Text = "🔄 Refixar"
    end
end)

CopyButton.MouseButton1Click:Connect(function()
    if fixedCoords then
        if setclipboard then
            setclipboard(fixedCoords)
            Rayfield:Notify({Name = "Sucesso", Content = "Coordenadas copiadas para a área de transferência!", Duration = 2})
        elseif toclipboard then
            toclipboard(fixedCoords)
            Rayfield:Notify({Name = "Sucesso", Content = "Coordenadas copiadas para a área de transferência!", Duration = 2})
        else
            Rayfield:Notify({Name = "Erro", Content = "Seu executor não suporta cópia automática.", Duration = 3})
        end
    end
end)

VisualTab:CreateToggle({
    Name = "📍 Mostrar Painel de Coordenadas",
    CurrentValue = true,
    Callback = function(v) MainFrame.Visible = v end
})

------------------------------------------------
-- SISTEMA DE HITBOX INQUEBRÁVEL (RGB INFINITO)
------------------------------------------------
local function forceHighlight(char)
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    if not char:FindFirstChild("Brayan_Hub_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "Brayan_Hub_Highlight"
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
                    local h = p.Character:FindFirstChild("Brayan_Hub_Highlight") 
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
    Callback = function(v) aimOn = v end
})

------------------------------------------------
-- LOOP PRINCIPAL (RenderStepped Unificado)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- 1. LOOP INFINITO DO RGB CENTRALIZADO
    if hitboxOn then
        local dynamicColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                forceHighlight(p.Character)
                local hl = p.Character:FindFirstChild("Brayan_Hub_Highlight")
                if hl then
                    hl.FillColor = dynamicColor
                    hl.OutlineColor = dynamicColor
                end
            end
        end
    end

    -- 2. LÓGICA DO AIMBOT
    currentTarget = nil 
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
                            closest = p.Character
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

    -- 3. MONITOR DINÂMICO PRÉ-FIXAÇÃO
    if MainFrame.Visible and not fixedCoords then
        if currentTarget and currentTarget:FindFirstChild("Head") then
            local headPos = currentTarget.Head.Position
            CoordLabel.Text = string.format("X: %.2f\nY: %.2f\nZ: %.2f", headPos.X, headPos.Y, headPos.Z)
            CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            CoordLabel.Text = "MIRANDO: NENHUM ALVO\n\n(Aproxime a mira de um alvo\ne aperte em Fixar)"
            CoordLabel.TextColor3 = Color3.fromRGB(240, 70, 70)
        end
    end
end)

print("Brayan Hub carregado com sucesso!")
