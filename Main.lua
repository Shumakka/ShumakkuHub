-- Shumakku (DOORS)
-- By Shumakku
-- Telegram: https://t.me/MakeinuHub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Shumakku (DOORS)",
    LoadingTitle = "Загрузка Shumakku...",
    LoadingSubtitle = "TG: @MakeinuHub",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "DoorsCheats_Shumakku"
    }
})

local MainTab = Window:CreateTab("Основное", 4483362458)
local AuthorTab = Window:CreateTab("Автор", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ESPDoors = false
local ESPKeys = false
local ESPItems = false
local ESPLevers = false
local ESPMonsters = false
local ESPPlayers = false
local ESPBooks = false
local ESPWardrobes = false
local MonsterNotify = false
local SeekNotify = false

local fullbrightConn = nil
local fovConn = nil
local speedConn = nil
local monsterNotifyConn = nil
local seekNotifyConn = nil

local monsterNames = {"RushMoving", "AmbushMoving", "Eyes", "Halt", "SeekMoving", "A60", "A120"}

-- ИЗМЕНЕНО: русские названия предметов
local itemNames = {
    ["Crucifix"] = "Распятие",
    ["Flashlight"] = "Фонарик",
    ["Lighter"] = "Зажигалка",
    ["Lockpick"] = "Отмычка",
    ["SkeletonKey"] = "Скелет-ключ",
    ["Battery"] = "Батарейка",
    ["Vitamins"] = "Витамины",
    ["Smoothie"] = "Смузи",
    ["Candle"] = "Свеча",
    ["Bandage"] = "Бандаж",
    ["GlowStick"] = "Светящаяся палка",
    ["Glowstick"] = "Светящаяся палка"
}

-- Цвета для разных типов предметов
local itemColors = {
    ["Crucifix"] = Color3.fromRGB(255, 215, 0),    -- Золотой
    ["Flashlight"] = Color3.fromRGB(255, 255, 0),   -- Желтый
    ["Lighter"] = Color3.fromRGB(255, 165, 0),      -- Оранжевый
    ["Lockpick"] = Color3.fromRGB(192, 192, 192),   -- Серебряный
    ["SkeletonKey"] = Color3.fromRGB(255, 255, 255), -- Белый
    ["Battery"] = Color3.fromRGB(50, 205, 50),      -- Лаймовый
    ["Vitamins"] = Color3.fromRGB(255, 105, 180),   -- Розовый
    ["Smoothie"] = Color3.fromRGB(255, 20, 147),    -- Глубокий розовый
    ["Candle"] = Color3.fromRGB(255, 140, 0),       -- Темно-оранжевый
    ["Bandage"] = Color3.fromRGB(255, 255, 255),    -- Белый
    ["GlowStick"] = Color3.fromRGB(0, 255, 0),      -- Ярко-зеленый
    ["Glowstick"] = Color3.fromRGB(0, 255, 0),      -- Ярко-зеленый
    ["UsedGlowStick"] = Color3.fromRGB(139, 69, 19), -- Коричневый (использованный)
    ["UsedGlowstick"] = Color3.fromRGB(139, 69, 19)  -- Коричневый (использованный)
}

local defaultFOV = 70
local defaultSpeed = 15
local currentFOV = defaultFOV
local currentSpeed = defaultSpeed
local seekChaseSpeed = 23

local trackedBooks = {}
local trackedFigure50 = nil
local trackedFigure100 = nil
local trackedWardrobes = {}
local trackedKeys = {}
local trackedLevers = {}

local function playAlertSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://124951621656853"
        sound.Volume = 1
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end)
end

local function createESP(part, color, name, sizeMultiplier, showText)
    if not part or not part:IsA("BasePart") then return end
    sizeMultiplier = sizeMultiplier or 1
    showText = showText == nil and true or showText
    pcall(function()
        if part:FindFirstChild("ESPBox") then part.ESPBox:Destroy() end
        if part:FindFirstChild("ESPBillboard") then part.ESPBillboard:Destroy() end
        
        local boxSize = Vector3.new(
            math.max(part.Size.X, part.Size.Y, part.Size.Z) * sizeMultiplier,
            math.max(part.Size.X, part.Size.Y, part.Size.Z) * sizeMultiplier,
            math.max(part.Size.X, part.Size.Y, part.Size.Z) * sizeMultiplier
        )
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Parent = part
        box.Adornee = part
        box.Size = boxSize
        box.Color3 = color
        box.Transparency = 0.3
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Visible = true
        
        if showText and name and name ~= "" then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPBillboard"
            billboard.Parent = part
            billboard.Adornee = part
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = billboard
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = name
            textLabel.TextColor3 = color
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.new(0,0,0)
        end
    end)
