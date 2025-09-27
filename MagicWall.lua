UI.Separator()
setDefaultTab("A")

local marked_tiles = {}
local key = "F11"

function tablefind(tab,el)
  for index, value in ipairs(tab) do
    if value == el then
      return index
    end
  end
end

local holdMWMacro = macro(300, "Magic Wall", function()
  if table.getn(marked_tiles) ~= 0 then
    for i, tile in pairs(marked_tiles) do
      if getDistanceBetween(pos(), tile:getPosition()) > 7 then
        table.remove(marked_tiles, tablefind(marked_tiles, tile))
        tile:setText("")
      end
      if tile:getPosition().z == posz() then
        if tile and tile:getText() == "MARKED" and tile:getTimer() <= 300 or (tile:getTopThing():getId() ~= 2130 and tile:getTopThing():getId() ~= 2130) then
          useWith(3180, tile:getTopUseThing())
        end
      else
        table.remove(marked_tiles, tablefind(marked_tiles, tile))
      end
    end
  end
end, macroTab)

local resetTimer = 0
local resetTiles = false
onKeyDown(function(keys)
  if keys == key and resetTimer == 0 then
    resetTimer = now
  end
end)

onKeyPress(function(keys)
  if keys == key and (resetTimer - now) < -2500 then
    if table.getn(marked_tiles) ~= 0 then
      for i, tile in pairs(marked_tiles) do
        table.remove(marked_tiles, tablefind(marked_tiles, tile))
        tile:setText("")
      end
      resetTiles = true
    else
      resetTimer = 0
    end
  else
    resetTimer = 0
    resetTiles = false
  end
end)

onKeyUp(function(keys)
  if holdMWMacro.isOn() then
    if keys == key and not resetTiles then
      local tile = getTileUnderCursor()
      if tile then
        if tile:getText() == "MARKED" then
          tile:setText("")
          table.remove(marked_tiles, tablefind(marked_tiles, tile))
        else
          tile:setText("MARKED")
          table.insert(marked_tiles, tile)
        end
      end
    end
  end
end)

UI.Separator()
