-- ============================================
--     🐾 PAW VUA + DÍNH NGƯỜI - FULL 🐾
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
local character = LocalPlayer.Character
local humanoid = character.Humanoid
humanoid.WalkSpeed = 70 -- Speed mặc định 70

-- ============================================
--       PHẦN 1: MENU DÍNH NGƯỜI
-- ============================================
local OFFSET_HEIGHT, OFFSET_BACK = 17, 2.1
local targetPlayer, connection, originalPlatformStand = nil, nil, false
local playerConnections = {}

-- Menu dính người (góc phải trên)
local stickGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
stickGui.Name = "StickMenu"

local stickFrame = Instance.new("Frame", stickGui)
stickFrame.Size = UDim2.new(0, 200, 0, 220)
stickFrame.Position = UDim2.new(1, -210, 0, 10)
stickFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
stickFrame.BackgroundTransparency = 0.2
stickFrame.BorderSizePixel = 0
stickFrame.Draggable = true
stickFrame.Active = true
stickFrame.Visible = false
Instance.new("UICorner", stickFrame).CornerRadius = UDim.new(0, 10)

local stickTitle = Instance.new("TextLabel", stickFrame)
stickTitle.Size = UDim2.new(1, 0, 0, 30)
stickTitle.BackgroundColor3 = Color3.fromRGB(255, 130, 160)
stickTitle.Text = "🎯 DÍNH NGƯỜI"
stickTitle.TextSize = 14
stickTitle.Font = Enum.Font.GothamBold
stickTitle.TextColor3 = Color3.new(1, 1, 1)
stickTitle.BorderSizePixel = 0
Instance.new("UICorner", stickTitle).CornerRadius = UDim.new(0, 10)

local stickSearch = Instance.new("TextBox", stickFrame)
stickSearch.Size = UDim2.new(0.9, 0, 0, 25)
stickSearch.Position = UDim2.new(0.05, 0, 0, 35)
stickSearch.PlaceholderText = "Tìm tên..."
stickSearch.Text = ""
stickSearch.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
stickSearch.TextColor3 = Color3.new(1, 1, 1)
stickSearch.BorderSizePixel = 0
Instance.new("UICorner", stickSearch).CornerRadius = UDim.new(0, 6)

local stickSF = Instance.new("ScrollingFrame", stickFrame)
stickSF.Size = UDim2.new(0.9, 0, 0, 100)
stickSF.Position = UDim2.new(0.05, 0, 0, 65)
stickSF.CanvasSize = UDim2.new(0, 0, 0, 0)
stickSF.ScrollBarThickness = 4
stickSF.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
stickSF.BorderSizePixel = 0
Instance.new("UICorner", stickSF).CornerRadius = UDim.new(0, 6)

local stickLayout = Instance.new("UIListLayout", stickSF)
stickLayout.Padding = UDim.new(0, 3)

local stickDetach = Instance.new("TextButton", stickFrame)
stickDetach.Size = UDim2.new(0.9, 0, 0, 28)
stickDetach.Position = UDim2.new(0.05, 0, 0, 175)
stickDetach.Text = "HỦY DÍNH"
stickDetach.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
stickDetach.TextColor3 = Color3.new(1, 1, 1)
stickDetach.Font = Enum.Font.GothamBold
stickDetach.TextSize = 12
stickDetach.BorderSizePixel = 0
Instance.new("UICorner", stickDetach).CornerRadius = UDim.new(0, 8)

local function detach()
    if connection then connection:Disconnect(); connection = nil end
    targetPlayer = nil
    local c = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if c then c.PlatformStand = originalPlatformStand end
end

local function attachToPlayer(p)
    detach()
    if p == LocalPlayer or not p.Character then return end
    targetPlayer = p
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then originalPlatformStand = myHum.PlatformStand; myHum.PlatformStand = true end

    connection = RunService.Heartbeat:Connect(function()
        if not targetPlayer or not targetPlayer.Character then detach() return end
        local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        myChar = LocalPlayer.Character
        local myRoot, myH = myChar and myChar:FindFirstChild("HumanoidRootPart"), myChar and myChar:FindFirstChildOfClass("Humanoid")
        if tRoot and myRoot and myH then
            myH.PlatformStand = true
            local pos = tRoot.Position + (tRoot.CFrame.UpVector * OFFSET_HEIGHT) - (tRoot.CFrame.LookVector * OFFSET_BACK)
            myRoot.CFrame = CFrame.lookAt(pos, tRoot.Position)
            myRoot.AssemblyLinearVelocity, myRoot.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        else detach() end
    end)
