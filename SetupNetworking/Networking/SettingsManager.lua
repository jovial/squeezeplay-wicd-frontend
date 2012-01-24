
local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable,tostring, require = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable,tostring, require

local oo			= require("loop.simple")
local string           = require("jive.utils.string")

local oo               = require("loop.simple")
local io               = require("io")
local lfs              = require("lfs")

local debug            = require("jive.utils.debug")
local utilLog          = require("jive.utils.log")
local log              = require("jive.utils.log").logger("SetupNetworking.SettingsManager")
local locale           = require("jive.utils.locale")
local dumper           = require("jive.utils.dumper")
local table            = require("jive.utils.table")

local System           = require("jive.System")


local SettingsManager = oo.class()


-- path is relative to user path
function SettingsManager:__init(path,name)
  
  
  local obj = oo.rawnew(self)
  
  obj.name = name
  
  local _userpathdir = System.getUserDir()
  
  obj.path = _userpathdir .. path
  
  log:info("Settings manager path: ", obj.path)
  
  _mkdirRecursive(obj.path)
  
  
  obj.settings = obj:getSettings()
  
  
  return obj
  
end

function SettingsManager:getName()
  return self.name
end

function SettingsManager:storeSettings()
  log:info("store settings: " , self:getName()  )
  
  System:atomicWrite(self:getPath() .. self:getName(),
    dumper.dump(self.settings, "settings", true))
  
end


function SettingsManager:getPath()
  
  return self.path
  
end


function SettingsManager:_loadSettings()
  
  local path = self:getPath()
  local name = self:getName()
  
  if self.settings then
    -- already loaded
    return
  end
  
  log:debug("_loadSettings: ", path .. name)
  
  local fh = io.open(path .. name)
  
  if fh == nil then
    return {}
  end
  
  --print("loading")
  
  local f, err = load(function() return fh:read() end)
  fh:close()
  
  if not f then
    log:error("Error reading settings from ", path .. name, err)
  else
    -- evalulate the settings in a sandbox
    local env = {}
    setfenv(f, env)
    f()
    
    self.settings = env.settings
  end
  
  self.settings = self.settings or {}
  
  return self.settings 
end


function SettingsManager:getSettings()
  
  if self.settings == nil then
    
    return self:_loadSettings()
    
  end
  
  return self.settings
  
end




function _mkdirRecursive(dir)
  --normalize to "/"
  local dir = dir:gsub("\\", "/")
  
  local newPath = ""
  for i, element in pairs(string.split('/', dir)) do
    newPath = newPath .. element
    if i ~= 1 then --first element is (for full path): blank for unix , "<drive-letter>:" for windows
      if lfs.attributes(newPath, "mode") == nil then
        log:debug("Making directory: " , newPath)
        
        local created, err = lfs.mkdir(newPath)
        if not created then
          error (string.format ("error creating dir '%s' (%s)", newPath, err))
        end	
      end
    end
    newPath = newPath .. "/"
  end
  
end


return SettingsManager



