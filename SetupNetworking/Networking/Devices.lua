
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


local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable, require, pcall = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable, require, pcall

local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")
local Task		= require("jive.ui.Task")
local Framework		= require("jive.ui.Framework")
local Event		= require("jive.ui.Event")
local coroutine        = require("coroutine")
local Timer         = require("jive.ui.Timer")

local EVENT_UPDATE  = jive.ui.EVENT_UPDATE
local EVENT_KEY_BACK = jive.ui.EVENT_KEY_BACK


wicd = wicd or {}
wicd.daemon = require("wicdbridge_daemon")
wicd.daemon.wireless = require("wicdbridge_wireless")
wicd.daemon.wired = require("wicdbridge_wired")

SettingsManager = require("Networking.SettingsManager")

function init()
  
  squeezeplayProfileExists = false
  
  for i,j in pairs(wicd.daemon.wired.GetWiredProfileList()) do
    
    if j=="squeezeplay" then
      squeezeplayProfileExists = true
    end
    
    
  end
  
  if not squeezeplayProfileExists then
    
    wicd.daemon.wired.SaveWiredNetworkProfile("squeezeplay")
    
  end
  
  wicd.daemon.wired.ReadWiredNetworkProfile("squeezeplay")
  
  
  
end


-- init wired profile
init()



-- devices "class"
local Devices = {}

function Devices:new(deviceID)
  local device = {}
  
  
  
  -- make a list of each subclass - do not look up list in metatable!
  if deviceID != nil then
    
    metatableBak = getmetatable(self)
    setmetatable(self, nil)
    
    
  end
  
  self.list = self.list or {}
  
  -- restore metatable
  
  if deviceID != nil then
    --self.__index = indexBak;
    setmetatable(self, metatableBak)
  end
  
  setmetatable(device, self)
  self.__index = self
  device.deviceID = deviceID
  -- static list of all devices
  if deviceID != nil then
    --self.list[deviceID] = device
    -- prefer to be ordered as added
    -- maybe make comparator to sort alphabetically
    -- if want to use strings as keys
    lua_table.insert(self.list, device)
  end
  --print(self.list["deviceID"].deviceID)
  return device
end

-- static method -- device type checking is not enforced, use with care.
function Devices:setSelected(device)
  -- were we sent a genuine device ?
  _assert(device.deviceID != nil)
  -- assert static call
  _assert(self.deviceID == nil)
  self.selected = device
  -- dbus call here to update
  
end

function Devices:getSelected()
  
  return self.selected
  
end

-- generic networking subclass for common routines

Devices.Networking = Devices:new()

-- TODO: migrate wired and wireless to new common subclass, networking

-- wired subclass

Devices.Wired = Devices.Networking:new()

-- wireless subclass
Devices.Wireless = Devices.Networking:new()

function Devices.Wired:setSelected(device)
  
  local oldDevice = Devices.Wired:getSelected()
  local switchSucessful = false
  
  if device != nil then
    -- do some dbus calls then call overrided method
    
    wicd.daemon.SetWiredInterface(device.deviceID)
    wicd.daemon.wired.EnableWiredInterface()
    if device.deviceID == wicd.daemon.wired.DetectWiredInterface() and wicd.daemon.wired.IsWiredUp() then
      getmetatable(self).setSelected(self,device)
      switchSucessful = true
    end
  else -- assume called on device
    wicd.daemon.SetWiredInterface(self.deviceID)
    if self.deviceID == wicd.daemon.wired.DetectWiredInterface() and wicd.daemon.wired.IsWiredUp() then
      getmetatable(self):setSelected(self)
      switchSucessful = true
    end
    
    if not switchSucessful then
      if oldDevice !=nil then
        wicd.daemon.SetWiredInterface(oldDevice.deviceID)
        wicd.daemon.wired.EnableWiredInterface()
        if oldDevice.deviceID == wicd.daemon.wired.DetectWiredInterface() then
          Devices.Wired:setSelected(oldDevice)
          log:warn("Unable to switch network device, reverting back to: " .. oldDevice.deviceID)
        else
          Devices.Wired.selected = nil -- should probably set this through the set method
          log:warn("Unable to switch network device. Could not revert back to original")
        end
      else
        Devices.Wired.selected = nil
        log:warn("Unable to switch network device. No wired devices currently selected")
      end
    end
  end
  
end

