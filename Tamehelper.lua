-- TameHelper addon
local TameHelper = CreateFrame("Frame", "TameHelperFrame")

-- Known hunter tomes / unlocks (spellID or questID; 0 = not used)
local tomes = {
  {name="Blood Beasts",        spellID=54753,  questID=0},
  {name="Direhorns",           spellID=138430, questID=0},
  {name="Feathermanes",        spellID=242155, questID=0},
  {name="Cloud Serpents",      spellID=340826, questID=62254},
  {name="Mechanicals",         spellID=205154, questID=0},
  {name="Gargons",             spellID=0,      questID=61160},
  {name="Undead",              spellID=0,      questID=62255},
  {name="Lesser Dragonkin",    spellID=0,      questID=72094},
  {name="Ottuk",               spellID=0,      questID=66444},
}

local GREEN = "|cFF00FF00"
local RED   = "|cFFFF0000"
local TAG   = GREEN .. "TameHelper:|r "

local function colorYesNo(ok)
  return ok and (GREEN .. "Yes|r") or (RED .. "No|r")
end

function TameHelper:Print(msg) print(TAG .. msg) end

function TameHelper:HasLearnedTome(spellID)
  if not spellID or spellID == 0 then return false end
  return IsPlayerSpell(spellID)
end

function TameHelper:HasCompletedTomeQuest(questID)
  if not questID or questID == 0 then return false end
  return C_QuestLog.IsQuestFlaggedCompleted(questID)
end

function TameHelper:DisplayAvailablePets()
  self:Print("You can tame the following types of pets:")
  for _, t in ipairs(tomes) do
    local ok = (t.questID ~= 0) and self:HasCompletedTomeQuest(t.questID)
               or self:HasLearnedTome(t.spellID)
    self:Print(("- %s: %s"):format(t.name, colorYesNo(ok)))
  end

  -- Class/spec context
  local _, classToken = UnitClass("player")
  if classToken ~= "HUNTER" then
    self:Print("\nYou are not a hunter.")
    return
  end

  local spec = GetSpecialization()
  if spec == 1 then
    local exotic = {"Chimaeras","Clefthooves","Core Hounds","Devilsaurs","Quilen","Shale Spiders","Silithids","Spirit Beasts","Water Striders"}
    self:Print("\nExotic pets you can tame as Beast Mastery:")
    for _, f in ipairs(exotic) do self:Print("- " .. f) end
  else
    self:Print("\nYou are not in Beast Mastery spec.")
  end
end

TameHelper:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_LOGIN" then
    self:Print("Loaded. Type /tamehelp to check your unlocks.")
  end
end)

TameHelper:RegisterEvent("PLAYER_LOGIN")

SLASH_TAMEHELPER1 = "/tamehelp"
SlashCmdList.TAMEHELPER = function() TameHelper:DisplayAvailablePets() end
