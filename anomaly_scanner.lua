-- ==========================================================
-- ANOMALY DETECTOR V3.0 (Smart Category Observation Duty)
-- ==========================================================
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 1. CLEAN-UP UI LAMA
if CoreGui:FindFirstChild("AnomalyHelperUI") then
    CoreGui.AnomalyHelperUI:Destroy()
end

-- 2. BUAT UI PANEL UTAMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnomalyHelperUI"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 440)
Frame.Position = UDim2.new(0.02, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 45)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Text = "🚨 Smart Anomaly Radar V3"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.Parent = Frame
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseBtn

-- Tombol Minimize (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.Parent = Frame
local MinCorner = Instance.new("UICorner") MinCorner.CornerRadius = UDim.new(0, 6) MinCorner.Parent = MinBtn

-- Tombol Ambil Baseline (Kondisi Normal)
local SnapshotBtn = Instance.new("TextButton")
SnapshotBtn.Size = UDim2.new(1, -20, 0, 35)
SnapshotBtn.Position = UDim2.new(0, 10, 0, 50)
SnapshotBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SnapshotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SnapshotBtn.TextSize = 13
SnapshotBtn.Font = Enum.Font.GothamBold
SnapshotBtn.Text = "📸 1. Rekam Kondisi Normal (Start Shift)"
SnapshotBtn.Parent = Frame

local SnapshotCorner = Instance.new("UICorner")
SnapshotCorner.CornerRadius = UDim.new(0, 6)
SnapshotCorner.Parent = SnapshotBtn

-- Container Konten
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -90)
ContentContainer.Position = UDim2.new(0, 0, 0, 90)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Frame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -15)
Scroll.Position = UDim2.new(0, 10, 0, 5)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Scroll.Parent = ContentContainer

local OutputText = Instance.new("TextLabel")
OutputText.Size = UDim2.new(1, 0, 1, 0)
OutputText.BackgroundTransparency = 1
OutputText.TextColor3 = Color3.fromRGB(200, 200, 200)
OutputText.TextSize = 12
OutputText.Font = Enum.Font.Code
OutputText.TextXAlignment = Enum.TextXAlignment.Left
OutputText.TextYAlignment = Enum.TextYAlignment.Top
OutputText.TextWrapped = true
OutputText.Parent = Scroll

-- Fungsi Minimize & Close
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentContainer.Visible = not isMinimized
    if isMinimized then
        Frame.Size = UDim2.new(0, 350, 0, 55)
        MinBtn.Text = "+"
    else
        Frame.Size = UDim2.new(0, 350, 0, 440)
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 3. SISTEM PEMETAAN & KLASIFIKASI ANOMALI
local baselineData = {}
local isScanning = false

SnapshotBtn.MouseButton1Click:Connect(function()
    baselineData = {}
    local count = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            baselineData[obj] = {
                Position = obj.Position,
                Transparency = obj.Transparency,
                Color = obj.Color,
                ParentName = obj.Parent and obj.Parent.Name or "Unknown"
            }
            count = count + 1
        end
    end
    
    isScanning = true
    OutputText.Text = "[✓] Berhasil merekam " .. count .. " bagian part map!\n[+] Memindai kategori anomali..."
end)

-- Loop Cek Anomali Pintar (Mencocokkan dengan kategori game)
task.spawn(function()
    while true do
        task.wait(1.2)
        if isScanning then
            local anomaliesFound = {}
            
            for obj, data in pairs(baselineData) do
                if obj and obj.Parent then
                    -- 1. Kategori: MISPLACED SHADOW / NEW OBJECT / ENTITY (Bayangan atau objek muncul)
                    if data.Transparency > 0.4 and obj.Transparency <= 0.4 then
                        local nameLower = string.lower(obj.Name)
                        if nameLower:find("shadow") or nameLower:find("bayangan") then
                            table.insert(anomaliesFound, "👻 [MISPLACED SHADOW]\n ➔ Ditemukan di: " .. data.ParentName)
                        else
                            table.insert(anomaliesFound, "👁️ [NEW OBJECT / ENTITY]\n ➔ Objek muncul di: " .. data.ParentName)
                        end
                    end
                    
                    -- 2. Kategori: OBJECT RELOCATION (Bergeser posisi)
                    local dist = (obj.Position - data.Position).Magnitude
                    if dist > 3.0 and obj.Transparency <= 0.4 then
                        table.insert(anomaliesFound, "⚠️ [OBJECT RELOCATION]\n ➔ " .. obj.Name .. " bergeser di " .. data.ParentName)
                    end
                    
                    -- 3. Kategori: LIGHTING CHANGE (Perubahan lampu/warna)
                    if obj.Color ~= data.Color and obj.Transparency <= 0.4 then
                        table.insert(anomaliesFound, "💡 [LIGHTING/SURFACE CHANGE]\n ➔ Perubahan warna di " .. data.ParentName)
                    end
                end
            end
            
            if #anomaliesFound > 0 then
                OutputText.Text = "[!] ANOMALI TERDETEKSI:\n\n" .. table.concat(anomaliesFound, "\n\n")
            else
                OutputText.Text = "[✓] Aman. Belum ada anomali yang cocok dengan kategori."
            end
        end
    end
end)

-- 4. AUTO-RELOAD COMMAND (/reload di chat game)
player.Chatted:Connect(function(msg)
    if msg == "/reload" then
        print("[AutoReload] Mereload script...")
        pcall(function() ScreenGui:Destroy() end)
        loadstring(game:HttpGet("URL_RAW_GITHUB_KAMU_DISINI", true))()
    end
end)
