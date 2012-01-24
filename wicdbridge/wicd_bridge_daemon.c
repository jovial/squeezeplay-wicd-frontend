
//glib auto generated bindings
#include "common/wicd-client-stub.h"
// shared code
#include "common/wicd_common_defs.h"
// dbus related code
#include "common/wicd_dbus_connection.h"
#include "wicd-marshallers.h"

static int GetConnectionStatus(lua_State *L) {

//structure containg state and info
GValueArray * StateInfoStruct;

//temp var to hold Gvalue before we convert to actual type
GValue * intermediary;

//keep track of how many objects we've pushed.
int pushCount =0;
int sizeOfState;

// objects extracted from sctructure
char ** info;
guint state;


DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_get_connection_status (proxy, &StateInfoStruct, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(L,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(L);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}



intermediary = g_value_array_get_nth(StateInfoStruct,0);

state = g_value_get_uint(intermediary);
lua_pushnumber(L,state);
pushCount++;


intermediary = g_value_array_get_nth(StateInfoStruct,1);

info = (char **) g_value_get_boxed( intermediary);

lua_newtable(L);

int i =0;

switch(state) {
case 0: 
	sizeOfState = 1;
	pushCount++;
	break;
case 1:
	sizeOfState = 2;
	pushCount++;
	break;
case 2:
	sizeOfState = 5;
	pushCount++;
	break;
case 3:
	sizeOfState = 1;
	pushCount++;
	break;
case 4:
	sizeOfState = 1;
	pushCount++;
	break;
default:
	sizeOfState = 0;
}

for (i = 1 ; i<=sizeOfState; i++) {
	lua_pushnumber(L, i);  
	lua_pushstring(L, info[i-1] );
	lua_rawset(L, -3);
}

//return string
//lua_pushstring(L,info[2]);

/* Cleanup */
g_value_array_free(StateInfoStruct);
closeProxy(proxy);

//indicate one object was returned
return pushCount;
}

static int Disconnect(lua_State *L) {

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_disconnect (proxy, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(L,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(L);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

closeProxy(proxy);

return 0;
}


static int AutoConnect(lua_State *L) {

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);
GError *error = NULL;

gboolean AutoConnect = get_boolean_arg(L,-1);


if (!org_wicd_daemon_auto_connect (proxy, AutoConnect, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(L,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(L);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

closeProxy(proxy);

return 0;
}


static int GetAutoReconnect(lua_State *L) {

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);
GError *error = NULL;

gboolean AutoReconnect;

if (!org_wicd_daemon_get_auto_reconnect (proxy, &AutoReconnect, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(L,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(L);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

lua_pushboolean(L,AutoReconnect);

closeProxy(proxy);

return 1;
}

static int SetAutoReconnect(lua_State *L) {

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);
GError *error = NULL;

gboolean AutoReconnect = get_boolean_arg(L,-1);


if (!org_wicd_daemon_set_auto_reconnect (proxy, AutoReconnect, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(L,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(L);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

closeProxy(proxy);


return 0;
}


static void
status_signal_handler (DBusGProxy *proxy, guint status, GArray * StateInfoStruct, gpointer user_data)
{
 printf("hello");
}

// doesnt work
static int AddStatusListener(lua_State *L) {

// http://old.nabble.com/glib-signal-marshaller-td21724700.html

GMainLoop *mainloop= g_main_loop_new (NULL, FALSE);
DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);

GType otype = dbus_g_type_get_struct("GArray",
                                       G_TYPE_VARIANT,
                                      G_TYPE_INVALID); 

//otype = dbus_g_type_get_collection("GPtrArray",  G_TYPE_OBJECT);

                                     

dbus_g_object_register_marshaller (_wicd_marshal_VOID__UINT_BOXED, G_TYPE_NONE, G_TYPE_UINT, otype, G_TYPE_INVALID);

dbus_g_proxy_add_signal (proxy, "StatusChanged", G_TYPE_UINT, otype, G_TYPE_INVALID);

dbus_g_proxy_connect_signal (proxy, "StatusChanged", G_CALLBACK (status_signal_handler),
                       NULL, NULL);

g_main_loop_run (mainloop);

return 0;

}

static int GetConnectedInterface(lua_State *L)
{

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);

return zero_arg_string_return_dbus_call(L, proxy,&org_wicd_daemon_get_connected_interface);

}

static int SetWirelessInterface(lua_State *L)
{

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);

return string_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_set_wireless_interface);

}

static int SetWiredInterface(lua_State *L)
{

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);

return string_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_set_wired_interface);

}


static int SetPreferWiredNetwork(lua_State *L)
{

DBusGProxy * proxy = get_daemon_proxy(init_dbus(L),L);

return boolean_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_set_prefer_wired_network);

}

static int GetPreferWiredNetwork(lua_State *L) {

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
return zero_arg_variable_return_dbus_call(L,proxy,"GetPreferWiredNetwork");

}


static const luaL_Reg daemon_lib[] = {
  {"GetConnectionStatus", GetConnectionStatus},
  {"Disconnect", Disconnect},
  {"AutoConnect", AutoConnect},
  {"GetAutoReconnect", GetAutoReconnect},
  {"SetAutoReconnect", SetAutoReconnect},
  //{"AddStatusListener", AddStatusListener}, //removed as doesn't work
  {"GetConnectedInterface",GetConnectedInterface},
  {"SetWirelessInterface", SetWirelessInterface},
  {"SetWiredInterface", SetWiredInterface},
  {"SetPreferWiredNetwork",SetPreferWiredNetwork},
  {"GetPreferWiredNetwork",GetPreferWiredNetwork},
  {NULL, NULL}
};



LUALIB_API int luaopen_wicdbridge_daemon(lua_State *L) {

g_type_init();
//init_dbus(L);
// lets not register lib, but return functions with call to require instead.
//luaL_register(L,"wicd.daemon",daemon_lib);

luaL_register (L,
                    "wicdbridge_daemon",
                    daemon_lib);

return 1;
}