end

local function updateStickList()
    for _, c in ipairs(stickSF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local search = stickSearch.Text:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (search == "" or p.DisplayName:lower():find(search) or p.Name:lower():find(search)) then
            local btn = Instance.new("TextButton", stickSF)
            btn.Size = UDim2.new(0.95, 0, 0, 24)
            btn.Text = p.DisplayName
            btn.BackgroundColor3 = Color3.fromRGB(255, 160, 180)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 11
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            btn.MouseButton1Click:Connect(function() attachToPlayer(p) end)
        end
    end
    stickSF.CanvasSize = UDim2.new(0, 0, 0, stickLayout.AbsoluteContentSize.Y)
end

stickSearch:GetPropertyChangedSignal("Text"):Connect(updateStickList)

local function listen(p)
    if playerConnections[p] then return end
    playerConnections[p] = {
        p.CharacterAdded:Connect(updateStickList),
        p.CharacterRemoving:Connect(updateStickList)
    }
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then listen(p) end end
Players.PlayerAdded:Connect(function(p) listen(p); updateStickList() end)
Players.PlayerRemoving:Connect(function(p)
    if playerConnections[p] then for _, c in pairs(playerConnections[p]) do c:Disconnect() end; playerConnections[p] = nil end
    updateStickList()
end)

stickDetach.MouseButton1Click:Connect(detach)
LocalPlayer.CharacterRemoving:Connect(detach)
updateStickList()

-- ============================================
--       PHẦN 2: MENU PAW VUA CHÍNH
-- ============================================
local pawGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
pawGui.Name = "PawVua_Main"
pawGui.IgnoreGuiInset = true

-- Nút tròn
local toggleBtn = Instance.new("TextButton", pawGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 130)
toggleBtn.Text = "🐾"
toggleBtn.TextSize = 24
toggleBtn.BorderSizePixel = 0
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Menu chính
local mainFrame = Instance.new("Frame", pawGui)
mainFrame.Size = UDim2.new(0, 370, 0, 350)
mainFrame.Position = UDim2.new(0.5, -185, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 180, 200)
mainFrame.BackgroundTransparency = 0.45
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 130, 160)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -65, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🐾 PAW VUA SCRIPT"
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
closeBtn.Text = "✕"
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false; toggleBtn.Text = "🐾" end)

-- Nút mở menu dính
local stickToggleBtn = Instance.new("TextButton", titleBar)
stickToggleBtn.Size = UDim2.new(0, 28, 0, 24)
stickToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
stickToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 150)
stickToggleBtn.Text = "🎯"
stickToggleBtn.TextSize = 12
stickToggleBtn.TextColor3 = Color3.new(1, 1, 1)
stickToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", stickToggleBtn).CornerRadius = UDim.new(0, 6)
stickToggleBtn.MouseButton1Click:Connect(function() stickFrame.Visible = not stickFrame.Visible end)

-- Kéo menu
local dragging = false
local dragStart, menuStart = nil, nil
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; menuStart = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        mainFrame.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + d.X, menuStart.Y.Scale, menuStart.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Scroll
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, -8, 1, -44)
scrollFrame.Position = UDim2.new(0, 4, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
scrollFrame.ScrollBarThickness = 5
scrollFrame.BorderSizePixel = 0
local uiList = Instance.new("UIListLayout", scrollFrame)
uiList.Padding = UDim.new(0, 3)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleBtn.Text = mainFrame.Visible and "✕" or "🐾"
end)

