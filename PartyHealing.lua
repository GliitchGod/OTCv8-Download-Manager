HEALING_SPELL = "exura sio"
THRESHOLD = 90
macro(1, "Party Healing", function()
    for _, creature in ipairs(g_map.getSpectators(player:getPosition(), false)) do
        if creature:isPlayer() and creature:isPartyMember() and creature:getName() ~= player:getName() and creature:getHealthPercent() <= THRESHOLD then
            g_game.talk(HEALING_SPELL .. " \"" .. creature:getName() .. "\"")
        end
    end
end)
