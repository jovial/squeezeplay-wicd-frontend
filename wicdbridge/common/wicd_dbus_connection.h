#ifndef WICD_DBUS_CONNECTION_H
#define WICD_DBUS_CONNECTION_H

#include "wicd_common_defs.h"

#define NO_DBUS_CONNECTION_ERROR "Dbus connection does not exist"
#define NO_DBUS_CONNECTION_ERROR_MESSAGE "Did you call init_dbus()?"
#define BUS_CONNECTION_ERROR "Could not connect to the system bus"


DBusGConnection * init_dbus(lua_State *luaStateIn);

DBusGProxy * get_wireless_proxy(DBusGConnection * dbusC, lua_State *L);

DBusGProxy * get_wired_proxy(DBusGConnection * dbusC,lua_State *L);

DBusGProxy * get_daemon_proxy(DBusGConnection * dbusC, lua_State *L);

void closeProxy(DBusGProxy * proxy);










#endif
