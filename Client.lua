--FROSTFORGED REPACK v1.24

local AIO = AIO or require("AIO")

-- CLIENT SECRET
local clientSecret = ""
local handlerName = "yQ4CiWjHET"

--|TInterface/ICONS/VAS_RaceChange:35:35|t
local LastContainerNum = 1
-- Settings
local iconSize = 52
local leftConst = 172
local itemsPerRow = 7
local current_class = 1
local current_spec = 1
local prices = {}

-- Ready-to-use for the system

local classes = {"Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior", "Deathknight","MONK", "DEMONHUNTER"};
local class_list = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR", "DEATHKNIGHT"}
local spell_point_list = {}
local talent_point_list = {}


--Data
if AIO.IsServer() then
    --Spells
    AIO.AddAddon("lua_scripts\\ClassLess\\data\\spells.data", "spells")
    --Talents
    AIO.AddAddon("lua_scripts\\ClassLess\\data\\talents.data", "talents")
    --Locks
    AIO.AddAddon("lua_scripts\\ClassLess\\data\\locks.data", "locks")
    --Requirements
    AIO.AddAddon("lua_scripts\\ClassLess\\data\\req.data", "req")
end

if AIO.AddAddon() then
    return
end

--Variables

local spellsplus, spellsminus = {}, {}
local tpellsplus, tpellsminus = {}, {}
local talentsplus, talentsminus = {}, {}
local db = CLDB

--Functions

local function CountSpellPoints(c, s)
	local r = 0
	for k,v in pairs(db.data.spells[class_list[c]][s][4]) do
		--check if v[1][1] in db.spells, if so r++
		if tContains(db.spells, v[1][1]) then 
			r = r + 1
		end
	end
	return r
end

local function CountTalentPoints(c, s)
	local r = 0
	for k,v in pairs(db.data.talents[class_list[c]][s][4]) do
		--check if v[1][1] in db.spells, if so r++
		for i,j in pairs(v[1]) do
			if tContains(db.talents, j) then 
				r = r + 1
			end
		end
	end
	return r	
end

local function UpdatePointText()
	for k,v in pairs(class_list) do --zeta
        local cap = 0
        local ctp = 0
        for i = 1, 3 do 
            local ap = CountSpellPoints(k, i)
            cap = cap + ap
            local tp = CountTalentPoints(k,i)
            ctp = ctp + tp
            for j = 1, 2 do
                _G["CLContainer"..j.."Sub"..k.."SubButton"..i].text:SetText()
                _G["CLContainer"..j.."Sub"..k.."SubButton"..i].text2:SetText()
            end
        end
        for j = 1, 2 do 
            _G["CLContainer"..j.."SubButton"..k].text:SetText()	
            _G["CLContainer"..j.."SubButton"..k].text2:SetText()	
        end
    end
end

local function FrameToggle(frame)
    local f = _G[frame]
    if f ~= nil then
        if f:IsVisible() ~= 1 then
            f:Show()
        elseif f:IsVisible() == 1 then
            f:Hide()
        end
    end
end

local function FrameShow(fname)
    local frame = fname
    if type(fname) ~= "table" then
        frame = _G[fname]
    end
    if frame ~= nil and frame:IsVisible() ~= 1 then
        frame:Show()
    end
end

local function FrameHide(fname)
    local frame = fname
    if type(fname) ~= "table" then
        frame = _G[fname]
    end
    if frame ~= nil and frame:IsVisible() == 1 then
        frame:Hide()
    end
end

