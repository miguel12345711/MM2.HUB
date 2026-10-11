--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  Ruan MM2 Hub — v2.0                         ║
    ║                                                              ║
    ║   ESP, Chams, Tracers, Fullbright, Fly, Noclip, Teleport     ║
    ║   Mobile otimizado (Samsung A06)                             ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local viewport = workspace.CurrentCamera.ViewportSize

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
function Utils.notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title or "Ruan", Text = text or "", Duration = dur or 4})
    end)
end

--==============================================================
-- SETTINGS GLOBAIS
--==============================================================
getgenv().Ruan = getgenv().Ruan or {}
getgenv().Ruan.Tabs = {}
getgenv().Ruan.Settings = {
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
    Invisible = false,
    SpeedBoost = false,
    JumpBoost = false,
    AntiVoid = false,
    AntiAFK = false,
    AutoCoins = false,
    AutoGrabGun = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 80,
    CrosshairSize = 12,
}
local S = getgenv().Ruan.Settings

--==============================================================
-- CORES
--==============================================================
local CORES = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 150, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    Gun = Color3.fromRGB(255, 220, 0),
    Coin = Color3.fromRGB(255, 180, 0),
}

--==============================================================
-- DETECÇÃO DE ROLE (CORRIGIDA - 3 MÉTODOS)
--==============================================================
-- Método 1: Verifica Knife/Gun no personagem ou backpack
-- Método 2: Verifica tool no character (equipada)
-- Método 3: Verifica nome do objeto no backpack (variações)

local function temFerramenta(p, nomes)
    if not p then return false end
    local char = p.Character
    local backpack = p:FindFirstChild("Backpack")

    -- Método 1: personagem equipado
    if char then
        for _, nome in ipairs(nomes) do
            if char:FindFirstChild(nome) then return true end
        end
        -- Método 2: verifica qualquer Tool no personagem
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                for _, nome in ipairs(nomes) do
                    if obj.Name:lower():find(nome:lower()) then return true end
                end
            end
        end
    end

    -- Método 3: backpack
    if backpack then
        for _, nome in ipairs(nomes) do
            if backpack:FindFirstChild(nome) then return true end
        end
        for _, obj in ipairs(backpack:GetChildren()) do
            if obj:IsA("Tool") then
                for _, nome in ipairs(nomes) do
                    if obj.Name:lower():find(nome:lower()) then return true end
                end
            end
        end
    end

    return false
end

local function getRole(p)
    if not p or not p.Character then return nil end

    local nomesKnife = {"Knife", "knife", "Faca"}
    local nomesGun = {"Gun", "gun", "Revolver", "revolver", "Pistol"}

    -- Verifica Murderer primeiro (mais importante)
    if temFerramenta(p, nomesKnife) then
        return "Murderer"
    end

    -- Verifica Sheriff
    if temFerramenta(p, nomesGun) then
        return "Sheriff"
    end

    -- Innocent padrão
    return "Innocent"
end

getgenv().Ruan.getRole = getRole

--==============================================================
-- MENU LIBRARY
--==============================================================
local RuanRoot, mainWindow, tabList, contentArea, selectedTab, activeTabButton
local notifHolder
local notifIcons = {
    info = "rbxassetid://11780939099",
    x = "rbxassetid://10002373478",
    check = "rbxassetid://11604833061",
}

