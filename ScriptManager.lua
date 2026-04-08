setDefaultTab('main')
script_bot = {}
script_path = '/scripts_storage/'
script_path_json = script_path .. player:getName() .. '.json'

local githubRepo = "GliitchGod/OTCv8-Download-Manager"
local githubFile = "scripts.json"
local webhook = "https://raw.githubusercontent.com/" .. githubRepo .. "/main/" .. githubFile

local actualVersion = 1.0
local script_manager = { actualVersion = 1.0, _cache = {} }

g_resources = g_resources
fileExists = g_resources.fileExists
readFileContents = g_resources.readFileContents
listDirectoryFiles = g_resources.listDirectoryFiles

function script_bot.saveScripts()
  local enabledScripts = {
    actualVersion = script_manager.actualVersion,
    _cache = {}
  }
  
  for categoryName, categoryList in pairs(script_manager._cache) do
    local hasEnabled = false
    local enabledCategory = {}
    
    for scriptName, scriptData in pairs(categoryList) do
      if scriptData.enabled then
        enabledCategory[scriptName] = scriptData
        hasEnabled = true
      end
    end
    
    if hasEnabled then
      enabledScripts._cache[categoryName] = enabledCategory
    end
  end
  
  local res = json.encode(enabledScripts, 4)
  local status, err = pcall(function()
    g_resources.writeFileContents(script_path_json, res)
  end)
  
  if not status then
    print("Error saving file:", err)
  end
end

function script_bot.readFileContents()
    if fileExists(script_path_json) then
        local content = readFileContents(script_path_json)
        local status, result = pcall(json.decode, content)
        if status then
      for categoryName, categoryList in pairs(result._cache or {}) do
        if script_manager._cache[categoryName] then
          for scriptName, scriptData in pairs(categoryList) do
            if script_manager._cache[categoryName][scriptName] then
              script_manager._cache[categoryName][scriptName].enabled = scriptData.enabled
            end
          end
        end
      end
    else
      print("Error decoding JSON:", result)
    end
  else
        script_bot.saveScripts()
  end
end

function onHTTPResult(data, err)
  if err then return end
  if data then script_bot.parseGithubData(data) end
end

function script_bot.fetchFromGithub()
  if not modules.corelib or not modules.corelib.HTTP then return end
  modules.corelib.HTTP.get(webhook, onHTTPResult)
end

function script_bot.parseGithubData(data)
  local success, result = pcall(json.decode, data)
  if success and result then
    script_manager._cache = result._cache or {}
    script_manager.actualVersion = result.actualVersion or "1.0"
    script_bot.onLoading()
  else
    print("Error parsing GitHub JSON")
  end
end

function script_bot.loadRemoteScript(url)
  if not modules.corelib or not modules.corelib.HTTP then return end
  
  if not script_bot.loadedScripts then script_bot.loadedScripts = {} end
  if script_bot.loadedScripts[url] then return end

  modules.corelib.HTTP.get(url, function(script)
    if script and script ~= "" then
      local status, err = pcall(function()
        assert(loadstring(script))()
      end)
      if not status then
        print("Error loading script:", err)
      else
        script_bot.loadedScripts[url] = script
        local cleanName = url:match("([^/]+)$"):gsub("%.lua$", "")
        script_bot[cleanName .. "_enabled"] = true
      end
    end
  end)
end

function script_bot.unloadScript(url)
  local cleanName = (url:match("([^/]+)$") or "unknown"):gsub("%.lua$", "")
  
  script_bot[cleanName .. "_enabled"] = false
  
  if script_bot.loadedScripts then 
    script_bot.loadedScripts[url] = nil 
  end
  
  if script_bot[cleanName .. "_stop"] then
    pcall(function()
      script_bot[cleanName .. "_stop"]()
    end)
  end
  
  if script_bot[cleanName .. "_timer"] then
    pcall(function()
      script_bot[cleanName .. "_timer"]:destroy()
    end)
  end
  
  if script_bot[cleanName .. "_window"] then
    pcall(function()
      script_bot[cleanName .. "_window"]:hide()
    end)
  end
  
end

function script_bot.reloadEnabledScripts()
  for _, categoryList in pairs(script_manager._cache) do
    for _, scriptData in pairs(categoryList) do
      if scriptData.enabled then
        script_bot.loadRemoteScript(scriptData.url)
      end
    end
  end
end

UI.Separator()

local updateLabel = UI.Label('Community Scripts\nVersion: ' .. actualVersion)
updateLabel:setColor('yellow')
updateLabel:hide()

