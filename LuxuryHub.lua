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

print("[LuxuryHub] Auto Drive carregado ✔")-- =============================================
-- ABA: BOOM BOX (Músicas + Database)
-- =============================================
local BoomTab = Window:Tab({ Title = "Boom Box", Icon = "music" })

local BoomState = {
	Sound = nil,
	Database = { Musicas = {}, Ordem = {} },
	Arquivo = "LuxuryHub_Musicas.json",
}

-- ============================================
-- TOCAR MÚSICA
-- ============================================
local function TocarMusica(id)
	pcall(function()
		if BoomState.Sound then BoomState.Sound:Destroy() end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. id
		sound.Volume = 2
		sound.Parent = hrp or Workspace
		sound:Play()
		BoomState.Sound = sound
	end)
end

local function PararMusica()
	if BoomState.Sound then
		pcall(function()
			BoomState.Sound:Stop()
			BoomState.Sound:Destroy()
		end)
		BoomState.Sound = nil
	end
end

-- ============================================
-- SERIALIZAÇÃO DA DATABASE
-- ============================================
local function SerializarDB()
	local linhas = {"{"}
	table.insert(linhas, '  "ordem": [')
	for i, id in ipairs(BoomState.Database.Ordem) do
		local virg = i < #BoomState.Database.Ordem and "," or ""
		table.insert(linhas, '    "' .. id .. '"' .. virg)
	end
	table.insert(linhas, "  ],")
	table.insert(linhas, '  "musicas": {')
	local ids = {}
	for id, _ in pairs(BoomState.Database.Musicas) do table.insert(ids, id) end
	for i, id in ipairs(ids) do
		local m = BoomState.Database.Musicas[id]
		local virg = i < #ids and "," or ""
		local nome = (m.nome or ""):gsub('"', '\\"')
		local dataAdicao = m.dataAdicao or ""
		table.insert(linhas, '    "' .. id .. '": {"nome": "' .. nome .. '", "data": "' .. dataAdicao .. '"}' .. virg)
	end
	table.insert(linhas, "  }")
	table.insert(linhas, "}")
	return table.concat(linhas, "\n")
end

local function DeserializarDB(texto)
	local db = { Musicas = {}, Ordem = {} }
	if not texto or texto == "" then return db end
	local ordemBloco = texto:match('"ordem"%s*:%s*%[(.-)%]')
	if ordemBloco then
		for id in ordemBloco:gmatch('"([^"]+)"') do
			table.insert(db.Ordem, id)
		end
	end
	local musicasBloco = texto:match('"musicas"%s*:%s*%{(.-)%s*}%s*$')
	if musicasBloco then
		for id, corpo in musicasBloco:gmatch('"([^"]+)"%s*:%s*{(.-)}') do
			local nome = corpo:match('"nome"%s*:%s*"([^"]*)"') or ""
			local dataAdicao = corpo:match('"data"%s*:%s*"([^"]*)"') or ""
			db.Musicas[id] = { nome = nome, dataAdicao = dataAdicao }
		end
	end
	return db
end

local function CarregarDB()
	pcall(function()
		if readfile and isfile and isfile(BoomState.Arquivo) then
			local texto = readfile(BoomState.Arquivo)
			if texto and texto ~= "" then
				BoomState.Database = DeserializarDB(texto)
			end
		end
	end)
end

local function SalvarDB()
	pcall(function()
		if writefile then
			writefile(BoomState.Arquivo, SerializarDB())
		end
	end)
end

CarregarDB()

-- ============================================
-- CRUD DATABASE
-- ============================================
local function DB_Adicionar(id, nome)
	if not id or id == "" then return false, "ID vazio" end
	if not nome or nome == "" then return false, "Nome vazio" end
	id = tostring(id):gsub("%D", "")
	if id == "" then return false, "ID inválido" end
	if BoomState.Database.Musicas[id] then
		return false, "ID já existe (" .. BoomState.Database.Musicas[id].nome .. ")"
	end
	BoomState.Database.Musicas[id] = {
		nome = nome,
		dataAdicao = os.date("%d/%m/%Y %H:%M"),
	}
	table.insert(BoomState.Database.Ordem, id)
	SalvarDB()
	return true, "Adicionada"
