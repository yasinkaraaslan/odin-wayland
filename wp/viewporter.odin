#+build linux
package wp
@(private)
viewporter_types := []^interface {
	nil,
	nil,
	nil,
	nil,
	&viewport_interface,
	&wl.surface_interface,
}
/* The global interface exposing surface cropping and scaling
      capabilities is used to instantiate an interface extension for a
      wl_surface object. This extended interface will then allow
      cropping and scaling the surface contents, effectively
      disconnecting the direct relationship between the buffer and the
      surface size. */
viewporter :: struct {}
viewporter_set_user_data :: proc "contextless" (viewporter_: ^viewporter, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)viewporter_, user_data)
}

viewporter_get_user_data :: proc "contextless" (viewporter_: ^viewporter) -> rawptr {
   return proxy_get_user_data(cast(^proxy)viewporter_)
}

/* Informs the server that the client will not be using this
	protocol object anymore. This does not affect any other objects,
	wp_viewport objects included. */
VIEWPORTER_DESTROY :: 0
viewporter_destroy :: proc "contextless" (viewporter_: ^viewporter) {
	proxy_marshal_flags(cast(^proxy)viewporter_, VIEWPORTER_DESTROY, nil, proxy_get_version(cast(^proxy)viewporter_), 1)
}

/* Instantiate an interface extension for the given wl_surface to
	crop and scale its content. If the given wl_surface already has
	a wp_viewport object associated, the viewport_exists
	protocol error is raised. */
VIEWPORTER_GET_VIEWPORT :: 1
viewporter_get_viewport :: proc "contextless" (viewporter_: ^viewporter, surface_: ^wl.surface) -> ^viewport {
	ret := proxy_marshal_flags(cast(^proxy)viewporter_, VIEWPORTER_GET_VIEWPORT, &viewport_interface, proxy_get_version(cast(^proxy)viewporter_), 0, nil, surface_)
	return cast(^viewport)ret
}

/*  */
viewporter_error :: enum {
	viewport_exists = 0,
}
@(private)
viewporter_requests := []message {
	{"destroy", "", raw_data(viewporter_types)[0:]},
	{"get_viewport", "no", raw_data(viewporter_types)[4:]},
}

viewporter_interface : interface

/* An additional interface to a wl_surface object, which allows the
      client to specify the cropping and scaling of the surface
      contents.

      This interface works with two concepts: the source rectangle (src_x,
      src_y, src_width, src_height), and the destination size (dst_width,
      dst_height). The contents of the source rectangle are scaled to the
      destination size, and content outside the source rectangle is ignored.
      This state is double-buffered, see wl_surface.commit.

      The two parts of crop and scale state are independent: the source
      rectangle, and the destination size. Initially both are unset, that
      is, no scaling is applied. The whole of the current wl_buffer is
      used as the source, and the surface size is as defined in
      wl_surface.attach.

      If the destination size is set, it causes the surface size to become
      dst_width, dst_height. The source (rectangle) is scaled to exactly
      this size. This overrides whatever the attached wl_buffer size is,
      unless the wl_buffer is NULL. If the wl_buffer is NULL, the surface
      has no content and therefore no size. Otherwise, the size is always
      at least 1x1 in surface local coordinates.

      If the source rectangle is set, it defines what area of the wl_buffer is
      taken as the source. If the source rectangle is set and the destination
      size is not set, then src_width and src_height must be integers, and the
      surface size becomes the source rectangle size. This results in cropping
      without scaling. If src_width or src_height are not integers and
      destination size is not set, the bad_size protocol error is raised when
      the surface state is applied.

      The coordinate transformations from buffer pixel coordinates up to
      the surface-local coordinates happen in the following order:
        1. buffer_transform (wl_surface.set_buffer_transform)
        2. buffer_scale (wl_surface.set_buffer_scale)
        3. crop and scale (wp_viewport.set*)
      This means, that the source rectangle coordinates of crop and scale
      are given in the coordinates after the buffer transform and scale,
      i.e. in the coordinates that would be the surface-local coordinates
      if the crop and scale was not applied.

      If src_x or src_y are negative, the bad_value protocol error is raised.
      Otherwise, if the source rectangle is partially or completely outside of
      the non-NULL wl_buffer, then the out_of_buffer protocol error is raised
      when the surface state is applied. A NULL wl_buffer does not raise the
      out_of_buffer error.

      If the wl_surface associated with the wp_viewport is destroyed,
      all wp_viewport requests except 'destroy' raise the protocol error
      no_surface.

      If the wp_viewport object is destroyed, the crop and scale
      state is removed from the wl_surface. The change will be applied
      on the next wl_surface.commit. */