-- ========== HÀM UI ==========
local function CT(name, def, cb)
    local fr = Instance.new("Frame", scrollFrame)
    fr.Size = UDim2.new(1, -6, 0, 36)
    fr.BackgroundTransparency = 0.85
    fr.BorderSizePixel = 0
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)
    local lb = Instance.new("TextLabel", fr)
    lb.Size = UDim2.new(0, 200, 1, 0)
    lb.Position = UDim2.new(0, 10, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextSize = 12
    lb.Font = Enum.Font.GothamSemibold
    lb.TextColor3 = Color3.fromRGB(60, 25, 45)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("TextButton", fr)
    sw.Size = UDim2.new(0, 38, 0, 19)
    sw.Position = UDim2.new(1, -48, 0.5, -9)
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.BorderSizePixel = 0
    sw.BackgroundColor3 = def and Color3.fromRGB(255, 105, 140) or Color3.fromRGB(170, 170, 180)
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local dt = Instance.new("Frame", sw)
    dt.Size = UDim2.new(0, 14, 0, 14)
    dt.Position = def and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dt.BackgroundColor3 = Color3.new(1, 1, 1)
    dt.BorderSizePixel = 0
    Instance.new("UICorner", dt).CornerRadius = UDim.new(1, 0)
    local on = def or false
    sw.MouseButton1Click:Connect(function()
        on = not on
        sw.BackgroundColor3 = on and Color3.fromRGB(255, 105, 140) or Color3.fromRGB(170, 170, 180)
        dt:TweenPosition(on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.12)
        cb(on)
    end)
end

local function CS(name, min, max, def, cb)
    local fr = Instance.new("Frame", scrollFrame)
    fr.Size = UDim2.new(1, -6, 0, 54)
    fr.BackgroundTransparency = 0.85
    fr.BorderSizePixel = 0
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)
    local lb = Instance.new("TextLabel", fr)
    lb.Size = UDim2.new(0, 230, 0, 18)
    lb.Position = UDim2.new(0, 10, 0, 2)
    lb.BackgroundTransparency = 1
    lb.Text = name .. ": " .. def
    lb.TextSize = 11
    lb.Font = Enum.Font.GothamSemibold
    lb.TextColor3 = Color3.fromRGB(60, 25, 45)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    local tr = Instance.new("TextButton", fr)
    tr.Size = UDim2.new(1, -20, 0, 16)
    tr.Position = UDim2.new(0, 10, 0, 26)
    tr.BackgroundColor3 = Color3.fromRGB(255, 195, 210)
    tr.BackgroundTransparency = 0.3
    tr.Text = ""
    tr.AutoButtonColor = false
    tr.BorderSizePixel = 0
    Instance.new("UICorner", tr).CornerRadius = UDim.new(0, 8)
    local pct = (def - min) / (max - min)
    local fl = Instance.new("Frame", tr)
    fl.Size = UDim2.new(pct, 0, 1, 0)
    fl.BackgroundColor3 = Color3.fromRGB(255, 105, 140)
    fl.BorderSizePixel = 0
    Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 8)
    local kn = Instance.new("TextButton", tr)
    kn.Size = UDim2.new(0, 18, 0, 18)
    kn.Position = UDim2.new(pct, -9, 0.5, -9)
    kn.BackgroundColor3 = Color3.new(1, 1, 1)
    kn.Text = ""
    kn.AutoButtonColor = false
    kn.BorderSizePixel = 0
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    local function up(x)
        local rx = math.clamp(x - tr.AbsolutePosition.X, 0, tr.AbsoluteSize.X)
        local pp = rx / tr.AbsoluteSize.X
        local v = math.floor(min + (max - min) * pp + 0.5)
        fl.Size = UDim2.new(pp, 0, 1, 0)
        kn.Position = UDim2.new(pp, -9, 0.5, -9)
        lb.Text = name .. ": " .. v
        cb(v)
    end
    tr.MouseButton1Down:Connect(function()
        up(mouse.X)
        local c1 = mouse.Move:Connect(function() up(mouse.X) end)
        local c2 = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then c1:Disconnect(); c2:Disconnect() end
        end)
    end)
    kn.MouseButton1Down:Connect(function()
        local c1 = mouse.Move:Connect(function() up(mouse.X) end)
        local c2 = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then c1:Disconnect(); c2:Disconnect() end
        end)
    end)
end

-- ========== BIẾN CHỨC NĂNG ==========
local aa, ah, sj, nc = false, false, false, false
local spd = 70
local sb, ssp = false, 60
local et, ev, hb = false, false, false
local hbs = 3

