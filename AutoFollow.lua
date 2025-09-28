local panelName = "PrecisionFollow"
setDefaultTab("Main") 

storage[panelName] = storage[panelName] or {}
storage[panelName].enabled = storage[panelName].enabled or false

storage[panelName].leaders = storage[panelName].leaders or {}
storage[panelName].leaders.followName = storage[panelName].leaders.followName or "Follow name"

storage[panelName].delays = storage[panelName].delays or {}
storage[panelName].delays.gameFollow = storage[panelName].delays.gameFollow or 1000
storage[panelName].delays.use = storage[panelName].delays.use or 500
storage[panelName].delays.walk = storage[panelName].delays.walk or 100
storage[panelName].delays.followStop = storage[panelName].delays.followStop or 3500

storage[panelName].other = storage[panelName].other or {}
storage[panelName].other.ropeId = storage[panelName].other.ropeId or 3003
storage[panelName].other.tab = storage[panelName].other.tab or "Main"

storage[panelName].spells = storage[panelName].spells or {}
storage[panelName].spells.magicRope = storage[panelName].spells.magicRope or "Exani Tera"
storage[panelName].spells.levitateUp = storage[panelName].spells.levitateUp or "Exani Hur Up"
storage[panelName].spells.levitateDown = storage[panelName].spells.levitateDown or "Exani Hur Down"

setDefaultTab(storage[panelName].other.tab)

local leaderPositions = {}
local leaderDirections = {}
local leader
local lastLeaderFloor
local standTime = now
local followEnabled = true

local lastUseTime = 0
local lastFollowTime = 0
local followStopTime = 0
local isFollowStopped = false

local function getFollowName()
  return storage[panelName].leaders.followName:lower()
end

local function getRopeId()
  return storage[panelName].other.ropeId
end

local FloorChangers = {
  RopeSpots = {
    Up = {386, 421},
    Down = {}
  },
  Use = {
    Up = {1628, 1629, 1631, 1632, 1638, 1640, 1642, 
                   1664, 1644, 1646, 1646, 1648, 1650, 1651, 
                   1653, 1654, 1656, 1658, 1660, 1662, 1664,
                   1666, 1668, 1669, 1671, 1672, 1674, 1676,
                   1678, 1680, 1682, 1683, 1685, 1687, 1689,
                   1691, 1692, 1694, 1696, 1698, 5097, 5098,
                   5100, 5102, 5104, 5106, 5107, 5109, 5111,
                   5113, 5115, 5116, 5118, 5120, 5122, 5124,
                   5125, 5127, 5129, 5131, 5133, 5134, 5136,
                   5137, 5139, 5140, 5142, 5143, 5277, 5278,
                   5280, 5281, 5283, 5285, 5287, 5289, 5291,
                   5293, 5514, 5516, 6191, 6192, 6194, 6195,
                   6197, 6199, 6201, 6203, 6205, 6207, 6248,
                   6249, 6251, 6252, 6254, 6256, 6258, 6260,
                   6262, 6264, 6891, 6892, 6894, 6896, 6898,
                   6900, 6901, 6903, 6905, 6907, 7033, 7034,
                   7036, 7038, 7040, 7042, 7043, 7075, 7047,
                   7049, 7711, 7712, 7714, 7715, 7717, 7719,
                   7721, 7723, 7725, 7727, 8249, 8250, 8252,
                   8253, 8255, 8257, 8259, 8261, 8263, 8265,
                   8351, 8352, 8354, 8355, 8357, 8359, 8361,
                   8363, 8365, 8367, 9351, 9352, 9354, 9355,
                   9359, 9361, 9363, 9365, 9367, 9551, 9552,
                   9554, 9556, 9558, 9560, 9561, 9563, 9565,
                   9567, 9858, 9859, 9863, 9865, 9867, 9868,
                   9872, 9874, 11232, 11233, 11237, 11239, 11241,
                   11242, 11246, 11248, 13135, 13136, 13142, 13143,
                   17560, 17561, 17563, 17565, 17567, 17569, 17570,
                   17572, 17574, 17576, 17700, 17701, 17703, 17705,
                   17707, 17709, 17710, 17712, 17714, 17716, 17993,
                   17994, 17996, 17998, 18000, 18002, 18003, 18005,
                   18007, 18009, 29443, 20444, 20446, 20448, 20450,
                   20452, 20453, 20455, 20457, 20459, 22502, 22504,
                   22506, 22508, 24541, 24543, 28364, 28365, 28366,
                   28367, 28519, 28658, 28659, 30033, 30034, 30037,
                   30038, 30041, 30043, 30045, 30047, 30049, 30051,
                   30772, 30773, 30774, 30775, 30833, 30834, 80835,
                   30836, 30849, 30850, 30851, 30852, 31494, 31495,
                   31568, 31570, 31663, 31665, 33271, 33273, 33335,
                   33336, 34221, 34223, 34635, 34636, 34638, 34639,
                   34641, 34642, 34644, 34645, 34936, 34937, 34938,
                   34939, 37981, 37982, 37983, 37984, 39351, 39352,
                   39660, 39661, 39934, 39935, 39936, 39937, 42624,
                   43625, 43626, 43627, 42744, 43932, 43933, 43934,
                   43935, 43936, 43937, 43938, 43939, 43952, 43953,
                   11139, 13279, 13294, 8615, 1968, 12023, 20474, 
                   20475, 1948},
    Down = {435}
  }
}

