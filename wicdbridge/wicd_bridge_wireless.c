
//glib auto generated bindings
#include "common/wicd-client-stub.h"
// shared code
#include "common/wicd_common_defs.h"
// dbus related code
#include "common/wicd_dbus_connection.h"

static int SaveWirelessNetworkProfile(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);

return int_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_save_wireless_network_profile);


}

static int GetNumberOfNetworks(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);

return zero_arg_int_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_get_number_of_networks);


}

static int Scan(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);

return boolean_arg_boolean_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_scan);

}

static int SetHiddenNetworkESSID(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);

return string_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_set_hidden_network_es_si_d);

}

static int GetWirelessProperty(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return int_string_arg_variable_return_dbus_call(L, proxy,"GetWirelessProperty");


return 0;
}

static int SetWirelessProperty(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return int_string_string_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_set_wireless_property);
}

static int GetCurrentNetwork(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return int_arg_string_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_get_current_network);

}

static int DetectWirelessInterface(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_string_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_detect_wireless_interface);

}

static int GetCurrentNetworkID(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return int_arg_int_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_get_current_network_id);

}

static int GetWirelessIP(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return int_arg_variable_return_dbus_call(L, proxy,"GetWirelessIP" );

}

static int ConnectWireless(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return int_arg_no_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_connect_wireless );

}

static int CheckIfWirelessConnecting(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_boolean_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_check_if_wireless_connecting);

}

static int CheckWirelessConnectingMessage(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_variable_return_dbus_call(L, proxy,"CheckWirelessConnectingMessage");

}

static int EnableWirelessInterface(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_boolean_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_enable_wireless_interface);

}

static int DisableWirelessInterface(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_boolean_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_disable_wireless_interface);

}

static int IsWirelessUp(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_boolean_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_is_wireless_up);

}

static int GetWirelessInterfaces(lua_State *L) {

DBusGProxy * proxy = get_wireless_proxy(init_dbus(L),L);
return zero_arg_string_array_return_dbus_call(L, proxy,&org_wicd_daemon_wireless_get_wireless_interfaces);

}


static const luaL_Reg daemon_lib[] = {
  {"SaveWirelessNetworkProfile", SaveWirelessNetworkProfile},
  {"GetNumberOfNetworks",GetNumberOfNetworks},
  {"Scan",Scan},
  {"SetHiddenNetworkESSID",SetHiddenNetworkESSID},
  {"GetWirelessProperty",GetWirelessProperty},
  {"SetWirelessProperty",SetWirelessProperty},
  {"GetCurrentNetwork",GetCurrentNetwork},
  {"DetectWirelessInterface", DetectWirelessInterface},
  {"GetCurrentNetworkID",GetCurrentNetworkID},
  {"GetWirelessIP",GetWirelessIP},
  {"ConnectWireless",ConnectWireless},
  {"CheckIfWirelessConnecting",CheckIfWirelessConnecting},
  {"CheckWirelessConnectingMessage",CheckWirelessConnectingMessage},
  {"EnableWirelessInterface",EnableWirelessInterface},
  {"DisableWirelessInterface",DisableWirelessInterface},
  {"IsWirelessUp",IsWirelessUp},
  {"GetWirelessInterfaces",GetWirelessInterfaces},
  {NULL, NULL}
};



LUALIB_API int luaopen_wicdbridge_wireless(lua_State *L) {

g_type_init();
//init_dbus(L);
// lets not register lib, but return functions with call to require instead.
//luaL_register(L,"wicd.daemon",daemon_lib);

//push_luaL_Reg_array(L,daemon_lib);

luaL_register (L,
                    "wicdbridge_wireless",
                    daemon_lib);

return 1;
}