-- ========== TẠO CHỨC NĂNG ==========
CT("⚔️ Tự động đánh", false, function(v) aa = v end)
CT("🏥 Auto Heal (băng gạc)", false, function(v) ah = v end)
CT("🦘 Nhảy cao vô hạn", false, function(v) sj = v; if humanoid then humanoid.JumpPower = v and 300 or 50 end end)
CT("👻 Xuyên tường", false, function(v) nc = v end)
CS("🏃 Tốc độ chạy", 16, 200, 70, function(v) spd = v; if humanoid then humanoid.WalkSpeed = v end end)
CT("🔄 Spinbot", false, function(v) sb = v end)
CS("💫 Tốc độ quay Spin", 1, 100, 60, function(v) ssp = v end)
CT("🟢 ESP Tia Xanh Lá", false, function(v) et = v end)
CT("👁️ ESP Nhân Vật", false, function(v) ev = v end)
CT("🌈 Hitbox Rainbow", false, function(v) hb = v end)
CS("📏 Kích thước Hitbox", 1, 10, 3, function(v) hbs = v end)

scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 650)

-- ============================================
--         LOGIC CHỨC NĂNG
-- ============================================

-- Auto Attack
task.spawn(function() while task.wait(0.12) do if aa then pcall(function() local c = LocalPlayer.Character; if c then local t = c:FindFirstChildOfClass("Tool"); if t then t:Activate() end end end) end end end)

-- Auto Heal
task.spawn(function()
    while task.wait(0.6) do
        if ah then
            pcall(function()
                local c = LocalPlayer.Character; if not c then return end
                local h = c:FindFirstChild("Humanoid"); if not h or h.Health <= 0 then return end
                if h.Health < h.MaxHealth * 0.65 then
                    local tool = nil
                    for _, k in ipairs(c:GetChildren()) do if k:IsA("Tool") then local n = k.Name:lower(); if n:find("band") or n:find("băng") or n:find("gạc") or n:find("med") or n:find("heal") then tool = k; break end end end
                    if not tool then for _, it in ipairs(LocalPlayer.Backpack:GetChildren()) do if it:IsA("Tool") then local n = it.Name:lower(); if n:find("band") or n:find("băng") or n:find("gạc") or n:find("med") or n:find("heal") then tool = it; h:EquipTool(it); task.wait(0.1); break end end end end
                    if tool then tool:Activate() end
                end
            end)
        end
    end
end)

-- Nhảy cao
task.spawn(function() while task.wait(0.1) do if sj then pcall(function() local c = LocalPlayer.Character; if c then local h = c:FindFirstChild("Humanoid"); if h and h.Health > 0 then if h.JumpPower ~= 300 then h.JumpPower = 300 end; if h:GetState() == Enum.HumanoidStateType.Landed then h.Jump = true end end end end) end end end)

-- Xuyên tường
task.spawn(function() while task.wait(0.05) do if nc then pcall(function() local c = LocalPlayer.Character; if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end end end)

-- Speed (luôn giữ)
task.spawn(function() while task.wait(0.2) do pcall(function() local c = LocalPlayer.Character; if c then local h = c:FindFirstChild("Humanoid"); if h and h.Health > 0 then h.WalkSpeed = spd end end end) end end)

-- Spinbot
task.spawn(function() while task.wait(0.03) do if sb then pcall(function() local c = LocalPlayer.Character; if c and c.PrimaryPart then c.PrimaryPart.CFrame = c.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(ssp), 0) end end) end end end)

-- ESP Tia
task.spawn(function()
    local objs = {}
    while task.wait(0.1) do
        if et then
            pcall(function()
                local mc = LocalPlayer.Character; if not mc or not mc.PrimaryPart then return end
                for _, o in ipairs(Players:GetPlayers()) do
                    if o ~= LocalPlayer and o.Character and o.Character:FindFirstChild("Head") then
                        if objs[o.Name] then for _, j in ipairs(objs[o.Name]) do pcall(function() j:Remove() end) end end
                        local bm = Instance.new("Beam", workspace)
                        local a0 = Instance.new("Attachment", mc.PrimaryPart); a0.Position = Vector3.new(0, 2, 0)
                        local a1 = Instance.new("Attachment", o.Character.Head)
                        bm.Attachment0 = a0; bm.Attachment1 = a1
                        bm.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
                        bm.Width0 = 0.25; bm.Width1 = 0.25
                        bm.Transparency = NumberSequence.new(0.15)
                        bm.Enabled = true
                        objs[o.Name] = {bm, a0, a1}
                    end
                end
            end)
        end
    end
end)

