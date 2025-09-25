local macroName = 'Exeta Res';
local macroDelay = 100;
local tabName = setDefaultTab('A');


macro(macroDelay, macroName, function()
    if g_game.isAttacking() and 
    distanceFromPlayer(g_game.getAttackingCreature():getPosition()) <= 1 and 
    manapercent() > 30 then
        say("Exeta Res")
        delay(5000)
    end
end, tabName)
