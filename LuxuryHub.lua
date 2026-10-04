# Luxury.-GZx-- =============================================
-- PARTE 1/5 | Kirtium.qyz (UI Preta)
-- Services + UI + Configs + Bola + Skybox
-- =============================================

local KS = {}
_G.KS = KS

local hitboxAnchor, hitboxFolder, hitboxLines, originalColors
if ui and ui.Destroy then
	ui:Destroy()
end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
if not WindUI then
	error("\xE8\xF1pv\x02\xCC\xCAG\xE3")
end
KS.WindUI = WindUI

local Backgrounds = {BlackCat = "rbxassetid://73996114712615", catsamurai = "rbxassetid://89598194576679", BlackHole = "rbxassetid://129182988208983", ["Classic xiters"] = "rbxassetid://137552094969", Preto = "rbxassetid://0"}
KS.Backgrounds = Backgrounds

local Window = WindUI:CreateWindow({Title = "Kirtium.qyz", Icon = "crown", Theme = "Dark", Background = Backgrounds.Preto, BackgroundImageTransparency = 1, Transparent = false})
Window:Tag({Title = "v0.0.9", Icon = "github", Color = Color3.fromHex("#000000"), Radius = 0})
KS.Window = Window

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

KS.Players = Players
KS.LocalPlayer = LocalPlayer
KS.TeleportService = TeleportService
KS.Workspace = Workspace
KS.VirtualUser = VirtualUser
KS.Lighting = Lighting
KS.RunService = RunService
KS.UserInputService = UserInputService
KS.HttpService = HttpService
KS.ReplicatedStorage = ReplicatedStorage
KS.VirtualInputManager = VirtualInputManager

-- ============ ESTADO GLOBAL ============
local antiAfkEnabled = false
local ballRange = 3
local autoGoalBlue = false
local autoGoalGreen = false
local lastGoalShot = 0
local goalShotCooldown = 2
local ballAtGoal = false
local blueGoalPos = Vector3.new(-9, -27, -199)
local greenGoalPos = Vector3.new(-20, -29, 379)
local reachConfig = {isActive = false, reach = 3, showHitbox = false}
local curveState = {Side = "None", Dip = false, CPower = 0, DPower = 0, Guided = false, Damp = 0.985, Attract = 0.45, Mult = 1, Active = false}
local curvePresets = {["Curve Esquerda"] = {side = "Left", dip = true, cPower = 60, dPower = 20, guided = false, damp = 0.985, attract = 0.45, mult = 1}, ["Curve Direita"] = {side = "Right", dip = false, cPower = 80, dPower = 0, guided = false, damp = 0.985, attract = 0.45, mult = 1}}

KS.S = {
	antiAfkEnabled = antiAfkEnabled,
	ballRange = ballRange,
	autoGoalBlue = autoGoalBlue,
	autoGoalGreen = autoGoalGreen,
	lastGoalShot = lastGoalShot,
	goalShotCooldown = goalShotCooldown,
	ballAtGoal = ballAtGoal,
	blueGoalPos = blueGoalPos,
	greenGoalPos = greenGoalPos,
	reachConfig = reachConfig,
	curveState = curveState,
	curvePresets = curvePresets,
}

local function applyCurve(U)
	local x9, ya
	x9 = curvePresets[U]
	if not x9 then
		curveState.Side = "None"; curveState.Dip = false
		curveState.CPower = 0; curveState.DPower = 0
		curveState.Guided = false; curveState.Damp = 0.985
		curveState.Attract = 0.45; curveState.Mult = 1
		curveState.Active = false
		return
	end
	curveState.Side = x9.side; curveState.Dip = x9.dip
	curveState.CPower = x9.cPower; curveState.DPower = x9.dPower
	curveState.Guided = x9.guided or false
	curveState.Damp = x9.damp or 0.985
	curveState.Attract = x9.attract or 0.45
	curveState.Mult = x9.mult or 1
	curveState.Active = true
end
KS.applyCurve = applyCurve

-- ============ KEYMAP ============
local keyMap = {Q = Enum.KeyCode.Q, W = Enum.KeyCode.W, E = Enum.KeyCode.E, R = Enum.KeyCode.R, T = Enum.KeyCode.T, Y = Enum.KeyCode.Y, U = Enum.KeyCode.U, I = Enum.KeyCode.I, O = Enum.KeyCode.O, P = Enum.KeyCode.P, A = Enum.KeyCode.A, S = Enum.KeyCode.S, D = Enum.KeyCode.D, F = Enum.KeyCode.F, G = Enum.KeyCode.G, H = Enum.KeyCode.H, J = Enum.KeyCode.J, K = Enum.KeyCode.K, L = Enum.KeyCode.L, Z = Enum.KeyCode.Z, X = Enum.KeyCode.X, C = Enum.KeyCode.C, V = Enum.KeyCode.V, B = Enum.KeyCode.B, N = Enum.KeyCode.N, M = Enum.KeyCode.M, LeftShift = Enum.KeyCode.LeftShift, RightShift = Enum.KeyCode.RightShift, LeftControl = Enum.KeyCode.LeftControl, RightControl = Enum.KeyCode.RightControl, LeftAlt = Enum.KeyCode.LeftAlt, RightAlt = Enum.KeyCode.RightAlt}
KS.keyMap = keyMap

-- ============ AUTO CATCH ============
local autoCatchEnabled = false
local catchDistance = 5
local canCatch = true
local lastCatch = 0
local catchCooldown = 0.3
local holdingBall = false
local CatchBallRemote = ReplicatedStorage:FindFirstChild("CatchBall")
local DropBallRemote = ReplicatedStorage:FindFirstChild("DropBall")
KS.CATCH = {
	get enabled() return autoCatchEnabled end,
	set enabled(v) autoCatchEnabled = v end,
	get distance() return catchDistance end,
	set distance(v) catchDistance = v end,
	get holding() return holdingBall end,
	set holding(v) holdingBall = v end,
	get canCatch() return canCatch end,
	set canCatch(v) canCatch = v end,
	get lastCatch() return lastCatch end,
	set lastCatch(v) lastCatch = v end,
	get cooldown() return catchCooldown end,
	get remote() return CatchBallRemote end,
	get dropRemote() return DropBallRemote end,
}

-- ============ GET BALL ============
local cachedBall = nil
local lastBallScan = 0
local function getBall()
	if cachedBall and cachedBall.Parent and os.clock() - lastBallScan < 0.3 then
		return cachedBall
	end
	lastBallScan = os.clock()
	for _, yn in ipairs(Workspace:GetDescendants()) do
		if yn:IsA("BasePart") and yn.Name == "TPS" then
			cachedBall = yn
			return yn
		end
	end
	cachedBall = nil
	return nil
end
KS.getBall = getBall

local function isBallNear()
	local yp, hrp, dist
	yp = LocalPlayer.Character
	if not yp then return false end
	hrp = yp:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	yp = getBall()
	if not yp then return false end
	dist = (yp.Position - hrp.Position).Magnitude
	return dist < catchDistance + 2
end
KS.isBallNear = isBallNear

local function tryCatch()
	local ball, yv, hrp2
	if not CatchBallRemote then return end
	if not canCatch then return end
	if tick() - lastCatch < catchCooldown then return end
	ball = getBall()
	if not ball then return end
	yv = ball:FindFirstChild("Owner")
	if yv and yv.Value ~= LocalPlayer and yv.Value ~= nil then return end
	yv = LocalPlayer.Character
	if not yv then return end
	hrp2 = yv:FindFirstChild("HumanoidRootPart")
	if not hrp2 then return end
	if (ball.Position - hrp2.Position).Magnitude <= catchDistance then
		pcall(function()
			CatchBallRemote:FireServer(ball)
			lastCatch = tick()
			holdingBall = true
			task.wait(0.1)
		end)
	end
end
KS.tryCatch = tryCatch

local function dropBall()
	if not DropBallRemote then return end
	pcall(function()
		DropBallRemote:FireServer()
		holdingBall = false
	end)
end
KS.dropBall = dropBall

-- ============ SKYBOXES ============
local Skyboxes = loadstring(game:HttpGet("https://pastefy.app/j5e1zeSB/raw"))()
if not Skyboxes then error("Falha ao carregar skyboxes") end

local function clearSky()
	for _, yX in pairs(Lighting:GetChildren()) do
		if yX:IsA("Sky") then yX:Destroy() end
	end
	if Workspace:FindFirstChild("RainFolder") then Workspace.RainFolder:Destroy() end
	if Workspace:FindFirstChild("RainAmbience") then
		Workspace.RainAmbience:Stop()
		Workspace.RainAmbience:Destroy()
	end
end
KS.clearSky = clearSky

local function resetLighting()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(70, 70, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
	Lighting.FogColor = Color3.fromRGB(191, 191, 191)
	Lighting.FogEnd = 100000
	Lighting.ShadowSoftness = 0.2
	Lighting.ExposureCompensation = 0
end

local function applySkybox(bH)
	local y1, sky
	y1 = Skyboxes[bH]
	if not y1 then return end
	clearSky()
	resetLighting()
	sky = Instance.new("Sky")
	sky.SkyboxBk = y1.SkyboxBk
	sky.SkyboxDn = y1.SkyboxDn
	sky.SkyboxFt = y1.SkyboxFt
	sky.SkyboxLf = y1.SkyboxLf
	sky.SkyboxRt = y1.SkyboxRt
	sky.SkyboxUp = y1.SkyboxUp
	sky.Name = bH .. "Skybox"
	sky.Parent = Lighting
end
KS.applySkybox = applySkybox

local function setSunSky()
	clearSky()
	Lighting.ClockTime = 7
	Lighting.Brightness = 2
	Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 255)
	Lighting.Ambient = Color3.fromRGB(255, 210, 160)
	Lighting.FogColor = Color3.fromRGB(255, 170, 100)
	Lighting.FogEnd = 100000
	local bR = Instance.new("Sky")
	bR.SkyboxBk = "rbxassetid://541743453"
	bR.SkyboxDn = "rbxassetid://541743443"
	bR.SkyboxFt = "rbxassetid://541743446"
	bR.SkyboxLf = "rbxassetid://541743436"
	bR.SkyboxRt = "rbxassetid://541743435"
	bR.SkyboxUp = "rbxassetid://541743441"
	bR.Name = "SunSkybox"
	bR.Parent = Lighting
end
KS.setSunSky = setSunSky

local function setMoonSky()
	clearSky()
	Lighting.ClockTime = 21
	Lighting.Brightness = 1
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	Lighting.FogColor = Color3.fromRGB(150, 150, 150)
	Lighting.FogEnd = 100000
	local bV = Instance.new("Sky")
	bV.SkyboxBk = "rbxassetid://4498828382"
	bV.SkyboxDn = "rbxassetid://4498828812"
	bV.SkyboxFt = "rbxassetid://4498829917"
	bV.SkyboxLf = "rbxassetid://4498830911"
	bV.SkyboxRt = "rbxassetid://4498830417"
	bV.SkyboxUp = "rbxassetid://4498831746"
	bV.Name = "MoonSkybox"
	bV.Parent = Lighting
end
KS.setMoonSky = setMoonSky

