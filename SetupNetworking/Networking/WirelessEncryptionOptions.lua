
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


local ipairs, pairs, print, type, setmetatable, table, _G, _assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local SimpleMenu 		= require("jive.ui.SimpleMenu")
local Window 			= require("jive.ui.Window")
local Choice 			= require("jive.ui.Choice")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")

local EVENT_WINDOW_POP  = jive.ui.EVENT_WINDOW_POP
local EVENT_CONSUME  = jive.ui.EVENT_CONSUME


--used to redraw window everytime its shown
local EVENT_WINDOW_ACTIVE     = jive.ui.EVENT_WINDOW_ACTIVE

local SETTINGS_ENTRY = "WirelessEncryption"

local WirelessEncryption = require("Networking.WirelessEncryption")

local EncryptionType = oo.class()

-- we need a reference to the parent to store our settings
-- convert to our own settings manager implementation?
function EncryptionType:__init(parent, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", "Invalid callback function")
  
  
  local obj = oo.rawnew(self)
  
  obj.parent = parent
  obj.window = nil
  obj.menu = nil
  obj.callback = callback
  
  obj:update()
  
  
  return obj
  
end

-- return mapping: wicd reaadable name -> human
function EncryptionType:getEncryptionTypes()
    encTypes = {}
    encTypes.none = "None"
    for i,j in pairs(WirelessEncryption.getEncTypes()) do
    encTypes[i]= j.human_name
    end
    --encTypes.wpa = "WPA passphrase"
    return encTypes
end


function EncryptionType:configureMenu()
  
  local menu = SimpleMenu("menu")
  
    
  encryptionTypes = self:getEncryptionTypes()
  
  log:info("adding enc types: ")

  for i,j in pairs(encryptionTypes) do
    log:info(i .. " -> " .. j)
    local menuItem = { text = j, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        {}, 
        function(choice, selectedIndex) --callback
          self:setSelected(i,j)
          self:storeSettings()
          self.window:hide()
          if (self.callback != nil) then
            self.callback()
          end
        end
        
      ),
      
    }
    
    menu:addItem(menuItem)
    
  end
  		      
  
  self.menu = menu
  
end



function EncryptionType:show()
  
  self:update()
  
  if (self.window == nil) then
    local window = Window("text_list", "Select Encryption Type")
    
    self.window = window
    
    self.window:addWidget(self.menu)
    
    window:addListener(EVENT_WINDOW_POP,
      function(event)
        self.parent:storeSettings()
        if (self.callback != nil) then
          self.callback()
        end						
        
    end)
   
    
  end
  self.parent:tieAndShowWindow(self.window)
  
  
end

function EncryptionType:update()
  
  --prevents the situation where where the menu is modified whilst it is being shown,
  -- and hence producing a "different parent" exception
  if self.window != nil and self.menu != nil then
    self.window:removeWidget(self.menu)
  end
  
  -- should proably parse this from main applet as someone may accidently overwrite
  self.settings = self.parent:getSettings()
  self.settings[SETTINGS_ENTRY] = self.settings[SETTINGS_ENTRY] or {}
  self.settings[SETTINGS_ENTRY].encryption = self.settings[SETTINGS_ENTRY].encryption or {}
  
  self:configureMenu()
  
  if self.window != nil and self.menu != nil then
    self.window:addWidget(self.menu)
  end
  
  
end


function EncryptionType:setSelected(name, human)
  log:info("Encryption: " .. human .. " selected") 
  self.settings[SETTINGS_ENTRY].encryption.real_name = name
  self.settings[SETTINGS_ENTRY].encryption.human_name = human
  
end


function EncryptionType:clearSelected()
  
  self.settings[SETTINGS_ENTRY].encryption = {}
  
end


function EncryptionType:getSelected(parent)
  
  self:update()
  return self.settings[SETTINGS_ENTRY].encryption
  
end

function EncryptionType:storeSettings()
    self.parent:storeSettings()
end


function EncryptionType:redraw()

  if self.menu != nil then
    
    if self.parent != nil then
      self.window:removeWidget(self.menu)
      self:configureMenu()
      self.window:addWidget(self.menu)
    end
    
  end
  
end

return EncryptionType



