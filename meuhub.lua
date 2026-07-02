-- FPS TEST HUB - RAYFIELD

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
-- RGB HIGHLIGHT (Contorno do Personagem)
------------------------------------------------

local hitboxOn = false
local highlights = {}

local function createHighlight(char)
    if not char then return end

    -- Usa Highlight para contornar o corpo em vez de criar uma caixa fixa
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.5 -- Transparência do preenchimento de dentro
    hl.OutlineTransparency = 0 -- Contorno totalmente visível
    hl.Parent = char

    local hue = 0
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if hl.Parent and char:FindFirstChild("Humanoid") then
            hue = hue + 0.01
            local color = Color3.fromHSV(hue % 1, 1, 1)
            hl.FillColor = color
            hl.OutlineColor = color
        else
            connection:Disconnect()
        end
    end)

    table.insert(highlights, hl)
end

local function enableBoxes()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            createHighlight(p.Character)
        end
    end
end

local function disableBoxes()
    for _, hl in pairs(highlights) do
        if hl then
            hl:Destroy()
        end
    end
    highlights = {}
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

-- Monitora novos jogadores entrando para aplicar o contorno se o toggle estiver ativo
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if hitboxOn then
            task.wait(0.5) -- Pequena espera para carregar o boneco completo
            createHighlight(char)
        end
    end)
end)

------------------------------------------------
-- AIM NO CORPO (Com checagem de Vida)
------------------------------------------------

local aimOn = false

local function getClosestPlayer()
    local closest = nil
    local distance = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = p.Character:FindFirstChild("Humanoid")

            -- Verifica se o jogador tem o root, a humanoid e se ele está VIVO (Health > 0)
            if root and humanoid and humanoid.Health > 0 then
                local screen, onScreen = camera:WorldToViewportPoint(root.Position)

                if onScreen then
                    -- Mede a distância em relação ao centro da sua tela (mira)
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
    if aimOn then
        local target = getClosestPlayer()

        -- Se encontrou um alvo válido e vivo, aponta a câmera para ele
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
            camera.CFrame = CFrame.lookAt(
                camera.CFrame.Position,
                target.Position
            )
        end
    end
end)

print("FPS TEST HUB carregado")
