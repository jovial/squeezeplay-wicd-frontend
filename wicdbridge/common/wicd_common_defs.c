#include "wicd_common_defs.h"

//shared global vars
//lua_State *luaState = NULL;
//DBusGConnection * systemDbusConnection = NULL;


//return: count - returns the number of functions passed back to lua
/*
int push_luaL_Reg_array(lua_State *L, const luaL_Reg registrationTable []) {

int count = 0;

lua_newtable(L);

while (1){

if(registrationTable[count].name ==NULL && registrationTable[count].func ==NULL) {
	//end of array
	break;
}
lua_pushstring(L, registrationTable[count].name);  
lua_pushcfunction(L, registrationTable[count].func);
lua_rawset(L, -3);

count++;
}

return count;

}
*/

int get_boolean_arg(lua_State *L, int index)
{
    if ( lua_isboolean( L, index ) ) {
        return lua_toboolean( L, index );
        } else {
        PUSH_ERROR_MESSAGE(L,INVALID_ARG_ERROR, "An argument failed a boolean check");
        //shouldn't get here!
        return 0;
        }
      
}

int zero_arg_boolean_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,gboolean *, GError **)) {

gboolean Return;
GError *error = NULL;


if (!(*functionToCall)(proxy, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushboolean(luaState,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}

int zero_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,char **, GError **)) {

gchar *Return;

GError *error = NULL;


if (!(*functionToCall)(proxy,  &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushstring(luaState,Return);

/* Cleanup */
g_free (Return);
closeProxy(proxy);

//indicate one object was returned
return 1;

}

int string_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const char *,char **, GError **)){


const char * arg = lua_tolstring(luaState,-1,NULL);

gchar *Return;
GError *error = NULL;


if (!(*functionToCall) (proxy, arg, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushstring(luaState,Return);

/* Cleanup */
g_free (Return);
closeProxy(proxy);

//indicate one object was returned
return 1;

}

int int_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, const gint, GError **)) {



const int arg = lua_tonumber(luaState,-1);


GError *error = NULL;

if (!(*functionToCall) (proxy, arg, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}


closeProxy(proxy);


return 0;

}


int zero_arg_int_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,gint *, GError **)) {

gint Return;
GError *error = NULL;


if (!(*functionToCall)(proxy, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushnumber(luaState,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}


int boolean_arg_boolean_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const gboolean, gboolean *, GError **)) {

const gboolean arg = get_boolean_arg(luaState,-1);

gboolean Return;
GError *error = NULL;


if (!(*functionToCall)(proxy,arg, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushboolean(luaState,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}


int string_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const char *, GError **)){


const char * arg = lua_tolstring(luaState,-1,NULL);

GError *error = NULL;


if (!(*functionToCall) (proxy, arg, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}



/* Cleanup */

closeProxy(proxy);

//indicate one object was returned
return 0;

}


int int_string_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, const gint,const char *,char **, GError **)){

const int arg1 = lua_tonumber(luaState,-2);
const char * arg2 = lua_tolstring(luaState,-1,NULL);

gchar *Return;
GError *error = NULL;


if (!(*functionToCall) (proxy, arg1, arg2, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushstring(luaState,Return);

/* Cleanup */
g_free (Return);
closeProxy(proxy);

//indicate one object was returned
return 1;

}


int int_string_string_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, const gint,const char *,const char *, GError **)){

const int arg1 = lua_tonumber(luaState,-3);
const char * arg2 = lua_tolstring(luaState,-2,NULL);
const char * arg3 = lua_tolstring(luaState,-1,NULL);

GError *error = NULL;


if (!(*functionToCall) (proxy, arg1, arg2, arg3, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}



/* Cleanup */

closeProxy(proxy);

//indicate one object was returned
return 0;

}


int int_arg_string_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, const gint ,char **, GError **)){

const int arg1 = lua_tonumber(luaState,-1);

gchar *Return;
GError *error = NULL;


if (!(*functionToCall) (proxy, arg1, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushstring(luaState,Return);

/* Cleanup */
g_free (Return);
closeProxy(proxy);

//indicate one object was returned
return 1;

}

int int_arg_int_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const gint,gint *, GError **)) {

const gint arg1 = lua_tonumber(luaState,-1);
gint Return;
GError *error = NULL;


if (!(*functionToCall)(proxy,arg1, &Return, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}

//return string
lua_pushnumber(luaState,Return);

/* Cleanup */

closeProxy(proxy);

return 1;


}

int int_string_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod){

const int arg1 = lua_tointeger(luaState,-2);
const char * arg2 = lua_tostring(luaState,-1);


char *string;
gint integer;
gboolean booleanRet;
GError *error = NULL;
int pushCount =0 ;


while (1) {

	// try string
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_INT, arg1, G_TYPE_STRING, arg2, G_TYPE_INVALID,
                          G_TYPE_STRING, &string, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	
	lua_pushstring(luaState,string);
	g_free (string);
	pushCount++;
	break;
	
	}
	// try int
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_INT, arg1, G_TYPE_STRING, arg2, G_TYPE_INVALID,
                          G_TYPE_INT, &integer, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	lua_pushnumber(luaState,integer);
	pushCount++;
	break;
	
	}	
	
	//try boolean 

	 if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_INT, arg1, G_TYPE_STRING, arg2, G_TYPE_INVALID,
                          G_TYPE_BOOLEAN, &booleanRet, G_TYPE_INVALID)){
	// last type to try -clear error outside
	}else {
	
	lua_pushboolean(luaState,booleanRet);
	pushCount++;
	break;
	
	}
	
	
	//give up
	
	// remote method failed:
	// push error message to top of stack
	//PUSH_ERROR_MESSAGE(FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	//lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	
	
	//lets just return nothing if we dont find the right type
	return 0;

}

