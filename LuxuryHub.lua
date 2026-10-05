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

print("[Kirtium UI] Parte 2/2 carregada ✔ — UI completa!")-- =============================================
-- PARTE 3/3 | Auto Drive Unificado
-- Dive + Aimbot + AutoCatch (GK Intelligence)
-- =============================================

local KS = _G.KS_UI
if not KS then
	error("Execute as PARTES 1/2 e 2/2 primeiro!")
end

local Window       = KS.Window
local WindUI       = KS.WindUI
local Players      = KS.Players
local Workspace    = KS.Workspace
local RunService   = KS.RunService
local UserInputService = KS.UserInputService
local LocalPlayer  = KS.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Refs do personagem
local Camera   = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid  = Character:FindFirstChildOfClass("Humanoid")
local RootPart  = Character:FindFirstChild("HumanoidRootPart")

-- ============================================================
-- HELPERS — GetValidBall / ScanGoalPosition / GetBall
-- ============================================================
local function GetValidBall()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "TPS" then
			return obj
		end
	end
	return nil
end
KS.GetValidBall = GetValidBall

local function ScanGoalPosition(direction)
	local goalFolder = Workspace:FindFirstChild("Goals")
		or Workspace:FindFirstChild("Goal")
		or Workspace:FindFirstChild("GoalFolder")

	if goalFolder then
		for _, obj in ipairs(goalFolder:GetDescendants()) do
			if obj:IsA("BasePart") then
				local nome = string.lower(obj.Name)
				if (direction == "Blue" and nome:find("blue"))
					or (direction == "Green" and nome:find("green")) then
					return obj.Position
				end
			end
		end
	end

	-- Fallback fixo
	if direction == "Blue" then
		return Vector3.new(-9, -27, -199)
	elseif direction == "Green" then
		return Vector3.new(-20, -29, 379)
	end
	return nil
end
KS.ScanGoalPosition = ScanGoalPosition

-- ============================================================
-- BOTÕES GK (GOLEIRO)
-- ============================================================
local GKBotoes = {}

local function EscanearBotoesGK()
	GKBotoes = {}
	pcall(function()
		for _, v in ipairs(PlayerGui:GetDescendants()) do
			if v:IsA("TextButton") or v:IsA("ImageButton") then
				local nome = v.Name
				local texto = ""
				pcall(function() texto = v.Text end)
				if nome:find("GK") or nome:find("C2")
				or texto:find("Dive") or texto:find("Catch")
				or texto:find("High") or texto:find("Low")
				or texto:find("Reflex") or texto:find("Forward")
				or texto:find("Front") or texto:find("Rush") then
					table.insert(GKBotoes, {Button = v, Nome = nome, Texto = texto})
				end
			end
		end
	end)
	print("[Auto Drive] Botões GK encontrados:", #GKBotoes)
end
KS.EscanearBotoesGK = EscanearBotoesGK

EscanearBotoesGK()
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(2)
	EscanearBotoesGK()
end)

local function EncontrarBotaoPorTexto(texto)
	for _, info in ipairs(GKBotoes) do
		if info.Texto and info.Texto:lower() == texto:lower() then
			return info.Button
		end
	end
	for _, info in ipairs(GKBotoes) do
		if info.Texto and info.Texto:lower():find(texto:lower(), 1, true) then
			return info.Button
		end
	end
	return nil
end

local function ClicarBotao(botao)
	if not botao then return end
	pcall(function() firesignal(botao.Activated) end)
	pcall(function() firesignal(botao.MouseButton1Click) end)
	pcall(function() firesignal(botao.MouseButton1Down) end)
	pcall(function() firesignal(botao.MouseButton1Up) end)
	pcall(function() firesignal(botao.TouchTap) end)
end

local function Pular()
	pcall(function() Humanoid.Jump = true end)
	pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
end

