setDefaultTab("A")

if not storage.buffCDW then
    storage.buffCDW = 0
end

local textBuff = addTextEdit("Buff ", storage.buffConfig or "Buff", function(widget, text)
    storage.buffConfig = text:trim():lower()
end)
textBuff:setTooltip('Buff Spell, Buff Orange Message, Cooldown(Seconds)')

macro(100, "Buff", function()
    local buffSetup = storage.buffConfig:split(',')
    if isInPz() then return end
    if storage.buffCDW <= os.time() then
        say(buffSetup[1])
    end
end)

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return end
    local buffSetup = storage.buffConfig:split(',')
    local textBuff = buffSetup[2] and buffSetup[2]:trim() or buffSetup[1]:trim()
    if text:lower():trim() == textBuff then
        local cooldown = tonumber(buffSetup[3]) or 5
        storage.buffCDW = os.time() + cooldown
    end
end)
