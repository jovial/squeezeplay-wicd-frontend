#include "wicd_dbus_connection.h"

DBusGConnection * init_dbus(lua_State *luaStateIn) {

// set global var declared in common defs
//luaState = luaStateIn;

GError *error = NULL;

// connect to the system bus
DBusGConnection * systemDbusConnection = dbus_g_bus_get (DBUS_BUS_SYSTEM, &error);

if (systemDbusConnection == NULL){
	PUSH_ERROR_MESSAGE(luaStateIn,BUS_CONNECTION_ERROR, error->message);
	g_error_free (error);
	lua_error(luaStateIn);
	return NULL;
}
return systemDbusConnection;
}


DBusGProxy * get_daemon_proxy(DBusGConnection * dbusC, lua_State *L) {
	
	if (dbusC == NULL){
	PUSH_ERROR_MESSAGE(L,NO_DBUS_CONNECTION_ERROR,NO_DBUS_CONNECTION_ERROR_MESSAGE);
	lua_error(L);
	return NULL; 
	}

	DBusGProxy * proxy = NULL;

	proxy = dbus_g_proxy_new_for_name (dbusC,
		"org.wicd.daemon",
		"/org/wicd/daemon",
		"org.wicd.daemon");
	return proxy;
}


DBusGProxy * get_wired_proxy(DBusGConnection * dbusC, lua_State *L) {
	
	if (dbusC == NULL){
	PUSH_ERROR_MESSAGE(L,NO_DBUS_CONNECTION_ERROR,NO_DBUS_CONNECTION_ERROR_MESSAGE);
	lua_error(L);
	return NULL; 
	}

	DBusGProxy * proxy = NULL;

	proxy = dbus_g_proxy_new_for_name (dbusC,
		"org.wicd.daemon",
		"/org/wicd/daemon/wired",
		"org.wicd.daemon.wired");
	return proxy;
}

DBusGProxy * get_wireless_proxy(DBusGConnection * dbusC, lua_State *L) {
	
	if (dbusC == NULL){
	PUSH_ERROR_MESSAGE(L,NO_DBUS_CONNECTION_ERROR,NO_DBUS_CONNECTION_ERROR_MESSAGE);
	lua_error(L);
	return NULL; 
	}

	DBusGProxy * proxy = NULL;

	proxy = dbus_g_proxy_new_for_name (dbusC,
		"org.wicd.daemon",
		"/org/wicd/daemon/wireless",
		"org.wicd.daemon.wireless");
	return proxy;
}

void closeProxy(DBusGProxy * proxy){
	g_object_unref (proxy);
}



