--FROSTFORGED REPACK v1.24

-- SERVER SECRET
local serverSecret = randomString(128)
local handlerName = "yQ4CiWjHET"

local prices = {10000, 50000, 100000, 150000, 200000, 350000}

--Functions
local function tContains(table, item)
    local index = 1
    while table[index] do
        if (item == table[index]) then
            return true
        end
        index = index + 1
    end
    return nil
end

local function toTable(string)
    local t = {}
    if string ~= "" then
        for i in string.gmatch(string, "([^,]+)") do
            table.insert(t, tonumber(i))
        end
    end
    return t
end

local function toString(tbl)
    local string = ""
    if #tbl > 1 then
        string = table.concat(tbl, ",")
    elseif #tbl == 1 then
        string = tbl[1]
    end
    return string
end

--Init
local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers(handlerName, {})
local spells, tpells, talents, stats, resets = {}, {}, {}, {}, {}
local AttributesAuraIds = {7464, 7471, 7477, 7468, 7474} -- Strength, Agility, Stamina, Intellect, Spirit

local function SendVars(msg, player, resend)
    local guid = player:GetGUIDLow()
    local sendspells = spells[guid] or ""
    local sendtpells = tpells[guid] or ""
    local sendtalents = talents[guid] or ""
    local sendstats = stats[guid] or "0,0,0,0,0"
    local sendreset = resets[guid] or 0
    AIO.Handle(player, handlerName, "LoadVars", sendspells, sendtpells, sendtalents, sendstats, sendreset, prices, serverSecret, resend)
end

AIO.AddOnInit(SendVars)

--Database Functions
--create DB for GUID
local function DBCreate(guid)
    CharDBQuery("INSERT INTO character_classless VALUES (" .. guid .. ", '', '', '', '0,0,0,0,0', 0)")
end

--Read DB for GUID
local function DBRead(querry)
    local spells, tpells, talents, stats, reset = "", "", "", "0,0,0,0,0", 0
    if querry ~= nil then
        spells = querry:GetString(1)
        tpells = querry:GetString(2)
        talents = querry:GetString(3)
        stats = "0,0,0,0,0"
        reset = querry:GetUInt32(5)
    end
    return spells, tpells, talents, stats, reset
end

--Write DB for GUID
local function DBWrite(guid, entry, value)
    local querry = "UPDATE character_classless SET " .. entry .. "='" .. value .. "' WHERE guid = " .. guid
    CharDBQuery(querry)
    return true
end

--Delete DB for GUID
local function OnDelete(event, guid)
    CharDBQuery("DELETE FROM character_classless WHERE guid = " .. guid)
end

--Utility Functions
local function OnLogin(event, player)
    local guid = player:GetGUIDLow()
    local sp, tsp, tal, sta, reset = "", "", "", "0,0,0,0,0", 0
    local querry = CharDBQuery("SELECT * FROM character_classless WHERE guid = " .. guid)
    if querry == nil then
        DBCreate(guid)
    else
        sp, tsp, tal, sta, reset = DBRead(querry)
    end
    spells[guid] = toTable(sp)
    tpells[guid] = toTable(tsp)
    talents[guid] = toTable(tal)
    stats[guid] = toTable(sta)
    resets[guid] = reset
end

local function OnLogout(event, player)
    local guid = player:GetGUIDLow()
    DBWrite(guid, "spells", toString(spells[guid]))
    DBWrite(guid, "tpells", toString(tpells[guid]))
    DBWrite(guid, "talents", toString(talents[guid]))
    DBWrite(guid, "stats", "0,0,0,0,0")
    DBWrite(guid, "resets", resets[guid])
    spells[guid] = nil
    tpells[guid] = nil
    talents[guid] = nil
    stats[guid] = nil
    resets[guid] = nil
end

RegisterPlayerEvent(2, OnDelete)
RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(4, OnLogout)


local plrs = GetPlayersInWorld()
if plrs then
    for i, player in ipairs(plrs) do
        OnLogin(i, player)
    end
end

function MyHandlers.LearnSpell(player, spr, tpr, clientSecret)
	local isValid = checkSecret(player, clientSecret, serverSecret)
	if not (isValid) then return end
    local guid = player:GetGUIDLow()
    for i = 1, #spr do
        local spell = spr[i]
        if not player:HasSpell(spell) then

            player:LearnSpell(spell)
        end
    end
	for i = 1, #spells[guid] do
  local spell = spells[guid][i]
  if not tContains(spr, spell) then
    player:RemoveSpell(spell)
  end
