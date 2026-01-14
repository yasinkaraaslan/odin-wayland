#+build linux
package wp
@(private)
tablet_v2_types := []^interface {
	nil,
	nil,
	nil,
	&tablet_seat_v2_interface,
	&wl.seat_interface,
	&tablet_v2_interface,
	&tablet_tool_v2_interface,
	&tablet_pad_v2_interface,
	nil,
	&wl.surface_interface,
	nil,
	nil,
	nil,
	&tablet_v2_interface,
	&wl.surface_interface,
	&tablet_pad_ring_v2_interface,
	&tablet_pad_strip_v2_interface,
	&tablet_pad_dial_v2_interface,
	&tablet_pad_group_v2_interface,
	nil,
	&tablet_v2_interface,
	&wl.surface_interface,
	nil,
	&wl.surface_interface,
}
/* An object that provides access to the graphics tablets available on this
      system. All tablets are associated with a seat, to get access to the
      actual tablets, use wp_tablet_manager.get_tablet_seat. */
tablet_manager_v2 :: struct {}
tablet_manager_v2_set_user_data :: proc "contextless" (tablet_manager_v2_: ^tablet_manager_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_manager_v2_, user_data)
}

tablet_manager_v2_get_user_data :: proc "contextless" (tablet_manager_v2_: ^tablet_manager_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_manager_v2_)
}

/* Get the wp_tablet_seat object for the given seat. This object
	provides access to all graphics tablets in this seat. */
TABLET_MANAGER_V2_GET_TABLET_SEAT :: 0
tablet_manager_v2_get_tablet_seat :: proc "contextless" (tablet_manager_v2_: ^tablet_manager_v2, seat_: ^wl.seat) -> ^tablet_seat_v2 {
	ret := proxy_marshal_flags(cast(^proxy)tablet_manager_v2_, TABLET_MANAGER_V2_GET_TABLET_SEAT, &tablet_seat_v2_interface, proxy_get_version(cast(^proxy)tablet_manager_v2_), 0, nil, seat_)
	return cast(^tablet_seat_v2)ret
}

/* Destroy the wp_tablet_manager object. Objects created from this
	object are unaffected and should be destroyed separately. */
TABLET_MANAGER_V2_DESTROY :: 1
tablet_manager_v2_destroy :: proc "contextless" (tablet_manager_v2_: ^tablet_manager_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_manager_v2_, TABLET_MANAGER_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_manager_v2_), 1)
}

@(private)
tablet_manager_v2_requests := []message {
	{"get_tablet_seat", "no", raw_data(tablet_v2_types)[3:]},
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

tablet_manager_v2_interface : interface

/* An object that provides access to the graphics tablets available on this
      seat. After binding to this interface, the compositor sends a set of
      wp_tablet_seat.tablet_added and wp_tablet_seat.tool_added events. */
tablet_seat_v2 :: struct {}
tablet_seat_v2_set_user_data :: proc "contextless" (tablet_seat_v2_: ^tablet_seat_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_seat_v2_, user_data)
}

tablet_seat_v2_get_user_data :: proc "contextless" (tablet_seat_v2_: ^tablet_seat_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_seat_v2_)
}

/* Destroy the wp_tablet_seat object. Objects created from this
	object are unaffected and should be destroyed separately. */
TABLET_SEAT_V2_DESTROY :: 0
tablet_seat_v2_destroy :: proc "contextless" (tablet_seat_v2_: ^tablet_seat_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_seat_v2_, TABLET_SEAT_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_seat_v2_), 1)
}

tablet_seat_v2_listener :: struct {
/* This event is sent whenever a new tablet becomes available on this
	seat. This event only provides the object id of the tablet, any
	static information about the tablet (device name, vid/pid, etc.) is
	sent through the wp_tablet interface. */
	tablet_added : proc "c" (data: rawptr, tablet_seat_v2: ^tablet_seat_v2) -> ^tablet_v2,

/* This event is sent whenever a tool that has not previously been used
	with a tablet comes into use. This event only provides the object id
	of the tool; any static information about the tool (capabilities,
	type, etc.) is sent through the wp_tablet_tool interface. */
	tool_added : proc "c" (data: rawptr, tablet_seat_v2: ^tablet_seat_v2) -> ^tablet_tool_v2,

/* This event is sent whenever a new pad is known to the system. Typically,
	pads are physically attached to tablets and a pad_added event is
	sent immediately after the wp_tablet_seat.tablet_added.
	However, some standalone pad devices logically attach to tablets at
	runtime, and the client must wait for wp_tablet_pad.enter to know
	the tablet a pad is attached to.

	This event only provides the object id of the pad. All further
	features (buttons, strips, rings) are sent through the wp_tablet_pad
	interface. */
	pad_added : proc "c" (data: rawptr, tablet_seat_v2: ^tablet_seat_v2) -> ^tablet_pad_v2,

}
tablet_seat_v2_add_listener :: proc "contextless" (tablet_seat_v2_: ^tablet_seat_v2, listener: ^tablet_seat_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_seat_v2_, cast(^generic_c_call)listener,data)
}
@(private)
tablet_seat_v2_requests := []message {
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_seat_v2_events := []message {
	{"tablet_added", "n", raw_data(tablet_v2_types)[5:]},
	{"tool_added", "n", raw_data(tablet_v2_types)[6:]},
	{"pad_added", "n", raw_data(tablet_v2_types)[7:]},
}

tablet_seat_v2_interface : interface

/* An object that represents a physical tool that has been, or is
      currently in use with a tablet in this seat. Each wp_tablet_tool
      object stays valid until the client destroys it; the compositor
      reuses the wp_tablet_tool object to indicate that the object's
      respective physical tool has come into proximity of a tablet again.

      A wp_tablet_tool object's relation to a physical tool depends on the
      tablet's ability to report serial numbers. If the tablet supports
      this capability, then the object represents a specific physical tool
      and can be identified even when used on multiple tablets.

      A tablet tool has a number of static characteristics, e.g. tool type,
      hardware_serial and capabilities. These capabilities are sent in an
      event sequence after the wp_tablet_seat.tool_added event before any
      actual events from this tool. This initial event sequence is
      terminated by a wp_tablet_tool.done event.

      Tablet tool events are grouped by wp_tablet_tool.frame events.
      Any events received before a wp_tablet_tool.frame event should be
      considered part of the same hardware state change. */
tablet_tool_v2 :: struct {}
tablet_tool_v2_set_user_data :: proc "contextless" (tablet_tool_v2_: ^tablet_tool_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_tool_v2_, user_data)
}

tablet_tool_v2_get_user_data :: proc "contextless" (tablet_tool_v2_: ^tablet_tool_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_tool_v2_)
}