function Devices.Wireless:new(deviceID)  
  local currentDevice = getmetatable(self).new(self,deviceID,settingsManager)
  if deviceID == wicd.daemon.wireless.DetectWirelessInterface() and wicd.daemon.wireless.IsWirelessUp() then
    
    self.selected = currentDevice
    log:info("selected wireless device: " ..self.selected.deviceID)
  end
  
  
  currentDevice.settingsManager = SettingsManager("/SetupNetworking/Devices/Wireless/", deviceID)
  currentDevice.settings = currentDevice.settingsManager:getSettings()
  currentDevice.settingsManager:storeSettings()
  
  return currentDevice
  
end

function Devices.Wired:new(deviceID,settingsManager) 
  
  local currentDevice = getmetatable(self).new(self,deviceID,settingsManager)
  -- remember to change IsWiredUp to function call after testing
  if deviceID == wicd.daemon.wired.DetectWiredInterface() and wicd.daemon.wired.IsWiredUp() then
    self.selected = currentDevice
    
    
  end
  
  currentDevice.settingsManager = SettingsManager("/SetupNetworking/Devices/Wired/", deviceID)
  currentDevice.settings = currentDevice.settingsManager:getSettings()
  currentDevice:initManualSettings()
  currentDevice.settingsManager:storeSettings()
  
  
  
  return currentDevice
  
end

function Devices.Wireless:setSelected(device)
  
  local oldDevice = Devices.Wireless:getSelected()
  local switchSucessful = false
  
  
  if device != nil then
    -- do some dbus calls then call overrided method
    wicd.daemon.SetWirelessInterface(device.deviceID)
    wicd.daemon.wireless.EnableWirelessInterface()
    if device.deviceID == wicd.daemon.wireless.DetectWirelessInterface() and wicd.daemon.wireless.IsWirelessUp() then
      getmetatable(self).setSelected(self,device)
      switchSucessful = true
    end
    --getmetatable(self):setSelected(device)
  else -- assume called on device
    wicd.daemon.SetWirelessInterface(self.deviceID)
    wicd.daemon.wireless.EnableWirelessInterface()
    if self.deviceID == wicd.daemon.wireless.DetectWirelessInterface() and wicd.daemon.wireless.IsWirelessUp() then
      getmetatable(self):setSelected(self)
      switchSucessful = true
    end
    
    if not switchSucessful then
      if oldDevice != nil then
        wicd.daemon.SetWirelessInterface(oldDevice.deviceID)
        wicd.daemon.wireless.EnableWirelessInterface()
        if oldDevice.deviceID == wicd.daemon.wireless.DetectWirelessInterface() then
          Devices.Wireless:setSelected(oldDevice)
          log:warn("Unable to switch network device, reverting back to: " .. oldDevice.deviceID)
        else
          Devices.Wireless.selected = nil -- should probably set this through the set method
          log:warn("Unable to switch network device. Could not revert back to original")
        end
      else
        Devices.Wireless.selected = nil
        log:warn("Unable to switch network device. No wireless devices currently selected")
      end
    end
  end
  
end

function Devices.Wired:populate()
  
  -- reset DeviceList and repopulate
    
  Devices.Wired.list = {}
  local deviceList = {}
 
  -- python throws exception when trying to marshall empty list as string array as it cannot detect
  -- the type
  if pcall(function() deviceList = wicd.daemon.wired.GetWiredInterfaces() end) then
    -- do nothing
  else
    deviceList = {}
  end
  
  for i,j in pairs(deviceList) do
    
    Devices.Wired:new(j)
    
  end
  
  -- dummy wired
  --Devices.Wired:new("eth1")
  
end

function Devices.Wired.disable()
  
  wicd.daemon.wired.DisableWiredInterface()
  Devices.Wired.selected = nil
  
end


function Devices.Wireless.disable()
  
  wicd.daemon.wireless.DisableWirelessInterface()
  Devices.Wireless.selected = nil
  
end

function Devices.Wireless:populate()

  log:debug("entering Devices.Wireless:populate")
  
  Devices.Wireless.list = {}
  
  local deviceList
  
  -- python throws exception when trying to marshall empty list as string array as it cannot detect
  -- the type
  if pcall(function() deviceList = wicd.daemon.wireless.GetWirelessInterfaces() end) then
    -- do nothing
  else
    deviceList = {}
  end

  log:debug("retrieved wireless interfaces")
  
  for i,j in pairs(deviceList) do
    
    Devices.Wireless:new(j)
    
  end
  
  -- dummy wireless
  --Devices.Wireless:new("wlan1")
  
end

