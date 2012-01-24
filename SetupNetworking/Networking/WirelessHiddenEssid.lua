
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


local HiddenEssid = oo.class()

function HiddenEssid:__init(parent, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", "Invalid callback function")
  
  
  local obj = oo.rawnew(self)
  
  obj.parent = parent
  obj.window = nil
  obj.menu = nil
  obj.callback = callback
  
  obj:update()
  
  
  return obj
  
end

function HiddenEssid:configureMenu(parent)
  
  local menu = SimpleMenu("menu")
  
  
  
  local essidList = self.settings.WirelessHiddenEssid.essids
  
  -- essids
  
  for i,j in ipairs(essidList) do
    
    local menuItem = { text = j.essid, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        {}, 
        function(choice, selectedIndex) --callback
          self.settings.WirelessHiddenEssid.selected = j
          parent:storeSettings()
          self.window:hide()
          if (self.callback != nil) then
            self.callback()
          end
        end
        
      ),
      cmCallback = 
      function(event, item)
        self:contextMenu(event,item, j)
        return EVENT_CONSUME
      end
      
    }
    
    menu:addItem(menuItem)
    
  end
  
  -- divider
  
  if lua_table.getn(essidList) != 0 then
    
    local menuItem = { text = "Options", style = 'section_title', check = Choice (  
        "section_title.choice", 
        {""}, -- empty table
        function(self) 
          -- do nothing function
    end )}
    
    menu:addItem(menuItem)				      
    
  end
  
  
  local function addNewNetwork(self,value)
    entry = { ["essid"]=tostring(value) }
    lua_table.insert(self.settings.WirelessHiddenEssid.essids, entry)
    self.parent:storeSettings()
    
    -- refresh list
    self:redraw()
    
    
  end
  
  
  
  local menuItem =	{ 	text = "Add new network ", 
    style = 'item',
    callback = function(event, menuItem)
      -- call keyboard
      self:getUserInput(parent, menuItem, addNewNetwork)
      
      
    end
  }
  
  menu:addItem(menuItem)
  
  
  
  
  self.menu = menu
  
end

function HiddenEssid:getUserInput(parent, menuItem, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", " Invalid callback function")
  local window = Window("text_list", menuItem.text)
  
  local v = Textinput.textValue("")
  
  local userInput 
  
  local textinput = Textinput("textinput", v,
    function(_, value)
      callback(self,value)
      window:playSound("WINDOWSHOW")
      window:hide(Window.transitionPushLeft)
      return true
  end)
  local backspace = Keyboard.backspace()
  local group = Group('keyboard_textinput', { textinput = textinput, backspace = backspace } )
  
  window:addWidget(group)
  window:addWidget(Keyboard('keyboard', "qwerty", textinput))
  window:focusWidget(group)
  
  
  parent:tieAndShowWindow(window)
  
  return userInput
  
  
end

function HiddenEssid:contextMenu(event,item,essidData)
  
  local window = ContextMenuWindow(item.text) 
  
  local menu = SimpleMenu("menu")
  
  local menuItem =	{ 	text = "Delete", 
    callback = function(event, menuItem)
      self:removeItem(essidData)
      window:hide()
      --self:update()
    end
  }
  
  menu:addItem(menuItem)
  
  
  window:addWidget(menu)
  
  
  self.parent:tieAndShowWindow(window)
  
end


function HiddenEssid:show()
  
  self:update()
  
  if (self.window == nil) then
    local window = Window("text_list", "Select hidden ESSID")
    
    self.window = window
    
    self.window:addWidget(self.menu)
    
    
    
    window:addListener(EVENT_WINDOW_ACTIVE,
      function(event)
        --self.window:hide()
        self:redraw()
        
    end)
    
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

function HiddenEssid:update()
  
  --prevents the situation where where the menu is modified whilst it is being shown,
  -- and hence producing a "different parent" exception
  if self.window != nil and self.menu != nil then
    self.window:removeWidget(self.menu)
  end
  
  -- should proably parse this from main applet as someone may accidently overwrite
  self.settings = self.parent:getSettings()
  self.settings.WirelessHiddenEssid = self.settings.WirelessHiddenEssid or {}
  self.settings.WirelessHiddenEssid.essids = self.settings.WirelessHiddenEssid.essids or {}
  self.settings.WirelessHiddenEssid.selected = self.settings.WirelessHiddenEssid.selected or nil
  self:configureMenu(self.parent)
  
  if self.window != nil and self.menu != nil then
    self.window:addWidget(self.menu)
  end
  
  
end

function HiddenEssid:removeItem(essidData)
  
  if self:getSelected() == essidData then
    -- item selected, so remove
    self:setSelected(nil) 
  end
  
  
  local index
  
  for i,j in pairs(self.settings.WirelessHiddenEssid.essids) do
    
    if j == essidData then
      index = i
    end
    
  end
  
  
  lua_table.remove(self.settings.WirelessHiddenEssid.essids,index)
  self.parent:storeSettings()
  
end


function HiddenEssid:setSelected(value)
  
  self.settings.WirelessHiddenEssid.selected = nil
  
end


function HiddenEssid:getSelected(parent)
  
  self:update()
  return self.settings.WirelessHiddenEssid.selected
  
end


function HiddenEssid:redraw()
  
  --if self.menu != nil then
  --	self.window:removeWidget(self.menu)
  --	self:configureMenu(self.parent)
  --	self.window:addWidget(self.menu)
  --end
  
  if self.menu != nil then
    
    if self.parent != nil then
      self.window:removeWidget(self.menu)
      self:configureMenu(self.parent)
      self.window:addWidget(self.menu)
    end
    
  end
  
end

return HiddenEssid



