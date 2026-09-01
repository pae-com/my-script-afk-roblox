local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Window = Rayfield:CreateWindow({
    name = "My Cool Hub",
    subtitle = "Rayfield Gen2 Demo",
    theme = "cobalt", -- default, cobalt, ember, amethyst, frost, rose
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "MyCoolHub"
    }
})

-- ==================== TAB 1: หลัก ====================
local MainTab = Window:CreateTab({
    name = "Main",
    icon = 93364949241311 -- หรือใส่ชื่อ Lucide ก็ได้
})

MainTab:CreateText({
    title = "ยินดีต้อนรับ",
    content = "นี่คือตัวอย่าง UI ของ Rayfield Gen2 ที่ครบลูกเล่นพอสมควร"
})

MainTab:CreateDivider()

MainTab:CreateButton({
    name = "ทดสอบปุ่ม",
    description = "กดแล้วจะขึ้น Notification",
    callback = function()
        Window:Notify({
            title = "สำเร็จ!",
            content = "ปุ่มทำงานปกติ",
            duration = 4
        })
    end
})

local AutoFarm = MainTab:CreateToggle({
    name = "Auto Farm",
    description = "เปิด/ปิดระบบฟาร์มอัตโนมัติ",
    value = false,
    flag = "AutoFarm",
    callback = function(value)
        print("Auto Farm:", value)
    end
})

MainTab:CreateSlider({
    name = "ความเร็วเดิน",
    range = {16, 200},
    value = 16,
    suffix = " studs",
    flag = "WalkSpeed",
    callback = function(value)
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

MainTab:CreateDropdown({
    name = "เลือกโหมด",
    options = {"Normal", "Silent", "Rage", "Legit"},
    value = "Normal",
    flag = "AimMode",
    callback = function(selected)
        print("เลือกโหมด:", selected)
    end
})

MainTab:CreateDropdown({
    name = "เลือกหลายอย่าง",
    multiSelect = true,
    options = {"ESP", "Tracer", "Box", "Name", "Health"},
    value = {"ESP", "Box"},
    flag = "Visuals",
    callback = function(selected)
        print("เลือก:", table.concat(selected, ", "))
    end
})

-- ==================== TAB 2: ตั้งค่า ====================
local SettingsTab = Window:CreateTab({
    name = "Settings"
})

SettingsTab:CreateInput({
    name = "ชื่อผู้เล่น",
    placeholder = "ใส่ชื่อที่นี่...",
    flag = "PlayerName",
    callback = function(text)
        print("ชื่อที่ใส่:", text)
    end
})

SettingsTab:CreateKeybind({
    name = "ปุ่มเปิด/ปิด UI",
    value = "RightControl",
    flag = "ToggleUI",
    callback = function()
        Window:ToggleHide()
    end
})

SettingsTab:CreateColorPicker({
    name = "สีหลัก",
    value = Color3.fromRGB(0, 170, 255),
    flag = "MainColor",
    callback = function(color)
        print("สีที่เลือก:", color)
    end
})

SettingsTab:CreateDivider()

SettingsTab:CreateButton({
    name = "เปลี่ยนธีมเป็น Ember",
    callback = function()
        Window:ChangeTheme("ember")
    end
})

SettingsTab:CreateButton({
    name = "เปลี่ยนธีมเป็น Amethyst",
    callback = function()
        Window:ChangeTheme("amethyst")
    end
})

SettingsTab:CreateButton({
    name = "บันทึกค่าทันที",
    callback = function()
        Window:Save()
        Window:Notify({title = "Saved", content = "บันทึกค่าเรียบร้อยแล้ว"})
    end
})

-- ==================== TAB 3: แสดงผล ====================
local InfoTab = Window:CreateTab({
    name = "Info"
})

local MoneyStat = InfoTab:CreateStat({
    name = "เงินในเกม",
    prefix = "$",
    value = 12500
})

-- ตัวอย่างอัปเดตค่า Stat
task.spawn(function()
    while task.wait(3) do
        MoneyStat:Set(MoneyStat.value + math.random(100, 800))
    end
end)

InfoTab:CreateProgress({
    name = "ความคืบหน้าเควส",
    value = 0.65, -- 0 ถึง 1
    description = "กำลังทำเควสหลัก"
})

InfoTab:CreateConsole({
    name = "Log",
    -- สามารถใช้ .Print() หรือ .Clear() ได้
})

print("✅ Rayfield Gen2 UI โหลดเสร็จแล้ว")