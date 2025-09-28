setDefaultTab("MAIN")
local HIDE_TIMEOUT = 3000
local hideEvent
local arrowWidget = setupUI([[

UIWidget
  anchors.centerIn: parent
  margin: -20 10 200 0
  size: 32 32
  margin-bottom: 50
]], modules.game_interface.getMapPanel())

local imageUrl = "https://otcscripts.pl/scripts/images/arrow.png"
local function onDownloadImage(image, err)
  if err then
    warn(err)
    return
  end
  arrowWidget:setImageSource(image)
end

HTTP.downloadImage(imageUrl, onDownloadImage)
modules.corelib.g_effects.fadeOut(arrowWidget)

local rotateDegree = {
  ["north-west"] = 45,
  ["north"] = 90,
  ["north-east"] = 135,
  ["west"] = 0,
  ["east"] = 180,
  ["south-west"] = 315,
  ["south"] = 270,
  ["south-east"] = 225
}

local widgetMargins = {
  ["north-west"] = {0, 60, 80, 0},
  ["north"] = {0, 10, 80, 0},
  ["north-east"] = {0, 0, 80, 40},
  ["west"] = {0, 80, 30, 0},
  ["east"] = {0, 0, 30, 55},
  ["south-west"] = {40, 60, 0, 0},
  ["south"] = {40, 10, 0, 0},
  ["south-east"] = {40, 0, 0, 40}
}

local m = macro(100000000, "UI Exiva", function() end)
local function cancelHideEvent()
  if hideEvent then
    hideEvent:cancel()
    hideEvent = nil
  end
end

local function scheduleHideEvent()
  hideEvent = modules.corelib.scheduleEvent(function()
    modules.corelib.g_effects.fadeOut(arrowWidget)
    hideEvent = nil
  end, HIDE_TIMEOUT)
end

local function rotateWidget(direction)
  local rotation = rotateDegree[direction]
  local margins = widgetMargins[direction]
  if not rotation or not margins then
    return
  end

  cancelHideEvent()
  modules.corelib.g_effects.fadeIn(arrowWidget)
  arrowWidget:setRotation(rotation)
  arrowWidget:setMargin(modules.corelib.unpack(margins))
  scheduleHideEvent()
end

local regex = [[to the ([A-z-]+)]]
onTextMessage(function(mode, text)
  if m.isOff() then return end
 
  local result = regexMatch(text, regex)
  if #result > 0 then
    local direction = result[1][2]
	rotateWidget(direction)
  end
end)
