-- BRAYAN HUB - MOBILE PRO (Versão v16.0 - Correção Total de Geometria Mobile)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({Name = "Brayan Hub", LoadingTitle = "Inicializando...", LoadingSubtitle = "Sincronizado v16.0"})
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local aimOn = false
local advancedAimOn = false
local advancedAimFOV = 150
local magicBulletOn = false
local visualsOn = false

local globalClosestHead = nil
local boxes = {}
local lines = {}

-- Círculo FOV com criação robusta
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

local function clearVisuals(p)
    if boxes[p] then boxes[p]:Remove(); boxes[p] = nil end
    if lines[p] then lines[p]:Remove(); lines[p] = nil end
    if p.Character then
        local h = p.Character:FindFirstChild("Brayan_Hub_Highlight")
        if h then h:Destroy() end
    end
end

-- Interface
VisualTab:CreateToggle({Name = "🌈 Hitbox RGB + ESP", CurrentValue = false, Callback = function(v) visualsOn = v end})
AimTab:CreateToggle({Name = "🎯 Aimbot 1 (Grudar)", CurrentValue = false, Callback = function(v) aimOn = v end})
AimTab:CreateToggle({Name = "⚡ Aimbot 2 (Predição + FOV)", CurrentValue = false, Callback = function(v) advancedAimOn = v; FOVCircle.Visible = v end})
AimTab:CreateSlider({Name = "⭕ Raio do FOV", Min = 50, Max = 400, Default = 150, Callback = function(v) advancedAimFOV = v; FOVCircle.Radius = v end})

RunService.RenderStepped:Connect(function()
    -- Atualização dinâmica do centro e cor
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    FOVCircle.Position = center
    
    local hue = tick() % 5 / 5
    local dynamicColor = Color3.fromHSV(hue, 1, 1)
    FOVCircle.Color = dynamicColor
    
    local shortestDist = math.huge
    local advancedClosestHead = nil
    local advancedShortestDist = advancedAimFOV 
    globalClosestHead = nil

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            
            if head and root then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                -- ESP e Hitbox
                if visualsOn then
                    local hl = p.Character:FindFirstChild("Brayan_Hub_Highlight") or Instance.new("Highlight", p.Character)
                    hl.Name = "Brayan_Hub_Highlight"; hl.Adornee = p.Character
                    hl.FillColor = dynamicColor; hl.OutlineColor = dynamicColor
                end

                -- Lógica de Mira
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                
                if onScreen then
                    -- Aimbot 2 (Predição)
                    if advancedAimOn and magnitude < advancedShortestDist then
                        advancedClosestHead = head
                        advancedShortestDist = magnitude
                    end
                    -- Aimbot 1 (Grudar)
                    if aimOn and magnitude < 300 and magnitude < shortestDist then
                        globalClosestHead = head
                        shortestDist = magnitude
                    end
                end
            end
        end
    end

    -- Execução das Miras
    if aimOn and globalClosestHead then
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, globalClosestHead.Position), 0.16)
    elseif advancedAimOn and advancedClosestHead then
        local velocity = advancedClosestHead.Parent:FindFirstChild("HumanoidRootPart") and advancedClosestHead.Parent.HumanoidRootPart.Velocity or Vector3.new(0,0,0)
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, advancedClosestHead.Position + (velocity * 0.12)), 0.2)
    end
end)
