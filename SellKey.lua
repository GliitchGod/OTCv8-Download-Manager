setDefaultTab("Tools")
UI.Separator()
local ui = setupUI([[
Panel
  height: 71
  padding: 2

  BotItem
    id: key
    anchors.top: parent.top
    anchors.left: parent.left
    margin-left: 1

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: prev.right
    anchors.right: parent.right
    text-align: center
    width: 138
    !text: tr('Sell Items')
    margin-top: 9
    margin-left: 5

  BotContainer
    id: SellItems
    anchors.top: key.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
    height: 34 
]])

if not storage.Seller then
    storage.Seller = {
        enabled = false,
        SellItems = {},
        key = 1722
    }
end

local config = storage.Seller

ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
    config.enabled = not config.enabled
    ui.title:setOn(config.enabled)
end

UI.Container(function()
    config.SellItems = ui.SellItems:getItems()
end, true, nil, ui.SellItems)
ui.SellItems:setItems(config.SellItems)

ui.key.onItemChange = function(widget)
    config.key = widget:getItemId()
end
ui.key:setItemId(config.key)

local function properTable(t)
    local r = {}
    for _, entry in pairs(t) do
      table.insert(r, entry.id)
    end
    return r
end

macro(500, function()
    if not config.enabled then return end
    local containers = getContainers()
    for i, container in pairs(containers) do
        for j, item in ipairs(container:getItems()) do
            if table.find(properTable(config.SellItems), item:getId()) then
                useWith(config.key, item)
            end
        end
    end
end)