function Devices.Wired:connect(callback)
  
  
  local connect = wicd.daemon.wired.ConnectWired
  local message = wicd.daemon.wired.CheckWiredConnectingMessage
  local check = wicd.daemon.wired.CheckIfWiredConnecting
  local info = "Connecting wired interface: " .. self.deviceID
  
  
  local connectTask = Task("Wired Connect", self, function() getmetatable(self):connectRoutine(callback,info,connect,check, message) end)
  
  local timer = Timer(100, function()connectTask:addTask() end, true)
  timer:start()
  
end

-- return true if key required, else false

function Devices.Wireless:connect(callback, validate)
  
  local function connectWrapper()
    
    wicd.daemon.wireless.ConnectWireless(self:getNetworkID(self:getBssid()))
    
  end
  
  local connect = connectWrapper
  local message = wicd.daemon.wireless.CheckWirelessConnectingMessage
  local check = wicd.daemon.wireless.CheckIfWirelessConnecting
  
  
  local info = "Connecting wireless interface: " .. self.deviceID
  
  local connectTask = Task("Wireless Connect", self, function() getmetatable(self):connectRoutine(callback,info,connect,check, message) end)
  
  
  local timer = Timer(100, function()connectTask:addTask() end, true)
  
  
  -- if device is currently unselected, select it now so that we connect using the correct interface
  
  getmetatable(self):setSelected(self)
  
  timer:start()
  
  
  return connectTask
  
end

-- connect - function to connect the interface
-- check - checks if interface up
-- message - gets the connecting message / return false if not connecting
-- info - message to explain what we are doing, passed back to callback function to display info etc


function Devices.Networking:connectRoutine(callback, info, connect, check, message)
  Task:yield()
  
  _assert(type(callback) == "function", "Invalid function as callback")
  _assert(type(info) == "string", "Invalid string as info message")
  _assert(type(connect) == "function", "Invalid function as target")
  _assert(type(check) == "function", "Invalid function as check")
  _assert(type(message) == "function", "Invalid function as message")
  
  local success = false;
  
  local lastMessage = ""
  
  
  --FIXME: nonsensical event
  
  local keyCode = jive.ui.KEY_NONE
  
  --send messages to callback function to report status
  
  local event = Event:new(jive.ui.EVENT_KEY_UP,keyCode)
  
  -- global event listener so we can avoid messing up the ui using a keypress event
  -- surely nothing will generate a EVENT_KEY_UP with keycode= KEY_NONE ?!
  
  -- consume the event to stop it messing with generic key_up listeners,
  -- may have to change if this isnt the case
  
  Framework:addListener(jive.ui.EVENT_KEY_UP, function(event) 
      if event:getKeycode() == keyCode then
        callback(event, info, success, lastMessage)	
        return jive.ui.EVENT_CONSUME
      end
      -- else let the event pass
  end, -1)
  
  Task:yield()
  
  connect()
  
  Task:yield()
  
  while check() do
    --Framework:dispatchEvent(widget, event)
    local nextMessage = message()
    if nextMessage != lastMessage then
      lastMessage = nextMessage
      if nextMessage == "done" then
        break
      end
      Framework:dispatchEvent(nil, event)
      Task:yield()
    end
    
    
  end
  
  local function getConnectionStatus()
    local status, connectInfo
    
    status, connectInfo = wicd.daemon.GetConnectionStatus()
    
    --maybe check wired/wireless 
    --print(status)
    if (status != 0) and (status !=1) then
      success = true
    end
    
    lastMessage = "done"
    
    Framework:dispatchEvent(nil, event)
  end
  
  local timer = Timer(5000, function()getConnectionStatus() end, true)
  timer:start()
  
  --group.connectTask:removeTask()
  
end