--==============================================================
-- NOTIFICAÇÃO
--==============================================================
local function Notify(msg, cor, icon)
    if not notifHolder then return end
    task.spawn(function()
        local sample = notifHolder:FindFirstChild("NotificationSample")
        if not sample then return end
        local notif = sample:Clone()
        notif.Parent = notifHolder
        notif.Position = UDim2.fromScale(0.5, -0.1)
        notif.UIScale.Scale = 0.7
        notif.Visible = true
        if cor and typeof(cor) == "Color3" then
            if notif:FindFirstChild("UIStroke") then notif.UIStroke.Color = cor end
            if notif:FindFirstChild("ImageLabel") then notif.ImageLabel.ImageColor3 = cor end
        end
        if icon and notifIcons[icon] then
            notif.ImageLabel.Image = notifIcons[icon]
        end
        notif.TextLabel.Text = tostring(msg)
        notif:SetAttribute("close", false)
        TS:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
            Position = UDim2.new(0.5, 0, 0, 10)
        }):Play()
        TS:Create(notif.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {Scale = 1}):Play()
        notif.Close.MouseButton1Click:Connect(function()
            notif:SetAttribute("close", true)
        end)
        task.wait()
        local t = os.clock()
        repeat task.wait() until os.clock() - t > 4 or notif:GetAttribute("close")
        local fin = TS:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
            Position = UDim2.fromScale(0.5, -0.1)
        })
        fin:Play()
        fin.Completed:Connect(function() notif:Destroy() end)
    end)
end
getgenv().Ruan.Notify = Notify

--==============================================================
-- DRAGGABLE
--==============================================================
local DraggableObject = {}
DraggableObject.__index = DraggableObject
function DraggableObject.new(object, toMove)
    local self = setmetatable({}, DraggableObject)
    self.Object = object
    self.ToMove = toMove or object
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
            lastPos = nil
        end
    end)
end

