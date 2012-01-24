
local ipairs, pairs, print, type, setmetatable, lua_table, _G, _assert, getmetatable, tostring = ipairs, pairs, print, type, setmetatable, table, _G , assert,  getmetatable, tostring

local oo               = require("loop.simple")
local Font                   = require("jive.ui.Font")
local jive = jive


-- got lazy and pasted a lot of libs

local io                     = require("io")
local oo                     = require("loop.simple")
local math                   = require("math")
local string                 = require("string")
local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")

local Applet                 = require("jive.Applet")
local System                 = require("jive.System")
local Checkbox               = require("jive.ui.Checkbox")
local Choice                 = require("jive.ui.Choice")
local Framework              = require("jive.ui.Framework")
local Event                  = require("jive.ui.Event")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local Button                 = require("jive.ui.Button")
local Popup                  = require("jive.ui.Popup")
local Group                  = require("jive.ui.Group")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Slider                 = require("jive.ui.Slider")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Textinput              = require("jive.ui.Textinput")
local Window                 = require("jive.ui.Window")
local ContextMenuWindow      = require("jive.ui.ContextMenuWindow")
local Timer                  = require("jive.ui.Timer")
local Keyboard               = require("jive.ui.Keyboard")


--


local fontpath = "fonts/"
local FONT_NAME = "FreeSans"
local FIXED_FONT_NAME = "FreeMono"
local BOLD_PREFIX = "Bold"

local Networking = {}
Networking.Option = require("Networking.Option")

local Utilities = oo.class()

function Utilities:_init()
  
  --do nothing
  
end

-- define a local function that makes it easier to set fonts
function Utilities:_font(fontSize)
  return Font:load(fontpath .. FONT_NAME .. ".ttf", fontSize)
end

-- define a local function that makes it easier to set bold fonts
function Utilities:_font_boldfont(fontSize)
  return Font:load(fontpath .. FONT_NAME .. BOLD_PREFIX .. ".ttf", fontSize)
end


function Utilities:_uses(parent, value)
  local style = {}
  setmetatable(style, { __index = parent })
  
  for k,v in pairs(value or {}) do
    if type(v) == "table" and type(parent[k]) == "table" then
      -- recursively inherrit from parent style
      style[k] = self:_uses(parent[k], v)
    else
      style[k] = v
    end
  end
  
  return style
end


-- clones a parent style, replacing attributes specified in value
-- returns: new style
function Utilities:_clone_style(parent, value)
  local style = {}
  setmetatable(style, { __index = parent })
  
  if(parent == nil) then
    return
  end
  
  -- speical case : empty table, action: copy parent table
  if type(value) == "table" and type(parent) =="table" then
    lastElement = lua_table.getn(value)
    if (lastElement == 0) then
      for a,b in pairs (parent) do
        style[a] = b
      end
    end
    
  end
  
  --copy all parent atributes (baring those specified in value)
  for k,v in pairs(value or {}) do
    if type(v) == "table" and type(parent[k]) == "table" then
      -- recursively inherrit from parent style
      style[k] = self:_clone_style(parent[k], v)
    else
      style[k] = v
      if (k == lastElement) then
        for i,j in pairs(parent) do
          if style[i] == nil then
            style[i]=j
          end
        end
      end
    end
  end
  
  return style
end

-- creates a new style from an existing one, changing any attributes specified in attributes

function Utilities:modifyOldStyle(styleName, parentStyle, attributes, hasPressed , hasSelected ) 
  
  jive.ui.style[styleName] = self:_clone_style(jive.ui.style[parentStyle], attributes)
  jive.ui.style.icon_list.menu[styleName] = self:_clone_style(jive.ui.style.icon_list.menu[parentStyle], attributes)
  if hasSelected == true then
    jive.ui.style.icon_list.menu.selected[styleName]  = self:_clone_style(jive.ui.style.icon_list.menu.selected[parentStyle], attributes)
  end
  if hasPressed == true then
    jive.ui.style.icon_list.menu.pressed[styleName] = self:_clone_style(jive.ui.style.icon_list.menu.pressed[parentStyle], attributes)
  end
end

-- creates a style for title section and returns the style code as a string
function Utilities:createSectionTitleStyle()
  
  if jive.ui.style["section_title"] == nil then
    
    local attributes = {}
    local styleName= "section_title"
    local parentStyle = "item_choice"
    
    attributes.bgImg = jive.ui.style.title.bgImg
    attributes.text = {font =self:_font(18)}
    attributes.choice = {font =self:_font(18), align="right"}
    
    jive.ui.style[styleName] = self:_clone_style(jive.ui.style[parentStyle], attributes)
  end
  
