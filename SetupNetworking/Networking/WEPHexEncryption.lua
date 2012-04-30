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

-- for /etc/wicd/encryption/templates/wep-hex

local ipairs, pairs, print, type, setmetatable, table, _G, assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")


local WirelessEncryption = require("Networking.WirelessEncryption")
local WEPHex = oo.class({},WirelessEncryption)

WEPHex.HUMAN_NAME = "WEP hex"
WEPHex.WICD_NAME = "wep-hex"

function WEPHex:__init(args)
    args.name = WEPHex.WICD_NAME
    super = WirelessEncryption(args)
    local obj = oo.rawnew(self,super)
    local device = obj:getDevice()
    device:setWirelessNetworkProperty("enctype",WEPHex.WICD_NAME)
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
function WEPHex:_getMapping() 
    local enc = {}   
    if (self.enc and not self:isReset()) then
        enc = self.enc
    else
        enc.key= {}
        enc.key.data = {}
        enc.key.data.human = WEPHex.HUMAN_NAME
        enc.key.data.required = self:isKeyRequired()
        enc.key.data.set = WEPHex.setKey
        enc.key.data.reset = WEPHex.resetKey
    end    

    self:_clearReset()
    self.enc = enc
    return enc
end

function WEPHex:setKey(value)
    local device = self:getDevice()
    log:info("setting key :")
    log:info(value)   
    device:setWirelessNetworkProperty("key",value)
end

function WEPHex:resetKey()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("key","")
end

function WEPHex:isKeyRequired()
    local device = self:getDevice()
    local key = device:getWirelessNetworkProperty("key")
    -- case : already have key
    if (key != nil and key != "") then
        return false
    end
    --default : request Key
    return true
end

WirelessEncryption.registerEncType(WEPHex.WICD_NAME,{class=WEPHex, human_name=WEPHex.HUMAN_NAME })

return WEPHex