end

local function removeESP(part)
    pcall(function()
        if part:FindFirstChild("ESPBox") then part.ESPBox:Destroy() end
        if part:FindFirstChild("ESPBillboard") then part.ESPBillboard:Destroy() end
    end)
end

-- НОВАЯ функция для поиска glowstick в шахтах
local function findGlowsticks()
    if not ESPItems then return end
    
    local mines = Workspace:FindFirstChild("Mines") or Workspace:FindFirstChild("TheMines")
    if not mines then return end
    
    -- Поиск светящихся палок
    for _, child in pairs(mines:GetDescendants()) do
        if child:IsA("Model") then
            local nameLower = child.Name:lower()
            
            -- Поиск неиспользованных glowstick
            if nameLower:find("glowstick") or nameLower:find("glow stick") then
                if not nameLower:find("used") then
                    local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                    if part and not part:FindFirstChild("ESPBox") then
                        local color = itemColors["GlowStick"] or Color3.fromRGB(0, 255, 0)
                        createESP(part, color, "Светящаяся палка", 1)
                    end
                end
            end
            
            -- Поиск использованных glowstick (тускло коричневые)
            if nameLower:find("usedglowstick") or nameLower:find("used glow stick") or 
               (nameLower:find("glowstick") and nameLower:find("used")) then
                local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                if part and not part:FindFirstChild("ESPBox") then
                    createESP(part, Color3.fromRGB(139, 69, 19), "Исп. свет. палка", 0.8)
                end
            end
        end
        
        -- Поиск отдельных частей (на случай если это не модель)
        if child:IsA("BasePart") and (child.Name:lower():find("glowstick") or child.Name:lower():find("glow stick")) then
            if not child:FindFirstChild("ESPBox") then
                if child.Name:lower():find("used") then
                    createESP(child, Color3.fromRGB(139, 69, 19), "Исп. свет. палка", 0.8)
                else
                    createESP(child, Color3.fromRGB(0, 255, 0), "Светящаяся палка", 1)
                end
            end
        end
    end
end

local function findBooks()
    if not ESPBooks then
        for _, part in pairs(trackedBooks) do removeESP(part) end
        trackedBooks = {}
        return
    end
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    local room50 = currentRooms:FindFirstChild("50")
    if room50 then
        local assets = room50:FindFirstChild("Assets")
        if assets then
            for _, bookshelf in pairs(assets:GetChildren()) do
                if bookshelf.Name:find("Bookshelves") then
                    for _, item in pairs(bookshelf:GetChildren()) do
                        local liveHintBook = item:FindFirstChild("LiveHintBook")
                        if liveHintBook then
                            local base = liveHintBook:FindFirstChild("Base")
                            if base and base:IsA("BasePart") and not base:FindFirstChild("ESPBox") then
                                createESP(base, Color3.fromRGB(255, 255, 0), "", 1, false)
                                table.insert(trackedBooks, base)
                            end
                        end
                    end
                end
            end
        end
    end
    local room100 = currentRooms:FindFirstChild("100")
    if room100 then
        for _, child in pairs(room100:GetChildren()) do
            local base = child:FindFirstChild("Base")
            if base and base:IsA("BasePart") and not base:FindFirstChild("ESPBox") then
                createESP(base, Color3.fromRGB(255, 255, 0), "", 1, false)
                table.insert(trackedBooks, base)
            end
        end
    end
end

local function findFigure()
    if not ESPMonsters then
        if trackedFigure50 then removeESP(trackedFigure50); trackedFigure50 = nil end
        if trackedFigure100 then removeESP(trackedFigure100); trackedFigure100 = nil end
        return
    end
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    local room50 = currentRooms:FindFirstChild("50")
    if room50 then
        local figureSetup = room50:FindFirstChild("FigureSetup")
        if figureSetup then
            local figureRig = figureSetup:FindFirstChild("FigureRig")
            if figureRig then
                local hitbox = figureRig:FindFirstChild("Hitbox")
                if hitbox and hitbox:IsA("BasePart") and not hitbox:FindFirstChild("ESPBox") then
                    createESP(hitbox, Color3.fromRGB(255, 0, 0), "Монстр: Figure")
                    trackedFigure50 = hitbox
                end
            end
        end
    end
    local room100 = currentRooms:FindFirstChild("100")
    if room100 then
        local figureSetup = room100:FindFirstChild("FigureSetup")
        if figureSetup then
            local figureRig = figureSetup:FindFirstChild("FigureRig")
            if figureRig then
                local hitbox = figureRig:FindFirstChild("Hitbox")
                if hitbox and hitbox:IsA("BasePart") and not hitbox:FindFirstChild("ESPBox") then
                    createESP(hitbox, Color3.fromRGB(255, 0, 0), "Монстр: Figure")
                    trackedFigure100 = hitbox
                end
            end
        end
    end
