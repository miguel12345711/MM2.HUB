--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    Ruan MM2 Hub — V1.0                       ║
    ║                                                              ║
    ║   Sistema de Key + Menu Library                              ║
    ║   ESP, Chams, Tracers, Fullbright, Teleports, Farm, Misc     ║
    ║                                                              ║
    ║   Key: 123 Ruan                                              ║
    ║   Mobile Otimizado (Samsung A06)                             ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

--==============================================================
-- SERVIÇOS
--==============================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local viewport = workspace.CurrentCamera.ViewportSize

--==============================================================
-- GLOBAIS
--==============================================================
getgenv().Ruan = getgenv().Ruan or {}
getgenv().Ruan.Tabs = {}
getgenv().Ruan.FloatingButtons = {}
getgenv().Ruan.FloatingDraggers = {}
getgenv().Ruan.Highlights = {}
getgenv().Ruan.Tracers = {}
getgenv().Ruan.Connections = {}
getgenv().Ruan.Settings = {
    Key = "123 Ruan",
    Toggled = {
        ESP_Murderer = false,
        ESP_Sheriff = false,
        ESP_Innocent = false,
        ESP_Gun = false,
        ESP_Coins = false,
        ShowNames = false,
        Tracers = false,
        Chams = false,
        Fullbright = false,
        Crosshair = false,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        AntiAFK = false,
        AntiVoid = false,
        FPSBoost = false,
        AutoCoins = false,
    },
    Values = {
        WalkSpeed = 16,
        JumpPower = 50,
        FlySpeed = 80,
        CrosshairSize = 10,
    }
}

--==============================================================
-- UTILS
--==============================================================
local Utils = {}

function Utils.randomString(len)
    len = len or math.random(10, 20)
    local t = {}
    for i = 1, len do t[i] = string.char(math.random(32, 126)) end
    return table.concat(t)
end

function Utils.round(num, decimals)
    return tonumber(string.format("%." .. decimals .. "f", num))
end

function Utils.toBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, b2 = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b2 % 2^i - b2 % 2^(i-1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
        return b:sub(c+1, c+1)
    end) .. ({'', '==', '='})[#data % 3 + 1])
end

function Utils.fromBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function Utils.serializeUDim2(v)
    if typeof(v) == "UDim2" then
        return string.format("%g,%g,%g,%g", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
    elseif typeof(v) == "string" then
        local xs, xo, ys, yo = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
        if not xs then return UDim2.new(0,0,0,0) end
        return UDim2.new(tonumber(xs), tonumber(xo), tonumber(ys), tonumber(yo))
    end
end

function Utils.notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Ruan Hub",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

--==============================================================
-- POINTSAVE (salva configs)
--==============================================================
getgenv()._FOLDERS = getgenv()._FOLDERS or {}
getgenv()._FILES = getgenv()._FILES or {}

isfolder = isfolder or function(n) return getgenv()._FOLDERS[n] ~= nil end
makefolder = makefolder or function(n) getgenv()._FOLDERS[n] = {} return getgenv()._FOLDERS[n] end
isfile = isfile or function(n) return getgenv()._FILES[n] ~= nil end
writefile = writefile or function(n, c) getgenv()._FILES[n] = c return c end
readfile = readfile or function(n) return getgenv()._FILES[n] end
delfile = delfile or function(n) getgenv()._FILES[n] = nil end

local PointSave = {}
PointSave.__index = PointSave

function PointSave.new(ns)
    if not isfolder("RuanHub") then makefolder("RuanHub") end
    if not isfolder("RuanHub/" .. ns) then makefolder("RuanHub/" .. ns) end
    return setmetatable({path = "RuanHub/" .. ns}, PointSave)
end

function PointSave:set(k, v) writefile(self.path .. "/" .. k .. ".txt", tostring(v)) end
function PointSave:get(k)
    local p = self.path .. "/" .. k .. ".txt"
    if isfile(p) then return readfile(p) end
end
function PointSave:remove(k)
    local p = self.path .. "/" .. k .. ".txt"
    if isfile(p) then delfile(p) end
end

local Save = PointSave.new("Ruan")

--==============================================================
-- SISTEMA DE KEY
--==============================================================
local function checkKey()
    -- Verifica se já foi validada antes (salva)
    if Save:get("KeyValidated") == "true" then
        return true
    end
    return false
end

local function validateKey(input)
    input = tostring(input):gsub("^%s+", ""):gsub("%s+$", "")
    return input == "123 Ruan"
end

local function createKeyUI(callback)
    local gui = Instance.new("ScreenGui")
    gui.Name = Utils.randomString()
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        if gethui then gui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = CoreGui
        else gui.Parent = CoreGui end
    end)

    -- Fundo escurecido
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 0
    bg.Parent = gui

    -- Janela principal
    local win = Instance.new("Frame")
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.Size = UDim2.fromOffset(math.min(360, viewport.X - 40), 260)
    win.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    win.BorderSizePixel = 0
    win.Parent = gui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", win)
    stroke.Color = Color3.fromRGB(197, 0, 0)
    stroke.Thickness = 2

    local grad = Instance.new("UIGradient", win)
    grad.Color = ColorSequence.new(Color3.fromRGB(35,35,35), Color3.fromRGB(15,15,15))
    grad.Rotation = 68

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.fromOffset(0, 20)
    title.BackgroundTransparency = 1
    title.Text = "🔒 RUAN MM2 HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = win

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 24)
    sub.Position = UDim2.fromOffset(0, 70)
    sub.BackgroundTransparency = 1
    sub.Text = "Digite a key para continuar"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.TextColor3 = Color3.fromRGB(180, 180, 180)
    sub.Parent = win

    -- Caixa de texto
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -60, 0, 45)
    box.Position = UDim2.fromOffset(30, 110)
    box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = "Digite a key aqui..."
    box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.ClearTextOnFocus = false
    box.Parent = win
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local boxPad = Instance.new("UIPadding", box)
    boxPad.PaddingLeft = UDim.new(0, 12)
    boxPad.PaddingRight = UDim.new(0, 12)

    -- Botão confirmar
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -60, 0, 45)
    btn.Position = UDim2.fromOffset(30, 170)
    btn.BackgroundColor3 = Color3.fromRGB(197, 0, 0)
    btn.BorderSizePixel = 0
    btn.Text = "CONFIRMAR"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = win
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.fromOffset(0, 222)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Parent = win

    -- Função de validação
    local function attempt()
        if validateKey(box.Text) then
            status.Text = "✅ Key correta!"
            status.TextColor3 = Color3.fromRGB(0, 255, 100)
            Save:set("KeyValidated", "true")
            task.wait(0.8)
            gui:Destroy()
            if callback then callback() end
        else
            status.Text = "❌ Key incorreta. Tente novamente."
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            box.Text = ""
            -- Efeito de shake
            for _ = 1, 3 do
                box.Position = UDim2.fromOffset(25, 110)
                task.wait(0.05)
                box.Position = UDim2.fromOffset(35, 110)
                task.wait(0.05)
            end
            box.Position = UDim2.fromOffset(30, 110)
        end
    end

    btn.MouseButton1Click:Connect(attempt)
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then attempt() end
    end)
end