--==============================================================
-- HELPERS
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
    RuanRoot.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    pcall(function()
        if gethui then RuanRoot.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(RuanRoot)
            RuanRoot.Parent = CoreGui
        else
            RuanRoot.Parent = CoreGui
        end
    end)
    getgenv().Ruan.Root = RuanRoot

    local winW = math.min(420, viewport.X - 40)
    local winH = math.min(420, viewport.Y * 0.62)

    mainWindow = makeFrame({
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, -0.6),
        Size = UDim2.fromOffset(winW, winH),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    })
    mainWindow.Parent = RuanRoot
    Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", mainWindow)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2

    local grad = Instance.new("UIGradient", mainWindow)
    grad.Color = ColorSequence.new(Color3.fromRGB(35,35,35), Color3.fromRGB(15,15,15))

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
        TextColor3 = Color3.fromRGB(255,255,255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
    })
    title.Parent = header

    local version = makeLabel({
        Name = "Version",
        Text = "MM2 v2.0",
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
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(12,12,12),
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
        BackgroundColor3 = Color3.fromRGB(12,12,12),
        Position = UDim2.new(1, -50, 0, 6),
        Size = UDim2.fromOffset(40, 38),
    })
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseButton1Click:Connect(function()
        if mainWindow then
            mainWindow.Visible = false
            if getgenv().Ruan.MinBtn then
                getgenv().Ruan.MinBtn.Visible = true
            end
        end
    end)
    minBtn.MouseButton1Click:Connect(function()
        if mainWindow then
            mainWindow.Visible = false
            if getgenv().Ruan.MinBtn then
                getgenv().Ruan.MinBtn.Visible = true
            end
        end
    end)

    -- LISTA DE ABAS
    tabList = makeFrame({
        Name = "TabList",
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(0, 120, 1, -72),
        BackgroundColor3 = Color3.fromRGB(12,12,12),
    })
    tabList.Parent = mainWindow
    Instance.new("UICorner", tabList).CornerRadius = UDim.new(0, 12)

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Size = UDim2.fromScale(1, 1)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 4
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.CanvasSize = UDim2.new(0,0,0,0)
    tabScroll.Parent = tabList

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPad = Instance.new("UIPadding", tabScroll)
    tabPad.PaddingTop = UDim.new(0, 8)
    tabPad.PaddingBottom = UDim.new(0, 8)

    getgenv().Ruan.TabScroll = tabScroll

    -- ÁREA DE CONTEÚDO
    contentArea = makeFrame({
        Name = "Content",
        Position = UDim2.new(0, 138, 0, 60),
        Size = UDim2.new(1, -148, 1, -72),
        BackgroundTransparency = 1,
    })
    contentArea.Parent = mainWindow

    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "ContentScroll"
    contentScroll.Size = UDim2.fromScale(1, 1)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 4
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.CanvasSize = UDim2.new(0,0,0,0)
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

    -- ANIMAÇÃO ENTRADA
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
        BackgroundColor3 = Color3.fromRGB(22,22,22),
        ClipsDescendants = true,
        Visible = false,
    })
    sample.Parent = notifHolder
    Instance.new("UICorner", sample).CornerRadius = UDim.new(0, 12)

    local sStroke = Instance.new("UIStroke", sample)
    sStroke.Color = Color3.fromRGB(255,255,255)
    sStroke.Thickness = 2

    local sGrad = Instance.new("UIGradient", sample)
    sGrad.Color = ColorSequence.new(Color3.fromRGB(46,46,46), Color3.fromRGB(12,12,12))

    local sImg = Instance.new("ImageLabel", sample)
    sImg.Name = "ImageLabel"
    sImg.Image = notifIcons.info
    sImg.ImageColor3 = Color3.fromRGB(255,255,255)
    sImg.BackgroundTransparency = 1
    sImg.AnchorPoint = Vector2.new(0.5, 0.5)
    sImg.Position = UDim2.new(0.12, 0, 0.5, 0)
    sImg.Size = UDim2.new(0.1, 0, 0.55, 0)

    local sText = makeLabel({
        Name = "TextLabel",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255),
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

    -- BOTÃO FLUTUANTE
    local minBtnFloat = makeButton({
        Name = "MinimizedBtn",
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromOffset(15, 80),
        Size = UDim2.fromOffset(70, 70),
        BackgroundColor3 = Color3.fromRGB(197, 0, 0),
        Text = "R",
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        TextColor3 = Color3.fromRGB(255,255,255),
        Visible = false,
        ZIndex = 20,
    })
    minBtnFloat.Parent = RuanRoot
    Instance.new("UICorner", minBtnFloat).CornerRadius = UDim.new(1, 0)
    local mbStroke = Instance.new("UIStroke", minBtnFloat)
    mbStroke.Color = Color3.fromRGB(255,255,255)
    mbStroke.Thickness = 2.5

    minBtnFloat.MouseButton1Click:Connect(function()
        if mainWindow then
            mainWindow.Visible = true
            minBtnFloat.Visible = false
        end
    end)

    local mbDrag = DraggableObject.new(minBtnFloat)
    mbDrag:Enable()
    getgenv().Ruan.MinBtn = minBtnFloat
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

    local btn = makeButton({
        Name = name .. "Btn",
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(22,22,22),
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
            BackgroundColor3 = Color3.fromRGB(22,22,22)
        }):Play()
    end
    activeTabButton = self
    selectedTab = self
    TS:Create(self.Button, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(197, 0, 0)
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

function Tab:AddSection(text)
    local builder = function(parent)
        local lbl = makeLabel({
            Text = "─── " .. text .. " ───",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Size = UDim2.new(1, 0, 0, 25),
        })
        lbl.Parent = parent
    end
    table.insert(self.Elements, {Builder = builder})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
end

function Tab:AddButton(text, callback)
    local builder = function(parent)
        local btn = makeButton({
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = Color3.fromRGB(22,22,22),
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
                if not ok then warn("[Ruan]", err) end
            end
        end)
    end
    table.insert(self.Elements, {Builder = builder})
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
            TextColor3 = Color3.fromRGB(255,255,255),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Size = UDim2.new(0.62, 0, 1, 0),
        })
        lbl.Parent = container

        local switchBg = makeFrame({
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(58, 30),
            BackgroundColor3 = state and Color3.fromRGB(197, 0, 0) or Color3.fromRGB(60, 60, 60),
        })
        switchBg.Parent = container
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

        local knob = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
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
                BackgroundColor3 = state and Color3.fromRGB(197, 0, 0) or Color3.fromRGB(60, 60, 60)
            }):Play()
            TS:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0)
            }):Play()
            if fire and callback then pcall(callback, state) end
        end

        clickBtn.MouseButton1Click:Connect(function()
            setState(not state, true)
        end)
    end
    table.insert(self.Elements, {Builder = builder})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
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
            TextColor3 = Color3.fromRGB(255,255,255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7, 0, 0, 22),
        })
        lbl.Parent = container

        local valueLbl = makeLabel({
            Text = tostring(value),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(197, 0, 0),
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
            BackgroundColor3 = Color3.fromRGB(197, 0, 0),
        })
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
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
    table.insert(self.Elements, {Builder = builder})
    if selectedTab == self then builder(getgenv().Ruan.ContentScroll) end
