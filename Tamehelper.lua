-- TameHelper addon
-- Updated for WoW: Midnight (12.0.x)

local TameHelper = CreateFrame("Frame", "TameHelperFrame")

-- Tome / unlock entries.
-- spellID: learned via IsPlayerSpell() after reading the tome
-- questID: learned via quest completion (C_QuestLog.IsQuestFlaggedCompleted)
-- race:    optional; if set, that race gets it for free
-- Both spellID and questID may be set; either being true counts as unlocked.
local tomes = {
    {name = "Blood Beasts",     spellID = 54753,   questID = 0},
    {name = "Direhorns",        spellID = 138430,  questID = 0},
    {name = "Feathermanes",     spellID = 242155,  questID = 0},
    {name = "Cloud Serpents",   spellID = 340826,  questID = 62254},
    {name = "Mechanicals",      spellID = 205154,  questID = 0},
    {name = "Gargons",          spellID = 0,       questID = 61160},
    {name = "Undead",           spellID = 0,       questID = 62255},
    {name = "Lesser Dragonkin", spellID = 0,       questID = 72094},
    {name = "Ottuk",            spellID = 0,       questID = 66444},
    -- Midnight additions --
    {name = "Florafaun",        spellID = 1272785, questID = 0,
     note = "Haranir hunters know this automatically"},
}

local GREEN = "|cFF00FF00"
local RED   = "|cFFFF0000"
local GREY  = "|cFF999999"
local TAG   = GREEN .. "TameHelper:|r "

local function colorYesNo(ok)
    return ok and (GREEN .. "Yes|r") or (RED .. "No|r")
end

function TameHelper:Print(msg)
    print(TAG .. msg)
end

-- Returns true if the player has learned the spell (tome was read account-wide)
function TameHelper:HasLearnedSpell(spellID)
    if not spellID or spellID == 0 then return false end
    return IsPlayerSpell(spellID)
end

-- Returns true if the player has completed the associated quest
function TameHelper:HasCompletedQuest(questID)
    if not questID or questID == 0 then return false end
    return C_QuestLog.IsQuestFlaggedCompleted(questID)
end

-- Returns true if the player is a specific race (e.g. "Haranir" for Florafaun)
function TameHelper:IsRace(raceToken)
    local _, race = UnitRace("player")
    return race == raceToken
end

function TameHelper:HasTomeUnlock(t)
    -- Haranir get Florafaun for free
    if t.name == "Florafaun" and self:IsRace("Haranir") then
        return true
    end
    return self:HasLearnedSpell(t.spellID) or self:HasCompletedQuest(t.questID)
end

function TameHelper:DisplayAvailablePets()
    local _, classToken = UnitClass("player")
    if classToken ~= "HUNTER" then
        self:Print("You are not a Hunter.")
        return
    end

    self:Print("Special taming unlocks:")
    for _, t in ipairs(tomes) do
        local ok   = self:HasTomeUnlock(t)
        local line = ("- %s: %s"):format(t.name, colorYesNo(ok))
        if t.note and not ok then
            line = line .. "  " .. GREY .. "(" .. t.note .. ")|r"
        end
        self:Print(line)
    end

    local spec = GetSpecialization()
    if spec == 1 then
        -- Beast Mastery exotic families (includes Midnight's Whip Tails)
        local exotic = {
            "Chimaeras",
            "Clefthooves",
            "Core Hounds",
            "Devilsaurs",
            "Quilen",
            "Shale Spiders",
            "Silithids",
            "Spirit Beasts",
            "Water Striders",
            "Whip Tails",   -- Added in Midnight
        }
        self:Print("\nExotic families (Beast Mastery only):")
        for _, f in ipairs(exotic) do
            self:Print("- " .. f)
        end
    else
        self:Print(GREY .. "\n(Switch to Beast Mastery to see exotic families.)|r")
    end
end

TameHelper:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:Print("Loaded. Type /tamehelp to check your unlocks.")
    end
end)
TameHelper:RegisterEvent("PLAYER_LOGIN")

SLASH_TAMEHELPER1 = "/tamehelp"
SlashCmdList["TAMEHELPER"] = function()
    TameHelper:DisplayAvailablePets()
end