function Devices.Wireless:getNetworkList(rescan, maxRetries, hiddenEssid)
  
  
  if rescan then
    
    if hiddenEssid != nil then
      if type(hiddenEssid) == "string" then
        wicd.daemon.wireless.SetHiddenNetworkESSID(hiddenEssid)
        log:info("Using hiddenEssid:" .. hiddenEssid)
      else
        log:warn("Ignoring hiddenEssid: not a string value.")
      end
    end
    
    self.scanResults = {}
    
    -- max retries not set? then default to 1
    
    maxRetries = maxRetries or 1
    
    for count = 0,maxRetries,1 do
      if wicd.daemon.wireless.Scan(true) == true then
        break
      end
    end
    
    local numberOfNetworks = wicd.daemon.wireless.GetNumberOfNetworks()
    -- if it doesn't return then return cached data
    if (type(numberOfNetworks) != "function") then
      for networkId = 0, numberOfNetworks -1 do	
        local details = {}
        details.networkID = networkId
        details.quality = wicd.daemon.wireless.GetWirelessProperty(networkId, "quality")
        details.bssid = wicd.daemon.wireless.GetWirelessProperty(networkId, "bssid")
        details.channel = wicd.daemon.wireless.GetWirelessProperty(networkId, "channel")
        details.essid = wicd.daemon.wireless.GetWirelessProperty(networkId, "essid")
        details.mode = wicd.daemon.wireless.GetWirelessProperty(networkId, "mode")
        details.bitrates = wicd.daemon.wireless.GetWirelessProperty(networkId, "bitrates")
        details.encryption = wicd.daemon.wireless.GetWirelessProperty(networkId, "encryption")
        
        if (details.encryption) then
          details.encryptionType = wicd.daemon.wireless.GetWirelessProperty(networkId, "enctype")
        end
        lua_table.insert(self.scanResults,details)
      end
    end
  end
  
  return self.scanResults or {}
  
end

function Devices.Wireless:getWirelessProperty(bssid,property)
  
  if self.scanResults == nil then
    self.getNetworkList(true,1)
  end
  
  local networkID = nil
  
  for i,network in pairs(self.scanResults) do
    if network.bssid == bssid then
      networkID = network.networkID
    end
  end
  
  if networkID == nil then
    return
  end
  
  return wicd.daemon.wireless.GetWirelessProperty(networkID,property)
  
end

function Devices.Wireless:getNetworkID(bssid)
  
  if self.scanResults == nil then
    self.getNetworkList(true,1)
  end
  
  local networkID = nil
  
  for i,network in pairs(self.scanResults) do
    if network.bssid == bssid then
      networkID = network.networkID
    end
  end
  
  if networkID == nil then
    return nil
  end
  
  return networkID
  
end

function Devices.Wireless:setWirelessProperty(bssid,property,value)
  
  local networkID = self:getNetworkID(bssid)
  log:info(networkID)
  if (networkID == nil) then
    return
  end
  log:info(property)
  log:info(value)
  wicd.daemon.wireless.SetWirelessProperty(networkID,property,value)
  wicd.daemon.wireless.SaveWirelessNetworkProfile(networkID)
  
end

function Devices.Wireless:setBssid(bssid)
  self.bssid = bssid
  self.settings[bssid] = self.settings[bssid]  or {}
  -- make manualSettings tree 
  self:initManualSettings(bssid)
  
  self.settingsManager:storeSettings()
end

function Devices.Wireless:getBssid()
  return self.bssid
end

function Devices.Wireless:isDHCP(bssid)
  
  ip = self:getWirelessProperty(self:getBssid(),"ip")
  
  if type(ip) == "string" then
    
    return false
    
  end
  
  -- work around as dbus calls do not work when back is pressed
  if self.dhcp != nil then
    return self.dhcp
  else
    return true
  end
  
end

function Devices.Wired:isDHCP()
  
  ip = wicd.daemon.wired.GetWiredProperty("ip")
  
  if type(ip) == "string" then
    
    return false
    
  end
  
  -- work around as dbus calls do not work when back is pressed
  if self.dhcp != nil then
    return self.dhcp
  else
    return true
  end
  
end

--[[
function Devices.Wireless:setIP(ip)

self:setWirelessProperty(self:getBssid(),"ip",ip)

log:info("Set wireless ip: " .. ip)

end


function Devices.Wired:setIP(ip)

wicd.daemon.wired.SetWirelessProperty("ip",ip)

log:info("Set Wired ip: " .. ip)

end

]]--

function Devices.Wireless:setManual()
  
  local settings = self.settings[self:getBssid()].manualAddressSettings
  
  if settings == nil then
    settings = {}
    settings.ip = "-"
    settings.dns1 = "-"
    settings.dns2 = "-"
    settings.dns3 = "-"
    settings.netmask = "-"
    settings.gateway = "-"
    self.settings[self:getBssid()].manualAddressSettings = settings
    self.settingsManager:storeSettings()
  end
  
  self:updateSettings()
  
  self.dhcp=false
  
end


function Devices.Wired:setManual()
  
  local settings = self.settings.manualAddressSettings
  
  if settings == nil then
    settings = {}
    settings.ip = "-"
    settings.dns1 = "-"
    settings.dns2 = "-"
    settings.dns3 = "-"
    settings.netmask = "-"
    settings.gateway = "-"
    self.settings.manualAddressSettings = settings
    self.settingsManager:storeSettings()
  end
  
  self:updateSettings()
  
  self.dhcp=false
  
