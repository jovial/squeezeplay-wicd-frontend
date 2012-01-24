
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



local WiredSetup = oo.class()

function WiredSetup:__init(parent, device, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", "Invalid callback function")
  
  
  local obj = oo.rawnew(self)
  
  obj.parent = parent
  obj.device = device
  
  
  return obj
  
end

function WiredSetup:getParent()
  
  return self.parent
  
end


function WiredSetup:getDevice()
  
  return self.device
  
end

function WiredSetup:createMenu()
  
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
  
  local function connect(device)
    
    -- probably more annoying, reckon manual is best as it gives opporunity to connect again
    --jiveMain:goHome()
    
    local connectingPopup = Networking.ConnectingPopup(self.parent,"","",45)
    
    local function connectCallback(event, info, success, message)
      
      log:info("class: WiredSetup, function: connect/ConnectCallback")
      
      connectingPopup:update(info,message)
      
      if message == "done" then
        connectingPopup:close(success)
        
        if (success) then
          -- make profile default for autoreconnect
          device:makeDefault()
        end
        
      end
      
      
    end
    
    connectingPopup:show()
    
    device:connect(connectCallback)
    
    
    
    
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

function WiredSetup:setCallback(callback)
  self.callback = callback
end

function WiredSetup:getCallback()
  
  return self.callback
end

function WiredSetup:setWindow(window)
  
  self.window = window
  
end

function WiredSetup:getWindow()
  
  return self.window
  
end

function WiredSetup:show()
  
  if self:getWindow() == nil then
    
    
    local window = Window("text_list", "Wired Setup: " .. self:getDevice().deviceID)
    
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


function WiredSetup:redraw()
  log:info("redrawing wired setup window")
  
  local window = self:getWindow()
  window:removeWidget(self.menu)
  self.menu = self:createMenu()
  window:addWidget(self.menu)
  
  
end

return WiredSetup