viewport :: struct {}
viewport_set_user_data :: proc "contextless" (viewport_: ^viewport, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)viewport_, user_data)
}

viewport_get_user_data :: proc "contextless" (viewport_: ^viewport) -> rawptr {
   return proxy_get_user_data(cast(^proxy)viewport_)
}

/* The associated wl_surface's crop and scale state is removed.
	The change is applied on the next wl_surface.commit. */
VIEWPORT_DESTROY :: 0
viewport_destroy :: proc "contextless" (viewport_: ^viewport) {
	proxy_marshal_flags(cast(^proxy)viewport_, VIEWPORT_DESTROY, nil, proxy_get_version(cast(^proxy)viewport_), 1)
}

/* Set the source rectangle of the associated wl_surface. See
	wp_viewport for the description, and relation to the wl_buffer
	size.

	If all of x, y, width and height are -1.0, the source rectangle is
	unset instead. Any other set of values where width or height are zero
	or negative, or x or y are negative, raise the bad_value protocol
	error.

	The crop and scale state is double-buffered, see wl_surface.commit. */
VIEWPORT_SET_SOURCE :: 1
viewport_set_source :: proc "contextless" (viewport_: ^viewport, x_: fixed_t, y_: fixed_t, width_: fixed_t, height_: fixed_t) {
	proxy_marshal_flags(cast(^proxy)viewport_, VIEWPORT_SET_SOURCE, nil, proxy_get_version(cast(^proxy)viewport_), 0, x_, y_, width_, height_)
}

/* Set the destination size of the associated wl_surface. See
	wp_viewport for the description, and relation to the wl_buffer
	size.

	If width is -1 and height is -1, the destination size is unset
	instead. Any other pair of values for width and height that
	contains zero or negative values raises the bad_value protocol
	error.

	The crop and scale state is double-buffered, see wl_surface.commit. */
VIEWPORT_SET_DESTINATION :: 2
viewport_set_destination :: proc "contextless" (viewport_: ^viewport, width_: int, height_: int) {
	proxy_marshal_flags(cast(^proxy)viewport_, VIEWPORT_SET_DESTINATION, nil, proxy_get_version(cast(^proxy)viewport_), 0, width_, height_)
}

/*  */
viewport_error :: enum {
	bad_value = 0,
	bad_size = 1,
	out_of_buffer = 2,
	no_surface = 3,
}
@(private)
viewport_requests := []message {
	{"destroy", "", raw_data(viewporter_types)[0:]},
	{"set_source", "ffff", raw_data(viewporter_types)[0:]},
	{"set_destination", "ii", raw_data(viewporter_types)[0:]},
}

viewport_interface : interface

@(private)
@(init)
init_interfaces_viewporter :: proc "contextless" () {
	viewporter_interface.name = "wp_viewporter"
	viewporter_interface.version = 1
	viewporter_interface.method_count = 2
	viewporter_interface.event_count = 0
	viewporter_interface.methods = raw_data(viewporter_requests)
	viewport_interface.name = "wp_viewport"
	viewport_interface.version = 1
	viewport_interface.method_count = 3
	viewport_interface.event_count = 0
	viewport_interface.methods = raw_data(viewport_requests)
}

// Functions from libwayland-client
import wl ".."
