local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- QUẢN LÝ ---
local ChestManager = { IgnoreList = {}, Enabled = false }
local Settings = {
    Noclip = false, InfiniteJump = false, AutoHeal = false, AutoAttack = false, 
    AutoLoot = false, AutoRespawn = false, ESP = false, Hitbox = false, 
    Tracer = false, SpinBot = false, SpinSpeed = 10, ShowHealth = false
}

-- --- HÀM HỖ TRỢ ---
function ChestManager:GetNearest(maxDist)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local folder = workspace:FindFirstChild("Chests")
    if not hrp or not folder then return nil end
    local nearest, dist = nil, maxDist or 500
    for _, chest in ipairs(folder:GetChildren()) do
        if chest:IsA("BasePart") and not self.IgnoreList[chest] then
            local d = (hrp.Position - chest.Position).Magnitude
            if d < dist then dist = d; nearest = chest end
        end
    end
    return nearest
end

-- --- GIAO DIỆN ---
local Window = Rayfield:CreateWindow({Name = "Paw Vua Script - Ultimate Hub", LoadingTitle = "Khởi tạo...", LoadingSubtitle = "by Gemini"})

local TabMove = Window:CreateTab("Di chuyển", nil)
TabMove:CreateToggle({Name = "Xuyên tường", Callback = function(v) Settings.Noclip = v end})
TabMove:CreateToggle({Name = "Nhảy vô hạn", Callback = function(v) Settings.InfiniteJump = v end})

local TabCombat = Window:CreateTab("Chiến đấu", nil)
TabCombat:CreateToggle({Name = "Hitbox Đỏ", Callback = function(v) Settings.Hitbox = v end})
TabCombat:CreateToggle({Name = "ESP Rainbow", Callback = function(v) Settings.ESP = v end})
TabCombat:CreateToggle({Name = "Hiện máu người chơi", Callback = function(v) Settings.ShowHealth = v end})
TabCombat:CreateToggle({Name = "Auto Attack", Callback = function(v) Settings.AutoAttack = v end})

local TabMisc = Window:CreateTab("Loot & Khác", nil)
TabMisc:CreateToggle({Name = "Auto Loot (Đi bộ tới)", Callback = function(v) ChestManager.Enabled = v end})
TabMisc:CreateToggle({Name = "Auto Heal", Callback = function(v) Settings.AutoHeal = v end})
TabMisc:CreateButton({Name = "Đổi Server (Server Hop)", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})

-- --- ENGINE CHÍNH ---
RunService.RenderStepped:Connect(function()
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local MyChar = LocalPlayer.Character
    if not MyChar then return end
    local H, HRP = MyChar:FindFirstChild("Humanoid"), MyChar:FindFirstChild("HumanoidRootPart")

    -- AUTO LOOT (Dùng MoveTo thay vì Teleport để an toàn hơn)
    if ChestManager.Enabled and H and HRP then
        local target = ChestManager:GetNearest(150)
        if target then
            H:MoveTo(target.Position)
            if (HRP.Position - target.Position).Magnitude < 5 then
                ChestManager.IgnoreList[target] = true
                task.delay(3, function() ChestManager.IgnoreList[target] = nil end)
            end
        end
    end

    -- XỬ LÝ NGƯỜI CHƠI (ESP, HITBOX, MÁU)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local head, hum = char:FindFirstChild("Head"), char:FindFirstChild("Humanoid")
            if head then
                -- Hitbox
                head.Size = Settings.Hitbox and Vector3.new(6,6,6) or Vector3.new(2,1,1)
                head.Transparency = Settings.Hitbox and 0.7 or 0
                head.Color = Settings.Hitbox and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                -- ESP
                if Settings.ESP then
                    if not char:FindFirstChild("Highlight") then Instance.new("Highlight", char) end
                    char.Highlight.FillColor = rainbow
                elseif char:FindFirstChild("Highlight") then char.Highlight:Destroy() end
                -- Hiển thị máu
                if Settings.ShowHealth and hum then
                    local gui = head:FindFirstChild("HP_GUI") or Instance.new("BillboardGui", head)
                    gui.Name = "HP_GUI"; gui.Size = UDim2.new(0, 100, 0, 50); gui.AlwaysOnTop = true
                    local txt = gui:FindFirstChild("Text") or Instance.new("TextLabel", gui)
                    txt.Name = "Text"; txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
                    txt.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    txt.TextColor3 = (hum.Health/hum.MaxHealth < 0.3) and Color3.new(1,0,0) or Color3.new(0,1,0)
                elseif head:FindFirstChild("HP_GUI") then head.HP_GUI:Destroy() end
            end
        end
    end

    -- CÁC LOGIC KHÁC
    if Settings.AutoHeal and H and H.Health < 80 then
        local b = LocalPlayer.Backpack:FindFirstChild("Bandage") or MyChar:FindFirstChild("Bandage")
        if b then b.Parent = MyChar; b:Activate() end
    end
    if Settings.AutoAttack then local t = MyChar:FindFirstChildOfClass("Tool") if t then t:Activate() end end
    if Settings.Noclip then for _,v in pairs(MyChar:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end)

UserInputService.JumpRequest:Connect(function() if Settings.InfiniteJump then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)