end

--==============================================================
-- API PÚBLICA
--==============================================================
local Ruan = getgenv().Ruan
function Ruan:CreateTab(name) return Tab.new(name) end

function Ruan:Init()
    buildUI()
end

getgenv().Ruan:Init()

print("[Ruan] Menu Library carregada.")
--==============================================================
-- ==================== ABA VISUAL (ESP) ========================
--==============================================================

--==============================================================
-- HIGHLIGHT HELPER
--==============================================================
local function criarHighlight(char, cor, nome)
    if not char then return end
    local old = char:FindFirstChild(nome)
    if old then old:Destroy() end
    local h = Instance.new("Highlight")
    h.Name = nome
    h.Adornee = char
    h.FillColor = cor
    h.OutlineColor = cor
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    return h
end

local function limparHighlights(char)
    if not char then return end
    for _, h in ipairs(char:GetChildren()) do
        if h.Name:match("^RuanESP_") then
            h:Destroy()
        end
    end
end

--==============================================================
-- LOOP PRINCIPAL ESP (XERIFE / ASSASSINO / INOCENTE)
--==============================================================
task.spawn(function()
    while task.wait(0.4) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local role = getRole(p)

                -- Verifica se deve ter ESP
                local deveTer = false
                local cor = nil
                local nomeH = nil

                if S.ESP_Murderer and role == "Murderer" then
                    deveTer, cor, nomeH = true, CORES.Murderer, "RuanESP_Murderer"
                elseif S.ESP_Sheriff and role == "Sheriff" then
                    deveTer, cor, nomeH = true, CORES.Sheriff, "RuanESP_Sheriff"
                elseif S.ESP_Innocent and role == "Innocent" then
                    deveTer, cor, nomeH = true, CORES.Innocent, "RuanESP_Innocent"
                end

                -- Remove ESP de outro role se mudou
                for _, h in ipairs(char:GetChildren()) do
                    if h.Name:match("^RuanESP_") and h.Name ~= nomeH then
                        h:Destroy()
                    end
                end

                -- Aplica ESP
                if deveTer then
                    if not char:FindFirstChild(nomeH) then
                        criarHighlight(char, cor, nomeH)
                    else
                        local h = char[nomeH]
                        if h.FillColor ~= cor then
                            h.FillColor = cor
                            h.OutlineColor = cor
                        end
                    end
                end
            end
        end

        -- Limpa ESP de jogadores que saíram
        for _, char in ipairs(workspace:GetChildren()) do
            if char:IsA("Model") and char:FindFirstChildOfClass("Humanoid") then
                local dono = Players:GetPlayerFromCharacter(char)
                if dono ~= LocalPlayer and not dono then
                    limparHighlights(char)
                end
            end
        end
    end
end)

--==============================================================
-- ESP DE ARMA CAÍDA
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        if S.ESP_Gun then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj.Name == "GunDrop" or obj.Name == "DroppedGun" or obj.Name:lower():find("drop"))
                and obj:IsA("BasePart") then
                    if not obj:FindFirstChild("RuanESP_Gun") then
                        local h = Instance.new("Highlight")
                        h.Name = "RuanESP_Gun"
                        h.Adornee = obj
                        h.FillColor = CORES.Gun
                        h.OutlineColor = CORES.Gun
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
    end
end)

