
local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable

local oo               = require("loop.simple")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local Popup                  = require("jive.ui.Popup")



local ConnectPopup = oo.class()

function ConnectPopup:__init(parent,title, subtext, maxTime)
  
  local obj = oo.rawnew(self)
  
  maxTime = maxTime or 60
  
  obj.popup = Popup("waiting_popup")	
  obj.icon = Icon("icon_connecting")
  
  obj.label = Label("text", title or "")
  obj.message = subtext
  obj.label2 = Label("subtext", subtext or "")
  obj.title = title
  obj.parent = parent
  obj.completed = false
  obj.maxCount = maxTime * 2
  
  obj.popup:addWidget(obj.icon)
  obj.popup:addWidget(obj.label)
  obj.popup:addWidget(obj.label2)
  
  obj.count = 0
  obj.timer = obj.popup:addTimer(500, function()
      
      obj.count = obj.count + 1
      
      obj.label:setValue(obj.title)
      
      if obj.count >= obj.maxCount or obj.completed then
        
        if obj.completed then
          
          obj.icon:setStyle("icon_connected")
          obj.label2:setValue("Connection Successful")
          obj.label2:setStyle('subtext_connected')
          
        else
          
          obj.label2:setValue("Connection failed")
          
        end
        
        obj.popup:removeTimer(obj.timer)
        -- show status for 2 seconds, then hide
        obj.popup:addTimer(4000, function() obj.popup:hide() end, true)
      end
      
  end)
  
  obj.popup:ignoreAllInputExcept({})
  
  
  return obj
  
end

function ConnectPopup:terminate()
  
  self.popup:removeTimer(self.timer)
  self.popup:hide()
  
end

function ConnectPopup:update(title, subtext)
  
  self.message = subtext
  self.title = title
  
  if self.message != nil then
    self.label2:setValue(self.message)
  end  
  
  if self.title != nil then
    self.label:setValue(self.title)
  end  
  
end

function ConnectPopup:close(success)
  success = success or false 
  
  if success then
    self.completed = true
    
  else
    self.count = self.maxCount
    
  end
  
  
  
end

function ConnectPopup:show()
  
  self.parent:tieAndShowWindow(self.popup)
  
end


function ConnectPopup:isVisible()
  
  return self.popup:isVisible()
  
end

return ConnectPopup




