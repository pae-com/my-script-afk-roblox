--[[
    Anti-AFK + Stats (Improved)
    Features: Anti-AFK, Ping, FPS, Timer, AFK Countdown, Minimize, Save Position, Keybind, Auto Rejoin
]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- ป้องกันรันซ้ำ
if getgenv().AntiAfkV2 then
    getgenv().AntiAfkV2:Destroy()
    getgenv().AntiAfkV2 = nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ====================== CONFIG ======================
local CONFIG = {
    Keybind = Enum.KeyCode.RightControl,   -- ปุ่มเปิด/ปิด GUI
    AFKTimeout = 20 * 60,                  -- 20 นาที (วินาที)
    AutoRejoin = true,                     -- เปิด Auto Rejoin
    RejoinDelay = 3,                       -- รอ กี่วินาทีก่อน rejoin
    SaveFile = "AntiAfkV2_Config.json",    -- ไฟล์เซฟตำแหน่ง
}

-- ====================== STATE ======================
local State = {
    AntiAfkEnabled = true,
    GuiVisible = true,
    Minimized = false,
    Running = true,
    LastInput = tick(),
    Seconds = 0,
    Minutes = 0,
    Hours = 0,
}

getgenv().AntiAfkV2Running = true

-- ====================== LOAD / SAVE POSITION ======================
local function LoadPosition()
    if isfile and isfile(CONFIG.SaveFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(CONFIG.SaveFile))
        end)
        if success and data and data.X and data.Y then
            return UDim2.new(0, data.X, 0, data.Y)
        end
    end
    return UDim2.new(0.08, 0, 0.13, 0) -- ตำแหน่งเริ่มต้น
end

local function SavePosition(frame)
    if writefile then
        local pos = {
            X = math.floor(frame.AbsolutePosition.X),
            Y = math.floor(frame.AbsolutePosition.Y)
        }
        pcall(function()
            writefile(CONFIG.SaveFile, game:GetService("HttpService"):JSONEncode(pos))
        end)
    end
end

-- ====================== CREATE GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiAfkV2"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
getgenv().AntiAfkV2 = ScreenGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 130)
Main.Position = LoadPosition()
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 28)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "Anti-AFK V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

-- ปุ่มปิด
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Main
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มย่อ
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -56, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = Main
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- เส้นคั่น
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -16, 0, 1)
Line.Position = UDim2.new(0, 8, 0, 32)
Line.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
Line.BorderSizePixel = 0
Line.Parent = Main

-- Labels
local function CreateLabel(name, pos, text)
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Size = UDim2.new(0, 110, 0, 20)
    lbl.Position = pos
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Main
    return lbl
end

local PingLabel = CreateLabel("Ping", UDim2.new(0, 12, 0, 42), "Ping: --")
local FpsLabel = CreateLabel("FPS", UDim2.new(0, 130, 0, 42), "FPS: --")
local TimerLabel = CreateLabel("Timer", UDim2.new(0, 12, 0, 64), "Time: 0:0:0")
local AfkLabel = CreateLabel("AFK", UDim2.new(0, 12, 0, 86), "AFK Left: 20:00")
local StatusLabel = CreateLabel("Status", UDim2.new(0, 12, 0, 106), "Status: Anti-AFK ON")

-- ====================== DRAG ======================
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                SavePosition(Main)
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ====================== MINIMIZE ======================
local fullSize = UDim2.new(0, 240, 0, 130)
local miniSize = UDim2.new(0, 240, 0, 32)

MinBtn.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    if State.Minimized then
        Main.Size = miniSize
        for _, child in ipairs(Main:GetChildren()) do
            if child:IsA("TextLabel") and child ~= Title then
                child.Visible = false
            end
        end
        Line.Visible = false
        MinBtn.Text = "+"
    else
        Main.Size = fullSize
        for _, child in ipairs(Main:GetChildren()) do
            if child:IsA("TextLabel") then child.Visible = true end
        end
        Line.Visible = true
        MinBtn.Text = "−"
    end
end)

-- ====================== CLOSE ======================
CloseBtn.MouseButton1Click:Connect(function()
    State.Running = false
    getgenv().AntiAfkV2Running = false
    ScreenGui:Destroy()
    getgenv().AntiAfkV2 = nil
end)

-- ====================== KEYBIND (ซ่อน/โชว์ GUI) ======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.Keybind then
        State.GuiVisible = not State.GuiVisible
        Main.Visible = State.GuiVisible
    end
end)

-- ====================== ANTI-AFK ======================
LocalPlayer.Idled:Connect(function()
    if State.AntiAfkEnabled and State.Running then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        State.LastInput = tick() -- รีเซ็ตเวลา AFK
    end
end)

-- ตรวจจับการขยับเมาส์/คีย์บอร์ด เพื่อรีเซ็ต AFK timer
UserInputService.InputBegan:Connect(function()
    State.LastInput = tick()
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        State.LastInput = tick()
    end
end)

-- ====================== FPS ======================
local fpsTable = {}
local lastFpsUpdate = tick()

RunService.RenderStepped:Connect(function()
    if not State.Running then return end
    local now = tick()
    table.insert(fpsTable, now)
    for i = #fpsTable, 1, -1 do
        if fpsTable[i] < now - 1 then
            table.remove(fpsTable, i)
        end
    end
    if now - lastFpsUpdate >= 0.5 then
        FpsLabel.Text = "FPS: " .. #fpsTable
        lastFpsUpdate = now
    end
end)

-- ====================== PING + TIMER + AFK COUNTDOWN ======================
task.spawn(function()
    while State.Running and ScreenGui.Parent do
        -- Ping
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.PerformanceStats.Ping:GetValue())
        end)
        PingLabel.Text = "Ping: " .. ping

        -- Timer
        State.Seconds += 1
        if State.Seconds >= 60 then
            State.Seconds = 0
            State.Minutes += 1
        end
        if State.Minutes >= 60 then
            State.Minutes = 0
            State.Hours += 1
        end
        TimerLabel.Text = string.format("Time: %d:%d:%d", State.Hours, State.Minutes, State.Seconds)

        -- AFK Countdown
        local elapsed = tick() - State.LastInput
        local remaining = math.max(0, CONFIG.AFKTimeout - elapsed)
        local mins = math.floor(remaining / 60)
        local secs = math.floor(remaining % 60)
        AfkLabel.Text = string.format("AFK Left: %02d:%02d", mins, secs)

        if remaining <= 60 then
            AfkLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        else
            AfkLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end

        StatusLabel.Text = State.AntiAfkEnabled and "Status: Anti-AFK ON" or "Status: Anti-AFK OFF"
        StatusLabel.TextColor3 = State.AntiAfkEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

        task.wait(1)
    end
end)

-- ====================== AUTO REJOIN ======================
if CONFIG.AutoRejoin then
    local function Rejoin()
        if not State.Running then return end
        task.wait(CONFIG.RejoinDelay)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end

    LocalPlayer.OnTeleport:Connect(function(teleportState)
        if teleportState == Enum.TeleportState.Failed then
            Rejoin()
        end
    end)

    game:GetService("CoreGui").RobloxPromptGui.DescendantAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" or child:FindFirstChild("ErrorMessage") then
            task.delay(2, Rejoin)
        end
    end)

    -- สำรอง: ถ้า Character หายไปนานผิดปกติ
    LocalPlayer.CharacterRemoving:Connect(function()
        task.delay(15, function()
            if State.Running and (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid")) then
                Rejoin()
            end
        end)
    end)
end

print("[Anti-AFK V2] Loaded | Keybind: RightControl")