local function setRainSky()
	local zs, zt, zu, zv, zw, zx, zy, zz, folder, zU, zV, zW
	clearSky()
	Lighting.ClockTime = 21
	Lighting.Brightness = 1
	Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
	Lighting.Ambient = Color3.fromRGB(50, 50, 60)
	Lighting.FogColor = Color3.fromRGB(100, 100, 120)
	Lighting.FogEnd = 100000
	zy = Instance.new("Sky")
	zy.SkyboxBk = "rbxassetid://4498828382"
	zy.SkyboxDn = "rbxassetid://4498828812"
	zy.SkyboxFt = "rbxassetid://4498829917"
	zy.SkyboxLf = "rbxassetid://4498830911"
	zy.SkyboxRt = "rbxassetid://4498830417"
	zy.SkyboxUp = "rbxassetid://4498831746"
	zy.Name = "RainSkybox"
	zy.Parent = Lighting
	zs = 200
	zw = 50
	zt = 120
	zz = Vector3.new(0.05, 3, 0.05)
	folder = Instance.new("Folder")
	folder.Name = "RainFolder"
	folder.Parent = Workspace
	zx, zu = {}, {}
	zU = 1
	while zU <= 50 do
		zV = zU
		zW = zV
		zx[zW] = {x = math.random(-zs / 2, zs / 2), z = math.random(-zs / 2, zs / 2), y = math.random(0, zw)}
		zy = Instance.new("Part")
		zy.Size = zz
		zy.Anchored, zy.CanCollide, zy.CastShadow = true, false, false
		zy.Material, zy.Color, zy.Transparency = Enum.Material.SmoothPlastic, Color3.fromRGB(160, 200, 255), 0.5
		zy.Position = Vector3.new(zx[zW].x, zx[zW].y, zx[zW].z)
		zy.Parent = folder
		zu[zW] = zy
		zU = zU + 1
	end
	zv = nil
	zv = RunService.RenderStepped:Connect(function(cc)
		local y8, char, hrp3, zn, zp
		if not Workspace:FindFirstChild("RainFolder") then
			zv:Disconnect()
			return
		end
		y8 = Vector3.new(0, 0, 0)
		char = LocalPlayer.Character
		if char then
			hrp3 = char:FindFirstChild("HumanoidRootPart")
			if hrp3 then y8 = hrp3.Position end
		end
		for ck, cl in ipairs(zu) do
			zn = ck
			zp = cl
			local zo = zn
			local zq = zp
			zx[zo].y = zx[zo].y - zt * cc
			if zx[zo].y < y8.Y - 10 then
				zx[zo].y = y8.Y + zw
				zx[zo].x = math.random(-zs / 2, zs / 2)
				zx[zo].z = math.random(-zs / 2, zs / 2)
			end
			zq.Position = Vector3.new(y8.X + zx[zo].x, zx[zo].y, y8.Z + zx[zo].z)
		end
	end)
	zy = Instance.new("Sound")
	zy.Name, zy.SoundId, zy.Looped, zy.Volume = "RainAmbience", "rbxassetid://365362615", true, 0.4
	zy.Parent = Workspace
	zy:Play()
end
KS.setRainSky = setRainSky

-- ============ WALK SPEED ============
local walkSpeed = 16
KS.getWalkSpeed = function() return walkSpeed end
KS.setWalkSpeed = function(v) walkSpeed = v end

-- ============ CURVE LOOP ============
RunService.Heartbeat:Connect(function()
	local ball2, z3, z4, z5, z6
	if not curveState.Active then return end
	ball2 = getBall()
	if not ball2 or not ball2:IsA("BasePart") then return end
	z3 = ball2.AssemblyLinearVelocity
	if z3.Magnitude <= 15 then return end
	z4 = LocalPlayer.Character
	z5 = z4 and z4:FindFirstChild("HumanoidRootPart")
	z4 = z5
	z5 = curveState.Guided and z4
	if z5 then
		z5 = z4.Position - ball2.Position
		z4 = z5.Magnitude
		if z4 < 120 and z4 > 3 then
			ball2.AssemblyLinearVelocity = z3 * curveState.Damp + z5.Unit * curveState.Attract * 2.5
			return
		end
	end
	if curveState.Side == "None" and not curveState.Dip and curveState.Mult <= 1 then return end
	z4 = Vector3.zero
	z5 = Vector3.new(z3.X, 0, z3.Z)
	z6 = not (curveState.Side == "None") and z5.Magnitude > 2
	if z6 then
		z6 = z5:Cross(Vector3.yAxis).Unit
		if curveState.Side == "Left" then z6 = -z6 end
		z4 = z4 + z6 * (curveState.CPower / 180)
	end
	if curveState.Dip then z4 = z4 + Vector3.new(0, -(curveState.DPower / 180), 0) end
	if curveState.Mult > 1 and z3.Magnitude < 130 then
		z4 = z4 + z3.Unit * ((curveState.Mult - 1) * 12)
	end
	ball2.AssemblyLinearVelocity = z3 + z4
end)

print("[Kirtium] Parte 1/5 carregada ✔")-- =============================================
-- PARTE 2/5 | Character + Follow + Reach + Hitbox + Skill + Goal + Shoot + Control Ball
-- =============================================
local KS = _G.KS
if not KS then error("Execute a PARTE 1/5 primeiro!") end

local LocalPlayer = KS.LocalPlayer
local Workspace = KS.Workspace
local RunService = KS.RunService
local UserInputService = KS.UserInputService
local VirtualInputManager = KS.VirtualInputManager
local WindUI = KS.WindUI
local keyMap = KS.keyMap

-- ============ WALK SPEED LOOP ============
RunService.Heartbeat:Connect(function()
	local zY, hrp4, z_
	local ws = KS.getWalkSpeed()
	if ws == 16 then return end
	zY = LocalPlayer.Character
	if not zY then return end
	hrp4 = zY:FindFirstChild("HumanoidRootPart")
	z_ = zY:FindFirstChildOfClass("Humanoid")
	zY = hrp4 and z_
	if zY then
		zY = z_.MoveDirection
		if zY.Magnitude > 0.1 then
			z_ = hrp4.AssemblyLinearVelocity
			hrp4.AssemblyLinearVelocity = Vector3.new(zY.X * ws, z_.Y, zY.Z * ws)
		end
	end
end)

-- ============ CHARACTER / FOLLOW ============
local autoFollowEnabled = false
local autoSkillEnabled = false
local skillSpeed = 5
local skillStep = 0
local skillPhase = 0
local character = nil
local humanoid = nil
local rootPart = nil
local followStopDistance = 1.8
local autoFollowKey = Enum.KeyCode.K
local autoFollowKeyName = "K"

KS.F = {
	get enabled() return autoFollowEnabled end,
	set enabled(v) autoFollowEnabled = v end,
	get key() return autoFollowKey end,
	set key(v) autoFollowKey = v end,
	get keyName() return autoFollowKeyName end,
	set keyName(v) autoFollowKeyName = v end,
	get skill() return autoSkillEnabled end,
	set skill(v) autoSkillEnabled = v end,
	get skillSpeed() return skillSpeed end,
	set skillSpeed(v) skillSpeed = v end,
	get skillStep() return skillStep end,
	set skillStep(v) skillStep = v end,
	get skillPhase() return skillPhase end,
	set skillPhase(v) skillPhase = v end,
	get stopDist() return followStopDistance end,
	set stopDist(v) followStopDistance = v end,
}

local function refreshCharacter()
	character = LocalPlayer.Character
	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		rootPart = character:FindFirstChild("HumanoidRootPart")
	end
end
KS.refreshCharacter = refreshCharacter

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	refreshCharacter()
end)
refreshCharacter()

local function isMoving()
	return UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
end
KS.isMoving = isMoving

local function findBall()
	local At, Au
	At = Workspace:FindFirstChild("WorkspaceStadiumSounds")
	if At then
		Au = At:FindFirstChild("TPS")
		if Au and Au:IsA("BasePart") then return Au end
	end
	for _, AH in pairs(Workspace:GetDescendants()) do
		if AH.Name == "TPS" and AH:IsA("BasePart") and not AH.Anchored then return AH end
	end
	return nil
end
KS.findBall = findBall

local function autoFollowStep()
	local AJ, AK, AL
	if not autoFollowEnabled then return end
	if not rootPart or not rootPart.Parent or not humanoid then return end
	AJ = findBall()
	if not AJ then return end
	if isMoving() then return end
	AK = AJ.Position
	AJ = AK - rootPart.Position
	AL = Vector3.new(AJ.X, 0, AJ.Z)
	if AL.Magnitude > followStopDistance and AL.Magnitude < 150 then
		humanoid:Move(AL.Unit, false)
		rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(AK.X, rootPart.Position.Y, AK.Z))
	else
		humanoid:Move(Vector3.zero, false)
	end
end
KS.autoFollowStep = autoFollowStep

local function setAutoFollow(dx)
	autoFollowEnabled = dx
	if not dx and humanoid then humanoid:Move(Vector3.zero, false) end
	KS.updateMobileButton()
end
KS.setAutoFollow = setAutoFollow

-- ============ REACH ============
local function reachStep()
	local hrp5, AU, ball3, AW, char2, AY
	local reachConfig = KS.S.reachConfig
	if not reachConfig.isActive then return end
	char2 = LocalPlayer.Character
	if not char2 then return end
	hrp5 = char2:FindFirstChild("HumanoidRootPart")
	if not hrp5 then return end
	ball3 = findBall()
	if not ball3 or not ball3.Parent then return end
	AY = (ball3.Position - hrp5.Position).Magnitude
	if AY <= reachConfig.reach then
		pcall(function()
			firetouchinterest(hrp5, ball3, 0)
			firetouchinterest(hrp5, ball3, 1)
		end)
		AY = char2:FindFirstChild("Left Foot") or char2:FindFirstChild("Left Leg")
		AW = AY
		AY = char2:FindFirstChild("Right Foot") or char2:FindFirstChild("Right Leg")
		AU = AY
		if AW then
			pcall(function()
				firetouchinterest(AW, ball3, 0)
				firetouchinterest(AW, ball3, 1)
			end)
		end
		if AU then
			pcall(function()
				firetouchinterest(AU, ball3, 0)
				firetouchinterest(AU, ball3, 1)
			end)
		end
	end
end
KS.reachStep = reachStep

-- ============ HITBOX ============
local hitboxAnchor, hitboxFolder, hitboxLines

local function getHitboxFolder()
	if not hitboxFolder or not hitboxFolder.Parent then
		hitboxFolder = Instance.new("Folder")
		hitboxFolder.Name = "ReachHitboxFolder"
		hitboxFolder.Parent = Workspace
	end
	return hitboxFolder
end

local function getHitboxAnchor()
	if not hitboxAnchor or not hitboxAnchor.Parent then
		hitboxAnchor = Instance.new("Part")
		hitboxAnchor.Name = "ReachHitboxAnchor"
		hitboxAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
		hitboxAnchor.Transparency = 1
		hitboxAnchor.CanCollide = false
		hitboxAnchor.CanQuery = false
		hitboxAnchor.Anchored = true
		hitboxAnchor.Parent = getHitboxFolder()
	end
	return hitboxAnchor
end

local function buildHitboxLines(d2)
	local Ba, Bb, Bc, Bd, Bp, lineHandleAdornment
	Ba = {}
	Bb = d2 / 2
	Bc = {Vector3.new(-Bb, -Bb, -Bb), Vector3.new(Bb, -Bb, -Bb), Vector3.new(Bb, -Bb, Bb), Vector3.new(-Bb, -Bb, Bb), Vector3.new(-Bb, Bb, -Bb), Vector3.new(Bb, Bb, -Bb), Vector3.new(Bb, Bb, Bb), Vector3.new(-Bb, Bb, Bb)}
	Bb = {{1, 2}, {2, 3}, {3, 4}, {4, 1}, {5, 6}, {6, 7}, {7, 8}, {8, 5}, {1, 5}, {2, 6}, {3, 7}, {4, 8}}
	Bd = getHitboxAnchor()
	for _, Bx in ipairs(Bb) do
		Bb = Bc[Bx[1]]
		Bp = Bc[Bx[2]]
		lineHandleAdornment = Instance.new("LineHandleAdornment")
		lineHandleAdornment.Adornee = Bd
		lineHandleAdornment.Color3 = Color3.fromRGB(0, 255, 0)
		lineHandleAdornment.Thickness = 2.5
		lineHandleAdornment.Length = (Bb - Bp).Magnitude
		lineHandleAdornment.CFrame = CFrame.new(Bb, Bp)
		lineHandleAdornment.Visible = true
		lineHandleAdornment.Parent = getHitboxFolder()
		table.insert(Ba, lineHandleAdornment)
	end
	return Ba
