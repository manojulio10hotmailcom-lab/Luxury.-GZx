-- =============================================
-- PARTE 1/2 | Kirtium.qyz UI - WindUI (Fundo Preto)
-- Base + Serviços + Home + Player
-- =============================================

if ui and ui.Destroy then
	ui:Destroy()
end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
if not WindUI then
	error("Falha ao carregar WindUI")
end

-- ============ CONFIG DE FUNDO ============
local Backgrounds = {
	Preto       = "rbxassetid://0",
	BlackHole   = "rbxassetid://129182988208983",
	BlackCat    = "rbxassetid://73996114712615",
	catsamurai  = "rbxassetid://89598194576679",
	Classic     = "rbxassetid://137552094969",
}

local Window = WindUI:CreateWindow({
	Title = "Kirtium.qyz",
	Icon = "crown",
	Theme = "Dark",
	Background = Backgrounds.Preto,
	BackgroundImageTransparency = 1,
	Transparent = false,
	Size = UDim2.fromOffset(620, 460),
})
Window:Tag({
	Title = "v1.0.0",
	Icon = "github",
	Color = Color3.fromHex("#111111"),
	Radius = 0,
})

-- ============ SERVIÇOS ============
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ============ SHARED STATE ============
_G.KS_UI = _G.KS_UI or {}
local KS = _G.KS_UI
KS.Window = Window
KS.WindUI = WindUI
KS.Backgrounds = Backgrounds
KS.Players = Players
KS.Workspace = Workspace
KS.Lighting = Lighting
KS.RunService = RunService
KS.UserInputService = UserInputService
KS.TeleportService = TeleportService
KS.VirtualUser = VirtualUser
KS.HttpService = HttpService
KS.LocalPlayer = LocalPlayer

KS.Config = KS.Config or {
	WalkSpeed   = 16,
	FOV         = 70,
	JumpPower   = 50,
	Gravity     = 196.2,
	AntiAFK     = false,
	Fullbright  = false,
	NoFog       = false,
	InfJump     = false,
}

-- ============ ABA: HOME ============
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })

HomeTab:Section({ Title = "Bem-vindo ao Kirtium.qyz", TextSize = 20 })

HomeTab:Paragraph({
	Title = "Kirtium Hub",
	Desc = "Hub de scripts completo com WindUI, fundo preto, e dezenas de funções prontas. Use o menu lateral para navegar entre as abas.",
	Image = "rbxassetid://75489164889751",
	ImageSize = 48,
	Buttons = {
		{
			Title = "Discord",
			Icon = "message-circle",
			Callback = function()
				Window:Notify({
					Title = "Discord",
					Content = "https://discord.gg/dHtWuMSmSG",
					Icon = "link",
					Duration = 4,
				})
				if setclipboard then
					setclipboard("https://discord.gg/dHtWuMSmSG")
				end
			end,
		},
	},
})

HomeTab:Space()

HomeTab:Button({
	Title = "Rejoin Server",
	Desc = "Reconecta ao mesmo servidor",
	Icon = "refresh-cw",
	Callback = function()
		Window:Notify({
			Title = "Reconectando...",
			Content = "Você voltará ao mesmo servidor",
			Icon = "refresh-cw",
			Duration = 2,
		})
		task.wait(1)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end,
})

HomeTab:Space()

HomeTab:Button({
	Title = "Server Hop",
	Desc = "Entra em um servidor aleatório",
	Icon = "shuffle",
	Callback = function()
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		local ok, result = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and result then
			local data = HttpService:JSONDecode(result)
			for _, srv in pairs(data.data) do
				if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
					return
				end
			end
		end
		Window:Notify({ Title = "Erro", Content = "Nenhum servidor encontrado", Icon = "x-circle" })
	end,
})

-- ============ ABA: PLAYER ============
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
KS.PlayerTab = PlayerTab

PlayerTab:Section({ Title = "Movimento", TextSize = 16 })

PlayerTab:Slider({
	Title = "WalkSpeed",
	Desc = "Velocidade do personagem",
	Value = { Min = 16, Max = 250, Default = 16 },
	Callback = function(v)
		KS.Config.WalkSpeed = v
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = v end
		end
	end,
})

PlayerTab:Space()

PlayerTab:Slider({
	Title = "JumpPower",
	Desc = "Força do pulo",
	Value = { Min = 50, Max = 300, Default = 50 },
	Callback = function(v)
		KS.Config.JumpPower = v
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.UseJumpPower = true; hum.JumpPower = v end
		end
	end,
})