--==============================================================
-- VERIFICA E CHAMA
--==============================================================
if checkKey() then
    -- Key já validada, continua o script direto
    getgenv().Ruan.KeyValidated = true
else
    -- Precisa validar a key
    createKeyUI(function()
        getgenv().Ruan.KeyValidated = true
        Utils.notify("Ruan Hub", "Key validada! Script carregando...", 3)
    end)
    -- Aguarda a validação
    repeat task.wait(0.1) until getgenv().Ruan.KeyValidated
end

print("[Ruan Hub] Key validada com sucesso!")
--==============================================================
-- MENU LIBRARY BASE
--==============================================================
local RuanRoot, mainWindow, tabList, contentArea, selectedTab, activeTabButton

local ThemeManager = {
    textColor = Color3.fromRGB(255, 255, 255),
    accentColor = Color3.fromRGB(197, 0, 0),
    primaryColor = Color3.fromRGB(22, 22, 22),
    secondaryColor = Color3.fromRGB(12, 12, 12),
    successColor = Color3.fromRGB(0, 200, 100),
    warningColor = Color3.fromRGB(255, 200, 0),
}

local notifHolder
local notifIcons = {
    info = "rbxassetid://11780939099",
    x = "rbxassetid://10002373478",
    check = "rbxassetid://11604833061",
}

--==============================================================
-- NOTIFICAÇÕES
--==============================================================
local notifIncoming = false
local function Notify(msg, color, icon)
    if not notifHolder then return end
    notifIncoming = true
    task.spawn(function()
        local sample = notifHolder:FindFirstChild("NotificationSample")
        if not sample then return end
        local notif = sample:Clone()
        notif.Parent = notifHolder
        notif.Name = tostring(msg)
        notif.Position = UDim2.fromScale(0.5, -0.1)
        notif.UIScale.Scale = 0.7
        notif.Visible = true

        if color and typeof(color) == "Color3" then
            if notif:FindFirstChild("UIStroke") then notif.UIStroke.Color = color end
            if notif:FindFirstChild("ImageLabel") then notif.ImageLabel.ImageColor3 = color end
        end
        if icon and notifIcons[icon] then
            notif.ImageLabel.Image = notifIcons[icon]
        end

        notif.TextLabel.Text = tostring(msg)
        notif:SetAttribute("close", false)

        TS:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
            Position = UDim2.new(0.5, 0, 0, 10)
        }):Play()
        TS:Create(notif.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {
            Scale = 1
        }):Play()

        notif.Close.MouseButton1Click:Connect(function() notif:SetAttribute("close", true) end)

        task.wait()
        notifIncoming = false
        local t = os.clock()
        repeat task.wait() until os.clock() - t > 4 or notifIncoming or notif:GetAttribute("close")

        local fin = TS:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
            Position = UDim2.fromScale(0.5, -0.1)
        })
        fin:Play()
        fin.Completed:Connect(function() notif:Destroy() end)
    end)
end

--==============================================================
-- DRAGGABLE
--==============================================================
local DraggableObject = {}
DraggableObject.__index = DraggableObject

function DraggableObject.new(object, toMove)
    local self = setmetatable({}, DraggableObject)
    self.Object = object
    self.ToMove = toMove or object
    self.Dragging = false
    return self
end

function DraggableObject:Enable()
    local obj = self.Object
    local target = self.ToMove
    local lastPos, currentPos, isDragging

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if obj.Parent == nil then return end
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            if not lastPos then
                lastPos = input.Position
                currentPos = target.Position
                self.Dragging = true
            end
            local delta = input.Position - lastPos
            target.Position = UDim2.new(
                currentPos.X.Scale, currentPos.X.Offset + delta.X,
                currentPos.Y.Scale, currentPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            self.Dragging = false
            lastPos = nil
        end
    end)
end

