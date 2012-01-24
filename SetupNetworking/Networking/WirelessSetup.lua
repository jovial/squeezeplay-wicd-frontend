
local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local Icon			= require("jive.ui.Icon")
local Label			= require("jive.ui.Label")
local SimpleMenu 		= require("jive.ui.SimpleMenu")
local Window 			= require("jive.ui.Window")
local Choice 			= require("jive.ui.Choice")
local Keyboard 			= require("jive.ui.Keyboard")			
local Textinput 		= require("jive.ui.Textinput")
local Label 			= require("jive.ui.Label")
local Group			= require("jive.ui.Group")
local ContextMenuWindow      = require("jive.ui.ContextMenuWindow")
local Textinput              = require("jive.ui.Textinput")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")

local appletManager = appletManager
local jiveMain      = jiveMain

local EVENT_WINDOW_POP  = jive.ui.EVENT_WINDOW_POP
local EVENT_CONSUME  = jive.ui.EVENT_CONSUME



--used to redraw window everytime its shown
local EVENT_WINDOW_ACTIVE     = jive.ui.EVENT_WINDOW_ACTIVE

-- load Devices "class"
local Devices = require("Networking.Devices")

-- some utility methods
local Networking = {}
Networking.Utilities = require("Networking.Utilities")
Networking.Option = require("Networking.Option")
Networking.ConnectingPopup = require("Networking.ConnectingPopup")
--SettingsManager = require("Networking.SettingsManager")



local WirelessSetup = oo.class()

function WirelessSetup:__init(parent, bssid, device, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", "Invalid callback function")
  
  
  local obj = oo.rawnew(self)
  obj.parent = parent
  obj.bssid = bssid
  obj.device = device
  
  device:setBssid(bssid)
  
  
  
  
  return obj
  
end

function WirelessSetup:getParent()
  
  return self.parent
  
end

function WirelessSetup:getBssid()
  
  return self.bssid
  
end

function WirelessSetup:getDevice()
  
  return self.device
  
end

function WirelessSetup:createMenu()
  
  local parent = self:getParent()
  local device = self:getDevice()
  
  local menu = SimpleMenu("menu")
  
  -- redraw wrapper
  local function redraw()
    
    self:redraw()
    
  end
  
  local function getInput(title, callback, initial, style)
    
    if style == "ip" then
      local style = "numeric"
      
      
      local textinput = Networking.Utilities.ipAddressValue(initial)
      
      
      Networking.Utilities:getUserInput(parent, style, title, callback, initial, textinput)
    else
      local style = "qwerty"
      Networking.Utilities:getUserInput(parent, style, title, callback, initial, textinput)
      
    end
  end
  
  local options = Networking.Utilities:getStandardNetworkOptions(device, redraw, getInput)
  
  for i,j in ipairs(options) do
    
    local menuItem = { text = j.title, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        j.options,
        j:getCallback(),
        j:getStatusIndex()
        
    )}
    
    
    menu:addItem(menuItem)
    
  end
  
  
  
  local menuItem = { text = "Options", style = 'section_title', check = Choice (  
      "section_title.choice", 
      {""}, -- empty table
      function(self) 
        -- do nothing function
  end )}
  
  menu:addItem(menuItem)	
  
  local function connect(device, key)
    
    -- probably more annoying, reckon manual is best as it gives opporunity to connect again
    --jiveMain:goHome()
    
    local connectingPopup = Networking.ConnectingPopup(self.parent,"","",45)
    
    local function connectCallback(event, info, success, message)
      
      log:info("class: WirelessSetup, function: connect/ConnectCallback")
      
      connectingPopup:update(info,message)
      
      if message == "done" then
        connectingPopup:close(success)
        
        if success then
          device:storeEncKey()
        else
          -- assume all failures due to password failure, we cannot guarentee 
          -- we will get authentication failed message
          device:removeEncKey()
        end
        
      end
      
      
    end
    
    connectingPopup:show()
    
    connectTask, keyRequested = device:connect(connectCallback,key)
    
    
    if (keyRequested == true) then
      
      connectTask:removeTask()
      connectingPopup:terminate()
      
      local function reconnect(value)
        
        device:setEncKey(value)
        connect(device, value)
        
      end
      
      local encryptionType = device:getEncType()
      
      getInput(encryptionType .. " key",reconnect, "", "qwerty")
      
    end
    
    
  end
  
  options = Networking.Utilities:getStandardConnectionOptions(device, redraw, getInput,connect)
  
  for i,j in ipairs(options) do
    
    local menuItem = { text = j.title, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        j.options,
        j:getCallback(),
        j:getStatusIndex()
        
    )}
    
    
    menu:addItem(menuItem)
    
  end
  
  
  return menu
  
end

function WirelessSetup:setCallback(callback)
  self.callback = callback
end

function WirelessSetup:getCallback()
  
  return self.callback
end

function WirelessSetup:setWindow(window)
  
  self.window = window
  
end

function WirelessSetup:getWindow()
  
  return self.window
  
end

function WirelessSetup:show()
  
  if self:getWindow() == nil then
    
    local essid = Devices.Wireless:getWirelessProperty(self:getBssid(),"essid")
    
    local window = Window("text_list", "Wireless Setup: " .. essid)
    
    self.menu = self:createMenu()
    window:addWidget(self.menu)
    
    
    window:addListener(EVENT_WINDOW_ACTIVE,
      function(event)
        --self.window:hide()
        self:redraw()
        
    end)
    
    window:addListener(EVENT_WINDOW_POP,
      function(event)
        --self.parent:storeSettings()
        if (self:getCallback() != nil) then
          self:getCallback()
        end						
        
    end)
    
    self:setWindow(window)
    
    self:getParent():tieAndShowWindow(window)
  else
    self:getParent():tieAndShowWindow(self:getWindow())
  end
end


function WirelessSetup:redraw()
  
  local window = self:getWindow()
  window:removeWidget(self.menu)
  self.menu = self:createMenu()
  window:addWidget(self.menu)
  
end

return WirelessSetup


