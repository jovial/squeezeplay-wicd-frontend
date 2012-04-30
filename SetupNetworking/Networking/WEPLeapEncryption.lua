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

-- for /etc/wicd/encryption/templates/leap

local ipairs, pairs, print, type, setmetatable, table, _G, assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")



local WirelessEncryption = require("Networking.WirelessEncryption")
local WEPLeapEncryption = oo.class({},WirelessEncryption)

WEPLeapEncryption.HUMAN_NAME = "WEP leap"
WEPLeapEncryption.WICD_NAME = "leap"

function WEPLeapEncryption:__init(args)
    args.name = WEPLeapEncryption.WICD_NAME
    super = WirelessEncryption(args)
    local obj = oo.rawnew(self,super)
    local device = obj:getDevice()
    device:setWirelessNetworkProperty("enctype",WEPLeapEncryption.WICD_NAME)
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
function WEPLeapEncryption:_getMapping() 
    local wep = {}   
    if (self.wep and not self:isReset()) then
        wep = self.wep
    else
        wep.username= {}
        wep.username.data = {}
        wep.username.data.human = "Username"
        wep.username.data.required = self:isUsernameRequired()
        wep.username.data.set = WEPLeapEncryption.setUsername
        wep.username.data.reset = WEPLeapEncryption.resetUsername
        
        wep.password= {}
        wep.password.data = {}
        wep.password.data.human = "Password"
        wep.password.data.required = self:isPasswordRequired()
        wep.password.data.set = WEPLeapEncryption.setPassword
        wep.password.data.reset = WEPLeapEncryption.resetPassword
               
        
    end    

    self:_clearReset()
    self.wep = wep
    return wep
end

function WEPLeapEncryption:setUsername(value)
    local device = self:getDevice()
    log:info("setting username :")
    log:info(value)   
    device:setWirelessNetworkProperty("username",value)
end

function WEPLeapEncryption:resetUsername()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("username","")
end

function WEPLeapEncryption:isUsernameRequired()
    local device = self:getDevice()
    local username = device:getWirelessNetworkProperty("username")
    -- case : already have username
    if (username != nil and username != "") then
        return false
    end
    --default : request Key
    return true
end

function WEPLeapEncryption:setPassword(value)
    local device = self:getDevice()
    log:info("setting password :")
    log:info(value)   
    device:setWirelessNetworkProperty("password",value)
end

function WEPLeapEncryption:resetPassword()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("password","")
end

function WEPLeapEncryption:isPasswordRequired()
    local device = self:getDevice()
    local password = device:getWirelessNetworkProperty("password")
    -- case : already have password
    if (password != nil and password != "") then
        return false
    end
    --default : request Key
    return true
end


WirelessEncryption.registerEncType(WEPLeapEncryption.WICD_NAME,{class=WEPLeapEncryption, human_name=WEPLeapEncryption.HUMAN_NAME })

return WEPLeapEncryption