local function handleUse(pos)
  local currentTime = now
  if currentTime - lastUseTime < storage[panelName].delays.use then
    return false
  end
  
  local lastZ = posz()
  if posz() == lastZ then
    local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
    if newTile then
      g_game.use(newTile:getTopUseThing())
      lastUseTime = currentTime
      return true
    end
  end
  return false
end

local function handleRope(pos)
  local currentTime = now
  if currentTime - lastUseTime < storage[panelName].delays.use then
    return false
  end
  
  local lastZ = posz()
  if posz() == lastZ then
    local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
    if newTile then
      say(storage[panelName].spells.magicRope)
      lastUseTime = currentTime
      return true
    end
  end
  return false
end

local floorChangeSelector = {
  RopeSpots = {Up = handleRope, Down = handleRope},
  Use = {Up = handleUse, Down = handleUse}
}

local function distance(pos1, pos2)
  local pos2 = pos2 or player:getPosition()
  return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

local function executeClosest(possibilities)
  local closest
  local closestDistance = 99
  for _, data in ipairs(possibilities) do
    local dist = distance(data.pos)
    if dist < closestDistance then
      closest = data
      closestDistance = dist
    end
  end

  if closest then
    closest.changer(closest.pos)
    return true
  end
  
  return false
end

local function handleFloorChange()
  local range = 1
  local p = player:getPosition()
  local possibleChangers = {}
  for _, dir in ipairs({"Down", "Up"}) do
    for changer, data in pairs(FloorChangers) do
      for x = -range, range do
        for y = -range, range do
          local tile = g_map.getTile({x = p.x + x, y = p.y + y, z = p.z})
          if tile and tile:getTopUseThing() then
            if table.find(data[dir], tile:getTopUseThing():getId()) then
              table.insert(possibleChangers, {changer = floorChangeSelector[changer][dir], pos = {x = p.x + x, y = p.y + y, z = p.z}})
            end
          end
        end
      end
    end
  end
  if #possibleChangers > 0 then
    return executeClosest(possibleChangers)
  end
  
  return false
end

local function levitate(dir)
  turn(dir)
  schedule(storage[panelName].delays.use, function()
    say(storage[panelName].spells.levitateDown)
    say(storage[panelName].spells.levitateUp)
  end)
end

local function matchPos(p1, p2)
  return (p1.x == p2.x and p1.y == p2.y)
end

local function useRope(pos)
  if not pos then
    pos = player:getPosition()
  end
  
  local dirs = {{0, 0}, {-1, 0}, {1, 0}, {0, -1}, {0, 1}, {1, -1}, {1, 1}, {-1, 1}, {-1, -1}}
  
  for i = 1, #dirs do
    local tpos = {x = pos.x+dirs[i][1], y = pos.y+dirs[i][2], z = posz()}
    local tile = g_map.getTile(tpos)
    
    if tile then
      if tile:getGround() then
        local ropeSpots = FloorChangers.RopeSpots.Up
        if table.contains(ropeSpots, tile:getGround():getId()) then
          if handleRope(tpos) then
            return true
          end
        end
      end
    end
  end
  
  return false
end

local function getStandTime()
  return now - standTime
end