--==============================================================
-- HELPERS UI
--==============================================================
local function makeFrame(props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k, v in pairs(props or {}) do f[k] = v end
    return f
end

local function makeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end

local function makeButton(props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    for k, v in pairs(props or {}) do b[k] = v end
    return b
end

--==============================================================
-- BUILD UI
--==============================================================
local function buildUI()
    RuanRoot = Instance.new("ScreenGui")
    RuanRoot.Name = Utils.randomString()
    RuanRoot.IgnoreGuiInset = true
    RuanRoot.ResetOnSpawn = false
    RuanRoot.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RuanRoot.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets

    pcall(function()
        if gethui then RuanRoot.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(RuanRoot); RuanRoot.Parent = CoreGui
        else RuanRoot.Parent = CoreGui end
    end)
    getgenv().Ruan.Root = RuanRoot

    local winWidth = math.min(420, viewport.X - 40)
    local winHeight = math.min(400, viewport.Y * 0.6)

    mainWindow = makeFrame({
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, -0.6),
        Size = UDim2.fromOffset(winWidth, winHeight),
        BackgroundColor3 = ThemeManager.primaryColor,
    })
    mainWindow.Parent = RuanRoot
    Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", mainWindow)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2

    local grad = Instance.new("UIGradient", mainWindow)
    grad.Color = ColorSequence.new(Color3.fromRGB(35,35,35), Color3.fromRGB(15,15,15))
    grad.Rotation = 68

    -- HEADER
    local header = makeFrame({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
    })
    header.Parent = mainWindow

    local title = makeLabel({
        Name = "Title",
        Text = "Ruan Hub",
        Font = Enum.Font.GothamBold,
        TextSize = 19,
        TextColor3 = ThemeManager.textColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
    })
    title.Parent = header

    local version = makeLabel({
        Name = "Version",
        Text = "MM2 v1.0",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(0.4, 0, 0, 0),
        Size = UDim2.new(0.35, 0, 1, 0),
    })
    version.Parent = header

    -- Botão minimizar
    local minBtn = makeButton({
        Name = "Minimize",
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = ThemeManager.textColor,
        BackgroundColor3 = ThemeManager.secondaryColor,
        Position = UDim2.new(1, -95, 0, 6),
        Size = UDim2.fromOffset(40, 38),
    })
    minBtn.Parent = header
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

    -- Botão fechar
    local closeBtn = makeButton({
        Name = "Close",
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        BackgroundColor3 = ThemeManager.secondaryColor,
        Position = UDim2.new(1, -50, 0, 6),
        Size = UDim2.fromOffset(40, 38),
    })
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseButton1Click:Connect(function()
        getgenv().Ruan:Unload()
    end)
    minBtn.MouseButton1Click:Connect(function()
        getgenv().Ruan:Minimize()
    end)

    -- LISTA DE ABAS
    local listWidth = 120

    tabList = makeFrame({
        Name = "TabList",
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(0, listWidth, 1, -72),
        BackgroundColor3 = ThemeManager.secondaryColor,
    })
    tabList.Parent = mainWindow
    Instance.new("UICorner", tabList).CornerRadius = UDim.new(0, 12)

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Size = UDim2.fromScale(1, 1)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 4
    tabScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.Parent = tabList

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPad = Instance.new("UIPadding", tabScroll)
    tabPad.PaddingTop = UDim.new(0, 8)
    tabPad.PaddingBottom = UDim.new(0, 8)
    tabPad.PaddingLeft = UDim.new(0, 4)
    tabPad.PaddingRight = UDim.new(0, 4)

    getgenv().Ruan.TabScroll = tabScroll

    -- ÁREA DE CONTEÚDO
    contentArea = makeFrame({
        Name = "Content",
        Position = UDim2.new(0, listWidth + 18, 0, 60),
        Size = UDim2.new(1, -(listWidth + 28), 1, -72),
        BackgroundTransparency = 1,
    })
    contentArea.Parent = mainWindow

    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "ContentScroll"
    contentScroll.Size = UDim2.fromScale(1, 1)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 4
    contentScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.Parent = contentArea

    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPad = Instance.new("UIPadding", contentScroll)
    contentPad.PaddingRight = UDim.new(0, 6)
    contentPad.PaddingBottom = UDim.new(0, 10)

    getgenv().Ruan.ContentScroll = contentScroll

    -- DRAG
    local drag = DraggableObject.new(header, mainWindow)
    drag:Enable()

    -- Animação entrada
    TS:Create(mainWindow, TweenInfo.new(0.8, Enum.EasingStyle.Cubic), {
        Position = UDim2.fromScale(0.5, 0.05)
    }):Play()

    -- NOTIFICAÇÕES
    notifHolder = makeFrame({
        Name = "NotificationHolder",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0.98, 0),
        Size = UDim2.new(0.95, 0, 0.5, 0),
        BackgroundTransparency = 1,
    })
    notifHolder.Parent = RuanRoot

    local nhLayout = Instance.new("UIListLayout", notifHolder)
    nhLayout.Padding = UDim.new(0, 8)
    nhLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nhLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    nhLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local sample = makeFrame({
        Name = "NotificationSample",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(1, -30, 0, 60),
        BackgroundColor3 = ThemeManager.primaryColor,
        ClipsDescendants = true,
        Visible = false,
    })
    sample.Parent = notifHolder
    Instance.new("UICorner", sample).CornerRadius = UDim.new(0, 12)
    local sStroke = Instance.new("UIStroke", sample)
    sStroke.Color = Color3.fromRGB(255, 255, 255)
    sStroke.Thickness = 2
    local sGrad = Instance.new("UIGradient", sample)
    sGrad.Color = ColorSequence.new(Color3.fromRGB(46,46,46), Color3.fromRGB(12,12,12))

    local sImg = Instance.new("ImageLabel", sample)
    sImg.Name = "ImageLabel"
    sImg.Image = notifIcons.info
    sImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
    sImg.BackgroundTransparency = 1
    sImg.AnchorPoint = Vector2.new(0.5, 0.5)
    sImg.Position = UDim2.new(0.12, 0, 0.5, 0)
    sImg.Size = UDim2.new(0.1, 0, 0.55, 0)

    local sText = makeLabel({
        Name = "TextLabel",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextScaled = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.55, 0, 0.6, 0),
    })
    sText.Parent = sample

    local sClose = Instance.new("ImageButton", sample)
    sClose.Name = "Close"
    sClose.Image = notifIcons.x
    sClose.BackgroundTransparency = 1
    sClose.AnchorPoint = Vector2.new(0.5, 0.5)
    sClose.Position = UDim2.new(0.9, 0, 0.5, 0)
    sClose.Size = UDim2.new(0.1, 0, 0.5, 0)

    -- BOTÃO FLUTUANTE "R" (mobile)
    local minimizedButton = makeButton({
        Name = "MinimizedBtn",
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromOffset(15, 80),
        Size = UDim2.fromOffset(65, 65),
        BackgroundColor3 = ThemeManager.accentColor,
        Text = "R",
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Visible = false,
        ZIndex = 20,
    })
    minimizedButton.Parent = RuanRoot
    Instance.new("UICorner", minimizedButton).CornerRadius = UDim.new(1, 0)
    local mbStroke = Instance.new("UIStroke", minimizedButton)
    mbStroke.Color = Color3.fromRGB(255, 255, 255)
    mbStroke.Thickness = 2.5

    minimizedButton.MouseButton1Click:Connect(function()
        getgenv().Ruan:Open()
    end)

    local mbDrag = DraggableObject.new(minimizedButton)
    mbDrag:Enable()
    getgenv().Ruan.MinBtn = minimizedButton
end

--==============================================================
-- CONTROLE DE JANELA
--==============================================================
local function openMenu()
    if not mainWindow then return end
    mainWindow.Visible = true
    if getgenv().Ruan.MinBtn then getgenv().Ruan.MinBtn.Visible = false end
    TS:Create(mainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.5, 0.05),
    }):Play()
end

local function minimizeMenu()
    if not mainWindow then return end
    mainWindow.Visible = false
    if getgenv().Ruan.MinBtn then
        getgenv().Ruan.MinBtn.Visible = true
    end
end

local function unloadMenu()
    for _, conn in pairs(getgenv().Ruan.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if RuanRoot then
        TS:Create(mainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
            Position = UDim2.fromScale(0.5, -0.6)
        }):Play()
        task.wait(0.4)
        RuanRoot:Destroy()
    end
    getgenv().Ruan.Tabs = {}
    getgenv().Ruan.Root = nil
    Utils.notify("Ruan Hub", "Script descarregado.", 3)
end

--==============================================================
-- CLASSE TAB
--==============================================================
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Elements = {}
    self.Button = nil

    local btn = makeButton({
        Name = name .. "Btn",
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = ThemeManager.textColor,
        BackgroundColor3 = ThemeManager.primaryColor,
        Size = UDim2.new(1, 0, 0, 42),
        TextWrapped = true,
    })
    btn.Parent = getgenv().Ruan.TabScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    self.Button = btn
    btn.MouseButton1Click:Connect(function() self:Select() end)

    table.insert(getgenv().Ruan.Tabs, self)

    if #getgenv().Ruan.Tabs == 1 then
        task.defer(function() self:Select() end)
    end

    return self
end

function Tab:Select()
    if activeTabButton and activeTabButton.Button then
        TS:Create(activeTabButton.Button, TweenInfo.new(0.25), {
            BackgroundColor3 = ThemeManager.primaryColor
        }):Play()
    end
    activeTabButton = self
    selectedTab = self
    TS:Create(self.Button, TweenInfo.new(0.25), {
        BackgroundColor3 = ThemeManager.accentColor
    }):Play()
    self:Refresh()
end

function Tab:Refresh()
    local scroll = getgenv().Ruan.ContentScroll
    if not scroll then return end
    for _, v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
            v:Destroy()
        end
    end
    for _, el in ipairs(self.Elements) do
        if el.Builder then pcall(el.Builder, scroll) end
    end
end

function Tab:Clear()
    self.Elements = {}
    self:Refresh()
end

--==============================================================
-- ELEMENTOS DA TAB
--==============================================================