--==============================================================
-- ESP DE MOEDAS
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        if S.ESP_Coins then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server" or obj.Name:lower():find("coin")) then
                    if not obj:FindFirstChild("RuanESP_Coin") then
                        local h = Instance.new("Highlight")
                        h.Name = "RuanESP_Coin"
                        h.Adornee = obj
                        h.FillColor = CORES.Coin
                        h.OutlineColor = CORES.Coin
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
local function criarNome(p)
    if not p or not p.Character then return end
    local head = p.Character:FindFirstChild("Head")
    if not head then return end

    local old = head:FindFirstChild("RuanName")
    if old then old:Destroy() end

    local role = getRole(p)
    local cor = CORES.Innocent
    if role == "Murderer" then cor = CORES.Murderer
    elseif role == "Sheriff" then cor = CORES.Sheriff end

    local bg = Instance.new("BillboardGui")
    bg.Name = "RuanName"
    bg.Size = UDim2.new(0, 200, 0, 30)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.Text = p.Name .. " [" .. role .. "]"
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextColor3 = cor
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.Parent = bg
end

task.spawn(function()
    while task.wait(0.5) do
        if S.ShowNames then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    criarNome(p)
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    local old = p.Character.Head:FindFirstChild("RuanName")
                    if old then old:Destroy() end
                end
            end
        end
    end
end)

--==============================================================
-- CHAMS (X-RAY)
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        if S.Chams then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("RuanChams") then
                        local role = getRole(p)
                        local cor = CORES.Innocent
                        if role == "Murderer" then cor = CORES.Murderer
                        elseif role == "Sheriff" then cor = CORES.Sheriff end

                        local h = Instance.new("Highlight")
                        h.Name = "RuanChams"
                        h.Adornee = p.Character
                        h.FillColor = cor
                        h.OutlineColor = cor
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
task.spawn(function()
    while task.wait(1) do
        if S.Fullbright then
            pcall(function()
                Lighting.Brightness = 3
                Lighting.ClockTime = 12
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            end)
        end
    end
end)

--==============================================================
-- CROSSHAIR
--==============================================================
local crossGui = Instance.new("ScreenGui")
crossGui.Name = Utils.randomString()
crossGui.IgnoreGuiInset = true
crossGui.ResetOnSpawn = false
pcall(function()
    if gethui then crossGui.Parent = gethui()
    else crossGui.Parent = CoreGui end
end)

local dot = Instance.new("Frame")
dot.Name = "Crosshair"
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.Size = UDim2.fromOffset(12, 12)
dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
dot.BorderSizePixel = 0
dot.Visible = false
dot.Parent = crossGui
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while task.wait(0.1) do
        dot.Visible = S.Crosshair
        dot.Size = UDim2.fromOffset(S.CrosshairSize, S.CrosshairSize)
    end
end)