/* Sets the surface of the cursor used for this tool on the given
	tablet. This request only takes effect if the tool is in proximity
	of one of the requesting client's surfaces or the surface parameter
	is the current pointer surface. If there was a previous surface set
	with this request it is replaced. If surface is NULL, the cursor
	image is hidden.

	The parameters hotspot_x and hotspot_y define the position of the
	pointer surface relative to the pointer location. Its top-left corner
	is always at (x, y) - (hotspot_x, hotspot_y), where (x, y) are the
	coordinates of the pointer location, in surface-local coordinates.

	On surface.attach requests to the pointer surface, hotspot_x and
	hotspot_y are decremented by the x and y parameters passed to the
	request. Attach must be confirmed by wl_surface.commit as usual.

	The hotspot can also be updated by passing the currently set pointer
	surface to this request with new values for hotspot_x and hotspot_y.

	The current and pending input regions of the wl_surface are cleared,
	and wl_surface.set_input_region is ignored until the wl_surface is no
	longer used as the cursor. When the use as a cursor ends, the current
	and pending input regions become undefined, and the wl_surface is
	unmapped.

	This request gives the surface the role of a wp_tablet_tool cursor. A
	surface may only ever be used as the cursor surface for one
	wp_tablet_tool. If the surface already has another role or has
	previously been used as cursor surface for a different tool, a
	protocol error is raised. */
TABLET_TOOL_V2_SET_CURSOR :: 0
tablet_tool_v2_set_cursor :: proc "contextless" (tablet_tool_v2_: ^tablet_tool_v2, serial_: uint, surface_: ^wl.surface, hotspot_x_: int, hotspot_y_: int) {
	proxy_marshal_flags(cast(^proxy)tablet_tool_v2_, TABLET_TOOL_V2_SET_CURSOR, nil, proxy_get_version(cast(^proxy)tablet_tool_v2_), 0, serial_, surface_, hotspot_x_, hotspot_y_)
}

/* This destroys the client's resource for this tool object. */
TABLET_TOOL_V2_DESTROY :: 1
tablet_tool_v2_destroy :: proc "contextless" (tablet_tool_v2_: ^tablet_tool_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_tool_v2_, TABLET_TOOL_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_tool_v2_), 1)
}

tablet_tool_v2_listener :: struct {
/* The tool type is the high-level type of the tool and usually decides
	the interaction expected from this tool.

	This event is sent in the initial burst of events before the
	wp_tablet_tool.done event. */
	type : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, tool_type_: tablet_tool_v2_type),

/* If the physical tool can be identified by a unique 64-bit serial
	number, this event notifies the client of this serial number.

	If multiple tablets are available in the same seat and the tool is
	uniquely identifiable by the serial number, that tool may move
	between tablets.

	Otherwise, if the tool has no serial number and this event is
	missing, the tool is tied to the tablet it first comes into
	proximity with. Even if the physical tool is used on multiple
	tablets, separate wp_tablet_tool objects will be created, one per
	tablet.

	This event is sent in the initial burst of events before the
	wp_tablet_tool.done event. */
	hardware_serial : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, hardware_serial_hi_: uint, hardware_serial_lo_: uint),

/* This event notifies the client of a hardware id available on this tool.

	The hardware id is a device-specific 64-bit id that provides extra
	information about the tool in use, beyond the wl_tool.type
	enumeration. The format of the id is specific to tablets made by
	Wacom Inc. For example, the hardware id of a Wacom Grip
	Pen (a stylus) is 0x802.

	This event is sent in the initial burst of events before the
	wp_tablet_tool.done event. */
	hardware_id_wacom : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, hardware_id_hi_: uint, hardware_id_lo_: uint),

/* This event notifies the client of any capabilities of this tool,
	beyond the main set of x/y axes and tip up/down detection.

	One event is sent for each extra capability available on this tool.

	This event is sent in the initial burst of events before the
	wp_tablet_tool.done event. */
	capability : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, capability_: tablet_tool_v2_capability),

/* This event signals the end of the initial burst of descriptive
	events. A client may consider the static description of the tool to
	be complete and finalize initialization of the tool. */
	done : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2),

/* This event is sent when the tool is removed from the system and will
	send no further events. Should the physical tool come back into
	proximity later, a new wp_tablet_tool object will be created.

	It is compositor-dependent when a tool is removed. A compositor may
	remove a tool on proximity out, tablet removal or any other reason.
	A compositor may also keep a tool alive until shutdown.

	If the tool is currently in proximity, a proximity_out event will be
	sent before the removed event. See wp_tablet_tool.proximity_out for
	the handling of any buttons logically down.

	When this event is received, the client must wp_tablet_tool.destroy
	the object. */
	removed : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2),

/* Notification that this tool is focused on a certain surface.

	This event can be received when the tool has moved from one surface to
	another, or when the tool has come back into proximity above the
	surface.

	If any button is logically down when the tool comes into proximity,
	the respective button event is sent after the proximity_in event but
	within the same frame as the proximity_in event. */
	proximity_in : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, serial_: uint, tablet_: ^tablet_v2, surface_: ^wl.surface),

/* Notification that this tool has either left proximity, or is no
	longer focused on a certain surface.

	When the tablet tool leaves proximity of the tablet, button release
	events are sent for each button that was held down at the time of
	leaving proximity. These events are sent before the proximity_out
	event but within the same wp_tablet.frame.

	If the tool stays within proximity of the tablet, but the focus
	changes from one surface to another, a button release event may not
	be sent until the button is actually released or the tool leaves the
	proximity of the tablet. */
	proximity_out : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2),

/* Sent whenever the tablet tool comes in contact with the surface of the
	tablet.

	If the tool is already in contact with the tablet when entering the
	input region, the client owning said region will receive a
	wp_tablet.proximity_in event, followed by a wp_tablet.down
	event and a wp_tablet.frame event.

	Note that this event describes logical contact, not physical
	contact. On some devices, a compositor may not consider a tool in
	logical contact until a minimum physical pressure threshold is
	exceeded. */
	down : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, serial_: uint),

/* Sent whenever the tablet tool stops making contact with the surface of
	the tablet, or when the tablet tool moves out of the input region
	and the compositor grab (if any) is dismissed.

	If the tablet tool moves out of the input region while in contact
	with the surface of the tablet and the compositor does not have an
	ongoing grab on the surface, the client owning said region will
	receive a wp_tablet.up event, followed by a wp_tablet.proximity_out
	event and a wp_tablet.frame event. If the compositor has an ongoing
	grab on this device, this event sequence is sent whenever the grab
	is dismissed in the future.

	Note that this event describes logical contact, not physical
	contact. On some devices, a compositor may not consider a tool out
	of logical contact until physical pressure falls below a specific
	threshold. */
	up : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2),

/* Sent whenever a tablet tool moves. */
	motion : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, x_: fixed_t, y_: fixed_t),