end

local function DB_Remover(id)
	if not BoomState.Database.Musicas[id] then return false, "Não existe" end
	BoomState.Database.Musicas[id] = nil
	for i, v in ipairs(BoomState.Database.Ordem) do
		if v == id then table.remove(BoomState.Database.Ordem, i); break end
	end
	SalvarDB()
	return true, "Removida"
end

local function DB_EditarNome(id, novoNome)
	if not BoomState.Database.Musicas[id] then return false, "Não existe" end
	BoomState.Database.Musicas[id].nome = novoNome
	SalvarDB()
	return true, "Editada"
end

local function DB_Total()
	return #BoomState.Database.Ordem
end

local function DB_Listar()
	local lista = {}
	for i, id in ipairs(BoomState.Database.Ordem) do
		local m = BoomState.Database.Musicas[id]
		if m then
			table.insert(lista, {indice = i, id = id, nome = m.nome, data = m.dataAdicao})
		end
	end
	return lista
end

local function DB_Limpar()
	BoomState.Database = { Musicas = {}, Ordem = {} }
	SalvarDB()
end

-- ============================================
-- UI — MÚSICAS PRONTAS
-- ============================================
BoomTab:Section({ Title = "Músicas Prontas", TextSize = 16 })

local musicasProntas = {
	{Nome = "Meant To Be",       ID = "84321228471359"},
	{Nome = "Sometimes",         ID = "128715303988843"},
	{Nome = "Blodlyn Bloodpop",  ID = "96414211708215"},
}

for _, m in ipairs(musicasProntas) do
	BoomTab:Button({
		Title = m.Nome,
		Icon = "play",
		Callback = function()
			TocarMusica(m.ID)
			Window:Notify({ Title = "Boom Box", Content = "Tocando: " .. m.Nome, Icon = "music", Duration = 2 })
		end,
	})
end

-- ============================================
-- UI — CUSTOM
-- ============================================
BoomTab:Space()
BoomTab:Section({ Title = "Música Custom", TextSize = 16 })

local customIdInput
customIdInput = BoomTab:Input({
	Title = "ID da Música",
	Placeholder = "rbxassetid apenas números...",
	InputIcon = "hash",
	Type = "Input",
	Callback = function(text)
		-- salva o valor digitado
		if text and text ~= "" then
			customIdInput._value = text
		end
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Tocar Música",
	Icon = "play-circle",
	Callback = function()
		local id = customIdInput._value
		if id and id ~= "" then
			TocarMusica(id)
			Window:Notify({ Title = "Boom Box", Content = "Tocando ID: " .. id, Icon = "music" })
		else
			Window:Notify({ Title = "Erro", Content = "Digite um ID primeiro!", Icon = "x-circle" })
		end
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Parar Música",
	Icon = "square",
	Callback = function()
		PararMusica()
		Window:Notify({ Title = "Boom Box", Content = "Música parada", Icon = "square" })
	end,
})

-- ============================================
-- UI — DATABASE
-- ============================================
BoomTab:Space()
BoomTab:Section({ Title = "Database de Músicas", TextSize = 16 })

local novoNomeMusica = ""
local novoIdMusica = ""

BoomTab:Input({
	Title = "Nome da Música",
	Placeholder = "ex: Meant To Be",
	InputIcon = "type",
	Type = "Input",
	Callback = function(t) novoNomeMusica = t or "" end,
})

BoomTab:Space()

