-- // Variables
getgenv().CNPrivateLoaded = true
local CNPrivateLogo, GetTime = game:HttpGet("https://i.ibb.co/7zCf4TZ/XDD.png"), os.clock()

local NoclipMacro, Macro, PanicMode, TriggerBot, Desync, FreezePos, FrameSkip, FakeSpike = false, false, false, false, false, false, false, false
local ClosestPointCF, ToolConnection, SilentTarget, AimTarget, ForceLock, keybindTime, LastStutter = nil, nil, nil, nil, nil, 0, tick()
local SmoothingFactor, PositionData, PositionData2, CurrentIndex, CurrentIndex2, CurrentVelocity, CurrentVelocity2 = 6, {}, {}, 1, 1, Vector3.zero, Vector3.zero

local Script = {Functions = {}, Friends = {}, Drawing = {}, EspPlayers = {}, NotifyNote = {}, BeizerManager = {}, BeizerCurve = {}, PanicModeSaves = {}, SavedValue = {}}

local Saves = {ShotCheck = {}, CharCheck = {}, AddedCheck = {}}
local Detection = {OldAmmo = {}, Suspicious = {}, NewBullets = nil}

local Players, Client, Mouse, RS, Camera, GuiS, Uis, Tween = game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer:GetMouse(), game:GetService("RunService"), game:GetService("Workspace").CurrentCamera, game:GetService("GuiService"), game:GetService("UserInputService"), game:GetService("TweenService")

Script.SavedValue.SilentPart = CNPrivate.Silent.Part
Script.SavedValue.AimAssistSmoothX = CNPrivate.AimAssist.Smoothness_X
Script.SavedValue.AimAssistSmoothY = CNPrivate.AimAssist.Smoothness_Y
Script.SavedValue.ShakeX = CNPrivate.AimAssist.Shake.Shake_X
Script.SavedValue.ShakeY = CNPrivate.AimAssist.Shake.Shake_Y
Script.SavedValue.ShakeZ = CNPrivate.AimAssist.Shake.Shake_Z

Script.BeizerCurve.Offset = Vector2.new(0,0)

-- // Using Thise For TweenService Support + Im 2 Lazy
local SilentFovRadius = Instance.new("NumberValue")
SilentFovRadius.Name = "DevConsole"
SilentFovRadius.Parent = nil
SilentFovRadius.Value = CNPrivate.Silent.Fov.Radius

-- // Main Intro Local
if CNPrivate.Options.Intro then
    local Flash = Instance.new("ColorCorrectionEffect")
    local Blur = Instance.new("BlurEffect")
    local Gui = Instance.new("ScreenGui")
    local Image = Instance.new("ImageLabel")
    
    Flash.Parent = game.Lighting

    Blur.Parent = game.Lighting
    Blur.Size = 0
    
    Gui.Name = "RobloxGui"
    Gui.Parent = game.CoreGui
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Image.Parent = Gui
    Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Image.BackgroundTransparency = 1.000
    Image.Position = UDim2.new(0.405, 0, 0.405, 0)
    Image.Size = UDim2.new(0.17, 0, 0.27, 0)
    Image.ImageTransparency = 1
    Image.Image = "rbxassetid://12714203201"
    
    local Create = Tween:Create(Blur, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = 50})
    Create:Play()
    Create.Completed:Wait()
    local Create2 = Tween:Create(Image, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {ImageTransparency = 0.2})
    Create2:Play()
    Create2.Completed:Wait()
    local Create3 = Tween:Create(Image, TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(0.15, 0, 0.25, 0)})
    Create3:Play()
    local Create4 = Tween:Create(Image, TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(0.415, 0, 0.415, 0)})
    Create4:Play()
    Flash.TintColor = Color3.fromRGB(223, 91, 91)
    Tween:Create(Flash, TweenInfo.new(0.7), {TintColor = Color3.fromRGB(255, 255, 255)}):Play()
    task.wait(1)
    Tween:Create(Image, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
    local Create5 = Tween:Create(Blur, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0})
    Create5:Play()
    Create5.Completed:Wait()
    
    Gui:Destroy()
    Flash:Destroy()
    Blur:Destroy()
end

-- // Low Gfx Function
if CNPrivate.Options.AutoLowGfx then
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
            if v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
end

-- // BoomBox Mute Function
if CNPrivate.Options.MuteBoomBox then
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("Sound") and not (v.Name == "ShootSound" or v.Name == "NoAmmo") then
            v.Volume = 0
        end
    end
end

-- // Seat Remove Function
if CNPrivate.Options.RemoveSeats then
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("Seat") then
            v:Destroy()
        end
    end
end

-- // The Gui V2. Not Giving Away

-- // Drawing For AimAssist, SilentAim And Desync Dot
Script.Drawing.SilentCircle = Drawing.new("Circle")
Script.Drawing.SilentCircle.Color = Color3.new(1,1,1)
Script.Drawing.SilentCircle.Thickness = 1
Script.Drawing.SilentCircle.NumSides = 128

Script.Drawing.AimAssistCircle = Drawing.new("Circle")
Script.Drawing.AimAssistCircle.Color = Color3.new(1,1,1)
Script.Drawing.AimAssistCircle.Thickness = 1
Script.Drawing.AimAssistCircle.NumSides = 128

Script.Drawing.DesyncCircle = Drawing.new("Circle")
Script.Drawing.DesyncCircle.Color = CNPrivate.Desync.Visualize.Color
Script.Drawing.DesyncCircle.NumSides = 128
Script.Drawing.DesyncCircle.Transparency = 1
Script.Drawing.DesyncCircle.Radius = CNPrivate.Desync.Visualize.Radius
Script.Drawing.DesyncCircle.Filled = true
Script.Drawing.DesyncCircle.Visible = false

-- // Checks If The Player Is Alive
Script.Functions.Alive = function(Plr)
    return (Plr and Plr.Character and Plr.Character:FindFirstChild("Humanoid") and Plr.Character:FindFirstChild("HumanoidRootPart")) and true or false
end

-- // Checks If Player Is On Your Screen
Script.Functions.OnScreen = function(Object)
    local _, OnScreen = Camera:WorldToScreenPoint(Object.Position)
    return OnScreen
end

-- // Gets The Fov Method
Script.Functions.GetFovPosition = function()
    if CNPrivate.Silent.Fov.Method == ("Screen") then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        return Vector2.new(Mouse.X, Mouse.Y)
    end
end

-- // Gets Magnitude From Part Position And Mouse
Script.Functions.GetMagnitudeFromMouse = function(Part)
    local PartPos, OnScreen = Camera:WorldToScreenPoint(Part.Position)
    if OnScreen then
        local GetScreenPos = Script.Functions.GetFovPosition()
        local Magnitude = ((Vector2.new(PartPos.X, PartPos.Y) - GetScreenPos) - CNPrivate.Silent.Fov.Offset).Magnitude
        return Magnitude
    end
    return math.huge
end

-- // Makes Random Number With Vector3 
Script.Functions.RandomVec3 = function(Number, Multi)
    return (Vector3.new(math.random(-Number, Number), math.random(-Number, Number), math.random(-Number, Number)) * Multi or 1)
end

-- // Checks If The Player Is Behind A Wall Or Something Else
Script.Functions.WallCheck = function(Pos, PartDescendant)
    local Character = Client.Character
    local Origin = Camera.CFrame.Position

    local RayCastParams = RaycastParams.new()
    RayCastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RayCastParams.FilterDescendantsInstances = {Character, Camera}

    local Result = Workspace.Raycast(Workspace, Origin, Pos - Origin, RayCastParams)
    
    if (Result) then
        local PartHit = Result.Instance
        local Visible = (not PartHit or Instance.new("Part").IsDescendantOf(PartHit, PartDescendant))
        
        return Visible
    end
    return false
end

-- // Random Number To Compare
Script.Functions.CalculateChance = function(Percentage)
    Percentage = math.floor(Percentage)
    return math.random(0, 99) < Percentage
end

-- // Check If Crew Folder Is A Thing
Script.Functions.FindCrew = function(Plr)
	if Plr:FindFirstChild("DataFolder") and Plr.DataFolder:FindFirstChild("Information") and Plr.DataFolder.Information:FindFirstChild("Crew") and Client:FindFirstChild("DataFolder") and Client.DataFolder:FindFirstChild("Information") and Client.DataFolder.Information:FindFirstChild("Crew") then
        if Client.DataFolder.Information:FindFirstChild("Crew").Value ~= nil and Plr.DataFolder.Information:FindFirstChild("Crew").Value ~= nil and Plr.DataFolder.Information:FindFirstChild("Crew").Value ~= ("") and Client.DataFolder.Information:FindFirstChild("Crew").Value ~= ("") then 
			return true
		end
	end
	return false
end

-- // Clears AnyThing In The Console
Script.Functions.ClearConsole = function()
    coroutine.resume(coroutine.create(function()
        local DevConsole = game:GetService("CoreGui"):WaitForChild("DevConsoleMaster")
        local DevWindow = DevConsole:WaitForChild("DevConsoleWindow")
        local DevUI = DevWindow:WaitForChild("DevConsoleUI")
        local MainView = DevUI:WaitForChild("MainView")
        local ClientLog = MainView:WaitForChild("ClientLog")
        for _, v in pairs(ClientLog:GetChildren()) do
            if v:IsA("GuiObject") and v.Name == v.Name:match("%d+") then
                v:Destroy()
            end
        end
    end))
end

-- // Calculates The Velocity
Script.Functions.GetVelocity = function(PositionData)
	local TotalVelocity = 0
	local AveragePosition = Vector3.zero
	local AverageTime = 0
	local GetData = #PositionData
	if GetData == 0 then
		return AveragePosition, AverageTime
	end
	for i = 1, GetData do
		local Data = PositionData[i]
		if Data and Data.Position then
			local Velocity = SmoothingFactor - i + 1
			AveragePosition = AveragePosition + (Data.Position * Velocity)
			AverageTime = AverageTime + (Data.Time * Velocity)
			TotalVelocity = TotalVelocity + Velocity
		end
	end
	AveragePosition = AveragePosition / TotalVelocity
	AverageTime = AverageTime / TotalVelocity
	return AveragePosition, AverageTime
end

-- // Smoothness The Velocity Out
Script.Functions.ComPlexVelocity = function(Plr, CurrentPos, Mode)
	local GetTick = tick()
    local GetPos = CurrentPos

    -- // Fixes Calculating The Wrong Position
    if Mode then
        if PositionData2[CurrentIndex2] and PositionData2[CurrentIndex2].Target and tostring(Plr) ~= PositionData2[CurrentIndex2].Target then
            PositionData2[CurrentIndex2] = {Target = tostring(Plr), Position = GetPos, Time = GetTick}
            return Vector3.zero
        end
    else
        if PositionData[CurrentIndex] and PositionData[CurrentIndex].Target and tostring(Plr) ~= PositionData[CurrentIndex].Target then
            PositionData[CurrentIndex] = {Target = tostring(Plr), Position = GetPos, Time = GetTick}
            return Vector3.zero
        end
    end

    if Mode then
    	PositionData2[CurrentIndex2] = {Target = tostring(Plr), Position = GetPos, Time = GetTick}
    	CurrentIndex2 = (CurrentIndex2 % SmoothingFactor) + 1
    	local AveragePosition, AverageTime = Script.Functions.GetVelocity(PositionData2)
    	local PreviousData = PositionData2[CurrentIndex2]
    	if PreviousData and PreviousData.Position then
    		local Velocity = (GetPos - PreviousData.Position) / (GetTick - PreviousData.Time)
    		return Velocity
    	end
    else
    	PositionData[CurrentIndex] = {Target = tostring(Plr), Position = GetPos, Time = GetTick}
    	CurrentIndex = (CurrentIndex % SmoothingFactor) + 1
    	local AveragePosition, AverageTime = Script.Functions.GetVelocity(PositionData)
    	local PreviousData = PositionData[CurrentIndex]
    	if PreviousData and PreviousData.Position then
    		local Velocity = (GetPos - PreviousData.Position) / (GetTick - PreviousData.Time)
    		return Velocity
    	end
    end
    return Vector3.zero
end

-- // Changes The Mouse Position
Script.Functions.MouseOffset = function(self, X, Y)
    local NewPosition = Vector2.new(X, Y) - CNPrivate.Silent.Fov.Offset
    mousemoveabs(NewPosition.X, NewPosition.Y)
end

-- // Splits The Gun Name And Splits []
Script.Functions.GetGunName = function(Name)
    local split = string.split(string.split(Name, "[")[2], "]")[1]
    return split
end

-- // Gets Current Gun
Script.Functions.GetCurrentWeaponName = function()
    if Client.Character and Client.Character:FindFirstChildWhichIsA("Tool") then
       local Tool =  Client.Character:FindFirstChildWhichIsA("Tool")
       if string.find(Tool.Name, "%[") and string.find(Tool.Name, "%]") and not string.find(Tool.Name, "Wallet") and not string.find(Tool.Name, "Phone") then
          return Script.Functions.GetGunName(Tool.Name)
       end
    end
    return nil
end

-- // Drawing Function With Property Attached
Script.Functions.NewDrawing = function(Type, Properties)
    local NewDrawing = Drawing.new(Type)
    for i, v in next, Properties or {} do
        NewDrawing[i] = v
    end
    return NewDrawing
end

-- // Draws For The New Players Joining For Esp
Script.Functions.NewPlayer = function(Plr)
    Script.EspPlayers[Plr] = {
        Name = Script.Functions.NewDrawing("Text", {Color = Color3.fromRGB(255,2550, 255), Outline = true, Visible = false, Center = true, Size = 13, Font = 0}),
        
        BoxOutline = Script.Functions.NewDrawing("Square", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Visible = false}),
        Box = Script.Functions.NewDrawing("Square", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Visible = false}),
        
        HealthBarOutline = Script.Functions.NewDrawing("Line", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Visible = false}),
        HealthBar = Script.Functions.NewDrawing("Line", {Color = Color3.fromRGB(0, 255, 0), Thickness = 1, Visible = false}),
        HealthText = Script.Functions.NewDrawing("Text", {Color = Color3.fromRGB(0, 255, 0), Outline = true, Visible = false, Center = true, Size = 13, Font = 0}),
        
        ArmorBarOutline = Script.Functions.NewDrawing("Line", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Visible = false}),
        ArmorBar = Script.Functions.NewDrawing("Line", {Color = Color3.fromRGB(0, 255, 0), Thickness = 1, Visible = false}),
        ArmorText = Script.Functions.NewDrawing("Text", {Color = Color3.fromRGB(0, 255, 0), Outline = true, Visible = false, Center = true, Size = 13, Font = 0}),
        
        Distance = Script.Functions.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Visible = false, Center = true, Size = 13, Font = 0}),
        
        Tool = Script.Functions.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Visible = false, Center = true, Size = 13, Font = 0}),
        
        Flag = Script.Functions.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Visible = false, Center = true, Size = 13, Font = 0}),
        
        Tracer = Script.Functions.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 244), Thickness = 1, Visible = false}),
    }
end