/* Sent whenever the pressure axis on a tool changes. The value of this
	event is normalized to a value between 0 and 65535.

	Note that pressure may be nonzero even when a tool is not in logical
	contact. See the down and up events for more details. */
	pressure : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, pressure_: uint),

/* Sent whenever the distance axis on a tool changes. The value of this
	event is normalized to a value between 0 and 65535.

	Note that distance may be nonzero even when a tool is not in logical
	contact. See the down and up events for more details. */
	distance : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, distance_: uint),

/* Sent whenever one or both of the tilt axes on a tool change. Each tilt
	value is in degrees, relative to the z-axis of the tablet.
	The angle is positive when the top of a tool tilts along the
	positive x or y axis. */
	tilt : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, tilt_x_: fixed_t, tilt_y_: fixed_t),

/* Sent whenever the z-rotation axis on the tool changes. The
	rotation value is in degrees clockwise from the tool's
	logical neutral position. */
	rotation : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, degrees_: fixed_t),

/* Sent whenever the slider position on the tool changes. The
	value is normalized between -65535 and 65535, with 0 as the logical
	neutral position of the slider.

	The slider is available on e.g. the Wacom Airbrush tool. */
	slider : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, position_: int),

/* Sent whenever the wheel on the tool emits an event. This event
	contains two values for the same axis change. The degrees value is
	in the same orientation as the wl_pointer.vertical_scroll axis. The
	clicks value is in discrete logical clicks of the mouse wheel. This
	value may be zero if the movement of the wheel was less
	than one logical click.

	Clients should choose either value and avoid mixing degrees and
	clicks. The compositor may accumulate values smaller than a logical
	click and emulate click events when a certain threshold is met.
	Thus, wl_tablet_tool.wheel events with non-zero clicks values may
	have different degrees values. */
	wheel : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, degrees_: fixed_t, clicks_: int),

/* Sent whenever a button on the tool is pressed or released.

	If a button is held down when the tool moves in or out of proximity,
	button events are generated by the compositor. See
	wp_tablet_tool.proximity_in and wp_tablet_tool.proximity_out for
	details. */
	button : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, serial_: uint, button_: uint, state_: tablet_tool_v2_button_state),

/* Marks the end of a series of axis and/or button updates from the
	tablet. The Wayland protocol requires axis updates to be sent
	sequentially, however all events within a frame should be considered
	one hardware event. */
	frame : proc "c" (data: rawptr, tablet_tool_v2: ^tablet_tool_v2, time_: uint),

}
tablet_tool_v2_add_listener :: proc "contextless" (tablet_tool_v2_: ^tablet_tool_v2, listener: ^tablet_tool_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_tool_v2_, cast(^generic_c_call)listener,data)
}
/* Describes the physical type of a tool. The physical type of a tool
	generally defines its base usage.

	The mouse tool represents a mouse-shaped tool that is not a relative
	device but bound to the tablet's surface, providing absolute
	coordinates.

	The lens tool is a mouse-shaped tool with an attached lens to
	provide precision focus. */
tablet_tool_v2_type :: enum {
	pen = 0x140,
	eraser = 0x141,
	brush = 0x142,
	pencil = 0x143,
	airbrush = 0x144,
	finger = 0x145,
	mouse = 0x146,
	lens = 0x147,
}
/* Describes extra capabilities on a tablet.

	Any tool must provide x and y values, extra axes are
	device-specific. */
tablet_tool_v2_capability :: enum {
	tilt = 1,
	pressure = 2,
	distance = 3,
	rotation = 4,
	slider = 5,
	wheel = 6,
}
/* Describes the physical state of a button that produced the button event. */
tablet_tool_v2_button_state :: enum {
	released = 0,
	pressed = 1,
}
/*  */
tablet_tool_v2_error :: enum {
	role = 0,
}
@(private)
tablet_tool_v2_requests := []message {
	{"set_cursor", "u?oii", raw_data(tablet_v2_types)[8:]},
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_tool_v2_events := []message {
	{"type", "u", raw_data(tablet_v2_types)[0:]},
	{"hardware_serial", "uu", raw_data(tablet_v2_types)[0:]},
	{"hardware_id_wacom", "uu", raw_data(tablet_v2_types)[0:]},
	{"capability", "u", raw_data(tablet_v2_types)[0:]},
	{"done", "", raw_data(tablet_v2_types)[0:]},
	{"removed", "", raw_data(tablet_v2_types)[0:]},
	{"proximity_in", "uoo", raw_data(tablet_v2_types)[12:]},
	{"proximity_out", "", raw_data(tablet_v2_types)[0:]},
	{"down", "u", raw_data(tablet_v2_types)[0:]},
	{"up", "", raw_data(tablet_v2_types)[0:]},
	{"motion", "ff", raw_data(tablet_v2_types)[0:]},
	{"pressure", "u", raw_data(tablet_v2_types)[0:]},
	{"distance", "u", raw_data(tablet_v2_types)[0:]},
	{"tilt", "ff", raw_data(tablet_v2_types)[0:]},
	{"rotation", "f", raw_data(tablet_v2_types)[0:]},
	{"slider", "i", raw_data(tablet_v2_types)[0:]},
	{"wheel", "fi", raw_data(tablet_v2_types)[0:]},
	{"button", "uuu", raw_data(tablet_v2_types)[0:]},
	{"frame", "u", raw_data(tablet_v2_types)[0:]},
}

tablet_tool_v2_interface : interface

/* The wp_tablet interface represents one graphics tablet device. The
      tablet interface itself does not generate events; all events are
      generated by wp_tablet_tool objects when in proximity above a tablet.

      A tablet has a number of static characteristics, e.g. device name and
      pid/vid. These capabilities are sent in an event sequence after the
      wp_tablet_seat.tablet_added event. This initial event sequence is
      terminated by a wp_tablet.done event. */
tablet_v2 :: struct {}
tablet_v2_set_user_data :: proc "contextless" (tablet_v2_: ^tablet_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_v2_, user_data)
}

tablet_v2_get_user_data :: proc "contextless" (tablet_v2_: ^tablet_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_v2_)
}

/* This destroys the client's resource for this tablet object. */
TABLET_V2_DESTROY :: 0
tablet_v2_destroy :: proc "contextless" (tablet_v2_: ^tablet_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_v2_, TABLET_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_v2_), 1)
}

