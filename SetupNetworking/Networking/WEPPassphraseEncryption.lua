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
local WEPPassphrase = oo.class({},WirelessEncryption)

WEPPassphrase.HUMAN_NAME = "WEP passphrase"
WEPPassphrase.WICD_NAME = "wep-passphrase"

function WEPPassphrase:__init(args)
    args.name = WEPPassphrase.WICD_NAME
    super = WirelessEncryption(args)
    local obj = oo.rawnew(self,super)
    local device = obj:getDevice()
    device:setWirelessNetworkProperty("enctype",WEPPassphrase.WICD_NAME)
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
function WEPPassphrase:_getMapping() 
    local wep = {}   
    if (self.wep and not self:isReset()) then
        wep = self.wep
    else
        log:info("generating mapping")
        wep.passphrase= {}
        wep.passphrase.data = {}
        wep.passphrase.data.human = WEPPassphrase.HUMAN_NAME
        wep.passphrase.data.required = self:isPassphraseRequired()
        wep.passphrase.data.set = WEPPassphrase.setPassphrase
        wep.passphrase.data.reset = WEPPassphrase.resetPassphrase
    end    

    self:_clearReset()
    self.wep = wep
    return wep
end

function WEPPassphrase:setPassphrase(value)
    local device = self:getDevice()  
    device:setWirelessNetworkProperty("passphrase",value)
end

function WEPPassphrase:resetPassphrase()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("passphrase","")
end

function WEPPassphrase:isPassphraseRequired()
    local device = self:getDevice()
    local pass = device:getWirelessNetworkProperty("passphrase")
    -- case : already have passphrase
    if (pass != nil and pass != "") then
        return false
    end
    log:info("passphrase required")
    --default : request Key
    return true
end

WirelessEncryption.registerEncType(WEPPassphrase.WICD_NAME,
        {class=WEPPassphrase, human_name=WEPPassphrase.HUMAN_NAME })

return WEPPassphrase