--DoShit Function
local function DoShit()
    --Table Functions
    local function tCopy(t)
        local u = {}
        for k, v in pairs(t) do
            u[k] = v
        end
        return setmetatable(u, getmetatable(t))
    end

    local function tRemoveKey(table, key)
        for i = 1, #table do
            if table[i] == key then
                tremove(table, i)
            end
        end
    end

    local function tCompare(t1, t2)
        if #t1 ~= #t2 then
            return false
        end
        for i = 1, #t1 do
            if t1[i] ~= t2[i] then
                return false
            end
        end
        return true
    end

    local function pairsSort(t, f)
        local a = {}
        for n in pairs(t) do
            table.insert(a, n)
        end
        table.sort(a, f)
        local i = 0
        local iter = function()
            i = i + 1
            if a[i] == nil then
                return nil
            else
                return a[i], t[a[i]]
            end
        end
        return iter
    end

    --Frame Creation Functions
    local function CreateTexture(base, layer, path, blend)
        local t = base:CreateTexture(nil, layer)
        if path then
            t:SetTexture(path)
        end
        if blend then
            t:SetBlendMode(blend)
        end
        return t
    end

    local function FrameBackground(frame, background)
        local t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT")
        frame.topleft = t

        t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT", frame.topleft, "TOPRIGHT")
        frame.topright = t

        t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT", frame.topleft, "BOTTOMLEFT")
        frame.bottomleft = t

        t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT", frame.topleft, "BOTTOMRIGHT")
        frame.bottomright = t
       -- frame.topleft:SetTexture(background .. "-TopLeft")
        --frame.topright:SetTexture(background .. "-TopRight")
       -- frame.bottomleft:SetTexture(background .. "-BottomLeft")
        --frame.bottomright:SetTexture(background .. "-BottomRight")
    end

    local function FrameLayout(frame, width, height)
        local texture_height = height / (256 + 75)
        local texture_width = width / (256 + 44)

        frame:SetSize(width, height)

        local wl, wr, ht, hb = texture_width * 256, texture_width * 64, texture_height * 256, texture_height * 128

        frame.topleft:SetSize(wl, ht)
        frame.topright:SetSize(wr, ht)
        frame.bottomleft:SetSize(wl, hb)
        frame.bottomright:SetSize(wr, hb)
    end

    local function MakeButton(name, parent) --gamma
        local button = CreateFrame("Button", name, parent)
        button:SetNormalFontObject(GameFontNormal)
        button:SetHighlightFontObject(GameFontHighlight)
        button:SetDisabledFontObject(GameFontDisable)
		if name == "CLButton1" or name == "CLButton2" then
			local texture = button:CreateTexture("BACKGROUND")
			if name == "CLButton1" then
				texture:SetTexture("")
			else
				texture:SetTexture("Interface\\Minimap\\TRACKING\\Class")
			end
       		-- texture:SetTexCoord(0, 0.625, 0, 0.6875)
			local size = button:GetSize()
        	texture:SetAllPoints()
			texture:SetSize(1.5 * size, 1.5 * size)
        	button.texture = texture
        	--[[texture = button:CreateTexture("ARTWORK")
        	texture:SetTexture("Interface\\Buttons\\CLCircle")
			--texture:SetTexCoord(0, 0.625, 0, 0.6875)
        	texture:SetPoint("CENTER")
			texture:SetSize(0.7 * size, 0.7 * size)
			button.normal = texture
			button:SetNormalTexture(texture)

			texture = button:CreateTexture("ARTWORK")
			texture:SetTexture("Interface\\Buttons\\CLCircleActive")
			texture:SetPoint("CENTER")
			texture:SetSize(0.7 * size, 0.7 * size)
        	button.pushed = texture
        	button:SetPushedTexture(texture)
			]]
        	--[[texture = button:CreateTexture()
        	texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Highlight"
       		-- texture:SetTexCoord(0, 0.625, 0, 0.6875)
        	texture:SetAllPoints(button)
        	button:SetHighlightTexture(texture)]]
		else
		 	local texture = button:CreateTexture()
        	texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Up"
        	texture:SetTexCoord(0, 0.625, 0, 0.6875)
        	texture:SetAllPoints(button)
        	button.normal = texture
        	button:SetNormalTexture(texture)
        	texture = button:CreateTexture()
        	texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Down"
        	texture:SetTexCoord(0, 0.625, 0, 0.6875)
        	texture:SetAllPoints(button)
        	button.pushed = texture
        	button:SetPushedTexture(texture)
        	texture = button:CreateTexture()
        	texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Highlight"
        	texture:SetTexCoord(0, 0.625, 0, 0.6875)
        	texture:SetAllPoints(button)
        	button:SetHighlightTexture(texture)
		end
        return button
    end

    local function MakeRankFrame(button, anchor)
        --local t = CreateTexture(button, "OVERLAY", "Interface\\Textures\\border")
        t:SetSize(32, 32)
        t:SetPoint("CENTER", button, anchor)
        local fs = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        --fs.texture = t
        fs:SetPoint("TOP", button, "BOTTOM", 0, -2)
        return fs
    end

    local function NewButton(name, parent, size, icon, rank, a, b, c, d, empty)
        local button = CreateFrame("Button", name, parent)
        -- ItemButtonTemplate (minus Count and Slot)
        button:SetSize(size, size)
        local t = CreateTexture(button, "BORDER")
        t:SetSize(size * 0.8, size * 0.8)
        t:SetPoint("CENTER")
        button.texture = t
		if(empty == nil) then
			t = CreateTexture(button, nil, "Interface\\Buttons\\CLCircle")
			t:SetSize(size * 1.2, size * 1.2)
			t:SetPoint("CENTER")
			button.normal = t
			button:SetNormalTexture(t)
			t = CreateTexture(button, nil, "Interface\\Buttons\\CLCircleActive")
			t:SetSize(size * 1.2, size * 1.2)
			t:SetPoint("CENTER")
			button.pushed = t
			button:SetPushedTexture(t)
			--[[t = CreateTexture(button, nil, "Interface\\Buttons\\ButtonHilight-Square", "ADD")
			t:SetSize(size, size)
			t:SetPoint("CENTER")
			button:SetHighlightTexture(t)]]
			-- TalentButtonTemplate
			--[[local texture = CreateTexture(button, "BACKGROUND", "Interface\\Buttons\\UI-EmptySlot-White")
			texture:SetSize(size * 1.7, size * 1.7)
			texture:SetPoint("CENTER")
			button.slot = texture]]
		end
        if rank ~= nil then
            button.rank = MakeRankFrame(button, "BOTTOMRIGHT")
        end

        if icon ~= nil then
            button.texture:SetTexture(icon)
            if a ~= nil then
                button.texture:SetTexCoord(a, b, c, d)
            end
        end
        return button
    end

    --Utility Functions
    function GetPoints(type)
        if type == "ap" then
            local ap = math.floor(UnitLevel("player") * 0.45) - #db.spells
            local tap = #spellsplus
            return ap - tap, tap
        end

        if type == "tp" then
            local tp = UnitLevel("player") - 9
            if tp < 0 then
                tp = 0
            end
            tp = tp - (#db.talents + #db.tpells)
            local ttp = #talentsplus + #tpellsplus
            return tp - ttp, ttp
        end
        return 0, 0
    end
    --main Frame Functions
    local function SelectTab(tab, cname, pname, bname)
        if tab ~= 0 then
            local parent = _G[pname]
            local ltab = parent:GetAttribute("tab")

            local button, lbutton = _G[bname .. tab], _G[bname .. ltab]
            local child, lchild = _G[cname .. tab], _G[cname .. ltab]
            if lchild ~= nil then
                FrameHide(lchild)
            end
            if lbutton ~= nil then
                lbutton:SetButtonState("NORMAL")
            end
            if button ~= nil then
                button:SetButtonState("PUSHED", true)
            end
            if child ~= nil then
                FrameShow(child)
            end
            parent:SetAttribute("tab", tab)
        end
    end

    local function LearnConfirm(action, state)
        local tab = _G["CLMainFrame"]:GetAttribute("tab")
        if tab ~= nil and tab > 0 then
            if action == "Apply" and state ~= "true" then
                StaticPopup_Show("LEARN_CONFIRM")
            end
            if action == "Reset" and state ~= "true" then
                StaticPopup_Show("RESET_CONFIRM")
            end

            if action == "Apply" and state == "true" then
                if tab == 1 then
                    for i = 1, #spellsplus do
                        if not tContains(db.spells, spellsplus[i]) then
                            tinsert(db.spells, spellsplus[i])
                        end
                    end
                    for i = 1, #tpellsplus do
                        if not tContains(db.tpells, tpellsplus[i]) then
                            tinsert(db.tpells, tpellsplus[i])
                        end
                    end
					for i=1, #spellsminus do
  if tContains(db.spells, spellsminus[i]) then
    tRemoveKey(db.spells, spellsminus[i])
  end
end
for i=1, #tpellsminus do
  if tContains(db.tpells, tpellsminus[i]) then
    tRemoveKey(db.tpells, tpellsminus[i])
  end
end
                    wipe(spellsplus)
                    wipe(spellsminus)
                    wipe(tpellsplus)
                    wipe(tpellsminus)
                    sort(db.spells)
                    sort(db.tpells)
                    AIO.Handle(handlerName, "LearnSpell", db.spells, db.tpells, clientSecret)
				end

                if tab == 2 then
                    for i = 1, #talentsplus do
                        if not tContains(db.talents, talentsplus[i]) then
                            tinsert(db.talents, talentsplus[i])
                        end
                    end
					for i=1, #talentsminus do
  if tContains(db.talents, talentsminus[i]) then
    tRemoveKey(db.talents, talentsminus[i])
  end
end
                    wipe(talentsplus)
                    wipe(talentsminus)
                    sort(db.talents)
                    AIO.Handle(handlerName, "LearnTalent", db.talents, clientSecret)
                end
				
               
            end

            if action == "Reset" and state == "true" then
                if tab == 1 then
                    wipe(spellsplus)
                    wipe(spellsminus)
                    wipe(tpellsplus)
                    wipe(tpellsminus)
                end

                if tab == 2 then
                    wipe(talentsplus)
                    wipe(talentsminus)
                end

            end
			UpdatePointText()
            SelectTab(tab, "CLContainer", "CLMainFrame", "CLButton")
        end
    end

    ------Fill Spells Functions
    local function TempLearnSpell(spell, talent)
        if tContains(spellsminus, spell) then
            tRemoveKey(spellsminus, spell)
        end
        if not tContains(spellsplus, spell) then
            tinsert(spellsplus, spell)
        end
        if talent == 1 then
            if tContains(tpellsminus, spell) then
                tRemoveKey(tpellsminus, spell)
            end
            if not tContains(tpellsplus, spell) then
                tinsert(tpellsplus, spell)
            end
        end
    end

    local function TempUnlearnSpell(spell, talent)
        if tContains(spellsplus, spell) then
            tRemoveKey(spellsplus, spell)
        end
        if not tContains(spellsminus, spell) then
            tinsert(spellsminus, spell)
        end
        if talent == 1 then
            if tContains(tpellsplus, spell) then
                tRemoveKey(tpellsplus, spell)
            end
            if not tContains(tpellsminus, spell) then
                tinsert(tpellsminus, spell)
            end
        end
    end

    local function TempLearnTalent(spell, talent)
        if tContains(talentsminus, spell) then
            tRemoveKey(talentsminus, spell)
        end
        if not tContains(talentsplus, spell) then
            tinsert(talentsplus, spell)
        end
    end

    local function TempUnlearnTalent(spell, talent)
        if tContains(talentsplus, spell) then
            tRemoveKey(talentsplus, spell)
        end
        if not tContains(talentsminus, spell) then
            tinsert(talentsminus, spell)
        end
    end

    local function ParseTooltip(spell)
        local f = CreateFrame("GameTooltip", "CLTmpTooltip", UIParent, "GameTooltipTemplate")
        f:SetOwner(UIParent, "ANCHOR_NONE")
        local link = GetSpellLink(spell)
        if link == nil then
            link = GetSpellLink(78)
            link = gsub(link, "78", spell)
        end
        f:SetHyperlink(link)

        local t = {}

        for i = 1, select("#", f:GetRegions()) do
            local ttl = _G["CLTmpTooltipTextLeft" .. i]
            local ttr = _G["CLTmpTooltipTextRight" .. i]
            if (ttl ~= nil and ttl:GetText() ~= nil) and (ttr ~= nil and ttr:GetText() ~= nil) then
                tinsert(t, {ttl:GetText(), ttr:GetText()})
            elseif (ttl ~= nil and ttl:GetText() ~= nil) then
                tinsert(t, ttl:GetText())
            end
        end

        f:ClearLines()
        f:Hide()
        return t
    end

    local function ButtonTooltip(button, spell, nspell, rank, ranks, level, lcolor, ccolor, state, cost, lock, req, rreq)
        local bname = button:GetName()
        local pt = ParseTooltip(spell)
        local c = RED_FONT_COLOR
        button.tooltip =
            _G[bname .. "tooltip"] or CreateFrame("GameTooltip", bname .. "tooltip", button, "GameTooltipTemplate")

        button:SetScript(
            "OnEnter",
            function()
                button.tooltip:Hide()
                button.tooltip:SetOwner(button, "ANCHOR_RIGHT")
                local link = GetSpellLink(nspell)
                if link == nil then
                    link = GetSpellLink(78)
                    link = gsub(link, "78", nspell)
                end
                button.tooltip:SetHyperlink(link)
                button.tooltip:AddDoubleLine("Current rank", rank .. "/" .. ranks, 1, 1, 1, 1, 1, 1)
                if pt[#pt] ~= nil and rank > 0 and ranks > 1 and rank ~= ranks then
                    button.tooltip:AddLine(pt[#pt], nil, nil, nil, true)
                end

                if rreq ~= nil then
                    button.tooltip:AddLine(rreq, c.r, c.g, c.b)
                end
                if rank < ranks then
                    if req ~= nil then
                        button.tooltip:AddLine(req, c.r, c.g, c.b)
                    end
                    if lock ~= nil then
                        button.tooltip:AddLine(lock, c.r, c.g, c.b)
                    end
                    if level ~= nil then
                        button.tooltip:AddLine("Requires level " .. level, lcolor.r, lcolor.g, lcolor.b)
                    end
                    button.tooltip:AddLine(cost, ccolor.r, ccolor.g, ccolor.b)
                end
                button.tooltip:AddLine("SPELLID: " .. spell)
                button.tooltip:Show()
            end
        )

        button:SetScript(
            "OnLeave",
            function()
                button.tooltip:Hide()
            end
        )
    end

    local function FillSpells(class, spec, parent, mode)
        local spells, eqt, spellcheck

        local spellcheck1 = tCopy(db.spells)
        for i = 1, #spellsplus do
            if not tContains(spellcheck1, spellsplus[i]) then
                tinsert(spellcheck1, spellsplus[i])
            else
                tremove(spellsplus, i)
            end
        end
        for i = 1, #spellsminus do
            if tContains(spellcheck1, spellsminus[i]) then
                tRemoveKey(spellcheck1, spellsminus[i])
            else
                tremove(spellsminus, i)
            end
        end

        local spellcheck2 = tCopy(db.talents)
        for i = 1, #talentsplus do
            if not tContains(spellcheck2, talentsplus[i]) then
                tinsert(spellcheck2, talentsplus[i])
            else
                tremove(talentsplus, i)
            end
        end
        for i = 1, #talentsminus do
            if tContains(spellcheck2, talentsminus[i]) then
                tRemoveKey(spellcheck2, talentsminus[i])
            else
                tremove(talentsminus, i)
            end
        end

        local allspells = tCopy(spellcheck1)
        for i = 1, #spellcheck2 do
            if not tContains(allspells, spellcheck2[i]) then
                tinsert(allspells, spellcheck2[i])
            end
        end

        if mode == "spell" then
            spells = db.data.spells[class][spec][4]
            eqt = "false"
            if tCompare(db.spells, spellcheck1) then
                eqt = "true"
            end
            spellcheck = spellcheck1
        else
            spells = db.data.talents[class][spec][4]
            eqt = "false"
            if tCompare(db.talents, spellcheck2) then
                eqt = "true"
            end
            spellcheck = spellcheck2
        end

        local left, top = leftConst, -12

        for i = 1, #spells do
            local spellid, levelid = spells[i][1], spells[i][2]

            local prank, rank, nrank, ranks, spell, nspell, nlevel
            rank, ranks = 0, #spellid

            for j = 1, ranks do
                if tContains(spellcheck, spellid[j]) then
                    rank = j
                end
            end

            if rank > 0 then
                spell = spellid[rank]
            else
                rank = 0
                spell = spellid[1]
            end
            if rank + 1 <= ranks then
                nspell, nlevel, nrank = spellid[rank + 1], levelid[rank + 1], rank + 1
            else
                nspell, nlevel, nrank = spellid[rank], levelid[rank], rank
            end
            prank = rank - 1

            local icon = ({GetSpellInfo(nspell)})[3]
			if nspell == 75 then icon = "Interface/Icons/Ability_Whirlwind" end
            local button =
                _G["CLSpellsClass" .. class .. "Spec" .. spec .. mode .. i] or
                NewButton("CLSpellsClass" .. class .. "Spec" .. spec .. mode .. i, parent, iconSize, icon, "true")
            button:SetButtonState("NORMAL", "true")
            button:SetPoint("TOPLEFT", left, top)
            if button:GetAttribute("hrank") == nil or eqt == "true" then
                button:SetAttribute("hrank", rank)
            end
			if mode == "spell" then
				if spell_point_list[class] == nil then
					spell_point_list[class] = {}
				end
				if spell_point_list[class][spec] == nil then
					spell_point_list[class][spec] = {}
				end
				spell_point_list[class][spec][icon] = rank
			else
				if talent_point_list[class] == nil then
					talent_point_list[class] = {}
				end
				if talent_point_list[class][spec] == nil then
					talent_point_list[class][spec] = {}
				end
				talent_point_list[class][spec][icon] = rank 
			end
            local hrank = button:GetAttribute("hrank")

            local state, saturated, color, acost, tcost, lock, req, rreq =
                "normal",
                0,
                GREEN_FONT_COLOR,
                1,
                0,
                nil,
                nil,
                nil
            local ap, tp = GetPoints("ap"), GetPoints("tp")
            local lcolor, ccolor = color, color
            local nacost, ntcost = acost, tcost
            local ncost

            if rank == 1 and spells[i][4] == 1 then
                tcost = 1
            end
            if nrank == 1 and spells[i][4] == 1 then
                ntcost = 1
            end

            if rank == ranks then
                state = "full"
            end

            if state ~= "full" then
                if UnitLevel("player") < nlevel then
                    state = "disabled"
                    lcolor = RED_FONT_COLOR
                end

                if mode == "spell" then
                    if ap < nacost or tp < ntcost then
                        state = "disabled"
                        ccolor = RED_FONT_COLOR
                    end
                else
                    if tp < nacost or ap < ntcost then
                        state = "disabled"
                        ccolor = RED_FONT_COLOR
                    end
                end

                if db.locks[spell] ~= nil then
                    for h = 1, #db.locks[spell] do
                        if tContains(allspells, db.locks[spell][h]) then
                            state = "disabled"
                            lock = 'Locked by "' .. ({GetSpellInfo(db.locks[spell][h])})[1] .. '" ' .. mode
                            break
                        end
                    end
                end

                if db.req[nspell] ~= nil then
                    local reqs, reqr = ({GetSpellInfo(db.req[nspell])})[1], ({GetSpellInfo(db.req[nspell])})[2]
                    if not tContains(allspells, db.req[nspell]) then
                        state = "disabled"
                        req = "req " .. mode .. ' "' .. reqs
                        if reqr ~= "" then
                            req = req .. "(" .. reqr .. ')"'
                        else
                            req = req .. '"'
                        end
                    end
                end
            end

            if db.rreq[spell] ~= nil then
                local rreqs, rreqr = ({GetSpellInfo(db.rreq[spell])})[1], ({GetSpellInfo(db.rreq[spell])})[2]
                if tContains(allspells, db.rreq[spell]) and rank ~= hrank then
                    state = "req"
                    rreq = "Required for " .. mode .. ' "' .. rreqs
                    if rreqr ~= "" then
                        rreq = rreq .. "(" .. rreqr .. ')"'
                    else
                        rreq = rreq .. '"'
                    end
                end
            end

            if state == "disabled" and rank > 0 then
                state = "temp"
            end
			
            if state == "disabled" then
                saturated = 1
                color = GRAY_FONT_COLOR
            elseif state == "full" then
                color = NORMAL_FONT_COLOR
            elseif state == "temp" then
                color = RAID_CLASS_COLORS["SHAMAN"]
            elseif state == "req" then
                color = ORANGE_FONT_COLOR
            end
            button.texture:SetDesaturated(saturated)
            --button.slot:SetVertexColor(color.r, color.g, color.b)
            button.rank:SetVertexColor(color.r, color.g, color.b)
            button.rank:SetText(rank)

            if mode == "spell" then
                ncost = "Requires 1 AP"
                if ntcost == 1 then
                    ncost = ncost .. ", 1 TP"
                end
            else
                ncost = "Requires 1 TP"
                if ntcost == 1 then
                    ncost = ncost .. ", 1 AP"
                end
            end
	
			local clickable = true

            if state == "normal" and rank > hrank then
                if nrank <= ranks then
                    button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
                end
            end
            if state == "normal" and rank == hrank then
                if nrank <= ranks then
                    button:RegisterForClicks("LeftButtonDown","RightButtonDown")
                end
            end
            if state == "normal" and rank == 0 then
                button:RegisterForClicks("LeftButtonDown")
            end
            if (state == "full" or state == "temp") and rank > hrank then
                button:RegisterForClicks("RightButtonDown")
            end
            if (state == "full" or state == "temp") and rank == hrank then
                button:RegisterForClicks("RightButtonDown")
				--clickable = false
            end
            if state == "req" and rank > hrank and nrank <= ranks and rreq ~= nil then
                if UnitLevel("player") < nlevel then
                    button:RegisterForClicks()
				clickable = false
                else
                    button:RegisterForClicks("LeftButtonDown")
                end
            end
            if state == "disabled" then
                button:RegisterForClicks()
				clickable = false
            end

            button:SetScript(
                "OnClick",
                function(self, key, down)
					if not (button:IsEnabled() and clickable ~= false) then return end
					local ap, tap = GetPoints("ap")
					local tp, ttp = GetPoints("tp")
                    if key == "LeftButton" then
                        if (mode == "spell") then
							if(ap > 0 and UnitLevel("player") >= nlevel) then
								if(ntcost == 1) then
									if(tp > 0) then
									TempLearnSpell(nspell, ntcost)
									end
								else
									TempLearnSpell(nspell, ntcost)
								end
							end
                        else if mode == "talent" and tp >0 and UnitLevel("player") >= nlevel then
                            TempLearnTalent(nspell, ntcost)
                        end
                    end
					end

                    if key == "RightButton" then
                        if mode == "spell" then
                            TempUnlearnSpell(spell, tcost)
                        else
                            TempUnlearnTalent(spell, tcost)
                        end
                    end

                    FillSpells(class, spec, parent, mode)
                    button:Hide()
                    button:Show()
                end)

            ButtonTooltip(button, spell, nspell, rank, ranks, nlevel, lcolor, ccolor, state, ncost, lock, req, rreq)

            if i / itemsPerRow == math.floor(i / itemsPerRow) then
                left = leftConst
                top = top - 60
            else
                left = left + 60
            end
        end
    end

    --Create Main Button
    local button =
        _G["CLButton"] or NewButton("CLButton", UIParent, 55, "Interface\\Minimap\\TRACKING\\Class", nil, nil, nil, nil, nil, true) --Interface\\ICONS\\INV_Enchant_FormulaEpic_01
    button:SetMovable(true)
    button:EnableMouse(true)
    button:SetToplevel(true)
    button:RegisterForDrag("RightButton")
    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", button.StopMovingOrSizing)
    button:SetPoint("RIGHT", -24, 0)
    button:SetScript(
        "OnClick",
        function()
            FrameToggle("CLMainFrame")
        end
    )
	
	AIO.SavePosition(button)
	
    --button.flash = CreateFrame("Frame", "CLButtonFlash", button)
    --button.flash:SetAllPoints()
    --button.flash:Hide()
    --local texture = button.flash:CreateTexture()
   -- texture:SetTexture("Interface\\Cooldown\\star4")
   -- texture:SetAllPoints()
   -- texture:SetBlendMode("ADD")
   -- button.animation = texture:CreateAnimationGroup()
  --  local a1 = button.animation:CreateAnimation("Scale")
  --  a1:SetScale(2.5, 2.5)
  --  a1:SetDuration(3)
   -- a1:SetSmoothing("OUT")

  --  local a2 = button.animation:CreateAnimation("Rotation")
  --  a2:SetDegrees(360)
 --   a2:SetDuration(3)
   -- a2:SetSmoothing("OUT")
   -- button.animation:SetLooping("BOUNCE")
   -- button.flash:SetScript(
   --     "OnShow",
   --     function()
   --         button.animation:Play()
   --     end
  --  )
   -- button.flash:SetScript(
   --     "OnHide",
   --     function()
    --        button.animation:Stop()
    --    end
   -- )

    button.tooltip =
        _G["CLButtontooltip"] or CreateFrame("GameTooltip", "CLButtontooltip", button, "GameTooltipTemplate")
    button:SetScript(
        "OnEnter",
        function()
            local ap, tp= GetPoints("ap"), GetPoints("tp")
            button.tooltip:Hide()
            button.tooltip:SetOwner(button, "ANCHOR_RIGHT")
            button.tooltip:AddLine("Talent Forge", nil, nil, nil, true)
            local c = GREEN_FONT_COLOR
            if ap > 0 or tp > 0 then
                local string =
                    "You have\n" .. tp .. " Talent Pills"
                button.tooltip:AddLine(string, c.r, c.g, c.b, true)
            end
            button.tooltip:AddLine("Drag with the right mouse button held to move.", 1, 1, 1, true)
            button.tooltip:Show()
        end
    )
    button:SetScript(
        "OnLeave",
        function()
            button.tooltip:Hide()
        end
    )

    button:SetScript(
        "OnUpdate",
        function()
            local ap, tp = GetPoints("ap"), GetPoints("tp")
            if ap > 0 or tp > 0 then
                FrameShow(button.flash)
            else
                FrameHide(button.flash)
            end
        end
    )

    button:RegisterEvent("PLAYER_LEVEL_UP")
    button:SetScript(
        "OnEvent",
        function()
            local tab = _G["CLMainFrame"]:GetAttribute("tab")
            if tab ~= 0 then
                SelectTab(tab, "CLContainer", "CLMainFrame", "CLButton")
            end
        end
    )

    --Create Main Frame
    local frame = CLMainFrame or CreateFrame("Frame", "CLMainFrame", UIParent)
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetToplevel(true)
	
	frame.titleRegion = frame:CreateTitleRegion()
	frame.titleRegion:SetSize(967, 50) -- 600 wide x 24 tall
	frame.titleRegion:SetPoint("TOPLEFT") -- anchor the titleRegion to top left of frame
	-- this is the drag bar texture
	frame.titleTexture = frame:CreateTexture("frame_titleTexture", "ARTWORK")
	frame.titleTexture:SetSize(967, 50)  -- texture is the same size as the title drag bar
	frame.titleTexture:SetPoint("TOPLEFT")
	
	
    frame:RegisterForDrag("LeftButton")
    frame:SetToplevel(true)
	frame:SetSize(967, 670) -- 420x680
    --[[frame:SetBackdrop(
        {
            bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            edgeSize = 16,
            tileSize = 32,
            insets = {left = 5, right = 5, top = 5, bottom = 5}
        }
    )]]

    -- FrameBackground(frame, "Interface\\QuestFrame\\UI-QuestLog-Empty")
    frame:SetPoint("CENTER", 0, 0)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetAttribute("tab", 0)
    frame:SetAttribute("child", "CLContainer")
	
	AIO.SavePosition(frame)
    
    local function TabSelect(frame)
        if (frame == nil) then frame = _G["CLMainFrame"] end
        local tab = frame:GetAttribute("tab")
        if tab == 0 then
                tab = 1
        end
        SelectTab(tab, "CLContainer", "CLMainFrame", "CLButton")
    end

    frame:SetScript(
        "OnShow",
        function()
            TabSelect()
			UpdatePointText()
        end
    )

    frame:SetScript(
        "OnHide",
        function()
            local tab = frame:GetAttribute("tab")
            if tab ~= 0 then
                FrameHide("Container" .. tab)
            end
        end
    )

    frame:SetScript(
        "OnUpdate",
        function()
            local ap, tap = GetPoints("ap")
            local tp, ttp = GetPoints("tp")
           -- local string =icons[1].."         "..icons[2].."\n"
			local string2 = ap
            if tap > 0 then
                string2 = string2 .. "(" .. tap .. ")"
            end
           -- string = string .. " AP "..icons[1].." " .. tp
			string2 = tp
            if ttp > 0 then
                string2 = string2 .. "(" .. ttp .. ")"
            end
            string2 = string2 .. " TP "--..icons[2]
            
            if _G["CLMainFramePoints"] ~= nil then
			--	CLMainFramePoints.text:SetText(string)
                CLMainFramePoints.text2:SetText(string2)
            end

            local tab = _G["CLMainFrame"]:GetAttribute("tab")
            if tab ~= nil and tab > 0 then
 
               if (tab == 1 and #spellsplus + #spellsminus > 0) or (tab == 2 and #talentsplus + #talentsminus + #tpellsplus + #tpellsminus > 0) then
                    FrameShow("CLResetButtonFrame")
                else
                    FrameHide("CLResetButtonFrame")
                end
            end
        end
    )

   -- Glyph button function 
   local glyphButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
glyphButton:SetSize(100, 25)
glyphButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -630, -660)
glyphButton:SetText("Glyphs")
glyphButton:SetScript("OnClick", function()
    ToggleGlyphFrame()
end)

-- Starting the spec button
local dualButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
dualButton:SetSize(100, 25)
dualButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -830, -10)
dualButton:SetText("DualSpec")
dualButton:SetScript("OnClick", function(self)
    StaticPopupDialogs["CONFIRM_DUAL_SPEC"] = {
        text = "Are you sure that you want to learn Dual Talent specialization? You will be able to save and swap 2 sets of glyphs, as well as an additional Loadout.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            StaticPopupDialogs["CONFIRM_DUAL_SPEC_COST"] = {
                text = "Learning Dual Talent Specialization will cost 1000 gold. Do you wish to continue?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    local copper = GetMoney()
                    local requiredCopper = 10000000 -- 1000 gold in copper
                    if copper >= requiredCopper then
                        SendChatMessage(".mod money -10000000", "SAY")
                        SendChatMessage(".cast 63680", "SAY")
                        SendChatMessage(".cast 63624", "SAY")
                        SendChatMessage(".achievement add 2716", "SAY")
                        PlaySound("igMainMenuOption")
                        DEFAULT_CHAT_FRAME:AddMessage("You have successfully learned Dual Talent Specialization!", 0, 1, 0)
                        ReloadUI()
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("You don't have enough gold.", 1, 0, 0)
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("CONFIRM_DUAL_SPEC_COST")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("CONFIRM_DUAL_SPEC")
end)

-- Save button 1 starting
local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
saveButton:SetSize(165,25)
saveButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -610, -101)
saveButton:SetText("Save to Loadout One")
saveButton:SetScript("OnClick", function()
    StaticPopupDialogs["SAVE_TALENTS_DIALOG"] = {
        text = "Are you sure you want to save your known Talents to Loadout One?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local playerGuid = UnitGUID("player")
            local guidNumber = tonumber(string.sub(playerGuid, -12), 16)
            AIO.Handle("yQ4CiWjHET", "SaveTalentLoadout", guidNumber)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SAVE_TALENTS_DIALOG")
end)

-- Loadout 1 load button starting
local loadButton1 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
loadButton1:SetSize(150, 25)
loadButton1:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -618, -139)
loadButton1:SetText("Load Loadout One")
loadButton1:SetScript("OnClick", function()
    StaticPopupDialogs["LOAD_TALENTS_DIALOG_1"] = {
        text = "Are you sure you want to load the Talents you saved in Loadout One?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local playerGuid = UnitGUID("player")
            local guidNumber = tonumber(string.sub(playerGuid, -12), 16)
            AIO.Handle("yQ4CiWjHET", "LoadTalentLoadout1", guidNumber)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("LOAD_TALENTS_DIALOG_1")
end)

-- Save button 2 starting
local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
saveButton:SetSize(165,25)
saveButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -101)
saveButton:SetText("Save to Loadout Two")
saveButton:SetScript("OnClick", function()
    StaticPopupDialogs["SAVE_TALENTS_DIALOG2"] = {
        text = "Are you sure you want to save your known Talents to Loadout Two?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local playerGuid = UnitGUID("player")
            local guidNumber = tonumber(string.sub(playerGuid, -12), 16)
            AIO.Handle("yQ4CiWjHET", "SaveTalentLoadout2", guidNumber)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SAVE_TALENTS_DIALOG2")
end)

-- Load button 2 starting
local loadButton1 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
loadButton1:SetSize(150, 25)
loadButton1:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -27, -139)
loadButton1:SetText("Load Loadout Two")
loadButton1:SetScript("OnClick", function()
    StaticPopupDialogs["LOAD_TALENTS_DIALOG_2"] = {
        text = "Are you sure you want to load the Talents you saved in Loadout Two?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local playerGuid = UnitGUID("player")
            local guidNumber = tonumber(string.sub(playerGuid, -12), 16)
            AIO.Handle("yQ4CiWjHET", "LoadTalentLoadout2", guidNumber)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("LOAD_TALENTS_DIALOG_2")
end)

-- Check and set initial DualSpec button visibility
local function UpdateDualSpecButtonVisibility()
    local _, _, _, completed = GetAchievementInfo(2716)
    if completed then
        dualButton:Hide()
    else
        dualButton:Show()
    end
end
UpdateDualSpecButtonVisibility()

-- Check and set initial Loadout Two buttons visibility
local function UpdateLoadoutTwoButtonsVisibility()
    local _, _, _, completed = GetAchievementInfo(2716)
    if completed then
        saveButton:Show()
        loadButton1:Show()
    else
        saveButton:Hide()
        loadButton1:Hide()
    end
end
UpdateLoadoutTwoButtonsVisibility()

-- Create frame to watch for achievement updates
local f = CreateFrame("Frame")
f:RegisterEvent("ACHIEVEMENT_EARNED")
f:SetScript("OnEvent", function(self, event, achievementID)
    if achievementID == 2716 then
        UpdateDualSpecButtonVisibility()
        UpdateLoadoutTwoButtonsVisibility()
    end
end)


   -- Close button
    local button = _G["CLMainFrameClose"] or CreateFrame("Button", "CLMainFrameClose", _G["CLMainFrame"])
    button:SetSize(36, 36)
    button:SetPoint("TOPRIGHT", -5, -7)
    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    button:SetScript(
        "OnClick",
        function()
            FrameHide("CLMainFrame", "CLGlyphFrame")
        end
    )

    -- AP and TP points
    local frame = _G["CLMainFramePoints"] or CreateFrame("Frame", "CLMainFramePoints", _G["CLMainFrame"])
    frame:SetSize(160, 32)
    frame:SetPoint("TOPLEFT", 25, -30)
    frame.text = frame:CreateFontString("CLMainFramePointsText", "OVERLAY", "GameFontNormal")
	frame.text:SetTextColor(199/255,42/255,42/255)
	CLMainFramePoints.text:SetJustifyV("MIDDLE");
	CLMainFramePoints.text:SetJustifyH("LEFT");
    frame.text:SetPoint("CENTER")
		
	frame.text2 = frame:CreateFontString("CLMainFramePointsText2", "OVERLAY", "GameFontNormal")
	frame.text2:SetTextColor(204/255,126/255,43/255)
	CLMainFramePoints.text2:SetJustifyV("MIDDLE");
	CLMainFramePoints.text2:SetJustifyH("LEFT");
    frame.text2:SetPoint("CENTER")
	--frame:SetScript("OnUpdate", UpdatePoints)

    -- Learn Confirm and cancel
    local frame = _G["CLResetFrame"] or CreateFrame("Frame", "CLResetFrame", _G["CLMainFrame"])
    frame:SetSize(160, 32)
    frame:SetPoint("BOTTOMRIGHT", -1, -1)
    --frame:SetScript("OnUpdate", UpdateReset)

    local frame = _G["CLResetButtonFrame"] or CreateFrame("Frame", "CLResetButtonFrame", _G["CLResetFrame"])
    frame:Hide()
    frame:SetSize(160, 32)
    frame:SetPoint("CENTER")
    
    local frame = _G["CLWipeButtonFrame"] or CreateFrame("Frame", "CLWipeButtonFrame", _G["CLResetFrame"])
    frame:SetSize(32, 32)
    frame:SetPoint("LEFT", -10, -5)

    local button =
    _G["CLWipeButton"] or
    NewButton(
        "CLWipeButton",
        _G["CLWipeButtonFrame"],
        36,
        "Interface\\Tooltips\\Reverse_White",
        nil
    )
    button:SetPoint("BOTTOMRIGHT", 10, - 8)
    button:SetScript(
        "OnClick",
        function()
            if not (button:IsEnabled()) then return end
            StaticPopup_Show("WIPE_SPELLS")
        end
    )
	

    StaticPopupDialogs["WIPE_SPELLS"] = {
        text = "Do you really want to reset all of the talents in your Loadout?",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            AIO.Handle(handlerName, "WipeAll", clientSecret)
            TabSelect()
            _G["CLMainFrame"]:Hide()
			UpdatePointText()
        end,
        OnShow = function(self)
            rst = db.reset + 1
            if (rst > #prices) then
                rst = #prices
            end
            MoneyFrame_Update(self.moneyFrame, prices[rst]);
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasMoneyFrame = 1,
        preferredIndex = 3
    }
	
	
	 local frame = _G["CLUnusedButtonFrame"] or CreateFrame("Frame", "CLUnusedButtonFrame", _G["CLResetFrame"])
    frame:SetSize(32, 32)
    frame:SetPoint("BOTTOMLEFT", -20, 0)
	
	
	-----------------------------------
    local buttons = {"Apply", "Reset"}
    for i = 1, #buttons do
        --buttons:
        local button = _G["CLResetButton" .. i] or MakeButton("CLResetButton" .. i, _G["CLResetButtonFrame"])
        button:SetText(buttons[i])
        button:SetSize(75, 32)
        button:SetPoint("LEFT", 80 * (i - 1)-321, 45) --
        button:SetScript(
            "OnClick",
            function()
				if not (button:IsEnabled()) then return end
                LearnConfirm(buttons[i], "false")
            end
        )
    end

    --Learn and reset confirm dialogs
    StaticPopupDialogs["LEARN_CONFIRM"] = {
        text = "Please confirm applying these changes.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            LearnConfirm("Apply", "true")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }

    StaticPopupDialogs["RESET_CONFIRM"] = {
        text = "Please confirm resetting your Loadout.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            LearnConfirm("Reset", "true")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }

    --Main Tab buttons, containers
    local buttons = {"", ""}
    for i = 1, #buttons do
        --buttons:
        local button = _G["CLButton" .. i] or MakeButton("CLButton" .. i, _G["CLMainFrame"], true)
        button:SetText(buttons[i])
		button:SetSize(18,18)
        button:SetPoint("TOP",50*(i) +6, -110) --alpha
		button.norm = button:CreateTexture(nil, "ARTWORK")
		button.norm:SetTexture("Interface/Buttons/CLCircle")
		button.norm:SetPoint("CENTER")
		button.norm:SetSize(30,30)
		button:SetNormalTexture(button.norm)
        button.push = button:CreateTexture(nil, "OVERLAY")
		button.push:SetTexture("Interface/Buttons/CLCircleActive")
		button.push:SetPoint("CENTER")
		button.push:SetSize(30,30)
		button:SetPushedTexture(button.push)	
		button:SetScript(
            "OnClick",
            function()
                SelectTab(i, "CLContainer", "CLMainFrame", "CLButton")
				SelectTab(current_class, "CLContainer"..i.."Sub", "CLContainer"..i, "CLContainer"..i.."SubButton")
				SelectTab(current_spec, "CLContainer"..i.."Sub"..current_class.."Sub", "CLContainer"..i.."Sub"..current_class, "CLContainer"..i.."Sub"..current_class.."SubButton")
            end
        )
        --containers:
        local frame = _G["CLContainer" .. i] or CreateFrame("Frame", "CLContainer" .. i, _G["CLMainFrame"])
        frame:SetSize (967, 670)
        frame:SetPoint("TOPLEFT")
        frame:SetAttribute("tab", 0)
        frame:SetAttribute("child", "CLContainer" .. i .. "Sub")
        frame:Hide()
        frame:SetScript(
            "OnShow",
            function()
                local tab = frame:GetAttribute("tab")
                if tab == 0 then
                    tab = 1
                end
                local child = frame:GetAttribute("child")
                SelectTab(tab, child, "CLContainer" .. i, child .. "Button")
            end
        )
    end

    local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(750, 115)
    titleBar:SetPoint("TOP", -300, 675)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
    
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    title:SetPoint("TOP", -300, 652)
    title:SetText(string.format("%s's Talents", UnitName("player")))
    title:SetTextColor(0, 0.6, 1)
	
	-- Class names and other text stuffs
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -669, 510)
    title:SetText("Deathknight")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -671, 450)
    title:SetText("Druid")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 390)
    title:SetText("Hunter")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 330)
    title:SetText("Mage")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 270)
    title:SetText("Paladin")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 210)
    title:SetText("Priest")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 150)
    title:SetText("Rogue")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 90)
    title:SetText("Shaman")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, 30)
    title:SetText("Warlock")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -670, -30)
    title:SetText("Warrior")
    title:SetTextColor(1, 0.8, 0, 1)

