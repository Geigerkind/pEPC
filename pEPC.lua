
function GameTooltip:pEPCParse()
    local stats = {
        ["Intellect"] = 0,
        ["Spirit"] = 0,
        ["SpellPower"] = 0,
        ["SpellHit"] = 0,
        ["SpellCrit"] = 0,
        ["Haste"] = 0,
        ["Sockets"] = 0,
        ["Meta"] = 0,
        ["Effect"] = 0,
    }
    local statWeights = {
        ["Intellect"] = 0.05,
        ["Spirit"] = 0.11,
        ["SpellPower"] = 1,
        ["SpellHit"] = 0.7692,
        ["SpellCrit"] = 0.1629,
        ["Haste"] = 0.535,
        ["Sockets"] = 9,
        ["Meta"] = 30.9,
        ["Effect"] = 1,
    }

    for i=1,self:NumLines() do
        local mytext = getglobal(self.pEPCName.."TextLeft" .. i)
        if mytext ~= nil then
            local text = mytext:GetText() or ""

            if (strsub(text, 0, 1) == "+") then
                local spacePos = strfind(text, " ");
                local number = tonumber(strsub(text, 1, spacePos  - 1));
                local type = strsub(text, spacePos + 1);
                if (type == "Intellect" or type == "Spirit") then
                    stats[type] = stats[type] + number;
                elseif (type == "Shadow spell damage") then
                    stats["SpellPower"] = stats["SpellPower"] + number;
                end
            elseif (strsub(text, 0, 6) == "Equip:") then
                local possibleStrings = {
                    [1] = {[1] = "Equip: Increases damage and healing done by magical spells and effects by up to ", [2] = "SpellPower"},
                    [2] = {[1] = "Equip: Increases damage done by Shadow spells and effects by up to ", [2] = "SpellPower"},
                    [3] = {[1] = "Equip: Improves spell critical strike rating by ", [2] = "SpellCrit"},
                    [4] = {[1] = "Equip: Improves spell hit rating by ", [2] = "SpellHit"},
                    [5] = {[1] = "Equip: Improves spell haste rating by ", [2] = "Haste"},
                };
                for i=1, 5 do
                    local _, pos = strfind(text, possibleStrings[i][1]);
                    if (pos ~= nil and pos > 0) then
                        local number = tonumber(strsub(text, pos + 1, -2));
                        stats[possibleStrings[i][2]] = stats[possibleStrings[i][2]] + number;
                    end
                end

                -- Special snowflakes
                local _, pos = strfind(text, " and damage done by up to ")
                if (pos ~= nil and pos > 0) then
                    local textAfterThat = strsub(text, pos + 1);
                    local number = tonumber(strsub(textAfterThat, 0, strfind(textAfterThat, " ") - 1));
                    stats["SpellPower"] = stats["SpellPower"] + number;
                end

                _, pos = strfind(text, "Equip: Restores ");
                if (pos ~= nil and pos > 0) then
                    local textAfterThat = strsub(text, pos + 1);
                    local number = tonumber(strsub(textAfterThat, 0, strfind(textAfterThat, " ") - 1));
                    stats["Spirit"] = stats["Spirit"] + number;
                end

                -- Trinkets:
                -- Assuming 45 sec cd
                _, pos = strfind(text, "Equip: Your harmful spells have a chance to increase your spell haste rating by ");
                if (pos ~= nil and pos > 0) then
                    local textAfterThat = strsub(text, pos + 1);
                    local p1, p2 = strfind(textAfterThat, " for ");
                    local number = tonumber(strsub(textAfterThat, 0, p1 - 1));
                    local forTime = tonumber(strsub(textAfterThat, p2 + 1, strfind(textAfterThat, " sec") - 1));
                    stats["Effect"] = stats["Effect"] + ((number*statWeights["Haste"])/45)*forTime;
                end
            elseif (strsub(text, 0, 4) == "Use:") then
                local _, pos = strfind(text, "Use: Increases damage and healing done by magical spells and effects by up to ");
                if (pos ~= nil and pos > 0) then
                    local textAfterThat = strsub(text, pos + 1);
                    local p1, p2 = strfind(textAfterThat, " for ");
                    local number = tonumber(strsub(textAfterThat, 0, p1 - 1));
                    local forTime = tonumber(strsub(textAfterThat, p2 + 1, strfind(textAfterThat, " sec") - 1));
                    p1 = strfind(textAfterThat, "(", 0, true);
                    textAfterThat = strsub(textAfterThat, p1+1);
                    p1 = strfind(textAfterThat, " ");
                    local cdTime = tonumber(strsub(textAfterThat, 0, p1 - 1));
                    local timeUnit = strsub(textAfterThat, p1 + 1, strfind(textAfterThat, ")", 0, true) - 1);
                    
                    if (strfind(timeUnit, "Min")) then
                        stats["Effect"] = stats["Effect"] + ((number)/(cdTime*60))*forTime;
                    else -- Seconds probably
                        stats["Effect"] = stats["Effect"] + ((number)/(cdTime))*forTime;
                    end
                end

                _, pos = strfind(text, " and damage done by spells by up to ");
                if (pos ~= nil and pos > 0) then
                    local textAfterThat = strsub(text, pos + 1);
                    local p1, p2 = strfind(textAfterThat, " for ");
                    local number = tonumber(strsub(textAfterThat, 0, p1 - 1));
                    local forTime = tonumber(strsub(textAfterThat, p2 + 1, strfind(textAfterThat, " sec") - 1));
                    p1 = strfind(textAfterThat, "(", 0, true);
                    textAfterThat = strsub(textAfterThat, p1+1);
                    p1 = strfind(textAfterThat, " ");
                    local cdTime = tonumber(strsub(textAfterThat, 0, p1 - 1));
                    local timeUnit = strsub(textAfterThat, p1 + 1, strfind(textAfterThat, ")", 0, true) - 1);
                    
                    if (strfind(timeUnit, "Min")) then
                        stats["Effect"] = stats["Effect"] + ((number)/(cdTime*60))*forTime;
                    else -- Seconds probably
                        stats["Effect"] = stats["Effect"] + ((number)/(cdTime))*forTime;
                    end
                end
            elseif (strfind(text, "+12 Spell Damage and Minor ") or strfind(text, "Meta Socket")) then
                stats["Meta"] = 1;
            elseif ((strsub(text, 0, 10) == "|cffffffff") or (strfind(text, "Red Socket") or strfind(text, "Yellow Socket") or strfind(text, "Blue Socket")) and strfind(text, "Socket Bonus") == nil) then
                -- Sockets
                stats["Sockets"] = stats["Sockets"] + 1;
            end
        end
    end

    local total = 0;
    for index, value in pairs(stats) do
        if (value > 0) then
            total = total + value*statWeights[index];
        end
    end

    if total ~= nil and total > 0 then
        self:AddLine(" ");
        self:AddLine("EP Values:");
        self:AddDoubleLine("Name", "EP");
        for index, value in pairs(stats) do
            if (value > 0) then
                self:AddDoubleLine(index, string.format("%.2f", value*statWeights[index]));
            end
        end
        self:AddDoubleLine("Total EP: ", string.format("%.2f",total));
        self:AddLine(" ");
    end