end

local function clearHitbox()
	if hitboxLines then
		for _, BF in ipairs(hitboxLines) do
			pcall(function() BF:Destroy() end)
		end
		hitboxLines = nil
	end
	if hitboxAnchor then
		pcall(function() hitboxAnchor:Destroy() end)
		hitboxAnchor = nil
	end
	if hitboxFolder then
		pcall(function() hitboxFolder:Destroy() end)
		hitboxFolder = nil
	end
end
KS.clearHitbox = clearHitbox

local function hitboxStep()
	local char3, hrp6
	local reachConfig = KS.S.reachConfig
	if not reachConfig.showHitbox then
		clearHitbox()
		return
	end
	char3 = LocalPlayer.Character
	if not char3 then return end
	hrp6 = char3:FindFirstChild("HumanoidRootPart")
	if not hrp6 then
		clearHitbox()
		return
	end
	if not hitboxLines then
		hitboxLines = buildHitboxLines(reachConfig.reach * 2)
	end
	if hitboxAnchor then hitboxAnchor.CFrame = hrp6.CFrame end
end
KS.hitboxStep = hitboxStep

-- ============ AUTO SKILL ============
local function autoSkillStep()
	local ball4, BL, BM
	if not autoSkillEnabled then return end
	if not character or not rootPart or not humanoid then refreshCharacter() end
	if not rootPart or not humanoid then return end
	ball4 = findBall()
	if not ball4 or (ball4.Position - rootPart.Position).Magnitude > KS.S.ballRange + 2 then return end
	BL = RunService.Heartbeat:Wait() or 0.016
	skillPhase = skillPhase + BL * skillSpeed
	if skillPhase >= 1 then
		skillPhase, skillStep = 0, (skillStep + 1) % 4
	end
	BL = skillStep == 0 and rootPart.CFrame.LookVector
	BM = BL
	if not BM then
		BL = skillStep == 1 and rootPart.CFrame.RightVector
		BM = BL
	end
	if not BM then
		BL = skillStep == 2 and -rootPart.CFrame.RightVector
		BM = BL
	end
	if not BM then BM = -rootPart.CFrame.LookVector end
	BL = BM * math.sin(skillPhase * math.pi) * 2
	BM = rootPart.Position + BL + Vector3.new(0, -1.5, 0)
	if ball4 and ball4.Parent then
		ball4.CFrame = CFrame.new(ball4.Position:Lerp(BM, 0.3), ball4.Position)
		ball4.Velocity, ball4.RotVelocity = Vector3.zero, Vector3.zero
	end
end
KS.autoSkillStep = autoSkillStep

-- ============ AUTO GOAL ============
local function findBallSimple()
	for _, B6 in ipairs(Workspace:GetDescendants()) do
		if B6:IsA("BasePart") and B6.Name == "TPS" then return B6 end
	end
	return nil
end
KS.findBallSimple = findBallSimple

local function autoGoalStep()
	local ball5, B9, Ca
	local S = KS.S
	ball5 = findBallSimple()
	if not ball5 then return end
	B9 = nil
	if S.autoGoalBlue then B9 = S.blueGoalPos
	elseif S.autoGoalGreen then B9 = S.greenGoalPos end
	if not B9 then return end
	if (ball5.Position - B9).Magnitude <= 10 then
		ball5.Velocity = Vector3.zero
		S.ballAtGoal = true
		return
	end
	if (ball5.Position - B9).Magnitude > 12 then S.ballAtGoal = false end
	Ca = ball5.Velocity.Magnitude > 15 and tick() - S.lastGoalShot >= S.goalShotCooldown
	if Ca and not S.ballAtGoal then
		Ca = (B9 - ball5.Position).Unit
		ball5.Velocity = Ca * 250 + Vector3.new(0, 5, 0)
		S.lastGoalShot = tick()
	end
end
KS.autoGoalStep = autoGoalStep

-- ============ POWER SHOOT ============
local powerShootEnabled = false
local shootForce = 5
local lastKick = 0
local kickCooldown = 0.5
KS.PS = {
	get enabled() return powerShootEnabled end,
	set enabled(v) powerShootEnabled = v end,
	get force() return shootForce end,
	set force(v) shootForce = v end,
}

local function kickBall(ko)
	local FK, char4, FM
	if not powerShootEnabled or shootForce <= 0 then return end
	if tick() - lastKick < kickCooldown then return end
	char4, FK, FM = LocalPlayer.Character, nil, nil
	if not char4 then return end
	FK, FM = char4:FindFirstChild("HumanoidRootPart"), char4:FindFirstChildOfClass("Humanoid")
	if not FK or not FM or FM.MoveDirection.Magnitude < 0.1 then return end
	if (ko.Position - FK.Position).Unit:Dot(FM.MoveDirection.Unit) > 0.5 then
		lastKick = tick()
		pcall(function()
			local bodyVelocity, FH
			FH = ko:FindFirstChild("KickForce")
			if FH then FH:Destroy() end
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "KickForce"
			bodyVelocity.Velocity = FK.CFrame.LookVector * shootForce * 45 + Vector3.new(0, shootForce * 9, 0)
			bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bodyVelocity.Parent = ko
			task.delay(0.15, function()
				pcall(function()
					if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end
				end)
			end)
		end)
	end
end

RunService.Heartbeat:Connect(function()
	local char5, hrp7
	if not powerShootEnabled or shootForce <= 0 then return end
	char5 = LocalPlayer.Character
	if not char5 then return end
	hrp7 = char5:FindFirstChild("HumanoidRootPart")
	if not hrp7 then return end
	for _, F3 in ipairs(Workspace:GetDescendants()) do
		if F3:IsA("BasePart") and F3.Name == "TPS" and (F3.Position - hrp7.Position).Magnitude <= KS.S.ballRange then
			kickBall(F3)
		end
	end
end)

-- ============ CONTROL BALL ============
local controlBallEnabled = false
local controllingBall = false
local controlledBall = nil
local controlRenderConn = nil
local controlInputConn = nil
local ballSpeed = 70
local cameraDistance = 16
local cameraHeight = 6
local mouseSensitivity = 0.004
local touchSensitivity = 0.006
local cameraYaw = 0
local cameraPitch = 0.2
local maxBallDistance = 80
local savedCameraType = nil
local savedCameraSubject = nil
local controlButton = nil
local controlGui = nil
local dragging = false
local dragStart = nil
local buttonStartPos = nil
local dragDistance = 0
local controlKey = Enum.KeyCode.U
local controlKeyName = "U"

local CB = {
	get enabled() return controlBallEnabled end,
	set enabled(v) controlBallEnabled = v end,
	get controlling() return controllingBall end,
	set controlling(v) controllingBall = v end,
	get ball() return controlledBall end,
	set ball(v) controlledBall = v end,
	get renderConn() return controlRenderConn end,
	set renderConn(v) controlRenderConn = v end,
	get inputConn() return controlInputConn end,
	set inputConn(v) controlInputConn = v end,
	get ballSpeed() return ballSpeed end,
	set ballSpeed(v) ballSpeed = v end,
	get camDist() return cameraDistance end,
	set camDist(v) cameraDistance = v end,
	get camH() return cameraHeight end,
	set camH(v) cameraHeight = v end,
	get yaw() return cameraYaw end,
	set yaw(v) cameraYaw = v end,
	get pitch() return cameraPitch end,
	set pitch(v) cameraPitch = v end,
	get key() return controlKey end,
	set key(v) controlKey = v end,
	get keyName() return controlKeyName end,
	set keyName(v) controlKeyName = v end,
	get btn() return controlButton end,
	set btn(v) controlButton = v end,
	get gui() return controlGui end,
	set gui(v) controlGui = v end,
	get dragging() return dragging end,
	set dragging(v) dragging = v end,
	get dragStart() return dragStart end,
	set dragStart(v) dragStart = v end,
	get btnStart() return buttonStartPos end,
	set btnStart(v) buttonStartPos = v end,
	get dragDist() return dragDistance end,
	set dragDist(v) dragDistance = v end,
	get maxDist() return maxBallDistance end,
	get savedType() return savedCameraType end,
	set savedType(v) savedCameraType = v end,
	get savedSubj() return savedCameraSubject end,
	set savedSubj(v) savedCameraSubject = v end,
	get mouseSens() return mouseSensitivity end,
	get touchSens() return touchSensitivity end,
}
KS.CB = CB

local function restoreCamera()
	if CB.savedType and CB.savedSubj then
		local cam = Workspace.CurrentCamera
		cam.CameraType = CB.savedType
		cam.CameraSubject = CB.savedSubj
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end
KS.restoreCamera = restoreCamera

local function stopControl()
	CB.controlling = false
	if CB.renderConn then CB.renderConn:Disconnect(); CB.renderConn = nil end
	if CB.inputConn then CB.inputConn:Disconnect(); CB.inputConn = nil end
	restoreCamera()
	if CB.btn then
		CB.btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		CB.btn.Text = "Control Ball"
	end
	CB.ball = nil
end
KS.stopControl = stopControl

local function findNearestBall()
	local Cq, Cr, Cs, CA, CBv
	Cq = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Cr = Cq
	Cq = Cr:FindFirstChild("HumanoidRootPart") or Cr:WaitForChild("HumanoidRootPart", 3)
	Cr = Cq
	if not Cr then return nil end
	Cq = CB.maxDist
	Cs = nil
	for _, CI in ipairs(Workspace:GetDescendants()) do
		if CI.Name == "TPS" then
			CA = nil
			if CI:IsA("Model") then
				CBv = CI.PrimaryPart or CI:FindFirstChildWhichIsA("BasePart")
				CA = CBv
			elseif CI:IsA("BasePart") then
				CA = CI
			end
			if CA then
				CBv = (CA.Position - Cr.Position).Magnitude
				if CBv < Cq then
					Cq = CBv
					Cs = CI
				end
			end
		end
	end
	return Cs
end
KS.findNearestBall = findNearestBall

local function startControl(fB)
	local CV, CW
	if CB.renderConn then CB.renderConn:Disconnect() end
	if CB.inputConn then CB.inputConn:Disconnect() end
	if fB:IsA("Model") then
		CW = fB.PrimaryPart or fB:FindFirstChildWhichIsA("BasePart")
		CV = CW
	else
		CV = fB
	end
	if not CV or not CV:IsA("BasePart") then stopControl(); return end
	CB.ball = CV
	CB.controlling = true
	if CB.btn then
		CB.btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		CB.btn.Text = "Control: ON"
	end
	CV = Workspace.CurrentCamera
	CB.savedType = CV.CameraType
	CB.savedSubj = CV.CameraSubject
	CW = CV.CFrame.LookVector
	CB.yaw = math.atan2(-CW.X, -CW.Z)
	CB.pitch = math.asin(math.clamp(CW.Y, -1, 1))
	CV.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	CB.inputConn = UserInputService.InputChanged:Connect(function(fT)
		if not CB.controlling then return end
		if fT.UserInputType == Enum.UserInputType.MouseMovement then
			CB.yaw = CB.yaw - fT.Delta.X * CB.mouseSens
			CB.pitch = math.clamp(CB.pitch - fT.Delta.Y * CB.mouseSens, -1.2, 1.2)
		elseif fT.UserInputType == Enum.UserInputType.Touch then
			CB.yaw = CB.yaw - fT.Delta.X * CB.touchSens
			CB.pitch = math.clamp(CB.pitch - fT.Delta.Y * CB.touchSens, -1.2, 1.2)
		end
	end)
	CB.renderConn = RunService.RenderStepped:Connect(function()
		local CP, CQ
		if not CB.controlling or not CB.ball or not CB.ball.Parent then stopControl(); return end
		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
		CP = CFrame.fromEulerAnglesYXZ(CB.pitch, CB.yaw, 0).LookVector
		pcall(function()
			CB.ball.AssemblyLinearVelocity = CP * CB.ballSpeed
			CB.ball.AssemblyAngularVelocity = Vector3.zero
		end)
		CQ = CB.ball.Position - CP * CB.camDist + Vector3.new(0, CB.camH, 0)
		Workspace.CurrentCamera.CFrame = CFrame.lookAt(CQ, CB.ball.Position + Vector3.new(0, 1.5, 0))
	end)
