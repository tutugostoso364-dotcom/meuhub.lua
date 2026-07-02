-- FPS TEST HUB - RAYFIELD

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Adicionado para detectar o clique da mira

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
    Name = "FPS TEST HUB",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "Dev Version"
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

------------------------------------------------
-- SPEED TEST
------------------------------------------------

local speedOn = false
local speedValue = 30

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

PlayerTab:CreateToggle({
    Name = "🏃 Speed",
    CurrentValue = false,
    Callback = function(v)
        speedOn = v
        if v then
            getHumanoid().WalkSpeed = speedValue
        else
            getHumanoid().WalkSpeed = 16
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Velocidade",
    Range = {16, 80},
    Increment = 1,
    CurrentValue = 30,
    Callback = function(v)
        speedValue = v
        if speedOn then
            getHumanoid().WalkSpeed = v
        end
    end
})

------------------------------------------------
-- RGB HIGHLIGHT (Contorno de TODOS os Personagens)
------------------------------------------------

local hitboxOn = false
local connections = {} -- Guarda os eventos para não dar lag

local function applyHighlight(char)
    if not char then return end
    
    -- Se já tiver um Highlight antigo, remove para não acumular
    local oldHl = char:FindFirstChildOfClass("Highlight")
    if oldHl then oldHl:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = char

    local hue = 0
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        if hl.Parent and char:FindFirstChild("Humanoid") then
            hue = hue + 0.01
            local color = Color3.fromHSV(hue % 1, 1, 1)
            hl.FillColor = color
            hl.OutlineColor = color
        else
            renderConn:Disconnect()
        end
    end)
end

local function enableBoxes()
    -- Aplica em todo mundo que já está no servidor
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            if p.Character then
                applyHighlight(p.Character)
            end
            
            -- Detecta quando esse jogador morrer e renascer para reaplicar o efeito!
            local conn = p.CharacterAdded:Connect(function(char)
                if hitboxOn then
                    task.wait(0.5) -- Espera o boneco carregar completamente
                    applyHighlight(char)
                end
            end)
            table.insert(connections, conn)
        end
    end
end

local function disableBoxes()
    -- Desconecta os eventos de spawn
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}

    -- Remove o visual de todos os bonecos do mapa
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChildOfClass("Highlight")
            if hl then hl:Destroy() end
        end
    end
end

VisualTab:CreateToggle({
    Name = "🌈 RGB Corpo",
    CurrentValue = false,
    Callback = function(v)
        hitboxOn = v
        if v then
            enableBoxes()
        else
            disableBoxes()
        end
    end
})

-- Cuida de novos jogadores que entrarem no servidor depois que você já abriu o menu
Players.PlayerAdded:Connect(function(p)
    local conn = p.CharacterAdded:Connect(function(char)
        if hitboxOn then
            task.wait(0.5)
            applyHighlight(char)
        end
    end)
    if hitboxOn then table.insert(connections, conn) end
end)

------------------------------------------------
-- AIM NO CORPO (Apenas ao Mirar / Segurar Botão Direito)
------------------------------------------------

local aimOn = false
local holdingAimButton = false -- Controla se você está segurando o botão de mira

-- Detecta quando aperta e solta o Botão Direito do Mouse (MouseButton2)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingAimButton = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingAimButton = false
    end
end)

local function getClosestPlayer()
    local closest = nil
    local distance = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = p.Character:FindFirstChild("Humanoid")

            -- Verifica se o inimigo está vivo
            if root and humanoid and humanoid.Health > 0 then
                local screen, onScreen = camera:WorldToViewportPoint(root.Position)

                if onScreen then
                    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local targetPos = Vector2.new(screen.X, screen.Y)
                    local mag = (targetPos - mousePos).Magnitude

                    if mag < distance then
                        distance = mag
                        closest = root
                    end
                end
            end
        end
    end

    return closest
end

AimTab:CreateToggle({
    Name = "🎯 Aim Corpo",
    CurrentValue = false,
    Callback = function(v)
        aimOn = v
    end
})

RunService.RenderStepped:Connect(function()
    -- Só vai mirar se o Script estiver Ativado E você estiver segurando o Botão Direito do mouse
    if aimOn and holdingAimButton then
        local target = getClosestPlayer()

        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
            camera.CFrame = CFrame.lookAt(
                camera.CFrame.Position,
                target.Position
            )
        end
    end
end)

print("FPS TEST HUB carregado")
