
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
local coroutine        = require("coroutine")
local table = require("jive.utils.table")

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
Networking.EncryptionSelect = require("Networking.WirelessEncryptionOptions")
--SettingsManager = require("Networking.SettingsManager")

Networking.WirelessEncryption = require("Networking.WirelessEncryption")

-- including registers the encryption type (or should)
Networking.WPAEncryption = require("Networking.WPAEncryption")
Networking.WPAPreshared = require("Networking.WPAPSKEncryption")
Networking.WPAPeapEncryption = require("Networking.WPAPeapEncryption")
Networking.WPA2PeapEncryption = require("Networking.WPA2PeapEncryption")
Networking.WPA2LeapEncryption = require("Networking.WPA2LeapEncryption")
Networking.WEPPassphrase = require("Networking.WEPPassphraseEncryption")
Networking.WEPSharedEncryption = require("Networking.WEPSharedEncryption")
Networking.WEPHexEncryption = require("Networking.WEPHexEncryption")
Networking.WEPLeapEncryption = require("Networking.WEPLeapEncryption")
Networking.PeapEncryption = require("Networking.PeapEncryption")

local WirelessSetup = oo.class()

function WirelessSetup:__init(parent, bssid, device, callback)
  
  _assert(type(callback) == "function" or type(callback) == "nil", "Invalid callback function")
  
  
  local obj = oo.rawnew(self)
  obj.parent = parent
  obj.bssid = bssid
  obj.device = device
  
  device:setBssid(bssid)

  WirelessSetup.initEncryptionSelect(obj)

    
  return obj
  
end

function WirelessSetup:initEncryptionSelect()

  local function callback()
    self:redraw()
  end
  self.encryptionSelect = Networking.EncryptionSelect(self.parent, callback)
  local currentSelection = self.encryptionSelect:getSelected()
  if currentSelection != nil and currentSelection.real_name != nil then
    self.encType = currentSelection.real_name
  end

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

  -- Wireless Encryption

  optionsList = {}
  options = {}

  title = "Encryption:"
  
  local encryptionSelect = self.encryptionSelect
  local currentSelection = encryptionSelect:getSelected()
  
  if currentSelection != nil and currentSelection.real_name != nil 
        and currentSelection.real_name != "none" then
    options = { currentSelection.human_name }
    self.encType = currentSelection.real_name
  else
    options = {"None"}
    self.encType = nil
  end
  
  local function callbackFunction(choiceObject, selectedIndex)
    encryptionSelect:show()
  end
  
  
  local function statusFunction(self) 
    
    return options[1]
    
  end
  
  Networking.Option(title, options, callbackFunction, statusFunction, optionsList)

  --TODO: convert to utility function

  for i,j in ipairs(optionsList) do
    
    local menuItem = { text = j.title, style = 'item_choice', 
      check =  Choice(
        "choice",  -- style
        j.options,
        j:getCallback(),
        j:getStatusIndex()
        
    )}
        
    menu:addItem(menuItem)
    
  end  


  --end Wireless Encryption
    	
  
  local function connect(device)
    
    -- probably more annoying, reckon manual is best as it gives opporunity to connect again
    --jiveMain:goHome()
    
    local connectingPopup = Networking.ConnectingPopup(self.parent,"","",45)
    local encryption = nil
    self.request_param_count = 0

    local function connectCallback(event, info, success, message)
      
      log:info("class: WirelessSetup, function: connect/ConnectCallback")
      connectingPopup:update(info,message)
      
      if message == "done" then
        connectingPopup:close(success)
        
        if success then
          -- dont need to do anything atm
        else
          -- assume all failures due to password failure, we cannot guarentee 
          -- we will get authentication failed message
          if (encType != "none" and encryption != nil) then
            encryption:reset()
          end
        end
        
      end
      
      
    end     
 
    local function connectRoutine()
        connectingPopup:show()
        connectTask= device:connect(connectCallback)
    end

   
    local function getUserInput(title,set,done, inputRequired)  
            

        
        local done = done
        local set = set
        --FIXME: race condition on checking count?
        local count = self.request_param_count or 0
        count = count + 1
    
        --check on condition count as input requests are shown in reverse order
        -- when back to 1 we have finished
        
        local function callback(value)
            log:info(done)
            log:info(set)
            log:info(count)
            --FIXME: why is value a table and not a string?            
            set(tostring(value))
            count = count -1
            -- if done            
            if (count == 0) then
                connectRoutine()
            end           
        end
        
        if (inputRequired) then        
            getInput(title,callback, "", "qwerty")
        else
            count = count -1
        end        
        
        --case already got credentials / no encryption
        -- if (done and notInputRequired)
        if (done and not inputRequired) then
            log:info("no input required")
            connectRoutine()
        end
        
        log:info(count)
        self.request_param_count = count;        

    end
    

    --check for encryption and get required credentials 

    if (self.encType != nil) then
        encryption = Networking.WirelessEncryption.getEncTypes()[self.encType]
    end

    if (encType != "none" and encryption != nil) then 
        encryption =  encryption.class {device = self:getDevice()}
        --encryption:reset()
        while (encryption:isInputRequired(getUserInput)) do
            -- empty
            log:info("checked one field")
        end
    else
        log:info("connecting with no encryption")
        connectRoutine()    
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
          local callback = self:getCallback()
          callback()
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


