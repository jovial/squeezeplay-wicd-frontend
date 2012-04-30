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

local ipairs, pairs, print, type, setmetatable, table, _G, assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")

local encTypes = {}

local WirelessEncryption = oo.class()

function WirelessEncryption:__init(args)
  _assert(type(args.name) == "string" , "Invalid identifier")
  log:info("Using encryption " .. args.name)
  local obj = oo.rawnew(self)
  obj.name = args.name
  obj.device = args.device  
  obj.settingsManager = SettingsManager("/SetupNetworking/Devices/Wireless/", args.name)
  obj.settings = obj.settingsManager:getSettings()
  obj.lastKey = nil;
  obj.resetFlag = false;
  
  return obj
  
end

-- Determines whether or not it is possible to connect, if not it will request input.
-- 
-- @param getInput(parameter) - function which takes name of requested parmeter as arg.
--                              Called if information is required for encryption type
--                              to authenticate

function WirelessEncryption:isInputRequired(getInput) 
        mapping = self:_getMapping() 
        local key = next(mapping, self.lastKey)
        local done = false
        if (key != nil and next(mapping, key) == nil) then
            done = true
        end        
        if key and mapping[key].data.required then
           
            -- set setting in wireless device
            local function func(raw)
                if mapping[key].data.set then
                    mapping[key].data.set(self,raw)
                else    
                    self.device:setWirelessNetworkProperty(key,raw)
                end
            end
            log:info(done)
            getInput(mapping[key].data.human,func,done,true)
            self.lastKey = key
            if (done) then
                return false
            else
                return true
            end
            
        end
    -- no input required
    getInput(nil,nil,done)
    self.lastKey = key

    if (done) then
        return false
    else
        return true
    end
       
end

-- Restore class to a clean state
function WirelessEncryption:reset()
    self:_resetMapped()
    self.lastKey = nil
    self.resetFlag = true
end


-- returns true if authentication data should be refetched,
-- false otherwise
function WirelessEncryption:isReset() 
    if (self.resetFlag) then
        return true
    end

    return false
end

-- 
function WirelessEncryption:_clearReset() 
    self.resetFlag = false
end

-- Returns a mapping to the the required info for the is encrpytion type.
-- Should be in the form: name -> data -> {required, human, set,reset},
-- where name
-- is the name of the parameter as recognised by wicd, and data is a table  
-- (mapped to "data" in the name table) containing key-value 
-- pairs(detailed below):
--
-- required - should be mapped to true if parameter is required or
-- false if a value is already stored.
-- 
-- set- function which passes data to wicd - takes one argument,
-- the raw user input data 
-- 
-- reset - function - resets the data as stored by wicd

-- human - human readable name
--
-- Should cache data on first call and return this cached data unless 
-- isReset() returns true 
--
-- Should call _clearReset before returning
function WirelessEncryption:_getMapping() 
    assert(false, "Must overide!");
end

-- Should reset the stored authentication settings to a clean state such that
-- getRequiredInfo requests all of necessary information to connect
function WirelessEncryption:_resetMapped()
    for i,j in pairs(self:_getMapping()) do
        if(j.data.reset != nil) then 
            j.data.reset(self)
        else
            self.device:setWirelessNetworkProperty(i,"")
        end
    end
end

-- Returns the device this class is handling the encrpytion for
function WirelessEncryption:getDevice()
    return self.device
end

-- Returns the settings manager
function WirelessEncryption:getSettingsManager()
    return self.settingsManager
end

-- Returns the settings table
function WirelessEncryption:getSettings()
    return self.settings
end

-- Returns a table containg all known enc types
function WirelessEncryption.getEncTypes()
    return encTypes
end

function WirelessEncryption.registerEncType(name, class)
  encTypes[name] = class
end

return WirelessEncryption