-- // The Notification Ui Function
Script.Functions.CreateNotification = function(Text, CustomColor)
	local Gap = 25
	local Width = 18
	local Alpha = 255
	local Time = 0
	local EStep = 0
	local EEStep = 0.02
	local InSety = 0

	local Note = {
		Enabled = true,
		TargetPos = Vector2.new(50, 33),
		Size = Vector2.new(200, Width),
		
		Drawings = {
		    Outline = Script.Functions.NewDrawing("Square", {Size = Vector2.new(202, Width + 2), Filled = false, Visible = true, Thickness = 1, Position = Vector2.new(), Color = Color3.new(0, 0, 0)}),
			Fade = Script.Functions.NewDrawing("Square", {Size = Vector2.new(202, Width + 2), Filled = false, Visible = true, Thickness = 1, Position = Vector2.new(), Color = Color3.new(0, 0, 0)}),
		},
        
		Remove = function(self, Part)
			if Part.Position.x < Part.Size.x then
				for _, v in pairs(self.Drawings) do
					v:Remove()
					v = false
				end
				self.Enabled = false
			end
		end,

		Update = function(self, Number, ListLength, Dt)
			local Pos = self.TargetPos
			local indexOffset = (ListLength - Number) * Gap
            
			if InSety < indexOffset then
				InSety = InSety - (InSety - indexOffset) * 0.2
			else
				InSety = indexOffset
			end

			local Size = self.Size
			local LastPos = Vector2.new(Pos.x - Size.x / Time - (Alpha / 255 * -Size.x + Size.x), Pos.y + InSety)
			self.Pos = LastPos
			
			local CurrentPos = {
				X = math.ceil(LastPos.x),
				Y = math.ceil(LastPos.y),
				W = math.floor(Size.x - (255 - Alpha) / (255 * 70)),
				H = Size.y,
			}
			
			local Fade = math.min(Time * 12, Alpha)
			Fade = Fade > 255 and 255 or Fade < 0 and 0 or Fade

			if self.Enabled then
				local LineRepeat = 1
				for i, v in pairs(self.Drawings) do
					v.Transparency = Fade / 255
					if type(i) == ("number") then
						v.Position = Vector2.new(CurrentPos.X + 1, CurrentPos.Y + i)
						v.Size = Vector2.new(CurrentPos.W - 2, 1)
					elseif i == ("Image") then
					    v.Position = LastPos + Vector2.new(6, 2)
					elseif i == ("Text") then
						v.Position = LastPos + Vector2.new(25, 2)
					elseif i == ("Outline") then
						v.Position = Vector2.new(CurrentPos.X, CurrentPos.Y)
						v.Size = Vector2.new(CurrentPos.W, CurrentPos.H)
					elseif i == ("Fade") then
						v.Position = Vector2.new(CurrentPos.X - 1, CurrentPos.Y - 1)
						v.Size = Vector2.new(CurrentPos.W + 2, CurrentPos.H + 2)
						local T = (200 - Fade) / 255 / 3
						v.Transparency = T < 0.4 and 0.4 or T
					elseif i:find("line") then
						v.Position = Vector2.new(CurrentPos.X + LineRepeat, CurrentPos.Y + 1)
						LineRepeat = LineRepeat + 1
					end
				end

				Time = Time + EStep * Dt * 128 
				EStep = EStep + EEStep * Dt * 64
			end
		end,

		Fade = function(self, Number, Len, Dt)
			if self.Pos.x > self.TargetPos.x - 0.2 * Len or self.Fading then
				if not self.Fading then
					EStep = 0
				end
				self.Fading = true
				Alpha = Alpha - EStep / 4 * Len * Dt * 50
				EEStep = EEStep + 0.01 * Dt * 100
			end
			
            if Alpha <= 0 then
				self:Remove(self.Drawings[1])
			end
		end,
	}

    for i = 1, Note.Size.y - 2 do
    	local X = 0.28 - i / 80
    	Note.Drawings[i] = Script.Functions.NewDrawing("Square", {Size = Vector2.new(200, 1), Filled = true, Visible = true, Thickness = 1, Position = Vector2.new(), Color = Color3.new(X, X, X)})
    end
    
    local C = CustomColor or Color3.fromRGB(206, 67, 67)
    Note.Drawings.Text = Script.Functions.NewDrawing("Text", {Size = 13,Text = Text , Visible = true, Center = false, Outline = true, Font = 2, Position = Vector2.new(), Color = Color3.new(1, 1, 1)})
    Note.Drawings.Image = Script.Functions.NewDrawing("Image", {Size = Vector2.new(15,15), Visible = true, Position = Vector2.new(), Data = CNPrivateLogo})

    if Note.Drawings.Text.TextBounds.x + 7 > Note.Size.x then
    	Note.Size = Vector2.new(Note.Drawings.Text.TextBounds.x + 27, Note.Size.y)
    end
    
    Note.Drawings.line = Script.Functions.NewDrawing("Square", {Size = Vector2.new(1, Note.Size.y - 2), Filled = true, Visible = true, Thickness = 1, Position = Vector2.new(), Color = C})
    Note.Drawings.line1 = Script.Functions.NewDrawing("Square", {Size = Vector2.new(1, Note.Size.y - 2), Filled = true, Visible = true, Thickness = 1, Position = Vector2.new(), Color = C})
    Script.NotifyNote[#Script.NotifyNote + 1] = Note
end

-- // Gets The Closest Part Of The Character To Cursor
Script.Functions.GetClosestBodyPart = function(Char)
    local Distance = math.huge
    local ClosestPart = nil
    local Filterd = {}

    local Parts = Char:GetChildren()
    for _, v in pairs(Parts) do
        if CNPrivate.Silent.UseWhitelistedParts and table.find(CNPrivate.Silent.WhitelistedPart, v.Name) == nil then continue end
        if v:IsA("MeshPart") and v:IsA("BasePart") and Script.Functions.OnScreen(v) then
            table.insert(Filterd, v)
            for _, v in pairs(Filterd) do                
                local Magnitude = Script.Functions.GetMagnitudeFromMouse(v)
                if Magnitude < Distance then
                    ClosestPart = v
                    Distance = Magnitude
                end
            end
        end
    end
    return ClosestPart
end

-- // Gets An Random Part Of The Character
Script.Functions.GetRandomBodyPart = function(Char)
    local CurrentParts = {}
    local Parts = Char:GetChildren()
    
    for _, v in pairs(Parts) do
        if CNPrivate.Silent.UseWhitelistedParts and table.find(CNPrivate.Silent.WhitelistedPart, v.Name) == nil then continue end
        if v:IsA("MeshPart") and v:IsA("BasePart") and Script.Functions.OnScreen(v) then
            table.insert(CurrentParts, v)
        end
    end
    
    local Randomize = CurrentParts[math.random(1, #CurrentParts)]
    return Randomize
end

-- // Gets The Closest Point From Cursor
Script.Functions.GetClosestPointOnPart = function(Part)
    local Transform = Part.CFrame:PointToObjectSpace(Mouse.Hit.Position)
    return Part.CFrame * Vector3.new(
        math.clamp(Transform.X, - Part.Size.X % (CNPrivate.Silent.ClosestPointScale / 2), Part.Size.X % (CNPrivate.Silent.ClosestPointScale / 2)), 
        math.clamp(Transform.Y, - Part.Size.Y % (CNPrivate.Silent.ClosestPointScale / 2), Part.Size.Y % (CNPrivate.Silent.ClosestPointScale / 2)), 
        math.clamp(Transform.Z, - Part.Size.Z % (CNPrivate.Silent.ClosestPointScale / 2), Part.Size.Z % (CNPrivate.Silent.ClosestPointScale / 2))
    )
end

-- // Mod Detection Function
Script.Functions.CheckIfMod = function(Plr)
    if CNPrivate.ModDetection.Enabled then
        if (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Creator.CreatorType == "Group" and true or false) == true then
            local GetId = game:GetService("GroupService"):GetGroupInfoAsync(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Creator.CreatorTargetId).Id
            local GroupId = tonumber(GetId)
            
            if Plr:IsInGroup(GroupId) and Plr:GetRankInGroup(GroupId) > CNPrivate.ModDetection.Rank then
                if CNPrivate.ModDetection.Method == ("Kick") then 
                    task.wait(CNPrivate.ModDetection.Delay)
                    Client:Kick("Detected Moderator / Admin: " .. tostring(Plr))
                elseif CNPrivate.ModDetection.Method == ("Notification") then
                    Script.Functions.CreateNotification("Detected Moderator / Admin: " .. tostring(Plr), Color3.fromRGB(206, 67, 67))
                end
            end
        end
    end
end

-- // Gets The Closest Player For Cursor (Silent Aim)
Script.Functions.GetClosestPlayer = function(Mode)
    local Target, Closest, HitChance = nil, math.huge, Script.Functions.CalculateChance(CNPrivate.Silent.HitChance)
    
    if not HitChance then
        return nil
    end
    if Mode then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart") then
                if not Script.Functions.OnScreen(v.Character.HumanoidRootPart) then continue end
                if CNPrivate.UniversalCheck.WallCheck and not Script.Functions.WallCheck(v.Character.HumanoidRootPart.Position, v.Character) then continue end
                local Distance = Script.Functions.GetMagnitudeFromMouse(v.Character.HumanoidRootPart)
                if (CNPrivate.Silent.ForceLock and Script.Drawing.SilentCircle.Radius + (Distance * 0.3) < Distance) then continue end
                if Distance < Closest then
                    Closest = Distance
                    Target = v
                end
            end
        end
    else
        if CNPrivate.Silent.ForceLock_AimAssistTarget and Script.Functions.Alive(AimTarget) then
            Target = AimTarget
        elseif CNPrivate.Silent.ForceLock_AimAssistTarget == false then
            Target = ForceLock
        end
    end
    
    if Script.Functions.Alive(Target) then
        local Velocity = Script.Functions.ComPlexVelocity(Target, Target.Character.HumanoidRootPart.Position, false)
        CurrentVelocity = Velocity
    else
        CurrentVelocity = Vector3.zero
    end

    return Target
end

-- // Target Check For Silent Aim Target
Script.Functions.SilentCheck = function(Plr)
    if CNPrivate.UniversalCheck.KoCheck and Plr.Character:FindFirstChild("BodyEffects") then
        local KoCheck = false
        if Plr.Character.BodyEffects:FindFirstChild("K.O") then
            KoCheck = Plr.Character.BodyEffects["K.O"].Value
        elseif Plr.Character.BodyEffects:FindFirstChild("KO") then
            KoCheck = Plr.Character.BodyEffects.KO.Value
        end
        local Grabbed = Plr.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
        if KoCheck or Grabbed then 
            return false 
        end
    end
    if CNPrivate.UniversalCheck.FriendCheck and table.find(Script.Friends, Plr) then
        return false  
    end
    if CNPrivate.UniversalCheck.TargetDeathCheck and Plr.Character:FindFirstChild("Humanoid") and Plr.Character.Humanoid.health < 4 then
        return false 
    end
    if CNPrivate.UniversalCheck.ForceFieldCheck and Plr.Character:FindFirstChildOfClass("ForceField") then
        return false
    end
    if CNPrivate.UniversalCheck.InVisibleCheck and Plr.Character:FindFirstChild("Head") and Plr.Character.Head.Transparency > 0.5 then
        return false  
    end
    if CNPrivate.UniversalCheck.CrewCheck and Script.Functions.FindCrew(Plr) and Plr.DataFolder.Information:FindFirstChild("Crew").Value ~= Client.DataFolder.Information:FindFirstChild("Crew").Value then 
        return false  
    end
    if CNPrivate.UniversalCheck.TeamCheck and Client.Team ~= nil and Plr.Team ~= nil and Plr.Team == Client.Team then 
        return false 
    end
    return true
end

-- // Error Detection Function

-- // Cheater Detection Function

-- // Gets The Closest Part From The Target And Checks If AimAssist Is On To Save Fps
Script.Functions.GetClosestPartMethod = function(Plr)
    local ClosestPart, PartClosest, Filterd = nil, math.huge, {}
    
    if CNPrivate.Silent.LegitMode then
        if CNPrivate.Silent.ClosestPart == false and Plr.Character:FindFirstChild(CNPrivate.Silent.Part) then
            return Plr.Character[CNPrivate.Silent.Part]
        elseif AimTarget and CNPrivate.AimAssist.ClosestPart and Plr.Character:FindFirstChild(CNPrivate.AimAssist.Part) then
            return Plr.Character[CNPrivate.AimAssist.Part]
        end
        return nil
    end
    
    if Script.Functions.Alive(Plr) then
        if SilentTarget.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            local AirHitChance = Script.Functions.CalculateChance(CNPrivate.Silent.AirHitChance)
            if not AirHitChance then
                return nil
            end
            if CNPrivate.Silent.UseAirPart and SilentTarget.Character:FindFirstChild(CNPrivate.Silent.AirPart) then
                return SilentTarget.Character[CNPrivate.Silent.AirPart]
            end
        else
            if CNPrivate.Silent.UseAirPart and SilentTarget.Character:FindFirstChild(Script.SavedValue.SilentPart) then
                return SilentTarget.Character[Script.SavedValue.SilentPart]
            end
        end
        
        if CNPrivate.Silent.ClosestPart == false and Plr.Character:FindFirstChild(CNPrivate.Silent.Part) then
            local PartDistance = Script.Functions.GetMagnitudeFromMouse(Plr.Character[CNPrivate.Silent.Part])

            if (CNPrivate.Silent.ForceLock == false and Script.Drawing.SilentCircle.Radius + 4 > PartDistance) or CNPrivate.Silent.ForceLock == true then
                return Plr.Character[CNPrivate.Silent.Part]
            end
            return nil
        end
        
        local Parts = Plr.Character:GetChildren()
        for _, v in pairs(Parts) do
            if CNPrivate.Silent.UseWhitelistedParts and table.find(CNPrivate.Silent.WhitelistedPart, v.Name) == nil then continue end
            if v:IsA("MeshPart") and v:IsA("BasePart") and Script.Functions.OnScreen(v) then
                table.insert(Filterd, v)
                for _, v in pairs(Filterd) do
                    local Mag = Script.Functions.GetMagnitudeFromMouse(v)
                    if (CNPrivate.Silent.ForceLock == false and CNPrivate.Silent.LegitMode == false and Script.Drawing.SilentCircle.Radius + 4 < Mag) then continue end
                    if Mag < PartClosest then
                        ClosestPart = v
                        PartClosest = Mag
                    end
                end
            end
        end
        
        return ClosestPart
    end
    return nil
end

-- // Gets Closest Player From Mouse For AimAssist
Script.Functions.GetClosestPlayer2 = function()
    local Target, Distance, Closest = nil, nil, math.huge
    
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart") then
            if not Script.Functions.OnScreen(v.Character.HumanoidRootPart) then continue end
            if CNPrivate.UniversalCheck.WallCheck and not Script.Functions.WallCheck(v.Character.HumanoidRootPart.Position, v.Character) then continue end
        	if CNPrivate.UniversalCheck.InVisibleCheck and v.Character:FindFirstChild("Head") then
        		if v.Character.Head.Transparency > 0.5 then
        			continue
        		end
        	end
            if CNPrivate.UniversalCheck.ForceField and not v.Character:FindFirstChildOfClass("ForceField") then
                continue
            end
        	if CNPrivate.UniversalCheck.CrewCheck and Script.Functions.FindCrew(v) and v.DataFolder.Information:FindFirstChild("Crew").Value ~= Client.DataFolder.Information:FindFirstChild("Crew").Value then
        		continue
        	end
            if CNPrivate.UniversalCheck.TeamCheck and Client.Team ~= nil and v.Team ~= nil and v.Team ~= Client.Team then
                continue
            end
            if CNPrivate.UniversalCheck.FriendCheck and table.find(Script.Friends, v) ~= nil then
                continue
            end
            local Distance = Script.Functions.GetMagnitudeFromMouse(v.Character.HumanoidRootPart)
            if Distance < Closest then
                if (CNPrivate.AimAssist.UseCircleRadius and Script.Drawing.AimAssistCircle.Radius + (Distance * 0.3) < Distance) then continue end
                Closest = Distance
                Target = v
            end
        end
    end

    return Target
end

-- // Main Functions For The BeizerManager Functions
Script.BeizerManager.__index = Script.BeizerManager

-- // The Main Function That Makes It Work
Script.BeizerManager.New = function()
    local self = setmetatable({}, Script.BeizerManager)
    
    self.T = 0
    self.T_Threshold = 0.99995
    self.StartPoint = Vector2.new()
    self.EndPoint = Vector2.new()
    self.CurvePoints = {
        Vector2.new(1, 1),
        Vector2.new(1, 1)
    }
    self.Active = false
    self.Smoothness = 0.0025
    self.DrawPath = false
    self.Function = Script.Functions.MouseOffset

    self.Started = false

    return self
end

-- // Changes Current self Propertiesself.T 
Script.BeizerManager.ChangeData = function(self, Data)
    self.StartPoint = (self.GetStartPoint() or Data.StartPoint)
    self.EndPoint = self.ModifyEndPoint(Data.TargetPosition)
    self.Smoothness = Data.Smoothness or self.Smoothness
    self.CurvePoints = Data.CurvePoints or self.CurvePoints
    self.DrawPath = Data.DrawPath or self.DrawPath

    self.T = 0
    self.Active = true
end

-- // Calculates Every Points For More Accuracy
Script.BeizerManager.CubicCurve = function(T, StartPoint, EndPoint, ControlPointA, ControlPointB)
    local T1 = (1 - T)

    local A = T1^3 * StartPoint
    local B = 3 * T1^2 * T * ControlPointA
    local C = 3 * T1 * T^2 * ControlPointB
    local D = T^3 * EndPoint
    
    return A + B + C + D
end

-- // Controls And Calculates StartPoint And Other Stuff
Script.BeizerManager.DoControlPoint = function(StartPoint, EndPoint, ControlPointA, ControlPointB)
    local Change = (EndPoint - StartPoint)

    local A = StartPoint + (Change * ControlPointA)
    local B = StartPoint + (Change * ControlPointB)
    return A, B
end

-- // Draws Circle Where The CurvePosition And The Client Position
Script.BeizerManager.DrawPathFunc = function(CurvePosition, A, B)
    local Path = Script.Functions.NewDrawing("Circle", {Color = Color3.fromRGB(255, 150, 150), Radius = 2, Visible = true, Position = CurvePosition,})
    task.delay(1, function()
        Path:Remove()
    end)

    local ControlPointA = Script.Functions.NewDrawing("Circle", {Color = Color3.fromRGB(255, 150, 255), Radius = 5, Visible = true, Position = A,})
    task.delay(1, function()
        ControlPointA:Remove()
    end)

    local ControlPointB = Script.Functions.NewDrawing("Circle", {Color = Color3.fromRGB(255, 150, 255), Radius = 5, Visible = true, Position = B,})
    task.delay(1, function()
        ControlPointB:Remove()
    end)
end

-- // Changes The self For The Curving To Happend
Script.BeizerManager.DoIteration = function(self)
    if (self.Active == false) then
        return
    end
    local BeizerCurve = self.CubicCurve
    local T = self.T
    while (T <= 1 and self.Active) do RS.RenderStepped:Wait()
        T = T + self.Smoothness
        if (T >= self.T_Threshold) then
            local clampedT = math.clamp(T, 0, 1)
            local New = self.StartPoint:Lerp(self.EndPoint, clampedT)

            self:Function(New.X, New.Y)
        else
            local A, B = self.DoControlPoint(self.StartPoint, self.EndPoint, unpack(self.CurvePoints))
            local CurvePosition = BeizerCurve(T, self.StartPoint, self.EndPoint, A, B)
                
            if (self.DrawPath) then
                Script.BeizerManager.DrawPathFunc(CurvePosition, A, B)
            end
            self:Function(CurvePosition.X, CurvePosition.Y)
        end
    end
    self.Active = false
end

-- // Modifies The EndPoint Just For Double Checks
Script.BeizerManager.ModifyEndPoint = function(EndPoint)
    return EndPoint
end

-- // Starts The Motion
Script.BeizerManager.Start = function(self)
    self.Started = true

    local Thread = coroutine.resume(coroutine.create(function()
        while (self.Started) do RS.RenderStepped:Wait()
            self:DoIteration()
        end
    end))

    return Thread
end

-- // Stops The Motion
Script.BeizerManager.Stop = function(self)
    self.Started = false
end

-- // Stops The Current Motion
Script.BeizerManager.StopCurrent = function(self)
    self.Active = false
    self.T = 0
end

-- // Gets Camera Instead Of Mouse
Script.BeizerManager.CameraMode = function(self)
    self.GetStartPoint = function()
        local Pitch, Yaw, _ = Camera.CFrame:ToEulerAnglesYXZ()
        local StartPoint = Vector2.new(Pitch, Yaw)
        return StartPoint
    end

    self.ModifyEndPoint = function(EndPoint)
        local LookAtEndPoint = CFrame.lookAt(Camera.CFrame.Position, EndPoint)
        local Pitch, Yaw, _ = LookAtEndPoint:ToEulerAnglesYXZ()
        EndPoint = Vector2.new(Pitch, Yaw)
        return EndPoint
    end

    self.Function = function(self, Pitch, Yaw)
        local RotationMatrix = CFrame.fromEulerAnglesYXZ(Pitch, Yaw, 0)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * RotationMatrix
    end

    self.DrawPathFunc = function()
        -- // Working On It
    end
end

-- // Gets Mouse Position ServerSided
Script.BeizerManager.GetStartPoint = function()
    return Uis:GetMouseLocation()
end

-- // Gets Mouse Instead Of Camera
Script.BeizerManager.MouseMode = function(self)
    self.GetStartPoint = Script.BeizerManager.GetStartPoint
    self.ModifyEndPoint = Script.BeizerManager.ModifyEndPoint
    self.Function = Script.Functions.MouseOffset
    self.DrawPathFunc = Script.BeizerManager.DrawPathFunc
end

-- // Start BeizerCurve
local ManagerA = Script.BeizerManager.New()
local ManagerB = Script.BeizerManager.New()
Script.BeizerCurve.ManagerA = ManagerA
Script.BeizerCurve.ManagerB = ManagerB

Script.BeizerCurve.AimTo = function(...)
    ManagerA:ChangeData(...)
end

Script.BeizerCurve.AimToB = function(...)
    ManagerB:ChangeData(...)
end

ManagerB:CameraMode()

ManagerB.Function = function(self, Pitch, Yaw)
    local RotationMatrix = CFrame.fromEulerAnglesYXZ(Pitch, Yaw, 0)
    Utilities.SetCameraCFrame(CFrame.new(Camera.CFrame.Position) * RotationMatrix)
end

ManagerA:Start()
ManagerB:Start()

-- // Silent Get Part Position
Script.Functions.GetPartPosition = function(Plr)
    local TargetCF = nil
    local TargetFalling = false
    local SilentPos = nil
    
    if CNPrivate.Silent.ClosestPoint then
        TargetCF = ClosestPointCF
    else
        if Plr.Character:FindFirstChild(CNPrivate.Silent.Part) then
            TargetCF = Plr.Character[CNPrivate.Silent.Part].Position
        end
    end

    if CNPrivate.Silent.AntiGroundShots and CurrentVelocity.Y < CNPrivate.Silent.AntiGroundActivation then
        TargetFalling = true
    end
    if TargetCF and CurrentVelocity then
        SilentPos = TargetCF
        if CNPrivate.Silent.PredictMovement then 
            if CNPrivate.Silent.BlatantMode then
                local Enabled = true
                local Mag = (Plr.Character.Humanoid.MoveDirection).Magnitude
                local SilentVel = Plr.Character.HumanoidRootPart.Velocity
                if (SilentVel).Magnitude > 100 then
                    Enabled = false
                elseif SilentVel.Y > 50 then
                    Enabled = false
                elseif SilentVel.Y < -35 then
                    Enabled = false
                elseif SilentVel.Y > 75 then
                    Enabled = false
                elseif (SilentVel).Magnitude < 1 and Mag > 0.01 then
                    Enabled = false
                elseif (SilentVel).Magnitude > 5 and Mag < 0.01 then
                    Enabled = false
                end
                if Enabled and CNPrivate.UniversalCheck.WallCheck_V2 and not Script.Functions.WallCheck(Plr.Character.HumanoidRootPart.Position + (SilentTarget.Character.HumanoidRootPart.Velocity * CNPrivate.Silent.Prediction), Plr.Character) then
                    return
                end
                if Enabled then
                    if TargetFalling then
                        SilentPos = SilentPos + (Vector3.new(SilentVel.X, (SilentVel.Y * CNPrivate.Silent.AntiGroundValue), SilentVel.Z) * CNPrivate.Silent.Prediction)
                    else
                        SilentPos = SilentPos + (SilentVel * CNPrivate.Silent.Prediction)
                    end
                else
                    if TargetFalling then
                        SilentPos = SilentPos + (Vector3.new(CurrentVelocity.X, (CurrentVelocity.Y * CNPrivate.Silent.AntiGroundValue), CurrentVelocity.Z) * CNPrivate.Silent.Prediction)
                    else
                        SilentPos = SilentPos + (CurrentVelocity * CNPrivate.Silent.Prediction)
                    end
                end
            else
                if TargetFalling then
                    SilentPos = SilentPos + (Vector3.new(CurrentVelocity.X, (CurrentVelocity.Y * CNPrivate.Silent.AntiGroundValue), CurrentVelocity.Z) * CNPrivate.Silent.Prediction)
                else
                    SilentPos = SilentPos + (CurrentVelocity * CNPrivate.Silent.Prediction)
                end
            end
        end
        if CNPrivate.Silent.Humanize then
            local HumanizeValue = CNPrivate.Silent.HumanizeValue 
            SilentPos = (SilentPos + Script.Functions.RandomVec3(HumanizeValue, 0.01))
        end
    end
    if SilentPos then
        if CNPrivate.Silent.LegitMode then
            local PartPos = Camera:WorldToScreenPoint(SilentPos)
            local GetScreenPos = Script.Functions.GetFovPosition()
            local Magnitude = (Vector2.new(PartPos.X, PartPos.Y) - GetScreenPos).Magnitude

            if (CNPrivate.Silent.ForceLock == false and Script.Drawing.SilentCircle.Radius + 4 > Magnitude) or CNPrivate.Silent.ForceLock == true then
                return SilentPos
            end
        else
            return SilentPos
        end
    end
    return nil
end

local MousePosChanger2 = nil 
MousePosChanger2 = hookmetamethod(game, "__index", function(self, Index)
    if not checkcaller() and CNPrivate.Silent.Enabled and CNPrivate.Silent.AntiAimViewer == false and self == Mouse and Script.Functions.Alive(SilentTarget) then
        if Index == ("Hit") then
            local EndPoint = Script.Functions.GetPartPosition(SilentTarget)
            if EndPoint then
                return EndPoint
            end
        elseif Index == ("Target") and SilentTarget.Character:FindFirstChild(CNPrivate.Silent.Part) then 
            return SilentTarget.Character[CNPrivate.Silent.Part]
        end
    end
    return MousePosChanger2(self, Index)
end)

-- // The AimAssist Mouse Dragging/Check Functions
Script.Functions.MouseChanger = function()
    if CNPrivate.AimAssist.Enabled and not Uis:GetFocusedTextBox() and Script.Functions.Alive(AimTarget) and Script.Functions.Alive(Client) and AimTarget.Character:FindFirstChild(CNPrivate.AimAssist.Part) then
        local EndPosition = nil
        local TargetPos = AimTarget.Character[CNPrivate.AimAssist.Part].Position

        if CNPrivate.AimAssist.ThirdPerson and CNPrivate.AimAssist.FirstPerson == false then
            if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude < 1 then
                return
            end
        elseif CNPrivate.AimAssist.ThirdPerson == false and CNPrivate.AimAssist.FirstPerson then
            if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then
                return
            end
        end
        CurrentVelocity2 = Script.Functions.ComPlexVelocity(AimTarget, AimTarget.Character.HumanoidRootPart.Position, true)
        if CurrentVelocity2 == nil then return end
        if CNPrivate.AimAssist.EnableChance then
            local Chance = Script.Functions.CalculateChance(CNPrivate.AimAssist.Chance)
            if not Chance then
                return
            end
        end
        if CNPrivate.UniversalCheck.ToolOut and not Client.Character:FindFirstChildWhichIsA("Tool") then
            return
        end
        if CNPrivate.UniversalCheck.ForceFieldCheck and AimTarget.Character:FindFirstChildOfClass("ForceField") then
            AimTarget = nil
            CurrentVelocity2 = Vector3.zero
            return
        end
        if CNPrivate.AimAssist.RandomPart or CNPrivate.AimAssist.ClosestPart then
            if Script.Functions.OnScreen(AimTarget.Character.HumanoidRootPart) then
                if CNPrivate.AimAssist.RandomPart then
                    local RandomizedPart = Script.Functions.GetRandomBodyPart(AimTarget.Character)
                    if RandomizedPart ~= nil then
                        CNPrivate.AimAssist.Part = tostring(RandomizedPart)
                    end
                elseif CNPrivate.AimAssist.ClosestPart then
                    local ClosestPart = Script.Functions.GetClosestBodyPart(AimTarget.Character)
                    CNPrivate.AimAssist.Part = tostring(ClosestPart)
                end
            else
                if CNPrivate.AimAssist.Method == ("Mouse") then
                    return
                end
            end
        end
        if CNPrivate.UniversalCheck.ReloadCheck then
            for _, v in pairs(Client.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
                if tostring(v) == ("Animation") then
                    return
                end
            end
        end
        if CNPrivate.UniversalCheck.NoAmmoCheck and Client.Character:FindFirstChildWhichIsA("Tool") and Client.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Ammo") then
            if Client.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Ammo").Value <= 0 then
                return
            end
        end
        if CNPrivate.AimAssist.Advanced.WallCheck_V2 and not Script.Functions.WallCheck(AimTarget.Character.HumanoidRootPart.Position, AimTarget.Character) then 
            return
        end
        if CNPrivate.AimAssist.DisableOutSideCircle then
            local Magnitude = Script.Functions.GetMagnitudeFromMouse(AimTarget.Character.HumanoidRootPart)
            if (Script.Drawing.AimAssistCircle.Radius + 4) < Magnitude then
                return
            end
        end
        if CNPrivate.UniversalCheck.PlayerDeathCheck then
            if Client.Character.Humanoid.health < 4 then
                AimTarget = nil
                CurrentVelocity2 = Vector3.zero
                return
            end
        end
        if CNPrivate.UniversalCheck.KoCheck and AimTarget.Character:FindFirstChild("BodyEffects") then 
            local Grabbed = AimTarget.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            local KoCheck = true
            if AimTarget.Character.BodyEffects:FindFirstChild("K.O") then
                KoCheck = AimTarget.Character.BodyEffects["K.O"].Value
            elseif AimTarget.Character.BodyEffects:FindFirstChild("KO") then
                KoCheck = AimTarget.Character.BodyEffects.KO.Value
            end
            if KoCheck or Grabbed then
                AimTarget = nil
                CurrentVelocity2 = Vector3.zero
                return
            end
        end
        if CNPrivate.UniversalCheck.TargetDeathCheck then
            if AimTarget.Character.Humanoid.health < 4 then
                AimTarget = nil
                CurrentVelocity2 = Vector3.zero
                return
            end
        end
        if CNPrivate.AimAssist.Shake.AirShake or CNPrivate.AimAssist.AirSmoothness then
            if AimTarget.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                if CNPrivate.AimAssist.AirSmoothness then
                    CNPrivate.AimAssist.Smoothness_X = CNPrivate.AimAssist.AirSmoothness_X
                    CNPrivate.AimAssist.Smoothness_X = CNPrivate.AimAssist.AirSmoothness_Y
                end
                if CNPrivate.AimAssist.Shake.AirShake then
                    if CNPrivate.AimAssist.Shake.Shake_X == Script.SavedValue.ShakeX then
                        CNPrivate.AimAssist.Shake.Shake_X = CNPrivate.AimAssist.Shake.Shake_X * (CNPrivate.AimAssist.Shake.AirPercentage / 100)
                    end
                    if CNPrivate.AimAssist.Shake.Shake_Y == Script.SavedValue.ShakeY then
                        CNPrivate.AimAssist.Shake.Shake_Y = CNPrivate.AimAssist.Shake.Shake_Y * (CNPrivate.AimAssist.Shake.AirPercentage / 100)
                    end
                    if CNPrivate.AimAssist.Shake.Shake_Z == Script.SavedValue.ShakeZ then
                        CNPrivate.AimAssist.Shake.Shake_Z = CNPrivate.AimAssist.Shake.Shake_Z * (CNPrivate.AimAssist.Shake.AirPercentage / 100)
                    end
                end
            else
                if CNPrivate.AimAssist.AirSmoothness then
                    if CNPrivate.AimAssist.Smoothness_X ~= Script.SavedValue.AimAssistSmoothX then
                        CNPrivate.AimAssist.Smoothness_X = Script.SavedValue.AimAssistSmoothX
                    end
                    if CNPrivate.AimAssist.Smoothness_Y ~= Script.SavedValue.AimAssistSmoothY then
                        CNPrivate.AimAssist.Smoothness_Y = Script.SavedValue.AimAssistSmoothY
                    end
                end
                if CNPrivate.AimAssist.Shake.AirShake then
                    if CNPrivate.AimAssist.Shake.Shake_X ~= Script.SavedValue.ShakeX then
                        CNPrivate.AimAssist.Shake.Shake_X = Script.SavedValue.ShakeX
                    end
                    if CNPrivate.AimAssist.Shake.Shake_Y ~= Script.SavedValue.ShakeY then
                        CNPrivate.AimAssist.Shake.Shake_Y = Script.SavedValue.ShakeY
                    end
                    if CNPrivate.AimAssist.Shake.Shake_Z ~= Script.SavedValue.ShakeZ then
                        CNPrivate.AimAssist.Shake.Shake_Z = Script.SavedValue.ShakeZ
                    end
                end
            end
        end
        
        if FrameSkip and CNPrivate.AimAssist.FrameSkip.TargetPart.Enabled and AimTarget.Character:FindFirstChild(CNPrivate.AimAssist.FrameSkip.TargetPart.Part) then
            if CNPrivate.AimAssist.FrameSkip.UsePrediction then
                EndPosition = AimTarget.Character[CNPrivate.AimAssist.FrameSkip.TargetPart.Part].Position + (CurrentVelocity2 * CNPrivate.AimAssist.Prediction)
            else
                EndPosition = AimTarget.Character[CNPrivate.AimAssist.FrameSkip.TargetPart.Part].Position
            end
        elseif FrameSkip then
            if CNPrivate.AimAssist.FrameSkip.UsePrediction then
                EndPosition = TargetPos + (CurrentVelocity2 * CNPrivate.AimAssist.Prediction)
            else
                EndPosition = TargetPos
            end
        elseif CNPrivate.AimAssist.PredictMovement then
            EndPosition = TargetPos + (CurrentVelocity2 * CNPrivate.AimAssist.Prediction)
        else
            EndPosition = TargetPos
        end

        if (EndPosition and (tick() - LastStutter) >= (CNPrivate.AimAssist.Advanced.Stutter / 1000)) then
            LastStutter = tick()
            if CNPrivate.AimAssist.Shake.Enabled and FrameSkip == false then
                local Mag = math.ceil((EndPosition - Client.Character.HumanoidRootPart.Position).Magnitude)
                EndPosition = EndPosition + (Vector3.new(
                    math.random(-Mag * CNPrivate.AimAssist.Shake.Shake_X, Mag * CNPrivate.AimAssist.Shake.Shake_X), 
                    math.random(-Mag * CNPrivate.AimAssist.Shake.Shake_Y, Mag * CNPrivate.AimAssist.Shake.Shake_Y), 
                    math.random(-Mag * CNPrivate.AimAssist.Shake.Shake_Z, Mag * CNPrivate.AimAssist.Shake.Shake_Z)) / 1000
                )
            end
            if CNPrivate.AimAssist.Method == ("Mouse") then
                local Vec2Pos = Camera:WorldToScreenPoint(EndPosition)
                local InCrementX = (Vec2Pos.X - CNPrivate.Silent.Fov.Offset.X) * (CNPrivate.AimAssist.UseSmoothness and CNPrivate.AimAssist.Smoothness_X or 1)
                local InCrementY = (Vec2Pos.Y - CNPrivate.Silent.Fov.Offset.Y) * (CNPrivate.AimAssist.UseSmoothness and CNPrivate.AimAssist.Smoothness_Y or 1)
                if FrameSkip then
                    FrameSkip = false
                    InCrementX = ((Vec2Pos.X - CNPrivate.Silent.Fov.Offset.X) - Mouse.X) * CNPrivate.AimAssist.FrameSkip.Power
                    InCrementY = ((Vec2Pos.Y - CNPrivate.Silent.Fov.Offset.Y) - Mouse.Y) * CNPrivate.AimAssist.FrameSkip.Power
                end
                mousemoverel(InCrementX, InCrementY)
            elseif CNPrivate.AimAssist.Method == ("Camera") then
                local Vec3Pos = CFrame.new(Camera.CFrame.p, EndPosition)
                if FrameSkip then
                    FrameSkip = false
                    Camera.CFrame = Camera.CFrame:Lerp(Vec3Pos, CNPrivate.AimAssist.FrameSkip.Power, CNPrivate.AimAssist.Advanced.EasingStyle, CNPrivate.AimAssist.Advanced.EasingDirection)
                    return
                end
                Camera.CFrame = Camera.CFrame:Lerp(Vec3Pos, (CNPrivate.AimAssist.UseSmoothness and CNPrivate.AimAssist.Smoothness_X or 1), CNPrivate.AimAssist.Advanced.EasingStyle, CNPrivate.AimAssist.Advanced.EasingDirection)
            end
        end
    end
end

-- // Silent Features That Needs To Be Looping
Script.Functions.SilentMisc = function()
    if CNPrivate.Silent.PingPrediction.Enabled and CNPrivate.Silent.PredictMovement and CNPrivate.Silent.GunSettings.Methods.Prediction == false and game:GetService("Stats") and game:GetService("Stats"):FindFirstChild("Network") and game:GetService("Stats").Network:FindFirstChild("ServerStatsItem") and game:GetService("Stats").Network.ServerStatsItem:FindFirstChild("Data Ping") then
        local Ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        if CNPrivate.Silent.PingPrediction.AutoMatic == false then
            if Ping > 200 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P200_Inf
            elseif Ping > 190 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P190_200
            elseif Ping > 180 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P180_190
            elseif Ping > 170 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P170_180
            elseif Ping > 160 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P160_170
            elseif Ping > 150 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P150_160
            elseif Ping > 140 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P140_150
            elseif Ping > 130 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P130_140
            elseif Ping > 120 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P120_130
            elseif Ping > 110 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P110_120
            elseif Ping > 100 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P100_110
            elseif Ping > 90 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P90_100
            elseif Ping > 80 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P80_90
            elseif Ping > 70 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P70_80
            elseif Ping > 60 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P60_70
            elseif Ping > 50 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P50_60
            elseif Ping > 40 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P40_50
            elseif Ping > 30 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P30_40
            elseif Ping > 20 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P20_30
            elseif Ping > 10 then
                CNPrivate.Silent.Prediction = CNPrivate.Silent.PingPrediction.P10_20
            end
        end
    end
end

-- // Gets Silent Target And Velocity
Script.Functions.GetSilentTarget = function()
    local Target = Script.Functions.GetClosestPlayer(not CNPrivate.Silent.ForceLock)

    if CNPrivate.Silent.AntiAimViewer == false and Script.Functions.Alive(Target) and Script.Functions.SilentCheck(Target) then 
        SilentTarget = Target
        local GetPart = Script.Functions.GetClosestPartMethod(Target)
        if GetPart ~= nil then
            CNPrivate.Silent.Part = tostring(GetPart)
            Script.SavedValue.SilentPart = tostring(GetPart)
            if CNPrivate.Silent.ClosestPoint then
                ClosestPointCF = Script.Functions.GetClosestPointOnPart(GetPart)
            end
        else
            SilentTarget = nil
        end
    else
        SilentTarget = Target
    end
end

-- // Desync Main Function. Velocity Change
Script.Functions.Desync = function()
    if Desync and Script.Functions.Alive(Client) and Client.Character.Humanoid.health > CNPrivate.Desync.HealthDeActivation then
        if CNPrivate.Desync.Method == ("Freeze_Pos") and sethiddenproperty then
            FreezePos = not FreezePos
            sethiddenproperty(Client.Character.HumanoidRootPart, "NetworkIsSleeping", FreezePos)
        elseif CNPrivate.Desync.Method == ("Slow_Data") and setfflag then
            setfflag("S2PhysicsSenderRate", 3)
        else
            local SaveVelocity = Client.Character.HumanoidRootPart.AssemblyLinearVelocity
            local SaveRotVelocity = Client.Character.HumanoidRootPart.AssemblyAngularVelocity
            if CNPrivate.Desync.Method == ("Vel_StandBy") then
                Client.Character.HumanoidRootPart.Velocity = Vector3.new(1,1,1) * (2^16)
                Client.Character.HumanoidRootPart.RotVelocity = Vector3.new(1,1,1) * (2^16)
            elseif CNPrivate.Desync.Method == ("Vel_Multi") then
                Client.Character.HumanoidRootPart.Velocity = Client.Character.HumanoidRootPart.Velocity * CNPrivate.Desync.Power
            elseif CNPrivate.Desync.Method == ("Custom_Vel") then
                Client.Character.HumanoidRootPart.Velocity = Vector3.new(CNPrivate.Desync.Custom.Vel_X, CNPrivate.Desync.Custom.Vel_Y, CNPrivate.Desync.Custom.Vel_Z)
            elseif CNPrivate.Desync.Method == ("Vel_Under") then
                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, -CNPrivate.Desync.Power, 0)
            elseif CNPrivate.Desync.Method == ("Vel_Over") then
                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, CNPrivate.Desync.Power, 0)
            elseif CNPrivate.Desync.Method == ("Vel_Zero") then
                Client.Character.HumanoidRootPart.Velocity = Vector3.zero
            end
            
            if CNPrivate.Desync.Visualize.Enabled then
                local GetMag = (Camera.CoordinateFrame.p - (Client.Character.HumanoidRootPart.Position + (Client.Character.HumanoidRootPart.Velocity * 0.13))).Magnitude
                local GetPos, OnScreen = Camera:WorldToScreenPoint(Client.Character.HumanoidRootPart.Position + (Client.Character.HumanoidRootPart.Velocity * 0.13))
                if OnScreen then
                    Script.Drawing.DesyncCircle.Visible = true
                    Script.Drawing.DesyncCircle.Color = CNPrivate.Desync.Visualize.Color
                    Script.Drawing.DesyncCircle.Radius = (CNPrivate.Desync.Visualize.Radius * 10) / GetMag
                    Script.Drawing.DesyncCircle.Position = Vector2.new(GetPos.X, GetPos.Y)
                else
                    Script.Drawing.DesyncCircle.Visible = false
                end
            else
                Script.Drawing.DesyncCircle.Visible = false
            end
            
            RS.RenderStepped:Wait()
            
            Client.Character.HumanoidRootPart.AssemblyLinearVelocity = SaveVelocity
            Client.Character.HumanoidRootPart.AssemblyAngularVelocity = SaveRotVelocity
        end
    else
        if CNPrivate.Desync.Visualize.Enabled then
            Script.Drawing.DesyncCircle.Visible = false
        end
    end
end

-- // Cheater Detection Function. Not Giving Away

-- // Update Properties Of Circle
Script.Functions.UpdateFOV = function()
    local GetScreenPos = Script.Functions.GetFovPosition()
    Script.Drawing.AimAssistCircle.Visible = CNPrivate.AimAssist.Fov.Visible
    Script.Drawing.AimAssistCircle.Filled = CNPrivate.AimAssist.Fov.Filled
    Script.Drawing.AimAssistCircle.Color = CNPrivate.AimAssist.Fov.Color
    Script.Drawing.AimAssistCircle.Transparency = CNPrivate.AimAssist.Fov.Transparency
    if CNPrivate.Silent.Fov.Method == ("Screen") then
        Script.Drawing.AimAssistCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y) - CNPrivate.Silent.Fov.Offset
    else
        Script.Drawing.AimAssistCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y + GuiS:GetGuiInset().Y) - CNPrivate.Silent.Fov.Offset
    end

	Script.Drawing.AimAssistCircle.Radius = CNPrivate.AimAssist.Fov.Radius * 3
    
    Script.Drawing.SilentCircle.Visible = CNPrivate.Silent.Fov.Visible
    Script.Drawing.SilentCircle.Color = CNPrivate.Silent.Fov.Color
    Script.Drawing.SilentCircle.Filled = CNPrivate.Silent.Fov.Filled
    Script.Drawing.SilentCircle.Transparency = CNPrivate.Silent.Fov.Transparency
    if CNPrivate.Silent.Fov.StickyFov and Script.Functions.Alive(SilentTarget) and SilentTarget.Character:FindFirstChild(CNPrivate.Silent.Part) then
        local PartPos, OnScreen = Camera:WorldToViewportPoint(SilentTarget.Character[CNPrivate.Silent.Part].Position)
        if OnScreen then
            local Magnitude = ((Vector2.new(PartPos.X, PartPos.Y) - Vector2.new(GetScreenPos.X, GetScreenPos.Y + GuiS:GetGuiInset().Y)) - CNPrivate.Silent.Fov.Offset).Magnitude

            if (CNPrivate.Silent.ForceLock == false and Script.Drawing.SilentCircle.Radius + 4 > Magnitude) or CNPrivate.Silent.ForceLock == true then
                Script.Drawing.SilentCircle.Position = Vector2.new(PartPos.X, PartPos.Y) - CNPrivate.Silent.Fov.Offset
            else
                if CNPrivate.Silent.Fov.Method == ("Screen") then
                    Script.Drawing.SilentCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y) - CNPrivate.Silent.Fov.Offset
                else
                    Script.Drawing.SilentCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y + GuiS:GetGuiInset().Y) - CNPrivate.Silent.Fov.Offset
                end
            end
        else
            if CNPrivate.Silent.Fov.Method == ("Screen") then
                Script.Drawing.SilentCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y) - CNPrivate.Silent.Fov.Offset
            else
                Script.Drawing.SilentCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y + GuiS:GetGuiInset().Y) - CNPrivate.Silent.Fov.Offset
            end
        end
    else
        if CNPrivate.Silent.Fov.Method == ("Screen") then
            Script.Drawing.SilentCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y) - CNPrivate.Silent.Fov.Offset
        else
            Script.Drawing.SilentCircle.Position = Vector2.new(GetScreenPos.X, GetScreenPos.Y + GuiS:GetGuiInset().Y) - CNPrivate.Silent.Fov.Offset
        end
    end
	Script.Drawing.SilentCircle.Radius = SilentFovRadius.Value * 3