tablet_v2_listener :: struct {
/* A descriptive name for the tablet device.

	If the device has no descriptive name, this event is not sent.

	This event is sent in the initial burst of events before the
        wp_tablet.done event. */
	name : proc "c" (data: rawptr, tablet_v2: ^tablet_v2, name_: cstring),

/* The vendor and product IDs for the tablet device.

	The interpretation of the id depends on the wp_tablet.bustype.
	Prior to version v2 of this protocol, the id was implied to be a USB
	vendor and product ID. If no wp_tablet.bustype is sent, the ID
	is to be interpreted as USB vendor and product ID.

	If the device has no vendor/product ID, this event is not sent.
	This can happen for virtual devices or non-USB devices, for instance.

	This event is sent in the initial burst of events before the
	wp_tablet.done event. */
	id : proc "c" (data: rawptr, tablet_v2: ^tablet_v2, vid_: uint, pid_: uint),

/* A system-specific device path that indicates which device is behind
	this wp_tablet. This information may be used to gather additional
	information about the device, e.g. through libwacom.

	A device may have more than one device path. If so, multiple
	wp_tablet.path events are sent. A device may be emulated and not
	have a device path, and in that case this event will not be sent.

	The format of the path is unspecified, it may be a device node, a
	sysfs path, or some other identifier. It is up to the client to
	identify the string provided.

	This event is sent in the initial burst of events before the
	wp_tablet.done event. */
	path : proc "c" (data: rawptr, tablet_v2: ^tablet_v2, path_: cstring),

/* This event is sent immediately to signal the end of the initial
	burst of descriptive events. A client may consider the static
	description of the tablet to be complete and finalize initialization
	of the tablet. */
	done : proc "c" (data: rawptr, tablet_v2: ^tablet_v2),

/* Sent when the tablet has been removed from the system. When a tablet
	is removed, some tools may be removed.

	When this event is received, the client must wp_tablet.destroy
	the object. */
	removed : proc "c" (data: rawptr, tablet_v2: ^tablet_v2),

/* The bustype argument is one of the BUS_ defines in the Linux kernel's
	linux/input.h

	If the device has no known bustype or the bustype cannot be
	queried, this event is not sent.

	This event is sent in the initial burst of events before the
	wp_tablet.done event. */
	bustype : proc "c" (data: rawptr, tablet_v2: ^tablet_v2, bustype_: tablet_v2_bustype),

}
tablet_v2_add_listener :: proc "contextless" (tablet_v2_: ^tablet_v2, listener: ^tablet_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_v2_, cast(^generic_c_call)listener,data)
}
/* Describes the bus types this tablet is connected to. */
tablet_v2_bustype :: enum {
	usb = 3,
	bluetooth = 5,
	virtual = 6,
	serial = 17,
	i2c = 24,
}
@(private)
tablet_v2_requests := []message {
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_v2_events := []message {
	{"name", "s", raw_data(tablet_v2_types)[0:]},
	{"id", "uu", raw_data(tablet_v2_types)[0:]},
	{"path", "s", raw_data(tablet_v2_types)[0:]},
	{"done", "", raw_data(tablet_v2_types)[0:]},
	{"removed", "", raw_data(tablet_v2_types)[0:]},
	{"bustype", "2u", raw_data(tablet_v2_types)[0:]},
}

tablet_v2_interface : interface

/* A circular interaction area, such as the touch ring on the Wacom Intuos
      Pro series tablets.

      Events on a ring are logically grouped by the wl_tablet_pad_ring.frame
      event. */
tablet_pad_ring_v2 :: struct {}
tablet_pad_ring_v2_set_user_data :: proc "contextless" (tablet_pad_ring_v2_: ^tablet_pad_ring_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_pad_ring_v2_, user_data)
}

tablet_pad_ring_v2_get_user_data :: proc "contextless" (tablet_pad_ring_v2_: ^tablet_pad_ring_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_pad_ring_v2_)
}

/* Request that the compositor use the provided feedback string
	associated with this ring. This request should be issued immediately
	after a wp_tablet_pad_group.mode_switch event from the corresponding
	group is received, or whenever the ring is mapped to a different
	action. See wp_tablet_pad_group.mode_switch for more details.

	Clients are encouraged to provide context-aware descriptions for
	the actions associated with the ring; compositors may use this
	information to offer visual feedback about the button layout
	(eg. on-screen displays).

	The provided string 'description' is a UTF-8 encoded string to be
	associated with this ring, and is considered user-visible; general
	internationalization rules apply.

	The serial argument will be that of the last
	wp_tablet_pad_group.mode_switch event received for the group of this
	ring. Requests providing other serials than the most recent one will be
	ignored. */
TABLET_PAD_RING_V2_SET_FEEDBACK :: 0
tablet_pad_ring_v2_set_feedback :: proc "contextless" (tablet_pad_ring_v2_: ^tablet_pad_ring_v2, description_: cstring, serial_: uint) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_ring_v2_, TABLET_PAD_RING_V2_SET_FEEDBACK, nil, proxy_get_version(cast(^proxy)tablet_pad_ring_v2_), 0, description_, serial_)
}

/* This destroys the client's resource for this ring object. */
TABLET_PAD_RING_V2_DESTROY :: 1
tablet_pad_ring_v2_destroy :: proc "contextless" (tablet_pad_ring_v2_: ^tablet_pad_ring_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_ring_v2_, TABLET_PAD_RING_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_pad_ring_v2_), 1)
}

tablet_pad_ring_v2_listener :: struct {
/* Source information for ring events.

	This event does not occur on its own. It is sent before a
	wp_tablet_pad_ring.frame event and carries the source information
	for all events within that frame.

	The source specifies how this event was generated. If the source is
	wp_tablet_pad_ring.source.finger, a wp_tablet_pad_ring.stop event
	will be sent when the user lifts the finger off the device.

	This event is optional. If the source is unknown for an interaction,
	no event is sent. */
	source : proc "c" (data: rawptr, tablet_pad_ring_v2: ^tablet_pad_ring_v2, source_: tablet_pad_ring_v2_source),

/* Sent whenever the angle on a ring changes.

	The angle is provided in degrees clockwise from the logical
	north of the ring in the pad's current rotation. */
	angle : proc "c" (data: rawptr, tablet_pad_ring_v2: ^tablet_pad_ring_v2, degrees_: fixed_t),

/* Stop notification for ring events.

	For some wp_tablet_pad_ring.source types, a wp_tablet_pad_ring.stop
	event is sent to notify a client that the interaction with the ring
	has terminated. This enables the client to implement kinetic scrolling.
	See the wp_tablet_pad_ring.source documentation for information on
	when this event may be generated.

	Any wp_tablet_pad_ring.angle events with the same source after this
	event should be considered as the start of a new interaction. */
	stop : proc "c" (data: rawptr, tablet_pad_ring_v2: ^tablet_pad_ring_v2),

/* Indicates the end of a set of ring events that logically belong
	together. A client is expected to accumulate the data in all events
	within the frame before proceeding.

	All wp_tablet_pad_ring events before a wp_tablet_pad_ring.frame event belong
	logically together. For example, on termination of a finger interaction
	on a ring the compositor will send a wp_tablet_pad_ring.source event,
	a wp_tablet_pad_ring.stop event and a wp_tablet_pad_ring.frame event.

	A wp_tablet_pad_ring.frame event is sent for every logical event
	group, even if the group only contains a single wp_tablet_pad_ring
	event. Specifically, a client may get a sequence: angle, frame,
	angle, frame, etc. */
	frame : proc "c" (data: rawptr, tablet_pad_ring_v2: ^tablet_pad_ring_v2, time_: uint),

}
tablet_pad_ring_v2_add_listener :: proc "contextless" (tablet_pad_ring_v2_: ^tablet_pad_ring_v2, listener: ^tablet_pad_ring_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_pad_ring_v2_, cast(^generic_c_call)listener,data)
}
/* Describes the source types for ring events. This indicates to the
	client how a ring event was physically generated; a client may
	adjust the user interface accordingly. For example, events
	from a "finger" source may trigger kinetic scrolling. */