BoomTab:Input({
	Title = "ID da Música",
	Placeholder = "ex: 84321228471359",
	InputIcon = "hash",
	Type = "Input",
	Callback = function(t) novoIdMusica = t or "" end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Salvar na Database",
	Desc = "Adiciona a música ao banco",
	Icon = "save",
	Callback = function()
		local ok, msg = DB_Adicionar(novoIdMusica, novoNomeMusica)
		if ok then
			TocarMusica(novoIdMusica)
			Window:Notify({ Title = "Database", Content = "Adicionada: " .. novoNomeMusica, Icon = "check-circle", Duration = 3 })
			print("[DB] Adicionada:", novoNomeMusica, "| ID:", novoIdMusica)
			print("[DB] Total:", DB_Total())
		else
			Window:Notify({ Title = "Database", Content = "Erro: " .. msg, Icon = "x-circle", Duration = 3 })
		end
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Listar Database",
	Desc = "Mostra todas no console (F9)",
	Icon = "list",
	Callback = function()
		local lista = DB_Listar()
		print("=== DATABASE DE MÚSICAS ===")
		print("Total: " .. DB_Total())
		if #lista == 0 then
			print("(vazia)")
		else
			for _, m in ipairs(lista) do
				print(string.format("[%d] %s | ID: %s | Adicionada em: %s",
					m.indice, m.nome, m.id, m.data or "?"))
			end
		end
		Window:Notify({ Title = "Database", Content = DB_Total() .. " músicas", Icon = "list", Duration = 3 })
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Tocar Database Inteira",
	Desc = "Toca todas em sequência",
	Icon = "list-music",
	Callback = function()
		local lista = DB_Listar()
		if #lista == 0 then
			Window:Notify({ Title = "Database", Content = "Vazia", Icon = "x-circle" })
			return
		end
		task.spawn(function()
			for _, m in ipairs(lista) do
				TocarMusica(m.id)
				Window:Notify({ Title = "Tocando", Content = m.nome, Icon = "music", Duration = 2 })
				local dur = 5
				pcall(function()
					if BoomState.Sound then
						local t = 0
						while BoomState.Sound.TimeLength == 0 and t < 3 do
							task.wait(0.1); t = t + 0.1
						end
						dur = math.max(BoomState.Sound.TimeLength, 3)
					end
				end)
				task.wait(dur + 0.3)
			end
		end)
	end,
})

-- ============================================
-- UI — EDITAR / REMOVER
-- ============================================
BoomTab:Space()
BoomTab:Section({ Title = "Editar / Remover", TextSize = 16 })

local idParaEditar = ""
local novoNomeEdicao = ""

BoomTab:Input({
	Title = "ID para Editar",
	Placeholder = "cole o ID aqui",
	InputIcon = "edit-3",
	Type = "Input",
	Callback = function(t) idParaEditar = (t or ""):gsub("%D", "") end,
})

BoomTab:Space()

BoomTab:Input({
	Title = "Novo Nome",
	Placeholder = "novo nome da música",
	InputIcon = "type",
	Type = "Input",
	Callback = function(t) novoNomeEdicao = t or "" end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Editar Nome",
	Icon = "edit",
	Callback = function()
		if idParaEditar == "" or novoNomeEdicao == "" then
			Window:Notify({ Title = "Database", Content = "Preencha ID e novo nome", Icon = "x-circle" })
			return
		end
		local ok, msg = DB_EditarNome(idParaEditar, novoNomeEdicao)
		Window:Notify({ Title = "Database", Content = msg, Icon = "check-circle" })
		print("[DB]", msg, "| ID:", idParaEditar)
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Remover Música",
	Icon = "trash",
	Callback = function()
		if idParaEditar == "" then
			Window:Notify({ Title = "Database", Content = "Cole um ID acima", Icon = "x-circle" })
			return
		end
		local ok, msg = DB_Remover(idParaEditar)
		Window:Notify({ Title = "Database", Content = msg, Icon = "check-circle" })
		print("[DB]", msg, "| ID:", idParaEditar)
	end,
})

-- ============================================
-- UI — FERRAMENTAS
-- ============================================
BoomTab:Space()
BoomTab:Section({ Title = "Ferramentas", TextSize = 16 })

BoomTab:Button({
	Title = "Exportar Database",
	Desc = "Copia o JSON pro clipboard",
	Icon = "clipboard",
	Callback = function()
		local json = SerializarDB()
		if setclipboard then pcall(setclipboard, json) end
		print("=== JSON EXPORTADO ===")
		print(json)
		Window:Notify({ Title = "Database", Content = "Exportado pro clipboard", Icon = "check-circle" })
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Backup Database",
	Desc = "Salva um arquivo extra",
	Icon = "hard-drive",
	Callback = function()
		pcall(function()
			if writefile then
				local backup = "LuxuryHub_Backup_" .. os.date("%Y%m%d_%H%M%S") .. ".json"
				writefile(backup, SerializarDB())
				Window:Notify({ Title = "Database", Content = "Backup: " .. backup, Icon = "check-circle" })
				print("[DB] Backup:", backup)
			else
				Window:Notify({ Title = "Database", Content = "Executor não suporta", Icon = "x-circle" })
			end
		end)
	end,
})

