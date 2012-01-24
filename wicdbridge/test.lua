
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

wicd = {}

--wicd.daemon = {}
wicd.daemon = require("wicdbridge_daemon")
wicd.daemon.wired = require("wicdbridge_wired")
wicd.daemon.wireless = require("wicdbridge_wireless")
--string = readWiredNetworkProfile("test")

--string = wicd.daemon.GetConnectionStatus()
--print(string)

--status, info = wicd.daemon.GetConnectionStatus()
--print(status)
--print(info[1])

--profilelist = wicd.daemon.wired.GetWiredProfileList()
--print(profilelist[3])

--string = wicd.daemon.wired.DetectWiredInterface()
--print(string)

--print( wicd.daemon.wireless.GetNumberOfNetworks());

--print( wicd.daemon.wireless.Scan(true));

--wicd.daemon.wireless.SetWirelessProperty(0,"ip","192.168.21.67") 

--wicd.daemon.wireless.SaveWirelessNetworkProfile(0)

-- can return too few argumnets
--print (wicd.daemon.wireless.GetWirelessProperty(0,"ip") )

--print (wicd.daemon.wireless.DetectWirelessInterface() )
--print (wicd.daemon.wireless.GetCurrentNetworkID(0) )

--can return too few if ip not 
--print (wicd.daemon.wireless.GetWirelessIP(0) )

--print(wicd.daemon.wireless.DisableWirelessInterface() )

--print (wicd.daemon.wireless.IsWirelessUp() )

--print(wicd.daemon.wireless.EnableWirelessInterface() )

--print (wicd.daemon.wireless.IsWirelessUp() )

--print(wicd.daemon.wireless.GetWirelessProperty(0, "quality"))

--print(wicd.daemon.wireless.GetWirelessProperty(0,"bssid"))
--print(wicd.daemon.wireless.GetWirelessProperty(1,"bssid"))
--print(wicd.daemon.wireless.GetWirelessProperty(0,"ip"))
--print(wicd.daemon.wireless.GetWirelessProperty(1,"ip"))

--if (wicd.daemon.wireless.GetWirelessProperty(1,"ip") == nil) then
--	print("nil")
--else
--	print("not nil")
--end

--wicd.daemon.wireless.SetHiddenNetworkESSID("test") 

--print(wicd.daemon.wired.CheckWiredConnectingMessage())

 co = coroutine.create(function ()
           for i=1,10 do

	--print(wicd.daemon.wireless.SetWirelessProperty(0,"ip","192.168.1.33"))
	print(wicd.daemon.wired.GetWiredProperty("ip"))
	coroutine.yield()
           end
         end)

coroutine.resume(co) 



