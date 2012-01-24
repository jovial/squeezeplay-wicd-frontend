
    --[[
    A frontend to wicd for squeezeplay
    Copyright (C) 2011  Will Szumski

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    --]]


--[[
=head1 NAME

applets.Test.SetupNetworking 

=head1 DESCRIPTION

Front end to wicd for squeezeplay

=head1 FUNCTIONS

-- add some functions

=cut
--]]



local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable, require, tostring = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable, require, tostring

-- clean thse up, not all used...

local io                     = require("io")
local oo                     = require("loop.simple")
local math                   = require("math")
local string                 = require("string")
local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")
local os		= require("os")

local Label            = require("jive.ui.Label")
local debug            = require("jive.utils.debug")
local datetime         = require("jive.utils.datetime")

local Applet                 = require("jive.Applet")
local System                 = require("jive.System")
local Checkbox               = require("jive.ui.Checkbox")
local Choice                 = require("jive.ui.Choice")
local Framework              = require("jive.ui.Framework")
local Event                  = require("jive.ui.Event")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local Button                 = require("jive.ui.Button")
local Popup                  = require("jive.ui.Popup")
local Group                  = require("jive.ui.Group")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Slider                 = require("jive.ui.Slider")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Textinput              = require("jive.ui.Textinput")
local Window                 = require("jive.ui.Window")
local ContextMenuWindow      = require("jive.ui.ContextMenuWindow")
local Timer                  = require("jive.ui.Timer")
local Keyboard               = require("jive.ui.Keyboard")
local Task		= require("jive.ui.Task")
local Timer         = require("jive.ui.Timer")

local Font                   = require("jive.ui.Font")
local jive = jive


local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")

local appletManager = appletManager
local jnt              = jnt


local EVENT_ALL               = jive.ui.EVENT_ALL
local EVENT_ALL_INPUT         = jive.ui.EVENT_ALL_INPUT
local ACTION                  = jive.ui.ACTION
local EVENT_KEY_ALL           = jive.ui.EVENT_KEY_ALL
local EVENT_MOUSE_HOLD        = jive.ui.EVENT_MOUSE_HOLD
local EVENT_MOUSE_DRAG        = jive.ui.EVENT_MOUSE_DRAG
local EVENT_MOUSE_PRESS       = jive.ui.EVENT_MOUSE_PRESS
local EVENT_MOUSE_DOWN        = jive.ui.EVENT_MOUSE_DOWN
local EVENT_MOUSE_UP          = jive.ui.EVENT_MOUSE_UP
local EVENT_MOUSE_ALL         = jive.ui.EVENT_MOUSE_ALL
local EVENT_ACTION            = jive.ui.EVENT_ACTION
local EVENT_SCROLL            = jive.ui.EVENT_SCROLL
local EVENT_KEY_PRESS         = jive.ui.EVENT_KEY_PRESS
local EVENT_KEY_HOLD          = jive.ui.EVENT_KEY_HOLD
local EVENT_CHAR_PRESS         = jive.ui.EVENT_CHAR_PRESS
local EVENT_WINDOW_PUSH       = jive.ui.EVENT_WINDOW_PUSH
local EVENT_WINDOW_POP        = jive.ui.EVENT_WINDOW_POP
local EVENT_WINDOW_ACTIVE     = jive.ui.EVENT_WINDOW_ACTIVE
local EVENT_WINDOW_INACTIVE   = jive.ui.EVENT_WINDOW_INACTIVE
local EVENT_FOCUS_LOST        = jive.ui.EVENT_FOCUS_LOST
local EVENT_FOCUS_GAINED      = jive.ui.EVENT_FOCUS_GAINED
local EVENT_SHOW              = jive.ui.EVENT_SHOW
local EVENT_HIDE              = jive.ui.EVENT_HIDE
local EVENT_CONSUME           = jive.ui.EVENT_CONSUME
local EVENT_UNUSED            = jive.ui.EVENT_UNUSED

-- detect script location and add it to path
package.cpath = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .. "lib/" .."?.so;" .. package.cpath
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;" .. package.path

local wicd = { }
wicd.daemon = require("wicdbridge_daemon")
wicd.daemon.wireless = require("wicdbridge_wireless")
wicd.daemon.wired = require("wicdbridge_wired")

local WiredSetup = require("Networking.WiredSetup")

