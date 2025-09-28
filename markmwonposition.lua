setDefaultTab("A")
--[Config]
local setHK = "Home"
local mwRuneId = 3180
-------------------

local mwTile
local detectTile
onKeyPress(function(keys)
  keys = keys:lower()
  if keys == setHK:lower() then
    local tUnder = getTileUnderCursor()
    
    if not tUnder then return end

    if not mwTile then
      mwTile = tUnder
      mwTile:setText("MW","yellow")
      return
    end

    if not detectTile then
      detectTile = tUnder
      detectTile:setText("WALK","yellow")
      return
    end

    for _, tile in ipairs(g_map.getTiles(posz())) do
      tile:setText("")
    end

    mwTile = nil
    detectTile = nil
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  if newPos and mwTile and detectTile and table.equals(newPos, detectTile:getPosition()) then
    local item = findItem(mwRuneId)
    if not item then
      item = Item.create(mwRuneId)
    end
    g_game.useWith(item, mwTile:getGround())
  end
end)
