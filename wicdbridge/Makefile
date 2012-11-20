# Makefile for wicdbridge - based on code featured in the excellent 
# tutorial for glib-dbus found at :
# http://wiki.maemo.org/Documentation/Maemo_5_Developer_Guide/DBus/Using_GLib_Wrappers_For_D-Bus
# One extra target (which requires xmllint, from package libxml2-utils)
# is available to verify the well-formedness and the structure of the
# interface definition xml file.
#
# Use the 'checkxml' target to run the interface XML through xmllint
# verification. You need to be connected to the Internet in order
# for xmllint to retrieve the DTD from fd.o (unless you setup local
# catalogs, which are not covered here).
# Interface XML name (used in multiple targets)


interface_xml := common/wicd-dbus-interface.xml

# Define a list of pkg-config packages we want to use
pkg_packages := dbus-1 dbus-glib-1 lua5.1

PKG_CFLAGS  := $(shell pkg-config --cflags $(pkg_packages))
PKG_LDFLAGS := $(shell pkg-config --libs $(pkg_packages))
# Add additional flags:
# -g : add debugging symbols
# -Wall : enable most gcc warnings
# -DG_DISABLE_DEPRECATED : disable GLib functions marked as deprecated
ADD_CFLAGS := -g -Wall -DG_DISABLE_DEPRECATED 
# -DNO_DAEMON : do not daemonize the server (on a separate line so can
#               be disabled just by commenting the line)
ADD_LDFLAGS := -Wl,--no-undefined -shared -fPIC
# Combine flags
CFLAGS  := $(PKG_CFLAGS) $(ADD_CFLAGS) $(CFLAGS)
LDFLAGS := $(PKG_LDFLAGS) $(LDFLAGS) $(ADD_LDFLAGS)

COBJFILES := $(patsubst common/%.c,common/%.o,$(wildcard common/*.c))

targets = wicdbridge_wired wicdbridge_wireless wicdbridge_daemon

SHARED_OBJECTS := $(patsubst %,%.so,$(targets))

.PHONY: all clean checkxml
all: $(targets)

# We don not use the implicit pattern rules built into GNU make, since
# they put the LDFLAGS in the wrong location (and linking consequently
# fails sometimes).
#
# NOTE: You could actually collapse the compilation and linking phases
#       together, but this arrangement is much more common.

wicdbridge_wired: wicdbridge_wired.o $(COBJFILES)
	$(CC) $< $(COBJFILES) -o $@.so $(LDFLAGS) 

wicdbridge_wireless: wicdbridge_wireless.o $(COBJFILES)
	$(CC) $< $(COBJFILES) -o $@.so $(LDFLAGS) 

wicdbridge_daemon: wicdbridge_daemon.o $(COBJFILES) wicd-marshallers.o 
	$(CC) $< $(COBJFILES) wicd-marshallers.o  -o $@.so $(LDFLAGS) 

# The server and client depend on the respective implementation source
# files, but also on the common interface as well as the generated
# stub interfaces.

common/%.o: common/%.c wicd-client-stub.h
	$(CC) $(CFLAGS) -DPROGNAME=\"$(basename $@)\" -c $< -o $@ 

wicdbridge_wired.o: wicd_bridge_wired.c wicd-client-stub.h 
	$(CC) $(CFLAGS) -DPROGNAME=\"$(basename $@)\" -c $< -o $@

wicdbridge_wireless.o: wicd_bridge_wireless.c wicd-client-stub.h 
	$(CC) $(CFLAGS) -DPROGNAME=\"$(basename $@)\" -c $< -o $@

wicdbridge_daemon.o: wicd_bridge_daemon.c wicd-client-stub.h wicd-marshallers.h
	$(CC) $(CFLAGS) -DPROGNAME=\"$(basename $@)\" -c $< -o $@
	
wicd-marshallers.o: wicd-marshallers.c
	$(CC) $(CFLAGS) -DPROGNAME=\"$(basename $@)\" -c $< -o $@
	
	
# Special target to run DTD validation on the interface XML. Not run
# automatically (since xmllint is not always available and also needs
# Internet connectivity).
checkxml: $(interface_xml)
	@xmllint -valid -noout $<
	@echo $< checks out ok

wicd-marshallers.c: wicd-marshallers.list
	glib-genmarshal --prefix _wicd_marshal --body $< > $@

wicd-marshallers.h: wicd-marshallers.list
	glib-genmarshal --prefix _wicd_marshal --header $< > $@

# Define a list of generated files so that they can be cleaned as well
cleanfiles := common/wicd-client-stub.h \
		common/wicd-server-stub.h \
		
 
 
# If the interface XML changes, the respective stub interfaces are
# automatically regenerated. Normally this also means that your
# builds fail after this because you are missing implementation
# code.
wicd-server-stub.h: $(interface_xml)
	dbus-binding-tool --prefix=wicd --mode=glib-server \
	$< > $@
 
wicd-client-stub.h: $(interface_xml)
	dbus-binding-tool --prefix=wicd --mode=glib-client \
	$< > common/$@
 
# ... Listing cut for brevity ...
 
clean:
	$(RM) $(targets) $(cleanfiles) *.o *.so common/*.o

install: all
	install -c $(SHARED_OBJECTS) /opt/squeezeplay-modified/share/jive/applets/SetupNetworking/lib/
	install -m 644 -c org.wicd.daemon.service /usr/share/dbus-1/system-services/
	
uninstall: 
	rm $(foreach var,$(SHARED_OBJECTS),/opt/squeezeplay-modified/share/jive/applets/SetupNetworking/lib/$(var))
	rm /usr/share/dbus-1/system-services/org.wicd.daemon.service

