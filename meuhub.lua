-- Puxa a interface Rayfield direto do repositório oficial atualizado
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusZDesign/Rayfield/main/source.lua'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Variáveis de controle
local hitboxAtiva = false
local tamanhoHitbox = 4
local aimbotAtivo = false

-- Criando a Janela do Painel
local Window = Rayfield:CreateWindow({
   Name = "🎯 Solo Rage Hub",
   LoadingTitle = "Iniciando Componentes...",
   LoadingSubtitle = "Apenas para " .. LocalPlayer.Name,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Criando as Abas
local HitboxTab = Window:CreateTab("Hitbox RGB", 4483362458)
local AimTab = Window:CreateTab("Aimbot", 4483362458)

--- ========================================================
--- ABA: HITBOX RGB (SÓ PARA VOCÊ)
--- ===========================