end

-- // Updates Esp Posistions
Script.Functions.UpdateEsp = function()
    for i, v in pairs(Script.EspPlayers) do
        if CNPrivate.Esp.Enabled and i.Character and i.Character:FindFirstChild("Humanoid") and i.Character:FindFirstChild("HumanoidRootPart") and i.Character:FindFirstChild("Head") then
            local Hum = i.Character.Humanoid
            local Hrp = i.Character.HumanoidRootPart
            
            local Vector, OnScreen = Camera:WorldToViewportPoint(i.Character.HumanoidRootPart.Position)
            local Size = (Camera:WorldToViewportPoint(Hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Hrp.Position + Vector3.new(0, 2.6, 0)).Y) / 2
            local BoxSize = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.9))
            local BoxPos = Vector2.new(math.floor(Vector.X - Size * 1.5 / 2), math.floor(Vector.Y - Size * 1.6 / 2))
            local BottomOffset = BoxSize.Y + BoxPos.Y + 1
            
            if OnScreen then
                if CNPrivate.Esp.Name.Enabled then
                    v.Name.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                    v.Name.Outline = CNPrivate.Esp.Name.OutLine
                    v.Name.Text = Hum.DisplayName
                    v.Name.Color = CNPrivate.Esp.Name.Color
                    v.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                    v.Name.Font = 0
                    v.Name.Size = CNPrivate.Esp.TextSize

                    v.Name.Visible = true
                else
                    v.Name.Visible = false
                end

                if CNPrivate.Esp.Distance.Enabled and Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") then
                    v.Distance.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BottomOffset)
                    v.Distance.Outline = CNPrivate.Esp.Distance.OutLine
                    v.Distance.Text = "[" .. math.floor((Hrp.Position - Client.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    v.Distance.Color = CNPrivate.Esp.Distance.Color
                    v.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)

                    v.Distance.Font = 0
                    v.Distance.Size = CNPrivate.Esp.TextSize

                    v.Distance.Visible = true
                else
                    v.Distance.Visible = false
                end

                if CNPrivate.Esp.Tool.Enabled then
                    if CNPrivate.Esp.Distance.Enabled then
                        v.Tool.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BottomOffset + 13)
                    else
                        v.Tool.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BottomOffset)
                    end
                    v.Tool.Outline = CNPrivate.Esp.Tool.OutLine
                    if i.Character:FindFirstChildWhichIsA("Tool") then
                        if i.Character:FindFirstChild("GunScript", true) ~= nil or i.Character:FindFirstChild("FlameThrowerScript", true) ~= nil or i.Character:FindFirstChild("RPGScript", true) ~= nil then
                            v.Tool.Text = i.Character:FindFirstChildWhichIsA("Tool").Name
                        else
                            v.Tool.Text = "[" .. i.Character:FindFirstChildWhichIsA("Tool").Name .. "]"
                        end
                    else
                        v.Tool.Text = "[None]"
                    end
                    v.Tool.Color = CNPrivate.Esp.Tool.Color
                    v.Tool.OutlineColor = Color3.fromRGB(0, 0, 0)
                    
                    v.Tool.Font = 0
                    v.Tool.Size = CNPrivate.Esp.TextSize

                    v.Tool.Visible = true
                else
                    v.Tool.Visible = false
                end

                if CNPrivate.Esp.Box.Enabled then
                    v.BoxOutline.Size = BoxSize
                    v.BoxOutline.Position = BoxPos
                    v.BoxOutline.Visible = CNPrivate.Esp.Box.OutLine
                    v.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
                    
                    v.Box.Size = BoxSize
                    v.Box.Position = BoxPos
                    if CNPrivate.Esp.TargetColor.Enabled and SilentTarget ~= nil and i == SilentTarget then
                        v.Box.Color = CNPrivate.Esp.TargetColor.Color
                    elseif CNPrivate.Esp.CrewColor.Enabled and Script.Functions.FindCrew(i) and i.DataFolder.Information:FindFirstChild("Crew").Value == Client.DataFolder.Information:FindFirstChild("Crew").Value then
                        v.Box.Color = CNPrivate.Esp.CrewColor.Color
                    else
                        v.Box.Color = CNPrivate.Esp.Box.Color
                    end
                    v.Box.Visible = true
                else
                    v.BoxOutline.Visible = false
                    v.Box.Visible = false
                end

                if CNPrivate.Esp.HealthBar.Enabled then
                    if CNPrivate.Esp.HealthBar.HealthColor then
                        local Health = i.Character.Humanoid.Health / i.Character.Humanoid.MaxHealth
                        v.HealthBar.Color = Color3.fromHSV(Health * 0.3, 1, 1) 
                    else
                        v.HealthBar.Color = CNPrivate.Esp.HealthBar.Color
                    end

                    v.HealthBar.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                    v.HealthBar.To = Vector2.new(v.HealthBar.From.X, v.HealthBar.From.Y - (Hum.Health / Hum.MaxHealth) * BoxSize.Y)
                    v.HealthBar.Visible = true

                    v.HealthBarOutline.From = Vector2.new(v.HealthBar.From.X, BoxPos.Y + BoxSize.Y + 1)
                    v.HealthBarOutline.To = Vector2.new(v.HealthBar.From.X, (v.HealthBar.From.Y - 1 * BoxSize.Y) - 1)
                    v.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
                    v.HealthBarOutline.Visible = CNPrivate.Esp.HealthBar.OutLine
                else
                    v.HealthBarOutline.Visible = false
                    v.HealthBar.Visible = false
                end

                if CNPrivate.Esp.HealthText.Enabled then
                    local Offset = 22
                    if CNPrivate.Esp.ArmorBar.Enabled == false then
                        Offset = Offset - 7
                    end
                    if CNPrivate.Esp.HealthBar.Enabled == false then
                        Offset = Offset - 7
                    end

                    if CNPrivate.Esp.HealthText.HealthColor then
                        local Health = i.Character.Humanoid.Health / i.Character.Humanoid.MaxHealth
                        v.HealthText.Color = Color3.fromHSV(Health * 0.3, 1, 1) 
                    else
                        v.HealthText.Color = CNPrivate.Esp.HealthText.Color
                    end
                    
                    v.HealthText.Text = tostring(math.floor((Hum.Health / Hum.MaxHealth) * 100 + 0.5))
                    v.HealthText.Position = Vector2.new((BoxPos.X - Offset), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) - 1)
                    v.HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)
                    v.HealthText.Outline = CNPrivate.Esp.HealthText.OutLine

                    v.HealthText.Font = 0
                    v.HealthText.Size = CNPrivate.Esp.TextSize

                    v.HealthText.Visible = true
                else
                    v.HealthText.Visible = false
                end

                if CNPrivate.Esp.Flags.Enabled then
                    local Offset = 10
                    if CNPrivate.Esp.ArmorBar.Enabled == false then
                        Offset = Offset - 7
                    end
                    if CNPrivate.Esp.HealthBar.Enabled == false then
                        Offset = Offset - 7
                    end
                    if i.Character.HumanoidRootPart.Velocity.Magnitude > 120 and CNPrivate.Esp.Flags.DesyncState then
                        v.Flag.Text = "Desyncing"
                    elseif i.Character.HumanoidRootPart.Velocity.Y > 2 and CNPrivate.Esp.Flags.WalkingState then
                        v.Flag.Text = "Jumping"
                    elseif i.Character.HumanoidRootPart.Velocity.Y < -2 and CNPrivate.Esp.Flags.WalkingState then
                        v.Flag.Text = "Falling"
                    elseif i.Character.HumanoidRootPart.Velocity.Magnitude > 2 and CNPrivate.Esp.Flags.WalkingState then
                        v.Flag.Text = "Walking"
                    elseif i.Character.HumanoidRootPart.Velocity.Magnitude < 1 and CNPrivate.Esp.Flags.WalkingState then
                        v.Flag.Text = "Standing"
                    end
                    v.Flag.Position = Vector2.new((BoxPos.X - Offset) - (string.len(v.Flag.Text) * 3), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) + 22)
                    v.Flag.Color = CNPrivate.Esp.Flags.Color
                    v.Flag.OutlineColor = Color3.fromRGB(0, 0, 0)
                    v.Flag.Outline = CNPrivate.Esp.Flags.OutLine

                    v.Flag.Font = 0
                    v.Flag.Size = CNPrivate.Esp.TextSize

                    v.Flag.Visible = true
                else
                    v.Flag.Visible = false
                end

                if CNPrivate.Esp.Tracer.Enabled then
                    if CNPrivate.Esp.Tracer.Method == ("Screen") then
                        v.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    else
                        v.Tracer.From = Vector2.new(Mouse.X, Mouse.Y + GuiS:GetGuiInset().Y)
                    end
                    v.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                    v.Tracer.Thickness = CNPrivate.Esp.Tracer.Thickness
                    v.Tracer.Color = CNPrivate.Esp.Tracer.Color
                    v.Tracer.Visible = true
                else
                    v.Tracer.Visible = false
                end

                if i.Character:FindFirstChild("BodyEffects") and i.Character:FindFirstChild("BodyEffects"):FindFirstChild("Armor") then
                    if CNPrivate.Esp.ArmorBar.Enabled then
                        if CNPrivate.Esp.HealthBar.Enabled then
                            v.ArmorBar.From = Vector2.new((BoxPos.X - 9), BoxPos.Y + BoxSize.Y)
                        else
                            v.ArmorBar.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                        end
                        v.ArmorBar.To = Vector2.new(v.ArmorBar.From.X, v.ArmorBar.From.Y - (i.Character.BodyEffects.Armor.Value / 200) * BoxSize.Y)
                        v.ArmorBar.Color = CNPrivate.Esp.ArmorBar.Color
                        v.ArmorBar.Visible = true

                        v.ArmorBarOutline.From = Vector2.new(v.ArmorBar.From.X, BoxPos.Y + BoxSize.Y + 1)
                        v.ArmorBarOutline.To = Vector2.new(v.ArmorBar.From.X, (v.ArmorBar.From.Y - 1 * BoxSize.Y) - 1)
                        v.ArmorBarOutline.Color = Color3.fromRGB(0, 0, 0)
                        v.ArmorBarOutline.Visible = CNPrivate.Esp.ArmorBar.OutLine
                    else
                        v.ArmorBarOutline.Visible = false
                        v.ArmorBar.Visible = false
                    end
                    if CNPrivate.Esp.ArmorText.Enabled then
                        local Offset = 22
                        if CNPrivate.Esp.ArmorBar.Enabled == false then
                            Offset = Offset - 7
                        end
                        if CNPrivate.Esp.HealthBar.Enabled == false then
                            Offset = Offset - 7
                        end
                        v.ArmorText.Text = tostring(math.floor((i.Character.BodyEffects.Armor.Value / 2) + 0.5))
                        if CNPrivate.Esp.HealthText.Enabled then
                            v.ArmorText.Position = Vector2.new((BoxPos.X - Offset), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) + 11)
                        else
                            v.ArmorText.Position = Vector2.new((BoxPos.X - Offset), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) - 1)
                        end
                        v.ArmorText.Color = CNPrivate.Esp.ArmorText.Color
                        v.ArmorText.OutlineColor = Color3.fromRGB(0, 0, 0)
                        v.ArmorText.Outline = CNPrivate.Esp.ArmorText.OutLine

                        v.ArmorText.Font = 0
                        v.ArmorText.Size = CNPrivate.Esp.TextSize

                        v.ArmorText.Visible = true
                    else
                        v.ArmorText.Visible = false
                    end
                else
                    v.ArmorBarOutline.Visible = false
                    v.ArmorBar.Visible = false
                    v.ArmorText.Visible = false
                end 
            else
                v.Name.Visible = false
                v.BoxOutline.Visible = false
                v.Box.Visible = false
                v.HealthBarOutline.Visible = false
                v.HealthBar.Visible = false
                v.HealthText.Visible = false
                v.ArmorBarOutline.Visible = false
                v.ArmorBar.Visible = false
                v.ArmorText.Visible = false
                v.Distance.Visible = false
                v.Tool.Visible = false
                v.Flag.Visible = false
                v.Tracer.Visible = false
            end
        else
            v.Name.Visible = false
            v.BoxOutline.Visible = false
            v.Box.Visible = false
            v.HealthBarOutline.Visible = false
            v.HealthBar.Visible = false
            v.HealthText.Visible = false
            v.ArmorBarOutline.Visible = false
            v.ArmorBar.Visible = false
            v.ArmorText.Visible = false
            v.Distance.Visible = false
            v.Tool.Visible = false
            v.Flag.Visible = false
            v.Tracer.Visible = false
        end
    end