end

function Devices.Wireless:setDHCP()
  
  
  settings = {}
  settings.ip = ""
  settings.dns1 = ""
  settings.dns2 = ""
  settings.dns3 = ""
  settings.netmask = ""
  settings.gateway = ""
  
  
  for i,j in pairs(settings) do
    
    log:info("changing setting dhcp: wireless")
    
    self:setWirelessProperty(self:getBssid(),i,j)
    
  end
  
  self.dhcp=true
  
end

function Devices.Wired:setDHCP()
  
  
  settings = {}
  settings.ip = ""
  settings.dns1 = ""
  settings.dns2 = ""
  settings.dns3 = ""
  settings.netmask = ""
  settings.gateway = ""
  
  
  for i,j in pairs(settings) do
    
    self:setWiredProperty(i,j)
    
  end
  
  
  self.dhcp=true
  
end

function Devices.Wired:initManualSettings()
    self.settings.manualAddressSettings = self.settings.manualAddressSettings or {}
end

function Devices.Wireless:initManualSettings(bssid)
    self.settings[bssid].manualAddressSettings = self.settings[bssid].manualAddressSettings or {}
end

function Devices.Wired:getManualSettings()
  
  return self.settings.manualAddressSettings
  
end

function Devices.Wireless:getManualSettings()
  
  return self.settings[self:getBssid()].manualAddressSettings
  
end

function Devices.Networking:validateManualSetting(ip)
  
  -- use dashes as placeholders
  
  if ip == "" then
    ip = "-"
  end
  
  return ip
  
end

function Devices.Networking:getIP()
  
  local settings = self:getManualSettings()
  
  if settings == nil then 
    return nil
  end
  
  log:debug("Devices.Networking:getIP returns: ", settings.ip or "nil")
  return settings.ip
  
end

function Devices.Networking:setIP(ip)
  ip = self:validateManualSetting(ip)
  local settings = self:getManualSettings()
  settings.ip = ip
  self:updateSettings()
  self.settingsManager:storeSettings()
  
end

function Devices.Networking:getGateway()
  local settings = self:getManualSettings()
  if settings == nil then 
    return nil
  end
  log:debug("Devices.Networking:getGateway returns: ", settings.gateway or "nil")
  return settings.gateway
end

function Devices.Networking:setGateway(gateway)
  gateway = self:validateManualSetting(gateway)
  local settings = self:getManualSettings()
  settings.gateway = gateway
  self:updateSettings()
  self.settingsManager:storeSettings()
end

function Devices.Networking:getDNS1()
  local settings = self:getManualSettings()
  if settings == nil then 
    return nil
  end
  log:debug("Devices.Networking:getDNS1 returns: ", settings.dns1 or "nil")
  return settings.dns1
end

function Devices.Networking:setDNS1(dns1)
  dns1 = self:validateManualSetting(dns1)
  local settings = self:getManualSettings()
  settings.dns1 = dns1
  self:updateSettings()
  self.settingsManager:storeSettings()
end

function Devices.Networking:getDNS2()
  local settings = self:getManualSettings()
  if settings == nil then 
    return nil
  end
  log:debug("Devices.Networking:getDNS2 returns: ", settings.dns2 or "nil")
  return settings.dns2
end

function Devices.Networking:setDNS2(dns2)
  dns2 = self:validateManualSetting(dns2)
  local settings = self:getManualSettings()
  settings.dns2 = dns2
  self:updateSettings()
  self.settingsManager:storeSettings()
end

function Devices.Networking:getDNS3()
  local settings = self:getManualSettings()
  if settings == nil then 
    return nil
  end
  log:debug("Devices.Networking:getDNS1 returns: ", settings.dns3 or "nil")
  return settings.dns3
end

function Devices.Networking:setDNS3(dns3)
  dns3 = self:validateManualSetting(dns3)
  local settings = self:getManualSettings()
  settings.dns3 = dns3
  self:updateSettings()
  self.settingsManager:storeSettings()
end

function Devices.Networking:getNetmask()
  local settings = self:getManualSettings()
  if settings == nil then 
    return nil
  end
  log:debug("Devices.Networking:getNetmask returns: ", settings.netmask or "nil")
  return settings.netmask
end

function Devices.Networking:setNetmask(netmask)
  netmask = self:validateManualSetting(netmask)
  local settings = self:getManualSettings()
  settings.netmask = netmask
  self:updateSettings()
  self.settingsManager:storeSettings()
