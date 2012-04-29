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

local WirelessEncryption = require("Networking.WirelessEncryption")
local WPAEncryption = oo.class({name ="wpa"},WirelessEncryption)

function WPAEncryption:__init(args)
    args.name = "wpa" 
    super = WirelessEncryption(args)
    local obj = oo.rawnew(self,super)
    local device = obj:getDevice()
    device:setWirelessNetworkProperty("enctype","wpa")
    return obj

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
function WPAEncryption:_getMapping() 
    local wpa = {}   
    if (self.wpa and not self:isReset()) then
        wpa = self.wpa
    else
        wpa.psk= {}
        wpa.psk.data = {}
        wpa.psk.data.human = "WPA passphrase"
        wpa.psk.data.required = self:isPskRequired()
        wpa.psk.data.set = WPAEncryption.setPSK
        wpa.psk.data.reset = WPAEncryption.resetPSK
    end    

    self:_clearReset()
    self.wpa = wpa
    return wpa
end

function WPAEncryption:setPSK(value)
    local device = self:getDevice()
    log:info("setting psk :")
    log:info(value)   
    device:setWirelessNetworkProperty("key",value)
end

function WPAEncryption:resetPSK()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("psk","")
end

function WPAEncryption:isPskRequired()
    local device = self:getDevice()
    local psk = device:getWirelessNetworkProperty("psk")
    -- case : already have psk
    if (psk != nil and psk != "") then
        return false
    end
    --default : request Key
    return true
end

WirelessEncryption.registerEncType("wpa",{class=WPAEncryption, human_name="WPA Passphrase" })

return WPAEncryption