-- ============================================================
-- ANÁLISE DA BOLA (lado + altura + vindo?)
-- ============================================================
local function AnalisarBolaInfo()
	local ball = GetValidBall()
	if not ball or not RootPart then return nil end

	local vel  = ball.AssemblyLinearVelocity
	local dist = (ball.Position - RootPart.Position).Magnitude
	local tempo = 0
	if vel.Magnitude > 3 then
		tempo = math.clamp(dist / vel.Magnitude, 0, 0.6)
	end

	local posFutura = ball.Position + (vel * tempo)

	local camLook  = Camera.CFrame.LookVector
	local camRight = Camera.CFrame.RightVector
	local frenteH  = Vector3.new(camLook.X, 0, camLook.Z)
	if frenteH.Magnitude < 0.1 then frenteH = Vector3.new(0, 0, -1) end
	frenteH = frenteH.Unit

	local direitaH = Vector3.new(camRight.X, 0, camRight.Z)
	if direitaH.Magnitude < 0.1 then direitaH = Vector3.new(1, 0, 0) end
	direitaH = direitaH.Unit

	local delta    = posFutura - RootPart.Position
	local deltaH   = Vector3.new(delta.X, 0, delta.Z)
	local lado     = deltaH:Dot(direitaH)
	local altura   = posFutura.Y - RootPart.Position.Y

	-- Se a bola está vindo pro player
	local dirParaPlayer = RootPart.Position - ball.Position
	local dirH = Vector3.new(dirParaPlayer.X, 0, dirParaPlayer.Z)
	local velH = Vector3.new(vel.X, 0, vel.Z)
	local vindo = false
	if dirH.Magnitude > 0.1 and velH.Magnitude > 0.1 then
		vindo = velH.Unit:Dot(dirH.Unit) > 0.15
	end

	return {
		ball = ball,
		vel = vel,
		dist = dist,
		posFutura = posFutura,
		lado = lado,
		altura = altura,
		vindo = vindo,
	}
end

-- ============================================================
-- CONFIG
-- ============================================================
local AutoDriveEnabled        = false
local AutoDriveConn           = nil
local AutoDriveCooldown       = 0.35
local AutoDriveLast           = 0
local AutoDriveRange          = 20
local AutoDiveHeightThreshold = 3.5
local AutoDriveDotThreshold   = 0.15
local AutoDriveMinSpeed       = 5
local AutoDriveForceMode      = false
local AutoDriveFixedButton    = "Auto"

-- ============================================================
-- DECISÃO DE BOTÃO
-- ============================================================
local function DecidirBotao(info)
	local lado     = info.lado
	local altura   = info.altura
	local ladoAbs  = math.abs(lado)
	local bolaAlta = altura > AutoDiveHeightThreshold
	local lateral  = ladoAbs >= 2.5

	if lateral then
		if bolaAlta then
			return lado < 0 and "High Dive Left" or "High Dive Right", true
		else
			return lado < 0 and "Dive Left" or "Dive Right", false
		end
	else
		if bolaAlta then
			return "High Catch", true
		else
			return "Low Catch", false
		end
	end
end

-- ============================================================
-- DISPARO
-- ============================================================
local function DispararBotao(info)
	if not info then return end

	-- Modo fixo
	if AutoDriveForceMode and AutoDriveFixedButton ~= "Auto" then
		local b = EncontrarBotaoPorTexto(AutoDriveFixedButton)
		if b then ClicarBotao(b) end
		return
	end

	local texto, pular = DecidirBotao(info)
	if not texto then return end
	if pular then task.spawn(Pular) end

	local botao = EncontrarBotaoPorTexto(texto)
	if botao then ClicarBotao(botao) end
end

-- ============================================================
-- LOOP PRINCIPAL DO AUTO DRIVE
-- ============================================================
local function StartAutoDrive()
	if AutoDriveConn then return end
	if #GKBotoes == 0 then EscanearBotoesGK() end

	AutoDriveConn = RunService.Heartbeat:Connect(function()
		if not AutoDriveEnabled then return end
		if not RootPart or not RootPart.Parent or not Humanoid then return end
		if tick() - AutoDriveLast < AutoDriveCooldown then return end

		local info = AnalisarBolaInfo()
		if not info then return end
		if info.dist > AutoDriveRange then return end
		if info.vel.Magnitude < AutoDriveMinSpeed then return end
		if not info.vindo then return end

		AutoDriveLast = tick()
		DispararBotao(info)
	end)