function Tab:AddText(text)
    local builder = function(parent)
        local lbl = makeLabel({
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = ThemeManager.textColor,
            TextWrapped = true,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        lbl.Parent = parent
    end
    table.insert(self.Elements, {Builder = builder, Type = "Text"})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
end

function Tab:AddSection(text)
    return self:AddText("─── " .. text .. " ───")
end

function Tab:AddButton(text, callback)
    local builder = function(parent)
        local btn = makeButton({
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = ThemeManager.textColor,
            BackgroundColor3 = ThemeManager.primaryColor,
            Size = UDim2.new(1, 0, 0, 42),
            TextWrapped = true,
        })
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local pad = Instance.new("UIPadding", btn)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)

        btn.MouseButton1Click:Connect(function()
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[Ruan] Erro:", err) end
            end
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Button"})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
end

function Tab:AddToggle(text, default, callback)
    local state = default or false
    local setState
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = ThemeManager.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Size = UDim2.new(0.62, 0, 1, 0),
        })
        lbl.Parent = container

        local switchBg = makeFrame({
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(58, 30),
            BackgroundColor3 = state and ThemeManager.accentColor or Color3.fromRGB(60, 60, 60),
        })
        switchBg.Parent = container
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

        local knob = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 2,
        })
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local clickBtn = makeButton({
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 3,
        })
        clickBtn.Parent = container

        setState = function(newState, fire)
            state = newState
            TS:Create(switchBg, TweenInfo.new(0.2), {
                BackgroundColor3 = state and ThemeManager.accentColor or Color3.fromRGB(60, 60, 60)
            }):Play()
            TS:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0)
            }):Play()
            if fire and callback then pcall(callback, state) end
        end

        clickBtn.MouseButton1Click:Connect(function() setState(not state, true) end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Toggle"})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
    return {
        SetValue = function(v) if setState then setState(v, false) end end,
        GetValue = function() return state end,
    }
end

function Tab:AddSlider(text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = default or min
    local value = default
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 72),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = ThemeManager.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7, 0, 0, 22),
        })
        lbl.Parent = container

        local valueLbl = makeLabel({
            Text = tostring(value),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = ThemeManager.accentColor,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size = UDim2.new(0.3, 0, 0, 22),
            Position = UDim2.new(0.7, 0, 0, 0),
        })
        valueLbl.Parent = container

        local track = makeFrame({
            Position = UDim2.new(0, 0, 0, 46),
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        })
        track.Parent = container
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = makeFrame({
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = ThemeManager.accentColor,
        })
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 2,
        })
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local clickArea = makeButton({
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 5,
        })
        clickArea.Parent = track

        local dragging = false
        local function update(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            valueLbl.Text = tostring(value)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            if callback then pcall(callback, value) end
        end

        clickArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
                update(input.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Slider"})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
    return {
        SetValue = function(v) value = math.clamp(v, min, max) end,
        GetValue = function() return value end,
    }
end

--==============================================================
-- API PÚBLICA BÁSICA
--==============================================================
function getgenv().Ruan:CreateTab(name) return Tab.new(name) end
function getgenv().Ruan:Open() openMenu() end
function getgenv().Ruan:Minimize() minimizeMenu() end
function getgenv().Ruan:Unload() unloadMenu() end
function getgenv().Ruan:Notify(msg, color, icon) Notify(msg, color, icon) end

function getgenv().Ruan:Init()
    buildUI()
    Utils.notify("Ruan Hub", "Menu carregado!", 3)
end

getgenv().Ruan:Init()

print("[Ruan Hub] Menu Library carregada.")
--==============================================================
-- ================== ABA VISUAL (ESP, CHAMS, ETC) =============
--==============================================================

--==============================================================
-- FUNÇÕES AUXILIARES DE ESP
--==============================================================
local function getRole(player)
    if not player or not player.Character then return nil end
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")

    if (char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if (char:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" then return p end
    end
end

local function findSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Sheriff" then return p end
    end
end

--==============================================================
-- CORES
--==============================================================
local COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 150, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    Gun = Color3.fromRGB(255, 255, 0),
    Coin = Color3.fromRGB(255, 200, 0),
}

--==============================================================
-- HIGHLIGHT BASE
--==============================================================
local function addHighlight(char, color, name)
    if not char then return end
    local old = char:FindFirstChild(name)
    if old then old:Destroy() end

    local h = Instance.new("Highlight")
    h.Name = name
    h.Adornee = char
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    return h
end

--==============================================================
-- LOOP PRINCIPAL DE ESP
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        local toggled = getgenv().Ruan.Settings.Toggled

        -- Limpa highlights antigos se necessário
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character

                -- Remove tudo
                for _, h in ipairs(char:GetChildren()) do
                    if h.Name:match("^RuanESP_") then
                        -- Vai ser recriado abaixo se ativo
                        local shouldExist = false
                        local role = getRole(p)
                        if toggled.ESP_Murderer and role == "Murderer" then shouldExist = true end
                        if toggled.ESP_Sheriff and role == "Sheriff" then shouldExist = true end
                        if toggled.ESP_Innocent and role == "Innocent" then shouldExist = true end
                        if not shouldExist then h:Destroy() end
                    end
                end

                -- Cria highlights ativos
                local role = getRole(p)
                if toggled.ESP_Murderer and role == "Murderer" then
                    addHighlight(char, COLORS.Murderer, "RuanESP_Murderer")
                end
                if toggled.ESP_Sheriff and role == "Sheriff" then
                    addHighlight(char, COLORS.Sheriff, "RuanESP_Sheriff")
                end
                if toggled.ESP_Innocent and role == "Innocent" then
                    addHighlight(char, COLORS.Innocent, "RuanESP_Innocent")
                end
            end
        end

        -- ESP de arma caída (procura workspace por GunDrop ou similar)
        if toggled.ESP_Gun then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "GunDrop" or obj.Name == "DroppedGun" then
                    if not obj:FindFirstChild("RuanESP_Gun") then
                        local h = Instance.new("Highlight")
                        h.Name = "RuanESP_Gun"
                        h.Adornee = obj
                        h.FillColor = COLORS.Gun
                        h.OutlineColor = COLORS.Gun
                        h.FillTransparency = 0.3
                        h.OutlineTransparency = 0
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                    end
                end
            end
        else
            for _, obj in ipairs(workspace:GetDescendants()) do
                local h = obj:FindFirstChild("RuanESP_Gun")
                if h then h:Destroy() end
            end
        end

        -- ESP de moedas
        if toggled.ESP_Coins then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Coin" or obj.Name == "Coin_Server" or obj.Name == "CoinVisual" then
                    if not obj:FindFirstChild("RuanESP_Coin") and obj:IsA("BasePart") then
                        local h = Instance.new("Highlight")
                        h.Name = "RuanESP_Coin"
                        h.Adornee = obj
                        h.FillColor = COLORS.Coin
                        h.OutlineColor = COLORS.Coin
                        h.FillTransparency = 0.4
                        h.OutlineTransparency = 0
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                    end
                end
            end
        else
            for _, obj in ipairs(workspace:GetDescendants()) do
                local h = obj:FindFirstChild("RuanESP_Coin")
                if h then h:Destroy() end
            end
        end
    end
end)

--==============================================================
-- NOMES EM CIMA DA CABEÇA
--==============================================================
local nameHolder = nil
local function createNameTag(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    local head = player.Character.Head
    local old = head:FindFirstChild("RuanName")
    if old then old:Destroy() end

    local role = getRole(player)
    local color = COLORS.Innocent
    if role == "Murderer" then color = COLORS.Murderer
    elseif role == "Sheriff" then color = COLORS.Sheriff end

    local bg = Instance.new("BillboardGui")
    bg.Name = "RuanName"
    bg.Size = UDim2.new(0, 200, 0, 30)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.Text = player.Name .. " [" .. role .. "]"
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.Parent = bg
end

local function removeAllNameTags()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local old = p.Character.Head:FindFirstChild("RuanName")
            if old then old:Destroy() end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().Ruan.Settings.Toggled.ShowNames then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    createNameTag(p)
                end
            end
        else
            removeAllNameTags()
        end
    end
end)

--==============================================================
-- TRACERS (linha do player até inimigo)
--==============================================================
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = Utils.randomString()
tracerGui.IgnoreGuiInset = true
tracerGui.ResetOnSpawn = false
pcall(function()
    if gethui then tracerGui.Parent = gethui()
    else tracerGui.Parent = CoreGui end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not getgenv().Ruan.Settings.Toggled.Tracers then
            for _, v in ipairs(tracerGui:GetChildren()) do v:Destroy() end
        else
            for _, v in ipairs(tracerGui:GetChildren()) do v:Destroy() end

            local camera = workspace.CurrentCamera
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local headPos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local role = getRole(p)
                        local color = COLORS.Innocent
                        if role == "Murderer" then color = COLORS.Murderer
                        elseif role == "Sheriff" then color = COLORS.Sheriff end

                        local line = Instance.new("Frame")
                        line.Size = UDim2.fromOffset(2, 2)
                        line.BackgroundColor3 = color
                        line.BorderSizePixel = 0
                        line.Parent = tracerGui

                        -- Ponto de origem: centro inferior da tela
                        local originX = viewport.X / 2
                        local originY = viewport.Y - 50
                        local targetX = headPos.X
                        local targetY = headPos.Y

                        local dx = targetX - originX
                        local dy = targetY - originY
                        local length = math.sqrt(dx * dx + dy * dy)
                        local angle = math.atan2(dy, dx)

                        line.Size = UDim2.fromOffset(length, 2)
                        line.Position = UDim2.fromOffset(originX, originY)
                        line.AnchorPoint = Vector2.new(0, 0.5)
                        line.Rotation = math.deg(angle)
                    end
                end
            end
        end
    end
end)

--==============================================================
-- CHAMS (X-Ray simples via highlight com transparência alta)
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().Ruan.Settings.Toggled.Chams then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local old = p.Character:FindFirstChild("RuanChams")
                    if not old then
                        local role = getRole(p)
                        local color = COLORS.Innocent
                        if role == "Murderer" then color = COLORS.Murderer
                        elseif role == "Sheriff" then color = COLORS.Sheriff end

                        local h = Instance.new("Highlight")
                        h.Name = "RuanChams"
                        h.Adornee = p.Character
                        h.FillColor = color
                        h.OutlineColor = color
                        h.FillTransparency = 0.2
                        h.OutlineTransparency = 0.5
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = p.Character
                    end
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local old = p.Character:FindFirstChild("RuanChams")
                    if old then old:Destroy() end
                end
            end
        end
    end
end)

--==============================================================
-- FULLBRIGHT
--==============================================================
local function applyFullbright()
    if getgenv().Ruan.Settings.Toggled.Fullbright then
        pcall(function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        end)
    end
end

task.spawn(function()
    while task.wait(1) do
        applyFullbright()
    end
end)

--==============================================================
-- CROSSHAIR
--==============================================================
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = Utils.randomString()
crosshairGui.IgnoreGuiInset = true
crosshairGui.ResetOnSpawn = false
pcall(function()
    if gethui then crosshairGui.Parent = gethui()
    else crosshairGui.Parent = CoreGui end
end)

local crosshairDot = Instance.new("Frame")
crosshairDot.Name = "Crosshair"
crosshairDot.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairDot.Position = UDim2.fromScale(0.5, 0.5)
crosshairDot.Size = UDim2.fromOffset(20, 20)
crosshairDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
crosshairDot.BorderSizePixel = 0
crosshairDot.Visible = false
crosshairDot.Parent = crosshairGui
Instance.new("UICorner", crosshairDot).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while task.wait(0.1) do
        crosshairDot.Visible = getgenv().Ruan.Settings.Toggled.Crosshair
        local s = getgenv().Ruan.Settings.Values.CrosshairSize
        crosshairDot.Size = UDim2.fromOffset(s, s)
    end
end)