tablet_pad_ring_v2_source :: enum {
	finger = 1,
}
@(private)
tablet_pad_ring_v2_requests := []message {
	{"set_feedback", "su", raw_data(tablet_v2_types)[0:]},
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_pad_ring_v2_events := []message {
	{"source", "u", raw_data(tablet_v2_types)[0:]},
	{"angle", "f", raw_data(tablet_v2_types)[0:]},
	{"stop", "", raw_data(tablet_v2_types)[0:]},
	{"frame", "u", raw_data(tablet_v2_types)[0:]},
}

tablet_pad_ring_v2_interface : interface

/* A linear interaction area, such as the strips found in Wacom Cintiq
      models.

      Events on a strip are logically grouped by the wl_tablet_pad_strip.frame
      event. */
tablet_pad_strip_v2 :: struct {}
tablet_pad_strip_v2_set_user_data :: proc "contextless" (tablet_pad_strip_v2_: ^tablet_pad_strip_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_pad_strip_v2_, user_data)
}

tablet_pad_strip_v2_get_user_data :: proc "contextless" (tablet_pad_strip_v2_: ^tablet_pad_strip_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_pad_strip_v2_)
}

/* Requests the compositor to use the provided feedback string
	associated with this strip. This request should be issued immediately
	after a wp_tablet_pad_group.mode_switch event from the corresponding
	group is received, or whenever the strip is mapped to a different
	action. See wp_tablet_pad_group.mode_switch for more details.

	Clients are encouraged to provide context-aware descriptions for
	the actions associated with the strip, and compositors may use this
	information to offer visual feedback about the button layout
	(eg. on-screen displays).

	The provided string 'description' is a UTF-8 encoded string to be
	associated with this ring, and is considered user-visible; general
	internationalization rules apply.

	The serial argument will be that of the last
	wp_tablet_pad_group.mode_switch event received for the group of this
	strip. Requests providing other serials than the most recent one will be
	ignored. */
TABLET_PAD_STRIP_V2_SET_FEEDBACK :: 0
tablet_pad_strip_v2_set_feedback :: proc "contextless" (tablet_pad_strip_v2_: ^tablet_pad_strip_v2, description_: cstring, serial_: uint) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_strip_v2_, TABLET_PAD_STRIP_V2_SET_FEEDBACK, nil, proxy_get_version(cast(^proxy)tablet_pad_strip_v2_), 0, description_, serial_)
}

/* This destroys the client's resource for this strip object. */
TABLET_PAD_STRIP_V2_DESTROY :: 1
tablet_pad_strip_v2_destroy :: proc "contextless" (tablet_pad_strip_v2_: ^tablet_pad_strip_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_strip_v2_, TABLET_PAD_STRIP_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_pad_strip_v2_), 1)
}

tablet_pad_strip_v2_listener :: struct {
/* Source information for strip events.

	This event does not occur on its own. It is sent before a
	wp_tablet_pad_strip.frame event and carries the source information
	for all events within that frame.

	The source specifies how this event was generated. If the source is
	wp_tablet_pad_strip.source.finger, a wp_tablet_pad_strip.stop event
	will be sent when the user lifts their finger off the device.

	This event is optional. If the source is unknown for an interaction,
	no event is sent. */
	source : proc "c" (data: rawptr, tablet_pad_strip_v2: ^tablet_pad_strip_v2, source_: tablet_pad_strip_v2_source),

/* Sent whenever the position on a strip changes.

	The position is normalized to a range of [0, 65535], the 0-value
	represents the top-most and/or left-most position of the strip in
	the pad's current rotation. */
	position : proc "c" (data: rawptr, tablet_pad_strip_v2: ^tablet_pad_strip_v2, position_: uint),

/* Stop notification for strip events.

	For some wp_tablet_pad_strip.source types, a wp_tablet_pad_strip.stop
	event is sent to notify a client that the interaction with the strip
	has terminated. This enables the client to implement kinetic
	scrolling. See the wp_tablet_pad_strip.source documentation for
	information on when this event may be generated.

	Any wp_tablet_pad_strip.position events with the same source after this
	event should be considered as the start of a new interaction. */
	stop : proc "c" (data: rawptr, tablet_pad_strip_v2: ^tablet_pad_strip_v2),

/* Indicates the end of a set of events that represent one logical
	hardware strip event. A client is expected to accumulate the data
	in all events within the frame before proceeding.

	All wp_tablet_pad_strip events before a wp_tablet_pad_strip.frame event belong
	logically together. For example, on termination of a finger interaction
	on a strip the compositor will send a wp_tablet_pad_strip.source event,
	a wp_tablet_pad_strip.stop event and a wp_tablet_pad_strip.frame
	event.

	A wp_tablet_pad_strip.frame event is sent for every logical event
	group, even if the group only contains a single wp_tablet_pad_strip
	event. Specifically, a client may get a sequence: position, frame,
	position, frame, etc. */
	frame : proc "c" (data: rawptr, tablet_pad_strip_v2: ^tablet_pad_strip_v2, time_: uint),

}
tablet_pad_strip_v2_add_listener :: proc "contextless" (tablet_pad_strip_v2_: ^tablet_pad_strip_v2, listener: ^tablet_pad_strip_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_pad_strip_v2_, cast(^generic_c_call)listener,data)
}
/* Describes the source types for strip events. This indicates to the
	client how a strip event was physically generated; a client may
	adjust the user interface accordingly. For example, events
	from a "finger" source may trigger kinetic scrolling. */