end

-- // Recreates An Table
Script.Functions.GetTable = function(Table)
    if type(Table) == ("table") then
        local Writer = {}
        Writer.__index = Writer
    
        Writer.New = function()
            local self = setmetatable({}, Writer)
            self.Indent = 0
            self.Text = ""
            return self
        end
    
        Writer.WriteIndentation = function(self)
            for i = 1, self.Indent do
                self.Text = self.Text .. "\t"
            end
        end
    
        Writer.Write = function(self, Text)
            self.Text = self.Text .. Text
        end
    
        Writer.WriteLine = function(self, Text)
            self.Text = self.Text .. Text .. "\n"
        end
    
        Writer.WriteIndent = function(self, Text)
            self:WriteIndentation()
            self:Write(Text)
        end
    
        Writer.IncIndent = function(self)
            self.Indent = self.Indent + 1
        end
    
        Writer.Unindent = function(self)
            self.Indent = self.Indent - 1
        end
    
        Writer.ToString = function(self)
            return self.Text
        end
    
        Writer.Clear = function(self)
            self.Text = ""
            self.Indent = 0
        end
    
        local TableDump = {}
        TableDump.__index = TableDump
    
        TableDump.New = function(Table)
            local self = setmetatable({}, TableDump)
            self.Writer = Writer.New()
            self.Ot = Table
            self.Memory = {}
            self.VisitedTables = {}
            return self
        end
    
        TableDump.CacheGlobalMemory = function(self)
            local CurrentTrack = {"_G"}
            local Functions = {}
    
            Functions.InternalCount = function(Table)
                local Current = 0
                for _, __ in pairs(Table) do
                    Current = Current + 1
                end
                return Current
            end
    
            Functions.CreateNamespace = function()
                local NameSpace = ""
                for Index, Value in pairs(CurrentTrack) do
                    if Value ~= ("_G") and Value ~= ("package") then
                        NameSpace = NameSpace .. Value .. "."
                    end
                end
                return NameSpace
            end
    
            Functions.InternalCache = function(Table)
                local Len = Functions.InternalCount(Table)
                local Current = 0
                for Index, value in pairs(Table) do
                    Current = Current + 1
                    if type(value) == ("function") or type(value) == ("table") then
                        if type(value) == ("table") and self.VisitedTables[value] == nil then
                            self.VisitedTables[value] = Index
                            CurrentTrack[#CurrentTrack + 1] = Index
                            Functions.InternalCache(value)
                        end
                        self.Memory[value] = Functions.CreateNamespace() .. Index
                    end
                    if Current == Len then
                        table.remove(CurrentTrack, #CurrentTrack)
                    end
                end
            end
    
            Functions.InternalCache(_G)
        end
    
        TableDump.Resolve = function(self)
            self:CacheGlobalMemory()
            local Functions = {}

            Functions.InternalResolveSpecial = function(Value)
                if Value == _G then
                    return "_G"
                end
                if self.Memory[Value] then
                    return self.Memory[Value]
                end
                if type(Value) == ("table") then
                    if self.VisitedTables[Value] ~= nil then
                        if self.VisitedTables[Value] == true then
                            return "{...}"
                        end
                        return self.VisitedTables
                    end
                    Functions.InternalResolve(Value)
                    return ""
                elseif type(Value) == ("function") then
                    return '"Function Couldnt Be Added: ' .. tostring(Value) .. '"'
                end
                return tostring(Value)
            end
    
            Functions.InternalResolveValue = function(Value)
                if type(Value) == ("function") or type(Value) == ("table") then
                    return Functions.InternalResolveSpecial(Value)
                elseif type(Value) == ("string") then
                    return '"' .. tostring(Value) .. '"'
                elseif type(Value) == ("number") and Value == math.huge then
                    return "math.huge"
                elseif type(Value) == ("number") and Value == math.pi then
                    return "math.pi"
                elseif typeof(Value) == ("Color3") then
                    return "Color3.new(" .. tostring(Value) .. ")"
                elseif typeof(Value) == ("Vector2") then
                    return "Vector2.new(" .. tostring(Value) .. ")"
                elseif typeof(Value) == ("Vector3") then
                    return "Vector3.new(" .. tostring(Value) .. ")"
                else
                    return tostring(Value)
                end
            end
    
            Functions.InternalCount = function(Table)
                local Current = 0
                for _, __ in pairs(Table) do
                    Current = Current + 1
                end
                return Current
            end
    
            Functions.InternalResolve = function(Table, Index)
                local Len = Functions.InternalCount(Table)
                local Current = 0

                if Len ~= 0 then
                    self.Writer:WriteLine("{")
                else
                    self.Writer:Write("{")
                end

                self.Writer:IncIndent()
                self.VisitedTables[Table] = true

                if Index then
                    self.VisitedTables[Table] = Index
                end

                for Index, value in pairs(Table) do
                    Current = Current + 1
                    if type(Index) == ("string") then
                        if string.find(Index, " ") then
                            self.Writer:WriteIndent('["' .. Index .. '"] = ')
                        else
                            self.Writer:WriteIndent(Index .. " = ")
                        end

                        self.Writer:Write(Functions.InternalResolveValue(value))
                    elseif type(Index) == ("number") then
                        self.Writer:WriteIndent("[" .. tostring(Index) .. "] = ")
                        self.Writer:Write(Functions.InternalResolveValue(value))
                    elseif type(Index) == ("table") then
                        self.Writer:WriteIndent("[")
                        Functions.InternalResolve(Index)
                        self.Writer:Write("] = ")
                        self.Writer:Write(Functions.InternalResolveValue(value))
                    elseif type(Index) == ("function") then
                        self.Writer:WriteIndent(Functions.InternalResolveValue(Index) .. " = ")
                        self.Writer:Write(Functions.InternalResolveValue(value))
                    else
                        self.Writer:WriteIndent(Functions.InternalResolveValue(Index) .. " = ")
                        self.Writer:Write(Functions.InternalResolveValue(value))
                    end
                    if Current == Len then
                        self.Writer:WriteLine("")
                    else
                        self.Writer:WriteLine(",")
                    end
                end

                self.Writer:Unindent()
                if Len ~= 0 then
                    self.Writer:WriteIndent("}")
                else
                    self.Writer:Write("}")
                end
            end
            Functions.InternalResolve(self.Ot)
        end
    
        TableDump.ToString = function(self)
            self:Resolve()
            return self.Writer:ToString()
        end
    
        return "return " .. TableDump.New(Table):ToString()
    else
        return "Error: Table Not Found"
    end
end

-- // Chat Change Check
Client.Chatted:Connect(function(Msg)
    if Msg == CNPrivate.ChatCommands.CrashMode then
        if CNPrivate.ChatCommands.CrashMethod == ("Freeze") then
            while true do end
        elseif CNPrivate.ChatCommands.CrashMethod == ("Shutdown") then
            game:Shutdown()
        end
    elseif Msg == CNPrivate.ChatCommands.RejoinServer then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Client)
    elseif Msg == CNPrivate.ChatCommands.RandomServer then
        game:GetService("TeleportService"):Teleport(game.PlaceId, Client) 
    end
    local Splitted = string.split(Msg, " ")
    if Splitted[1] and Splitted[2] and CNPrivate.ChatCommands.Enabled then
        if Splitted[1] == CNPrivate.ChatCommands.LoadConfig then
            if isfolder("CNPrivate/" .. game.PlaceId) and isfolder("CNPrivate/" .. game.PlaceId .. "/Configs") and isfile("CNPrivate/" .. game.PlaceId .. "/Configs/" .. Splitted[2] .. ".lua") then
                local Table = loadfile("CNPrivate/" .. game.PlaceId .. "/Configs/" .. Splitted[2] .. ".lua")()
                CNPrivate = Table
                Script.Functions.CreateNotification("SuccesFully Loaded File (Name: " .. Splitted[2] .. ")", Color3.fromRGB(206, 67, 67))
            else
                Script.Functions.CreateNotification("Error: Couldnt Find File (Name: " .. Splitted[2] .. ")", Color3.fromRGB(206, 67, 67))
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.SaveConfig then
            if not isfolder("CNPrivate") then
                makefolder("CNPrivate")
            end
            if not isfolder("CNPrivate/" .. game.PlaceId) then
                makefolder("CNPrivate/" .. game.PlaceId)
            end
            if not isfolder("CNPrivate/" .. game.PlaceId .. "/Configs") then
                makefolder("CNPrivate/" .. game.PlaceId .. "/Configs")
            end
            if not isfile("CNPrivate/" .. game.PlaceId .. "/Configs/" .. Splitted[2] .. ".lua") then
                writefile("CNPrivate/" .. game.PlaceId .. "/Configs/" .. Splitted[2] .. ".lua", Script.Functions.GetTable(CNPrivate))
                Script.Functions.CreateNotification("SuccesFully Created File (Name: " .. Splitted[2] .. ")", Color3.fromRGB(206, 67, 67))
            else
                Script.Functions.CreateNotification("Error: File Already Exists (Name: " .. Splitted[2] .. ")", Color3.fromRGB(206, 67, 67))
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_Prediction then
            CNPrivate.Silent.Prediction = Splitted[2]
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_Fov_Size then
            SilentFovRadius.Value = Splitted[2]
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_Fov_Show then
            if Splitted[2] == ("true") then
                CNPrivate.Silent.Fov.Visible = true
            else
                CNPrivate.Silent.Fov.Visible = false
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_Enabled then
            if Splitted[2] == ("true") then
                CNPrivate.Silent.Enabled = true
            else
                CNPrivate.Silent.Enabled = false 
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_HitChance then
            CNPrivate.Silent.HitChance = Splitted[2]
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_LegitMode then
            if Splitted[2] == ("true") then
                CNPrivate.Silent.LegitMode = true
            else
                CNPrivate.Silent.LegitMode = false
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.Silent_BlatantMode then
            if Splitted[2] == ("true") then
                CNPrivate.Silent.BlatantMode = true
            else
                CNPrivate.Silent.BlatantMode = false
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_Prediction then
            CNPrivate.AimAssist.Prediction = Splitted[2]
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_Fov_Size then
            CNPrivate.AimAssist.Fov.Radius = Splitted[2]
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_Fov_Show then
            if Splitted[2] == ("true") then
                CNPrivate.AimAssist.Fov.Visible = true
            else
                CNPrivate.AimAssist.Fov.Visible = false
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_Enabled then
            if Splitted[2] == ("true") then
                CNPrivate.AimAssist.Enabled = true
            else
                CNPrivate.AimAssist.Enabled = false
            end
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_SmoothX then
            CNPrivate.AimAssist.Smoothness_X = Splitted[2]
            Script.SavedValue.AimAssistSmoothX = CNPrivate.AimAssist.Smoothness_X
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_SmoothY then
            CNPrivate.AimAssist.Smoothness_Y = Splitted[2]
            Script.SavedValue.AimAssistSmoothY = CNPrivate.AimAssist.Smoothness_Y
        elseif Splitted[1] == CNPrivate.ChatCommands.AimAssist_Shake then
            CNPrivate.AimAssist.Shake.Shake_X = Splitted[2]
            CNPrivate.AimAssist.Shake.Shake_Y = Splitted[2]
            CNPrivate.AimAssist.Shake.Shake_Z = Splitted[2]
            Script.SavedValue.ShakeX = CNPrivate.AimAssist.Shake.Shake_X
            Script.SavedValue.ShakeY = CNPrivate.AimAssist.Shake.Shake_Y
            Script.SavedValue.ShakeZ = CNPrivate.AimAssist.Shake.Shake_Z
        end
    end
end)

-- // KeyDown Mouse Check
Uis.InputBegan:connect(function(input, Gp)
    if not Gp then
        -- // Not ElseIf So You Can Use Multiple Same Keybinds
        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.InventorySorter.KeyBind)] and CNPrivate.InventorySorter.Enabled and Script.Functions.Alive(Client) then
            local GunOrder = CNPrivate.InventorySorter.Slots
            local BackPack = Client.Backpack
            local CurrentTime = tick()
            local GunLoop = 10 - #GunOrder
            local TimeSinceLastKeybind = CurrentTime - keybindTime

            if TimeSinceLastKeybind >= 5 then
                keybindTime = CurrentTime
                local GunFolder = Instance.new("Folder")
                GunFolder.Name = "GunFolder"
                GunFolder.Parent = game.Workspace
                local GunFolderID = game.Workspace.GunFolder

                for _, v in pairs(BackPack:GetChildren()) do
                    if v:IsA("Tool") then
                        v.Parent = game.Workspace.GunFolder
                    end
                end

                for _, v in pairs(GunOrder) do
                    local Gun = GunFolderID:FindFirstChild(v)
                    if Gun then
                        Gun.Parent = BackPack
                        wait(0.05)
                    else
                        GunLoop = GunLoop + 1
                    end
                end

                if CNPrivate.InventorySorter.UseFood then
                    for _, v in pairs(GunFolderID:GetChildren()) do
                        if v:FindFirstChild("Drink") or v:FindFirstChild("Eat") then
                            v.Parent = BackPack
                            GunLoop = GunLoop -1
                        end
                    end
                end

                if GunLoop > 0 then
                    for i = 1, GunLoop do
                        local InvisTool = Instance.new("Tool")
                        InvisTool.Name = ""
                        InvisTool.ToolTip = "PlaceHolder"
                        InvisTool.GripPos = Vector3.new(0, 1, 0)
                        InvisTool.RequiresHandle = false
                        InvisTool.Parent = BackPack
                    end
                end

                for _, v in pairs(GunFolderID:GetChildren()) do
                    if v:IsA("Tool") then
                        v.Parent = BackPack
                    end
                end

                for _, v in pairs(BackPack:GetChildren()) do
                    if v.Name == "" then
                        v:Destroy()
                    end
                end

                GunFolder:Destroy()
            end
        end
        
        if CNPrivate.FakeSpike.Enabled and input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.FakeSpike.KeyBind)] then
            if CNPrivate.FakeSpike.ToggleMode then
                FakeSpike = not FakeSpike
                if FakeSpike == true then
                    settings().Network.IncomingReplicationLag = (CNPrivate.FakeSpike.Power * 0.001)
                    if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.FakeSpike then
                        Script.Functions.CreateNotification("FakeSpike: " .. tostring(FakeSpike), Color3.fromRGB(206, 67, 67))
                    end
                else
                    settings().Network.IncomingReplicationLag = 0
                    if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.FakeSpike then
                        Script.Functions.CreateNotification("FakeSpike: " .. tostring(FakeSpike), Color3.fromRGB(206, 67, 67))
                    end
                end
            else
                settings().Network.IncomingReplicationLag = (CNPrivate.FakeSpike.Power * 0.001)
                if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.FakeSpike then
                    Script.Functions.CreateNotification("FakeSpike: " .. tostring(FakeSpike), Color3.fromRGB(206, 67, 67))
                end
                task.wait(CNPrivate.FakeSpike.Delay)
                settings().Network.IncomingReplicationLag = 0
                if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.FakeSpike then
                    Script.Functions.CreateNotification("FakeSpike: " .. tostring(FakeSpike), Color3.fromRGB(206, 67, 67))
                end
            end
        end

        if CNPrivate.F9Cleaner.Enabled and input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.F9Cleaner.KeyBind)] then
            Script.Functions.ClearConsole()
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.AimAssist.FrameSkip.KeyBind)] and Script.Functions.Alive(AimTarget) and CNPrivate.AimAssist.FrameSkip.Enabled then
            FrameSkip = true
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Silent.ForceKeyBind)] and CNPrivate.Silent.ForceLock_AimAssistTarget == false and CNPrivate.Silent.ForceLock then
            if ForceLock == nil then
                ForceLock = Script.Functions.GetClosestPlayer(true)
        		if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Misc and ForceLock ~= nil then
        		    Script.Functions.CreateNotification("Locked: " .. tostring(ForceLock), Color3.fromRGB(206, 67, 67))
        		end
            else
                if ForceLock ~= nil then
                    ForceLock = nil
            		if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Misc then
            		    Script.Functions.CreateNotification("Unlocked", Color3.fromRGB(206, 67, 67))
            		end
        		end
            end
        end

        if input.KeyCode == Enum.KeyCode.I and CNPrivate.Macro.Speed_MacroAbuse and Script.Functions.Alive(Client) then
            if Client.Character:FindFirstChild("GunScript", true) ~= nil or Client.Character:FindFirstChild("FlameThrowerScript", true) ~= nil or Client.Character:FindFirstChild("RPGScript", true) ~= nil then
                local Controller = require(Client:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras().activeCameraController
                Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance - 5)
            end
        end

        if input.KeyCode == Enum.KeyCode.O and CNPrivate.Macro.Speed_MacroAbuse and Script.Functions.Alive(Client) then
            if Client.Character:FindFirstChild("GunScript", true) ~= nil or Client.Character:FindFirstChild("FlameThrowerScript", true) ~= nil or Client.Character:FindFirstChild("RPGScript", true) ~= nil then
                local Controller = require(Client:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras().activeCameraController
                Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance + 5)
            end
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.AimAssist.KeyBind)] and CNPrivate.AimAssist.Enabled then
            if AimTarget == nil then
                CurrentVelocity2 = Vector3.zero
                AimTarget = Script.Functions.GetClosestPlayer2()
                if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.AimAssist and AimTarget ~= nil then
                    Script.Functions.CreateNotification("Locked: " .. tostring(AimTarget), Color3.fromRGB(206, 67, 67))
                end
                if AimTarget and AimTarget.Character then
                    PositionData2 = {Target = tostring(AimTarget), Position = AimTarget.Character.HumanoidRootPart.Position, Time = tick()}
                end
            else
                if AimTarget ~= nil then
                    AimTarget = nil
                    CurrentVelocity2 = Vector3.zero
                    if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.AimAssist then
                        Script.Functions.CreateNotification("Unlocked", Color3.fromRGB(206, 67, 67))
                    end
                end
            end
        end

        if CNPrivate.Silent.TriggerBot and CNPrivate.Silent.TriggerBot_HotKey == false and input.UserInputType == Enum.UserInputType[CNPrivate.Silent.TriggerBotMouseKey] then
            TriggerBot = not TriggerBot
        end

        if CNPrivate.Silent.TriggerBot and CNPrivate.Silent.TriggerBot_HotKey and input.KeyCode == Enum.KeyCode[CNPrivate.Silent.TriggerBotKey] then
            TriggerBot = not TriggerBot
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Silent.KeyBind)] and CNPrivate.Silent.UseSilentKeyBind then
            CNPrivate.Silent.Enabled = not CNPrivate.Silent.Enabled
            if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Silent then
                Script.Functions.CreateNotification("Silent Aim: " .. tostring(CNPrivate.Silent.Enabled), Color3.fromRGB(206, 67, 67))
            end
            CurrentVelocity = Vector3.zero
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Lay_KeyBind)] and CNPrivate.Macro.Lay_Emote and game.PlaceId ~= 9825515356 then
            local Args = {
                [1] = "AnimationPack",
                [2] = "Lay"
            }
            game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(Args))
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Greet_Keybind)] and CNPrivate.Macro.Greet_Emote and game.PlaceId ~= 9825515356 then
            local Args = {
                [1] = "AnimationPack",
                [2] = "Greet"
            }
            game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(Args))
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Esp.EspKey)] and CNPrivate.Esp.UseEspKeyBind then
    		CNPrivate.Esp.Enabled = not CNPrivate.Esp.Enabled
    		if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Esp then
    		    Script.Functions.CreateNotification("Esp: " .. tostring(CNPrivate.Esp.Enabled), Color3.fromRGB(206, 67, 67))
    		end
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Desync.DesyncKey)] and CNPrivate.Desync.Enabled and CNPrivate.Desync.UseDesyncKey then
    		Desync = not Desync
    		if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Esp then
    		    Script.Functions.CreateNotification("Desync: " .. tostring(Desync), Color3.fromRGB(206, 67, 67))
    		end
            if CNPrivate.Desync.Method == ("Slow_Data") then
                wait()
                setfflag("S2PhysicsSenderRate", 15)
            end
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Noclip_KeyBind)] and CNPrivate.Macro.Noclip_Macro then
            NoclipMacro = not NoclipMacro
            if not NoclipMacro then return end
            repeat task.wait()
                for _, v in pairs(Client.Backpack:GetChildren()) do
                    if Script.Functions.Alive(Client) then
                        if v.Name == ("[TacticalShotgun]") then
                            v.Parent = Client.Character
                            task.wait(0.1)
                            if v then
                                v.Parent = Client.Backpack
                            end
                        elseif v.Name == ("[Shotgun]") then
                            v.Parent = Client.Character
                            task.wait(0.1)
                            if v then
                                v.Parent = Client.Backpack
                            end
                        end
                    end
                end
            until NoclipMacro == false
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Speed_KeyBind)] and CNPrivate.Macro.Speed_Enabled then
            Macro = not Macro
            repeat RS.Heartbeat:Wait()
            if CNPrivate.Macro.Speed_Method == ("FirstPerson") then
                local Controller = require(Client:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras().activeCameraController
                Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance - 1)
                for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                    RS.Heartbeat:Wait()
                end
                Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance + 1)
            elseif CNPrivate.Macro.Speed_Method == ("Shift") then
                keypress(0xA0)
                for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                    RS.Heartbeat:Wait()
                end
                keypress(0xA0)
                for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                    RS.Heartbeat:Wait()
                end
                keyrelease(0xA0)
                for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                    RS.Heartbeat:Wait()
                end
                keyrelease(0xA0)
            elseif CNPrivate.Macro.Speed_Method == ("ThirdPerson") then
                if CNPrivate.Macro.Speed_ThirdPersonV2 then
                    local Controller = require(Client:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras().activeCameraController
                    Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance - 8)
                    for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                        RS.Heartbeat:Wait()
                    end
                    Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance + 5)
                else
                    keypress(0x49)
                    for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                        RS.Heartbeat:Wait()
                    end
                    keypress(0x4F)
                    for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                        RS.Heartbeat:Wait()
                    end
                    keyrelease(0x49)
                    for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                        RS.Heartbeat:Wait()
                    end
                    keyrelease(0x4F)
                end
            end
            for i = 1, math.ceil(CNPrivate.Macro.Speed_Delay) do
                RS.Heartbeat:Wait()
            end
            until Macro == false
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.PanicMode.KeyBind)] and CNPrivate.PanicMode.Enabled then
            PanicMode = not PanicMode
            if PanicMode then
                if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.PanicMode then
                    Script.Functions.CreateNotification("PanicMode: " .. tostring(PanicMode), Color3.fromRGB(206, 67, 67))
                end
                if CNPrivate.Options.NotificationMode == true then
                    Script.PanicModeSaves.CurrentNotificationState = CNPrivate.Options.NotificationMode
                    CNPrivate.Options.NotificationMode = not CNPrivate.Options.NotificationMode
                end
                if CNPrivate.Silent.Enabled == true then
                    Script.PanicModeSaves.CurrentSilentState = CNPrivate.Silent.Enabled
                    CNPrivate.Silent.Enabled = not CNPrivate.Silent.Enabled
                end
                if CNPrivate.AimAssist.Enabled == true then
                    Script.PanicModeSaves.CurrentAimAssistState = CNPrivate.AimAssist.Enabled
                    CNPrivate.AimAssist.Enabled = not CNPrivate.AimAssist.Enabled
                end
                if CNPrivate.AimAssist.Fov.Visible == true then
                    Script.PanicModeSaves.CurrentAimAssistFov = CNPrivate.AimAssist.Fov.Visible
                    CNPrivate.AimAssist.Fov.Visible = not CNPrivate.AimAssist.Fov.Visible
                end
                if CNPrivate.Silent.Fov.Visible == true then
                    Script.PanicModeSaves.CurrentSilentFov = CNPrivate.Silent.Fov.Visible
                    CNPrivate.Silent.Fov.Visible = not CNPrivate.Silent.Fov.Visible
                end
            else
                if Script.PanicModeSaves.CurrentNotificationState then
                    CNPrivate.Options.NotificationMode = not CNPrivate.Options.NotificationMode
                end
                if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.PanicMode then
                    Script.Functions.CreateNotification("PanicMode: " .. tostring(PanicMode), Color3.fromRGB(206, 67, 67))
                end
                if Script.PanicModeSaves.CurrentSilentState then
                    CNPrivate.Silent.Enabled = Script.PanicModeSaves.CurrentSilentState
                end
                if Script.PanicModeSaves.CurrentAimAssistState then
                    CNPrivate.AimAssist.Enabled = Script.PanicModeSaves.CurrentAimAssistState
                end
                if Script.PanicModeSaves.CurrentAimAssistFov then
                    CNPrivate.AimAssist.Fov.Visible = Script.PanicModeSaves.CurrentAimAssistFov
                end
                if Script.PanicModeSaves.CurrentSilentFov then
                    CNPrivate.Silent.Fov.Visible = Script.PanicModeSaves.CurrentSilentFov
                end
            end
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Rotation_KeyBind)] and CNPrivate.Macro.RotationMode then
            if CNPrivate.AimAssist.Enabled then
                CNPrivate.AimAssist.Enabled = false
            end
            for i = 1, math.floor(CNPrivate.Macro.Degrees / CNPrivate.Macro.RotationSpeed) do
                Camera.CoordinateFrame = Camera.CoordinateFrame * CFrame.Angles(0, math.rad(CNPrivate.Macro.RotationSpeed), 0)
                RS.Heartbeat:Wait()
            end
            if CNPrivate.AimAssist.Enabled then
                CNPrivate.AimAssist.Enabled = true
            end
        end
    end