module(..., Framework.constants)
oo.class(_M, Applet)

-- load Devices "class"
local Devices = require("Networking.Devices")

-- some utility methods
local Networking = {}
Networking.Utilities = require("Networking.Utilities")
Networking.Option = require("Networking.Option")
Networking.ConnectingPopup = require("Networking.ConnectingPopup")
Networking.WirelessScanResults = require ("Networking.WirelessScanResults")
Networking.ConnectionStatus = require ("Networking.ConnectionStatus")

-- populates Devices with deviceIDs and returns a reference

function searchForNetworkDevices(self)
  
  Devices.Wireless:populate()
  Devices.Wired:populate()
  
  return Devices
  
end

local function getSectionTitle(identifier)
  
  return identifier .. " devices:"
  
end

local function getRadioGroup(identifier)
  --store in global list / create if not already there
  radioGroups = radioGroups or {}
  
  if radioGroups[identifier] == nil then
    
    radioGroups[identifier] = RadioGroup()
  end
  
  return radioGroups[identifier]
  
end

-- maintain a list of radiobuttons, for ease of lookup

-- lookup a radiobutton with a corresponding identifier
local function getRadioButton(identifier)
  
  return radioButtons[identifier]
  
end
-- store a radiobutton with its corresponding identifier in a list
local function setRadioButton(identifier, radioButton)
  
  radioButtons = radioButtons or {}
  
  radioButtons[identifier] = radioButton
  
  return radioButton
  
end



-- takes in a jive.ui.Menu and adds the corresponding network devices to bottom of list

local function addNetworkDevicesToMenu(self, menu, devices)
  
  
  local deviceList = { [Devices.Wired] = "Wired" , [Devices.Wireless] = "Wireless" }
  
  
  for x,y in pairs(deviceList) do
    
    
    local menuItem = { text = getSectionTitle(y), style = 'section_title', 
      check =  Choice(
        "section_title.choice",  -- style
        {"Enabled"}, 
        function(self) --callback
          
        end
        
    )}
    
    menu:addItem(menuItem)
    
    for i,v in ipairs(x.list) do
      
      
      menuItem = {	text = v.deviceID, 
        style = 'item_choice',
        check = setRadioButton(v, RadioButton(
            "radio", 
            getRadioGroup(y), 
            function(self)
              
            end,
            (getmetatable(v):getSelected() == v)
        )), 
        callback = function(event, menuItem) 
          
          
          if event:getType() == EVENT_ACTION then
            
            self:showDeviceConfigurationWindow(v,menuItem)
          else
            local enabledDevice = getmetatable(v):getSelected()
            local enabledRadioButton = getRadioButton(enabledDevice)
            if (enabledRadioButton != nil) then
              RadioButton.setSelected(enabledRadioButton)
              --print("just enabled a button") --convert to log
              if menuItem.check:isSelected() then
                RadioButton._set(menuItem.check,true)
              end
            else
              -- illusion of being deselcted
              menuItem.check:setSelected()
              RadioButton._set(menuItem.check,false)
            end
          end
          
          
          
          
        end,
        cmCallback = function(event, item)
          
          self:cmDevices(event,item,v)
          
          return EVENT_CONSUME
        end
      }
      
      
      menu:addItem(menuItem)
      
    end
  end
  
  
  
  
end


function showDeviceConfigurationWindow(parent,device,menuItem)
  
  log.info("entering showDeviceConfigurationWindow")
  
  if getmetatable(device) == Devices.Wireless then
    
    local scanResults = Networking.WirelessScanResults(parent,device)
    scanResults:show()
    
  else
    
    local wiredSetup = WiredSetup(parent,device)
    wiredSetup:show()
    
    
  end
  
  
end


--add any options that will affect all devices in here 