end

local function findWardrobes()
    if not ESPWardrobes then
        for _, part in pairs(trackedWardrobes) do removeESP(part) end
        trackedWardrobes = {}
        return
    end
    
    local function deepSearch(container, depth)
        if depth > 5 then return end
        
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("Model") then
                local nameLower = child.Name:lower()
                if nameLower:find("wardrobe") or 
                   nameLower:find("closet") or 
                   nameLower:find("шкаф") or 
                   nameLower:find("cabinet") or
                   nameLower:find("shkaf") then
                    
                    local main = child:FindFirstChild("Main") or 
                                child:FindFirstChild("Handle") or 
                                child:FindFirstChild("Part") or
                                child:FindFirstChildWhichIsA("BasePart")
                    
                    if main and main:IsA("BasePart") and not main:FindFirstChild("ESPBox") then
                        createESP(main, Color3.fromRGB(224, 145, 76), "Шкаф")
                        table.insert(trackedWardrobes, main)
                    end
                end
            end
            deepSearch(child, depth + 1)
        end
    end
    
    deepSearch(Workspace, 0)
    
    local locationsToCheck = {
        Workspace:FindFirstChild("CurrentRooms"),
        Workspace:FindFirstChild("Mines"),
        Workspace:FindFirstChild("TheMines"),
        Workspace:FindFirstChild("Outdoors"),
        Workspace:FindFirstChild("TheOutdoors"),
        Workspace:FindFirstChild("Rooms"),
        Workspace:FindFirstChild("TheRooms"),
        Workspace:FindFirstChild("Backdoors"),
        Workspace:FindFirstChild("TheBackdoors")
    }
    
    for _, location in pairs(locationsToCheck) do
        if location then
            deepSearch(location, 0)
        end
    end
end

local function findKeys()
    if not ESPKeys then
        for _, part in pairs(trackedKeys) do removeESP(part) end
        trackedKeys = {}
        return
    end
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    for _, room in pairs(currentRooms:GetChildren()) do
        local assets = room:FindFirstChild("Assets")
        if assets then
            local keyObtain = assets:FindFirstChild("KeyObtain")
            if keyObtain then
                local hitbox = keyObtain:FindFirstChild("Hitbox")
                if hitbox and hitbox:IsA("BasePart") and not hitbox:FindFirstChild("ESPBox") then
                    createESP(hitbox, Color3.fromRGB(255, 255, 0), "Ключ", 0.5)
                    table.insert(trackedKeys, hitbox)
                end
            end
            for _, child in pairs(assets:GetDescendants()) do
                if child.Name == "KeyObtain" and child:IsA("Model") then
                    local hitbox = child:FindFirstChild("Hitbox")
                    if hitbox and hitbox:IsA("BasePart") and not hitbox:FindFirstChild("ESPBox") then
                        createESP(hitbox, Color3.fromRGB(255, 255, 0), "Ключ", 0.5)
                        table.insert(trackedKeys, hitbox)
                    end
                end
            end
        end
    end
end

local function findLevers()
    if not ESPLevers then
        for _, part in pairs(trackedLevers) do removeESP(part) end
        trackedLevers = {}
        return
    end
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    for _, room in pairs(currentRooms:GetChildren()) do
        local assets = room:FindFirstChild("Assets")
        if assets then
            local leverForGate = assets:FindFirstChild("LeverForGate")
            if leverForGate then
                local main = leverForGate:FindFirstChild("Main")
                if main and main:IsA("BasePart") and not main:FindFirstChild("ESPBox") then
                    createESP(main, Color3.fromRGB(255, 165, 0), "Рычаг")
                    table.insert(trackedLevers, main)
                end
            end
        end
    end
end

