
//glib auto generated bindings
#include "common/wicd-client-stub.h"
// shared code
#include "common/wicd_common_defs.h"
// dbus related code
#include "common/wicd_dbus_connection.h"

static int ReadWiredNetworkProfile(lua_State *L) {

const char * arg = lua_tolstring(L,-1,NULL);

gchar *ReadWiredNetworkProfileMessage;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_read_wired_network_profile (proxy, arg, &ReadWiredNetworkProfileMessage, &error))
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

//return string
lua_pushstring(L,ReadWiredNetworkProfileMessage);

/* Cleanup */
g_free (ReadWiredNetworkProfileMessage);
closeProxy(proxy);

//indicate one object was returned
return 1;
}

static int SaveWiredNetworkProfile(lua_State *L) {
const char * arg = lua_tolstring(L,-1,NULL);

gchar *SaveWiredNetworkProfileMessage;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_save_wired_network_profile (proxy, arg, &SaveWiredNetworkProfileMessage, &error))
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

//return string
lua_pushstring(L,SaveWiredNetworkProfileMessage);

/* Cleanup */
g_free (SaveWiredNetworkProfileMessage);
closeProxy(proxy);

//indicate one object was returned
return 1;
}

static int GetWiredProfileList(lua_State *L) {


// objects extracted from sctructure

char ** WiredProfileList;
int sizeOfList;

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_get_wired_profile_list (proxy, &WiredProfileList, &error))
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


sizeOfList = g_strv_length(WiredProfileList);

lua_newtable(L);
int i;
for (i = 1 ; i<=sizeOfList; i++) {
	lua_pushnumber(L, i);  
	lua_pushstring(L, WiredProfileList[i-1] );
	lua_rawset(L, -3);
}



/* Cleanup */
g_strfreev(WiredProfileList);
closeProxy(proxy);

//indicate one object was returned
return 1;

}


static int GetWiredProperty(lua_State *L) {

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);;
return string_arg_variable_return_dbus_call(L,proxy,"GetWiredProperty");

}

static int SetWiredProperty(lua_State *L){


const char * arg1 = lua_tolstring(L,-2,NULL);
const char * arg2 = lua_tolstring(L,-1,NULL);

gboolean Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_set_wired_property (proxy, arg1, arg2, &Return, &error))
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

lua_pushboolean(L,Return);

/* Cleanup */

closeProxy(proxy);

return 1;

}

static int CheckPluggedIn(lua_State *L) {


gboolean Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_check_plugged_in (proxy, &Return, &error))
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


lua_pushboolean(L,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}


static int DetectWiredInterface(lua_State *L) {

gchar *Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_detect_wired_interface (proxy, &Return, &error))
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


lua_pushstring(L,Return);

/* Cleanup */
g_free (Return);
closeProxy(proxy);

//indicate one object was returned
return 1;

}

static int ConnectWired(lua_State *L) {

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_connect_wired(proxy, &error))
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


/* Cleanup */

closeProxy(proxy);

return 0;

}

static int CheckIfWiredConnecting(lua_State *L) {

gboolean Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_check_if_wired_connecting (proxy, &Return, &error))
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

//return string
lua_pushboolean(L,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}

// use CheckIfWiredConnecting() before calling this function

static int CheckWiredConnectingMessage(lua_State *L) {

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);;
return zero_arg_variable_return_dbus_call(L,proxy,"CheckWiredConnectingMessage");

}


static int EnableWiredInterface(lua_State *L) {

gboolean Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_enable_wired_interface (proxy, &Return, &error))
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

//return string
lua_pushboolean(L,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}

static int DisableWiredInterface(lua_State *L) {

gboolean Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_disable_wired_interface (proxy, &Return, &error))
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

//return string
lua_pushboolean(L,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}

static int IsWiredUp(lua_State *L) {


gboolean Return;
DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
GError *error = NULL;


if (!org_wicd_daemon_wired_is_wired_up(proxy, &Return, &error))
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

//return string
lua_pushboolean(L,Return);

/* Cleanup */

closeProxy(proxy);

return 1;



}

static int GetWiredInterfaces(lua_State *L) {

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
return zero_arg_string_array_return_dbus_call(L,proxy,&org_wicd_daemon_wired_get_wired_interfaces);

}

static int UnsetWiredDefault(lua_State *L) {

DBusGProxy * proxy = get_wired_proxy(init_dbus(L),L);
return zero_arg_variable_return_dbus_call(L,proxy,"UnsetWiredDefault");

}


static const luaL_Reg daemon_lib[] = {
  {"ReadWiredNetworkProfile", ReadWiredNetworkProfile},
  {"SaveWiredNetworkProfile",SaveWiredNetworkProfile},
  {"GetWiredProfileList",GetWiredProfileList},
  {"GetWiredProperty",GetWiredProperty},
  {"SetWiredProperty",SetWiredProperty},
  {"CheckPluggedIn",CheckPluggedIn},
  {"DetectWiredInterface",DetectWiredInterface},
  {"ConnectWired",ConnectWired},
  {"CheckIfWiredConnecting",CheckIfWiredConnecting},
  {"CheckWiredConnectingMessage",CheckWiredConnectingMessage},
  {"EnableWiredInterface",EnableWiredInterface},
  {"DisableWiredInterface",DisableWiredInterface},
  {"IsWiredUp",IsWiredUp},
  {"GetWiredInterfaces",GetWiredInterfaces},
  {"UnsetWiredDefault",UnsetWiredDefault},
  {NULL, NULL}
};



LUALIB_API int luaopen_wicdbridge_wired(lua_State *L) {

g_type_init();
//init_dbus(L);
// lets not register lib, but return functions with call to require instead.
//luaL_register(L,"wicd.daemon",daemon_lib);

//push_luaL_Reg_array(L,daemon_lib);

luaL_register (L,
                    "wicdbridge_wired",
                    daemon_lib);

//indicate return of table containg our functions we push aboved
return 1;
}