tablet_pad_strip_v2_source :: enum {
	finger = 1,
}
@(private)
tablet_pad_strip_v2_requests := []message {
	{"set_feedback", "su", raw_data(tablet_v2_types)[0:]},
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_pad_strip_v2_events := []message {
	{"source", "u", raw_data(tablet_v2_types)[0:]},
	{"position", "u", raw_data(tablet_v2_types)[0:]},
	{"stop", "", raw_data(tablet_v2_types)[0:]},
	{"frame", "u", raw_data(tablet_v2_types)[0:]},
}

tablet_pad_strip_v2_interface : interface

/* A pad group describes a distinct (sub)set of buttons, rings and strips
      present in the tablet. The criteria of this grouping is usually positional,
      eg. if a tablet has buttons on the left and right side, 2 groups will be
      presented. The physical arrangement of groups is undisclosed and may
      change on the fly.

      Pad groups will announce their features during pad initialization. Between
      the corresponding wp_tablet_pad.group event and wp_tablet_pad_group.done, the
      pad group will announce the buttons, rings and strips contained in it,
      plus the number of supported modes.

      Modes are a mechanism to allow multiple groups of actions for every element
      in the pad group. The number of groups and available modes in each is
      persistent across device plugs. The current mode is user-switchable, it
      will be announced through the wp_tablet_pad_group.mode_switch event both
      whenever it is switched, and after wp_tablet_pad.enter.

      The current mode logically applies to all elements in the pad group,
      although it is at clients' discretion whether to actually perform different
      actions, and/or issue the respective .set_feedback requests to notify the
      compositor. See the wp_tablet_pad_group.mode_switch event for more details. */
tablet_pad_group_v2 :: struct {}
tablet_pad_group_v2_set_user_data :: proc "contextless" (tablet_pad_group_v2_: ^tablet_pad_group_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_pad_group_v2_, user_data)
}

tablet_pad_group_v2_get_user_data :: proc "contextless" (tablet_pad_group_v2_: ^tablet_pad_group_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_pad_group_v2_)
}

/* Destroy the wp_tablet_pad_group object. Objects created from this object
	are unaffected and should be destroyed separately. */
TABLET_PAD_GROUP_V2_DESTROY :: 0
tablet_pad_group_v2_destroy :: proc "contextless" (tablet_pad_group_v2_: ^tablet_pad_group_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_group_v2_, TABLET_PAD_GROUP_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_pad_group_v2_), 1)
}

tablet_pad_group_v2_listener :: struct {
/* Sent on wp_tablet_pad_group initialization to announce the available
	buttons in the group. Button indices start at 0, a button may only be
	in one group at a time.

	This event is first sent in the initial burst of events before the
	wp_tablet_pad_group.done event.

	Some buttons are reserved by the compositor. These buttons may not be
	assigned to any wp_tablet_pad_group. Compositors may broadcast this
	event in the case of changes to the mapping of these reserved buttons.
	If the compositor happens to reserve all buttons in a group, this event
	will be sent with an empty array. */
	buttons : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2, buttons_: array),

/* Sent on wp_tablet_pad_group initialization to announce available rings.
	One event is sent for each ring available on this pad group.

	This event is sent in the initial burst of events before the
	wp_tablet_pad_group.done event. */
	ring : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2) -> ^tablet_pad_ring_v2,

/* Sent on wp_tablet_pad initialization to announce available strips.
	One event is sent for each strip available on this pad group.

	This event is sent in the initial burst of events before the
	wp_tablet_pad_group.done event. */
	strip : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2) -> ^tablet_pad_strip_v2,

/* Sent on wp_tablet_pad_group initialization to announce that the pad
	group may switch between modes. A client may use a mode to store a
	specific configuration for buttons, rings and strips and use the
	wl_tablet_pad_group.mode_switch event to toggle between these
	configurations. Mode indices start at 0.

	Switching modes is compositor-dependent. See the
	wp_tablet_pad_group.mode_switch event for more details.

	This event is sent in the initial burst of events before the
	wp_tablet_pad_group.done event. This event is only sent when more than
	more than one mode is available. */
	modes : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2, modes_: uint),

/* This event is sent immediately to signal the end of the initial
	burst of descriptive events. A client may consider the static
	description of the tablet to be complete and finalize initialization
	of the tablet group. */
	done : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2),

/* Notification that the mode was switched.

	A mode applies to all buttons, rings, strips and dials in a group
	simultaneously, but a client is not required to assign different actions
	for each mode. For example, a client may have mode-specific button
	mappings but map the ring to vertical scrolling in all modes. Mode
	indices start at 0.

	Switching modes is compositor-dependent. The compositor may provide
	visual cues to the user about the mode, e.g. by toggling LEDs on
	the tablet device. Mode-switching may be software-controlled or
	controlled by one or more physical buttons. For example, on a Wacom
	Intuos Pro, the button inside the ring may be assigned to switch
	between modes.

	The compositor will also send this event after wp_tablet_pad.enter on
	each group in order to notify of the current mode. Groups that only
	feature one mode will use mode=0 when emitting this event.

	If a button action in the new mode differs from the action in the
	previous mode, the client should immediately issue a
	wp_tablet_pad.set_feedback request for each changed button.

	If a ring, strip or dial action in the new mode differs from the action
	in the previous mode, the client should immediately issue a
	wp_tablet_ring.set_feedback, wp_tablet_strip.set_feedback or
	wp_tablet_dial.set_feedback request for each changed ring, strip or dial. */
	mode_switch : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2, time_: uint, serial_: uint, mode_: uint),

/* Sent on wp_tablet_pad initialization to announce available dials.
	One event is sent for each dial available on this pad group.

	This event is sent in the initial burst of events before the
	wp_tablet_pad_group.done event. */
	dial : proc "c" (data: rawptr, tablet_pad_group_v2: ^tablet_pad_group_v2) -> ^tablet_pad_dial_v2,

}
tablet_pad_group_v2_add_listener :: proc "contextless" (tablet_pad_group_v2_: ^tablet_pad_group_v2, listener: ^tablet_pad_group_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_pad_group_v2_, cast(^generic_c_call)listener,data)
}
@(private)
tablet_pad_group_v2_requests := []message {
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_pad_group_v2_events := []message {
	{"buttons", "a", raw_data(tablet_v2_types)[0:]},
	{"ring", "n", raw_data(tablet_v2_types)[15:]},
	{"strip", "n", raw_data(tablet_v2_types)[16:]},
	{"modes", "u", raw_data(tablet_v2_types)[0:]},
	{"done", "", raw_data(tablet_v2_types)[0:]},
	{"mode_switch", "uuu", raw_data(tablet_v2_types)[0:]},
	{"dial", "2n", raw_data(tablet_v2_types)[17:]},
}

tablet_pad_group_v2_interface : interface

/* A pad device is a set of buttons, rings, strips and dials
      usually physically present on the tablet device itself. Some
      exceptions exist where the pad device is physically detached, e.g. the
      Wacom ExpressKey Remote.

      Pad devices have no axes that control the cursor and are generally
      auxiliary devices to the tool devices used on the tablet surface.

      A pad device has a number of static characteristics, e.g. the number
      of rings. These capabilities are sent in an event sequence after the
      wp_tablet_seat.pad_added event before any actual events from this pad.
      This initial event sequence is terminated by a wp_tablet_pad.done
      event.

      All pad features (buttons, rings, strips and dials) are logically divided into
      groups and all pads have at least one group. The available groups are
      notified through the wp_tablet_pad.group event; the compositor will
      emit one event per group before emitting wp_tablet_pad.done.

      Groups may have multiple modes. Modes allow clients to map multiple
      actions to a single pad feature. Only one mode can be active per group,
      although different groups may have different active modes. */
tablet_pad_v2 :: struct {}
tablet_pad_v2_set_user_data :: proc "contextless" (tablet_pad_v2_: ^tablet_pad_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_pad_v2_, user_data)
}

