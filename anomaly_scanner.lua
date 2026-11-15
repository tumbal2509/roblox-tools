-- ==========================================================
-- ANOMALY DETECTOR HELPER V1.0 (Observation Duty Style)
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
Frame.Draggable = true -- Bisa digeser-geser di layar HP
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Text = "🚨 Anomaly Radar & Scanner"
Title.Parent = Frame

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

-- Scrolling Frame untuk Hasil Deteksi Anomali
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -155)
Scroll.Position = UDim2.new(0, 10, 0, 100)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Scroll.Parent = Frame

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

-- Tombol Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 35)
CloseBtn.Position = UDim2.new(0, 10, 1, -45)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "Tutup Helper"
CloseBtn.Parent = Frame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 3. SISTEM PENYIMPANAN BASELINE & DETEKSI
local baselineData = {}
local isScanning = false

SnapshotBtn.MouseButton1Click:Connect(function()
    baselineData = {}
    local count = 0
    
    -- Cari folder ruangan atau objek penting di Workspace
    for _, room in ipairs(Workspace:GetChildren()) do
        if room:IsA("Folder") or room:IsA("Model") then
            for _, obj in ipairs(room:GetDescendants()) do
                if obj:IsA("BasePart") then
                    baselineData[obj] = {
                        Position = obj.Position,
                        Parent = obj.Parent,
                        Transparency = obj.Transparency,
                        Color = obj.Color
                    }
                    count = count + 1
                end
            end
        end
    end
    
    isScanning = true
    OutputText.Text = "[✓] Berhasil merekam " .. count .. " objek normal!\n[+] Memantau anomali secara real-time..."
end)

-- Loop Cek Perubahan (Anomali) setiap detik
task.spawn(function()
    while true do
        task.wait(1.5)
        if isScanning then
            local anomaliesFound = {}
            
            for obj, data in pairs(baselineData) do
                if obj and obj.Parent then
                    -- Cek Pergeseran Posisi (Object Relocation)
                    local dist = (obj.Position - data.Position).Magnitude
                    if dist > 3.5 then -- Jika bergeser lebih dari 3.5 stud
                        table.insert(anomaliesFound, "⚠️ BERGESER: " .. obj.Name .. " (di " .. obj.Parent.Name .. ")")
                    end
                    
                    -- Cek Perubahan Warna/Lampu (Lighting Change)
                    if obj.Color ~= data.Color then
                        table.insert(anomaliesFound, "💡 LAMPU/WARNA BERUBAH: " .. obj.Name)
                    end
                else
                    -- Objek Hilang (Missing Object)
                    table.insert(anomaliesFound, "❌ HILANG: Objek tak dikenal")
                end
            end
            
            if #anomaliesFound > 0 then
                OutputText.Text = "[!] ANOMALI TERDETEKSI:\n\n" .. table.concat(anomaliesFound, "\n")
            else
                OutputText.Text = "[✓] Aman. Belum ada pergerakan/anomali terdeteksi."
            end
        end
    end
end)

-- 4. FITUR AUTO-RELOAD (Ketik /reload di chat game)
player.Chatted:Connect(function(msg)
    if msg == "/reload" then
        print("[AutoReload] Mereload Anomaly Scanner...")
        pcall(function() ScreenGui:Destroy() end)
        -- Ganti URL di bawah dengan link raw GitHub kamu yang terbaru
        loadstring(game:HttpGet("URL_RAW_GITHUB_KAMU_DISINI", true))()
    end
end)
