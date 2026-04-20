-- TameHelper addon
-- Updated for WoW: Midnight (12.0.x)

local TameHelper = CreateFrame("Frame", "TameHelperFrame")

-- Helper: build a chat-clickable item link for tooltip-on-hover
local function itemLink(itemID, label)
    return ("|cff0070dd|Hitem:%d:::::::::::::|h[%s]|h|r"):format(itemID, label)
end

-- Tome / unlock entries.
-- spellID:      learned via IsPlayerSpell() after reading the tome
-- questID:      learned via quest completion (C_QuestLog.IsQuestFlaggedCompleted)
-- itemID:       used to generate a hoverable tooltip link in chat (optional)
-- itemName:     display name inside the item link
-- defaultRaces: table of UnitRace tokens that get this unlock for free
-- perCharacter: true if this unlock does NOT carry over to other hunters automatically
-- bmOnly:       true if this unlock requires Beast Mastery spec to actually use
-- hint:         plain-text fallback shown when no itemID is available
local tomes = {
    {
        name         = "Blood Beasts",
        spellID      = 54753,
        questID      = 0,
        itemID       = 166502,
        itemName     = "Blood-Soaked Tome of Dark Whispers",
        defaultRaces = {},
        hint         = "Drops from Zul in Uldir (Normal+)",
    },
    {
        name         = "Direhorns",
        spellID      = 138430,
        questID      = 0,
        itemID       = 94232,
        itemName     = "Ancient Tome of Dinomancy",
        defaultRaces = {"ZandalariTroll"},
        perCharacter = true,
        hint         = "Rare drop from Zandalari Dinomancers, Isle of Giants",
    },
    {
        name         = "Feathermanes",
        spellID      = 242155,
        questID      = 0,
        itemID       = 147580,
        itemName     = "Tome of the Hybrid Beast",
        defaultRaces = {},
        perCharacter = true,
        hint         = "Requires Legion Order Hall mount on one hunter first. That hunter purchases copies for 1000 Order Resources each and sends them via Warband Bank.",
    },
    {
        name         = "Cloud Serpents",
        spellID      = 340826,
        questID      = 62254,
        itemID       = 183123,
        itemName     = "How to School Your Serpent",
        defaultRaces = {"Pandaren"},
        hint         = "Buy from San Redscale in Jade Forest (Exalted, Order of the Cloud Serpent)",
    },
    {
        name         = "Mechanicals",
        spellID      = 205154,
        questID      = 0,
        itemID       = 134125,
        itemName     = "Mecha-Bond Imprint Matrix",
        defaultRaces = {"Gnome", "Goblin", "Mechagnome"},
        perCharacter = true,
        hint         = "Crafted by Engineers or bought on the Auction House",
    },
    {
        name         = "Gargons",
        spellID      = 0,
        questID      = 61160,
        itemID       = 180705,
        itemName     = "Gargon Training Manual",
        defaultRaces = {},
        bmOnly       = true,
        hint         = "Drops from Huntmaster Petrus in Revendreth",
    },
    {
        name         = "Undead",
        spellID      = 0,
        questID      = 62255,
        itemID       = 183124,
        itemName     = "Simple Tome of Bone-Binding",
        defaultRaces = {"Scourge"},
        hint         = "Drops from elites in Maldraxxus, Plaguefall, or Theater of Pain",
    },
    {
        name         = "Lesser Dragonkin",
        spellID      = 0,
        questID      = 72094,
        itemID       = 201791,
        itemName     = "How to Train a Dragonkin",
        defaultRaces = {"Dracthyr"},
        hint         = "Quest reward at Valdrakken Accord Renown 23",
    },
    {
        name         = "Ottuk",
        spellID      = 390631,
        questID      = 66444,
        itemID       = 0,
        itemName     = "",
        defaultRaces = {},
        hint         = "Complete 'A Lost Tribe' questline (Iskaara Tuskarr Renown 11, Azure Span)",
    },
    -- Midnight additions --
    {
        name         = "Florafaun",
        spellID      = 1272785,
        questID      = 0,
        itemID       = 264895,
        itemName     = "Trials of the Florafaun Hunter",
        defaultRaces = {"Haranir"},
        hint         = "Drops from florafaun rares in Harandar",
    },
}

local GREEN  = "|cFF00FF00"
local RED    = "|cFFFF0000"
local GREY   = "|cFF999999"
local GOLD   = "|cFFFFD100"
local ORANGE = "|cFFFF8000"
local TAG    = GREEN .. "TameHelper:|r "

local function colorYesNo(ok)
    return ok and (GREEN .. "Yes|r") or (RED .. "No|r")
end

function TameHelper:Print(msg)
    print(TAG .. msg)
end

function TameHelper:HasLearnedSpell(spellID)
    if not spellID or spellID == 0 then return false end
    return IsPlayerSpell(spellID)
end

function TameHelper:HasCompletedQuest(questID)
    if not questID or questID == 0 then return false end
    return C_QuestLog.IsQuestFlaggedCompleted(questID)
end

function TameHelper:GetPlayerRace()
    local _, race = UnitRace("player")
    return race
end

function TameHelper:IsDefaultRace(t)
    local race = self:GetPlayerRace()
    for _, r in ipairs(t.defaultRaces) do
        if race == r then return true end
    end
    return false
end

function TameHelper:HasTomeUnlock(t)
    return self:IsDefaultRace(t)
        or self:HasLearnedSpell(t.spellID)
        or self:HasCompletedQuest(t.questID)
end

function TameHelper:DisplayAvailablePets()
    local _, classToken = UnitClass("player")
    if classToken ~= "HUNTER" then
        self:Print("You are not a Hunter.")
        return
    end

    local race = self:GetPlayerRace()
    local spec = GetSpecialization()
    local isBM = (spec == 1)

    self:Print("Special taming unlocks:")
    for _, t in ipairs(tomes) do
        local isDefault = self:IsDefaultRace(t)
        local ok        = isDefault or self:HasLearnedSpell(t.spellID) or self:HasCompletedQuest(t.questID)

        local line = ("- %s: %s"):format(t.name, colorYesNo(ok))

        if ok then
            if isDefault then
                line = line .. "  " .. GREY .. "(" .. race .. " default)|r"
            end
            -- Warn non-BM hunters that they can't use this even though it's unlocked
            if t.bmOnly and not isBM then
                line = line .. "  " .. RED .. "(Beast Mastery only!)|r"
            end
        else
            -- Show how to get it
            if t.itemID and t.itemID ~= 0 then
                line = line .. "  " .. itemLink(t.itemID, t.itemName)
            else
                line = line .. "  " .. GOLD .. t.hint .. "|r"
            end
            -- Add BM warning on No entries too so they know spec is also required
            if t.bmOnly then
                line = line .. "  " .. RED .. "(Beast Mastery only!)|r"
            end
        end

        -- Per character warning on Yes entries
        if ok and t.perCharacter then
            line = line .. "  " .. ORANGE .. "(per hunter — not account wide)|r"
        end

        self:Print(line)
    end

    if isBM then
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