end)

-- // KeyUp Mouse Check
Uis.InputEnded:connect(function(input, Gp)
    if not Gp then
        if CNPrivate.Silent.TriggerBot and TriggerBot and CNPrivate.Silent.TriggerBot_HotKey == false and CNPrivate.Silent.TriggerBot_HoldMode and input.UserInputType == Enum.UserInputType[CNPrivate.Silent.TriggerBotMouseKey] then
            TriggerBot = false
        end

        if CNPrivate.Silent.TriggerBot and TriggerBot and CNPrivate.Silent.TriggerBot_HotKey and CNPrivate.Silent.TriggerBot_HoldMode and input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Silent.TriggerBotKey)] then
            TriggerBot = false
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Esp.EspKey)] and CNPrivate.Esp.UseEspKeyBind and CNPrivate.Esp.HoldMode and CNPrivate.Esp.Enabled then
    		CNPrivate.Esp.Enabled = false
    		if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Esp then
    		    Script.Functions.CreateNotification("Esp: " .. tostring(CNPrivate.Esp.Enabled), Color3.fromRGB(206, 67, 67))
    		end
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.AimAssist.KeyBind)] and CNPrivate.AimAssist.Enabled and CNPrivate.AimAssist.HoldMode then
    		AimTarget = nil
    		CurrentVelocity2 = Vector3.zero
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Desync.DesyncKey)] and CNPrivate.Desync.HoldMode and CNPrivate.Desync.UseDesyncKey and CNPrivate.Desync.Enabled then
    		Desync = false
    		if CNPrivate.Options.NotificationMode.Enabled and CNPrivate.Options.NotificationMode.Desync then
    		    Script.Functions.CreateNotification("Desync: " .. tostring(Desync), Color3.fromRGB(206, 67, 67))
    		end
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Speed_KeyBind)] and CNPrivate.Macro.Speed_Enabled and CNPrivate.Macro.Speed_HoldMode and Macro then
            Macro = false
        end

        if input.KeyCode == Enum.KeyCode[string.upper(CNPrivate.Macro.Noclip_KeyBind)] and CNPrivate.Macro.Noclip_Macro and CNPrivate.Macro.Noclip_HoldMode and NoclipMacro then
            NoclipMacro = false
        end
    end