/* Cleanup */

closeProxy(proxy);

//indicate one object was returned
return pushCount;

}

int int_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod) {

const int arg1 = lua_tointeger(luaState,-1);

char *string;
gint integer;
gboolean booleanRet;
GError *error = NULL;
int pushCount =0 ;


while (1) {

	// try string
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error,G_TYPE_INT, arg1, G_TYPE_INVALID,
                          G_TYPE_STRING, &string, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	
	lua_pushstring(luaState,string);
	g_free (string);
	pushCount++;
	break;
	
	}
	// try int
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error,G_TYPE_INT, arg1, G_TYPE_INVALID,
                          G_TYPE_INT, &integer, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	lua_pushnumber(luaState,integer);
	pushCount++;
	break;
	
	}	
	
	//try boolean 

	 if (!dbus_g_proxy_call (proxy, remoteMethod, &error,G_TYPE_INT, arg1,  G_TYPE_INVALID,
                          G_TYPE_BOOLEAN, &booleanRet, G_TYPE_INVALID)){
	// last type to try -clear error outside
	}else {
	
	lua_pushboolean(luaState,booleanRet);
	pushCount++;
	break;
	
	}
	
	
	//give up
	
	// remote method failed:
	// push error message to top of stack
	//PUSH_ERROR_MESSAGE(FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	//lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	
	
	//lets just return nothing if we dont find the right type
	return 0;

}

/* Cleanup */

closeProxy(proxy);

//indicate one object was returned
return pushCount;

}

int zero_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod) {


char *string;
gint integer;
gboolean booleanRet;
GError *error = NULL;
int pushCount =0 ;


while (1) {

	// try string
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_INVALID,
                          G_TYPE_STRING, &string, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	
	lua_pushstring(luaState,string);
	g_free (string);
	pushCount++;
	break;
	
	}
	// try int
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_INVALID,
                          G_TYPE_INT, &integer, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	lua_pushnumber(luaState,integer);
	pushCount++;
	break;
	
	}	
	
	//try boolean 

	 if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_INVALID,
                          G_TYPE_BOOLEAN, &booleanRet, G_TYPE_INVALID)){
	// last type to try -clear error outside
	}else {
	
	lua_pushboolean(luaState,booleanRet);
	pushCount++;
	break;
	
	}
	
	
	//give up
	
	// remote method failed:
	// push error message to top of stack
	//PUSH_ERROR_MESSAGE(FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	//lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	
	
	//lets just return nothing if we dont find the right type
	return 0;

}

/* Cleanup */

closeProxy(proxy);

//indicate one object was returned
return pushCount;

}

int zero_arg_string_array_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy *, char *** , GError **)){

char ** stringArray;
int sizeOfList;

GError *error = NULL;


if (!(*functionToCall) (proxy, &stringArray, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}


sizeOfList = g_strv_length(stringArray);

lua_newtable(luaState);
int i;
for (i = 1 ; i<=sizeOfList; i++) {
	lua_pushnumber(luaState, i);  
	lua_pushstring(luaState, stringArray[i-1] );
	lua_rawset(luaState, -3);
}



/* Cleanup */
g_strfreev(stringArray);
closeProxy(proxy);

//indicate one object was returned
return 1;



}

int string_arg_variable_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, char * remoteMethod){

const char * arg1 = lua_tostring(luaState,-1);


char *string;
gint integer;
gboolean booleanRet;
GError *error = NULL;
int pushCount =0 ;


while (1) {

	// try string
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_STRING, arg1, G_TYPE_INVALID,
                          G_TYPE_STRING, &string, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	
	lua_pushstring(luaState,string);
	g_free (string);
	pushCount++;
	break;
	
	}
	// try int
	
	if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_STRING, arg1, G_TYPE_INVALID,
                          G_TYPE_INT, &integer, G_TYPE_INVALID)){
	//ignore error and move on
	g_error_free (error);
	error=NULL;
	}else {
	lua_pushnumber(luaState,integer);
	pushCount++;
	break;
	
	}	
	
	//try boolean 

	 if (!dbus_g_proxy_call (proxy, remoteMethod, &error, G_TYPE_STRING, arg1, G_TYPE_INVALID,
                          G_TYPE_BOOLEAN, &booleanRet, G_TYPE_INVALID)){
	// last type to try -clear error outside
	}else {
	
	lua_pushboolean(luaState,booleanRet);
	pushCount++;
	break;
	
	}
	
	
	//give up
	
	// remote method failed:
	// push error message to top of stack
	//PUSH_ERROR_MESSAGE(FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	//lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	
	
	//lets just return nothing if we dont find the right type
	return 0;

}

/* Cleanup */

closeProxy(proxy);

//indicate one object was returned
return pushCount;

}

int boolean_arg_no_return_dbus_call(lua_State * luaState, DBusGProxy * proxy, gboolean (*functionToCall)(DBusGProxy * ,const gboolean, GError **)) {

const gboolean arg = get_boolean_arg(luaState,-1);

GError *error = NULL;


if (!(*functionToCall)(proxy,arg, &error))
{
	// remote method failed:
	// push error message to top of stack
	PUSH_ERROR_MESSAGE(luaState,FUNCTION_CALL_ERROR,error->message);
	// free resources
	g_error_free (error);
	// better free the proxy before we exit
	closeProxy(proxy);
	// signal error 
	lua_error(luaState);
	//return prematurely - shouldn't reach here as we push the error to lua
	return 0;
}


/* Cleanup */

closeProxy(proxy);

return 0;

}


