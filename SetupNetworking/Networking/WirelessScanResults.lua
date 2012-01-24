
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


local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable, require

local oo			= require("loop.simple")
local Icon			= require("jive.ui.Icon")
local Label			= require("jive.ui.Label")
local SimpleMenu 		= require("jive.ui.SimpleMenu")
local Window 			= require("jive.ui.Window")
local Choice 			= require("jive.ui.Choice")

--used to redraw window everytime its shown
local EVENT_WINDOW_ACTIVE     = jive.ui.EVENT_WINDOW_ACTIVE

-- testing
local wicd = { }
wicd.daemon = require("wicdbridge_daemon")
wicd.daemon.wireless = require("wicdbridge_wireless")

-- load Devices "class"
local Devices = require("Networking.Devices")

-- some utility methods
local Networking = {}
Networking.Utilities = require("Networking.Utilities")
Networking.Option = require("Networking.Option")
Networking.ConnectingPopup = require("Networking.ConnectingPopup")
Networking.EssidSelect = require("Networking.WirelessHiddenEssid")
Networking.WirelessSetup = require("Networking.WirelessSetup")

local WirelessResults = oo.class()

function WirelessResults:__init(parent,device)
  
  local obj = oo.rawnew(self)
  
  self.parent = parent
  obj.window = nil
  obj.menu = nil
  obj.device = device
  
  
  local function callback()
    
    -- better than calling as global window lsitener as that is also trigger on load
    
    -- called when essidSelect is closed
    
    --FIXME: rescaning triggers a bug if back is pressed
    -- wicdbridge functions do not seem to return
    -- FIXED
    obj:redraw(true)
  end
  
  
  obj.essidSelect = Networking.EssidSelect(self.parent, callback)
  
  if obj.essidSelect:getSelected() != nil then
    obj.hiddenEssid = obj.essidSelect:getSelected().essid
  end
  
  obj:configureMenu(obj.parent)
  
  
  return obj
  
end

function WirelessResults:configureMenu(parent,rescan)
  
  local menu = SimpleMenu("menu")
  
  if rescan != false and rescan != true then
    rescan = true
  end
  
  
  -- rescan 
  
  local networkList = Devices.Wireless:getNetworkList(rescan,3,self.hiddenEssid)
  
  -- title bar
  
  local menuItem = { text = "Wireless essid:", style = 'section_title', check = Choice (  
      "section_title.choice", 
      {"Quality"}, -- empty table
      function(self) 
        -- do nothing function
  end )}
  
  menu:addItem(menuItem)
  
  -- wireless results
  
  local function wirelessCallback()
    
    -- called when wirelessSetup popped
    
  end
  
  
  
  for i,j in ipairs(networkList) do
    
    local menuItem = { text = j.essid, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        {j.quality}, 
        function() --callback
          wirelessSetup = Networking.WirelessSetup(self.parent,j.bssid,self.device,wirelessCallback)
          wirelessSetup:show()
        end
        
    )}
    
    menu:addItem(menuItem)
    
  end
  
  -- divider
  
  local menuItem = { text = "Options", style = 'section_title', check = Choice (  
      "section_title.choice", 
      {""}, -- empty table
      function(self) 
        -- do nothing function
  end )}
  
  menu:addItem(menuItem)				      
  
  
  
  local options = self:getOptions()
  
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
  
  
  
  self.menu = menu
  
end

function WirelessResults:getOptions()
  
  
  local optionsList = {}
  
  --rescan option
  
  local title = "Rescan"
  
  local options = {}
  
  local function callbackFunction(choiceObject, selectedIndex)
    
    self:redraw(true)
    
  end
  
  Networking.Option(title, options, callbackFunction, nil, optionsList)
  
  -- hidden essid
  
  
  --local function callback()
  
  -- better than calling as global window lsitener as that is also triggered on load
  
  -- called when essidSelect is closed
  
  
  
  title = "Select hidden ESSID:"
  
  local essidSelect = self.essidSelect
  
  
  if essidSelect:getSelected() != nil then
    options = { essidSelect:getSelected().essid }
    self.hiddenEssid = options[1]
  else
    options = {"None"}
    self.hiddenEssid = nil
  end
  
  local function callbackFunction(choiceObject, selectedIndex)
    essidSelect:show()
  end
  
  
  
  local function statusFunction(self) 
    
    return options[1]
    
  end
  
  Networking.Option(title, options, callbackFunction, statusFunction, optionsList)
  
  
  return optionsList
  
  
  
end

function WirelessResults:redraw(rescan)
  
  if self.menu != nil then
    
    if self.parent != nil then
      self.window:removeWidget(self.menu)
      self:configureMenu(self.parent,rescan)
      self.window:addWidget(self.menu)
    end
    
  end
  
end


function WirelessResults:show(parent)
  
  local window = Window("text_list", "Wireless Scan Results")
  
  
  
  
  
  WirelessResults.window = window
  
  self.window:addWidget(self.menu)
  
  self.parent:tieAndShowWindow(self.window)
  
  --refresh window each time its shown
  window:addListener(EVENT_WINDOW_ACTIVE,
    function(event)
      
      
      
  end)
  
end

return WirelessResults