end
for i = 1, #tpells[guid] do
  local spell = tpells[guid][i]
  if not tContains(spr, spell) then
    player:RemoveSpell(spell)
  end
end
    spells[guid] = spr
    tpells[guid] = tpr
    DBWrite(guid, "spells", toString(spr))
    DBWrite(guid, "tpells", toString(tpr))
    player:SaveToDB()
end

function MyHandlers.LearnTalent(player, tar, clientSecret)
	local isValid = checkSecret(player, clientSecret, serverSecret)
	if not (isValid) then return end
    local guid = player:GetGUIDLow()
    for i = 1, #tar do
        local spell = tar[i]
        if not player:HasSpell(spell) then
            player:LearnSpell(spell)
        end
    end
	for i = 1, #talents[guid] do
  local talent = talents[guid][i]
  if not tContains(tar, talent) then
    player:RemoveSpell(talent)
  end
end
    talents[guid] = tar
    DBWrite(guid, "talents", toString(tar))
    player:SaveToDB()
end



function MyHandlers.WipeAll(player, clientSecret)
	local isValid = checkSecret(player, clientSecret, serverSecret)
    if not (isValid) then return end

    local guid = player:GetGUIDLow()

    rst = resets[guid] + 1
    if (rst > #prices) then
        rst = #prices
    end

    price = prices[rst]
    if (player:GetCoinage() < price) then
        player:SendNotification("Not enough money to reset.")
        return 
    end

    player:ModifyMoney(-price)

    table.sort(spells[guid], function(a, b) return a > b end)
    table.sort(tpells[guid], function(a, b) return a > b end)
    table.sort(talents[guid], function(a, b) return a > b end)
    for i=1,#spells[guid] do
        local spell=spells[guid][i]
        if player:HasSpell(spell) then
            player:RemoveSpell(spell)
        end
    end

    for i=1,#tpells[guid] do
        local spell=tpells[guid][i]
        if player:HasSpell(spell) then
            player:RemoveSpell(spell)
            player:RemoveSpell(spell)
        end
    end

    for i=1,#talents[guid] do
        local spell=talents[guid][i]
        if player:HasSpell(spell) then
            player:RemoveSpell(spell)
        end
    end

    spells[guid]={}
    tpells[guid]={}
    talents[guid]={}
    stats[guid]={0,0,0,0,0}

    resets[guid] = resets[guid] + 1

    DBWrite(guid,"spells","")
    DBWrite(guid,"tpells","")
    DBWrite(guid,"talents","")
    DBWrite(guid,"stats","0,0,0,0,0")
    DBWrite(guid,"resets",resets[guid])
    player:SaveToDB()
    SendVars(AIO.Msg(), player, true)
end

-- Save button 1

function MyHandlers.SaveTalentLoadout(player)
    local guid = player:GetGUIDLow()
    
    -- Get current talents from character_classless table
    local query = CharDBQuery(string.format("SELECT talents FROM character_classless WHERE guid = %d", guid))
    
    if query then
        local currentTalents = query:GetString(0)
        
        -- Check if loadout already exists
        local checkQuery = CharDBQuery(string.format("SELECT guid FROM character_classless_loadouts WHERE guid = %d AND loadout_id = 1", guid))
        
        if checkQuery then
            -- Update existing loadout
            CharDBQuery(string.format("UPDATE character_classless_loadouts SET talents = '%s' WHERE guid = %d AND loadout_id = 1", currentTalents, guid))
        else
            -- Insert new loadout
            CharDBQuery(string.format("INSERT INTO character_classless_loadouts (guid, talents, loadout_id) VALUES (%d, '%s', 1)", guid, currentTalents))
        end
        
        player:SendBroadcastMessage("Talent loadout saved successfully!")
    end
end

-- Save button 1 end

-- Loadout load 1 start

function MyHandlers.LoadTalentLoadout1(player)
    local guid = player:GetGUIDLow()
    
    -- Get current talents to unlearn
    local currentQuery = CharDBQuery(string.format("SELECT talents FROM character_classless WHERE guid = %d", guid))
    if currentQuery then
        local currentTalents = currentQuery:GetString(0)
        local currentTable = toTable(currentTalents)
        
        -- Unlearn current talents
        for i = 1, #currentTable do
            if player:HasSpell(currentTable[i]) then
                player:RemoveSpell(currentTable[i])
            end
        end
        
        -- Get and learn loadout talents
        local loadoutQuery = CharDBQuery(string.format("SELECT talents FROM character_classless_loadouts WHERE guid = %d AND loadout_id = 1", guid))
        if loadoutQuery then
            local loadoutTalents = loadoutQuery:GetString(0)
            local loadoutTable = toTable(loadoutTalents)
            
            -- Learn new talents
            for i = 1, #loadoutTable do
                if not player:HasSpell(loadoutTable[i]) then
                    player:LearnSpell(loadoutTable[i])
                end
            end
            
            -- Update character_classless table with loadout talents
            CharDBQuery(string.format("UPDATE character_classless SET talents = '%s' WHERE guid = %d", loadoutTalents, guid))
            talents[guid] = loadoutTable
            
            player:SendBroadcastMessage("Loadout 1 has been loaded successfully! Be sure to /reload so this change displays properly!")
        else
            player:SendBroadcastMessage("No saved talents found in Loadout 1!")
        end
    end
end

--Loadout load 1 end 

-- Save button 2 start
function MyHandlers.SaveTalentLoadout2(player)
    local guid = player:GetGUIDLow()
    
    -- Get current talents from character_classless table
    local query = CharDBQuery(string.format("SELECT talents FROM character_classless WHERE guid = %d", guid))
    
    if query then
        local currentTalents = query:GetString(0)
        
        -- Check if loadout already exists
        local checkQuery = CharDBQuery(string.format("SELECT guid FROM character_classless_loadouts WHERE guid = %d AND loadout_id = 2", guid))
        
        if checkQuery then
            -- Update existing loadout
            CharDBQuery(string.format("UPDATE character_classless_loadouts SET talents = '%s' WHERE guid = %d AND loadout_id = 2", currentTalents, guid))
        else
            -- Insert new loadout
            CharDBQuery(string.format("INSERT INTO character_classless_loadouts (guid, talents, loadout_id) VALUES (%d, '%s', 2)", guid, currentTalents))
        end
        
        player:SendBroadcastMessage("Talent loadout saved successfully!")
    end
end
-- Save button 2 finished

-- Load button 2 start

function MyHandlers.LoadTalentLoadout2(player)
    local guid = player:GetGUIDLow()
    
    -- Get current talents to unlearn
    local currentQuery = CharDBQuery(string.format("SELECT talents FROM character_classless WHERE guid = %d", guid))
    if currentQuery then
        local currentTalents = currentQuery:GetString(0)
        local currentTable = toTable(currentTalents)
        
        -- Unlearn current talents
        for i = 1, #currentTable do
            if player:HasSpell(currentTable[i]) then
                player:RemoveSpell(currentTable[i])
            end
        end
        
        -- Get and learn loadout talents
        local loadoutQuery = CharDBQuery(string.format("SELECT talents FROM character_classless_loadouts WHERE guid = %d AND loadout_id = 2", guid))
        if loadoutQuery then
            local loadoutTalents = loadoutQuery:GetString(0)
            local loadoutTable = toTable(loadoutTalents)
            
            -- Learn new talents
            for i = 1, #loadoutTable do
                if not player:HasSpell(loadoutTable[i]) then
                    player:LearnSpell(loadoutTable[i])
                end
            end
            
            -- Update character_classless table with loadout talents
            CharDBQuery(string.format("UPDATE character_classless SET talents = '%s' WHERE guid = %d", loadoutTalents, guid))
            talents[guid] = loadoutTable
            
            player:SendBroadcastMessage("Loadout 2 has been loaded successfully! Be sure to /reload so this change displays properly!")
        else
            player:SendBroadcastMessage("No saved talents found in Loadout 2!")
        end
    end
end

-- Load button 2 finished

local function PLAYER_EVENT_ON_SAVE(event, player)
    player:SendBroadcastMessage("You're saved! :)")
end

-- RegisterPlayerEvent( 25, PLAYER_EVENT_ON_SAVE )