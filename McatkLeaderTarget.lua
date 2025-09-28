PvpAttackLeader = {}
local toAttack = nil
local friends = {"Morpheus", "Rabiot", "Esm 3", "Esm 4"}

onMissle(function(missle)
    if not storage.attackLeader or storage.attackLeader:len() == 0 then
        return
    end
    local src = missle:getSource()
    if src.z ~= posz() then return end
    local from = g_map.getTile(src)
    local to = g_map.getTile(missle:getDestination())
    if not from or not to then return end
    local fromCreatures = from:getCreatures()
    local toCreatures = to:getCreatures()
    if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end
    local c1 = fromCreatures[1]
    if c1:getName():lower() == storage.attackLeader:lower() then
        toAttack = toCreatures[1]
    end
end)

PvpAttackLeader.Macro = macro(50, "Attack Leader's Target", function()
    if toAttack and storage.attackLeader:len() > 0 and toAttack ~=
        g_game.getAttackingCreature() then
        for _, friend in ipairs(friends) do
            if friend:lower() == toAttack:getName():lower() then
                toAttack = nil
                return
            end
        end
        g_game.attack(toAttack)
        toAttack = nil
    end
end)

PvpAttackLeader.editAttackLeader = UI.TextEdit(
                                       storage.attackLeader or "player name",
                                       function(widget, newText)
        storage.attackLeader = newText
    end)

PvpAttackLeader.addFriend = function(name)
    table.insert(friends, name)
end

PvpAttackLeader.removeFriend = function(name)
    for i, friend in ipairs(friends) do
        if friend == name then
            table.remove(friends, i)
            break
        end
    end
end

PvpAttackLeader.setEnabled = function(enabled)
    if enabled then
        PvpAttackLeader.Macro:setOn()
    else
        PvpAttackLeader.Macro:setOff()
    end
end