--==============================================================
-- CRIA ABA VISUAL COM TODOS OS TOGGLES
--==============================================================
task.spawn(function()
    task.wait(0.5)

    local Visual = getgenv().Ruan:CreateTab("Visual")

    Visual:AddSection("ESP Jogadores")

    Visual:AddToggle("ESP Assassino", false, function(state)
        getgenv().Ruan.Settings.Toggled.ESP_Murderer = state
    end)

    Visual:AddToggle("ESP Xerife", false, function(state)
        getgenv().Ruan.Settings.Toggled.ESP_Sheriff = state
    end)

    Visual:AddToggle("ESP Inocente", false, function(state)
        getgenv().Ruan.Settings.Toggled.ESP_Innocent = state
    end)

    Visual:AddSection("ESP Objetos")

    Visual:AddToggle("ESP Arma Caída", false, function(state)
        getgenv().Ruan.Settings.Toggled.ESP_Gun = state
    end)

    Visual:AddToggle("ESP Moedas", false, function(state)
        getgenv().Ruan.Settings.Toggled.ESP_Coins = state
    end)

    Visual:AddSection("Extras")

    Visual:AddToggle("Mostrar Nomes", false, function(state)
        getgenv().Ruan.Settings.Toggled.ShowNames = state
    end)

    Visual:AddToggle("Tracers", false, function(state)
        getgenv().Ruan.Settings.Toggled.Tracers = state
    end)

    Visual:AddToggle("Chams (X-Ray)", false, function(state)
        getgenv().Ruan.Settings.Toggled.Chams = state
    end)

    Visual:AddSection("Iluminação")

    Visual:AddToggle("Fullbright", false, function(state)
        getgenv().Ruan.Settings.Toggled.Fullbright = state
        if not state then
            pcall(function()
                Lighting.Brightness = 1
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = true
                Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
            end)
        end
    end)

    Visual:AddSection("Mira")

    Visual:AddToggle("Crosshair Customizada", false, function(state)
        getgenv().Ruan.Settings.Toggled.Crosshair = state
    end)

    Visual:AddSlider("Tamanho da Crosshair", 5, 40, 10, function(v)
        getgenv().Ruan.Settings.Values.CrosshairSize = v
    end)

    Visual:AddSection("Ações")

    Visual:AddButton("🔴 Desligar Todos os ESPs", function()
        getgenv().Ruan.Settings.Toggled.ESP_Murderer = false
        getgenv().Ruan.Settings.Toggled.ESP_Sheriff = false
        getgenv().Ruan.Settings.Toggled.ESP_Innocent = false
        getgenv().Ruan.Settings.Toggled.ESP_Gun = false
        getgenv().Ruan.Settings.Toggled.ESP_Coins = false
        getgenv().Ruan.Settings.Toggled.ShowNames = false
        getgenv().Ruan.Settings.Toggled.Tracers = false
        getgenv().Ruan.Settings.Toggled.Chams = false
        getgenv().Ruan.Settings.Toggled.Fullbright = false
        getgenv().Ruan.Settings.Toggled.Crosshair = false
        Notify("Todos os ESPs desligados!", Color3.fromRGB(255, 100, 100), "x")
    end)

    Notify("Aba Visual carregada!", Color3.fromRGB(0, 200, 100), "check")
end)

