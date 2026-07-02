-- FPS TEST HUB - RAYFIELD

local Rayfield = loadstring(game:HttpGet(
'https://sirius.menu/rayfield'
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera


local Window = Rayfield:CreateWindow({
    Name = "FPS TEST HUB",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "Dev Version"
})


local PlayerTab = Window:CreateTab("Player",4483362458)
local VisualTab = Window:CreateTab("Visual",4483362458)
local AimTab = Window:CreateTab("Aim",4483362458)


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
    Name="🏃 Speed",
    CurrentValue=false,
    Callback=function(v)

        speedOn = v

        if v then
            getHumanoid().WalkSpeed = speedValue
        else
            getHumanoid().WalkSpeed = 16
        end

    end
})


PlayerTab:CreateSlider({
    Name="Velocidade",
    Range={16,80},
    Increment=1,
    CurrentValue=30,

    Callback=function(v)

        speedValue = v

        if speedOn then
            getHumanoid().WalkSpeed = v
        end

    end
})


------------------------------------------------
-- RGB HITBOX
------------------------------------------------

local hitboxOn=false
local boxes={}


local function createBox(char)

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end


    local box = Instance.new("BoxHandleAdornment")

    box.Adornee=root
    box.Size=Vector3.new(5,7,3)
    box.AlwaysOnTop=true
    box.Transparency=0.45
    box.ZIndex=5
    box.Parent=root


    local hue=0

    RunService.RenderStepped:Connect(function()

        if box.Parent then

            hue += 0.01

            box.Color3 =
            Color3.fromHSV(
                hue%1,
                1,
                1
            )

        end

    end)


    table.insert(boxes,box)

end



local function enableBoxes()

    for _,p in pairs(Players:GetPlayers()) do

        if p ~= player and p.Character then
            createBox(p.Character)
        end

    end

end



local function disableBoxes()

    for _,b in pairs(boxes) do

        if b then
            b:Destroy()
        end

    end

    boxes={}

end



VisualTab:CreateToggle({

    Name="🌈 RGB Corpo",

    CurrentValue=false,

    Callback=function(v)

        hitboxOn=v

        if v then
            enableBoxes()
        else
            disableBoxes()
        end

    end
})



------------------------------------------------
-- AIM NO CORPO
------------------------------------------------

local aimOn=false


local function getClosestPlayer()

    local closest=nil
    local distance=math.huge


    for _,p in pairs(Players:GetPlayers()) do

        if p ~= player and p.Character then

            local root =
            p.Character:FindFirstChild(
            "HumanoidRootPart"
            )


            if root then

                local screen =
                camera:WorldToViewportPoint(
                    root.Position
                )


                local mag =
                Vector2.new(
                    screen.X,
                    screen.Y
                ).Magnitude


                if mag < distance then

                    distance = mag
                    closest=root

                end

            end

        end

    end


    return closest

end



AimTab:CreateToggle({

    Name="🎯 Aim Corpo",

    CurrentValue=false,

    Callback=function(v)

        aimOn=v

    end
})



RunService.RenderStepped:Connect(function()

    if aimOn then

        local target =
        getClosestPlayer()


        if target then

            camera.CFrame =
            CFrame.lookAt(
                camera.CFrame.Position,
                target.Position
            )

        end

    end

end)



print("FPS TEST HUB carregado")
