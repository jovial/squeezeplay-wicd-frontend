#ifndef WICD_COMMON_DEFS_H
#define WICD_COMMON_DEFS_H

#include<glib.h>
#include <dbus/dbus-glib.h>

// Lua libs
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include "wicd_dbus_connection.h"

#define PUSH_ERROR_MESSAGE(LUASTATE,ERROR,MESSAGE) lua_pushfstring(LUASTATE,"\n\nAn error has occured in wicdbridge.so:\nError: %s\nCalling function: %s\nMessage: %s",ERROR,__FUNCTION__,MESSAGE)
#define FUNCTION_CALL_ERROR "Unable to call remote function"
#define INVALID_ARG_ERROR "Arguments missing or malformed"
#define INVALID_RETURN_TYPE_ERROR "Remore function returned an unepected type. Check method signature."

//extern lua_State *luaState;
//extern DBusGConnection * systemDbusConnection;

int push_luaL_Reg_array(lua_State *L, const luaL_Reg registrationTable[]);
int get_boolean_arg(lua_State *L, int index );
int zero_arg_boolean_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,gboolean *, GError **));
int zero_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,char **, GError **));
int string_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const char *,char **, GError **));
int int_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, const gint, GError **));
int zero_arg_int_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,gint *, GError **));
int boolean_arg_boolean_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const gboolean, gboolean *, GError **));
int string_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const char *, GError **));
int int_string_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * const, gint,const char *,char **, GError **));
int int_string_string_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * const, gint,const char *,const char *, GError **));
int int_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, const gint ,char **, GError **));
int int_arg_int_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const gint,gint *, GError **)) ;
int int_string_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod);
int zero_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod);
int int_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod);
int zero_arg_string_array_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, char *** , GError **));
int string_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod);
int boolean_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const gboolean, GError **));

#endif