print("[Ruan Hub] Aba Visual carregada.")
--==============================================================
-- ================== ABA MOVEMENT / TELEPORT / FARM ===========
--==============================================================

--==============================================================
-- UTILITÁRIOS DE PERSONAGEM
--==============================================================
local function getChar()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getChar()
    if char then return char:FindFirstChildOfClass("Humanoid") end
end

local function getRoot()
    local char = getChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
    end
end

--==============================================================
-- FLY (mobile friendly - sem teclado)
--==============================================================
local flyState = {
    active = false,
    bodyGyro = nil,
    bodyVelocity = nil,
    conns = {},
}

local function startFly()
    local char = getChar()
    if not char then Notify("Sem personagem!", Color3.fromRGB(255,100,100), "x") return end
    local root = getRoot()
    if not root then return end

    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    bg.Parent = root

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.P = 1250
    bv.Parent = root

    flyState.active = true
    flyState.bodyGyro = bg
    flyState.bodyVelocity = bv

    -- Loop de movimento com base em toque (mobile) ou teclado
    local renderConn = RS.RenderStepped:Connect(function()
        if not flyState.active then return end
        local hum = getHumanoid()
        if not hum or hum.Health <= 0 then return end

        local move = hum.MoveDirection
        local camera = workspace.CurrentCamera
        local dir = Vector3.zero
        local speed = getgenv().Ruan.Settings.Values.FlySpeed

        if move.Magnitude > 0 then
            local camCF = camera.CFrame
            local forward = camCF.LookVector
            local right = camCF.RightVector
            dir = (forward * move.Z + right * move.X).Unit * speed
        end

        -- Botões virtuais na tela para subir/descer no mobile
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, speed, 0)
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir = dir - Vector3.new(0, speed, 0)
        end

        bv.Velocity = dir
        bg.CFrame = camera.CFrame
    end)

    table.insert(flyState.conns, renderConn)
end

local function stopFly()
    flyState.active = false
    for _, c in ipairs(flyState.conns) do c:Disconnect() end
    flyState.conns = {}
    if flyState.bodyGyro then flyState.bodyGyro:Destroy() end
    if flyState.bodyVelocity then flyState.bodyVelocity:Destroy() end
    flyState.bodyGyro = nil
    flyState.bodyVelocity = nil
end

--==============================================================
-- NOCLIP
--==============================================================
local noclipConn = nil
local function startNoclip()
    if noclipConn then return end
    noclipConn = RS.Stepped:Connect(function()
        local char = getChar()
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

--==============================================================
-- INVISIBLE
--==============================================================
local invisConns = {}
local function setInvisible(state)
    local char = getChar()
    if not char then return end

    if state then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.LocalTransparencyModifier = 1
                p.Transparency = 1
            end
            if p:IsA("Decal") then
                p.Transparency = 1
            end
        end
        -- Repete pra prevenir respawn de partes
        table.insert(invisConns, RS.Stepped:Connect(function()
            if not getgenv().Ruan.Settings.Toggled.Invisible then return end
            local c = getChar()
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Transparency = 1
                end
                if p:IsA("Decal") then p.Transparency = 1 end
            end
        end))
    else
        for _, c in ipairs(invisConns) do c:Disconnect() end
        invisConns = {}
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Transparency = 0
                end
                if p:IsA("Decal") then p.Transparency = 0 end
            end
        end
    end
end

--==============================================================
-- INFINITE JUMP
--==============================================================
local infJumpConn = nil
local function startInfJump()
    if infJumpConn then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        if not getgenv().Ruan.Settings.Toggled.InfiniteJump then return end
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
end

--==============================================================
-- SPEED / JUMP POWER (aplicado continuamente)
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        local hum = getHumanoid()
        if hum then
            local targetSpeed = getgenv().Ruan.Settings.Values.WalkSpeed
            local targetJump = getgenv().Ruan.Settings.Values.JumpPower

            if targetSpeed ~= 16 and getgenv().Ruan.Settings.Toggled.SpeedBoost then
                hum.WalkSpeed = targetSpeed
            elseif not getgenv().Ruan.Settings.Toggled.SpeedBoost and hum.WalkSpeed ~= 16 then
                hum.WalkSpeed = 16
            end

            if targetJump ~= 50 and getgenv().Ruan.Settings.Toggled.JumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = targetJump
            elseif not getgenv().Ruan.Settings.Toggled.JumpPower and hum.JumpPower ~= 50 then
                hum.JumpPower = 50
            end
        end
    end
end)

--==============================================================
-- TELEPORTS
--==============================================================
local function teleportToPlayer(targetPlayer)
    local root = getRoot()
    if not root then Notify("Sem personagem", Color3.fromRGB(255,100,100), "x") return end
    if not targetPlayer or not targetPlayer.Character then
        Notify("Alvo não encontrado", Color3.fromRGB(255,100,100), "x") return
    end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then Notify("Alvo sem root", Color3.fromRGB(255,100,100), "x") return end

    root.CFrame = tRoot.CFrame * CFrame.new(0, 2, 3)
    Notify("Teleportado para " .. targetPlayer.Name, Color3.fromRGB(0, 200, 255), "info")
end

local function teleportToGun()
    local root = getRoot()
    if not root then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
            root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
            Notify("Teleportado para arma caída", Color3.fromRGB(255, 200, 0), "info")
            return
        end
    end
    Notify("Nenhuma arma caída encontrada", Color3.fromRGB(255,100,100), "x")
end

--==============================================================
-- AUTO GRAB GUN
--==============================================================
local function autoGrabGun()
    local root = getRoot()
    if not root then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
            root.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.1)
            return
        end
    end
end

--==============================================================
-- AUTO COINS
--==============================================================
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().Ruan.Settings.Toggled.AutoCoins then
            local root = getRoot()
            if root then
                local closest, dist = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then
                        local d = (root.Position - obj.Position).Magnitude
                        if d < dist then
                            closest = obj
                            dist = d
                        end
                    end
                end
                if closest and dist < 500 then
                    root.CFrame = closest.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
    end
end)

--==============================================================
-- ANTI VOID
--==============================================================
local antiVoidConn = nil
local function startAntiVoid()
    if antiVoidConn then return end
    antiVoidConn = RS.Heartbeat:Connect(function()
        local root = getRoot()
        if root and root.Position.Y < -50 then
            root.CFrame = CFrame.new(0, 50, 0)
            Notify("Anti-Void: te salvou!", Color3.fromRGB(0, 200, 255), "check")
        end
    end)
end

local function stopAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect() antiVoidConn = nil end
end