end 
AtlasLootTooltip.pEPCParse = GameTooltip.pEPCParse
ShoppingTooltip1.pEPCParse = GameTooltip.pEPCParse
ShoppingTooltip2.pEPCParse = GameTooltip.pEPCParse

local orig = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
    -- Parsing stats
    frame.pEPCName = "GameTooltip";
    frame:pEPCParse();

    if orig then return orig(frame, ...) end
end)

local orig2 = AtlasLootTooltip:GetScript("OnTooltipSetItem")
AtlasLootTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
    -- Parsing stats
    frame.pEPCName = "AtlasLootTooltip";
    frame:pEPCParse();

    if orig2 then return orig2(frame, ...) end
end)

local orig3 = AtlasLootTooltip:GetScript("OnTooltipSetItem")
ShoppingTooltip1:SetScript("OnTooltipSetItem", function(frame, ...)
    -- Parsing stats
    frame.pEPCName = "ShoppingTooltip1";
    frame:pEPCParse();

    if orig3 then return orig3(frame, ...) end
end)

local orig4 = AtlasLootTooltip:GetScript("OnTooltipSetItem")
ShoppingTooltip2:SetScript("OnTooltipSetItem", function(frame, ...)
    -- Parsing stats
    frame.pEPCName = "ShoppingTooltip2";
    frame:pEPCParse();

    if orig4 then return orig4(frame, ...) end
end)