BoomTab:Space()

BoomTab:Button({
	Title = "Limpar Toda a Database",
	Icon = "trash-2",
	Callback = function()
		DB_Limpar()
		Window:Notify({ Title = "Database", Content = "Database limpa", Icon = "trash-2" })
	end,
})

print("[LuxuryHub] Boom Box carregado ✔")--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 6/9 — ᴀᴜᴛᴏ ᴅʀɪᴠᴇ ᴜɴɪꜰɪᴄᴀᴅᴏ (ᴅɪᴠᴇ + ɪɴᴛᴇʟ + ᴀɪᴍʙᴏᴛ) ]]

DriveTab = Window:Tab({ Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Icon = "car" })

-- ============================================================
-- BOTÕES GK
-- ============================================================
GKBotoes = {}

function EscanearBotoesGK()
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
EscanearBotoesGK()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    EscanearBotoesGK()
end)

function EncontrarBotaoPorTexto(texto)
    for _, info in ipairs(GKBotoes) do
        if info.Texto and info.Texto:lower() == texto:lower() then return info.Button end
    end
    for _, info in ipairs(GKBotoes) do
        if info.Texto and info.Texto:lower():find(texto:lower(), 1, true) then return info.Button end
    end
    return nil
end
function ClicarBotao(botao)
    if not botao then return end
    pcall(function() firesignal(botao.Activated) end)
    pcall(function() firesignal(botao.MouseButton1Click) end)
    pcall(function() firesignal(botao.MouseButton1Down) end)
    pcall(function() firesignal(botao.MouseButton1Up) end)
    pcall(function() firesignal(botao.TouchTap) end)
end
function Pular()
    pcall(function() Humanoid.Jump = true end)
    pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
end

-- ============================================================
-- ANÁLISE DE BOLA (lado + altura + se está vindo)
-- ============================================================
function AnalisarBolaInfo()
    local ball = GetValidBall()
    if not ball or not RootPart then return nil end
    local vel = ball.AssemblyLinearVelocity
    local dist = (ball.Position - RootPart.Position).Magnitude
    local tempo = 0
    if vel.Magnitude > 3 then
        tempo = math.clamp(dist / vel.Magnitude, 0, 0.6)
    end
    local posFutura = ball.Position + (vel * tempo)
    local camLook = Camera.CFrame.LookVector
    local camRight = Camera.CFrame.RightVector
    local frenteH = Vector3.new(camLook.X, 0, camLook.Z)
    if frenteH.Magnitude < 0.1 then frenteH = Vector3.new(0, 0, -1) end
    frenteH = frenteH.Unit
    local direitaH = Vector3.new(camRight.X, 0, camRight.Z)
    if direitaH.Magnitude < 0.1 then direitaH = Vector3.new(1, 0, 0) end
    direitaH = direitaH.Unit
    local delta = posFutura - RootPart.Position
    local deltaH = Vector3.new(delta.X, 0, delta.Z)
    local lado = deltaH:Dot(direitaH)
    local altura = posFutura.Y - RootPart.Position.Y

    -- se a bola está vindo pro player (dot product)
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
-- ESCOLHA E CLIQUE DO BOTÃO (decide tudo)
-- ============================================================
function DecidirBotao(info)
    local lado = info.lado
    local altura = info.altura
    local ladoAbs = math.abs(lado)
    local bolaAlta = altura > AutoDiveHeightThreshold
    local bolaLateral = ladoAbs >= 2.5

    if bolaLateral then
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

function DispararBotao(info)
    if not info then return end
    local texto, pular = DecidirBotao(info)
    if not texto then return end
    if pular then
        task.spawn(Pular)
    end
    local botao = EncontrarBotaoPorTexto(texto)
    if botao then ClicarBotao(botao) end
end