-- starting with the labels and shitt

local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(323, 60)
    titleBar:SetPoint("TOP", -716, 562)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    title:SetPoint("TOP", -716, 551)
    title:SetText("Classes")
    title:SetTextColor(0, 0.6, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    title:SetPoint("TOP", -275, 528)
    title:SetText("Display Talents")
    title:SetTextColor(0, 0.6, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", 18, 0)
    title:SetText("Reset Loadout")
    title:SetTextColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    title:SetPoint("TOP", -237, 574)
    title:SetText("Specializations")
    title:SetTextColor(1, 0.8, 0, 1)
	
	-- More titles yeahp
	local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(10, 1325)
    titleBar:SetPoint("TOP", -630, 710)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(10, 1325)
    titleBar:SetPoint("TOP", -805, 710)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(1515, 10)
    titleBar:SetPoint("TOP", -230, 510)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(1875, 20)
    titleBar:SetPoint("TOP", -315, 645)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(1875, 20)
    titleBar:SetPoint("TOP", -315, -50)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local titleBar = frame:CreateTexture(nil, "ARTWORK")
    titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBar:SetSize(10, 1375)
    titleBar:SetPoint("TOP", 165, 715)
    titleBar:SetVertexColor(1, 0.8, 0, 1)
	
	local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 72, "OUTLINE")
    title:SetPoint("TOP", -740, 619)
    title:SetText(".")
    title:SetTextColor(0, 0.6, 1)
	
	-- yeahp lets get it back to the codstuffs
	
    local frame = _G["CLClassesFrame"] or CreateFrame("Frame", "CLClassesFrame", _G["CLMainFrame"])
    frame:SetSize(967, 695)
    frame:SetPoint("TOPLEFT")
	t = CreateTexture(frame, "BACKGROUND")
	t:SetTexCoord(0, 0.944, 0, 0.654)
    frame.background = t
	frame.background:SetVertexColor(0.7, 0.6, 0.4, 1)
	frame.background:SetTexture("Interface\\AddOns\\Frostforged\\TalentMenu")
	frame.background:SetAllPoints()	

  -- frame:SetBackdrop(
     --   {
       --     bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
          -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
       --     tile = true,
       --     edgeSize = 16,
      --      tileSize = 16,
      --      insets = {left = 0, right = 0, top = 2, bottom = 2}
     --   }
 --   )

    for index = 1, 2 do
        --Class buttons for spells and talents
        local i = 1
        local arr
        local mode
        if index == 1 then
            arr = db.data.spells
            mode = "spell"
        else
            arr = db.data.talents
            mode = "talent"
        end
        for k, v in pairsSort(arr) do
            local class, cnum, inum = k, i, index
            local button =
                _G["CLContainer" .. index .. "SubButton" .. i] or
                NewButton(
                    "CLContainer" .. index .. "SubButton" .. i,
                    _G["CLContainer" .. index],
                    36,
                    "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",
                    nil,
                    unpack(CLASS_ICON_TCOORDS[class])
                )
			button:SetPoint("TOPLEFT", 50, - 54 - 60 * i) --beta
            button.text = _G["CLContainer"..index.."SubButton"..i.."Text"] or button:CreateFontString("CLContainer"..index.."SubButton"..i.."Text", "OVERLAY")
			button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
 			button.text:SetPoint("CENTER", 50, 0)
			button.text:SetText(tostring(CountSpellPoints(i,1) + CountSpellPoints(i,2) + CountSpellPoints(i,3)))
			button.text:SetTextColor(186/255,38/255,38/255)
			button.texttex = button:CreateTexture(nil, "ARTWORK")
			button.texttex:SetTexture("Interface/Buttons/CLCircleSmall")
			button.texttex:SetPoint("CENTER", button.text, "CENTER")
            button.text2 = _G["CLContainer"..index.."SubButton"..i.."Text2"] or button:CreateFontString("CLContainer"..index.."SubButton"..i.."Text2", "OVERLAY") 
			button.text2:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
 			button.text2:SetPoint("CENTER", 80, 0)
			button.text2:SetText(tostring(CountTalentPoints(i,1) + CountTalentPoints(i,2) + CountTalentPoints(i, 3)))
			button.text2:SetTextColor(204/255,126/255,43/255)
			button.text2tex = button:CreateTexture(nil, "ARTWORK")
			button.text2tex:SetTexture("Interface/Buttons/CLCircleSmall")
			button.text2tex:SetPoint("CENTER", button.text2, "CENTER") 
			button:SetScript(
                "OnClick",
                function()
					if not (button:IsEnabled()) then return end --delta
					current_class = cnum
                    SelectTab(
                        cnum,
                        "CLContainer".. inum .."Sub",
                        "CLContainer" .. inum,
                        "CLContainer".. inum .."SubButton"
                    )
					LastContainerNum = inum
                end
            )

            local frame =
                _G["CLContainer" .. index .. "Sub" .. i] or
                CreateFrame("Frame", "CLContainer" .. index .. "Sub" .. i, _G["CLContainer" .. index])
            --frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
            frame:SetSize(_G["CLContainer" .. index]:GetSize())
            frame:SetPoint("TOPLEFT")
            frame:SetAttribute("tab", 0)
            frame:SetAttribute("child", "CLContainer" .. index .. "Sub" .. i .. "Sub")
            frame:Hide()
            frame:SetScript(
                "OnShow",
                function()
                    local tab = frame:GetAttribute("tab")
                    if tab == 0 then
                        tab = 1
                    end
                    local child = frame:GetAttribute("child")
                    SelectTab(tab, child, "CLContainer" .. inum .. "Sub" .. cnum, child .. "Button")
                end
            )

            --buttons and containers for spells
            for j = 1, #arr[class] do
                local snum = j
                local button =
                    _G["CLContainer" .. index .. "Sub" .. i .. "SubButton" .. j] or
                    NewButton(
                        "CLContainer" .. index .. "Sub" .. i .. "SubButton" .. j,
                        _G["CLContainer" .. index .. "Sub" .. i],
                        36,
                        "Interface\\Icons\\" .. arr[class][j][2],
                        nil
                    )
                button:SetPoint("TOP", 50 * (j) -20, -30)
				button.text = button:CreateFontString(nil, "OVERLAY")
				button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
 				button.text:SetPoint("CENTER", -10, -35)
				button.text:SetText(tostring(CountSpellPoints(i,j)))
				button.text:SetTextColor(186/255,38/255,38/255)
				button.texttex = button:CreateTexture(nil, "ARTWORK")
				button.texttex:SetTexture("Interface/Buttons/CLCircleSmall")
				button.texttex:SetPoint("CENTER", button.text, "CENTER")
                button.text2 = button:CreateFontString(nil, "OVERLAY")
				button.text2:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
 				button.text2:SetPoint("CENTER", 15, -35)
				button.text2:SetText(tostring(CountTalentPoints(i,j)))
				button.text2:SetTextColor(204/255,126/255,43/255)
				button.text2tex = button:CreateTexture(nil, "ARTWORK")
				button.text2tex:SetTexture("Interface/Buttons/CLCircleSmall")
				button.text2tex:SetPoint("CENTER", button.text2, "CENTER")  
				button:SetScript(
                    "OnClick",
                    function()
						if not (button:IsEnabled()) then return end--eta
						current_spec = snum
                        SelectTab(
                            snum,
                            "CLContainer".. inum .."Sub" .. cnum .. "Sub",
                            "CLContainer".. inum .."Sub" .. cnum,
                            "CLContainer".. inum .."Sub" .. cnum .. "SubButton"
                        )
						end
                )

                local frame =
                    _G["CLContainer" .. index .. "Sub" .. i .. "Sub" .. j] or
                    CreateFrame(
                        "Frame",
                        "CLContainer" .. index .. "Sub" .. i .. "Sub" .. j,
                        _G["CLContainer" .. index .. "Sub" .. i]
                    )
                frame:SetSize(
                    _G["CLContainer" .. index .. "Sub" .. i]:GetWidth()+10,
                    _G["CLContainer" .. index .. "Sub" .. i]:GetHeight()+35
                )
                frame:SetPoint("TOP", 200, - 145)
                FrameBackground(frame, "Interface\\FullScreenTextures\\OutOfControl" .. arr[class][j][3])
                FrameLayout(frame, frame:GetWidth(), frame:GetHeight()+45)
                frame:Hide()
                frame:SetScript(
                    "OnShow",
                    function()
                        local timer = GetTime()
                        frame:SetScript(
                            "OnUpdate",
                            function()
                                if GetTime() - timer >= 0.1 then
                                    FillSpells(class, snum, frame, mode)
									_G["Zin"] = spell_point_list
                                    frame:SetScript("OnUpdate", nil)
                                end
                            end
                        )
                    end
                )
            end

            i = i + 1
        end
    end --end of index

end --End of Doshit

--Main Execution
local MyHandlers = AIO.AddHandlers(handlerName, {})


function MyHandlers.LoadVars(player, spr, tpr, tar,rem, rst, prc, scr, rsd)
    --Init
    db.spells = spr
    db.tpells = tpr
    db.talents = tar
    db.reset = rst
    prices = prc
    if (rsd ~= true) then
	    clientSecret = scr
        DoShit()
    end
end

--hook original Talent Frame
function ToggleTalentFrame()
    FrameToggle("CLMainFrame")
end