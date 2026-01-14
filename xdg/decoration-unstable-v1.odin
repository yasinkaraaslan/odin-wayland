#+build linux
package xdg
@(private)
xdg_decoration_unstable_v1_types := []^interface {
	nil,
	&toplevel_decoration_v1_interface,
	&toplevel_interface,
}
/* This interface allows a compositor to announce support for server-side
      decorations.

      A window decoration is a set of window controls as deemed appropriate by
      the party managing them, such as user interface components used to move,
      resize and change a window's state.

      A client can use this protocol to request being decorated by a supporting
      compositor.

      If compositor and client do not negotiate the use of a server-side
      decoration using this protocol, clients continue to self-decorate as they
      see fit.

      Warning! The protocol described in this file is experimental and
      backward incompatible changes may be made. Backward compatible changes
      may be added together with the corresponding interface version bump.
      Backward incompatible changes are done by bumping the version number in
      the protocol and interface names and resetting the interface version.
      Once the protocol is to be declared stable, the 'z' prefix and the
      version number in the protocol and interface names are removed and the
      interface version number is reset. */
decoration_manager_v1 :: struct {}
decoration_manager_v1_set_user_data :: proc "contextless" (decoration_manager_v1_: ^decoration_manager_v1, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)decoration_manager_v1_, user_data)
}

decoration_manager_v1_get_user_data :: proc "contextless" (decoration_manager_v1_: ^decoration_manager_v1) -> rawptr {
   return proxy_get_user_data(cast(^proxy)decoration_manager_v1_)
}

/* Destroy the decoration manager. This doesn't destroy objects created
        with the manager. */
DECORATION_MANAGER_V1_DESTROY :: 0
decoration_manager_v1_destroy :: proc "contextless" (decoration_manager_v1_: ^decoration_manager_v1) {
	proxy_marshal_flags(cast(^proxy)decoration_manager_v1_, DECORATION_MANAGER_V1_DESTROY, nil, proxy_get_version(cast(^proxy)decoration_manager_v1_), 1)
}

/* Create a new decoration object associated with the given toplevel.

        Creating an xdg_toplevel_decoration from an xdg_toplevel which has a
        buffer attached or committed is a client error, and any attempts by a
        client to attach or manipulate a buffer prior to the first
        xdg_toplevel_decoration.configure event must also be treated as
        errors. */
DECORATION_MANAGER_V1_GET_TOPLEVEL_DECORATION :: 1
decoration_manager_v1_get_toplevel_decoration :: proc "contextless" (decoration_manager_v1_: ^decoration_manager_v1, toplevel_: ^toplevel) -> ^toplevel_decoration_v1 {
	ret := proxy_marshal_flags(cast(^proxy)decoration_manager_v1_, DECORATION_MANAGER_V1_GET_TOPLEVEL_DECORATION, &toplevel_decoration_v1_interface, proxy_get_version(cast(^proxy)decoration_manager_v1_), 0, nil, toplevel_)
	return cast(^toplevel_decoration_v1)ret
}

@(private)
decoration_manager_v1_requests := []message {
	{"destroy", "", raw_data(xdg_decoration_unstable_v1_types)[0:]},
	{"get_toplevel_decoration", "no", raw_data(xdg_decoration_unstable_v1_types)[1:]},
}

decoration_manager_v1_interface : interface

/* The decoration object allows the compositor to toggle server-side window
      decorations for a toplevel surface. The client can request to switch to
      another mode.

      The xdg_toplevel_decoration object must be destroyed before its
      xdg_toplevel. */
toplevel_decoration_v1 :: struct {}
toplevel_decoration_v1_set_user_data :: proc "contextless" (toplevel_decoration_v1_: ^toplevel_decoration_v1, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)toplevel_decoration_v1_, user_data)
}

toplevel_decoration_v1_get_user_data :: proc "contextless" (toplevel_decoration_v1_: ^toplevel_decoration_v1) -> rawptr {
   return proxy_get_user_data(cast(^proxy)toplevel_decoration_v1_)
}

/* Switch back to a mode without any server-side decorations at the next
        commit. */
TOPLEVEL_DECORATION_V1_DESTROY :: 0
toplevel_decoration_v1_destroy :: proc "contextless" (toplevel_decoration_v1_: ^toplevel_decoration_v1) {
	proxy_marshal_flags(cast(^proxy)toplevel_decoration_v1_, TOPLEVEL_DECORATION_V1_DESTROY, nil, proxy_get_version(cast(^proxy)toplevel_decoration_v1_), 1)
}