-- ============================================================
-- CONFIGURAÇÕES
-- ============================================================
AutoDriveEnabled = false
AutoDriveConn = nil
AutoDriveCooldown = 0.35
AutoDriveLast = 0
AutoDriveRange = 20
AutoDiveHeightThreshold = 3.5
AutoDriveDotThreshold = 0.15
AutoDriveMinSpeed = 5

-- ============================================================
-- LOOP ÚNICO (não briga consigo mesmo)
-- ============================================================
function StartAutoDrive()
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

        -- Só dispara se a bola está vindo pra você
        if not info.vindo then return end

        AutoDriveLast = tick()
        DispararBotao(info)
    end)
end

function StopAutoDrive()
    if AutoDriveConn then
        AutoDriveConn:Disconnect()
        AutoDriveConn = nil
    end
end

-- ============================================================
-- UI
-- ============================================================
DriveTab:Section({ Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ" })
DriveTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴅʀɪᴠᴇ",
    Desc = "ᴅɪᴠᴇ + ᴀᴄ ɪɴᴛᴇʟ ᴜɴɪꜰɪᴄᴀᴅᴏꜱ · ꜱó ᴘᴀʀᴀ ǫᴜᴀɴᴅᴏ ᴅᴇꜱʟɪɢᴀʀ",
    Value = false,
    Callback = function(v)
        AutoDriveEnabled = v
        if v then
            StartAutoDrive()
        else
            StopAutoDrive()
        end
    end,
})
DriveTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ",
    Value = { Min = 5, Max = 50, Default = 20 },
    Callback = function(v) AutoDriveRange = v end,
})
DriveTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ",
    Value = { Min = 1, Max = 30, Default = 35, Suffix = " x0.01s" },
    Callback = function(v) AutoDriveCooldown = v / 100 end,
})
DriveTab:Slider({
    Title = "ᴀʟᴛᴜʀᴀ (ʙᴏʟᴀ ᴀʟᴛᴀ)",
    Desc = "ᴀᴄɪᴍᴀ ᴅᴇꜱꜱᴀ ᴀʟᴛᴜʀᴀ ᴜꜱᴀ ʜɪɢʜ ᴄᴀᴛᴄʜ ᴏᴜ ʜɪɢʜ ᴅɪᴠᴇ",
    Value = { Min = 10, Max = 100, Default = 35, Suffix = " x0.1" },
    Callback = function(v) AutoDiveHeightThreshold = v / 10 end,
})
DriveTab:Slider({
    Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴍíɴɪᴍᴀ ᴅᴀ ʙᴏʟᴀ",
    Value = { Min = 1, Max = 30, Default = 5 },
    Callback = function(v) AutoDriveMinSpeed = v end,
})
DriveTab:Toggle({
    Title = "ᴍᴏᴅᴏ ꜰɪxᴏ (ᴅᴇꜱᴀᴛɪᴠᴀᴅᴏ = ᴀᴜᴛᴏ)",
    Desc = "ᴛᴏᴅᴏꜱ ᴏꜱ ᴅɪᴠᴇꜱ ᴜꜱᴀᴍ ᴏ ᴍᴇꜱᴍᴏ ʙᴏᴛãᴏ",
    Value = false,
    Callback = function(v) AutoDriveForceMode = v end,
})
DriveTab:Dropdown({
    Title = "ʙᴏᴛãᴏ ꜰɪxᴏ",
    Values = {"Auto", "High Dive Left", "High Dive Right", "Dive Left", "Dive Right", "High Catch", "Low Catch", "Reflex", "Front Dive", "Rush"},
    Value = "Auto",
    Callback = function(v) AutoDriveFixedButton = v end,
})
DriveTab:Button({
    Title = "ʀᴇᴇꜱᴄᴀɴᴇᴀʀ ʙᴏᴛõᴇꜱ ɢᴋ",
    Desc = "ᴜꜱᴇ ᴅᴇᴘᴏɪꜱ ᴅᴇ ᴇɴᴛʀᴀʀ ᴄᴏᴍᴏ ɢᴏʟᴇɪʀᴏ",
    Callback = function()
        EscanearBotoesGK()
        pcall(function() WindUI:Notify({Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Content = #GKBotoes .. " ʙᴏᴛõᴇꜱ ᴇɴᴄᴏɴᴛʀᴀᴅᴏꜱ", Duration = 3}) end)
    end,
})

-- Suporte ao modo fixo
AutoDriveForceMode = false
AutoDriveFixedButton = "Auto"

-- Patch no DispararBotao pra respeitar o modo fixo
_OriginalDispararBotao = DispararBotao
function DispararBotao(info)
    if AutoDriveForceMode and AutoDriveFixedButton ~= "Auto" then
        local botao = EncontrarBotaoPorTexto(AutoDriveFixedButton)
        if botao then ClicarBotao(botao) end
        return
    end
    _OriginalDispararBotao(info)
end

-- ============================================================
-- AIMBOT (mantido)
-- ============================================================
AimbotBlueEnabled = false
AimbotGreenEnabled = false

function doAimbot(direcaoGol)
    local ball = GetValidBall()
    if not ball or not ball.Parent then return end
    if not RootPart or not RootPart.Parent then return end
    local vel = ball.AssemblyLinearVelocity
    if vel.Magnitude < 15 then return end
    local golPos = ScanGoalPosition(direcaoGol)
    if not golPos then return end
    local dirGol = (Vector3.new(golPos.X - ball.Position.X, 0, golPos.Z - ball.Position.Z)).Unit
    local velH = Vector3.new(vel.X, 0, vel.Z)
    if velH.Magnitude < 0.1 then return end
    local velAlvo = velH.Unit:Lerp(dirGol, 0.25)
    ball.AssemblyLinearVelocity = Vector3.new(velAlvo.X * velH.Magnitude, vel.Y, velAlvo.Z * velH.Magnitude)
    ball.AssemblyAngularVelocity = Vector3.zero
end

DriveTab:Section({ Title = "ᴀɪᴍʙᴏᴛ ɢᴏʟ" })
DriveTab:Toggle({
    Title = "ᴀɪᴍʙᴏᴛ ʙʟᴜᴇ",
    Desc = "ʀᴇᴅɪʀᴇᴄɪᴏɴᴀ ᴀ ʙᴏʟᴀ ᴘʀᴏ ɢᴏʟ ᴀᴢᴜʟ",
    Value = false,
    Callback = function(v) AimbotBlueEnabled = v end,
})
DriveTab:Toggle({
    Title = "ᴀɪᴍʙᴏᴛ ɢʀᴇᴇɴ",
    Desc = "ʀᴇᴅɪʀᴇᴄɪᴏɴᴀ ᴀ ʙᴏʟᴀ ᴘʀᴏ ɢᴏʟ ᴠᴇʀᴅᴇ",
    Value = false,
    Callback = function(v) AimbotGreenEnabled = v end,
})

RunService.PreRender:Connect(function()
    if AimbotBlueEnabled then doAimbot("Blue") end
    if AimbotGreenEnabled then doAimbot("Green") end
end)

-- ============================================================
-- ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ (ʀᴇᴍᴏᴛᴇ)
-- ============================================================
CatchRemote = nil
pcall(function()
    CatchRemote = ReplicatedStorage:FindFirstChild("CatchBall", true)
end)
AutoCatchEnabled = false
AutoCatchRange = 8
AutoCatchDelay = 1
AutoCatchLast = 0
AC_Hitbox = false
AC_HitboxPart = nil

function TryCatch(ball)
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

DriveTab:Section({ Title = "ᴀᴄ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ (ʀᴇᴍᴏᴛᴇ)" })
DriveTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ",
    Value = false,
    Callback = function(v) AutoCatchEnabled = v end,
})
DriveTab:Slider({
    Title = "ᴅɪꜱᴛâɴᴄɪᴀ",
    Value = { Min = 3, Max = 30, Default = 8 },
    Callback = function(v) AutoCatchRange = v end,
})
DriveTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ",
    Value = { Min = 2, Max = 30, Default = 10, Suffix = " x0.1s" },
    Callback = function(v) AutoCatchDelay = v / 10 end,
})
DriveTab:Toggle({
    Title = "ᴍᴏꜱᴛʀᴀʀ ʜɪᴛʙᴏx",
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