end

local function StopAutoDrive()
	if AutoDriveConn then
		AutoDriveConn:Disconnect()
		AutoDriveConn = nil
	end
end

-- ============================================================
-- ABA: AUTO DRIVE
-- ============================================================
local DriveTab = Window:Tab({ Title = "Auto Drive", Icon = "car" })
KS.DriveTab = DriveTab

DriveTab:Section({ Title = "Auto Drive" })

DriveTab:Toggle({
	Title = "Ativar Auto Drive",
	Desc = "Dive + AutoCatch inteligente · só dispara quando a bola vem",
	Value = false,
	Callback = function(v)
		AutoDriveEnabled = v
		if v then StartAutoDrive() else StopAutoDrive() end
	end,
})

DriveTab:Space()

DriveTab:Slider({
	Title = "Alcance",
	Value = { Min = 5, Max = 50, Default = 20 },
	Callback = function(v) AutoDriveRange = v end,
})

DriveTab:Space()

DriveTab:Slider({
	Title = "Cooldown",
	Value = { Min = 1, Max = 30, Default = 35, Suffix = " x0.01s" },
	Callback = function(v) AutoDriveCooldown = v / 100 end,
})

DriveTab:Space()

DriveTab:Slider({
	Title = "Altura (bola alta)",
	Desc = "Acima dessa altura usa High Catch / High Dive",
	Value = { Min = 10, Max = 100, Default = 35, Suffix = " x0.1" },
	Callback = function(v) AutoDiveHeightThreshold = v / 10 end,
})

DriveTab:Space()

DriveTab:Slider({
	Title = "Velocidade mínima da bola",
	Value = { Min = 1, Max = 30, Default = 5 },
	Callback = function(v) AutoDriveMinSpeed = v end,
})

DriveTab:Space()

DriveTab:Toggle({
	Title = "Modo fixo (desativado = auto)",
	Desc = "Todos os dives usam o mesmo botão",
	Value = false,
	Callback = function(v) AutoDriveForceMode = v end,
})

DriveTab:Space()

DriveTab:Dropdown({
	Title = "Botão fixo",
	Values = {"Auto", "High Dive Left", "High Dive Right", "Dive Left", "Dive Right", "High Catch", "Low Catch", "Reflex", "Front Dive", "Rush"},
	Value = "Auto",
	Callback = function(v) AutoDriveFixedButton = v end,
})

DriveTab:Space()