end
KS.startControl = startControl

local function toggleControl()
	local ball6
	if CB.controlling then
		stopControl()
	else
		ball6 = findNearestBall()
		if ball6 then startControl(ball6)
		else WindUI:Notify({Title = "Error", Content = "Ball not found!", Icon = "x-circle", Duration = 2}) end
	end
end
KS.toggleControl = toggleControl

local function setControlKey(gt)
	local C6, C7, C8
	C6 = gt:gsub("%s+", "")
	if C6 == "" then
		WindUI:Notify({Title = "Error", Content = "Enter a valid key!", Icon = "x-circle", Duration = 2})
		return
	end
	C7 = keyMap[C6]
	if C7 then
		CB.key = C7
		CB.keyName = C6
		WindUI:Notify({Title = "Keybind Updated", Content = "Key: " .. C6, Icon = "check-circle", Duration = 2})
	else
		C7, C8 = pcall(function() return Enum.KeyCode[C6] end)
		if C7 and C8 then
			CB.key = C8
			CB.keyName = C6
			WindUI:Notify({Title = "Keybind Updated", Content = "Key: " .. C6, Icon = "check-circle", Duration = 2})
		else
			WindUI:Notify({Title = "Error", Content = "Key '" .. C6 .. "' not recognized!", Icon = "x-circle", Duration = 3})
		end
	end
end
KS.setControlKey = setControlKey

local function createControlGui()
	if CB.gui then return end
	local gui = Instance.new("ScreenGui")
	gui.Name = "ControlBallUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	CB.gui = gui
	local btn = Instance.new("TextButton")
	btn.Name = "ControlBall"
	btn.Size = UDim2.new(0, 140, 0, 45)
	btn.Position = UDim2.new(0.05, 0, 0.1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = "Control Ball"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.AutoButtonColor = false
	btn.Visible = CB.enabled
	btn.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	CB.btn = btn
	btn.InputBegan:Connect(function(gJ)
		if gJ.UserInputType == Enum.UserInputType.MouseButton1 or gJ.UserInputType == Enum.UserInputType.Touch then
			CB.dragging = true
			CB.dragStart = gJ.Position
			CB.btnStart = btn.Position
			CB.dragDist = 0
		end
	end)
	btn.InputChanged:Connect(function(gU)
		if CB.dragging and (gU.UserInputType == Enum.UserInputType.MouseMovement or gU.UserInputType == Enum.UserInputType.Touch) then
			local d = gU.Position - CB.dragStart
			CB.dragDist = CB.dragDist + d.Magnitude
			btn.Position = UDim2.new(CB.btnStart.X.Scale, CB.btnStart.X.Offset + d.X, CB.btnStart.Y.Scale, CB.btnStart.Y.Offset + d.Y)
			CB.dragStart = gU.Position
			CB.btnStart = btn.Position
		end
	end)
	btn.InputEnded:Connect(function(g3)
		if g3.UserInputType == Enum.UserInputType.MouseButton1 or g3.UserInputType == Enum.UserInputType.Touch then
			CB.dragging = false
			if CB.dragDist < 15 then toggleControl() end
		end
	end)
end
KS.createControlGui = createControlGui

local function destroyControlGui()
	if CB.gui then
		CB.gui:Destroy()
		CB.gui = nil
		CB.btn = nil
-- =============================================
-- PARTE 2/5 | Character + Follow + Reach + Hitbox + Skill + Goal + Shoot + Control Ball
-- =============================================
local KS = _G.KS
if not KS then error("Execute a PARTE 1/5 primeiro!") end

local LocalPlayer = KS.LocalPlayer
local Workspace = KS.Workspace
local RunService = KS.RunService
local UserInputService = KS.UserInputService
local VirtualInputManager = KS.VirtualInputManager
local WindUI = KS.WindUI
local keyMap = KS.keyMap

-- ============ WALK SPEED LOOP ============
RunService.Heartbeat:Connect(function()
	local zY, hrp4, z_
	local ws = KS.getWalkSpeed()
	if ws == 16 then return end
	zY = LocalPlayer.Character
	if not zY then return end
	hrp4 = zY:FindFirstChild("HumanoidRootPart")
	z_ = zY:FindFirstChildOfClass("Humanoid")
	zY = hrp4 and z_
	if zY then
		zY = z_.MoveDirection
		if zY.Magnitude > 0.1 then
			z_ = hrp4.AssemblyLinearVelocity
			hrp4.AssemblyLinearVelocity = Vector3.new(zY.X * ws, z_.Y, zY.Z * ws)
		end
	end
end)

-- ============ CHARACTER / FOLLOW ============
local autoFollowEnabled = false
local autoSkillEnabled = false
local skillSpeed = 5
local skillStep = 0
local skillPhase = 0
local character = nil
local humanoid = nil
local rootPart = nil
local followStopDistance = 1.8
local autoFollowKey = Enum.KeyCode.K
local autoFollowKeyName = "K"

KS.F = {
	get enabled() return autoFollowEnabled end,
	set enabled(v) autoFollowEnabled = v end,
	get key() return autoFollowKey end,
	set key(v) autoFollowKey = v end,
	get keyName() return autoFollowKeyName end,
	set keyName(v) autoFollowKeyName = v end,
	get skill() return autoSkillEnabled end,
	set skill(v) autoSkillEnabled = v end,
	get skillSpeed() return skillSpeed end,
	set skillSpeed(v) skillSpeed = v end,
	get skillStep() return skillStep end,
	set skillStep(v) skillStep = v end,
	get skillPhase() return skillPhase end,
	set skillPhase(v) skillPhase = v end,
	get stopDist() return followStopDistance end,
	set stopDist(v) followStopDistance = v end,
}

local function refreshCharacter()
	character = LocalPlayer.Character
	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		rootPart = character:FindFirstChild("HumanoidRootPart")
	end
end
KS.refreshCharacter = refreshCharacter

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	refreshCharacter()
end)
refreshCharacter()

local function isMoving()
	return UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
end
KS.isMoving = isMoving

local function findBall()
	local At, Au
	At = Workspace:FindFirstChild("WorkspaceStadiumSounds")
	if At then
		Au = At:FindFirstChild("TPS")
		if Au and Au:IsA("BasePart") then return Au end
	end
	for _, AH in pairs(Workspace:GetDescendants()) do
		if AH.Name == "TPS" and AH:IsA("BasePart") and not AH.Anchored then return AH end
	end
	return nil
end
KS.findBall = findBall

local function autoFollowStep()
	local AJ, AK, AL
	if not autoFollowEnabled then return end
	if not rootPart or not rootPart.Parent or not humanoid then return end
	AJ = findBall()
	if not AJ then return end
	if isMoving() then return end
	AK = AJ.Position
	AJ = AK - rootPart.Position
	AL = Vector3.new(AJ.X, 0, AJ.Z)
	if AL.Magnitude > followStopDistance and AL.Magnitude < 150 then
		humanoid:Move(AL.Unit, false)
		rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(AK.X, rootPart.Position.Y, AK.Z))
	else
		humanoid:Move(Vector3.zero, false)
	end
end
KS.autoFollowStep = autoFollowStep

local function setAutoFollow(dx)
	autoFollowEnabled = dx
	if not dx and humanoid then humanoid:Move(Vector3.zero, false) end
	KS.updateMobileButton()
end
KS.setAutoFollow = setAutoFollow

-- ============ REACH ============
local function reachStep()
	local hrp5, AU, ball3, AW, char2, AY
	local reachConfig = KS.S.reachConfig
	if not reachConfig.isActive then return end
	char2 = LocalPlayer.Character
	if not char2 then return end
	hrp5 = char2:FindFirstChild("HumanoidRootPart")
	if not hrp5 then return end
	ball3 = findBall()
	if not ball3 or not ball3.Parent then return end
	AY = (ball3.Position - hrp5.Position).Magnitude
	if AY <= reachConfig.reach then
		pcall(function()
			firetouchinterest(hrp5, ball3, 0)
			firetouchinterest(hrp5, ball3, 1)
		end)
		AY = char2:FindFirstChild("Left Foot") or char2:FindFirstChild("Left Leg")
		AW = AY
		AY = char2:FindFirstChild("Right Foot") or char2:FindFirstChild("Right Leg")
		AU = AY
		if AW then
			pcall(function()
				firetouchinterest(AW, ball3, 0)
				firetouchinterest(AW, ball3, 1)
			end)
		end
		if AU then
			pcall(function()
				firetouchinterest(AU, ball3, 0)
				firetouchinterest(AU, ball3, 1)
			end)
		end
	end
end
KS.reachStep = reachStep

-- ============ HITBOX ============
local hitboxAnchor, hitboxFolder, hitboxLines

local function getHitboxFolder()
	if not hitboxFolder or not hitboxFolder.Parent then
		hitboxFolder = Instance.new("Folder")
		hitboxFolder.Name = "ReachHitboxFolder"
		hitboxFolder.Parent = Workspace
	end
	return hitboxFolder
end

local function getHitboxAnchor()
	if not hitboxAnchor or not hitboxAnchor.Parent then
		hitboxAnchor = Instance.new("Part")
		hitboxAnchor.Name = "ReachHitboxAnchor"
		hitboxAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
		hitboxAnchor.Transparency = 1
		hitboxAnchor.CanCollide = false
		hitboxAnchor.CanQuery = false
		hitboxAnchor.Anchored = true
		hitboxAnchor.Parent = getHitboxFolder()
	end
	return hitboxAnchor
end

local function buildHitboxLines(d2)
	local Ba, Bb, Bc, Bd, Bp, lineHandleAdornment
	Ba = {}
	Bb = d2 / 2
	Bc = {Vector3.new(-Bb, -Bb, -Bb), Vector3.new(Bb, -Bb, -Bb), Vector3.new(Bb, -Bb, Bb), Vector3.new(-Bb, -Bb, Bb), Vector3.new(-Bb, Bb, -Bb), Vector3.new(Bb, Bb, -Bb), Vector3.new(Bb, Bb, Bb), Vector3.new(-Bb, Bb, Bb)}
	Bb = {{1, 2}, {2, 3}, {3, 4}, {4, 1}, {5, 6}, {6, 7}, {7, 8}, {8, 5}, {1, 5}, {2, 6}, {3, 7}, {4, 8}}
	Bd = getHitboxAnchor()
	for _, Bx in ipairs(Bb) do
		Bb = Bc[Bx[1]]
		Bp = Bc[Bx[2]]
		lineHandleAdornment = Instance.new("LineHandleAdornment")
		lineHandleAdornment.Adornee = Bd
		lineHandleAdornment.Color3 = Color3.fromRGB(0, 255, 0)
		lineHandleAdornment.Thickness = 2.5
		lineHandleAdornment.Length = (Bb - Bp).Magnitude
		lineHandleAdornment.CFrame = CFrame.new(Bb, Bp)
		lineHandleAdornment.Visible = true
		lineHandleAdornment.Parent = getHitboxFolder()
		table.insert(Ba, lineHandleAdornment)
	end
	return Ba