-- ESP Nhân Vật
task.spawn(function()
    local objs = {}
    while task.wait(0.3) do
        if ev then
            pcall(function()
                for _, v in ipairs(objs) do pcall(function() v:Remove() end) end; objs = {}
                for _, o in ipairs(Players:GetPlayers()) do
                    if o ~= LocalPlayer and o.Character and o.Character:FindFirstChild("Head") and o.Character:FindFirstChild("Humanoid") then
                        local pc = o.Character
                        local hl = Instance.new("Highlight", pc)
                        hl.FillColor = Color3.fromRGB(0, 255, 0); hl.FillTransparency = 0.7
                        hl.OutlineColor = Color3.fromRGB(0, 255, 0); hl.Enabled = true
                        table.insert(objs, hl)
                        local bb = Instance.new("BillboardGui", pc.Head)
                        bb.Size = UDim2.new(0, 160, 0, 45); bb.StudsOffset = Vector3.new(0, 2.2, 0); bb.AlwaysOnTop = true
                        for _, ed in ipairs({"Top", "Bottom", "Left", "Right"}) do
                            local f2 = Instance.new("Frame", bb); f2.BorderSizePixel = 0; f2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            if ed == "Top" then f2.Size = UDim2.new(1, 0, 0, 2)
                            elseif ed == "Bottom" then f2.Size = UDim2.new(1, 0, 0, 2); f2.Position = UDim2.new(0, 0, 1, -2)
                            elseif ed == "Left" then f2.Size = UDim2.new(0, 2, 1, 0)
                            else f2.Size = UDim2.new(0, 2, 1, 0); f2.Position = UDim2.new(1, -2, 0, 0) end
                        end
                        local nl2 = Instance.new("TextLabel", bb)
                        nl2.Size = UDim2.new(1, 0, 0, 14); nl2.Position = UDim2.new(0, 0, 0, -16); nl2.BackgroundTransparency = 1
                        nl2.Text = o.Name; nl2.TextColor3 = Color3.fromRGB(0, 255, 0); nl2.TextStrokeTransparency = 0
                        nl2.Font = Enum.Font.GothamBold; nl2.TextSize = 10
                        local hpl2 = Instance.new("TextLabel", bb)
                        hpl2.Size = UDim2.new(1, 0, 0, 12); hpl2.Position = UDim2.new(0, 0, 1, 2); hpl2.BackgroundTransparency = 1
                        hpl2.Text = "❤️ " .. math.floor(pc.Humanoid.Health); hpl2.TextColor3 = Color3.fromRGB(255, 50, 50)
                        hpl2.TextStrokeTransparency = 0; hpl2.Font = Enum.Font.GothamBold; hpl2.TextSize = 9
                        table.insert(objs, bb)
                    end
                end
            end)
        end
    end
end)

-- Hitbox Rainbow
task.spawn(function()
    local objs = {}; local hue = 0
    while task.wait(0.1) do
        if hb then
            pcall(function()
                for _, v in ipairs(objs) do pcall(function() v:Remove() end) end; objs = {}
                hue = (hue + 0.02) % 1; local clr = Color3.fromHSV(hue, 1, 1)
                for _, o in ipairs(Players:GetPlayers()) do
                    if o ~= LocalPlayer and o.Character then
                        for _, pt in ipairs(o.Character:GetDescendants()) do
                            if pt:IsA("BasePart") then
                                local hl2 = Instance.new("Highlight", pt)
                                hl2.FillColor = clr; hl2.FillTransparency = 0.4; hl2.OutlineColor = clr; hl2.Enabled = true
                                table.insert(objs, hl2)
                            end
                        end
                        local rt = o.Character:FindFirstChild("HumanoidRootPart")
                        if rt then rt.Size = Vector3.new(hbs, hbs, hbs); rt.Transparency = 0.4; rt.BrickColor = BrickColor.new(clr) end
                    end
                end
            end)
        end
    end
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    character = c; humanoid = c:WaitForChild("Humanoid")
    humanoid.WalkSpeed = spd
    if sj then humanoid.JumpPower = 300 end
end)

print("🐾 ========================================")
print("🐾   PAW VUA + DÍNH NGƯỜI LOADED!")
print("🐾   Speed: 70 | Spin: 60")
print("🐾   Menu chính: Nút 🐾 bên trái")
print("🐾   Menu dính: Nút 🎯 trên title bar")
print("🐾 ========================================")