--==============================================================
-- CRIA ABA VISUAL
--==============================================================
task.spawn(function()
    task.wait(0.5)
    local Visual = getgenv().Ruan:CreateTab("Visual")

    Visual:AddSection("ESP Jogadores")
    Visual:AddToggle("ESP Assassino", false, function(s) S.ESP_Murderer = s end)
    Visual:AddToggle("ESP Xerife", false, function(s) S.ESP_Sheriff = s end)
    Visual:AddToggle("ESP Inocente", false, function(s) S.ESP_Innocent = s end)

    Visual:AddSection("ESP Objetos")
    Visual:AddToggle("ESP Arma Caída", false, function(s) S.ESP_Gun = s end)
    Visual:AddToggle("ESP Moedas", false, function(s) S.ESP_Coins = s end)

    Visual:AddSection("Extras")
    Visual:AddToggle("Mostrar Nomes", false, function(s) S.ShowNames = s end)
    Visual:AddToggle("Chams (X-Ray)", false, function(s) S.Chams = s end)

    Visual:AddSection("Iluminação")
    Visual:AddToggle("Fullbright", false, function(s)
        S.Fullbright = s
        if not s then
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
    Visual:AddToggle("Crosshair", false, function(s) S.Crosshair = s end)
    Visual:AddSlider("Tamanho da Crosshair", 5, 40, 12, function(v)
        S.CrosshairSize = v
    end)

    Visual:AddSection("Ações")
    Visual:AddButton("🔴 Desligar Todos os ESPs", function()
        S.ESP_Murderer = false
        S.ESP_Sheriff = false
        S.ESP_Innocent = false
        S.ESP_Gun = false
        S.ESP_Coins = false
        S.ShowNames = false
        S.Chams = false
        S.Fullbright = false
        S.Crosshair = false
        Notify("Todos os ESPs desligados!", Color3.fromRGB(255, 100, 100), "x")
    end)
end)

--==============================================================
-- ==================== ABA MOVEMENT ============================
--==============================================================

local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar()
    if c then return c:FindFirstChildOfClass("Humanoid") end
end
local function getRoot()
    local c = getChar()
    if c then return c:FindFirstChild("HumanoidRootPart") end
end

-- FLY
local flyState = {active = false, conns = {}}
local function startFly()
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
    flyState.bg = bg
    flyState.bv = bv

    local conn = RS.RenderStepped:Connect(function()
        if not flyState.active then return end
        local hum = getHum()
        if not hum or hum.Health <= 0 then return end

        local move = hum.MoveDirection
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if move.Magnitude > 0 then
            dir = (cam.CFrame.LookVector * move.Z + cam.CFrame.RightVector * move.X).Unit * S.FlySpeed
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, S.FlySpeed, 0)
        end

        bv.Velocity = dir
        bg.CFrame = cam.CFrame
    end)
    table.insert(flyState.conns, conn)
end

local function stopFly()
    flyState.active = false
    for _, c in ipairs(flyState.conns) do c:Disconnect() end
    flyState.conns = {}
    if flyState.bg then flyState.bg:Destroy() end
    if flyState.bv then flyState.bv:Destroy() end
end

-- NOCLIP
local noclipConn = nil
local function startNoclip()
    if noclipConn then return end
    noclipConn = RS.Stepped:Connect(function()
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)
end
local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

-- INVISIBLE
local invisConn = nil
local function startInvisible()
    if invisConn then return end
    invisConn = RS.Stepped:Connect(function()
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 1 end
            if p:IsA("Decal") then p.Transparency = 1 end
        end
    end)
end
local function stopInvisible()
    if invisConn then invisConn:Disconnect() invisConn = nil end
    local c = getChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
            if p:IsA("Decal") then p.Transparency = 0 end
        end
    end
end

-- INFINITE JUMP
local infJumpConn = nil
local function startInfJump()
    if infJumpConn then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        if not S.InfiniteJump then return end
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
end

-- SPEED / JUMP
task.spawn(function()
    while task.wait(0.5) do
        local h = getHum()
        if h then
            if S.SpeedBoost then
                h.WalkSpeed = S.WalkSpeed
            else
                if h.WalkSpeed ~= 16 then h.WalkSpeed = 16 end
            end
            if S.JumpBoost then
                h.UseJumpPower = true
                h.JumpPower = S.JumpPower
            else
                if h.JumpPower ~= 50 then h.JumpPower = 50 end
            end
        end
    end
end)

-- ANTI VOID
local antiVoidConn = nil
local function startAntiVoid()
    if antiVoidConn then return end
    antiVoidConn = RS.Heartbeat:Connect(function()
        local r = getRoot()
        if r and r.Position.Y < -50 then
            r.CFrame = CFrame.new(0, 50, 0)
            Notify("Anti-Void ativado!", Color3.fromRGB(0, 200, 255), "check")
        end
    end)
end
local function stopAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect() antiVoidConn = nil end
end

