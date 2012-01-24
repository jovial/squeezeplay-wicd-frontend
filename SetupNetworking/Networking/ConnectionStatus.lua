
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
local Timer                  = require("jive.ui.Timer")

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




local ConnectionStatus = oo.class()

function ConnectionStatus:__init(parent, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", "Invalid callback function")
  
  
  local obj = oo.rawnew(self)
  
  obj.parent = parent
  
  return obj
  
end

function ConnectionStatus:getParent()
  
  return self.parent
  
end



function ConnectionStatus:createMenu()
  
  local parent = self:getParent()
  
  
  local menu = SimpleMenu("menu")
  
  local status, info = Devices.Networking:getConnectionStatus()
  local displayData = self:getDisplayData(status,info)
  
  for i,j in pairs(displayData) do 
    
    local title = j["heading"] .. ": "
    
    local options = {j["state"]}
    
    if j["type"] == "option" then
      
      
      local menuItem = { text = title, style = 'item_choice', 
        check =  Choice(
          "choice",  -- style
          options,
          function(self) 
            -- do nothing function
          end		   
      )}
      
      
      menu:addItem(menuItem)
      
      
      
    elseif j["type"] == "heading" then
      
      
      local menuItem = { text = title, style = 'section_title', check = Choice (  
          "section_title.choice", 
          options, 
          function(self) 
            -- do nothing function
      end )}
      
      menu:addItem(menuItem)		
      
      
    end	
    
    
  end
  
  
  
  
  return menu
  
end

function ConnectionStatus:getDisplayData(status,info)
  
  local data = {}
  
  
  -- report state
  
  
  if status == 0 then
    local item = {}
    item["type"]="option"
    item["heading"]="State"
    item["state"]="disconnected"
    lua_table.insert(data,item)
    return data
  end
  
  if status == 1 then
    local item = {}
    item["type"]="option"
    item["heading"]="State"
    item["state"]="connecting"
    lua_table.insert(data,item)	
    
    item = {}
    item["type"]="heading"
    item["heading"]="Details"
    item["state"]="State"
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="Device type"
    local deviceType = tostring(info[1])
    item["state"]=deviceType
    lua_table.insert(data,item)
    
    if deviceType == "wireless" then
      item = {}
      item["type"]="option"
      item["heading"]="Network essid"				
      local essid = tostring(info[2])
      item["state"] = essid
      lua_table.insert(data,item)
    end
    
    return data
    
  end
  
  if status == 2 then
    local item = {}
    item["type"]="option"
    item["heading"]="State"
    item["state"]="connected"
    lua_table.insert(data,item)	
    
    item = {}
    item["type"]="heading"
    item["heading"]="Details"
    item["state"]="State"
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="Device type"
    item["state"]="wireless"
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="IP address"
    item["state"]= tostring(info[1])
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="Network"
    item["state"]= tostring(info[2])
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="Signal strength"
    item["state"]= tostring(info[3])
    lua_table.insert(data,item)
    
    -- skip internal network id
    item = {}
    item["type"]="option"
    item["heading"]="Bitrate"
    item["state"]= tostring(info[5])
    lua_table.insert(data,item)
    
    return data	
    
    
    
  end
  
  if status == 3 then
    local item = {}
    item["type"]="option"
    item["heading"]="State"
    item["state"]="connected"
    lua_table.insert(data,item)	
    
    item = {}
    item["type"]="heading"
    item["heading"]="Details"
    item["state"]="State"
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="Device type"
    item["state"]="wired"
    lua_table.insert(data,item)
    
    item = {}
    item["type"]="option"
    item["heading"]="IP address"
    item["state"]= tostring(info[1])
    lua_table.insert(data,item)
    
    return data		
    
  end
  
  if status == 4 then
    local item = {}
    item["type"]="option"
    item["heading"]="State"
    item["state"]="suspended"
    lua_table.insert(data,item)
    return data
  end
  
  return data
  
end


function ConnectionStatus:setCallback(callback)
  self.callback = callback
end

function ConnectionStatus:getCallback()
  
  return self.callback
end

function ConnectionStatus:setWindow(window)
  
  self.window = window
  
end

function ConnectionStatus:getWindow()
  
  return self.window
  
end

function ConnectionStatus:addRefreshTimer()
  
  local timer = Timer(1000, function() self:redraw() end)
  timer:start()
  
  self.timer = timer
  
end

function ConnectionStatus:removeRefreshTimer()
  
  if self.timer != nil then
    self.timer:stop()
    self.timer = nil
  end
  
end


function ConnectionStatus:show()
  
  if self:getWindow() == nil then
    
    
    local window = Window("text_list", "Connection Status")
    
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
        self:removeRefreshTimer()
        					
        
    end)
    
    self:setWindow(window)
    
    self:getParent():tieAndShowWindow(window)
  else
    self:getParent():tieAndShowWindow(self:getWindow())
  end
  
  -- remove old timer, if still set
  self:removeRefreshTimer()
  self:addRefreshTimer()
end


function ConnectionStatus:redraw()
  log:info("redrawing connection status window")
  
  local window = self:getWindow()
  window:removeWidget(self.menu)
  self.menu = self:createMenu()
  window:addWidget(self.menu)
  
  
end

return ConnectionStatus


