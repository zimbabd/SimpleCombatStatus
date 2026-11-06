local addonName, addonTable = ...

-- Default Database
local defaultDB = {
    point = "CENTER",
    x = 0,
    y = 150,
    fontSize = 25,
    locked = true,
    lang = "auto",
}

-- Localization Table
local L = {
    enUS = {
        ENTER_COMBAT = "ENTER COMBAT",
        LEAVE_COMBAT = "LEAVE COMBAT",
        DRAG_ME = "DRAG ME",
        LOCKED = "Locked",
        UNLOCKED = "Unlocked - Drag to move",
        FONT_SIZE = "Font size set to",
        USAGE_SIZE = "Usage: /scs size <number>",
        RESET = "Settings reset to default",
        LANG_SET = "Language set to",
        LANG_USAGE = "Usage: /scs lang <code|auto> (e.g., enUS, ruRU, deDE, frFR)",
        HELP_HEADER = "scs Commands:",
        HELP_LOCK = "Lock frame position",
        HELP_UNLOCK = "Unlock frame position",
        HELP_SIZE = "Set font size",
        HELP_RESET = "Reset settings",
        HELP_LANG = "Set language",
    },
    ruRU = {
        ENTER_COMBAT = "НАЧАЛО БОЯ",
        LEAVE_COMBAT = "КОНЕЦ БОЯ",
        DRAG_ME = "ПЕРЕТАЩИ МЕНЯ",
        LOCKED = "Заблокировано",
        UNLOCKED = "Разблокировано - перетащите для перемещения",
        FONT_SIZE = "Размер шрифта установлен на",
        USAGE_SIZE = "Использование: /scs size <число>",
        RESET = "Настройки сброшены по умолчанию",
        LANG_SET = "Язык установлен на",
        LANG_USAGE = "Использование: /scs lang <код|auto> (напр. enUS, ruRU, deDE, frFR)",
        HELP_HEADER = "Команды scs:",
        HELP_LOCK = "Заблокировать позицию",
        HELP_UNLOCK = "Разблокировать позицию",
        HELP_SIZE = "Установить размер шрифта",
        HELP_RESET = "Сбросить настройки",
        HELP_LANG = "Установить язык",
    },
    deDE = {
        ENTER_COMBAT = "KAMPFBEGINN",
        LEAVE_COMBAT = "KAMPFENDE",
        DRAG_ME = "ZIEH MICH",
        LOCKED = "Gesperrt",
        UNLOCKED = "Entsperrt - Zum Verschieben ziehen",
        FONT_SIZE = "Schriftgröße eingestellt auf",
        USAGE_SIZE = "Verwendung: /scs size <Zahl>",
        RESET = "Einstellungen auf Standard zurückgesetzt",
        LANG_SET = "Sprache eingestellt auf",
        LANG_USAGE = "Verwendung: /scs lang <Code|auto> (z. B. enUS, ruRU, deDE, frFR)",
        HELP_HEADER = "scs Befehle:",
        HELP_LOCK = "Rahmenposition sperren",
        HELP_UNLOCK = "Rahmenposition entsperren",
        HELP_SIZE = "Schriftgröße festlegen",
        HELP_RESET = "Einstellungen zurücksetzen",
        HELP_LANG = "Sprache festlegen",
    },
    frFR = {
        ENTER_COMBAT = "Combat",
        LEAVE_COMBAT = "Sorti de combat",
        DRAG_ME = "DÉPLACEZ-MOI",
        LOCKED = "Verrouillé",
        UNLOCKED = "Déverrouillé - Glisser pour déplacer",
        FONT_SIZE = "Taille de la police définie sur",
        USAGE_SIZE = "Utilisation : /scs size <nombre>",
        RESET = "Paramètres réinitialisés par défaut",
        LANG_SET = "Langue définie sur",
        LANG_USAGE = "Utilisation : /scs lang <code|auto> (ex: enUS, ruRU, deDE, frFR)",
        HELP_HEADER = "Commandes scs :",
        HELP_LOCK = "Verrouiller la position du cadre",
        HELP_UNLOCK = "Déverrouiller la position du cadre",
        HELP_SIZE = "Définir la taille de la police",
        HELP_RESET = "Réinitialiser les paramètres",
        HELP_LANG = "Définir la langue",
    }
}

-- Helper to get localized string
local function GetL(key)
    local lang = (zimbaSimpleCombatStatusDB and zimbaSimpleCombatStatusDB.lang) or "auto"
    if lang == "auto" then
        lang = GetLocale()
    end
    
    if L[lang] and L[lang][key] then
        return L[lang][key]
    end
    
    -- Fallback to enUS
    if L["enUS"] and L["enUS"][key] then
        return L["enUS"][key]
    end
    
    return key
end

-- Frame Setup
local frame = CreateFrame("Frame", "scs_MainFrame", UIParent)
frame:SetSize(300, 60)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(false)

-- Background for dragging (only shown when unlocked)
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(frame)
bg:SetColorTexture(0, 0, 1, 0.3)
bg:Hide()

