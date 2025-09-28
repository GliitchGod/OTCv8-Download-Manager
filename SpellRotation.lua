setDefaultTab("A")
local distance = 4
local amountOfMonsters = 2
macro(1000, "multi target spell",  function()
    local specAmount = 0
    if not g_game.isAttacking() then
        return
    end
    for i,mob in ipairs(getSpectators()) do
        if (getDistanceBetween(player:getPosition(), mob:getPosition())  <= distance and mob:isMonster())  then
            specAmount = specAmount + 1
        end
    end
    if (specAmount >= amountOfMonsters) then 
        say(storage.Spell2, 250)
    else
        say(storage.Spell1, 250)
    end
end)
addTextEdit("Spell1", storage.Spell1 or "Single target", function(widget, text) 
storage.Spell1 = text
end)
addTextEdit("Spell2", storage.Spell2 or "Multi target", function(widget, text) 
storage.Spell2 = text
end)