end

local function clearHitbox()
	if hitboxLines then
		for _, BF in ipairs(hitboxLines) do
			pcall(function() BF:Destroy() end)
		end
		hitboxLines = nil
	end
	if hitboxAnchor then
		pcall(function() hitboxAnchor:Destroy() end)
		hitboxAnchor = nil
	end
	if hitboxFolder then
		pcall(function() hitboxFolder:Destroy() end)
		hitboxFolder = nil
	end
end
KS.clearHitbox = clearHitbox

local function hitboxStep()
	local char3, hrp6
	local reachConfig = KS.S.reachConfig
	if not reachConfig.showHitbox then
		clearHitbox()
		return
	end
	char3 = LocalPlayer.Character
	if not char3 then return end
	hrp6 = char3:FindFirstChild("HumanoidRootPart")
	if not hrp6 then
		clearHitbox()
		return
	end
	if not hitboxLines then
		hitboxLines = buildHitboxLines(reachConfig.reach * 2)
	end
	if hitboxAnchor then hitboxAnchor.CFrame = hrp6.CFrame end
end
KS.hitboxStep = hitboxStep

-- ============ AUTO SKILL ============
local function autoSkillStep()
	local ball4, BL, BM
	if not autoSkillEnabled then return end
	if not character or not rootPart or not humanoid then refreshCharacter() end
	if not rootPart or not humanoid then return end
	ball4 = findBall()
	if not ball4 or (ball4.Position - rootPart.Position).Magnitude > KS.S.ballRange + 2 then return end
	BL = RunService.Heartbeat:Wait() or 0.016
	skillPhase = skillPhase + BL * skillSpeed
	if skillPhase >= 1 then
		skillPhase, skillStep = 0, (skillStep + 1) % 4
	end
	BL = skillStep == 0 and rootPart.CFrame.LookVector
	BM = BL
	if not BM then
		BL = skillStep == 1 and rootPart.CFrame.RightVector
		BM = BL
	end
	if not BM then
		BL = skillStep == 2 and -rootPart.CFrame.RightVector
		BM = BL
	end
	if not BM then BM = -rootPart.CFrame.LookVector end
	BL = BM * math.sin(skillPhase * math.pi) * 2
	BM = rootPart.Position + BL + Vector3.new(0, -1.5, 0)
	if ball4 and ball4.Parent then
		ball4.CFrame = CFrame.new(ball4.Position:Lerp(BM, 0.3), ball4.Position)
		ball4.Velocity, ball4.RotVelocity = Vector3.zero, Vector3.zero
	end
end
KS.autoSkillStep = autoSkillStep

-- ============ AUTO GOAL ============
local function findBallSimple()
	for _, B6 in ipairs(Workspace:GetDescendants()) do
		if B6:IsA("BasePart") and B6.Name == "TPS" then return B6 end
	end
	return nil
end
KS.findBallSimple = findBallSimple

local function autoGoalStep()
	local ball5, B9, Ca
	local S = KS.S
	ball5 = findBallSimple()
	if not ball5 then return end
	B9 = nil
	if S.autoGoalBlue then B9 = S.blueGoalPos
	elseif S.autoGoalGreen then B9 = S.greenGoalPos end
	if not B9 then return end
	if (ball5.Position - B9).Magnitude <= 10 then
		ball5.Velocity = Vector3.zero
		S.ballAtGoal = true
		return
	end
	if (ball5.Position - B9).Magnitude > 12 then S.ballAtGoal = false end
	Ca = ball5.Velocity.Magnitude > 15 and tick() - S.lastGoalShot >= S.goalShotCooldown
	if Ca and not S.ballAtGoal then
		Ca = (B9 - ball5.Position).Unit
		ball5.Velocity = Ca * 250 + Vector3.new(0, 5, 0)
		S.lastGoalShot = tick()
	end
end
KS.autoGoalStep = autoGoalStep

-- ============ POWER SHOOT ============
local powerShootEnabled = false
local shootForce = 5
local lastKick = 0
local kickCooldown = 0.5
KS.PS = {
	get enabled() return powerShootEnabled end,
	set enabled(v) powerShootEnabled = v end,
	get force() return shootForce end,
	set force(v) shootForce = v end,
}

local function kickBall(ko)
	local FK, char4, FM
	if not powerShootEnabled or shootForce <= 0 then return end
	if tick() - lastKick < kickCooldown then return end
	char4, FK, FM = LocalPlayer.Character, nil, nil
	if not char4 then return end
	FK, FM = char4:FindFirstChild("HumanoidRootPart"), char4:FindFirstChildOfClass("Humanoid")
	if not FK or not FM or FM.MoveDirection.Magnitude < 0.1 then return end
	if (ko.Position - FK.Position).Unit:Dot(FM.MoveDirection.Unit) > 0.5 then
		lastKick = tick()
		pcall(function()
			local bodyVelocity, FH
			FH = ko:FindFirstChild("KickForce")
			if FH then FH:Destroy() end
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "KickForce"
			bodyVelocity.Velocity = FK.CFrame.LookVector * shootForce * 45 + Vector3.new(0, shootForce * 9, 0)
			bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bodyVelocity.Parent = ko
			task.delay(0.15, function()
				pcall(function()
					if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end
				end)
			end)
		end)
	end
end

RunService.Heartbeat:Connect(function()
	local char5, hrp7
	if not powerShootEnabled or shootForce <= 0 then return end
	char5 = LocalPlayer.Character
	if not char5 then return end
	hrp7 = char5:FindFirstChild("HumanoidRootPart")
	if not hrp7 then return end
	for _, F3 in ipairs(Workspace:GetDescendants()) do
		if F3:IsA("BasePart") and F3.Name == "TPS" and (F3.Position - hrp7.Position).Magnitude <= KS.S.ballRange then
			kickBall(F3)
		end
	end
end)

-- ============ CONTROL BALL ============
local controlBallEnabled = false
local controllingBall = false
local controlledBall = nil
local controlRenderConn = nil
local controlInputConn = nil
local ballSpeed = 70
local cameraDistance = 16
local cameraHeight = 6
local mouseSensitivity = 0.004
local touchSensitivity = 0.006
local cameraYaw = 0
local cameraPitch = 0.2
local maxBallDistance = 80
local savedCameraType = nil
local savedCameraSubject = nil
local controlButton = nil
local controlGui = nil
local dragging = false
local dragStart = nil
local buttonStartPos = nil
local dragDistance = 0
local controlKey = Enum.KeyCode.U
local controlKeyName = "U"

local CB = {
	get enabled() return controlBallEnabled end,
	set enabled(v) controlBallEnabled = v end,
	get controlling() return controllingBall end,
	set controlling(v) controllingBall = v end,
	get ball() return controlledBall end,
	set ball(v) controlledBall = v end,
	get renderConn() return controlRenderConn end,
	set renderConn(v) controlRenderConn = v end,
	get inputConn() return controlInputConn end,
	set inputConn(v) controlInputConn = v end,
	get ballSpeed() return ballSpeed end,
	set ballSpeed(v) ballSpeed = v end,
	get camDist() return cameraDistance end,
	set camDist(v) cameraDistance = v end,
	get camH() return cameraHeight end,
	set camH(v) cameraHeight = v end,
	get yaw() return cameraYaw end,
	set yaw(v) cameraYaw = v end,
	get pitch() return cameraPitch end,
	set pitch(v) cameraPitch = v end,
	get key() return controlKey end,
	set key(v) controlKey = v end,
	get keyName() return controlKeyName end,
	set keyName(v) controlKeyName = v end,
	get btn() return controlButton end,
	set btn(v) controlButton = v end,
	get gui() return controlGui end,
	set gui(v) controlGui = v end,
	get dragging() return dragging end,
	set dragging(v) dragging = v end,
	get dragStart() return dragStart end,
	set dragStart(v) dragStart = v end,
	get btnStart() return buttonStartPos end,
	set btnStart(v) buttonStartPos = v end,
	get dragDist() return dragDistance end,
	set dragDist(v) dragDistance = v end,
	get maxDist() return maxBallDistance end,
	get savedType() return savedCameraType end,
	set savedType(v) savedCameraType = v end,
	get savedSubj() return savedCameraSubject end,
	set savedSubj(v) savedCameraSubject = v end,
	get mouseSens() return mouseSensitivity end,
	get touchSens() return touchSensitivity end,
}
KS.CB = CB

local function restoreCamera()
	if CB.savedType and CB.savedSubj then
		local cam = Workspace.CurrentCamera
		cam.CameraType = CB.savedType
		cam.CameraSubject = CB.savedSubj
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end
KS.restoreCamera = restoreCamera

local function stopControl()
	CB.controlling = false
	if CB.renderConn then CB.renderConn:Disconnect(); CB.renderConn = nil end
	if CB.inputConn then CB.inputConn:Disconnect(); CB.inputConn = nil end
	restoreCamera()
	if CB.btn then
		CB.btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		CB.btn.Text = "Control Ball"
	end
	CB.ball = nil
end
KS.stopControl = stopControl

local function findNearestBall()
	local Cq, Cr, Cs, CA, CBv
	Cq = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Cr = Cq
	Cq = Cr:FindFirstChild("HumanoidRootPart") or Cr:WaitForChild("HumanoidRootPart", 3)
	Cr = Cq
	if not Cr then return nil end
	Cq = CB.maxDist
	Cs = nil
	for _, CI in ipairs(Workspace:GetDescendants()) do
		if CI.Name == "TPS" then
			CA = nil
			if CI:IsA("Model") then
				CBv = CI.PrimaryPart or CI:FindFirstChildWhichIsA("BasePart")
				CA = CBv
			elseif CI:IsA("BasePart") then
				CA = CI
			end
			if CA then
				CBv = (CA.Position - Cr.Position).Magnitude
				if CBv < Cq then
					Cq = CBv
					Cs = CI
				end
			end
		end
	end
	return Cs
end
KS.findNearestBall = findNearestBall

local function startControl(fB)
	local CV, CW
	if CB.renderConn then CB.renderConn:Disconnect() end
	if CB.inputConn then CB.inputConn:Disconnect() end
	if fB:IsA("Model") then
		CW = fB.PrimaryPart or fB:FindFirstChildWhichIsA("BasePart")
		CV = CW
	else
		CV = fB
	end
	if not CV or not CV:IsA("BasePart") then stopControl(); return end
	CB.ball = CV
	CB.controlling = true
	if CB.btn then
		CB.btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		CB.btn.Text = "Control: ON"
	end
	CV = Workspace.CurrentCamera
	CB.savedType = CV.CameraType
	CB.savedSubj = CV.CameraSubject
	CW = CV.CFrame.LookVector
	CB.yaw = math.atan2(-CW.X, -CW.Z)
	CB.pitch = math.asin(math.clamp(CW.Y, -1, 1))
	CV.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	CB.inputConn = UserInputService.InputChanged:Connect(function(fT)
		if not CB.controlling then return end
		if fT.UserInputType == Enum.UserInputType.MouseMovement then
			CB.yaw = CB.yaw - fT.Delta.X * CB.mouseSens
			CB.pitch = math.clamp(CB.pitch - fT.Delta.Y * CB.mouseSens, -1.2, 1.2)
		elseif fT.UserInputType == Enum.UserInputType.Touch then
			CB.yaw = CB.yaw - fT.Delta.X * CB.touchSens
			CB.pitch = math.clamp(CB.pitch - fT.Delta.Y * CB.touchSens, -1.2, 1.2)
		end
	end)
	CB.renderConn = RunService.RenderStepped:Connect(function()
		local CP, CQ
		if not CB.controlling or not CB.ball or not CB.ball.Parent then stopControl(); return end
		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
		CP = CFrame.fromEulerAnglesYXZ(CB.pitch, CB.yaw, 0).LookVector
		pcall(function()
			CB.ball.AssemblyLinearVelocity = CP * CB.ballSpeed
			CB.ball.AssemblyAngularVelocity = Vector3.zero
		end)
		CQ = CB.ball.Position - CP * CB.camDist + Vector3.new(0, CB.camH, 0)
		Workspace.CurrentCamera.CFrame = CFrame.lookAt(CQ, CB.ball.Position + Vector3.new(0, 1.5, 0))
	end)