-- Text Setup
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER")
text:SetText("")

-- Timer handle to prevent overlapping
local fadeTimer

-- Helper to update visuals based on DB
local function UpdateFrameVisuals()
    if not zimbaSimpleCombatStatusDB then return end
    
    local db = zimbaSimpleCombatStatusDB
    frame:ClearAllPoints()
    
    -- Safety check for point setting
    local status, err = pcall(function()
        frame:SetPoint(db.point or defaultDB.point, UIParent, db.point or defaultDB.point, db.x or defaultDB.x, db.y or defaultDB.y)
    end)
    if not status then
        frame:SetPoint(defaultDB.point, UIParent, defaultDB.point, defaultDB.x, defaultDB.y)
    end
    
    -- Update Font
    local fontPath, _, fontFlags = text:GetFont()
    if fontPath then
        local fontSize = tonumber(db.fontSize) or defaultDB.fontSize
        text:SetFont(fontPath, fontSize, "OUTLINE")
    end
    
    -- Update Lock State
    if db.locked then
        frame:EnableMouse(false)
        bg:Hide()
    else
        frame:EnableMouse(true)
        bg:Show()
    end
end

local function ShowCombatStatus(msg, r, g, b)
    if fadeTimer then
        fadeTimer:Cancel()
        fadeTimer = nil
    end
    
    text:SetText(msg)
    text:SetTextColor(r, g, b)
    
    -- Reset alpha and show
    frame:SetAlpha(1)
    frame:Show()
    
    -- Fade out after 3 seconds
    fadeTimer = C_Timer.NewTimer(3, function()
        UIFrameFadeOut(frame, 0.5, 1, 0)
        fadeTimer = nil
    end)
end

-- Dragging handlers
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not zimbaSimpleCombatStatusDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    zimbaSimpleCombatStatusDB.point = point
    zimbaSimpleCombatStatusDB.x = x
    zimbaSimpleCombatStatusDB.y = y
end)

-- Combat Events
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Leaving combat
frame:RegisterEvent("ADDON_LOADED")

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize DB
        if not zimbaSimpleCombatStatusDB then
            zimbaSimpleCombatStatusDB = {}
        end
        for k, v in pairs(defaultDB) do
            if zimbaSimpleCombatStatusDB[k] == nil then
                zimbaSimpleCombatStatusDB[k] = v
            end
        end
        UpdateFrameVisuals()
        self:UnregisterEvent("ADDON_LOADED")
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        ShowCombatStatus(GetL("ENTER_COMBAT"), 1, 0, 0)
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        ShowCombatStatus(GetL("LEAVE_COMBAT"), 0, 1, 0)
    end
end

frame:SetScript("OnEvent", OnEvent)

-- Slash Commands
SLASH_ZIMBASCS1 = "/scs"
SlashCmdList["ZIMBASCS"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()
    
    if cmd == "lock" then
        zimbaSimpleCombatStatusDB.locked = true
        UpdateFrameVisuals()
        print("|cff00ff00scs: " .. GetL("LOCKED") .. "|r")
        
    elseif cmd == "unlock" then
        zimbaSimpleCombatStatusDB.locked = false
        UpdateFrameVisuals()
        text:SetText(GetL("DRAG_ME"))
        text:SetTextColor(1, 1, 1)
        frame:SetAlpha(1)
        frame:Show()
        print("|cff00ff00scs: " .. GetL("UNLOCKED") .. "|r")
        
    elseif cmd == "size" then
        local newSize = tonumber(arg)
        if newSize and newSize > 0 then
            zimbaSimpleCombatStatusDB.fontSize = newSize
            UpdateFrameVisuals()
            print("|cff00ff00scs: " .. GetL("FONT_SIZE") .. " " .. newSize .. "|r")
        else
            print("|cffff0000scs: " .. GetL("USAGE_SIZE") .. "|r")
        end
        
    elseif cmd == "reset" then
        zimbaSimpleCombatStatusDB = {}
        for k, v in pairs(defaultDB) do
            zimbaSimpleCombatStatusDB[k] = v
        end
        UpdateFrameVisuals()
        print("|cff00ff00scs: " .. GetL("RESET") .. "|r")

    elseif cmd == "lang" then
        if arg ~= "" then
            zimbaSimpleCombatStatusDB.lang = arg
            print("|cff00ff00scs: " .. GetL("LANG_SET") .. " " .. arg .. "|r")
        else
            print("|cffff0000scs: " .. GetL("LANG_USAGE") .. "|r")
        end

    else
        print("|cffffff00" .. GetL("HELP_HEADER") .. "|r")
        print("  /scs lock - " .. GetL("HELP_LOCK"))
        print("  /scs unlock - " .. GetL("HELP_UNLOCK"))
        print("  /scs size <number> - " .. GetL("HELP_SIZE"))
        print("  /scs reset - " .. GetL("HELP_RESET"))
        print("  /scs lang <code|auto> - " .. GetL("HELP_LANG"))
    end
end

-- Initial Hide
frame:Hide()