/* Set the toplevel surface decoration mode. This informs the compositor
        that the client prefers the provided decoration mode.

        After requesting a decoration mode, the compositor will respond by
        emitting an xdg_surface.configure event. The client should then update
        its content, drawing it without decorations if the received mode is
        server-side decorations. The client must also acknowledge the configure
        when committing the new content (see xdg_surface.ack_configure).

        The compositor can decide not to use the client's mode and enforce a
        different mode instead.

        Clients whose decoration mode depend on the xdg_toplevel state may send
        a set_mode request in response to an xdg_surface.configure event and wait
        for the next xdg_surface.configure event to prevent unwanted state.
        Such clients are responsible for preventing configure loops and must
        make sure not to send multiple successive set_mode requests with the
        same decoration mode.

        If an invalid mode is supplied by the client, the invalid_mode protocol
        error is raised by the compositor. */
TOPLEVEL_DECORATION_V1_SET_MODE :: 1
toplevel_decoration_v1_set_mode :: proc "contextless" (toplevel_decoration_v1_: ^toplevel_decoration_v1, mode_: toplevel_decoration_v1_mode) {
	proxy_marshal_flags(cast(^proxy)toplevel_decoration_v1_, TOPLEVEL_DECORATION_V1_SET_MODE, nil, proxy_get_version(cast(^proxy)toplevel_decoration_v1_), 0, mode_)
}

/* Unset the toplevel surface decoration mode. This informs the compositor
        that the client doesn't prefer a particular decoration mode.

        This request has the same semantics as set_mode. */
TOPLEVEL_DECORATION_V1_UNSET_MODE :: 2
toplevel_decoration_v1_unset_mode :: proc "contextless" (toplevel_decoration_v1_: ^toplevel_decoration_v1) {
	proxy_marshal_flags(cast(^proxy)toplevel_decoration_v1_, TOPLEVEL_DECORATION_V1_UNSET_MODE, nil, proxy_get_version(cast(^proxy)toplevel_decoration_v1_), 0)
}

toplevel_decoration_v1_listener :: struct {
/* The configure event configures the effective decoration mode. The
        configured state should not be applied immediately. Clients must send an
        ack_configure in response to this event. See xdg_surface.configure and
        xdg_surface.ack_configure for details.

        A configure event can be sent at any time. The specified mode must be
        obeyed by the client. */
	configure : proc "c" (data: rawptr, toplevel_decoration_v1: ^toplevel_decoration_v1, mode_: toplevel_decoration_v1_mode),

}
toplevel_decoration_v1_add_listener :: proc "contextless" (toplevel_decoration_v1_: ^toplevel_decoration_v1, listener: ^toplevel_decoration_v1_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)toplevel_decoration_v1_, cast(^generic_c_call)listener,data)
}
/*  */
toplevel_decoration_v1_error :: enum {
	unconfigured_buffer = 0,
	already_constructed = 1,
	orphaned = 2,
	invalid_mode = 3,
}
/* These values describe window decoration modes. */
toplevel_decoration_v1_mode :: enum {
	client_side = 1,
	server_side = 2,
}
@(private)
toplevel_decoration_v1_requests := []message {
	{"destroy", "", raw_data(xdg_decoration_unstable_v1_types)[0:]},
	{"set_mode", "u", raw_data(xdg_decoration_unstable_v1_types)[0:]},
	{"unset_mode", "", raw_data(xdg_decoration_unstable_v1_types)[0:]},
}

@(private)
toplevel_decoration_v1_events := []message {
	{"configure", "u", raw_data(xdg_decoration_unstable_v1_types)[0:]},
}

toplevel_decoration_v1_interface : interface

@(private)
@(init)
init_interfaces_xdg_decoration_unstable_v1 :: proc "contextless" () {
	decoration_manager_v1_interface.name = "zxdg_decoration_manager_v1"
	decoration_manager_v1_interface.version = 1
	decoration_manager_v1_interface.method_count = 2
	decoration_manager_v1_interface.event_count = 0
	decoration_manager_v1_interface.methods = raw_data(decoration_manager_v1_requests)
	toplevel_decoration_v1_interface.name = "zxdg_toplevel_decoration_v1"
	toplevel_decoration_v1_interface.version = 1
	toplevel_decoration_v1_interface.method_count = 3
	toplevel_decoration_v1_interface.event_count = 1
	toplevel_decoration_v1_interface.methods = raw_data(toplevel_decoration_v1_requests)
	toplevel_decoration_v1_interface.events = raw_data(toplevel_decoration_v1_events)
}

// Functions from libwayland-client
import wl ".."
