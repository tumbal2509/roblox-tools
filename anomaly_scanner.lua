-- ==========================================================
-- ANOMALY DETECTOR HELPER V2.0 (Advanced Observation Duty)
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
Frame.Size = UDim2.new(0, 340, 0, 420)
Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
Title.Text = "🚨 Anomaly Radar V2"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Tombol Close (Silang X)
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
SnapshotBtn.Position = UDim2.new(0, 10, 0, 55)
SnapshotBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SnapshotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SnapshotBtn.TextSize = 13
SnapshotBtn.Font = Enum.Font.GothamBold
SnapshotBtn.Text = "📸 1. Rekam Kondisi Normal (Start Shift)"
SnapshotBtn.Parent = Frame

local SnapshotCorner = Instance.new("UICorner")
SnapshotCorner.CornerRadius = UDim.new(0, 6)
SnapshotCorner.Parent = SnapshotBtn

-- Container Konten (Bisa disembunyikan saat minimize)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -95)
ContentContainer.Position = UDim2.new(0, 0, 0, 95)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Frame

-- Scrolling Frame untuk Hasil Deteksi Anomali
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

-- Fungsi Tombol Minimize & Close
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentContainer.Visible = not isMinimized
    if isMinimized then
        Frame.Size = UDim2.new(0, 340, 0, 55)
        MinBtn.Text = "+"
    else
        Frame.Size = UDim2.new(0, 340, 0, 420)
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 3. SISTEM PENCATATAN & DETEKSI ANOMALI TINGKAT LANJUT
local baselineData = {}
local isScanning = false

SnapshotBtn.MouseButton1Click:Connect(function()
    baselineData = {}
    local count = 0
    
    -- Rekam semua objek, termasuk yang transparan/tersembunyi
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            baselineData[obj] = {
                Parent = obj.Parent,
                Transparency = obj:IsA("BasePart") and obj.Transparency or 0,
                Position = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPrimaryPartCFrame().Position or Vector3.new(0,0,0))
            }
            count = count + 1
        end
    end
    
    isScanning = true
    OutputText.Text = "[✓] Berhasil merekam " .. count + " objek!\n[+] Memantau bayangan & perubahan visual..."
end)

-- Loop Cek Anomali (Mendeteksi kemunculan bayangan, objek baru, atau pergeseran)
task.spawn(function()
    while true do
        task.wait(1)
        if isScanning then
            local anomaliesFound = {}
            
            for obj, data in pairs(baselineData) do
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then
                        -- Cek Anomali Bayangan / Objek tiba-tiba muncul (Transparansi berubah dari 1 jadi 0 atau keliatan)
                        if data.Transparency > 0.5 and obj.Transparency < 0.5 then
                            table.insert(anomaliesFound, "👻 BAYANGAN/OBJEK MUNCUL: " .. obj.Name)
                        end
                        
                        -- Cek Pergeseran Posisi Objek (Object Relocation)
                        local dist = (obj.Position - data.Position).Magnitude
                        if dist > 4 then
                            table.insert(anomaliesFound, "⚠️ BERGESER: " .. obj.Name)
                        end
                    end
                end
            end
            
            if #anomaliesFound > 0 then
                OutputText.Text = "[!] ANOMALI TERDETEKSI:\n\n" .. table.concat(anomaliesFound, "\n")
            else
                OutputText.Text = "[✓] Aman. Belum ada anomali bayangan/pergerakan."
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