end

function Utilities:getStandardNetworkOptions(device,redraw, getInput)
  
  
  _assert(type(redraw) == "function", "You must pass in a valid function to redaw the interface")
  
  local optionsList = {}
  
  
  local title = "Network Address:"
  
  local options = {"DHCP","Manual"}
  
  local function callbackFunction(choiceObject, selectedIndex)
    
    --print(selectedIndex)
    
    if selectedIndex == 2 then
      device:setManual()
    else
      
      device:setDHCP()
    end
    
    redraw()
    
  end
  
  local function statusFunction(self)
    
    if device:isDHCP() then
      return options[1]
    else
      return options[2]
    end
    
  end
  
  Networking.Option(title, options, callbackFunction, statusFunction, optionsList)
  
  if not device:isDHCP() then
    
    local title = "IP address: "
    
    local options = {device:getIP()}
    
    local function setIP(value)
      local stringValue = tostring(value)
      device:setIP(stringValue)
      redraw()
    end
    
    local function callbackFunction(choiceObject, selectedIndex)
      
      getInput(title,setIP,device:getIP(),"ip")
      
    end
    
    
    Networking.Option(title, options, callbackFunction, nil, optionsList)
    
    local function setIP(value)
      local stringValue = tostring(value)
      device:setNetmask(stringValue)
      redraw()
    end
    
    
    local title = "Netmask: "
    
    local options = {device:getNetmask()}
    
    local function callbackFunction(choiceObject, selectedIndex)
      
      getInput(title,setIP,device:getNetmask(),"ip")
      
    end
    
    Networking.Option(title, options, callbackFunction, nil, optionsList)
    
    local function setIP(value)
      local stringValue = tostring(value)
      device:setGateway(stringValue)
      redraw()
    end	
    
    local title = "Gateway: "
    
    local options = {device:getGateway()}
    
    local function callbackFunction(choiceObject, selectedIndex)
      
      getInput(title,setIP,device:getGateway(),"ip")
      
    end
    
    
    Networking.Option(title, options, callbackFunction, nil, optionsList)
    
    local function setIP(value)
      local stringValue = tostring(value)
      device:setDNS1(stringValue)
      redraw()
    end	
    
    local title = "DNS 1: "
    
    local options = {device:getDNS1()}
    
    local function callbackFunction(choiceObject, selectedIndex)
      
      getInput(title,setIP,device:getDNS1(),"ip")
      
    end
    
    
    Networking.Option(title, options, callbackFunction, nil, optionsList)
    
    local function setIP(value)
      local stringValue = tostring(value)
      device:setDNS2(stringValue)
      redraw()
    end		
    
    local title = "DNS 2: "
    
    local options = {device:getDNS2()}
    
    local function callbackFunction(choiceObject, selectedIndex)
      
      getInput(title,setIP,device:getDNS2(),"ip")
      
    end
    
    
    Networking.Option(title, options, callbackFunction, nil, optionsList)
    
    local function setIP(value)
      local stringValue = tostring(value)
      device:setDNS3(stringValue)
      redraw()
    end
    
    local title = "DNS 3: "
    
    local options = {device:getDNS3()}
    
    local function callbackFunction(choiceObject, selectedIndex)
      
      getInput(title,setIP,device:getDNS3(),"ip")
      
    end
    
    
    Networking.Option(title, options, callbackFunction, nil, optionsList)
    
    
  end
  
  
  return optionsList
  
  
end

function Utilities:getStandardConnectionOptions(device,redraw, getInput, connect)
  
  _assert(type(redraw) == "function", "You must pass in a valid function to redaw the interface")
  
  local optionsList = {}
  
  
  local title = "Connect"
  
  local options = {""}
  
  local function callbackFunction(choiceObject, selectedIndex)
    
    connect(device)
    
  end
  
  
  Networking.Option(title, options, callbackFunction, nil, optionsList)
  
  
  
  return optionsList
  
  
  
end


function Utilities:getUserInput(parent, style, title, callback, initial, textinput)
  
  initial = initial or ""
  
  _assert(type(callback) == "function" or type(callback) == "nil", " Invalid callback function")
  local window = Window("text_list", title)
  
  local v =  textinput or Textinput.textValue(initial)
  
  
  local textinput = Textinput("textinput", v,
    function(_, value)
      callback(value)
      window:playSound("WINDOWSHOW")
      window:hide(Window.transitionPushLeft)
      return true
  end)
  local backspace = Keyboard.backspace()
  local group = Group('keyboard_textinput', { textinput = textinput, backspace = backspace } )
  
  window:addWidget(group)
  window:addWidget(Keyboard('keyboard', style, textinput))
  window:focusWidget(group)
  
  
  parent:tieAndShowWindow(window)
  
  
  