end
KS.startControl = startControl

local function toggleControl()
	local ball6
	if CB.controlling then
		stopControl()
	else
		ball6 = findNearestBall()
		if ball6 then startControl(ball6)
		else WindUI:Notify({Title = "Error", Content = "Ball not found!", Icon = "x-circle", Duration = 2}) end
	end
end
KS.toggleControl = toggleControl

local function setControlKey(gt)
	local C6, C7, C8
	C6 = gt:gsub("%s+", "")
	if C6 == "" then
		WindUI:Notify({Title = "Error", Content = "Enter a valid key!", Icon = "x-circle", Duration = 2})
		return
	end
	C7 = keyMap[C6]
	if C7 then
		CB.key = C7
		CB.keyName = C6
		WindUI:Notify({Title = "Keybind Updated", Content = "Key: " .. C6, Icon = "check-circle", Duration = 2})
	else
		C7, C8 = pcall(function() return Enum.KeyCode[C6] end)
		if C7 and C8 then
			CB.key = C8
			CB.keyName = C6
			WindUI:Notify({Title = "Keybind Updated", Content = "Key: " .. C6, Icon = "check-circle", Duration = 2})
		else
			WindUI:Notify({Title = "Error", Content = "Key '" .. C6 .. "' not recognized!", Icon = "x-circle", Duration = 3})
		end
	end
end
KS.setControlKey = setControlKey

local function createControlGui()
	if CB.gui then return end
	local gui = Instance.new("ScreenGui")
	gui.Name = "ControlBallUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	CB.gui = gui
	local btn = Instance.new("TextButton")
	btn.Name = "ControlBall"
	btn.Size = UDim2.new(0, 140, 0, 45)
	btn.Position = UDim2.new(0.05, 0, 0.1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = "Control Ball"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.AutoButtonColor = false
	btn.Visible = CB.enabled
	btn.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	CB.btn = btn
	btn.InputBegan:Connect(function(gJ)
		if gJ.UserInputType == Enum.UserInputType.MouseButton1 or gJ.UserInputType == Enum.UserInputType.Touch then
			CB.dragging = true
			CB.dragStart = gJ.Position
			CB.btnStart = btn.Position
			CB.dragDist = 0
		end
	end)
	btn.InputChanged:Connect(function(gU)
		if CB.dragging and (gU.UserInputType == Enum.UserInputType.MouseMovement or gU.UserInputType == Enum.UserInputType.Touch) then
			local d = gU.Position - CB.dragStart
			CB.dragDist = CB.dragDist + d.Magnitude
			btn.Position = UDim2.new(CB.btnStart.X.Scale, CB.btnStart.X.Offset + d.X, CB.btnStart.Y.Scale, CB.btnStart.Y.Offset + d.Y)
			CB.dragStart = gU.Position
			CB.btnStart = btn.Position
		end-- =============================================
-- PARTE 3/5 | Tot Mobile + Mobile Button + Render Loop
-- =============================================
local KS = _G.KS
if not KS then error("Execute a PARTE 1/5 e 2/5 primeiro!") end

local LocalPlayer = KS.LocalPlayer
local Workspace = KS.Workspace
local RunService = KS.RunService
local UserInputService = KS.UserInputService
local VirtualInputManager = KS.VirtualInputManager

-- ============ TOT MOBILE ============
local totMobileActive = false
local totMobileGui = nil
local totMobileConns = {}
local totHumanoid = nil
local TOT = {
	get active() return totMobileActive end,
	set active(v) totMobileActive = v end,
	get gui() return totMobileGui end,
	set gui(v) totMobileGui = v end,
	get conns() return totMobileConns end,
	get humanoid() return totHumanoid end,
	set humanoid(v) totHumanoid = v end,
}
KS.TOT = TOT

local function disableTotMobile()
	TOT.active = false
	for _, DC in ipairs(TOT.conns) do
		pcall(function() DC:Disconnect() end)
	end
	table.clear(TOT.conns)
	if TOT.gui then TOT.gui:Destroy(); TOT.gui = nil end
	pcall(function() require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Enable() end)
	TOT.humanoid = nil
end
KS.disableTotMobile = disableTotMobile

local function enableTotMobile()
	local Eq, frame, Et, frame2, imageButton, Ey, Ez, EA, EC, ED, E1, E3
	if TOT.active then disableTotMobile() end
	pcall(function() require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Disable() end)
	local gui = Instance.new("ScreenGui")
	gui.Name = "TotMobileGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 999
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	TOT.gui = gui
	TOT.active = true
	EC = {{name = "R", key = Enum.KeyCode.R}, {name = "T", key = Enum.KeyCode.T}}
	function ED(hz)
		local hA, hE, hD, hB, hC = false, false, 8, nil, nil
		local hM = hz.InputBegan:Connect(function(hF)
			if hF.UserInputType == Enum.UserInputType.MouseButton1 or hF.UserInputType == Enum.UserInputType.Touch then
				hA = true; hB = hF.Position; hC = hz.Position; hE = false
			end
		end)
		table.insert(TOT.conns, hM)
		local h_ = hz.InputChanged:Connect(function(hP)
			if hA and (hP.UserInputType == Enum.UserInputType.MouseMovement or hP.UserInputType == Enum.UserInputType.Touch) then
				local d = hP.Position - hB
				if d.Magnitude > hD then hE = true end
				hz.Position = UDim2.new(hC.X.Scale, hC.X.Offset + d.X, hC.Y.Scale, hC.Y.Offset + d.Y)
				hB = hP.Position; hC = hz.Position
			end
		end)
		table.insert(TOT.conns, h_)
		local h3 = hz.InputEnded:Connect(function(h0)
			if h0.UserInputType == Enum.UserInputType.MouseButton1 or h0.UserInputType == Enum.UserInputType.Touch then hA = false end
		end)
		table.insert(TOT.conns, h3)
	end
	for h4, h5 in ipairs(EC) do
		local Ev, EB, Es, Ex
		E1 = h4; E3 = h5
		local E2 = E1; local E4 = E3
		Ev = Instance.new("TextButton")
		Ev.Size = UDim2.new(0, 60, 0, 60)
		Ev.Position = UDim2.new(1, -90, 1, -220 - (E2 - 1) * 75)
		Ev.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		Ev.BackgroundTransparency = 0.3
		Ev.Text = E4.name
		Ev.TextColor3 = Color3.new(1, 1, 1)
		Ev.TextScaled = true
		Ev.Font = Enum.Font.GothamBold
		Ev.AutoButtonColor = false
		Ev.Parent = gui
		Instance.new("UICorner", Ev).CornerRadius = UDim.new(1, 0)
		ED(Ev)
		EB = false; Es = false; Ex = Vector2.zero
		EC = Ev.InputBegan:Connect(function(ia)
			if ia.UserInputType == Enum.UserInputType.MouseButton1 or ia.UserInputType == Enum.UserInputType.Touch then
				EB = false; Ex = ia.Position
			end
		end)
		table.insert(TOT.conns, EC)
		EC = Ev.InputChanged:Connect(function(ig)
			if (ig.UserInputType == Enum.UserInputType.MouseMovement or ig.UserInputType == Enum.UserInputType.Touch) and (ig.Position - Ex).Magnitude > 8 then EB = true end
		end)
		table.insert(TOT.conns, EC)
		EC = Ev.MouseButton1Click:Connect(function()
			if EB then return end
			if Es then
				Es = false
				Ev.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				VirtualInputManager:SendKeyEvent(false, E4.key, false, game)
			else
				Es = true
				Ev.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
				VirtualInputManager:SendKeyEvent(true, E4.key, false, game)
			end
		end)
		table.insert(TOT.conns, EC)
	end
	imageButton = Instance.new("ImageButton")
	imageButton.Size = UDim2.new(0, 70, 0, 70)
	imageButton.Position = UDim2.new(1, -100, 1, -95)
	imageButton.BackgroundTransparency = 1
	imageButton.Image = "rbxassetid://120976481677763"
	imageButton.Parent = gui
	function EC(iw) if iw then TOT.humanoid = iw:WaitForChild("Humanoid") end end
	if LocalPlayer.Character then EC(LocalPlayer.Character) end
	ED = LocalPlayer.CharacterAdded:Connect(EC)
	table.insert(TOT.conns, ED)
	Ez = false
	EC = imageButton.MouseButton1Down:Connect(function()
		Ez = true
		imageButton.ImageColor3 = Color3.fromRGB(150, 150, 150)
	end)
	table.insert(TOT.conns, EC)
	EC = imageButton.MouseButton1Up:Connect(function()
		Ez = false
		imageButton.ImageColor3 = Color3.new(1, 1, 1)
	end)
	table.insert(TOT.conns, EC)
	EC = RunService.RenderStepped:Connect(function()
		if Ez and TOT.humanoid then TOT.humanoid.Jump = true end
	end)
	table.insert(TOT.conns, EC)
	Eq = 45
	frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(0, 220, 0, 220)
	frame2.Position = UDim2.new(0, 20, 1, -240)
	frame2.BackgroundTransparency = 1
	frame2.Active = true
	frame2.Parent = gui
	frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 34, 0, 34)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.35
	frame.Parent = frame2
	Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
	Ey = nil; EA = false; Et = Vector3.zero
	function EC(iT) if iT then TOT.humanoid = iT:WaitForChild("Humanoid") end end
	if LocalPlayer.Character then EC(LocalPlayer.Character) end
	ED = LocalPlayer.CharacterAdded:Connect(EC)
	table.insert(TOT.conns, ED)
	EC = frame2.InputBegan:Connect(function(iW, iX)
		if iX then return end
		if iW.UserInputType == Enum.UserInputType.Touch or iW.UserInputType == Enum.UserInputType.MouseButton1 then
			EA = true; Ey = iW
		end
	end)
	table.insert(TOT.conns, EC)
	EC = UserInputService.InputChanged:Connect(function(i2)
		if EA and i2 == Ey then
			local center = frame2.AbsolutePosition + frame2.AbsoluteSize / 2
			local delta = Vector2.new(i2.Position.X, i2.Position.Y) - center
			local mag = delta.Magnitude
			local clamped = mag > Eq and delta.Unit * Eq or delta
			frame.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)
			local norm = mag > 0 and clamped / Eq or Vector2.zero
			Et = Vector3.new(norm.X, 0, norm.Y)
		end
	end)
	table.insert(TOT.conns, EC)
	EC = UserInputService.InputEnded:Connect(function(ji)
		if EA and ji == Ey then
			EA = false; Ey = nil
			frame.Position = UDim2.new(0.5, 0, 0.5, 0)
			Et = Vector3.zero
		end
	end)
	table.insert(TOT.conns, EC)
	EC = RunService.RenderStepped:Connect(function()
		if not TOT.humanoid then return end
		if Et.Magnitude > 0.05 then
			local cam = Workspace.CurrentCamera
			local fwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
			if fwd.Magnitude > 0 then fwd = fwd.Unit end
			if right.Magnitude > 0 then right = right.Unit end
			local move = right * Et.X + fwd * -Et.Z
			if move.Magnitude > 0 then TOT.humanoid:Move(move, false) else TOT.humanoid:Move(Vector3.zero, false) end
		else
			TOT.humanoid:Move(Vector3.zero, false)
		end
	end)
	table.insert(TOT.conns, EC)