local function addGlobalOptions(self, menu)
  
  -- use style, section_title we made when addings devices to keep styling consistent
  
  -- title
  
  local menuItem = { text = "Global settings:", style = 'section_title', check = Choice (  
      "section_title.choice", 
      {"State"}, -- empty table
      function(self) 
        -- do nothing function
  end )}
  
  menu:addItem(menuItem)
  
  --title end
  
  -- options
  
  local globalOptions = {}
  
  local title = "Status"
  
  
  local options = {}
  
  local function callbackFunction(choiceObject, selectedIndex)
    
    connectionStatus = Networking.ConnectionStatus(self)
    connectionStatus:show()
    
    
  end
  
  
  Networking.Option(title, options, callbackFunction, nil, globalOptions)
  
  --next
  
  title = "Auto-reconnect"
  
  options = {"Enabled","Disabled"}
  
  
  
  local function callbackFunction(choiceObject, selectedIndex)
    
    if choiceObject:getSelected() == "Enabled" then
      wicd.daemon.SetAutoReconnect(true)
      return
    end
    
    wicd.daemon.SetAutoReconnect(false)
    
  end
  
  
  
  local function statusFunction(self) 
    
    
    
    if wicd.daemon.GetAutoReconnect() then
      
      return self.options[1] -- "Enabled"
      --return "Enabled"
    end
    
    return self.options[2] --"Disabled"
    --return "Disabled"
    
  end
  
  Networking.Option(title, options, callbackFunction, statusFunction, globalOptions)
  
  -- next
  
  title = "Auto-connect"
  
  options = {}
  
  
  local function convertStatusCode(status, info)
    
    if status == 0 then
      return "Not Connected"
      
    end
    
    if status ==1 then
      local message = "Connecting to: "
      message = message .. tostring(info[1])
      return message
      
    end
    
    if status ==2 then
      return "Connected to wireless"
    end
    
    if status ==3 then
      return "Connected to wired"
    end
    
    if status ==4 then
      return "Suspended"
    end
    
    return "Unknown message"
    
  end
  
  
  local function callbackFunction(choiceObject, selectedIndex)
    
    --local count = selectedIndex or 0
    
    --lua_table.insert(choiceObject.options,"test" .. count)
    
    local title = "Attempting to automatically connect..."
    local connectTask = nil
    
    local connectingPopup = Networking.ConnectingPopup(self,title,"",45)
    
    local function closePopup(success)
      connectingPopup:close(success)
      if (connectTask != nil) then
        connectTask:removeTask()
      end
    end
    
    local function connectCallback(event, status, info, inDeadZone)
      
      log:info("class: SetupNetworking, function: connectCallback")
      
      message = convertStatusCode(status,info)
      
      connectingPopup:update(title,message)
      
      -- status reverted back to 0
      if not inDeadZone and (status == 0) then
        closePopup(false)
      end
      
      -- indicates connction successful
      if status == 2 or status == 3 then
        closePopup(true)
      end
      -- pop timeout reached, stop monitoring loop
      if not connectingPopup:isVisible() then
        if (connectTask != nil) then
          connectTask:removeTask()
        end
      end
      
    end
    
    connectingPopup:show()
    
    --give time for the popup to appear
    local timer = Timer(100, function() connectTask = Devices.Networking:autoConnect(connectCallback,2000) end, true)
    timer:start()
    
    
    
  end
  
  local function statusFunction(self,choiceObject,selectedIndex) 
    
    
    
    
  end
  
  Networking.Option(title, options, callbackFunction, statusFunction, globalOptions)
  
  
  
  for i,j in ipairs(globalOptions) do
    
    local menuItem = { text = j.title, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        j.options,
        j:getCallback(),
        j:getStatusIndex()
        
    )}
    
    
    menu:addItem(menuItem)
    
  end
  
  
  
  
  
  
end

--

function createDeviceConfigMenu(self)
  
  local menu = SimpleMenu("menu")
  
  -- add network devices
  
  local devices =  self:searchForNetworkDevices() 
  
  addNetworkDevicesToMenu(self,menu, devices)
  
  -- add global options
  
  addGlobalOptions(self,menu)
  
  return menu
  
end



function menu(self, menuItem)
  
  log:info("SetupNetworkingApplet: starting")
  
  
  -- creates a new style, called "section_title", as defined in Networking/Utilities.lua
  Networking.Utilities:createSectionTitleStyle()
  
  
  
  local menu = self:createDeviceConfigMenu()
  
  
  --  create window and set title to name from previous menu
  local window = Window("icon_list", menuItem.text)
  
  
  -- add menu to widget
  window:addWidget(menu)
  
  
  window:addListener(EVENT_WINDOW_ACTIVE,
    function(event)
      -- redraw
      log:info("redrawing main window")
      window:removeWidget(menu)
      menu = self:createDeviceConfigMenu()
      window:addWidget(menu)
      
  end)
  
  
  -- tie and show 	
  self:tieAndShowWindow(window)
  return window
  
  
  