--==============================================================
-- CRIA ABA MOVEMENT
--==============================================================
task.spawn(function()
    task.wait(0.7)
    local Move = getgenv().Ruan:CreateTab("Movement")

    Move:AddSection("Velocidade")
    Move:AddToggle("Speed Boost", false, function(s) S.SpeedBoost = s end)
    Move:AddSlider("WalkSpeed", 16, 250, 16, function(v) S.WalkSpeed = v end)
    Move:AddToggle("Jump Boost", false, function(s) S.JumpBoost = s end)
    Move:AddSlider("JumpPower", 50, 300, 50, function(v) S.JumpPower = v end)

    Move:AddSection("Voo / Mobilidade")
    Move:AddToggle("Fly", false, function(s)
        S.Fly = s
        if s then startFly() else stopFly() end
    end)
    Move:AddSlider("Fly Speed", 20, 300, 80, function(v) S.FlySpeed = v end)
    Move:AddToggle("Infinite Jump", false, function(s)
        S.InfiniteJump = s
        if s then startInfJump() else stopInfJump() end
    end)
    Move:AddToggle("Noclip", false, function(s)
        S.Noclip = s
        if s then startNoclip() else stopNoclip() end
    end)
    Move:AddToggle("Invisible", false, function(s)
        S.Invisible = s
        if s then startInvisible() else stopInvisible() end
    end)
    Move:AddToggle("Anti-Void", false, function(s)
        S.AntiVoid = s
        if s then startAntiVoid() else stopAntiVoid() end
    end)

    --==============================================================
    -- ABA TELEPORT
    --==============================================================
    local TP = getgenv().Ruan:CreateTab("Teleport")

    local function tpTo(target)
        local r = getRoot()
        if not r or not target or not target.Character then return end
        local tR = target.Character:FindFirstChild("HumanoidRootPart")
        if not tR then return end
        r.CFrame = tR.CFrame * CFrame.new(0, 2, 3)
        Notify("Teleportado para " .. target.Name, Color3.fromRGB(0, 200, 255), "info")
    end

    local function acharAssassino()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and getRole(p) == "Murderer" then return p end
        end
    end
    local function acharXerife()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and getRole(p) == "Sheriff" then return p end
        end
    end

    TP:AddSection("Teleportes Rápidos")
    TP:AddButton("🎯 Teleportar para Assassino", function()
        local a = acharAssassino()
        if a then tpTo(a) else Notify("Sem assassino na partida", Color3.fromRGB(255,100,100), "x") end
    end)
    TP:AddButton("👮 Teleportar para Xerife", function()
        local x = acharXerife()
        if x then tpTo(x) else Notify("Sem xerife na partida", Color3.fromRGB(255,100,100), "x") end
    end)
    TP:AddButton("🔫 Teleportar para Arma Caída", function()
        local r = getRoot()
        if not r then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
                r.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                Notify("Teleportado para arma", Color3.fromRGB(255,200,0), "info")
                return
            end
        end
        Notify("Sem arma caída", Color3.fromRGB(255,100,100), "x")
    end)

    --==============================================================
    -- ABA FARM
    --==============================================================
    local Farm = getgenv().Ruan:CreateTab("Farm")

    Farm:AddSection("Auto Coins")
    Farm:AddToggle("Auto Coins", false, function(s) S.AutoCoins = s end)
    Farm:AddButton("Pegar 1 moeda mais próxima", function()
        local r = getRoot()
        if not r then return end
        local closest, dist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then
                local d = (r.Position - obj.Position).Magnitude
                if d < dist then closest = obj dist = d end
            end
        end
        if closest then
            r.CFrame = closest.CFrame + Vector3.new(0, 2, 0)
            Notify("Teleportado pra moeda", Color3.fromRGB(255, 200, 0), "info")
        else
            Notify("Sem moeda próxima", Color3.fromRGB(255,100,100), "x")
        end
    end)

    Farm:AddSection("Auto Gun")
    Farm:AddToggle("Auto Grab Gun", false, function(s) S.AutoGrabGun = s end)
    Farm:AddButton("Pegar arma caída agora", function()
        local r = getRoot()
        if not r then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
                r.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
                return
            end
        end
    end)
end)

