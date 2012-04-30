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

-- for /etc/wicd/encryption/templates/peap

local ipairs, pairs, print, type, setmetatable, table, _G, assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")



local WirelessEncryption = require("Networking.WirelessEncryption")
local PeapEncryption = oo.class({},WirelessEncryption)

PeapEncryption.HUMAN_NAME = "WPA PEAP with GTC"
PeapEncryption.WICD_NAME = "peap"

function PeapEncryption:__init(args)
    args.name = PeapEncryption.WICD_NAME
    super = WirelessEncryption(args)
    local obj = oo.rawnew(self,super)
    local device = obj:getDevice()
    device:setWirelessNetworkProperty("enctype",PeapEncryption.WICD_NAME)
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
function PeapEncryption:_getMapping() 
    local wpa = {}   
    if (self.wpa and not self:isReset()) then
        wpa = self.wpa
    else
        wpa.username= {}
        wpa.username.data = {}
        wpa.username.data.human = "Username"
        wpa.username.data.required = self:isUsernameRequired()
        wpa.username.data.set = PeapEncryption.setUsername
        wpa.username.data.reset = PeapEncryption.resetUsername
        
        wpa.password= {}
        wpa.password.data = {}
        wpa.password.data.human = "Password"
        wpa.password.data.required = self:isPasswordRequired()
        wpa.password.data.set = PeapEncryption.setPassword
        wpa.password.data.reset = PeapEncryption.resetPassword
              
        
    end    

    self:_clearReset()
    self.wpa = wpa
    return wpa
end

function PeapEncryption:setUsername(value)
    local device = self:getDevice()
    log:info("setting username :")
    log:info(value)   
    device:setWirelessNetworkProperty("identity",value)
end

function PeapEncryption:resetUsername()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("identity","")
end

function PeapEncryption:isUsernameRequired()
    local device = self:getDevice()
    local username = device:getWirelessNetworkProperty("identity")
    -- case : already have username
    if (username != nil and username != "") then
        return false
    end
    --default : request Key
    return true
end

function PeapEncryption:setPassword(value)
    local device = self:getDevice()
    log:info("setting password :")
    log:info(value)   
    device:setWirelessNetworkProperty("password",value)
end

function PeapEncryption:resetPassword()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("password","")
end

function PeapEncryption:isPasswordRequired()
    local device = self:getDevice()
    local password = device:getWirelessNetworkProperty("password")
    -- case : already have password
    if (password != nil and password != "") then
        return false
    end
    --default : request Key
    return true
end



WirelessEncryption.registerEncType(PeapEncryption.WICD_NAME,{class=PeapEncryption, human_name=PeapEncryption.HUMAN_NAME })

return PeapEncryption