--==============================================================
-- CRIA ABA MOVEMENT + TELEPORT + FARM
--==============================================================
task.spawn(function()
    task.wait(0.8)

    local Move = getgenv().Ruan:CreateTab("Movement")

    Move:AddSection("Velocidade")

    Move:AddToggle("Speed Boost", false, function(state)
        getgenv().Ruan.Settings.Toggled.SpeedBoost = state
        if not state then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end)

    Move:AddSlider("WalkSpeed", 16, 200, 16, function(v)
        getgenv().Ruan.Settings.Values.WalkSpeed = v
    end)

    Move:AddToggle("Jump Power", false, function(state)
        getgenv().Ruan.Settings.Toggled.JumpPower = state
        if not state then
            local hum = getHumanoid()
            if hum then hum.JumpPower = 50 end
        end
    end)

    Move:AddSlider("JumpPower", 50, 300, 50, function(v)
        getgenv().Ruan.Settings.Values.JumpPower = v
    end)

    Move:AddSection("Voo e Mobilidade")

    Move:AddToggle("Fly", false, function(state)
        getgenv().Ruan.Settings.Toggled.Fly = state
        if state then startFly() else stopFly() end
    end)

    Move:AddSlider("Fly Speed", 20, 300, 80, function(v)
        getgenv().Ruan.Settings.Values.FlySpeed = v
    end)

    Move:AddToggle("Infinite Jump", false, function(state)
        getgenv().Ruan.Settings.Toggled.InfiniteJump = state
        if state then startInfJump() else stopInfJump() end
    end)

    Move:AddToggle("Noclip", false, function(state)
        getgenv().Ruan.Settings.Toggled.Noclip = state
        if state then startNoclip() else stopNoclip() end
    end)

    Move:AddToggle("Invisible", false, function(state)
        getgenv().Ruan.Settings.Toggled.Invisible = state
        setInvisible(state)
    end)

    Move:AddToggle("Anti-Void", false, function(state)
        getgenv().Ruan.Settings.Toggled.AntiVoid = state
        if state then startAntiVoid() else stopAntiVoid() end
    end)

    --==============================================================
    -- ABA TELEPORT
    --==============================================================
    local TP = getgenv().Ruan:CreateTab("Teleport")

    TP:AddSection("Teleportes Rápidos")

    TP:AddButton("🎯 Teleportar para Assassino", function()
        local murder = findMurderer()
        if murder then teleportToPlayer(murder) else Notify("Sem assassino na partida", Color3.fromRGB(255,100,100), "x") end
    end)

    TP:AddButton("👮 Teleportar para Xerife", function()
        local sher = findSheriff()
        if sher then teleportToPlayer(sher) else Notify("Sem xerife na partida", Color3.fromRGB(255,100,100), "x") end
    end)

    TP:AddButton("🔫 Teleportar para Arma Caída", function()
        teleportToGun()
    end)

    TP:AddSection("Teleportar por Nome")

    local inputPlayerName
    TP:AddButton("Teleportar para jogador digitado", function()
        if inputPlayerName and inputPlayerName ~= "" then
            local target = Players:FindFirstChild(inputPlayerName)
            if target then
                teleportToPlayer(target)
            else
                Notify("Jogador não encontrado: " .. inputPlayerName, Color3.fromRGB(255,100,100), "x")
            end
        else
            Notify("Digite um nome primeiro", Color3.fromRGB(255,200,0), "info")
        end
    end)

    --==============================================================
    -- ABA FARM
    --==============================================================
    local Farm = getgenv().Ruan:CreateTab("Farm")

    Farm:AddSection("Auto Coins")

    Farm:AddToggle("Auto Coins", false, function(state)
        getgenv().Ruan.Settings.Toggled.AutoCoins = state
    end)

    Farm:AddButton("Pegar 1 moeda mais próxima", function()
        local root = getRoot()
        if not root then return end
        local closest, dist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then
                local d = (root.Position - obj.Position).Magnitude
                if d < dist then
                    closest = obj
                    dist = d
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0, 2, 0)
            Notify("Teleportado pra moeda", Color3.fromRGB(255, 200, 0), "info")
        else
            Notify("Nenhuma moeda encontrada", Color3.fromRGB(255,100,100), "x")
        end
    end)

    Farm:AddSection("Auto Grab Gun")

    Farm:AddToggle("Auto Grab Gun", false, function(state)
        getgenv().Ruan.Settings.Toggled.AutoGrabGun = state
    end)

    Farm:AddButton("Pegar arma caída agora", function()
        autoGrabGun()
    end)

    Farm:AddSection("Dicas")

    Farm:AddText("💡 Auto Coins só funciona se as moedas estiverem no mapa (durante a partida).")
    Farm:AddText("💡 Auto Grab Gun vai te teleportar até a arma caída e pegar automaticamente.")

    Notify("Abas Movement / Teleport / Farm carregadas!", Color3.fromRGB(0, 200, 100), "check")
end)

--==============================================================
-- LOOP AUTO GRAB GUN
--==============================================================
task.spawn(function()
    while task.wait(1) do
        if getgenv().Ruan.Settings.Toggled.AutoGrabGun then
            autoGrabGun()
        end
    end
end)

print("[Ruan Hub] Aba Movement/Teleport/Farm carregada.")
--==============================================================
-- ================== ABA MISC + CONFIG + FINAL ================
--==============================================================

--==============================================================
-- ANTI-AFK
--==============================================================
local antiAfkConn = nil
local function startAntiAFK()
    if antiAfkConn then return end
    antiAfkConn = LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
    Notify("Anti-AFK ativado", Color3.fromRGB(0, 200, 100), "check")
end

local function stopAntiAFK()
    if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
end