PlayerTab:Space()

PlayerTab:Slider({
	Title = "Field of View",
	Desc = "Campo de visão da câmera",
	Value = { Min = 70, Max = 150, Default = 70 },
	Callback = function(v)
		KS.Config.FOV = v
		if Workspace.CurrentCamera then
			Workspace.CurrentCamera.FieldOfView = v
		end
	end,
})

PlayerTab:Space()

PlayerTab:Section({ Title = "Utilidades", TextSize = 16 })

PlayerTab:Toggle({
	Title = "Infinite Jump",
	Desc = "Permite pular infinitamente no ar",
	Value = false,
	Callback = function(v)
		KS.Config.InfJump = v
	end,
})

PlayerTab:Space()

PlayerTab:Toggle({
	Title = "Anti AFK",
	Desc = "Impede kick por inatividade",
	Value = false,
	Callback = function(v)
		KS.Config.AntiAFK = v
		if v and not _G.AntiAFKConn then
			_G.AntiAFKConn = LocalPlayer.Idled:Connect(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		elseif not v and _G.AntiAFKConn then
			_G.AntiAFKConn:Disconnect()
			_G.AntiAFKConn = nil
		end
	end,
})

PlayerTab:Space()

PlayerTab:Button({
	Title = "Reset Character",
	Desc = "Mata e respawna o personagem",
	Icon = "rotate-ccw",
	Callback = function()
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.Health = 0 end
		end
	end,
})

-- Aplicar walk/jump automaticamente ao respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = KS.Config.WalkSpeed
		hum.UseJumpPower = true
		hum.JumpPower = KS.Config.JumpPower
	end
end)

-- Infinite Jump loop
UserInputService.JumpRequest:Connect(function()
	if KS.Config.InfJump then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end
end)

print("[Kirtium UI] Parte 1/2 carregada ✔")-- =============================================
-- PARTE 2/2 | Kirtium.qyz UI - WindUI
-- Visual + Teleport + Settings + Final
-- =============================================

local KS = _G.KS_UI
if not KS then
	error("Execute a PARTE 1/2 primeiro!")
end

local Window = KS.Window
local WindUI = KS.WindUI
local Backgrounds = KS.Backgrounds
local Players = KS.Players
local Workspace = KS.Workspace
local Lighting = KS.Lighting
local HttpService = KS.HttpService
local LocalPlayer = KS.LocalPlayer
local UserInputService = KS.UserInputService

-- ============ ABA: VISUAL ============
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
KS.VisualTab = VisualTab

VisualTab:Section({ Title = "Iluminação", TextSize = 16 })

VisualTab:Toggle({
	Title = "Fullbright",
	Desc = "Deixa o mapa totalmente iluminado",
	Value = false,
	Callback = function(v)
		KS.Config.Fullbright = v
		if v then
			Lighting.Brightness = 3
			Lighting.ClockTime = 12
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
			Lighting.GlobalShadows = false
		else
			Lighting.Brightness = 2
			Lighting.Ambient = Color3.fromRGB(70, 70, 70)
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			Lighting.GlobalShadows = true
		end
	end,
})

VisualTab:Space()

VisualTab:Toggle({
	Title = "No Fog",
	Desc = "Remove névoa do mapa",
	Value = false,
	Callback = function(v)
		KS.Config.NoFog = v
		if v then
			Lighting.FogEnd = 100000
		else
			Lighting.FogEnd = 1000
		end
	end,
})

VisualTab:Space()