end)

-- // Anti Aim Viewer Functions
Script.Functions.ToolActivated = function()
    if CNPrivate.Silent.Enabled and CNPrivate.Silent.AntiAimViewer and Script.Functions.Alive(SilentTarget) and Script.Functions.SilentCheck(SilentTarget) then
        local TargetCF = nil
        local TargetFalling = false

        local GetPart = Script.Functions.GetClosestPartMethod(SilentTarget)
        if GetPart == nil then return end
        CNPrivate.Silent.Part = tostring(GetPart)
        Script.SavedValue.SilentPart = tostring(GetPart)
        
        if CNPrivate.Silent.ClosestPoint then
            TargetCF = Script.Functions.GetClosestPointOnPart(GetPart)
        else
            TargetCF = GetPart.Position
        end

        if CNPrivate.Silent.AntiGroundShots and CurrentVelocity.Y < CNPrivate.Silent.AntiGroundActivation then
            TargetFalling = true
        end
        
        if TargetCF and CurrentVelocity then
            if CNPrivate.Silent.PredictMovement then 
                if CNPrivate.Silent.BlatantMode then
                    local Enabled = true
                    local Mag = (SilentTarget.Character.Humanoid.MoveDirection).Magnitude
                    local SilentVel = SilentTarget.Character.HumanoidRootPart.Velocity
                    if (SilentVel).Magnitude > 110 then
                        Enabled = false
                    elseif SilentVel.Y > 50 then
                        Enabled = false
                    elseif SilentVel.Y < -35 then
                        Enabled = false
                    elseif SilentVel.Y > 75 then
                        Enabled = false
                    elseif (SilentVel).Magnitude < 1 and Mag > 0.01 then
                        Enabled = false
                    elseif (SilentVel).Magnitude > 5 and Mag < 0.01 then
                        Enabled = false
                    end
                    if Enabled and CNPrivate.UniversalCheck.WallCheck_V2 and not Script.Functions.WallCheck(SilentTarget.Character.HumanoidRootPart.Position + (SilentVel * CNPrivate.Silent.Prediction), SilentTarget.Character) then
                        return
                    end
                    if Enabled then
                        if TargetFalling then
                            TargetCF = TargetCF + (Vector3.new(SilentVel.X, (SilentVel.Y * CNPrivate.Silent.AntiGroundValue), SilentVel.Z) * CNPrivate.Silent.Prediction)
                        else
                            TargetCF = TargetCF + (SilentVel * CNPrivate.Silent.Prediction)
                        end
                    else
                        if TargetFalling then
                            TargetCF = TargetCF + (Vector3.new(CurrentVelocity.X, (CurrentVelocity.Y * CNPrivate.Silent.AntiGroundValue), CurrentVelocity.Z) * CNPrivate.Silent.Prediction)
                        else
                            TargetCF = TargetCF + (CurrentVelocity * CNPrivate.Silent.Prediction)
                        end
                    end
                else
                    if TargetFalling then
                        TargetCF = TargetCF + (Vector3.new(CurrentVelocity.X, (CurrentVelocity.Y * CNPrivate.Silent.AntiGroundValue), CurrentVelocity.Z) * CNPrivate.Silent.Prediction)
                    else
                        TargetCF = TargetCF + (CurrentVelocity * CNPrivate.Silent.Prediction)
                    end
                end
            end
            if CNPrivate.Silent.Humanize then
                local HumanizeValue = CNPrivate.Silent.HumanizeValue 
                TargetCF = (TargetCF + Script.Functions.RandomVec3(HumanizeValue, 0.01))
            end
        end
        if TargetCF then
            if CNPrivate.Silent.LegitMode then
                local PartPos = Camera:WorldToScreenPoint(TargetCF)
                local GetScreenPos = Script.Functions.GetFovPosition()
                local Magnitude = ((Vector2.new(PartPos.X, PartPos.Y) - GetScreenPos) - CNPrivate.Silent.Fov.Offset).Magnitude

                if (CNPrivate.Silent.ForceLock == false and Script.Drawing.SilentCircle.Radius + 4 > Magnitude) or CNPrivate.Silent.ForceLock == true then
                    return
                end
            end

            if CNPrivate.Silent.Custom_AntiAimViewerPoint.Enabled == false then
                if game.PlaceId == 13873488228 or game.PlaceId == 13872892064 or game.PlaceId == 13872913451 then
                    local Args = {
                        [1] = "MOUSE",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage").MAINEVENT:FireServer(unpack(Args))
                elseif game.PlaceId == 13397024889 then
                    local Args = {
                        [1] = "MOUSE",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage").MAINEVENT:FireServer(unpack(Args))
                elseif game.PlaceId == 9825515356 then
                    local Args = {
                        [1] = "GetMousePos",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(Args))
                elseif game.PlaceId == 9183932460 then
                    local Args = {
                        [1] = "UpdateMousePos",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage"):FindFirstChild(".gg/untitledhood"):FireServer(unpack(Args))
                elseif game.PlaceId == 5602055394 then
                    local Args = {
                        [1] = "MousePos",
                        [2] = TargetCF,
                        [3] = "P"
                    }
                    game:GetService("ReplicatedStorage").Bullets:FireServer(unpack(Args))
                elseif game.PlaceId == 13051460029 or game.PlaceId == 11833542073 or game.PlaceId == 13051527453 or game.PlaceId == 13395952276 then
                    local Args = {
                        [1] = "UpdateMousePos",
                        [2] = {
                            ["MousePos"] = TargetCF,
                            ["Camera"] = Vector3.new(Camera.CFrame.X, Camera.CFrame.Y, Camera.CFrame.Z)
                        }
                    }
                    game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(Args))
                elseif game.PlaceId == 13051527453 then
                    local Args = {
                        [1] = "UpdateMousePos",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(Args))
                elseif game.PlaceId == 12618586930 then
                    local Args = {
                        [1] = "UpdateMousePos",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage").Remote:FireServer(unpack(Args))
                else
                    local Args = {
                        [1] = "UpdateMousePos",
                        [2] = TargetCF
                    }
                    game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(Args))
                end
            else
                if type(CNPrivate.Silent.Custom_AntiAimViewerPoint.RemoteEvent) == ("function") then
                    local Args, MainEvent = CNPrivate.Silent.Custom_AntiAimViewerPoint.RemoteEvent(TargetCF)
                    if type(Args) == ("table") and MainEvent:IsA("RemotEvent") then
                        MainEvent:FireServer(unpack(Args))
                    end
                end
            end
        end
    end
end

-- // Connects The AntiAimViewer To Gun
Script.Functions.GetConnections = function(Tool)
    if Tool:IsA("Tool") then
        if ToolConnection then
            ToolConnection:Disconnect()
        end
        ToolConnection = Tool.Activated:Connect(Script.Functions.ToolActivated)
    end
end

-- // Gets Character When New Character Is Added
Script.Functions.WhenCharacterAdded = function(Character)
    Character.ChildAdded:Connect(Script.Functions.GetConnections)
end

-- // Connects The LocalPlayer Character
if Client.Character then
    Script.Functions.WhenCharacterAdded(Client.Character)
end
Client.CharacterAdded:Connect(Script.Functions.WhenCharacterAdded)

-- // Memory Spoofer Functions
Script.Functions.ChangeText = function()
    pcall(function()
        coroutine.resume(coroutine.create(function()
            local PerformanceStats = game:GetService("CoreGui").RobloxGui:FindFirstChild("PerformanceStats")
            if not PerformanceStats then return end
            for _, v in pairs(PerformanceStats:GetDescendants()) do
                if v.ClassName == "TextLabel" then
                    if v.Text:match("MB") then
                        if v.Name == "ValueLabel" then
                            v.Text = Text_1 .. "" .. Text_2
                        end
                        if v.Name == "Label" then
                            if v.Text:match("Current") then
                                v.Text = "Current " .. Text_1 .. "" .. Text_2
                            end
                            if v.Text:match("Average") then
                                v.Text = "Average " .. Text_3.. "" .. Text_4
                            end
                        end
                    end
                end
            end
        end))
        local DevConsole = game:GetService("CoreGui"):FindFirstChild("DevConsoleMaster")
        if not DevConsole then return end
        for _, v in pairs(DevConsole:GetDescendants()) do
            if v.ClassName == "TextButton" then
                if v.Text:match("MB") and not v.Text:match("Value MB") then
                    v.Text = Text_5 .. " MB"
                end
            end
        end
        if DevConsole:FindFirstChild("DevConsoleWindow"):FindFirstChild("DevConsoleUI"):FindFirstChild("MainView"):FindFirstChild("ClientMemory"):FindFirstChild("Entries"):FindFirstChild("Memory"):FindFirstChild("value") then
            DevConsole.DevConsoleWindow.DevConsoleUI.MainView.ClientMemory.Entries.Memory.value.Text =  Text_5 .. "" .. Text_6
        end
        
        local Graph = DevConsole:FindFirstChild("DevConsoleWindow"):FindFirstChild("DevConsoleUI"):FindFirstChild("MainView"):FindFirstChild("ClientMemory"):FindFirstChild("Entries"):FindFirstChild("Memory"):FindFirstChild("Graph"):FindFirstChild("graph")
        local Graph2 = DevConsole:FindFirstChild("DevConsoleWindow"):FindFirstChild("DevConsoleUI"):FindFirstChild("MainView"):FindFirstChild("ClientMemory"):FindFirstChild("Entries"):FindFirstChild("Memory"):FindFirstChild("Graph")
        if Graph then
            if Graph:FindFirstChild("LatestEntryText") then
                Graph:FindFirstChild("LatestEntryText").Text = Text_1 .. Text_7
                Graph:FindFirstChild("AxisTextY0").Text = math.floor(Text_5 * 0.9) .. Text_6
            end
            local Hover_Y = Graph.HoverDetails.HoverHorizontal.Position.Y.Offset
            local TopValue = tonumber(Graph.LatestEntryText.Text)
            local BottomValue = tonumber(Graph.AxisTextY0.Text)
            local TopText_Y = Graph.LatestEntryText.Position.Y.Offset
            local BottomText_Y = Graph.AxisTextY0.Position.Y.Offset
            local LatestEntryLine_Y = Graph.LatestEntryLine.Position.Y.Offset
            local Name = DevConsole.DevConsoleWindow.DevConsoleUI.MainView.ClientMemory.Entries.Memory.Graph.name
            
            if Hover_Y < LatestEntryLine_Y then
                TopText_Y = Graph.LatestEntryText.Position.Y.Offset
                BottomText_Y = Graph.AxisTextY0.Position.Y.Offset
            elseif Graph.AxisTextY0.Position.Y.Offset < LatestEntryLine_Y then
                TopText_Y = Name.Position.Y.Offset
                BottomText_Y = Graph.LatestEntryText.Position.Y.Offset
                TopValue = tonumber(DevConsoleUI.TopBar.LiveStatsModule["MemoryUsage_MB"].Text)
                BottomValue = tonumber(Graph.LatestEntryText.Text)
            end
            
            local HoverValue = BottomValue + ((TopValue - BottomValue) * ((Hover_Y - BottomText_Y) / (TopText_Y - BottomText_Y)))
            Graph.HoverDetails.HoverTextY.Text = string.format("%.3f", HoverValue)
        end
    end)
end

local SavedError, SavedError2, SavedError3 = nil, nil, nil
-- // Fires Every Frame Prior To The Frame Being Rendered.
coroutine.resume(coroutine.create(function()
    while true do
        local Succes, Error = pcall(function()
            if Client.Character and Client.Character:FindFirstChild("LowerTorso") and Client.Character.LowerTorso:FindFirstChild("LeftHipRigAttachment") and Client.Character.LowerTorso.LeftHipRigAttachment:FindFirstChild("OriginalPosition") then
                Client.Character.LowerTorso.LeftHipRigAttachment.OriginalPosition:Destroy()
            end
            if CNPrivate.Options.AntiError then 
                coroutine.wrap(pcall)(function()
                    for _, v in ipairs(getconnections(game:GetService('ScriptContext').Error)) do 
                        v:Disable();
                    end
                end)
            end
            Script.Functions.Desync()
            Script.Functions.GetSilentTarget()
            Script.Functions.UpdateFOV()
            if CNPrivate.Options.AutoGetUp and Script.Functions.Alive(Client) and Client.Character.Humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
                Client.Character.Humanoid:ChangeState("GettingUp")
            end
            Script.Functions.MouseChanger()
            if TriggerBot and Script.Functions.Alive(SilentTarget) and SilentTarget.Character:FindFirstChild(CNPrivate.Silent.Part) then
                local Magnitude = Script.Functions.GetMagnitudeFromMouse(SilentTarget.Character.HumanoidRootPart)

                if (CNPrivate.Silent.ForceLock == false and Script.Drawing.SilentCircle.Radius + 4 > Magnitude) or CNPrivate.Silent.ForceLock == true then
                    if CNPrivate.Silent.TriggerBot_Delay == 0 then
                        mouse1click()
                    else
                        task.spawn(function()
                            task.wait(CNPrivate.Silent.TriggerBot_Delay / 1000)
                            mouse1click()
                        end)
                    end
                end
            end
            Script.Functions.SilentMisc()
            Script.Functions.UpdateEsp()
        end)
        if not Succes then
            if SavedError ~= Error then
                SavedError = Error
                Script.Functions.CreateNotification("SomeThing Went Wrong! We Have Sent The Error Code To The Devs!", Color3.fromRGB(206, 67, 67))
                wait(0.5)
                Script.Functions.CreateNotification(Error, Color3.fromRGB(206, 67, 67))
            end
        end
        RS.Heartbeat:Wait()
    end
end))

-- // Fires Every Frame After The Physics Simulation Has Completed.
RS.RenderStepped:Connect(function(DeltaTime)
    local Succes, Error = pcall(function()
        -- // Notification Fade Function And Position Change
    	local Smallest = math.huge
    	for i = 1, #Script.NotifyNote do
    		local v = Script.NotifyNote[i]
    		if v and v.Enabled then
    			Smallest = i < Smallest and i or Smallest
    		else
    			table.remove(Script.NotifyNote, i)
    		end
    	end
    	local Length = #Script.NotifyNote
    	for i = 1, #Script.NotifyNote do
    		local Note = Script.NotifyNote[i]
    		Note:Update(i, Length, DeltaTime)
    		if i <= math.ceil(Length / 10) or Note.Fading then
    			Note:Fade(i, Length, DeltaTime)
    		end
    	end
    end)
    if not Succes then
        if SavedError2 ~= Error then
            SavedError2 = Error
            Script.Functions.CreateNotification("SomeThing Went Wrong! We Have Sent The Error Code To The Devs!", Color3.fromRGB(206, 67, 67))
            wait(0.5)
            Script.Functions.CreateNotification(Error, Color3.fromRGB(206, 67, 67))
        end
    end
end)

-- // The Function For Target Bot, GunSettings
coroutine.resume(coroutine.create(function()
    while true do
        local Succes, Error = pcall(function()
            if CNPrivate.UniversalCheck.Advanced.Target_Bots and game:GetService("Workspace"):FindFirstChild(CNPrivate.UniversalCheck.Advanced.Bot_Path) then
                for _, v in pairs(game:GetService("Workspace")[CNPrivate.UniversalCheck.Advanced.Bot_Path]:GetChildren()) do
                    if not Players:FindFirstChild(v.Name) then
                        local CreatePlayer = Instance.new("Player")
                        CreatePlayer.Name = v.Name
                        CreatePlayer.Character = v
                    else
                        if Players:FindFirstChild(v.Name) then
                            Players[v.Name].Character = v
                        end
                    end
                end
            end
        	if CNPrivate.Silent.GunSettings.Enabled then
            	local CurrentGun = Script.Functions.GetCurrentWeaponName()
                local WeaponSettings = CNPrivate.Silent.GunSettings[CurrentGun]
                if WeaponSettings ~= nil then
                    if CNPrivate.Silent.GunSettings.Methods.Range == false then
                        if CNPrivate.Silent.GunSettings.Methods.Smoothness and Script.SavedValue.AimAssistSmoothX ~=  WeaponSettings.Smoothness then
                            CNPrivate.AimAssist.Smoothness_X = WeaponSettings.Smoothness
                            CNPrivate.AimAssist.Smoothness_Y = WeaponSettings.Smoothness
                            Script.SavedValue.AimAssistSmoothX = WeaponSettings.Smoothness
                            Script.SavedValue.AimAssistSmoothY = WeaponSettings.Smoothness
                        end
                        if CNPrivate.Silent.GunSettings.Methods.AirSmoothness and CNPrivate.AimAssist.AirSmoothness_X ~= WeaponSettings.AirSmoothness then
                            CNPrivate.AimAssist.AirSmoothness_X = WeaponSettings.AirSmoothness
                            CNPrivate.AimAssist.AirSmoothness_Y = WeaponSettings.AirSmoothness
                        end
                        if CNPrivate.Silent.GunSettings.Methods.HitChance and CNPrivate.Silent.Prediction ~= WeaponSettings.HitChance then
                            CNPrivate.Silent.HitChance = WeaponSettings.HitChance
                        end
                        if CNPrivate.Silent.GunSettings.Methods.AirHitChance and CNPrivate.Silent.Prediction ~= WeaponSettings.AirHitChance then
                            CNPrivate.Silent.AirHitChance = WeaponSettings.AirHitChance
                        end
                        if CNPrivate.Silent.GunSettings.Methods.Prediction and CNPrivate.Silent.Prediction ~= WeaponSettings.Prediction then
                            CNPrivate.Silent.Prediction = WeaponSettings.Prediction
                        end
                        if CNPrivate.Silent.GunSettings.Methods.Fov and SilentFovRadius.Value ~= WeaponSettings.Fov then
                            if CNPrivate.Silent.GunSettings.Dynamic.Enabled then
                                local Create = Tween:Create(SilentFovRadius, TweenInfo.new(CNPrivate.Silent.GunSettings.Dynamic.Time, Enum.EasingStyle[CNPrivate.Silent.GunSettings.Dynamic.EasingStyle], Enum.EasingDirection[CNPrivate.Silent.GunSettings.Dynamic.EasingDirection]), {Value = WeaponSettings.Fov})
                                Create:Play()
                                Create.Completed:Wait()
                            else
                                SilentFovRadius.Value = WeaponSettings.Fov
                            end
                        end
                    end
                    if CNPrivate.Silent.Part == nil then return end
                    if CNPrivate.Silent.GunSettings.Methods.Range and Script.Functions.Alive(SilentTarget) and Script.Functions.Alive(Client) and SilentTarget.Character:FindFirstChild(CNPrivate.Silent.Part) then
                        local Magnitude = Script.Functions.GetMagnitudeFromMouse(SilentTarget.Character.HumanoidRootPart)

                        if (CNPrivate.Silent.ForceLock == false and Script.Drawing.SilentCircle.Radius + 4 > Magnitude) or CNPrivate.Silent.ForceLock == true then
                            local Magnitude = (SilentTarget.Character.HumanoidRootPart.Position - Client.Character.HumanoidRootPart.Position).Magnitude
                            if Magnitude < CNPrivate.Silent.GunSettings.Close_Activation then
                                if CNPrivate.Silent.GunSettings.Methods.Smoothness and Script.SavedValue.AimAssistSmoothX ~=  WeaponSettings.CloseSmoothness then
                                    CNPrivate.AimAssist.Smoothness_X = WeaponSettings.CloseSmoothness
                                    CNPrivate.AimAssist.Smoothness_Y = WeaponSettings.CloseSmoothness
                                    Script.SavedValue.AimAssistSmoothX = WeaponSettings.CloseSmoothness
                                    Script.SavedValue.AimAssistSmoothY = WeaponSettings.CloseSmoothness
                                end
                                if CNPrivate.Silent.GunSettings.Methods.AirSmoothness and CNPrivate.AimAssist.AirSmoothness_X ~= WeaponSettings.CloseAirSmoothness then
                                    CNPrivate.AimAssist.AirSmoothness_X = WeaponSettings.CloseAirSmoothness
                                    CNPrivate.AimAssist.AirSmoothness_Y = WeaponSettings.CloseAirSmoothness
                                end
                                if CNPrivate.Silent.GunSettings.Methods.HitChance and CNPrivate.Silent.HitChance ~= WeaponSettings.CloseHitChance then
                                    CNPrivate.Silent.HitChance = WeaponSettings.CloseHitChance
                                end
                                if CNPrivate.Silent.GunSettings.Methods.AirHitChance and CNPrivate.Silent.AirHitChance ~= WeaponSettings.CloseAirHitChance then
                                    CNPrivate.Silent.AirHitChance = WeaponSettings.CloseAirHitChance
                                end
                                if CNPrivate.Silent.GunSettings.Methods.Prediction and CNPrivate.Silent.Prediction ~= WeaponSettings.ClosePrediction then
                                    CNPrivate.Silent.Prediction = WeaponSettings.ClosePrediction
                                end
                                if CNPrivate.Silent.GunSettings.Methods.Fov and SilentFovRadius.Value ~= WeaponSettings.CloseFov then
                                    if CNPrivate.Silent.GunSettings.Dynamic.Enabled then
                                        local Create = Tween:Create(SilentFovRadius, TweenInfo.new(CNPrivate.Silent.GunSettings.Dynamic.Time, Enum.EasingStyle[CNPrivate.Silent.GunSettings.Dynamic.EasingStyle], Enum.EasingDirection[CNPrivate.Silent.GunSettings.Dynamic.EasingDirection]), {Value = WeaponSettings.CloseFov})
                                        Create:Play()
                                        Create.Completed:Wait()
                                    else
                                        SilentFovRadius.Value = WeaponSettings.CloseFov
                                    end
                                end
                            elseif Magnitude < CNPrivate.Silent.GunSettings.Medium_Activation then
                                if CNPrivate.Silent.GunSettings.Methods.Smoothness and Script.SavedValue.AimAssistSmoothX ~= WeaponSettings.MedSmoothness then
                                    CNPrivate.AimAssist.Smoothness_X = WeaponSettings.MedSmoothness
                                    CNPrivate.AimAssist.Smoothness_Y = WeaponSettings.MedSmoothness
                                    Script.SavedValue.AimAssistSmoothX = WeaponSettings.MedSmoothness
                                    Script.SavedValue.AimAssistSmoothY = WeaponSettings.MedSmoothness
                                end
                                if CNPrivate.Silent.GunSettings.Methods.AirSmoothness and CNPrivate.AimAssist.AirSmoothness_X ~= WeaponSettings.MedAirSmoothness then
                                    CNPrivate.AimAssist.AirSmoothness_X = WeaponSettings.MedAirSmoothness
                                    CNPrivate.AimAssist.AirSmoothness_Y = WeaponSettings.MedAirSmoothness
                                end
                                if CNPrivate.Silent.GunSettings.Methods.HitChance and CNPrivate.Silent.HitChance ~= WeaponSettings.MedHitChance then
                                    CNPrivate.Silent.HitChance = WeaponSettings.MedHitChance
                                end
                                if CNPrivate.Silent.GunSettings.Methods.AirHitChance and CNPrivate.Silent.AirHitChance ~= WeaponSettings.MedAirHitChance then
                                    CNPrivate.Silent.AirHitChance = WeaponSettings.MedAirHitChance
                                end
                                if CNPrivate.Silent.GunSettings.Methods.Prediction and CNPrivate.Silent.Prediction ~= WeaponSettings.MedPrediction then
                                    CNPrivate.Silent.Prediction = WeaponSettings.ClosePrediction
                                end
                                if CNPrivate.Silent.GunSettings.Methods.Fov and SilentFovRadius.Value ~= WeaponSettings.MedFov then
                                    if CNPrivate.Silent.GunSettings.Dynamic.Enabled then
                                        local Create = Tween:Create(SilentFovRadius, TweenInfo.new(CNPrivate.Silent.GunSettings.Dynamic.Time, Enum.EasingStyle[CNPrivate.Silent.GunSettings.Dynamic.EasingStyle], Enum.EasingDirection[CNPrivate.Silent.GunSettings.Dynamic.EasingDirection]), {Value = WeaponSettings.MedFov})
                                        Create:Play()
                                        Create.Completed:Wait()
                                    else
                                        SilentFovRadius.Value = WeaponSettings.MedFov
                                    end
                                end
                            elseif Magnitude < CNPrivate.Silent.GunSettings.Far_Activation then
                                if CNPrivate.Silent.GunSettings.Methods.Smoothness and Script.SavedValue.AimAssistSmoothX ~= WeaponSettings.FarSmoothness then
                                    CNPrivate.AimAssist.Smoothness_X = WeaponSettings.FarSmoothness
                                    CNPrivate.AimAssist.Smoothness_Y = WeaponSettings.FarSmoothness
                                    Script.SavedValue.AimAssistSmoothX = WeaponSettings.FarSmoothness
                                    Script.SavedValue.AimAssistSmoothY = WeaponSettings.FarSmoothness
                                end
                                if CNPrivate.Silent.GunSettings.Methods.AirSmoothness and CNPrivate.AimAssist.AirSmoothness_X ~= WeaponSettings.FarAirSmoothness then
                                    CNPrivate.AimAssist.AirSmoothness_X = WeaponSettings.FarAirSmoothness
                                    CNPrivate.AimAssist.AirSmoothness_Y = WeaponSettings.FarAirSmoothness
                                end
                                if CNPrivate.Silent.GunSettings.Methods.HitChance and CNPrivate.Silent.HitChance ~= WeaponSettings.FarHitChance then
                                    CNPrivate.Silent.HitChance = WeaponSettings.FarHitChance
                                end
                                if CNPrivate.Silent.GunSettings.Methods.AirHitChance and CNPrivate.Silent.AirHitChance ~= WeaponSettings.FarAirHitChance then
                                    CNPrivate.Silent.AirHitChance = WeaponSettings.FarAirHitChance
                                end
                                if CNPrivate.Silent.GunSettings.Methods.Prediction and CNPrivate.Silent.Prediction ~= WeaponSettings.FarPrediction then
                                    CNPrivate.Silent.Prediction = WeaponSettings.FarPrediction
                                end
                                if CNPrivate.Silent.GunSettings.Methods.Fov and SilentFovRadius.Value ~= WeaponSettings.FarFov then
                                    if CNPrivate.Silent.GunSettings.Dynamic.Enabled then
                                        local Create = Tween:Create(SilentFovRadius, TweenInfo.new(CNPrivate.Silent.GunSettings.Dynamic.Time, Enum.EasingStyle[CNPrivate.Silent.GunSettings.Dynamic.EasingStyle], Enum.EasingDirection[CNPrivate.Silent.GunSettings.Dynamic.EasingDirection]), {Value = WeaponSettings.FarFov})
                                        Create:Play()
                                        Create.Completed:Wait()
                                    else
                                        SilentFovRadius.Value = WeaponSettings.FarFov
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not Succes then
            if SavedError3 ~= Error then
                SavedError3 = Error
                Script.Functions.CreateNotification("SomeThing Went Wrong! We Have Sent The Error Code To The Devs!", Color3.fromRGB(206, 67, 67))
                wait(0.5)
                Script.Functions.CreateNotification(Error, Color3.fromRGB(206, 67, 67))
            end
        end
        RS.Heartbeat:Wait()
    end
end))

-- // Checks Everyone In The Server And Puts It In A Table
for _, Plr in pairs(Players:GetPlayers()) do
    coroutine.resume(coroutine.create(function()
        if Plr ~= Client then
            if Client:IsFriendsWith(Plr.UserId) then
                table.insert(Script.Friends, Plr)
            end
            Script.Functions.CheckIfMod(Plr)
            Script.Functions.NewPlayer(Plr)
        end
    end))
end

-- // Checks When Players Joins And Adds Them To A Table
Players.PlayerAdded:Connect(function(Plr)
    coroutine.resume(coroutine.create(function()
        if Plr ~= Client then
            if Client:IsFriendsWith(Plr.UserId) then
                table.insert(Script.Friends, Plr)
            end
            Script.Functions.CheckIfMod(Plr)
            Script.Functions.NewPlayer(Plr)
        end
    end))
end)

-- // Checks If A Player Left And Removes Them From The Table
Players.PlayerRemoving:Connect(function(Plr)
    if table.find(Script.Friends, Plr) then
        table.remove(Script.Friends, FindPlayer)
    end
    if game.PlaceId == 2788229376 then
        Script.Functions.RemoveTarget(Plr)
    end
    if table.find(Script.EspPlayers, Plr) then
        for _, v in pairs(Script.EspPlayers[Plr]) do
            if v ~= nil then
                v:Remove()
            end
        end
        table.remove(Script.EspPlayers, Plr)
    end
end)

-- // The Functions For The Internal Commands. SHITTY
if CNPrivate.Options.Internal and rconsoleprint and rconsolename then
    local InternalChatCommands = {
        clear = function()
            rconsoleclear()
        end,
        
        set = function(Path, Path2, Value)
            local CurrentPath = CNPrivate[Path]
            if not CurrentPath or not CurrentPath[Path2] then return rconsoleprint("Error: Coudlnt Find Path\n") end
            CurrentPath[Path2] = Value
            rconsoleprint("> " .. tostring(Path2) .. " Is Now Set To: " .. tostring(Value) .. "\n")
        end,

        set2 = function(Path, Path2, Path3, Value)
            local CurrentPath = CNPrivate[Path]
            local CurrentPath2 = CurrentPath[Path2]
            if not CurrentPath or not CurrentPath2 or CurrentPath2[Path3] then return rconsoleprint("Error: Coudlnt Find Path\n") end
            CurrentPath2[Path3] = Value
            rconsoleprint("> " .. tostring(Path3) .. " Is Now Set To: " .. tostring(Value) .. "\n")
        end,
        
        getplayers = function()
            for _, v in pairs(Players:GetChildren()) do
                if v ~= Client then
                    rconsoleprint("> " .. tostring(v).."\n")
                end
            end
        end,
        
        getplayersmagnitude = function()
            for _, v in pairs(Players:GetChildren()) do
                if v ~= Client and Script.Functions.Alive(v) and Script.Functions.Alive(Client) then
                    local GetStuds = (Client.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    rconsoleprint("> " .. tostring(v) .. " Is " .. GetStuds .. " Studs Away From You\n")
                end
            end
        end,
        
        removeesp = function(Plr)
            if table.find(Script.EspPlayers, Players[tostring(Plr)]) then
                for i, v in pairs(Script.EspPlayers[Players[tostring(Plr)]]) do
                    if v then
                        v:Remove()
                        rconsoleprint("> SuccesFully Removed ".. tostring(i) .." \n")
                    else
                        rconsoleprint("Error: Coudlnt Find Player \n")
                    end
                end
                table.remove(Script.EspPlayers, Players[tostring(Plr)])
            end
        end,
        
        addesp = function(Plr)
            if Players[tostring(Plr)] then
                Script.Functions.NewPlayer(Players[tostring(Plr)])
                rconsoleprint("> SuccesFully Added ".. tostring(Plr) .." \n")
            else
                rconsoleprint("Error: Coudlnt Find Player \n")
            end
        end,
        
        teleport = function(Plr)
            if Script.Functions.Alive(Players[Plr]) and Script.Functions.Alive(Client) then
                Client.Character.HumanoidRootPart.CFrame = Players[Plr].Character.HumanoidRootPart.CFrame
                rconsoleprint("> SuccesFully Teleported ".. tostring(Plr) .." \n")
            else
                rconsoleprint("Error: Coudlnt Find Player \n")
            end
        end,

        exec = function(Text)
            loadstring(Text)
        end,
        
        chat = function(Text)
            if Text == ("false") then 
                if getgenv().GetChat then 
                    getgenv().GetChat:Disconnect() 
                end 
            end
            if Text == ("true") then
                local Event = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                getgenv().GetChat = Event.OnMessageDoneFiltering.OnClientEvent:Connect(function(object)
                    rconsoleprint("> " .. string.format("%s : %s \n>", object.FromSpeaker, object.Message or ""))
                end)
            end
        end,
        
        discord = function(Plr)
            if setclipboard then
                setclipboard("discord.gg/CNPrivate")
            end
            if http_request or request or HttpPost or syn.request then
                local Send = http_request or request or HttpPost or syn.request
                local Table = {
                    ["cmd"] = "INVITE_BROWSER",
                    ["args"] = {["code"] = "CNPrivate"},
                    ["nonce"] = game:GetService("HttpService"):GenerateGUID(true)
                }
                Send({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    Body = game:GetService("HttpService"):JSONEncode(Table)
                })
                rconsoleprint("> SuccesFully Invited You To The Discord\n")
            end
        end,
        
        help = function()
            rconsoleprint("\n> List of available ChatCommands:\n\n")
            rconsoleprint("> set(<Path> <Path2> <boolean> Or <string>): Sets The Table To The Value!\n")
            rconsoleprint("> set2(<Path> <Path2> <Path3> <boolean> Or <string>): Sets The Table To The Value!\n")
            rconsoleprint("> addesp(<playername>): WhiteLists The Player Esp\n")
            rconsoleprint("> removeesp(<playername>): Remove The Player Esp\n")
            rconsoleprint("> teleport(<playername>): Teleports You To The Player (RISKY)\n")
            rconsoleprint("> getplayers: prints you an list of the players\n")
            rconsoleprint("> getplayersmagnitude: Prints You An List Of The Players And How Long Away From You\n")
            rconsoleprint("> clear: Clears The Console\n")
            rconsoleprint("> discord: Gets Invites You To The Discord\n")
            rconsoleprint("> exec(<string>): Executes The String\n")
            rconsoleprint("> chat(<boolean>): Shows You People Chatting\n\n")
        end,
    }

    -- // The Main Function For Internal
    coroutine.resume(coroutine.create(function()
        while wait(0.1) do
            rconsolename("CNPrivate Internal")
            rconsoleprint("> ")
            local line = rconsoleinput()
            local Command, Args = string.match(line, "(%S+)%s*(.*)")

            if Command == nil then
                return
            end

            if type(InternalChatCommands[Command]) ~= ("function") then
                rconsoleprint("\nUnknown Command: " .. Command .. "\n")
            else
                local Splitted = string.split(line, " ")
                if Splitted[2] ~= nil and Splitted[3] ~= nil and Splitted[4] ~= nil and Splitted[5] ~= nil then
                    if Splitted[5] == ("false") then 
                        Splitted[5] = false
                    elseif Splitted[5] == ("true") then 
                        Splitted[5] = true
                    end

                    local Succes, Error = pcall(InternalChatCommands[Command], Splitted[2], Splitted[3], Splitted[4], Splitted[5])
                    if not Succes then
                        rconsoleprint("\nError: " .. Error .. "\n")
                    end
                elseif Splitted[2] ~= nil and Splitted[3] ~= nil and Splitted[4] ~= nil then
                    if Splitted[4] == ("false") then 
                        Splitted[4] = false
                    elseif Splitted[4] == ("true") then 
                        Splitted[4] = true
                    end

                    local Succes, Error = pcall(InternalChatCommands[Command], Splitted[2], Splitted[3], Splitted[4])
                    if not Succes then
                        rconsoleprint("\nError: " .. Error .. "\n")
                    end
                else
                    if Command ~= ("set") or Command ~= ("set2") then
                        local Succes, Error = pcall(InternalChatCommands[Command], Args)
                        if not Succes then
                            rconsoleprint("\nError: " .. Error .. "\n")
                        end

                        rconsoleprint("\nError: Command Error\n")
                    end
                end
            end
        end
    end))
end

-- // Sends Information For Basic Stuff
if CNPrivate.Options.GetInformation then
    if GetTime then
        Script.Functions.CreateNotification("Loaded In: " .. string.format("%.".."4".."f", os.clock() - GetTime) .. " Seconds", Color3.fromRGB(206, 67, 67))
    end
end