tablet_pad_v2_get_user_data :: proc "contextless" (tablet_pad_v2_: ^tablet_pad_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_pad_v2_)
}

/* Requests the compositor to use the provided feedback string
	associated with this button. This request should be issued immediately
	after a wp_tablet_pad_group.mode_switch event from the corresponding
	group is received, or whenever a button is mapped to a different
	action. See wp_tablet_pad_group.mode_switch for more details.

	Clients are encouraged to provide context-aware descriptions for
	the actions associated with each button, and compositors may use
	this information to offer visual feedback on the button layout
	(e.g. on-screen displays).

	Button indices start at 0. Setting the feedback string on a button
	that is reserved by the compositor (i.e. not belonging to any
	wp_tablet_pad_group) does not generate an error but the compositor
	is free to ignore the request.

	The provided string 'description' is a UTF-8 encoded string to be
	associated with this ring, and is considered user-visible; general
	internationalization rules apply.

	The serial argument will be that of the last
	wp_tablet_pad_group.mode_switch event received for the group of this
	button. Requests providing other serials than the most recent one will
	be ignored. */
TABLET_PAD_V2_SET_FEEDBACK :: 0
tablet_pad_v2_set_feedback :: proc "contextless" (tablet_pad_v2_: ^tablet_pad_v2, button_: uint, description_: cstring, serial_: uint) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_v2_, TABLET_PAD_V2_SET_FEEDBACK, nil, proxy_get_version(cast(^proxy)tablet_pad_v2_), 0, button_, description_, serial_)
}

/* Destroy the wp_tablet_pad object. Objects created from this object
	are unaffected and should be destroyed separately. */
TABLET_PAD_V2_DESTROY :: 1
tablet_pad_v2_destroy :: proc "contextless" (tablet_pad_v2_: ^tablet_pad_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_v2_, TABLET_PAD_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_pad_v2_), 1)
}

tablet_pad_v2_listener :: struct {
/* Sent on wp_tablet_pad initialization to announce available groups.
	One event is sent for each pad group available.

	This event is sent in the initial burst of events before the
	wp_tablet_pad.done event. At least one group will be announced. */
	group : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2) -> ^tablet_pad_group_v2,

/* A system-specific device path that indicates which device is behind
	this wp_tablet_pad. This information may be used to gather additional
	information about the device, e.g. through libwacom.

	The format of the path is unspecified, it may be a device node, a
	sysfs path, or some other identifier. It is up to the client to
	identify the string provided.

	This event is sent in the initial burst of events before the
	wp_tablet_pad.done event. */
	path : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2, path_: cstring),

/* Sent on wp_tablet_pad initialization to announce the available
	buttons.

	This event is sent in the initial burst of events before the
	wp_tablet_pad.done event. This event is only sent when at least one
	button is available. */
	buttons : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2, buttons_: uint),

/* This event signals the end of the initial burst of descriptive
	events. A client may consider the static description of the pad to
	be complete and finalize initialization of the pad. */
	done : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2),

/* Sent whenever the physical state of a button changes. */
	button : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2, time_: uint, button_: uint, state_: tablet_pad_v2_button_state),

/* Notification that this pad is focused on the specified surface. */
	enter : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2, serial_: uint, tablet_: ^tablet_v2, surface_: ^wl.surface),

/* Notification that this pad is no longer focused on the specified
	surface. */
	leave : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2, serial_: uint, surface_: ^wl.surface),

/* Sent when the pad has been removed from the system. When a tablet
	is removed its pad(s) will be removed too.

	When this event is received, the client must destroy all rings, strips
	and groups that were offered by this pad, and issue wp_tablet_pad.destroy
	the pad itself. */
	removed : proc "c" (data: rawptr, tablet_pad_v2: ^tablet_pad_v2),

}
tablet_pad_v2_add_listener :: proc "contextless" (tablet_pad_v2_: ^tablet_pad_v2, listener: ^tablet_pad_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_pad_v2_, cast(^generic_c_call)listener,data)
}
/* Describes the physical state of a button that caused the button
	event. */
tablet_pad_v2_button_state :: enum {
	released = 0,
	pressed = 1,
}
@(private)
tablet_pad_v2_requests := []message {
	{"set_feedback", "usu", raw_data(tablet_v2_types)[0:]},
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_pad_v2_events := []message {
	{"group", "n", raw_data(tablet_v2_types)[18:]},
	{"path", "s", raw_data(tablet_v2_types)[0:]},
	{"buttons", "u", raw_data(tablet_v2_types)[0:]},
	{"done", "", raw_data(tablet_v2_types)[0:]},
	{"button", "uuu", raw_data(tablet_v2_types)[0:]},
	{"enter", "uoo", raw_data(tablet_v2_types)[19:]},
	{"leave", "uo", raw_data(tablet_v2_types)[22:]},
	{"removed", "", raw_data(tablet_v2_types)[0:]},
}

tablet_pad_v2_interface : interface

/* A rotary control, e.g. a dial or a wheel.

      Events on a dial are logically grouped by the wl_tablet_pad_dial.frame
      event. */
tablet_pad_dial_v2 :: struct {}
tablet_pad_dial_v2_set_user_data :: proc "contextless" (tablet_pad_dial_v2_: ^tablet_pad_dial_v2, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)tablet_pad_dial_v2_, user_data)
}

tablet_pad_dial_v2_get_user_data :: proc "contextless" (tablet_pad_dial_v2_: ^tablet_pad_dial_v2) -> rawptr {
   return proxy_get_user_data(cast(^proxy)tablet_pad_dial_v2_)
}

/* Requests the compositor to use the provided feedback string
	associated with this dial. This request should be issued immediately
	after a wp_tablet_pad_group.mode_switch event from the corresponding
	group is received, or whenever the dial is mapped to a different
	action. See wp_tablet_pad_group.mode_switch for more details.

	Clients are encouraged to provide context-aware descriptions for
	the actions associated with the dial, and compositors may use this
	information to offer visual feedback about the button layout
	(eg. on-screen displays).

	The provided string 'description' is a UTF-8 encoded string to be
	associated with this ring, and is considered user-visible; general
	internationalization rules apply.

	The serial argument will be that of the last
	wp_tablet_pad_group.mode_switch event received for the group of this
	dial. Requests providing other serials than the most recent one will be
	ignored. */
