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