end


local function _refreshDevicesCM(event, item, device, window, menu)
  
  window:removeWidget(menu)
  window:addWidget(generateDevicesCM(self,event, item, device,window))
  
  
end



function cmDevices(self,event, item, device)
  
  local window = ContextMenuWindow(item.text) 
  
  local menu = generateDevicesCM(self,event, item, device, window)
  
  
  
  for i,j in pairs(menu.listeners) do 
    
  end
  
  window:addWidget(menu)
  
  
  self:tieAndShowWindow(window)
end




function generateDevicesCM(self,event, item, device, window)
  
  local menu = SimpleMenu("menu")
  
  
  local wiredDisabled = {}
  local wiredEnabled = {}
  local wirelessDisabled = {}
  local wirelessEnabled = {}
  local genericEnabled = {}
  local genericDisabled = {}
  local wiredGeneric = {}
  local wirelessGeneric = {}
  local generic = {}
  
  local connectingPopup = Networking.ConnectingPopup(self,"","",10)
  
  local function wiredConnectCallback(event, info, success, message)
    
    log:info("class: SetupNetworking, function: generateDevicesCM/wiredConnectCallback")
    
    connectingPopup:update(info,message)
    
    if message == "done" then
      connectingPopup:close(success)
    end
    
    
  end
  
  local menuItem = { text = "Connect",
    sound = "WINDOWSHOW",
    callback = function(event, menuItem)
      --connectingPopup = Networking.ConnectingPopup(self,"","",10)
      connectingPopup:show()
      --local task = Task("Wired Connect", self, function() Devices.Wired:connect(wiredConnectCallback) end)
      --task:addTask()
      device:connect(wiredConnectCallback)
  end, weight = 1 }
  
  
  
  lua_table.insert(wiredEnabled, menuItem)
  
  
  
  
  
  
  
  local menuItem = { text = "Disable" ,
    callback = function()
      getmetatable(device).disable()
      item.callback(event,item)
      _refreshDevicesCM(event, item, device, window, menu)
    end,
    weight = 20
  }
  
  
  lua_table.insert(genericEnabled, menuItem)
  
  
  local menuItem = { text = "Enable" ,
    callback = function()
      device:setSelected()
      item.callback(event,item)
      _refreshDevicesCM(event, item, device, window, menu)
    end,
    weight = 20
  }
  
  
  lua_table.insert(genericDisabled, menuItem)
  
  
  
  
  if item.check:isSelected() and (getmetatable(device):getSelected() != nil) then
    
    --enabled menu
    
    for i,j in ipairs(genericEnabled) do
      
      menu:addItem(j)
      
    end		
    
    if getmetatable(device) == Devices.Wireless then
      
      -- wireless menu enabled
      for i,j in ipairs(wirelessEnabled) do
        
        menu:addItem(j)
        
      end
      
    else
      
      -- wired menu enabled
      
      for i,j in ipairs(wiredEnabled) do
        
        menu:addItem(j)
        
      end		
      
    end
    
    
  else
    
    --disabled menu
    
    for i,j in ipairs(genericDisabled) do
      
      menu:addItem(j)
      
    end	
    
    if getmetatable(device) == Devices.Wireless then
      
      -- wireless menu disabled
      
      for i,j in ipairs(wirelessDisabled) do
        
        menu:addItem(j)
        
      end
      
      
      
      
    else
      
      -- wired menu disabled
      
      for i,j in ipairs(wiredDisabled) do
        
        menu:addItem(j)
        
      end
      
      
    end	
    
    
  end
  
  
  
  if getmetatable(device) == Devices.Wireless then
    
    -- wireless generic
    for i,j in ipairs(wirelessGeneric) do
      
      menu:addItem(j)
      
    end	
    
    
    
    
  else
    -- wired generic
    
    for i,j in ipairs(wiredGeneric) do
      
      menu:addItem(j)
      
    end	
    
    
    
  end
  
  for i,j in ipairs(generic) do
    
    menu:addItem(j)	
    
    
  end
  
  menu:setComparator(menu.itemComparatorWeightAlpha)
  
  return menu
  
  
end





--[[

=head1 LICENSE



=cut
--]]