end

-- modfied textinput to allow deletion (zero length)
function Utilities.ipAddressValue(default)
  local obj = {}
  setmetatable(obj, {
      __tostring = function(obj)
        if not (Framework:isMostRecentInput("ir")
          or Framework:isMostRecentInput("key")
          or Framework:isMostRecentInput("scroll")) then
          return obj.str
        end
        
        local s = {}
        for i=1,4 do
          s[i] = string.format("%03d", obj.v[i] or 0)
        end
        return table.concat(s, ".")
      end,
      
      __index = {
        setValue = function(obj, str)
          local v = {}
          
          if string.match(str, "%.%.") then
            return false
          end
          
          local i = 1
          for ddd in string.gmatch(str, "(%d+)") do
            v[i] = tonumber(ddd)
            
            -- Bug: 10352
            -- Allow changing first digit from 1 to 2 and
            --  then correct to 255 if needed
            -- This allows user to enter / correct from left
            --  to right even for non zero values, i.e.
            --  old: 192 -> new: 292 -> auto corrected: 255
            if v[i] > 255 and v[i] < 300 then
              v[i] = 255
            end
            
            if v[i] > 255 then
              return false
            end
            
            i = i + 1
            if i > 5 then
              return false
            end
          end
          
          obj.v = v
          obj.str = table.concat(v, ".")
          if string.sub(str, -1) == "." then
            obj.str = obj.str .. "."
          end
          
          return true
        end,
        
        getValue = function(obj)
          -- remove leading zeros
          local norm = {}
          for i,v in ipairs(obj.v) do
            norm[i] = tostring(tonumber(v))
          end
          return table.concat(norm, ".")
        end,
        
        getChars = function(obj, cursor)
          -- keyboard input
          if not (Framework:isMostRecentInput("ir")
            or Framework:isMostRecentInput("key")
            or Framework:isMostRecentInput("scroll")) then
            if #obj.v < 4 then
              return "0123456789."
            else
              return "0123456789"
            end
          end
          
          -- IR input
          local n = (cursor % 4)
          if n == 0 then
            return ""
          end
          local v = tonumber(obj.v[math.floor(cursor/4)+1]) or 0
          
          local a = math.floor(v / 100)
          local b = math.floor(v % 100 / 10)
          local c = math.floor(v % 10)
          
          if n == 1 then
            -- Bug: 10352
            -- Allow changing first digit from 1 to 2 and
            --  then correct to 255 if needed
            -- This allows user to enter / correct from left
            --  to right even for non zero values, i.e.
            --  old: 192 -> new: 292 -> auto corrected: 255
            return "012"
          elseif n == 2 then
            if a >= 2 and c > 5 then
              return "01234"
            elseif a >= 2 then
              return "012345"
            else
              return "0123456789"
            end
          elseif n == 3 then
            if a >= 2 and b >= 5 then
              return "012345"
            else
              return "0123456789"
            end
          end
        end,
        
        reverseScrollPolarityOnUpDownInput = function()
          return true
        end,
        
        defaultCursorToStart = function()
          if not default or default == "" then
            return true
          else
            return false
          end
        end,
        
        isValid = function(obj, cursor)
          
          if #obj.v == 0 then
            return true
          end
          
          return #obj.v == 4 and not
          (obj.v[1] == 0 and
            obj.v[2] == 0 and
            obj.v[3] == 0 and
            obj.v[4] == 0)
        end,
        
        useValueDelete = function(obj)
          --bypass custom delete for touch
          return (Framework:isMostRecentInput("ir")
            or Framework:isMostRecentInput("key")
            or Framework:isMostRecentInput("scroll"))
        end,
        
        delete = function(obj, cursor)
          local str = tostring(obj)
          if cursor <= #str then
            -- Switch to 0 at cursor
            local s1 = string.sub(str, 1, cursor - 1)
            local s2 = "0"
            local s3 = string.sub(str, cursor + 1)
            
            local new = s1 .. s2 .. s3
            
            obj:setValue(new)
            return -1
            
          elseif cursor > 1 then
            -- just move back one
            return -1
            
          else
            return false
          end
        end
      }
  })
  
  obj:setValue(default or "")
  
  return obj
end

return Utilities