local function doFollow()
  if not storage[panelName].enabled or not followEnabled then return end
  
  local currentTime = now
  
  -- Check if follow should be stopped due to path blocking
  if isFollowStopped then
    if currentTime - followStopTime < storage[panelName].delays.followStop then
      return
    else
      isFollowStopped = false
    end
  end
  
  -- Check game follow delay
  if currentTime - lastFollowTime < storage[panelName].delays.gameFollow then
    return
  end
  
  if not leader then
    local leaderPos = leaderPositions[posz()]
    if leaderPos and getDistanceBetween(player:getPosition(), leaderPos) > 0 then
      autoWalk(leaderPos, 70, {ignoreNonPathable=true, precision=0})
      lastFollowTime = currentTime
      schedule(storage[panelName].delays.walk, function() end)
      return
    end
    
    if handleFloorChange() then
      lastFollowTime = currentTime
      return
    end
    
    local dir = leaderDirections[posz()]
    if dir then
      levitate(dir)
      lastFollowTime = currentTime
    end
  else
    local lpos = leader:getPosition()
    local parameters = {ignoreNonPathable=true, precision=1, ignoreCreatures=true}
    local path = findPath(player:getPosition(), lpos, 40, parameters)
    local distance = getDistanceBetween(player:getPosition(), lpos)
    
    if distance > 1 and not path then
      -- Path is blocked, trigger follow stop
      isFollowStopped = true
      followStopTime = currentTime
      handleFloorChange()
      return
    elseif distance > 2 then
      if getStandTime() > 500 then
        autoWalk(lpos, 40, parameters)
        lastFollowTime = currentTime
        schedule(storage[panelName].delays.walk, function() end)
      end
    end
  end
end

local function followLoop()
  if storage[panelName].enabled and followEnabled then
    doFollow()
    schedule(50, followLoop)
  end
end

