#!/usr/bin/python

#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

import optparse
import dbus
import dbus.service
import sys
from wicd import misc

misc.RenameProcess('wicd-cli')

if getattr(dbus, 'version', (0, 0, 0)) < (0, 80, 0):
    import dbus.glib
else:
    from dbus.mainloop.glib import DBusGMainLoop
    DBusGMainLoop(set_as_default=True)

bus = dbus.SystemBus()
try:
	daemon = dbus.Interface(bus.get_object('org.wicd.daemon', '/org/wicd/daemon'),
			'org.wicd.daemon')
	wireless = dbus.Interface(bus.get_object('org.wicd.daemon', '/org/wicd/daemon/wireless'),
			'org.wicd.daemon.wireless')
	wired = dbus.Interface(bus.get_object('org.wicd.daemon', '/org/wicd/daemon/wired'),
			'org.wicd.daemon.wired')
	config = dbus.Interface(bus.get_object('org.wicd.daemon', '/org/wicd/daemon/config'),
			'org.wicd.daemon.config')
except dbus.DBusException:
	print 'Error: Could not connect to the daemon. Please make sure it is running.'
	sys.exit(3)

list=["hello"]

daemon.EmitStatusChanged(0,list)