local function updateESP()
    while true do
        pcall(function()
            local currentRooms = Workspace:FindFirstChild("CurrentRooms")
            if not currentRooms then return end
            if ESPDoors then
                for _, room in pairs(currentRooms:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and door.PrimaryPart and not door.PrimaryPart:FindFirstChild("ESPBox") then
                        local roomNum = tonumber(room.Name) or 0
                        createESP(door.PrimaryPart, Color3.fromRGB(100, 255, 100), tostring(roomNum + 1), 1)
                    end
                end
            else
                for _, room in pairs(currentRooms:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and door.PrimaryPart then removeESP(door.PrimaryPart) end
                end
            end
            
            -- ИЗМЕНЕНО: предметы с русскими названиями и индивидуальными цветами
            if ESPItems then
                for _, room in pairs(currentRooms:GetChildren()) do
                    for _, descendant in pairs(room:GetDescendants()) do
                        if descendant:IsA("Model") then
                            for engName, rusName in pairs(itemNames) do
                                if descendant.Name == engName then
                                    local part = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart")
                                    if part and not part:FindFirstChild("ESPBox") then
                                        local color = itemColors[engName] or Color3.fromRGB(128, 128, 0)
                                        createESP(part, color, rusName, 1)
                                    end
                                end
                            end
                        end
                    end
                end
                -- Поиск glowstick в шахтах
                pcall(findGlowsticks)
            else
                for _, room in pairs(currentRooms:GetChildren()) do
                    for _, descendant in pairs(room:GetDescendants()) do
                        if descendant:IsA("Model") then
                            for engName, _ in pairs(itemNames) do
                                if descendant.Name == engName then
                                    local part = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart")
                                    if part then removeESP(part) end
                                end
                            end
                        end
                    end
                end
            end
        end)
        pcall(findBooks)
        pcall(findFigure)
        pcall(findWardrobes)
        pcall(findKeys)
        pcall(findLevers)
        pcall(function()
            if ESPMonsters then
                for _, monster in pairs(Workspace:GetChildren()) do
                    if monster:IsA("Model") and table.find(monsterNames, monster.Name) then
                        local part = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildWhichIsA("BasePart")
                        if part and not part:FindFirstChild("ESPBox") then
                            createESP(part, Color3.fromRGB(255, 0, 0), "Монстр: " .. monster.Name)
                        end
                    end
                end
            else
                for _, monster in pairs(Workspace:GetChildren()) do
                    if monster:IsA("Model") and table.find(monsterNames, monster.Name) then
                        local part = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildWhichIsA("BasePart")
                        if part then removeESP(part) end
                    end
                end
            end
        end)
        pcall(function()
            if ESPPlayers then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart and not player.Character.PrimaryPart:FindFirstChild("ESPBox") then
                        createESP(player.Character.PrimaryPart, Color3.fromRGB(0, 255, 255), player.Name)
                    end
                end
            else
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
                        removeESP(player.Character.PrimaryPart)
                    end
                end
            end
        end)
        wait(0.5)
    end
end

spawn(updateESP)

local function setupSeekNotification()
    if seekNotifyConn then seekNotifyConn:Disconnect() end
    
    seekNotifyConn = RunService.Heartbeat:Connect(function()
        local seekMoving = Workspace:FindFirstChild("SeekMoving")
        local seekChase = Workspace:FindFirstChild("SeekChase")
        
        if (seekMoving or seekChase) and SeekNotify then
            if not getgenv().lastSeekNotify or tick() - getgenv().lastSeekNotify > 10 then
                getgenv().lastSeekNotify = tick()
                playAlertSound()
                Rayfield:Notify({
                    Title = "СКРИТЧ АКТИВЕН!",
                    Content = "ВНИМАНИЕ: Скритч преследует тебя!",
                    Duration = 5,
                    Image = 4483362458
                })
            end
        end
    end)
end

-- Основное (читы)
MainTab:CreateToggle({
    Name = "Освещение",
    CurrentValue = false,
    Flag = "FullbrightV1",
    Callback = function(Value)
        if Value then
            fullbrightConn = RunService.Heartbeat:Connect(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 9e9
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.new(1,1,1)
                Lighting.Ambient = Color3.new(1,1,1)
                Lighting.ShadowSoftness = 0
            end)
        else
            if fullbrightConn then fullbrightConn:Disconnect(); fullbrightConn = nil end
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
            Lighting.Ambient = Color3.new(0.4,0.4,0.5)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Двери (ESP)",
    CurrentValue = false,
    Flag = "ESPDoorsV1",
    Callback = function(Value)
        ESPDoors = Value
    end,
})

MainTab:CreateToggle({
    Name = "Ключ (ESP)",
    CurrentValue = false,
    Flag = "ESPKeysV1",
    Callback = function(Value)
        ESPKeys = Value
        if not Value then
            for _, part in pairs(trackedKeys) do removeESP(part) end
            trackedKeys = {}
        end
    end,
})

MainTab:CreateToggle({
    Name = "Предметы (ESP)",
    CurrentValue = false,
    Flag = "ESPItemsV1",
    Callback = function(Value)
        ESPItems = Value
    end,
})

MainTab:CreateToggle({
    Name = "Рычаг (ESP)",
    CurrentValue = false,
    Flag = "ESPLeversV1",
    Callback = function(Value)
        ESPLevers = Value
        if not Value then
            for _, part in pairs(trackedLevers) do removeESP(part) end
            trackedLevers = {}
        end
    end,
})

MainTab:CreateToggle({
    Name = "Шкафы (ESP)",
    CurrentValue = false,
    Flag = "ESPWardrobesV1",
    Callback = function(Value)
        ESPWardrobes = Value
        if not Value then
            for _, part in pairs(trackedWardrobes) do removeESP(part) end
            trackedWardrobes = {}
        end
    end,
})

MainTab:CreateToggle({
    Name = "Книги/Предохранители (ESP)",
    CurrentValue = false,
    Flag = "ESPBooksV1",
    Callback = function(Value)
        ESPBooks = Value
        if not Value then
            for _, part in pairs(trackedBooks) do removeESP(part) end
            trackedBooks = {}
        end
    end,
})

MainTab:CreateToggle({
    Name = "Монстры (ESP)",
    CurrentValue = false,
    Flag = "ESPMonstersV1",
    Callback = function(Value)
        ESPMonsters = Value
        if not Value then
            if trackedFigure50 then removeESP(trackedFigure50); trackedFigure50 = nil end
            if trackedFigure100 then removeESP(trackedFigure100); trackedFigure100 = nil end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Оповещение о монстрах",
    CurrentValue = false,
    Flag = "MonsterNotifyV1",
    Callback = function(Value)
        MonsterNotify = Value
        if Value then
            monsterNotifyConn = Workspace.ChildAdded:Connect(function(child)
                if table.find(monsterNames, child.Name) then
                    playAlertSound()
                    Rayfield:Notify({
                        Title = "МОНСТР ПОЯВИЛСЯ!",
                        Content = "ВНИМАНИЕ: " .. child.Name .. " появился!",
                        Duration = 5,
                        Image = 4483362458
                    })
                end
            end)
        else
            if monsterNotifyConn then monsterNotifyConn:Disconnect(); monsterNotifyConn = nil end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Оповещение о скритче",
    CurrentValue = false,
    Flag = "SeekNotifyV1",
    Callback = function(Value)
        SeekNotify = Value
        if Value then
            setupSeekNotification()
        else
            if seekNotifyConn then seekNotifyConn:Disconnect(); seekNotifyConn = nil end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Другие игроки (ESP)",
    CurrentValue = false,
    Flag = "ESPPlayersV1",
    Callback = function(Value)
        ESPPlayers = Value
    end,
})

MainTab:CreateSlider({
    Name = "FOV",
    Range = {30, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = defaultFOV,
    Flag = "FOVV1",
    Callback = function(Value)
        currentFOV = Value
        if fovConn then fovConn:Disconnect() end
        local camera = Workspace.CurrentCamera
        fovConn = RunService.RenderStepped:Connect(function()
            camera.FieldOfView = currentFOV
        end)
    end,
})

MainTab:CreateSlider({
    Name = "Скорость (15-21)",
    Range = {15, 21},
    Increment = 1,
    Suffix = "",
    CurrentValue = defaultSpeed,
    Flag = "SpeedV1",
    Callback = function(Value)
        currentSpeed = Value
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local seekActive = Workspace:FindFirstChild("SeekMoving") ~= nil
                char.Humanoid.WalkSpeed = seekActive and seekChaseSpeed or currentSpeed
            end
        end)
    end,
})

MainTab:CreateButton({
    Name = "Вернуть FOV (70°)",
    Callback = function()
        currentFOV = defaultFOV
        if fovConn then fovConn:Disconnect(); fovConn = nil end
        Workspace.CurrentCamera.FieldOfView = defaultFOV
    end,
})

MainTab:CreateButton({
    Name = "Вернуть скорость (16)",
    Callback = function()
        currentSpeed = defaultSpeed
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = defaultSpeed
        end
    end,
})

-- Вкладка Автор (Telegram)
AuthorTab:CreateButton({
    Name = "Telegram канал",
    Callback = function()
        if setclipboard then
            setclipboard("https://t.me/MakeinuHub")
            Rayfield:Notify({
                Title = "Ссылка скопирована!",
                Content = "Ссылка на Telegram канал скопирована",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Буфер обмена не поддерживается",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    local char = LocalPlayer.Character
    if fovConn then
        Workspace.CurrentCamera.FieldOfView = currentFOV
    end
    if speedConn and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = currentSpeed
    end
end)

Rayfield:Notify({
    Title = "Shumakku (DOORS) готов!",
    Content = "TG: @MakeinuHub | Удачи!",
    Duration = 8,
    Image = 4483362458
})