end
KS.enableTotMobile = enableTotMobile

-- ============ MOBILE AUTOFOLLOW BUTTON ============
local mobileGui = nil
local mobileButton = nil
local mobileButtonEnabled = false

local function makeDraggable(jw)
	local jx = false; local jA; local jz; local jy
	jw.InputBegan:Connect(function(jB)
		if jB.UserInputType == Enum.UserInputType.MouseButton1 or jB.UserInputType == Enum.UserInputType.Touch then
			jx = true; jz = jB.Position; jA = jw.Position
		end
	end)
	jw.InputEnded:Connect(function(jH)
		if jH.UserInputType == Enum.UserInputType.MouseButton1 or jH.UserInputType == Enum.UserInputType.Touch then jx = false end
	end)
	jw.InputChanged:Connect(function(jK)
		if jK.UserInputType == Enum.UserInputType.MouseMovement or jK.UserInputType == Enum.UserInputType.Touch then jy = jK end
	end)
	UserInputService.InputChanged:Connect(function(jO)
		if jO == jy and jx then
			local d = jO.Position - jz
			jw.Position = UDim2.new(jA.X.Scale, jA.X.Offset + d.X, jA.Y.Scale, jA.Y.Offset + d.Y)
		end
	end)
end

local function createMobileGui()
	if mobileGui then return end
	mobileGui = Instance.new("ScreenGui")
	mobileGui.Name = "KirtiumMobileGui"
	mobileGui.ResetOnSpawn = false
	mobileGui.IgnoreGuiInset = true
	mobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	mobileButton = Instance.new("TextButton")
	mobileButton.Size, mobileButton.Position = UDim2.new(0, 130, 0, 40), UDim2.new(0, 20, 0.75, 0)
	mobileButton.BackgroundColor3, mobileButton.TextColor3, mobileButton.Font = Color3.fromRGB(40, 40, 40), Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold
	mobileButton.TextSize, mobileButton.Text, mobileButton.Parent = 16, "AutoFollow: OFF", mobileGui
	Instance.new("UICorner", mobileButton).CornerRadius = UDim.new(0, 8)
	makeDraggable(mobileButton)
	mobileButton.MouseButton1Click:Connect(function()
		KS.setAutoFollow(not KS.F.enabled)
		if KS.autoFollowToggle then KS.autoFollowToggle:Set(KS.F.enabled) end
	end)
end

function KS.updateMobileButton()
	if not mobileButtonEnabled then return end
	if not mobileGui then createMobileGui() end
	if KS.F.enabled then
		mobileButton.Text, mobileButton.BackgroundColor3 = "AutoFollow: ON", Color3.fromRGB(40, 150, 70)
	else
		mobileButton.Text, mobileButton.BackgroundColor3 = "AutoFollow: OFF", Color3.fromRGB(40, 40, 40)
	end
end

local function setMobileButton(j9)
	mobileButtonEnabled = j9
	if j9 then
		createMobileGui()
		mobileGui.Enabled = true
		KS.updateMobileButton()
	elseif mobileGui then
		mobileGui.Enabled = false
	end
end
KS.setMobileButton = setMobileButton

UserInputService.InputBegan:Connect(function(kd, ke)
	if ke then return end
	if kd.KeyCode == KS.F.key then
		KS.setAutoFollow(not KS.F.enabled)
		if KS.autoFollowToggle then KS.autoFollowToggle:Set(KS.F.enabled) end
		if mobileButtonEnabled then KS.updateMobileButton() end
	end
end)

-- ============ RENDER LOOP PRINCIPAL ============
RunService.RenderStepped:Connect(function()
	KS.autoFollowStep()
	if KS.F.skill then KS.autoSkillStep() end
	KS.reachStep()
	KS.hitboxStep()
	if KS.S.autoGoalBlue or KS.S.autoGoalGreen then KS.autoGoalStep() end
	local C = KS.CATCH
	if C.enabled then
		if not C.canCatch then return end
		if C.holding then
			if not KS.isBallNear() then C.holding = false end
			return
		end
		KS.tryCatch()
	end
end)

print("[Kirtium] Parte 3/5 carregada ✔")
	end)
	btn.InputEnded:Connect(function(g3)
		if g3.UserInputType == Enum.UserInputType.MouseButton1 or g3.UserInputType == Enum.UserInputType.Touch then
			CB.dragging = false
			if CB.dragDist < 15 then toggleControl() end
		end
	end)
end
KS.createControlGui = createControlGui

local function destroyControlGui()
	if CB.gui then
		CB.gui:Destroy()
		CB.gui = nil
		CB.btn = nil-- =============================================
-- PARTE 4/5 | Tabs: Player + Reach + Ball + Troll
-- =============================================
local KS = _G.KS
if not KS then error("Execute as PARTES 1/5, 2/5 e 3/5 primeiro!") end

local Window = KS.Window
local WindUI = KS.WindUI
local LocalPlayer = KS.LocalPlayer
local Workspace = KS.Workspace
local TeleportService = KS.TeleportService
local VirtualUser = KS.VirtualUser
local keyMap = KS.keyMap
local CB = KS.CB
local S = KS.S

-- ============ PLAYER TAB ============
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})
PlayerTab:Slider({Title = "Speed", Desc = "Adjust player speed", Value = {Min = 16, Max = 150, Default = 16}, Callback = function(value)
	KS.setWalkSpeed(value)
end})
PlayerTab:Space()
PlayerTab:Slider({Title = "FOV Changer", Desc = "Adjust FOV", Value = {Min = 70, Max = 150, Default = 70}, Callback = function(value2)
	if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = value2 end
end})
PlayerTab:Space()
PlayerTab:Button({Title = "Rejoin", Desc = "Reconnect to same server", Callback = function()
	WindUI:Notify({Title = "Reconnecting...", Content = "You will be reconnected", Icon = "refresh-cw", Duration = 2})
	task.wait(1)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end})
PlayerTab:Space()
PlayerTab:Button({Title = "Anti AFK", Desc = "Prevents being disconnected due to inactivity", Callback = function()
	if S.antiAfkEnabled then return end
	S.antiAfkEnabled = true
	LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end})

-- ============ REACH TAB ============
local ReachTab = Window:Tab({Title = "Reach", Icon = "target"})
local AutoFollowToggle
AutoFollowToggle = ReachTab:Toggle({Title = "AutoFollow", Desc = "Follows the ball automatically (Key: " .. KS.F.keyName .. ")", Value = false, Callback = function(enabled)
	KS.setAutoFollow(enabled)
	KS.setMobileButton(enabled)
end})
KS.autoFollowToggle = AutoFollowToggle
ReachTab:Space()
local autoFollowInputReady = false
local autoFollowKeyInput
autoFollowKeyInput = ReachTab:Input({Title = "AutoFollow Keybind", Desc = "Enter desired key (K, G, etc.)", Value = "K", InputIcon = "key", Type = "Input", Placeholder = "Enter key...", Callback = function(text)
	local Gd, Ge, Gf
	if not autoFollowInputReady then autoFollowInputReady = true; return end
	Gd = text:gsub("%s+", "")
	if Gd == "" then
		WindUI:Notify({Title = "Error", Content = "Enter a valid key!", Icon = "x-circle", Duration = 2})
		return
	end
	Ge = keyMap[Gd]
	if Ge then
		KS.F.key = Ge
		KS.F.keyName = Gd
		autoFollowKeyInput:Set(Gd)
		AutoFollowToggle:SetDesc("Follows the ball automatically (Key: " .. Gd .. ")")
		WindUI:Notify({Title = "Keybind Updated", Content = "AutoFollow key: " .. Gd, Icon = "check-circle", Duration = 2})
	else
		Ge, Gf = pcall(function() return Enum.KeyCode[Gd] end)
		if Ge and Gf then
			KS.F.key = Gf
			KS.F.keyName = Gd
			autoFollowKeyInput:Set(Gd)
			AutoFollowToggle:SetDesc("Follows the ball automatically (Key: " .. Gd .. ")")
			WindUI:Notify({Title = "Keybind Updated", Content = "AutoFollow key: " .. Gd, Icon = "check-circle", Duration = 2})
		else
			WindUI:Notify({Title = "Error", Content = "Key '" .. Gd .. "' not recognized!", Icon = "x-circle", Duration = 3})
		end
	end
end})
ReachTab:Space()
local ReachToggle
ReachToggle = ReachTab:Toggle({Title = "Reach Active", Desc = "Activates reach (ball goes to your body) - Distance: " .. S.reachConfig.reach .. " studs", Value = false, Callback = function(enabled2)
	S.reachConfig.isActive = enabled2
end})
ReachTab:Space()
ReachTab:Slider({Title = "Reach Size", Desc = "Reach range (1 to 10 studs)", Value = {Min = 1, Max = 10, Default = 3}, Callback = function(value3)
	S.reachConfig.reach = value3
	ReachToggle:SetDesc("Activates reach (ball goes to your body) - Distance: " .. S.reachConfig.reach .. " studs")
	KS.clearHitbox()
end})
ReachTab:Space()
ReachTab:Toggle({Title = "Show Hitbox", Desc = "Shows green wireframe cube on your character", Value = false, Callback = function(enabled3)
	S.reachConfig.showHitbox = enabled3
	if not enabled3 then KS.clearHitbox() end
end})

-- ============ BALL TAB ============
local BallTab = Window:Tab({Title = "Ball", Icon = "circle"})
BallTab:Section({Title = "PowerShoot", TextSize = 16})
BallTab:Toggle({Title = "Power Shoot", Desc = "Kicks the ball with force when touching", Value = false, Callback = function(enabled4)
	KS.PS.enabled = enabled4
end})
BallTab:Space()
BallTab:Slider({Title = "Shoot Force", Desc = "Kick strength", Value = {Min = 0, Max = 10, Default = 5}, Callback = function(value4)
	KS.PS.force = value4
end})
BallTab:Space()
BallTab:Section({Title = "AutoSkill", TextSize = 16})
BallTab:Toggle({Title = "Auto Skill", Desc = "Tries to enhance a Skiller (may contain bugs)", Value = false, Callback = function(enabled5)
	KS.F.skill = enabled5
	if not enabled5 then
		KS.F.skillPhase = 0
		KS.F.skillStep = 0
	end
end})
BallTab:Space()
BallTab:Slider({Title = "Skill Speed", Desc = "Lower for more legit", Value = {Min = 1, Max = 10, Default = 5}, Callback = function(value5)
	KS.F.skillSpeed = value5
end})
BallTab:Space()
BallTab:Section({Title = "Curve Shot", TextSize = 16})
local selectedCurve = "Default"
BallTab:Dropdown({Title = "Tipo de Curva", Desc = "Escolha o tipo de curva na bola", Values = {"Default", "Curve Esquerda", "Curve Direita"}, Value = "Default", Callback = function(option)
	selectedCurve = option
end})
BallTab:Space()
BallTab:Button({Title = "Apply Curve Shot", Desc = "Aplica a curva selecionada", Callback = function()
	KS.applyCurve(selectedCurve)
	if selectedCurve ~= "Default" then
		WindUI:Notify({Title = "Curve Shot", Content = "Applied", Icon = "check-circle", Duration = 2})
	end
end})
BallTab:Space()
BallTab:Section({Title = "Control Ball", TextSize = 16})
local ControlBallToggle
ControlBallToggle = BallTab:Toggle({Title = "Control Ball", Desc = "Enables ball control (current key: " .. CB.keyName .. ")", Value = false, Callback = function(enabled6)
	CB.enabled = enabled6
	if enabled6 then
		KS.createControlGui()
		if CB.btn then CB.btn.Visible = true end
	else
		if CB.controlling then KS.stopControl() end
		KS.destroyControlGui()
	end
end})
BallTab:Space()
BallTab:Slider({Title = "Ball Speed", Desc = "Ball movement speed", Value = {Min = 10, Max = 200, Default = 70}, Callback = function(value6)
	CB.ballSpeed = value6
end})
BallTab:Space()
local controlKeyInputReady = false
BallTab:Input({Title = "Keybind", Desc = "Enter desired key (U, K, G,)", Value = "U", InputIcon = "key", Type = "Input", Placeholder = "Enter key...", Callback = function(text2)
	if not controlKeyInputReady then controlKeyInputReady = true; return end
	KS.setControlKey(text2)
	ControlBallToggle:SetDesc("Enables ball control (current key: " .. CB.keyName .. ")")
end})