VisualTab:Button({
	Title = "Resetar Iluminação",
	Desc = "Restaura as configurações padrão",
	Icon = "sun",
	Callback = function()
		Lighting.ClockTime = 14
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(70, 70, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = true
	end,
})

VisualTab:Space()

VisualTab:Section({ Title = "Tema da UI", TextSize = 16 })

local selectedBackground = "Preto"
local backgroundDropdown
backgroundDropdown = VisualTab:Dropdown({
	Title = "Fundo da UI",
	Desc = "Escolha o fundo da interface",
	Values = { "Preto", "BlackHole", "BlackCat", "catsamurai", "Classic" },
	Value = "Preto",
	Callback = function(opt)
		selectedBackground = opt
	end,
})

VisualTab:Space()

VisualTab:Button({
	Title = "Aplicar Fundo",
	Desc = "Aplica o fundo selecionado",
	Icon = "image",
	Callback = function()
		local bg = Backgrounds[selectedBackground]
		if bg then
			local ok = pcall(function() Window:SetBackground(bg) end)
			if not ok then
				pcall(function() Window.Background = bg end)
			end
			Window:Notify({
				Title = "Fundo Aplicado",
				Content = selectedBackground,
				Icon = "check-circle",
			})
		end
	end,
})

-- ============ ABA: TELEPORT ============
local TpTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
KS.TpTab = TpTab

TpTab:Section({ Title = "Teleportar para Jogador", TextSize = 16 })

local targetPlayer = nil

TpTab:Dropdown({
	Title = "Jogador",
	Desc = "Escolha um jogador",
	Values = (function()
		local list = {}
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(list, p.Name)
			end
		end
		return list
	end)(),
	Value = "",
	Callback = function(opt)
		targetPlayer = opt
	end,
})

TpTab:Space()

TpTab:Button({
	Title = "Teleportar",
	Desc = "Vai até o jogador selecionado",
	Icon = "arrow-right",
	Callback = function()
		if not targetPlayer then
			Window:Notify({ Title = "Erro", Content = "Selecione um jogador!", Icon = "x-circle" })
			return
		end
		local plr = Players:FindFirstChild(targetPlayer)
		if plr and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and myHrp then
				myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
				Window:Notify({ Title = "Teleportado", Content = targetPlayer, Icon = "check-circle" })
			end
		end
	end,
})

TpTab:Space()

TpTab:Button({
	Title = "Teleportar para Origem",
	Desc = "Vai para 0, 50, 0",
	Icon = "crosshair",
	Callback = function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(0, 50, 0)
			Window:Notify({ Title = "Teleportado", Content = "Origem", Icon = "check-circle" })
		end
	end,
})

TpTab:Space()

TpTab:Section({ Title = "Coordenadas", TextSize = 16 })

local coordXInput, coordYInput, coordZInput

coordXInput = TpTab:Input({
	Title = "X",
	Value = "0",
	Type = "Input",
	Placeholder = "0",
	Callback = function() end,
})

coordYInput = TpTab:Input({
	Title = "Y",
	Value = "50",
	Type = "Input",
	Placeholder = "50",
	Callback = function() end,
})

coordZInput = TpTab:Input({
	Title = "Z",
	Value = "0",
	Type = "Input",
	Placeholder = "0",
	Callback = function() end,
})

TpTab:Space()

TpTab:Button({
	Title = "Ir para Coordenadas",
	Desc = "Teleporta para as coordenadas informadas",
	Icon = "target",
	Callback = function()
		local x = tonumber(coordXInput.Value) or 0
		local y = tonumber(coordYInput.Value) or 50
		local z = tonumber(coordZInput.Value) or 0
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(x, y, z)
			Window:Notify({ Title = "Teleportado", Content = string.format("(%.1f, %.1f, %.1f)", x, y, z), Icon = "check-circle" })
		end
	end,
})

-- ============ ABA: SETTINGS ============
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
KS.SettingsTab = SettingsTab

SettingsTab:Section({ Title = "Configurações da UI", TextSize = 16 })

SettingsTab:Button({
	Title = "Fechar UI",
	Desc = "Fecha a janela principal",
	Icon = "x",
	Callback = function()
		Window:Close()
	end,
})

SettingsTab:Space()

SettingsTab:Button({
	Title = "Minimizar UI",
	Desc = "Minimiza para o ícone flutuante",
	Icon = "minus",
	Callback = function()
		Window:Minimize()
	end,
})

SettingsTab:Space()

SettingsTab:Section({ Title = "Atalhos", TextSize = 16 })

SettingsTab:Paragraph({
	Title = "Teclas Padrão",
	Desc = "• M — Abrir/fechar UI\n• RightShift — Toggle do menu\n• Botão minimizar — esconde para canto",
	Image = "rbxassetid://75489164889751",
	ImageSize = 32,
})

SettingsTab:Space()

SettingsTab:Button({
	Title = "Destruir Tudo",
	Desc = "Remove completamente a UI",
	Icon = "trash-2",
	Callback = function()
		if ui and ui.Destroy then
			ui:Destroy()
		end
		Window:Destroy()
	end,
})

-- ============ KEYBIND E FINAL ============
Window:SetToggleKey(Enum.KeyCode.M)
_G.KirtiumUI = Window

Window:Notify({
	Title = "Kirtium.qyz",
	Content = "UI carregada com sucesso! Aperte M para abrir/fechar.",
	Icon = "check-circle",
	Duration = 4,
})

print("[Kirtium UI] Parte 2/2 carregada ✔ — UI completa!")
