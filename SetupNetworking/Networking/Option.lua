
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


local oo               = require("loop.simple")

local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable

-- devices "class"

local Options = oo.class()

function Options:__init(title, options, callback, currentStatus, group)
  
  _assert(type(title) == "string")
  _assert(type(options)  == "table" or type(options)  == "nil" )
  _assert((type(callback) == "function") or type(callback) == "nil" )
  _assert((type(currentStatus) == "function") or type(currentStatus) == "nil" )
  _assert((type(group) == "table") or type(group) == "nil" )
  
  local obj = oo.rawnew(self)
  
  
  obj.title = title
  obj.options = options or {}
  obj.userCallback = callback or {}
  obj.getCurrentStatus = currentStatus or self.getCurrentStatus
  
  if group != nil then
    
    lua_table.insert(group, obj)
    
  end
  
  return obj
  
end

function Options:getCallback()
  
  
  local function callback(choiceObject, selectedIndex)
    
    --local statusIndex = self:getStatusIndex()
    
    --statusIndex = self:getStatusIndex()
    
    self.userCallback(choiceObject, selectedIndex)
    
    local statusIndex = self:getStatusIndex(choiceObject, selectedIndex)
    -- requires a number, selectedINdex can equal nil
    
    if (self.options[statusIndex] != nil) then
      choiceObject:setValue(self.options[statusIndex])
      
    end
    
    
  end
  
  return callback
  
end


function Options:getCurrentStatus()
  
  return nil
  
end

function Options:getStatusIndex(choiceObject, selectedIndex) 
  
  local status = self:getCurrentStatus(choiceObject, selectedIndex)
  
  
  if status == nil then
    return 1
  end
  
  
  for i,j in ipairs(self.options) do
    
    if j==status then
      return i
    end
  end 
  
  return 1
  
end

return Options