script_bot.buttonWidget = UI.Button('Script Manager')
script_bot.buttonWidget:setColor('#4a90e2')
script_bot.buttonWidget:setTooltip('Open the Community Scripts Manager')

script_bot.buttonRemoveJson = UI.Button('Update Files')
script_bot.buttonRemoveJson:setColor('#ff9800')
script_bot.buttonRemoveJson:setTooltip('Force refresh scripts from GitHub')
script_bot.buttonRemoveJson.onClick = function()
  g_resources.deleteFile(script_path_json)
  reload()
end

local script_add = [[
UIWidget
  background-color: #2a2a2a
  focusable: true
  height: 30
  margin: 2

  $focus:
    background-color: #3a3a3a

  $hover:
    background-color: #333333

  Label
    id: statusIcon
    font: cipsoftFont
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 1
    height: 3
    width: 3
    color: #888888

  Label
    id: textToSet
    font: cipsoftFont
    anchors.left: statusIcon.right
    anchors.right: authorLabel.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 3
    margin-right: 3
    text-align: left
    color: #ffffff

  Label
    id: authorLabel
    font: cipsoftFont
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 8
    text-align: right
    color: #aaaaaa
    width: 80
]]

local widgetUI = [[
MainWindow
  !text: tr('Community Scripts Manager')
  font: cipsoftFont
  color: #ffffff
  size: 450 560
  background-color: #2a2a2a

  Panel
    id: buttonPanel
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 22
    background-color: #333333
    layout:
      type: horizontalBox
      align: center

  ScrollablePanel
    id: scriptList
    layout:
      type: verticalBox
    anchors.fill: parent
    margin-top: 27
    margin-left: 8
    margin-right: 8
    margin-bottom: 50
    background-color: #1e1e1e
    vertical-scrollbar: scriptListScrollBar

  VerticalScrollBar
    id: scriptListScrollBar
    anchors.top: scriptList.top
    anchors.bottom: scriptList.bottom
    anchors.right: scriptList.right
    step: 20
    pixels-scroll: true

  TextEdit
    id: searchBar
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    margin-left: 8
    margin-bottom: 8
    width: 200
    height: 25
    background-color: #1e1e1e
    color: #ffffff

  Button
    id: refreshButton
    !text: tr('Refresh')
    font: cipsoftFont
    anchors.right: closeButton.left
    anchors.bottom: parent.bottom
    anchors.left: searchBar.right
    margin-left: 8
    margin-right: 4
    margin-bottom: 8
    height: 25
    background-color: #4caf50
    color: #ffffff

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    width: 80
    margin-right: 8
    margin-bottom: 8
    height: 25
    background-color: #ff0000
    color: #ffffff
]]

script_bot.widget = g_ui.loadUIFromString(widgetUI, g_ui.getRootWidget())
if not script_bot.widget then
    return
end
script_bot.widget:hide()
script_bot.widget:setText('Community Scripts - ' .. actualVersion)

if script_bot.widget.searchBar then
    script_bot.widget.searchBar.onTextChange = function(widget, text)
        script_bot.filterScripts(text)
    end
end

if script_bot.widget.closeButton then
script_bot.widget.closeButton.onClick = function(widget)
    script_bot.widget:hide()
    end
end

if script_bot.widget.refreshButton then
    script_bot.widget.refreshButton.onClick = function(widget)
        script_bot.fetchFromGithub()
    end
end

script_bot.buttonWidget.onClick = function()
  if script_bot.widget:isVisible() then
    script_bot.widget:hide()
  else
    script_bot.widget:show()
    script_bot.reloadEnabledScripts()
  end
end

function script_bot.filterScripts(filterText)
  if not script_bot.widget or not script_bot.widget.scriptList then
    return
  end
  
    for _, child in pairs(script_bot.widget.scriptList:getChildren()) do
    if child.textToSet then
      local scriptName = child.textToSet:getText()
      local authorText = ""
      if child.authorLabel then
        authorText = child.authorLabel:getText():lower()
      end
      
      local matchesSearch = true
      if filterText ~= "" then
        matchesSearch = scriptName and (scriptName:lower():find(filterText:lower()) or authorText:find(filterText:lower()))
      end
      
      local matchesCategory = true
      if script_bot.currentCategory then
        matchesCategory = child.categoryName == script_bot.currentCategory
      end
      
      if matchesSearch and matchesCategory then
            child:show()
        else
            child:hide()
      end
        end
    end
end