--==============================================================
-- FPS BOOST
--==============================================================
local fpsSaved = {}
local function applyFPSBoost()
    pcall(function()
        fpsSaved.Brightness = Lighting.Brightness
        fpsSaved.ClockTime = Lighting.ClockTime
        fpsSaved.FogEnd = Lighting.FogEnd
        fpsSaved.GlobalShadows = Lighting.GlobalShadows

        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
        if obj:IsA("Decal") and obj.Name ~= "face" then
            obj.Transparency = 1
        end
    end

    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") then
            obj.Enabled = false
        end
    end
end

--==============================================================
-- SERVER HOP
--==============================================================
local function serverHop()
    Notify("Procurando servidor...", Color3.fromRGB(255, 200, 0), "info")
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        Notify("Erro ao buscar servidores", Color3.fromRGB(255,100,100), "x")
        return
    end

    local data = HS:JSONDecode(result)
    if data and data.data then
        for _, server in ipairs(data.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                Notify("Entrando em servidor novo...", Color3.fromRGB(0, 200, 100), "check")
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
    Notify("Nenhum servidor disponível", Color3.fromRGB(255,100,100), "x")
end

--==============================================================
-- REJOIN
--==============================================================
local function rejoin()
    Notify("Reconectando...", Color3.fromRGB(255, 200, 0), "info")
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end

--==============================================================
-- COPY SCRIPT
--==============================================================
local SCRIPT_URL = "https://raw.githubusercontent.com/miguel12345711/Murde.Mystery/main/Ruan-Noob.V1.0.LUA"
local function copyScript()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
        Notify("Script copiado! Cole no seu amigo.", Color3.fromRGB(0, 200, 100), "check")
    else
        Notify("Copiar não suportado nesse executor", Color3.fromRGB(255,100,100), "x")
    end
end

--==============================================================
-- KEYBIND DE ABRIR/FECHAR
--==============================================================
local openKey = Enum.KeyCode.RightShift
local keybindConn = UIS.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == openKey then
        local win = mainWindow
        if win then
            if win.Visible then
                getgenv().Ruan:Minimize()
            else
                getgenv().Ruan:Open()
            end
        end
    end
end)

table.insert(getgenv().Ruan.Connections, keybindConn)

--==============================================================
-- SALVAR / CARREGAR CONFIG
--==============================================================
local function saveConfig()
    local data = {
        Toggled = getgenv().Ruan.Settings.Toggled,
        Values = getgenv().Ruan.Settings.Values,
    }
    local ok, encoded = pcall(function()
        return HS:JSONEncode(data)
    end)
    if ok then
        Save:set("Config", encoded)
        Notify("Configurações salvas!", Color3.fromRGB(0, 200, 100), "check")
    else
        Notify("Erro ao salvar config", Color3.fromRGB(255,100,100), "x")
    end
end

local function loadConfig()
    local raw = Save:get("Config")
    if not raw then
        Notify("Nenhuma config salva", Color3.fromRGB(255, 200, 0), "info")
        return
    end
    local ok, data = pcall(function()
        return HS:JSONDecode(raw)
    end)
    if ok and data then
        for k, v in pairs(data.Toggled or {}) do
            getgenv().Ruan.Settings.Toggled[k] = v
        end
        for k, v in pairs(data.Values or {}) do
            getgenv().Ruan.Settings.Values[k] = v
        end
        -- Aplica efeitos que precisam de reativação
        if getgenv().Ruan.Settings.Toggled.Noclip then startNoclip() end
        if getgenv().Ruan.Settings.Toggled.InfiniteJump then startInfJump() end
        if getgenv().Ruan.Settings.Toggled.AntiVoid then startAntiVoid() end
        if getgenv().Ruan.Settings.Toggled.AntiAFK then startAntiAFK() end
        if getgenv().Ruan.Settings.Toggled.Fly then startFly() end
        Notify("Configurações carregadas!", Color3.fromRGB(0, 200, 100), "check")
    else
        Notify("Erro ao carregar config", Color3.fromRGB(255,100,100), "x")
    end
end

local function resetConfig()
    Save:remove("Config")
    Notify("Config resetada. Reinicie o script.", Color3.fromRGB(255, 200, 0), "info")
end

--==============================================================
-- TEMAS
--==============================================================
local function applyTheme(color)
    ThemeManager.accentColor = color
    if mainWindow then
        for _, d in ipairs(mainWindow:GetDescendants()) do
            if d:IsA("UIStroke") and d.Parent == mainWindow then
                d.Color = color
            end
            if d:IsA("Frame") and d.BackgroundColor3 == Color3.fromRGB(197, 0, 0) then
                d.BackgroundColor3 = color
            end
            if d:IsA("TextButton") and d.BackgroundColor3 == Color3.fromRGB(197, 0, 0) then
                d.BackgroundColor3 = color
            end
        end
    end
    Notify("Tema aplicado!", Color3.fromRGB(0, 200, 100), "check")
end

--==============================================================
-- CRIA ABAS FINAIS
--==============================================================
task.spawn(function()
    task.wait(1)

    --==============================================================
    -- ABA MISC
    --==============================================================
    local Misc = getgenv().Ruan:CreateTab("Misc")

    Misc:AddSection("Anti / Boost")

    Misc:AddToggle("Anti-AFK", false, function(state)
        getgenv().Ruan.Settings.Toggled.AntiAFK = state
        if state then startAntiAFK() else stopAntiAFK() end
    end)

    Misc:AddToggle("FPS Boost", false, function(state)
        getgenv().Ruan.Settings.Toggled.FPSBoost = state
        if state then applyFPSBoost() end
    end)

    Misc:AddSection("Servidor")

    Misc:AddButton("🔄 Server Hop", function()
        serverHop()
    end)

    Misc:AddButton("🔁 Rejoin (mesmo servidor)", function()
        rejoin()
    end)

    Misc:AddSection("Social")

    Misc:AddButton("📋 Copiar script p/ amigo", function()
        copyScript()
    end)

    Misc:AddButton("💬 Copiar link do Discord", function()
        if setclipboard then
            setclipboard("https://discord.gg/SEU_DISCORD")
            Notify("Link copiado!", Color3.fromRGB(0, 200, 100), "check")
        end
    end)

    Misc:AddSection("Info")

    Misc:AddText("Script: Ruan MM2 Hub v1.0")
    Misc:AddText("Key: 123 Ruan")
    Misc:AddText("Executor: " .. (identifyexecutor and identifyexecutor() or "Desconhecido"))
    Misc:AddText("Jogo: " .. game.PlaceId)

    --==============================================================
    -- ABA CONFIG
    --==============================================================
    local Config = getgenv().Ruan:CreateTab("Config")

    Config:AddSection("Salvar / Carregar")

    Config:AddButton("💾 Salvar Configurações", function()
        saveConfig()
    end)

    Config:AddButton("📂 Carregar Configurações", function()
        loadConfig()
    end)

    Config:AddButton("🗑️ Resetar Configurações", function()
        resetConfig()
    end)

    Config:AddSection("Tema")

    Config:AddButton("🔴 Tema Vermelho (Padrão)", function()
        applyTheme(Color3.fromRGB(197, 0, 0))
    end)

    Config:AddButton("🔵 Tema Azul", function()
        applyTheme(Color3.fromRGB(0, 150, 255))
    end)

    Config:AddButton("🟢 Tema Verde", function()
        applyTheme(Color3.fromRGB(0, 200, 100))
    end)

    Config:AddButton("🟣 Tema Roxo", function()
        applyTheme(Color3.fromRGB(150, 0, 255))
    end)

    Config:AddButton("🟡 Tema Amarelo", function()
        applyTheme(Color3.fromRGB(255, 200, 0))
    end)

    Config:AddSection("Sistema")

    Config:AddButton("❌ Descarregar Script", function()
        getgenv().Ruan:Unload()
    end)

    Config:AddText("💡 Aperte RightShift pra abrir/fechar o menu.")

    Notify("Abas Misc e Config carregadas!", Color3.fromRGB(0, 200, 100), "check")
end)

--==============================================================
-- NOTIFICAÇÃO FINAL
--==============================================================
task.spawn(function()
    task.wait(2)
    Notify("Ruan MM2 Hub carregado! Key: 123 Ruan", Color3.fromRGB(0, 200, 100), "check")
    task.wait(0.5)
    Notify("Aperte RightShift para abrir o menu", Color3.fromRGB(0, 150, 255), "info")
end)

print("==================================================")
print("[Ruan MM2 Hub] SCRIPT COMPLETO CARREGADO!")
print("[Ruan MM2 Hub] Key: 123 Ruan")
print("[Ruan MM2 Hub] Abas: Visual, Movement, Teleport, Farm, Misc, Config")
print("[Ruan MM2 Hub] Abrir/Fechar: RightShift")
print("==================================================")