DriveTab:Button({
	Title = "Reescanear botões GK",
	Desc = "Use depois de entrar como goleiro",
	Callback = function()
		EscanearBotoesGK()
		pcall(function()
			WindUI:Notify({ Title = "Auto Drive", Content = #GKBotoes .. " botões encontrados", Duration = 3 })
		end)
	end,
})

-- ============================================================
-- AIMBOT
-- ============================================================
local AimbotBlueEnabled = false
local AimbotGreenEnabled = false

local function doAimbot(direcaoGol)
	local ball = GetValidBall()
	if not ball or not ball.Parent then return end
	if not RootPart or not RootPart.Parent then return end

	local vel = ball.AssemblyLinearVelocity
	if vel.Magnitude < 15 then return end

	local golPos = ScanGoalPosition(direcaoGol)
	if not golPos then return end

	local dirGol = Vector3.new(golPos.X - ball.Position.X, 0, golPos.Z - ball.Position.Z)
	if dirGol.Magnitude < 0.1 then return end
	dirGol = dirGol.Unit

	local velH = Vector3.new(vel.X, 0, vel.Z)
	if velH.Magnitude < 0.1 then return end

	local velAlvo = velH.Unit:Lerp(dirGol, 0.25)
	ball.AssemblyLinearVelocity = Vector3.new(velAlvo.X * velH.Magnitude, vel.Y, velAlvo.Z * velH.Magnitude)
	ball.AssemblyAngularVelocity = Vector3.zero
end

DriveTab:Space()
DriveTab:Section({ Title = "Aimbot Gol" })

DriveTab:Toggle({
	Title = "Aimbot Blue",
	Desc = "Redireciona a bola pro gol azul",
	Value = false,
	Callback = function(v) AimbotBlueEnabled = v end,
})

DriveTab:Space()

DriveTab:Toggle({
	Title = "Aimbot Green",
	Desc = "Redireciona a bola pro gol verde",
	Value = false,
	Callback = function(v) AimbotGreenEnabled = v end,
})

RunService.PreRender:Connect(function()
	if AimbotBlueEnabled then doAimbot("Blue") end
	if AimbotGreenEnabled then doAimbot("Green") end
end)

-- ============================================================
-- AUTO CATCH (REMOTE)
-- ============================================================
local CatchRemote = nil
pcall(function()
	CatchRemote = ReplicatedStorage:FindFirstChild("CatchBall", true)
end)

local AutoCatchEnabled = false
local AutoCatchRange   = 8
local AutoCatchDelay   = 1
local AutoCatchLast    = 0
local AC_Hitbox        = false
local AC_HitboxPart    = nil

local function TryCatch(ball)
	if not ball or not ball.Parent then return end
	if CatchRemote then
		pcall(function()
			if CatchRemote:IsA("RemoteEvent") then
				CatchRemote:FireServer(ball)
			elseif CatchRemote:IsA("RemoteFunction") then
				CatchRemote:InvokeServer(ball)
			end
		end)
	end
	AutoCatchLast = tick()
end

DriveTab:Space()
DriveTab:Section({ Title = "Auto Catch (remote)" })

DriveTab:Toggle({
	Title = "Ativar Auto Catch",
	Value = false,
	Callback = function(v) AutoCatchEnabled = v end,
})

DriveTab:Space()

DriveTab:Slider({
	Title = "Distância",
	Value = { Min = 3, Max = 30, Default = 8 },
	Callback = function(v) AutoCatchRange = v end,
})

DriveTab:Space()

DriveTab:Slider({
	Title = "Cooldown",
	Value = { Min = 2, Max = 30, Default = 10, Suffix = " x0.1s" },
	Callback = function(v) AutoCatchDelay = v / 10 end,
})

DriveTab:Space()

DriveTab:Toggle({
	Title = "Mostrar Hitbox",
	Value = false,
	Callback = function(v) AC_Hitbox = v end,
})

RunService.PreRender:Connect(function()
	if not RootPart or not RootPart.Parent or not Humanoid then return end
	local ball = GetValidBall()

	if AutoCatchEnabled and tick() - AutoCatchLast >= AutoCatchDelay then
		local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
		if ball and hrp and (ball.Position - hrp.Position).Magnitude <= AutoCatchRange then
			TryCatch(ball)
		end
	end

	if AC_Hitbox and RootPart and RootPart.Parent then
		local d = AutoCatchRange * 2
		if not AC_HitboxPart or not AC_HitboxPart.Parent then
			AC_HitboxPart = Instance.new("Part")
			AC_HitboxPart.Name = "Manic_AC_Hitbox"
			AC_HitboxPart.Shape = Enum.PartType.Ball
			AC_HitboxPart.Material = Enum.Material.ForceField
			AC_HitboxPart.Color = Color3.fromRGB(0, 200, 255)
			AC_HitboxPart.Transparency = 0.65
			AC_HitboxPart.CanCollide = false
			AC_HitboxPart.CanQuery = false
			AC_HitboxPart.CanTouch = false
			AC_HitboxPart.Anchored = true
			AC_HitboxPart.Parent = Workspace
		end
		AC_HitboxPart.Size = Vector3.new(d, d, d)
		AC_HitboxPart.Position = RootPart.Position
	elseif AC_HitboxPart and AC_HitboxPart.Parent then
		AC_HitboxPart:Destroy()
		AC_HitboxPart = nil
	end
end)

-- ============================================================
-- ATUALIZAR REFS NO RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	Character = char
	Humanoid  = char:FindFirstChildOfClass("Humanoid")
	RootPart  = char:FindFirstChild("HumanoidRootPart")
end)

print("[LuxuryHub] Auto Drive carregado ✔")