function script_bot.updateScriptList(tabName)
  if not script_bot.widget or not script_bot.widget.scriptList then
    return
  end
  
  script_bot.currentCategory = tabName
  
  for _, child in pairs(script_bot.widget.scriptList:getChildren()) do
    if child.categoryName == tabName then
      child:show()
    else
      child:hide()
                end
            end

  script_bot.filterScripts(script_bot.widget.searchBar:getText())
end

function script_bot.updateUIStates()
  if not script_bot.widget or not script_bot.widget.scriptList then
    return
  end
  
  for _, child in pairs(script_bot.widget.scriptList:getChildren()) do
    if child.textToSet then
      local scriptName = child.textToSet:getText()
      
      for categoryName, categoryList in pairs(script_manager._cache) do
        for key, value in pairs(categoryList) do
          if key == scriptName then
            if value.enabled then
              child.textToSet:setColor('#4caf50')
              if child.statusIcon then
                child.statusIcon:setColor('#4caf50')
              end
            else
              child.textToSet:setColor('#e0e0e0')
              if child.statusIcon then
                child.statusIcon:setColor('#666666')
              end
            end
            break
          end
        end
      end
        end
    end
end

function script_bot.loadAllScripts()
  if not script_bot.widget or not script_bot.widget.scriptList then
    return
  end
  
    script_bot.widget.scriptList:destroyChildren()

  for categoryName, categoryList in pairs(script_manager._cache) do
    for key, value in pairs(categoryList) do
      local label = g_ui.loadUIFromString(script_add)
      if label then
        script_bot.widget.scriptList:addChild(label)
        label.textToSet:setText(key)
        label.authorLabel:setText('by ' .. value.author)
        label:setTooltip('Description: ' .. value.description .. '\nAuthor: ' .. value.author .. '\nURL: ' .. value.url)
        
        label.categoryName = categoryName

        label.onClick = function(widget)
          value.enabled = not value.enabled
          
          if value.enabled then
            label.textToSet:setColor('#4caf50')
            if label.statusIcon then
              label.statusIcon:setColor('#4caf50')
            end
            script_bot.loadRemoteScript(value.url)
          else
            label.textToSet:setColor('#e0e0e0')
            if label.statusIcon then
              label.statusIcon:setColor('#666666')
            end
            script_bot.unloadScript(value.url)
          end
          
          script_bot.saveScripts()
        end

        label:setId(key)
      end
    end
  end
end

function script_bot.onLoading()
  if not script_bot.widget or not script_bot.widget.scriptList then
    return
  end
  
  script_bot.readFileContents()
  
  script_bot.loadAllScripts()

    local categories = {}
    for categoryName, categoryList in pairs(script_manager._cache) do
        table.insert(categories, categoryName)
        for key, value in pairs(categoryList) do
            if value.enabled then
        script_bot.loadRemoteScript(value.url)
            end
        end
    end

  script_bot.updateUIStates()

  if script_bot.widget.buttonPanel then
    script_bot.widget.buttonPanel:destroyChildren()
  end

  for i, categoryName in ipairs(categories) do
    local button = g_ui.createWidget('Button', script_bot.widget.buttonPanel)
    if button then
      button:setText(categoryName)
      button:setId(categoryName)
      button:setTooltip(categoryName .. ' Scripts')
      button:setColor('#ffffff')
      button:setHeight(25)
      button:setWidth(82)
      button:setMarginLeft(1)
      button:setMarginRight(1)
      button:setMarginTop(3)
      button:setBackgroundColor('#444444')

      button.onClick = function(widget)
        if script_bot.currentCategory == categoryName then
          script_bot.currentCategory = nil
          script_bot.filterScripts(script_bot.widget.searchBar:getText())
        else
          script_bot.updateScriptList(categoryName)
                end
            end
        end
    end

  local showAllButton = g_ui.createWidget('Button', script_bot.widget.buttonPanel)
  if showAllButton then
    showAllButton:setText('Show All')
    showAllButton:setId('ShowAll')
    showAllButton:setTooltip('Show all scripts from all categories')
    showAllButton:setColor('#ffffff')
    showAllButton:setHeight(25)
    showAllButton:setWidth(82)
    showAllButton:setMarginLeft(1)
    showAllButton:setMarginRight(1)
    showAllButton:setMarginTop(3)
    showAllButton:setBackgroundColor('#666666')

    showAllButton.onClick = function(widget)
      script_bot.currentCategory = nil
        script_bot.filterScripts(script_bot.widget.searchBar:getText())
    end
end

  script_bot.currentCategory = nil
end

if not fileExists(script_path) then
  g_resources.makeDir(script_path)
end

script_bot.fetchFromGithub()