g_ui.importStyleFromString([[
PrecisionFollowSettings < MainWindow
  !text: tr('Precision Follow Settings')
  color: orange
  size: 422 350
  @onEscape: self:hide()

  LeadersPanel
    id: leaders
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 6

  UILabel
    anchors.top: parent.top
    anchors.left: parent.left
    font: verdana-11px-rounded 
    margin-left: 5
    text: Leaders
    color: #884B36 

  DelaysPanel
    id: delays
    anchors.top: leaders.bottom
    anchors.left: parent.left
    margin-top: 15

  UILabel
    anchors.top: leaders.bottom
    anchors.left: parent.left
    font: verdana-11px-rounded 
    margin-top: 9
    margin-left: 5
    text: Delays
    color: #884B36

  OtherPanel
    id: other
    anchors.top: delays.bottom
    anchors.left: parent.left
    margin-top: 15

  UILabel
    anchors.top: delays.bottom
    anchors.left: parent.left
    font: verdana-11px-rounded 
    margin-top: 9
    margin-left: 5
    text: Other
    color: #884B36

  SpellsPanel
    id: spells
    anchors.top: other.bottom
    anchors.left: parent.left
    margin-top: 15

  UILabel
    anchors.top: other.bottom
    anchors.left: parent.left
    font: verdana-11px-rounded
    margin-top: 9
    margin-left: 5
    text: Spells
    color: #884B36

  Button
    size: 45 21
    !text: tr('Close')
    font: cipsoftFont
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    margin-top: 15
    margin-left: 347
    @onClick: self:getParent():hide()

ToolTipLabel < UIWidget
  font: verdana-11px-rounded
  color: orange
  height: 14
  text-align: center 

LeadersPanel < Panel
  id: leaders
  image-source: /images/ui/panel_flat
  image-border: 6
  size: 392 44

  ToolTipLabel
    id: followNameLabel
    anchors.left: parent.left
    anchors.top: parent.top
    margin-top: 15
    margin-left: 10
    font: verdana-11px-rounded
    text: Follow Name
    tooltip: Player name that you will follow

  BotTextEdit
    id: followName
    anchors.left: followNameLabel.left
    anchors.top: parent.top 
    margin-left: 80
    height: 17
    width: 200
    font: verdana-11px-rounded

SpellsPanel < Panel
  id: spells
  image-source: /images/ui/panel_flat
  image-border: 6
  size: 392 74

  ToolTipLabel
    id: magicRopeLabel
    anchors.left: parent.left
    anchors.top: parent.top
    margin-top: 15
    margin-left: 10
    font: verdana-11px-rounded
    text: Magic Rope
    tooltip: Ex. exani tera

  BotTextEdit
    id: magicRope
    anchors.left: magicRopeLabel.left
    anchors.top: parent.top 
    margin-left: 98
    margin-top: 13
    height: 17
    width: 90
    font: verdana-11px-rounded

  ToolTipLabel
    id: levitateUpLabel
    anchors.top: magicRopeLabel.top
    anchors.left: magicRope.left
    margin-left: 105
    font: verdana-11px-rounded
    text: Levitate Up
    tooltip: Ex. exani hur up

  BotTextEdit
    id: levitateUp
    anchors.left: levitateUpLabel.left
    anchors.top: magicRope.top
    margin-left: 80
    height: 17
    width: 90
    font: verdana-11px-rounded

  ToolTipLabel
    id: levitateDownLabel
    anchors.left: magicRopeLabel.left
    anchors.top: magicRopeLabel.top
    margin-top: 30
    font: verdana-11px-rounded
    text: Levitate Down
    tooltip: Ex. exani hur down

  BotTextEdit
    id: levitateDown
    anchors.left: levitateDownLabel.left
    anchors.top: magicRope.bottom
    margin-top: 14 
    margin-left: 98
    height: 17
    width: 90
    font: verdana-11px-rounded

DelaysPanel < Panel
  id: delays
  image-source: /images/ui/panel_flat
  image-border: 6
  size: 392 74

  ToolTipLabel
    id: gameFollowLabel
    anchors.left: parent.left
    anchors.top: parent.top
    margin-top: 15
    margin-left: 10
    font: verdana-11px-rounded
    text: Game Follow
    tooltip: Delay to use follow from the game

  BotTextEdit
    id: gameFollow
    anchors.left: gameFollowLabel.left
    anchors.top: parent.top 
    margin-left: 98
    margin-top: 13
    height: 17
    width: 90
    font: verdana-11px-rounded

  ToolTipLabel
    id: useLabel
    anchors.top: gameFollowLabel.top
    anchors.left: gameFollow.left
    font: verdana-11px-rounded
    margin-left: 105
    text: Use Things
    tooltip: Delay to use things

  BotTextEdit
    id: use
    anchors.top: gameFollow.top 
    anchors.left: useLabel.left
    margin-left: 80
    height: 17
    width: 90
    font: verdana-11px-rounded

  ToolTipLabel
    id: walkDelayLabel
    anchors.left: gameFollowLabel.left
    anchors.top: gameFollowLabel.top
    margin-top: 30
    font: verdana-11px-rounded
    text: Walk
    tooltip: Additional delay to walking

  BotTextEdit
    id: walk
    anchors.left: walkDelayLabel.left
    anchors.top: gameFollow.bottom 
    margin-left: 98
    margin-top: 14
    height: 17
    width: 90
    font: verdana-11px-rounded

  ToolTipLabel
    id: followStopDelayLabel
    anchors.top: walkDelayLabel.top
    anchors.left: walk.left
    font: verdana-11px-rounded
    margin-left: 105
    text: Follow Stop
    tooltip: When the path to the player that you follow is blocked, follow stops for a while

  BotTextEdit
    id: followStop
    anchors.top: walk.top 
    anchors.left: followStopDelayLabel.left
    margin-left: 80
    height: 17
    width: 90
    font: verdana-11px-rounded

OtherPanel < Panel
  id: other
  image-source: /images/ui/panel_flat
  image-border: 6
  size: 392 44

  ToolTipLabel
    id: tabLabel
    anchors.left: parent.left
    anchors.top: parent.top
    margin-top: 15
    margin-left: 10
    font: verdana-11px-rounded
    text: Tab Name
    tooltip: Script will show in this tab

  BotTextEdit
    id: tab
    anchors.left: tabLabel.left
    anchors.top: parent.top 
    margin-left: 98
    margin-top: 14
    height: 17
    width: 90
    font: verdana-11px-rounded

  ToolTipLabel
    id: ropeLabel
    anchors.left: tab.left
    anchors.top: tabLabel.top
    margin-left: 105
    font: verdana-11px-rounded
    text: Rope ID
    tooltip: Rope Item id

  BotTextEdit
    id: ropeId
    anchors.left: ropeLabel.left
    anchors.top: tab.top 
    margin-left: 80
    height: 17
    width: 90
    font: verdana-11px-rounded
]])

local panel = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 115
    !text: tr('Precision Follow')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], getTab(storage[panelName].other.tab))
panel:setId(panelName)

panel.title:setOn(storage[panelName].enabled)
panel.title.onClick = function(widget)
  storage[panelName].enabled = not storage[panelName].enabled
  widget:setOn(storage[panelName].enabled)
  
  if storage[panelName].enabled then
    followEnabled = true
    leader = getCreatureByName(getFollowName())
    followLoop()
  else
    followEnabled = false
  end
end
 