-- ============ TROLL TAB ============
local TrollTab = Window:Tab({Title = "Troll", Icon = "skull"})
TrollTab:Section({Title = "Auto Goal", TextSize = 16})
TrollTab:Toggle({Title = "Auto Goal Blue", Desc = "Automatically shoots the ball to the Blue goal", Value = false, Callback = function(enabled7)
	S.autoGoalBlue = enabled7
	if enabled7 and S.autoGoalGreen then
		S.autoGoalGreen = false
		if autoGoalGreenToggle then autoGoalGreenToggle:Set(false) end
	end
	S.ballAtGoal = false
end})
TrollTab:Space()
TrollTab:Toggle({Title = "Auto Goal Green", Desc = "Automatically shoots the ball to the Green goal", Value = false, Callback = function(enabled8)
	S.autoGoalGreen = enabled8
	if enabled8 and S.autoGoalBlue then
		S.autoGoalBlue = false
		if autoGoalBlueToggle then autoGoalBlueToggle:Set(false) end
	end
	S.ballAtGoal = false
end})

print("[Kirtium] Parte 4/5 carregada ✔")-- =============================================
-- PARTE 5/5 | Tabs: Others + Goalkeeper + Visual + Discord + Final
-- =============================================
local KS = _G.KS
if not KS then error("Execute as PARTES 1/5, 2/5, 3/5 e 4/5 primeiro!") end

local Window = KS.Window
local WindUI = KS.WindUI
local LocalPlayer = KS.LocalPlayer
local Workspace = KS.Workspace
local HttpService = KS.HttpService
local Backgrounds = KS.Backgrounds
local TOT = KS.TOT
local C = KS.CATCH
local S = KS.S

local colorPickerReady = nil
local originalColors = {}

-- ============ OTHERS TAB ============
local OthersTab = Window:Tab({Title = "Others", Icon = "smartphone"})
OthersTab:Section({Title = "Tot Mobile", TextSize = 16})
OthersTab:Toggle({Title = "Tot Mobile", Desc = "Activates mobile controls (joystick + R/T buttons + jump)", Value = false, Callback = function(enabled9)
	if enabled9 then KS.enableTotMobile()
	else KS.disableTotMobile() end
end})

-- ============ GOALKEEPER TAB ============
local GoalkeeperTab = Window:Tab({Title = "Goalkeeper", Icon = "shield"})
local AutoCatchToggle
AutoCatchToggle = GoalkeeperTab:Toggle({Title = "Auto Catch", Desc = "Automatically catches the ball when close (Distance)", Value = false, Callback = function(enabled10)
	C.enabled = enabled10
	if not enabled10 then
		KS.dropBall()
		C.holding = false
		C.canCatch = true
	else
		C.holding = false
		C.canCatch = true
		C.lastCatch = 0
	end
end})
GoalkeeperTab:Space()
GoalkeeperTab:Slider({Title = "Catch Distance", Desc = "Maximum distance to catch the ball (1 to 15 studs)", Value = {Min = 1, Max = 15, Default = 5}, Callback = function(value7)
	C.distance = value7
	AutoCatchToggle:SetDesc("Automatically catches the ball when close (Distance: " .. C.distance .. " studs)")
end})

-- ============ VISUAL TAB ============
local VisualTab = Window:Tab({Title = "Visual", Icon = "eye"})
VisualTab:Section({Title = "Skybox Changer", TextSize = 16})
local skyboxDropdownReady = false
VisualTab:Dropdown({Title = "Skybox", Desc = "Choose sky visual", Values = {"Space", "GreenAurora", "PurpleNight", "MinecraftSky", "Default", "PurpleSplash", "Night", "Sun", "Moon", "Rain"}, Value = "Default", Callback = function(option2)
	if not skyboxDropdownReady then skyboxDropdownReady = true; return end
	if option2 == "Sun" then KS.setSunSky()
	elseif option2 == "Moon" then KS.setMoonSky()
	elseif option2 == "Rain" then KS.setRainSky()
	else KS.applySkybox(option2) end
end})
VisualTab:Space()
VisualTab:Section({Title = "Map Color", TextSize = 16})
colorPickerReady = false

local function getGrassParts()
	local GM, GX
	GM = {}
	for _, G5 in pairs(Workspace:GetDescendants()) do
		if G5:IsA("BasePart") then
			GX = string.lower(G5.Name)
			if (G5.Material == Enum.Material.Grass or string.find(GX, "grass") or string.find(GX, "pitch") or string.find(GX, "field") or string.find(GX, "grama")) and not string.find(GX, "line") and not string.find(GX, "linha") then
				table.insert(GM, G5)
			end
		end
	end
	return GM
end

local function saveOriginalColors()
	for _, He in pairs(getGrassParts()) do
		if not originalColors[He] then originalColors[He] = He.Color end
	end
end

local function setMapColor(m4)
	saveOriginalColors()
	for Hn, m8 in pairs(originalColors) do
		if Hn and Hn.Parent then Hn.Color = m4 end
	end
end

local function restoreMapColor()
	for nc, nd in pairs(originalColors) do
		if nc and nc.Parent then nc.Color = nd end
	end
end

VisualTab:Colorpicker({Title = "Map Color", Desc = "Map color (grass)", Default = Color3.fromRGB(255, 255, 255), Callback = function(color)
	if not colorPickerReady then colorPickerReady = true; return end
	setMapColor(color)
end})
VisualTab:Space()
VisualTab:Button({Title = "Restore Map Color", Desc = "Restore original color", Callback = function()
	restoreMapColor()
end})
VisualTab:Space()
VisualTab:Section({Title = "Theme UI", TextSize = 16})
local backgroundDropdownReady = false
local selectedBackground = "Preto"
local backgroundNames = {"BlackCat", "catsamurai", "BlackHole", "Classic xiters", "Preto"}
VisualTab:Dropdown({Title = "Background", Desc = "Choose UI background image", Values = backgroundNames, Value = "Preto", Callback = function(option3)
	if not backgroundDropdownReady then backgroundDropdownReady = true; return end
	selectedBackground = option3
end})
VisualTab:Space()
VisualTab:Button({Title = "Apply Background", Desc = "Apply chosen background", Callback = function()
	local HH, HL
	HH = Backgrounds[selectedBackground]
	if not HH then return end
	HL = false
	for _, nD in ipairs({function() Window:SetBackground(HH) end, function() Window:SetBackgroundImage(HH) end, function() Window.Background = HH end, function() Window.BackgroundImage = HH end}) do
		if pcall(nD) then HL = true end
		if HL then break end
	end
end})
VisualTab:Space()
VisualTab:Section({Title = "Changer Ball", TextSize = 16})
local ballSkins = {["Champions Laranja"] = {Texture = "http://www.roblox.com/asset/?id=6631296730", Mesh = "rbxassetid://4545270159"}, ["Champions Azul"] = {Texture = "rbxassetid://8108082224", Mesh = "rbxassetid://4454597214"}, ["Champions Branca"] = {Texture = "http://www.roblox.com/asset/?id=7897839361", Mesh = "rbxassetid://4761031195"}}
local ballSkinNames = {"Champions Laranja", "Champions Azul", "Champions Branca"}
local ballDropdownReady = false

local function findBalls()
	local HQ, H_
	HQ = {}
	for _, H7 in pairs(Workspace:GetDescendants()) do
		if H7:IsA("BasePart") then
			H_ = string.lower(H7.Name)
			if H_ == "football" or H_ == "ball" or H_ == "soccerball" or H_ == "tps" or H_ == "hitbox" or H_ == "bola" or string.find(H_, "tcs") then
				table.insert(HQ, H7)
			end
		end
	end
	return HQ
end

local function applyBallSkin(nP)
	local Il = ballSkins[nP]
	if not Il then return end
	for _, Is in pairs(findBalls()) do
		pcall(function()
			local H9 = Is:FindFirstChildOfClass("SpecialMesh")
			if Is:IsA("MeshPart") then
				Is.MeshId = Il.Mesh
				Is.TextureID = Il.Texture
			else
				if not H9 then H9 = Instance.new("SpecialMesh", Is) end
				H9.MeshType = Enum.MeshType.FileMesh
				H9.MeshId = Il.Mesh
				H9.TextureId = Il.Texture
			end
			for _, Ij in pairs(Is:GetChildren()) do
				if Ij:IsA("Decal") or Ij:IsA("Texture") then
					Ij.Texture = Il.Texture
					Ij.Transparency = 0
				end
			end
		end)
	end
end

VisualTab:Dropdown({Title = "Select Ball", Desc = "Choose a Champions ball to apply", Values = ballSkinNames, Value = "Champions Laranja", Callback = function(option4)
	if not ballDropdownReady then ballDropdownReady = true; return end
	applyBallSkin(option4)
end})

-- ============ DISCORD TAB ============
local DiscordTab = Window:Tab({Title = "Discord", Icon = "message-circle"})
local inviteCode = "dHtWuMSmSG"
local inviteApiUrl = "https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=true&with_expiration=true"
local discordDescription = "The official kirtium.qyz community"
local synRequest = syn
local tmp6
if synRequest then tmp6 = syn.request end
local requestFn = tmp6 or http_request or request
local httpRequest = requestFn
if httpRequest then
	local requestOk, response = pcall(function()
		local oc = httpRequest({Url = inviteApiUrl, Method = "GET", Headers = {["User-Agent"] = "Roblox"}})
		return HttpService:JSONDecode(oc.Body)
	end)
	local hasDescription = requestOk and response and response.guild and response.guild.description and not (response.guild.description == "")
	if hasDescription then discordDescription = response.guild.description end
end
DiscordTab:Section({Title = "Join our Discord server!", TextSize = 20})
DiscordTab:Paragraph({Title = "kirtium.qyz", Desc = discordDescription, Image = "rbxassetid://75489164889751", ImageSize = 48, Buttons = {{Title = "Copy link", Icon = "link", Callback = function()
	if setclipboard then
		setclipboard("https://discord.gg/" .. inviteCode)
	else
		WindUI:Notify({Title = "Discord Invite Link", Content = "https://discord.gg/" .. inviteCode})
	end
end}}})

-- ============ FINAL ============
Window:SetToggleKey(Enum.KeyCode.M)
_G.KirtiumUI = Window

LocalPlayer.CharacterAdded:Connect(function()
	if TOT.active then KS.enableTotMobile() end
	if C.enabled then
		C.holding = false
		C.canCatch = true
		C.lastCatch = 0
	end
	if S.reachConfig.isActive then KS.clearHitbox() end
end)

Workspace.DescendantRemoving:Connect(function(ov)
	if ov:IsA("BasePart") and ov.Name == "TPS" then
		if C.holding then C.holding = false end
	end
end)

print("[Kirtium] Parte 5/5 carregada ✔ — Script completo!")