TABLET_PAD_DIAL_V2_SET_FEEDBACK :: 0
tablet_pad_dial_v2_set_feedback :: proc "contextless" (tablet_pad_dial_v2_: ^tablet_pad_dial_v2, description_: cstring, serial_: uint) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_dial_v2_, TABLET_PAD_DIAL_V2_SET_FEEDBACK, nil, proxy_get_version(cast(^proxy)tablet_pad_dial_v2_), 0, description_, serial_)
}

/* This destroys the client's resource for this dial object. */
TABLET_PAD_DIAL_V2_DESTROY :: 1
tablet_pad_dial_v2_destroy :: proc "contextless" (tablet_pad_dial_v2_: ^tablet_pad_dial_v2) {
	proxy_marshal_flags(cast(^proxy)tablet_pad_dial_v2_, TABLET_PAD_DIAL_V2_DESTROY, nil, proxy_get_version(cast(^proxy)tablet_pad_dial_v2_), 1)
}

tablet_pad_dial_v2_listener :: struct {
/* Sent whenever the position on a dial changes.

	This event carries the wheel delta as multiples or fractions
	of 120 with each multiple of 120 representing one logical wheel detent.
	For example, an axis_value120 of 30 is one quarter of
	a logical wheel step in the positive direction, a value120 of
	-240 are two logical wheel steps in the negative direction within the
	same hardware event. See the wl_pointer.axis_value120 for more details.

	The value120 must not be zero. */
	delta : proc "c" (data: rawptr, tablet_pad_dial_v2: ^tablet_pad_dial_v2, value120_: int),

/* Indicates the end of a set of events that represent one logical
	hardware dial event. A client is expected to accumulate the data
	in all events within the frame before proceeding.

	All wp_tablet_pad_dial events before a wp_tablet_pad_dial.frame event belong
	logically together.

	A wp_tablet_pad_dial.frame event is sent for every logical event
	group, even if the group only contains a single wp_tablet_pad_dial
	event. Specifically, a client may get a sequence: delta, frame,
	delta, frame, etc. */
	frame : proc "c" (data: rawptr, tablet_pad_dial_v2: ^tablet_pad_dial_v2, time_: uint),

}
tablet_pad_dial_v2_add_listener :: proc "contextless" (tablet_pad_dial_v2_: ^tablet_pad_dial_v2, listener: ^tablet_pad_dial_v2_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)tablet_pad_dial_v2_, cast(^generic_c_call)listener,data)
}
@(private)
tablet_pad_dial_v2_requests := []message {
	{"set_feedback", "su", raw_data(tablet_v2_types)[0:]},
	{"destroy", "", raw_data(tablet_v2_types)[0:]},
}

@(private)
tablet_pad_dial_v2_events := []message {
	{"delta", "i", raw_data(tablet_v2_types)[0:]},
	{"frame", "u", raw_data(tablet_v2_types)[0:]},
}

tablet_pad_dial_v2_interface : interface

@(private)
@(init)
init_interfaces_tablet_v2 :: proc "contextless" () {
	tablet_manager_v2_interface.name = "zwp_tablet_manager_v2"
	tablet_manager_v2_interface.version = 2
	tablet_manager_v2_interface.method_count = 2
	tablet_manager_v2_interface.event_count = 0
	tablet_manager_v2_interface.methods = raw_data(tablet_manager_v2_requests)
	tablet_seat_v2_interface.name = "zwp_tablet_seat_v2"
	tablet_seat_v2_interface.version = 2
	tablet_seat_v2_interface.method_count = 1
	tablet_seat_v2_interface.event_count = 3
	tablet_seat_v2_interface.methods = raw_data(tablet_seat_v2_requests)
	tablet_seat_v2_interface.events = raw_data(tablet_seat_v2_events)
	tablet_tool_v2_interface.name = "zwp_tablet_tool_v2"
	tablet_tool_v2_interface.version = 2
	tablet_tool_v2_interface.method_count = 2
	tablet_tool_v2_interface.event_count = 19
	tablet_tool_v2_interface.methods = raw_data(tablet_tool_v2_requests)
	tablet_tool_v2_interface.events = raw_data(tablet_tool_v2_events)
	tablet_v2_interface.name = "zwp_tablet_v2"
	tablet_v2_interface.version = 2
	tablet_v2_interface.method_count = 1
	tablet_v2_interface.event_count = 6
	tablet_v2_interface.methods = raw_data(tablet_v2_requests)
	tablet_v2_interface.events = raw_data(tablet_v2_events)
	tablet_pad_ring_v2_interface.name = "zwp_tablet_pad_ring_v2"
	tablet_pad_ring_v2_interface.version = 2
	tablet_pad_ring_v2_interface.method_count = 2
	tablet_pad_ring_v2_interface.event_count = 4
	tablet_pad_ring_v2_interface.methods = raw_data(tablet_pad_ring_v2_requests)
	tablet_pad_ring_v2_interface.events = raw_data(tablet_pad_ring_v2_events)
	tablet_pad_strip_v2_interface.name = "zwp_tablet_pad_strip_v2"
	tablet_pad_strip_v2_interface.version = 2
	tablet_pad_strip_v2_interface.method_count = 2
	tablet_pad_strip_v2_interface.event_count = 4
	tablet_pad_strip_v2_interface.methods = raw_data(tablet_pad_strip_v2_requests)
	tablet_pad_strip_v2_interface.events = raw_data(tablet_pad_strip_v2_events)
	tablet_pad_group_v2_interface.name = "zwp_tablet_pad_group_v2"
	tablet_pad_group_v2_interface.version = 2
	tablet_pad_group_v2_interface.method_count = 1
	tablet_pad_group_v2_interface.event_count = 7
	tablet_pad_group_v2_interface.methods = raw_data(tablet_pad_group_v2_requests)
	tablet_pad_group_v2_interface.events = raw_data(tablet_pad_group_v2_events)
	tablet_pad_v2_interface.name = "zwp_tablet_pad_v2"
	tablet_pad_v2_interface.version = 2
	tablet_pad_v2_interface.method_count = 2
	tablet_pad_v2_interface.event_count = 8
	tablet_pad_v2_interface.methods = raw_data(tablet_pad_v2_requests)
	tablet_pad_v2_interface.events = raw_data(tablet_pad_v2_events)
	tablet_pad_dial_v2_interface.name = "zwp_tablet_pad_dial_v2"
	tablet_pad_dial_v2_interface.version = 2
	tablet_pad_dial_v2_interface.method_count = 2
	tablet_pad_dial_v2_interface.event_count = 2
	tablet_pad_dial_v2_interface.methods = raw_data(tablet_pad_dial_v2_requests)
	tablet_pad_dial_v2_interface.events = raw_data(tablet_pad_dial_v2_events)
}

// Functions from libwayland-client
import wl ".."