end

function Devices.Wireless:getEncType()
  
  return self:getWirelessProperty(self:getBssid(),"encryption_method") or "Unknown encryption"
  
end

function Devices.Wireless:setEncKey(value)
  
  self:setWirelessProperty(self:getBssid(),"key",value)
  
end

function Devices.Wireless:getEncKey()
  -- wont work after connection, as key is deleted.
  return self:getWirelessProperty(self:getBssid(),"key")
  
end

function Devices.Wireless:setPsk(psk)
  
  self:setWirelessProperty(self:getBssid(),"psk",psk)
  
end

function Devices.Wireless:getPsk(psk)
  
  return self:getWirelessProperty(self:getBssid(),"psk")
  
end

function Devices.Wireless:setWirelessNetworkProperty(property, value)
  --log:info("setting Wireless property: " .. property .. " -> " .. value)
  log:info(property)
  log:info(value)
  log:info(self:getBssid())
  self:setWirelessProperty(self:getBssid(), property, value)
  
end

function Devices.Wireless:getWirelessNetworkProperty(property)
    return self:getWirelessProperty(self:getBssid(), property)
end

function Devices.Wireless.isEncrypted() 
    local encrypted = self:getWirelessProperty(self:getBssid(),"encryption")
    if (encrypted) then
        return true

    else
        return false
    end
        

end


function Devices.Wireless:storeEncKey()
  local key = self:getPsk()
  log:info("Storing key: ", key)
  self:getManualSettings().psk = key
  self.settingsManager:storeSettings()
  
end

function Devices.Wireless:removeEncKey()
  
  local count =1
  local index = nil 
  local settings = self:getManualSettings()
  
  for i,j in pairs(settings) do
    
    if i == "psk" then
      index = count
      break
    end
    count = count + 1
  end
  
  if index != nil then
    log:info("removing stored psk key at index", index)
    settings.psk =nil
    self.settingsManager:storeSettings()
    
  end
  
  
  
end

function Devices.Wired:setWiredProperty(property,value)
  
  wicd.daemon.wired.SetWiredProperty(property,value)
  self:saveSettings()
  
end

function Devices.Wired:saveSettings()
  
  wicd.daemon.wired.SaveWiredNetworkProfile("squeezeplay")
  
end


function Devices.Wired:makeDefault()
  
  wicd.daemon.wired.UnsetWiredDefault()
  self:setWiredProperty("default","True")
  wicd.daemon.SetPreferWiredNetwork(true)
  
end

function Devices.Wired:updateSettings()
  
  local settings = self:getManualSettings()
  
  for i,j in pairs(settings) do
    
    -- do not add place holders in case the case issues
    -- ie dns servers which do not respond
    
    if (i != ip) and (j=="-") then
      self:setWiredProperty(i,"")
    else
      self:setWiredProperty(i,j)
    end
    
  end
  
  
end

function Devices.Wireless:updateSettings()

  local settings = self:getManualSettings()	
  
  for i,j in pairs(settings) do
    
    -- do not add place holders in case the case issues
    -- ie dns servers which do not respond
    log:info("changing setting manual : wireless")
    
    if (i != ip) and (j=="-") then
      self:setWirelessProperty(self:getBssid(),i,"")
      log:info("ignoring placeholder : wireless")
    else
      
      self:setWirelessProperty(self:getBssid(),i,j)
    end
  end
  
  
end

--static method
-- deadPeriod allows you to time a specified period, 
-- the status of which is reported via callback (true or false)
function Devices.Networking:autoConnect(callback, deadPeriod)
  
  local connectTask = Task("Wired Connect", self, function() self:autoConnectRoutine(callback,deadPeriod) end)
  
  connectTask:addTask()
  
  -- return task
  return connectTask
  
end

function Devices.Networking:autoConnectRoutine(callback, deadPeriod)
  
  local status, connectInfo, deadZone = true
  
  local timer = Timer(deadPeriod, function() deadZone=false end, true)
  timer:start()
  
  
  wicd.daemon.AutoConnect(true)
  
  ----------------
  
  -- run until manually stopped	
  while true do
    status, info = wicd.daemon.GetConnectionStatus()
    callback(event, status, info, deadZone)	
    -- stop hogging cpu
    Task:yield()
  end
  
  
  
end


function Devices.Networking:getConnectionStatus()
  return wicd.daemon.GetConnectionStatus()
  
end

return Devices


