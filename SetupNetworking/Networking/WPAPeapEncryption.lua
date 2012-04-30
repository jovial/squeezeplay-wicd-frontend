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

-- for /etc/wicd/encryption/templates/wpa-peap

local ipairs, pairs, print, type, setmetatable, table, _G, assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local log		= require("jive.utils.log").logger("squeezeplay.applets.SetupNetworking")



local WirelessEncryption = require("Networking.WirelessEncryption")
local WPAPeapEncryption = oo.class({},WirelessEncryption)

WPAPeapEncryption.HUMAN_NAME = "WPA peap"
WPAPeapEncryption.WICD_NAME = "wpa-peap"

function WPAPeapEncryption:__init(args)
    args.name = WPAPeapEncryption.WICD_NAME
    super = WirelessEncryption(args)
    local obj = oo.rawnew(self,super)
    local device = obj:getDevice()
    device:setWirelessNetworkProperty("enctype",WPAPeapEncryption.WICD_NAME)
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
function WPAPeapEncryption:_getMapping() 
    local wpa = {}   
    if (self.wpa and not self:isReset()) then
        wpa = self.wpa
    else
        wpa.username= {}
        wpa.username.data = {}
        wpa.username.data.human = "Username"
        wpa.username.data.required = self:isUsernameRequired()
        wpa.username.data.set = WPAPeapEncryption.setUsername
        wpa.username.data.reset = WPAPeapEncryption.resetUsername
        
        wpa.password= {}
        wpa.password.data = {}
        wpa.password.data.human = "Password"
        wpa.password.data.required = self:isPasswordRequired()
        wpa.password.data.set = WPAPeapEncryption.setPassword
        wpa.password.data.reset = WPAPeapEncryption.resetPassword
        
        wpa.domain= {}
        wpa.domain.data = {}
        wpa.domain.data.human = "Domain"
        wpa.domain.data.required = self:isDomainRequired()
        wpa.domain.data.set = WPAPeapEncryption.setDomain
        wpa.domain.data.reset = WPAPeapEncryption.resetDomain        
        
    end    

    self:_clearReset()
    self.wpa = wpa
    return wpa
end

function WPAPeapEncryption:setUsername(value)
    local device = self:getDevice()
    log:info("setting username :")
    log:info(value)   
    device:setWirelessNetworkProperty("identity",value)
end

function WPAPeapEncryption:resetUsername()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("identity","")
end

function WPAPeapEncryption:isUsernameRequired()
    local device = self:getDevice()
    local username = device:getWirelessNetworkProperty("identity")
    -- case : already have username
    if (username != nil and username != "") then
        return false
    end
    --default : request Key
    return true
end

function WPAPeapEncryption:setPassword(value)
    local device = self:getDevice()
    log:info("setting password :")
    log:info(value)   
    device:setWirelessNetworkProperty("password",value)
end

function WPAPeapEncryption:resetPassword()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("password","")
end

function WPAPeapEncryption:isPasswordRequired()
    local device = self:getDevice()
    local password = device:getWirelessNetworkProperty("password")
    -- case : already have password
    if (password != nil and password != "") then
        return false
    end
    --default : request Key
    return true
end

function WPAPeapEncryption:setDomain(value)
    local device = self:getDevice()
    log:info("setting domain :")
    log:info(value)   
    device:setWirelessNetworkProperty("domain",value)
end

function WPAPeapEncryption:resetDomain()
    local device = self:getDevice()
    device:setWirelessNetworkProperty("domain","")
end

function WPAPeapEncryption:isDomainRequired()
    local device = self:getDevice()
    local domain = device:getWirelessNetworkProperty("domain")
    -- case : already have domain
    if (domain != nil and domain != "") then
        return false
    end
    --default : request Key
    return true
end

WirelessEncryption.registerEncType(WPAPeapEncryption.WICD_NAME,{class=WPAPeapEncryption, human_name=WPAPeapEncryption.HUMAN_NAME })

return WPAPeapEncryption