panel.setup.onClick = function(widget)
  local settingsWindow = UI.createWindow('PrecisionFollowSettings')

  -- Remove mainLeader references
  settingsWindow.leaders.followName:setText(storage[panelName].leaders.followName)
  settingsWindow.leaders.followName.onTextChange = function(widget, text)
    storage[panelName].leaders.followName = text:lower()
    leader = getCreatureByName(text)
  end


  settingsWindow.delays.gameFollow:setText(storage[panelName].delays.gameFollow)
  settingsWindow.delays.gameFollow.onTextChange = function(widget, text)
    local value = tonumber(text) or storage[panelName].delays.gameFollow
    storage[panelName].delays.gameFollow = value
  end

  settingsWindow.delays.use:setText(storage[panelName].delays.use)
  settingsWindow.delays.use.onTextChange = function(widget, text)
    local value = tonumber(text) or storage[panelName].delays.use
    storage[panelName].delays.use = value
  end

  settingsWindow.delays.walk:setText(storage[panelName].delays.walk)
  settingsWindow.delays.walk.onTextChange = function(widget, text)
    local value = tonumber(text) or storage[panelName].delays.walk
    storage[panelName].delays.walk = value
  end

  settingsWindow.delays.followStop:setText(storage[panelName].delays.followStop)
  settingsWindow.delays.followStop.onTextChange = function(widget, text)
    local value = tonumber(text) or storage[panelName].delays.followStop
    storage[panelName].delays.followStop = value
  end

  settingsWindow.other.tab:setText(storage[panelName].other.tab)
  settingsWindow.other.tab.onTextChange = function(widget, text)
    storage[panelName].other.tab = text
  end

  settingsWindow.other.ropeId:setText(storage[panelName].other.ropeId)
  settingsWindow.other.ropeId.onTextChange = function(widget, text)
    local value = tonumber(text) or storage[panelName].other.ropeId
    storage[panelName].other.ropeId = value
  end

  settingsWindow.spells.magicRope:setText(storage[panelName].spells.magicRope)
  settingsWindow.spells.magicRope.onTextChange = function(widget, text)
    storage[panelName].spells.magicRope = text
  end

  settingsWindow.spells.levitateUp:setText(storage[panelName].spells.levitateUp)
  settingsWindow.spells.levitateUp.onTextChange = function(widget, text)
    storage[panelName].spells.levitateUp = text
  end

  settingsWindow.spells.levitateDown:setText(storage[panelName].spells.levitateDown)
  settingsWindow.spells.levitateDown.onTextChange = function(widget, text)
    storage[panelName].spells.levitateDown = text
  end
  
  settingsWindow:show()
  settingsWindow:raise()
  settingsWindow:focus()
end

onCreaturePositionChange(function(creature, newPos, oldPos)
  if not storage[panelName].enabled or not followEnabled then return end
  
  if creature:getName() == player:getName() then
    standTime = now
    return
  end
  
  if creature:getName():lower() ~= getFollowName() then return end
  
  if newPos then
    leaderPositions[newPos.z] = newPos
    lastLeaderFloor = newPos.z
    if newPos.z == posz() then
      leader = creature
    else
      leader = nil
    end
  else
    leader = nil
  end
  
  if oldPos then
    if newPos and oldPos.z ~= newPos.z then
      leaderDirections[oldPos.z] = creature:getDirection()
    end
    
    local oldTile = g_map.getTile(oldPos)
    local walkPrecision = 1
    if oldTile then
      if not oldTile:hasCreature() then
        walkPrecision = 0
      end
    end    
    
    autoWalk(oldPos, 40, {ignoreNonPathable=1, precision=walkPrecision})
  end
end)

onCreatureAppear(function(creature)
  if not storage[panelName].enabled or not followEnabled then return end
  if creature:getPosition().z ~= posz() then return end
  
  if creature:getName():lower() == getFollowName() then
    leader = creature
  elseif creature:getName() == player:getName() then
    if lastLeaderFloor and lastLeaderFloor == posz() then
      leader = getCreatureByName(getFollowName())
    end
  end
end)

onCreatureDisappear(function(creature)
  if not storage[panelName].enabled or not followEnabled then return end
  if creature:getPosition().z ~= posz() then return end
  
  if creature:getName():lower() == getFollowName() then
    leader = nil
  elseif creature:getName() == player:getName() and posz() ~= lastLeaderFloor then
    leader = nil
  end
end)

leader = getCreatureByName(getFollowName())
if storage[panelName].enabled then
  followEnabled = true
  followLoop()
end