--==============================================================
-- AUTO COINS LOOP
--==============================================================
task.spawn(function()
    while task.wait(0.3) do
        if S.AutoCoins then
            local r = getRoot()
            if r then
                local closest, dist = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then
                        local d = (r.Position - obj.Position).Magnitude
                        if d < dist then closest = obj dist = d end
                    end
                end
                if closest and dist < 500 then
                    r.CFrame = closest.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
    end
end)

--==============================================================
-- AUTO GRAB GUN LOOP
--==============================================================
task.spawn(function()
    while task.wait(1) do
        if S.AutoGrabGun then
            local r = getRoot()
            if r then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
                        r.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end
end)

--==============================================================
-- ==================== ABA MISC ================================
--==============================================================

-- ANTI-AFK
local antiAfkConn = nil
local function startAntiAfk()
    if antiAfkConn then return end
    antiAfkConn = LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end
local function stopAntiAfk()
    if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
end

-- SERVER HOP
local function serverHop()
    Notify("Buscando servidor...", Color3.fromRGB(255, 200, 0), "info")
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if not ok then
        Notify("Erro ao buscar", Color3.fromRGB(255,100,100), "x")
        return
    end
    local data = game:GetService("HttpService"):JSONDecode(result)
    if data and data.data then
        for _, s in ipairs(data.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end
    Notify("Sem servidor disponível", Color3.fromRGB(255,100,100), "x")
end

-- REJOIN
local function rejoin()
    Notify("Reconectando...", Color3.fromRGB(255, 200, 0), "info")
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- COPY SCRIPT
local function copyScript()
    if setclipboard then
        setclipboard("loadstring(game:HttpGet('https://raw.githubusercontent.com/miguel12345711/MM2.HUB/main/Ruan.lua'))()")
        Notify("Script copiado!", Color3.fromRGB(0, 200, 100), "check")
    else
        Notify("Copiar não suportado", Color3.fromRGB(255,100,100), "x")
    end
end

task.spawn(function()
    task.wait(1)
    local Misc = getgenv().Ruan:CreateTab("Misc")

    Misc:AddSection("Anti / Boost")
    Misc:AddToggle("Anti-AFK", false, function(s)
        S.AntiAFK = s
        if s then startAntiAfk() else stopAntiAfk() end
    end)

    Misc:AddSection("Servidor")
    Misc:AddButton("🔄 Server Hop", serverHop)
    Misc:AddButton("🔁 Rejoin", rejoin)

    Misc:AddSection("Social")
    Misc:AddButton("📋 Copiar script", copyScript)

    Misc:AddSection("Info")
    Misc:AddButton("⏹️ Descarregar Script", function()
        if getgenv().Ruan.Root then
            getgenv().Ruan.Root:Destroy()
        end
        if flyState.bg then flyState.bg:Destroy() end
        if flyState.bv then flyState.bv:Destroy() end
        stopNoclip()
        stopInvisible()
        stopInfJump()
        stopAntiVoid()
        stopAntiAfk()
        Notify("Script descarregado", Color3.fromRGB(255,100,100), "x")
    end)

    Misc:AddText("Ruan MM2 Hub v2.0")
    Misc:AddText("Executor: " .. (identifyexecutor and identifyexecutor() or "Desconhecido"))

    Notify("Script carregado! Toque no botão 'R'.", Color3.fromRGB(0, 200, 100), "check")
end)

--==============================================================
-- BOTÃO DE ABRIR/FECHAR
--==============================================================
UIS.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if mainWindow.Visible then
            mainWindow.Visible = false
            if getgenv().Ruan.MinBtn then getgenv().Ruan.MinBtn.Visible = true end
        else
            mainWindow.Visible = true
            if getgenv().Ruan.MinBtn then getgenv().Ruan.MinBtn.Visible = false end
        end
    end
end)

print("==================================================")
print("[Ruan MM2 Hub] SCRIPT COMPLETO CARREGADO!")
print("[Ruan MM2 Hub] Abas: Visual, Movement, Teleport, Farm, Misc")
print("[Ruan MM2 Hub] Abrir: RightShift ou botão 'R'")
print("==================================================")
