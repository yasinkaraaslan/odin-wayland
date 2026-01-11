#+build linux
package wayland
@(private)
wayland_types := []^interface {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	&callback_interface,
	&registry_interface,
	&surface_interface,
	&region_interface,
	&buffer_interface,
	nil,
	nil,
	nil,
	nil,
	nil,
	&shm_pool_interface,
	nil,
	nil,
	&data_source_interface,
	&surface_interface,
	&surface_interface,
	nil,
	&data_source_interface,
	nil,
	&data_offer_interface,
	nil,
	&surface_interface,
	nil,
	nil,
	&data_offer_interface,
	&data_offer_interface,
	&data_source_interface,
	&data_device_interface,
	&seat_interface,
	&buffer_interface,
	nil,
	nil,
	&callback_interface,
	&region_interface,
	&region_interface,
	&output_interface,
	&output_interface,
	&pointer_interface,
	&keyboard_interface,
	&touch_interface,
	nil,
	&surface_interface,
	nil,
	nil,
	nil,
	&surface_interface,
	nil,
	nil,
	nil,
	&surface_interface,
	nil,
	&surface_interface,
	nil,
	nil,
	&surface_interface,
	nil,
	nil,
	&surface_interface,
	nil,
	nil,
	nil,
	&subsurface_interface,
	&surface_interface,
	&surface_interface,
	&surface_interface,
	&surface_interface,
	&registry_interface,
}
/* The core global object.  This is a special singleton object.  It
      is used for internal Wayland protocol features. */
display :: struct {}
display_set_user_data :: proc "contextless" (display_: ^display, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)display_, user_data)
}

display_get_user_data :: proc "contextless" (display_: ^display) -> rawptr {
   return proxy_get_user_data(cast(^proxy)display_)
}

/* The sync request asks the server to emit the 'done' event
	on the returned wl_callback object.  Since requests are
	handled in-order and events are delivered in-order, this can
	be used as a barrier to ensure all previous requests and the
	resulting events have been handled.

	The object returned by this request will be destroyed by the
	compositor after the callback is fired and as such the client must not
	attempt to use it after that point.

	The callback_data passed in the callback is undefined and should be ignored. */
DISPLAY_SYNC :: 0
display_sync :: proc "contextless" (display_: ^display) -> ^callback {
	ret := proxy_marshal_flags(cast(^proxy)display_, DISPLAY_SYNC, &callback_interface, proxy_get_version(cast(^proxy)display_), 0, nil)
	return cast(^callback)ret
}

/* This request creates a registry object that allows the client
	to list and bind the global objects available from the
	compositor.

	It should be noted that the server side resources consumed in
	response to a get_registry request can only be released when the
	client disconnects, not when the client side proxy is destroyed.
	Therefore, clients should invoke get_registry as infrequently as
	possible to avoid wasting memory. */
DISPLAY_GET_REGISTRY :: 1
display_get_registry :: proc "contextless" (display_: ^display) -> ^registry {
	ret := proxy_marshal_flags(cast(^proxy)display_, DISPLAY_GET_REGISTRY, &registry_interface, proxy_get_version(cast(^proxy)display_), 0, nil)
	return cast(^registry)ret
}

display_listener :: struct {
/* The error event is sent out when a fatal (non-recoverable)
	error has occurred.  The object_id argument is the object
	where the error occurred, most often in response to a request
	to that object.  The code identifies the error and is defined
	by the object interface.  As such, each interface defines its
	own set of error codes.  The message is a brief description
	of the error, for (debugging) convenience. */
	error : proc "c" (data: rawptr, display: ^display, object_id_: rawptr, code_: uint, message_: cstring),

/* This event is used internally by the object ID management
	logic. When a client deletes an object that it had created,
	the server will send this event to acknowledge that it has
	seen the delete request. When the client receives this event,
	it will know that it can safely reuse the object ID. */
	delete_id : proc "c" (data: rawptr, display: ^display, id_: uint),

}
display_add_listener :: proc "contextless" (display_: ^display, listener: ^display_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)display_, cast(^generic_c_call)listener,data)
}
/* These errors are global and can be emitted in response to any
	server request. */
display_error :: enum {
	invalid_object = 0,
	invalid_method = 1,
	no_memory = 2,
	implementation = 3,
}
@(private)
display_requests := []message {
	{"sync", "n", raw_data(wayland_types)[8:]},
	{"get_registry", "n", raw_data(wayland_types)[9:]},
}

@(private)
display_events := []message {
	{"error", "ous", raw_data(wayland_types)[0:]},
	{"delete_id", "u", raw_data(wayland_types)[0:]},
}

display_interface : interface

/* The singleton global registry object.  The server has a number of
      global objects that are available to all clients.  These objects
      typically represent an actual object in the server (for example,
      an input device) or they are singleton objects that provide
      extension functionality.

      When a client creates a registry object, the registry object
      will emit a global event for each global currently in the
      registry.  Globals come and go as a result of device or
      monitor hotplugs, reconfiguration or other events, and the
      registry will send out global and global_remove events to
      keep the client up to date with the changes.  To mark the end
      of the initial burst of events, the client can use the
      wl_display.sync request immediately after calling
      wl_display.get_registry.

      A client can bind to a global object by using the bind
      request.  This creates a client-side handle that lets the object
      emit events to the client and lets the client invoke requests on
      the object. */
registry :: struct {}
registry_set_user_data :: proc "contextless" (registry_: ^registry, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)registry_, user_data)
}

registry_get_user_data :: proc "contextless" (registry_: ^registry) -> rawptr {
   return proxy_get_user_data(cast(^proxy)registry_)
}

/* Binds a new, client-created object to the server using the
	specified name as the identifier. */
REGISTRY_BIND :: 0
registry_bind :: proc "contextless" (registry_: ^registry, name_: uint, id_: ^interface, version: uint) -> rawptr {
	ret := proxy_marshal_flags(cast(^proxy)registry_, REGISTRY_BIND, id_, version, 0, name_, id_.name, version)
	return cast(rawptr)ret
}

registry_destroy :: proc "contextless" (registry_: ^registry) {
   proxy_destroy(cast(^proxy)registry_)
}

registry_listener :: struct {
/* Notify the client of global objects.

	The event notifies the client that a global object with
	the given name is now available, and it implements the
	given version of the given interface. */
	global : proc "c" (data: rawptr, registry: ^registry, name_: uint, interface_: cstring, version_: uint),

/* Notify the client of removed global objects.

	This event notifies the client that the global identified
	by name is no longer available.  If the client bound to
	the global using the bind request, the client should now
	destroy that object.

	The object remains valid and requests to the object will be
	ignored until the client destroys it, to avoid races between
	the global going away and a client sending a request to it. */
	global_remove : proc "c" (data: rawptr, registry: ^registry, name_: uint),

}
registry_add_listener :: proc "contextless" (registry_: ^registry, listener: ^registry_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)registry_, cast(^generic_c_call)listener,data)
}
@(private)
registry_requests := []message {
	{"bind", "usun", raw_data(wayland_types)[0:]},
}

@(private)
registry_events := []message {
	{"global", "usu", raw_data(wayland_types)[0:]},
	{"global_remove", "u", raw_data(wayland_types)[0:]},
}

registry_interface : interface

/* Clients can handle the 'done' event to get notified when
      the related request is done.

      Note, because wl_callback objects are created from multiple independent
      factory interfaces, the wl_callback interface is frozen at version 1. */
callback :: struct {}
callback_set_user_data :: proc "contextless" (callback_: ^callback, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)callback_, user_data)
}

callback_get_user_data :: proc "contextless" (callback_: ^callback) -> rawptr {
   return proxy_get_user_data(cast(^proxy)callback_)
}

callback_destroy :: proc "contextless" (callback_: ^callback) {
   proxy_destroy(cast(^proxy)callback_)
}

callback_listener :: struct {
/* Notify the client when the related request is done. */
	done : proc "c" (data: rawptr, callback: ^callback, callback_data_: uint),

}
callback_add_listener :: proc "contextless" (callback_: ^callback, listener: ^callback_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)callback_, cast(^generic_c_call)listener,data)
}
@(private)
callback_events := []message {
	{"done", "u", raw_data(wayland_types)[0:]},
}

callback_interface : interface

/* A compositor.  This object is a singleton global.  The
      compositor is in charge of combining the contents of multiple
      surfaces into one displayable output. */
compositor :: struct {}
compositor_set_user_data :: proc "contextless" (compositor_: ^compositor, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)compositor_, user_data)
}

compositor_get_user_data :: proc "contextless" (compositor_: ^compositor) -> rawptr {
   return proxy_get_user_data(cast(^proxy)compositor_)
}

/* Ask the compositor to create a new surface. */
COMPOSITOR_CREATE_SURFACE :: 0
compositor_create_surface :: proc "contextless" (compositor_: ^compositor) -> ^surface {
	ret := proxy_marshal_flags(cast(^proxy)compositor_, COMPOSITOR_CREATE_SURFACE, &surface_interface, proxy_get_version(cast(^proxy)compositor_), 0, nil)
	return cast(^surface)ret
}

/* Ask the compositor to create a new region. */
COMPOSITOR_CREATE_REGION :: 1
compositor_create_region :: proc "contextless" (compositor_: ^compositor) -> ^region {
	ret := proxy_marshal_flags(cast(^proxy)compositor_, COMPOSITOR_CREATE_REGION, &region_interface, proxy_get_version(cast(^proxy)compositor_), 0, nil)
	return cast(^region)ret
}

compositor_destroy :: proc "contextless" (compositor_: ^compositor) {
   proxy_destroy(cast(^proxy)compositor_)
}

@(private)
compositor_requests := []message {
	{"create_surface", "n", raw_data(wayland_types)[10:]},
	{"create_region", "n", raw_data(wayland_types)[11:]},
}

compositor_interface : interface

/* The wl_shm_pool object encapsulates a piece of memory shared
      between the compositor and client.  Through the wl_shm_pool
      object, the client can allocate shared memory wl_buffer objects.
      All objects created through the same pool share the same
      underlying mapped memory. Reusing the mapped memory avoids the
      setup/teardown overhead and is useful when interactively resizing
      a surface or for many small buffers. */
shm_pool :: struct {}
shm_pool_set_user_data :: proc "contextless" (shm_pool_: ^shm_pool, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)shm_pool_, user_data)
}

shm_pool_get_user_data :: proc "contextless" (shm_pool_: ^shm_pool) -> rawptr {
   return proxy_get_user_data(cast(^proxy)shm_pool_)
}

/* Create a wl_buffer object from the pool.

	The buffer is created offset bytes into the pool and has
	width and height as specified.  The stride argument specifies
	the number of bytes from the beginning of one row to the beginning
	of the next.  The format is the pixel format of the buffer and
	must be one of those advertised through the wl_shm.format event.

	A buffer will keep a reference to the pool it was created from
	so it is valid to destroy the pool immediately after creating
	a buffer from it. */
SHM_POOL_CREATE_BUFFER :: 0
shm_pool_create_buffer :: proc "contextless" (shm_pool_: ^shm_pool, offset_: int, width_: int, height_: int, stride_: int, format_: shm_format) -> ^buffer {
	ret := proxy_marshal_flags(cast(^proxy)shm_pool_, SHM_POOL_CREATE_BUFFER, &buffer_interface, proxy_get_version(cast(^proxy)shm_pool_), 0, nil, offset_, width_, height_, stride_, format_)
	return cast(^buffer)ret
}

/* Destroy the shared memory pool.

	The mmapped memory will be released when all
	buffers that have been created from this pool
	are gone. */
SHM_POOL_DESTROY :: 1
shm_pool_destroy :: proc "contextless" (shm_pool_: ^shm_pool) {
	proxy_marshal_flags(cast(^proxy)shm_pool_, SHM_POOL_DESTROY, nil, proxy_get_version(cast(^proxy)shm_pool_), 1)
}

/* This request will cause the server to remap the backing memory
	for the pool from the file descriptor passed when the pool was
	created, but using the new size.  This request can only be
	used to make the pool bigger.

	This request only changes the amount of bytes that are mmapped
	by the server and does not touch the file corresponding to the
	file descriptor passed at creation time. It is the client's
	responsibility to ensure that the file is at least as big as
	the new pool size. */
SHM_POOL_RESIZE :: 2
shm_pool_resize :: proc "contextless" (shm_pool_: ^shm_pool, size_: int) {
	proxy_marshal_flags(cast(^proxy)shm_pool_, SHM_POOL_RESIZE, nil, proxy_get_version(cast(^proxy)shm_pool_), 0, size_)
}

@(private)
shm_pool_requests := []message {
	{"create_buffer", "niiiiu", raw_data(wayland_types)[12:]},
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"resize", "i", raw_data(wayland_types)[0:]},
}

shm_pool_interface : interface

/* A singleton global object that provides support for shared
      memory.

      Clients can create wl_shm_pool objects using the create_pool
      request.

      On binding the wl_shm object one or more format events
      are emitted to inform clients about the valid pixel formats
      that can be used for buffers. */
shm :: struct {}
shm_set_user_data :: proc "contextless" (shm_: ^shm, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)shm_, user_data)
}

shm_get_user_data :: proc "contextless" (shm_: ^shm) -> rawptr {
   return proxy_get_user_data(cast(^proxy)shm_)
}

/* Create a new wl_shm_pool object.

	The pool can be used to create shared memory based buffer
	objects.  The server will mmap size bytes of the passed file
	descriptor, to use as backing memory for the pool. */
SHM_CREATE_POOL :: 0
shm_create_pool :: proc "contextless" (shm_: ^shm, fd_: int, size_: int) -> ^shm_pool {
	ret := proxy_marshal_flags(cast(^proxy)shm_, SHM_CREATE_POOL, &shm_pool_interface, proxy_get_version(cast(^proxy)shm_), 0, nil, fd_, size_)
	return cast(^shm_pool)ret
}

/* Using this request a client can tell the server that it is not going to
	use the shm object anymore.

	Objects created via this interface remain unaffected. */
SHM_RELEASE :: 1
shm_release :: proc "contextless" (shm_: ^shm) {
	proxy_marshal_flags(cast(^proxy)shm_, SHM_RELEASE, nil, proxy_get_version(cast(^proxy)shm_), 1)
}

shm_destroy :: proc "contextless" (shm_: ^shm) {
   proxy_destroy(cast(^proxy)shm_)
}

shm_listener :: struct {
/* Informs the client about a valid pixel format that
	can be used for buffers. Known formats include
	argb8888 and xrgb8888. */
	format : proc "c" (data: rawptr, shm: ^shm, format_: shm_format),

}
shm_add_listener :: proc "contextless" (shm_: ^shm, listener: ^shm_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)shm_, cast(^generic_c_call)listener,data)
}
/* These errors can be emitted in response to wl_shm requests. */
shm_error :: enum {
	invalid_format = 0,
	invalid_stride = 1,
	invalid_fd = 2,
}
/* This describes the memory layout of an individual pixel.

	All renderers should support argb8888 and xrgb8888 but any other
	formats are optional and may not be supported by the particular
	renderer in use.

	The drm format codes match the macros defined in drm_fourcc.h, except
	argb8888 and xrgb8888. The formats actually supported by the compositor
	will be reported by the format event.

	For all wl_shm formats and unless specified in another protocol
	extension, pre-multiplied alpha is used for pixel values. */
shm_format :: enum {
	argb8888 = 0,
	xrgb8888 = 1,
	c8 = 0x20203843,
	rgb332 = 0x38424752,
	bgr233 = 0x38524742,
	xrgb4444 = 0x32315258,
	xbgr4444 = 0x32314258,
	rgbx4444 = 0x32315852,
	bgrx4444 = 0x32315842,
	argb4444 = 0x32315241,
	abgr4444 = 0x32314241,
	rgba4444 = 0x32314152,
	bgra4444 = 0x32314142,
	xrgb1555 = 0x35315258,
	xbgr1555 = 0x35314258,
	rgbx5551 = 0x35315852,
	bgrx5551 = 0x35315842,
	argb1555 = 0x35315241,
	abgr1555 = 0x35314241,
	rgba5551 = 0x35314152,
	bgra5551 = 0x35314142,
	rgb565 = 0x36314752,
	bgr565 = 0x36314742,
	rgb888 = 0x34324752,
	bgr888 = 0x34324742,
	xbgr8888 = 0x34324258,
	rgbx8888 = 0x34325852,
	bgrx8888 = 0x34325842,
	abgr8888 = 0x34324241,
	rgba8888 = 0x34324152,
	bgra8888 = 0x34324142,
	xrgb2101010 = 0x30335258,
	xbgr2101010 = 0x30334258,
	rgbx1010102 = 0x30335852,
	bgrx1010102 = 0x30335842,
	argb2101010 = 0x30335241,
	abgr2101010 = 0x30334241,
	rgba1010102 = 0x30334152,
	bgra1010102 = 0x30334142,
	yuyv = 0x56595559,
	yvyu = 0x55595659,
	uyvy = 0x59565955,
	vyuy = 0x59555956,
	ayuv = 0x56555941,
	nv12 = 0x3231564e,
	nv21 = 0x3132564e,
	nv16 = 0x3631564e,
	nv61 = 0x3136564e,
	yuv410 = 0x39565559,
	yvu410 = 0x39555659,
	yuv411 = 0x31315559,
	yvu411 = 0x31315659,
	yuv420 = 0x32315559,
	yvu420 = 0x32315659,
	yuv422 = 0x36315559,
	yvu422 = 0x36315659,
	yuv444 = 0x34325559,
	yvu444 = 0x34325659,
	r8 = 0x20203852,
	r16 = 0x20363152,
	rg88 = 0x38384752,
	gr88 = 0x38385247,
	rg1616 = 0x32334752,
	gr1616 = 0x32335247,
	xrgb16161616f = 0x48345258,
	xbgr16161616f = 0x48344258,
	argb16161616f = 0x48345241,
	abgr16161616f = 0x48344241,
	xyuv8888 = 0x56555958,
	vuy888 = 0x34325556,
	vuy101010 = 0x30335556,
	y210 = 0x30313259,
	y212 = 0x32313259,
	y216 = 0x36313259,
	y410 = 0x30313459,
	y412 = 0x32313459,
	y416 = 0x36313459,
	xvyu2101010 = 0x30335658,
	xvyu12_16161616 = 0x36335658,
	xvyu16161616 = 0x38345658,
	y0l0 = 0x304c3059,
	x0l0 = 0x304c3058,
	y0l2 = 0x324c3059,
	x0l2 = 0x324c3058,
	yuv420_8bit = 0x38305559,
	yuv420_10bit = 0x30315559,
	xrgb8888_a8 = 0x38415258,
	xbgr8888_a8 = 0x38414258,
	rgbx8888_a8 = 0x38415852,
	bgrx8888_a8 = 0x38415842,
	rgb888_a8 = 0x38413852,
	bgr888_a8 = 0x38413842,
	rgb565_a8 = 0x38413552,
	bgr565_a8 = 0x38413542,
	nv24 = 0x3432564e,
	nv42 = 0x3234564e,
	p210 = 0x30313250,
	p010 = 0x30313050,
	p012 = 0x32313050,
	p016 = 0x36313050,
	axbxgxrx106106106106 = 0x30314241,
	nv15 = 0x3531564e,
	q410 = 0x30313451,
	q401 = 0x31303451,
	xrgb16161616 = 0x38345258,
	xbgr16161616 = 0x38344258,
	argb16161616 = 0x38345241,
	abgr16161616 = 0x38344241,
	c1 = 0x20203143,
	c2 = 0x20203243,
	c4 = 0x20203443,
	d1 = 0x20203144,
	d2 = 0x20203244,
	d4 = 0x20203444,
	d8 = 0x20203844,
	r1 = 0x20203152,
	r2 = 0x20203252,
	r4 = 0x20203452,
	r10 = 0x20303152,
	r12 = 0x20323152,
	avuy8888 = 0x59555641,
	xvuy8888 = 0x59555658,
	p030 = 0x30333050,
}
@(private)
shm_requests := []message {
	{"create_pool", "nhi", raw_data(wayland_types)[18:]},
	{"release", "2", raw_data(wayland_types)[0:]},
}

@(private)
shm_events := []message {
	{"format", "u", raw_data(wayland_types)[0:]},
}

shm_interface : interface

/* A buffer provides the content for a wl_surface. Buffers are
      created through factory interfaces such as wl_shm, wp_linux_buffer_params
      (from the linux-dmabuf protocol extension) or similar. It has a width and
      a height and can be attached to a wl_surface, but the mechanism by which a
      client provides and updates the contents is defined by the buffer factory
      interface.

      Color channels are assumed to be electrical rather than optical (in other
      words, encoded with a transfer function) unless otherwise specified. If
      the buffer uses a format that has an alpha channel, the alpha channel is
      assumed to be premultiplied into the electrical color channel values
      (after transfer function encoding) unless otherwise specified.

      Note, because wl_buffer objects are created from multiple independent
      factory interfaces, the wl_buffer interface is frozen at version 1. */
buffer :: struct {}
buffer_set_user_data :: proc "contextless" (buffer_: ^buffer, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)buffer_, user_data)
}

buffer_get_user_data :: proc "contextless" (buffer_: ^buffer) -> rawptr {
   return proxy_get_user_data(cast(^proxy)buffer_)
}

/* Destroy a buffer. If and how you need to release the backing
	storage is defined by the buffer factory interface.

	For possible side-effects to a surface, see wl_surface.attach. */
BUFFER_DESTROY :: 0
buffer_destroy :: proc "contextless" (buffer_: ^buffer) {
	proxy_marshal_flags(cast(^proxy)buffer_, BUFFER_DESTROY, nil, proxy_get_version(cast(^proxy)buffer_), 1)
}

buffer_listener :: struct {
/* Sent when this wl_buffer is no longer used by the compositor.

	For more information on when release events may or may not be sent,
	and what consequences it has, please see the description of
	wl_surface.attach.

	If a client receives a release event before the frame callback
	requested in the same wl_surface.commit that attaches this
	wl_buffer to a surface, then the client is immediately free to
	reuse the buffer and its backing storage, and does not need a
	second buffer for the next surface content update. Typically
	this is possible, when the compositor maintains a copy of the
	wl_surface contents, e.g. as a GL texture. This is an important
	optimization for GL(ES) compositors with wl_shm clients. */
	release : proc "c" (data: rawptr, buffer: ^buffer),

}
buffer_add_listener :: proc "contextless" (buffer_: ^buffer, listener: ^buffer_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)buffer_, cast(^generic_c_call)listener,data)
}
@(private)
buffer_requests := []message {
	{"destroy", "", raw_data(wayland_types)[0:]},
}

@(private)
buffer_events := []message {
	{"release", "", raw_data(wayland_types)[0:]},
}

buffer_interface : interface

/* A wl_data_offer represents a piece of data offered for transfer
      by another client (the source client).  It is used by the
      copy-and-paste and drag-and-drop mechanisms.  The offer
      describes the different mime types that the data can be
      converted to and provides the mechanism for transferring the
      data directly from the source client. */
data_offer :: struct {}
data_offer_set_user_data :: proc "contextless" (data_offer_: ^data_offer, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)data_offer_, user_data)
}

data_offer_get_user_data :: proc "contextless" (data_offer_: ^data_offer) -> rawptr {
   return proxy_get_user_data(cast(^proxy)data_offer_)
}

/* Indicate that the client can accept the given mime type, or
	NULL for not accepted.

	For objects of version 2 or older, this request is used by the
	client to give feedback whether the client can receive the given
	mime type, or NULL if none is accepted; the feedback does not
	determine whether the drag-and-drop operation succeeds or not.

	For objects of version 3 or newer, this request determines the
	final result of the drag-and-drop operation. If the end result
	is that no mime types were accepted, the drag-and-drop operation
	will be cancelled and the corresponding drag source will receive
	wl_data_source.cancelled. Clients may still use this event in
	conjunction with wl_data_source.action for feedback. */
DATA_OFFER_ACCEPT :: 0
data_offer_accept :: proc "contextless" (data_offer_: ^data_offer, serial_: uint, mime_type_: cstring) {
	proxy_marshal_flags(cast(^proxy)data_offer_, DATA_OFFER_ACCEPT, nil, proxy_get_version(cast(^proxy)data_offer_), 0, serial_, mime_type_)
}

/* To transfer the offered data, the client issues this request
	and indicates the mime type it wants to receive.  The transfer
	happens through the passed file descriptor (typically created
	with the pipe system call).  The source client writes the data
	in the mime type representation requested and then closes the
	file descriptor.

	The receiving client reads from the read end of the pipe until
	EOF and then closes its end, at which point the transfer is
	complete.

	This request may happen multiple times for different mime types,
	both before and after wl_data_device.drop. Drag-and-drop destination
	clients may preemptively fetch data or examine it more closely to
	determine acceptance. */
DATA_OFFER_RECEIVE :: 1
data_offer_receive :: proc "contextless" (data_offer_: ^data_offer, mime_type_: cstring, fd_: int) {
	proxy_marshal_flags(cast(^proxy)data_offer_, DATA_OFFER_RECEIVE, nil, proxy_get_version(cast(^proxy)data_offer_), 0, mime_type_, fd_)
}

/* Destroy the data offer. */
DATA_OFFER_DESTROY :: 2
data_offer_destroy :: proc "contextless" (data_offer_: ^data_offer) {
	proxy_marshal_flags(cast(^proxy)data_offer_, DATA_OFFER_DESTROY, nil, proxy_get_version(cast(^proxy)data_offer_), 1)
}

/* Notifies the compositor that the drag destination successfully
	finished the drag-and-drop operation.

	Upon receiving this request, the compositor will emit
	wl_data_source.dnd_finished on the drag source client.

	It is a client error to perform other requests than
	wl_data_offer.destroy after this one. It is also an error to perform
	this request after a NULL mime type has been set in
	wl_data_offer.accept or no action was received through
	wl_data_offer.action.

	If wl_data_offer.finish request is received for a non drag and drop
	operation, the invalid_finish protocol error is raised. */
DATA_OFFER_FINISH :: 3
data_offer_finish :: proc "contextless" (data_offer_: ^data_offer) {
	proxy_marshal_flags(cast(^proxy)data_offer_, DATA_OFFER_FINISH, nil, proxy_get_version(cast(^proxy)data_offer_), 0)
}

/* Sets the actions that the destination side client supports for
	this operation. This request may trigger the emission of
	wl_data_source.action and wl_data_offer.action events if the compositor
	needs to change the selected action.

	This request can be called multiple times throughout the
	drag-and-drop operation, typically in response to wl_data_device.enter
	or wl_data_device.motion events.

	This request determines the final result of the drag-and-drop
	operation. If the end result is that no action is accepted,
	the drag source will receive wl_data_source.cancelled.

	The dnd_actions argument must contain only values expressed in the
	wl_data_device_manager.dnd_actions enum, and the preferred_action
	argument must only contain one of those values set, otherwise it
	will result in a protocol error.

	While managing an "ask" action, the destination drag-and-drop client
	may perform further wl_data_offer.receive requests, and is expected
	to perform one last wl_data_offer.set_actions request with a preferred
	action other than "ask" (and optionally wl_data_offer.accept) before
	requesting wl_data_offer.finish, in order to convey the action selected
	by the user. If the preferred action is not in the
	wl_data_offer.source_actions mask, an error will be raised.

	If the "ask" action is dismissed (e.g. user cancellation), the client
	is expected to perform wl_data_offer.destroy right away.

	This request can only be made on drag-and-drop offers, a protocol error
	will be raised otherwise. */
DATA_OFFER_SET_ACTIONS :: 4
data_offer_set_actions :: proc "contextless" (data_offer_: ^data_offer, dnd_actions_: data_device_manager_dnd_action, preferred_action_: data_device_manager_dnd_action) {
	proxy_marshal_flags(cast(^proxy)data_offer_, DATA_OFFER_SET_ACTIONS, nil, proxy_get_version(cast(^proxy)data_offer_), 0, dnd_actions_, preferred_action_)
}

data_offer_listener :: struct {
/* Sent immediately after creating the wl_data_offer object.  One
	event per offered mime type. */
	offer : proc "c" (data: rawptr, data_offer: ^data_offer, mime_type_: cstring),

/* This event indicates the actions offered by the data source. It
	will be sent immediately after creating the wl_data_offer object,
	or anytime the source side changes its offered actions through
	wl_data_source.set_actions. */
	source_actions : proc "c" (data: rawptr, data_offer: ^data_offer, source_actions_: data_device_manager_dnd_action),

/* This event indicates the action selected by the compositor after
	matching the source/destination side actions. Only one action (or
	none) will be offered here.

	This event can be emitted multiple times during the drag-and-drop
	operation in response to destination side action changes through
	wl_data_offer.set_actions.

	This event will no longer be emitted after wl_data_device.drop
	happened on the drag-and-drop destination, the client must
	honor the last action received, or the last preferred one set
	through wl_data_offer.set_actions when handling an "ask" action.

	Compositors may also change the selected action on the fly, mainly
	in response to keyboard modifier changes during the drag-and-drop
	operation.

	The most recent action received is always the valid one. Prior to
	receiving wl_data_device.drop, the chosen action may change (e.g.
	due to keyboard modifiers being pressed). At the time of receiving
	wl_data_device.drop the drag-and-drop destination must honor the
	last action received.

	Action changes may still happen after wl_data_device.drop,
	especially on "ask" actions, where the drag-and-drop destination
	may choose another action afterwards. Action changes happening
	at this stage are always the result of inter-client negotiation, the
	compositor shall no longer be able to induce a different action.

	Upon "ask" actions, it is expected that the drag-and-drop destination
	may potentially choose a different action and/or mime type,
	based on wl_data_offer.source_actions and finally chosen by the
	user (e.g. popping up a menu with the available options). The
	final wl_data_offer.set_actions and wl_data_offer.accept requests
	must happen before the call to wl_data_offer.finish. */
	action : proc "c" (data: rawptr, data_offer: ^data_offer, dnd_action_: data_device_manager_dnd_action),

}
data_offer_add_listener :: proc "contextless" (data_offer_: ^data_offer, listener: ^data_offer_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)data_offer_, cast(^generic_c_call)listener,data)
}
/*  */
data_offer_error :: enum {
	invalid_finish = 0,
	invalid_action_mask = 1,
	invalid_action = 2,
	invalid_offer = 3,
}
@(private)
data_offer_requests := []message {
	{"accept", "u?s", raw_data(wayland_types)[0:]},
	{"receive", "sh", raw_data(wayland_types)[0:]},
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"finish", "3", raw_data(wayland_types)[0:]},
	{"set_actions", "3uu", raw_data(wayland_types)[0:]},
}

@(private)
data_offer_events := []message {
	{"offer", "s", raw_data(wayland_types)[0:]},
	{"source_actions", "3u", raw_data(wayland_types)[0:]},
	{"action", "3u", raw_data(wayland_types)[0:]},
}

data_offer_interface : interface

/* The wl_data_source object is the source side of a wl_data_offer.
      It is created by the source client in a data transfer and
      provides a way to describe the offered data and a way to respond
      to requests to transfer the data. */
data_source :: struct {}
data_source_set_user_data :: proc "contextless" (data_source_: ^data_source, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)data_source_, user_data)
}

data_source_get_user_data :: proc "contextless" (data_source_: ^data_source) -> rawptr {
   return proxy_get_user_data(cast(^proxy)data_source_)
}

/* This request adds a mime type to the set of mime types
	advertised to targets.  Can be called several times to offer
	multiple types. */
DATA_SOURCE_OFFER :: 0
data_source_offer :: proc "contextless" (data_source_: ^data_source, mime_type_: cstring) {
	proxy_marshal_flags(cast(^proxy)data_source_, DATA_SOURCE_OFFER, nil, proxy_get_version(cast(^proxy)data_source_), 0, mime_type_)
}

/* Destroy the data source. */
DATA_SOURCE_DESTROY :: 1
data_source_destroy :: proc "contextless" (data_source_: ^data_source) {
	proxy_marshal_flags(cast(^proxy)data_source_, DATA_SOURCE_DESTROY, nil, proxy_get_version(cast(^proxy)data_source_), 1)
}

/* Sets the actions that the source side client supports for this
	operation. This request may trigger wl_data_source.action and
	wl_data_offer.action events if the compositor needs to change the
	selected action.

	The dnd_actions argument must contain only values expressed in the
	wl_data_device_manager.dnd_actions enum, otherwise it will result
	in a protocol error.

	This request must be made once only, and can only be made on sources
	used in drag-and-drop, so it must be performed before
	wl_data_device.start_drag. Attempting to use the source other than
	for drag-and-drop will raise a protocol error. */
DATA_SOURCE_SET_ACTIONS :: 2
data_source_set_actions :: proc "contextless" (data_source_: ^data_source, dnd_actions_: data_device_manager_dnd_action) {
	proxy_marshal_flags(cast(^proxy)data_source_, DATA_SOURCE_SET_ACTIONS, nil, proxy_get_version(cast(^proxy)data_source_), 0, dnd_actions_)
}

data_source_listener :: struct {
/* Sent when a target accepts pointer_focus or motion events.  If
	a target does not accept any of the offered types, type is NULL.

	Used for feedback during drag-and-drop. */
	target : proc "c" (data: rawptr, data_source: ^data_source, mime_type_: cstring),

/* Request for data from the client.  Send the data as the
	specified mime type over the passed file descriptor, then
	close it. */
	send : proc "c" (data: rawptr, data_source: ^data_source, mime_type_: cstring, fd_: int),

/* This data source is no longer valid. There are several reasons why
	this could happen:

	- The data source has been replaced by another data source.
	- The drag-and-drop operation was performed, but the drop destination
	  did not accept any of the mime types offered through
	  wl_data_source.target.
	- The drag-and-drop operation was performed, but the drop destination
	  did not select any of the actions present in the mask offered through
	  wl_data_source.action.
	- The drag-and-drop operation was performed but didn't happen over a
	  surface.
	- The compositor cancelled the drag-and-drop operation (e.g. compositor
	  dependent timeouts to avoid stale drag-and-drop transfers).

	The client should clean up and destroy this data source.

	For objects of version 2 or older, wl_data_source.cancelled will
	only be emitted if the data source was replaced by another data
	source. */
	cancelled : proc "c" (data: rawptr, data_source: ^data_source),

/* The user performed the drop action. This event does not indicate
	acceptance, wl_data_source.cancelled may still be emitted afterwards
	if the drop destination does not accept any mime type.

	However, this event might however not be received if the compositor
	cancelled the drag-and-drop operation before this event could happen.

	Note that the data_source may still be used in the future and should
	not be destroyed here. */
	dnd_drop_performed : proc "c" (data: rawptr, data_source: ^data_source),

/* The drop destination finished interoperating with this data
	source, so the client is now free to destroy this data source and
	free all associated data.

	If the action used to perform the operation was "move", the
	source can now delete the transferred data. */
	dnd_finished : proc "c" (data: rawptr, data_source: ^data_source),

/* This event indicates the action selected by the compositor after
	matching the source/destination side actions. Only one action (or
	none) will be offered here.

	This event can be emitted multiple times during the drag-and-drop
	operation, mainly in response to destination side changes through
	wl_data_offer.set_actions, and as the data device enters/leaves
	surfaces.

	It is only possible to receive this event after
	wl_data_source.dnd_drop_performed if the drag-and-drop operation
	ended in an "ask" action, in which case the final wl_data_source.action
	event will happen immediately before wl_data_source.dnd_finished.

	Compositors may also change the selected action on the fly, mainly
	in response to keyboard modifier changes during the drag-and-drop
	operation.

	The most recent action received is always the valid one. The chosen
	action may change alongside negotiation (e.g. an "ask" action can turn
	into a "move" operation), so the effects of the final action must
	always be applied in wl_data_offer.dnd_finished.

	Clients can trigger cursor surface changes from this point, so
	they reflect the current action. */
	action : proc "c" (data: rawptr, data_source: ^data_source, dnd_action_: data_device_manager_dnd_action),

}
data_source_add_listener :: proc "contextless" (data_source_: ^data_source, listener: ^data_source_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)data_source_, cast(^generic_c_call)listener,data)
}
/*  */
data_source_error :: enum {
	invalid_action_mask = 0,
	invalid_source = 1,
}
@(private)
data_source_requests := []message {
	{"offer", "s", raw_data(wayland_types)[0:]},
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"set_actions", "3u", raw_data(wayland_types)[0:]},
}

@(private)
data_source_events := []message {
	{"target", "?s", raw_data(wayland_types)[0:]},
	{"send", "sh", raw_data(wayland_types)[0:]},
	{"cancelled", "", raw_data(wayland_types)[0:]},
	{"dnd_drop_performed", "3", raw_data(wayland_types)[0:]},
	{"dnd_finished", "3", raw_data(wayland_types)[0:]},
	{"action", "3u", raw_data(wayland_types)[0:]},
}

data_source_interface : interface

/* There is one wl_data_device per seat which can be obtained
      from the global wl_data_device_manager singleton.

      A wl_data_device provides access to inter-client data transfer
      mechanisms such as copy-and-paste and drag-and-drop. */
data_device :: struct {}
data_device_set_user_data :: proc "contextless" (data_device_: ^data_device, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)data_device_, user_data)
}

data_device_get_user_data :: proc "contextless" (data_device_: ^data_device) -> rawptr {
   return proxy_get_user_data(cast(^proxy)data_device_)
}

/* This request asks the compositor to start a drag-and-drop
	operation on behalf of the client.

	The source argument is the data source that provides the data
	for the eventual data transfer. If source is NULL, enter, leave
	and motion events are sent only to the client that initiated the
	drag and the client is expected to handle the data passing
	internally. If source is destroyed, the drag-and-drop session will be
	cancelled.

	The origin surface is the surface where the drag originates and
	the client must have an active implicit grab that matches the
	serial.

	The icon surface is an optional (can be NULL) surface that
	provides an icon to be moved around with the cursor.  Initially,
	the top-left corner of the icon surface is placed at the cursor
	hotspot, but subsequent wl_surface.offset requests can move the
	relative position. Attach requests must be confirmed with
	wl_surface.commit as usual. The icon surface is given the role of
	a drag-and-drop icon. If the icon surface already has another role,
	it raises a protocol error.

	The input region is ignored for wl_surfaces with the role of a
	drag-and-drop icon.

	The given source may not be used in any further set_selection or
	start_drag requests. Attempting to reuse a previously-used source
	may send a used_source error. */
DATA_DEVICE_START_DRAG :: 0
data_device_start_drag :: proc "contextless" (data_device_: ^data_device, source_: ^data_source, origin_: ^surface, icon_: ^surface, serial_: uint) {
	proxy_marshal_flags(cast(^proxy)data_device_, DATA_DEVICE_START_DRAG, nil, proxy_get_version(cast(^proxy)data_device_), 0, source_, origin_, icon_, serial_)
}

/* This request asks the compositor to set the selection
	to the data from the source on behalf of the client.

	To unset the selection, set the source to NULL.

	The given source may not be used in any further set_selection or
	start_drag requests. Attempting to reuse a previously-used source
	may send a used_source error. */
DATA_DEVICE_SET_SELECTION :: 1
data_device_set_selection :: proc "contextless" (data_device_: ^data_device, source_: ^data_source, serial_: uint) {
	proxy_marshal_flags(cast(^proxy)data_device_, DATA_DEVICE_SET_SELECTION, nil, proxy_get_version(cast(^proxy)data_device_), 0, source_, serial_)
}

/* This request destroys the data device. */
DATA_DEVICE_RELEASE :: 2
data_device_release :: proc "contextless" (data_device_: ^data_device) {
	proxy_marshal_flags(cast(^proxy)data_device_, DATA_DEVICE_RELEASE, nil, proxy_get_version(cast(^proxy)data_device_), 1)
}

data_device_destroy :: proc "contextless" (data_device_: ^data_device) {
   proxy_destroy(cast(^proxy)data_device_)
}

data_device_listener :: struct {
/* The data_offer event introduces a new wl_data_offer object,
	which will subsequently be used in either the
	data_device.enter event (for drag-and-drop) or the
	data_device.selection event (for selections).  Immediately
	following the data_device.data_offer event, the new data_offer
	object will send out data_offer.offer events to describe the
	mime types it offers. */
	data_offer : proc "c" (data: rawptr, data_device: ^data_device) -> ^data_offer,

/* This event is sent when an active drag-and-drop pointer enters
	a surface owned by the client.  The position of the pointer at
	enter time is provided by the x and y arguments, in surface-local
	coordinates. */
	enter : proc "c" (data: rawptr, data_device: ^data_device, serial_: uint, surface_: ^surface, x_: fixed_t, y_: fixed_t, id_: ^data_offer),

/* This event is sent when the drag-and-drop pointer leaves the
	surface and the session ends.  The client must destroy the
	wl_data_offer introduced at enter time at this point. */
	leave : proc "c" (data: rawptr, data_device: ^data_device),

/* This event is sent when the drag-and-drop pointer moves within
	the currently focused surface. The new position of the pointer
	is provided by the x and y arguments, in surface-local
	coordinates. */
	motion : proc "c" (data: rawptr, data_device: ^data_device, time_: uint, x_: fixed_t, y_: fixed_t),

/* The event is sent when a drag-and-drop operation is ended
	because the implicit grab is removed.

	The drag-and-drop destination is expected to honor the last action
	received through wl_data_offer.action, if the resulting action is
	"copy" or "move", the destination can still perform
	wl_data_offer.receive requests, and is expected to end all
	transfers with a wl_data_offer.finish request.

	If the resulting action is "ask", the action will not be considered
	final. The drag-and-drop destination is expected to perform one last
	wl_data_offer.set_actions request, or wl_data_offer.destroy in order
	to cancel the operation. */
	drop : proc "c" (data: rawptr, data_device: ^data_device),

/* The selection event is sent out to notify the client of a new
	wl_data_offer for the selection for this device.  The
	data_device.data_offer and the data_offer.offer events are
	sent out immediately before this event to introduce the data
	offer object.  The selection event is sent to a client
	immediately before receiving keyboard focus and when a new
	selection is set while the client has keyboard focus.  The
	data_offer is valid until a new data_offer or NULL is received
	or until the client loses keyboard focus.  Switching surface with
	keyboard focus within the same client doesn't mean a new selection
	will be sent.  The client must destroy the previous selection
	data_offer, if any, upon receiving this event. */
	selection : proc "c" (data: rawptr, data_device: ^data_device, id_: ^data_offer),

}
data_device_add_listener :: proc "contextless" (data_device_: ^data_device, listener: ^data_device_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)data_device_, cast(^generic_c_call)listener,data)
}
/*  */
data_device_error :: enum {
	role = 0,
	used_source = 1,
}
@(private)
data_device_requests := []message {
	{"start_drag", "?oo?ou", raw_data(wayland_types)[21:]},
	{"set_selection", "?ou", raw_data(wayland_types)[25:]},
	{"release", "2", raw_data(wayland_types)[0:]},
}

@(private)
data_device_events := []message {
	{"data_offer", "n", raw_data(wayland_types)[27:]},
	{"enter", "uoff?o", raw_data(wayland_types)[28:]},
	{"leave", "", raw_data(wayland_types)[0:]},
	{"motion", "uff", raw_data(wayland_types)[0:]},
	{"drop", "", raw_data(wayland_types)[0:]},
	{"selection", "?o", raw_data(wayland_types)[33:]},
}

data_device_interface : interface

/* The wl_data_device_manager is a singleton global object that
      provides access to inter-client data transfer mechanisms such as
      copy-and-paste and drag-and-drop.  These mechanisms are tied to
      a wl_seat and this interface lets a client get a wl_data_device
      corresponding to a wl_seat.

      Depending on the version bound, the objects created from the bound
      wl_data_device_manager object will have different requirements for
      functioning properly. See wl_data_source.set_actions,
      wl_data_offer.accept and wl_data_offer.finish for details. */
data_device_manager :: struct {}
data_device_manager_set_user_data :: proc "contextless" (data_device_manager_: ^data_device_manager, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)data_device_manager_, user_data)
}

data_device_manager_get_user_data :: proc "contextless" (data_device_manager_: ^data_device_manager) -> rawptr {
   return proxy_get_user_data(cast(^proxy)data_device_manager_)
}

/* Create a new data source. */
DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE :: 0
data_device_manager_create_data_source :: proc "contextless" (data_device_manager_: ^data_device_manager) -> ^data_source {
	ret := proxy_marshal_flags(cast(^proxy)data_device_manager_, DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE, &data_source_interface, proxy_get_version(cast(^proxy)data_device_manager_), 0, nil)
	return cast(^data_source)ret
}

/* Create a new data device for a given seat. */
DATA_DEVICE_MANAGER_GET_DATA_DEVICE :: 1
data_device_manager_get_data_device :: proc "contextless" (data_device_manager_: ^data_device_manager, seat_: ^seat) -> ^data_device {
	ret := proxy_marshal_flags(cast(^proxy)data_device_manager_, DATA_DEVICE_MANAGER_GET_DATA_DEVICE, &data_device_interface, proxy_get_version(cast(^proxy)data_device_manager_), 0, nil, seat_)
	return cast(^data_device)ret
}

data_device_manager_destroy :: proc "contextless" (data_device_manager_: ^data_device_manager) {
   proxy_destroy(cast(^proxy)data_device_manager_)
}

/* This is a bitmask of the available/preferred actions in a
	drag-and-drop operation.

	In the compositor, the selected action is a result of matching the
	actions offered by the source and destination sides.  "action" events
	with a "none" action will be sent to both source and destination if
	there is no match. All further checks will effectively happen on
	(source actions ∩ destination actions).

	In addition, compositors may also pick different actions in
	reaction to key modifiers being pressed. One common design that
	is used in major toolkits (and the behavior recommended for
	compositors) is:

	- If no modifiers are pressed, the first match (in bit order)
	  will be used.
	- Pressing Shift selects "move", if enabled in the mask.
	- Pressing Control selects "copy", if enabled in the mask.

	Behavior beyond that is considered implementation-dependent.
	Compositors may for example bind other modifiers (like Alt/Meta)
	or drags initiated with other buttons than BTN_LEFT to specific
	actions (e.g. "ask"). */
data_device_manager_dnd_action :: enum {
	none = 0,
	copy = 1,
	move = 2,
	ask = 4,
}
@(private)
data_device_manager_requests := []message {
	{"create_data_source", "n", raw_data(wayland_types)[34:]},
	{"get_data_device", "no", raw_data(wayland_types)[35:]},
}

data_device_manager_interface : interface

/* A surface is a rectangular area that may be displayed on zero
      or more outputs, and shown any number of times at the compositor's
      discretion. They can present wl_buffers, receive user input, and
      define a local coordinate system.

      The size of a surface (and relative positions on it) is described
      in surface-local coordinates, which may differ from the buffer
      coordinates of the pixel content, in case a buffer_transform
      or a buffer_scale is used.

      A surface without a "role" is fairly useless: a compositor does
      not know where, when or how to present it. The role is the
      purpose of a wl_surface. Examples of roles are a cursor for a
      pointer (as set by wl_pointer.set_cursor), a drag icon
      (wl_data_device.start_drag), a sub-surface
      (wl_subcompositor.get_subsurface), and a window as defined by a
      shell protocol (e.g. wl_shell.get_shell_surface).

      A surface can have only one role at a time. Initially a
      wl_surface does not have a role. Once a wl_surface is given a
      role, it is set permanently for the whole lifetime of the
      wl_surface object. Giving the current role again is allowed,
      unless explicitly forbidden by the relevant interface
      specification.

      Surface roles are given by requests in other interfaces such as
      wl_pointer.set_cursor. The request should explicitly mention
      that this request gives a role to a wl_surface. Often, this
      request also creates a new protocol object that represents the
      role and adds additional functionality to wl_surface. When a
      client wants to destroy a wl_surface, they must destroy this role
      object before the wl_surface, otherwise a defunct_role_object error is
      sent.

      Destroying the role object does not remove the role from the
      wl_surface, but it may stop the wl_surface from "playing the role".
      For instance, if a wl_subsurface object is destroyed, the wl_surface
      it was created for will be unmapped and forget its position and
      z-order. It is allowed to create a wl_subsurface for the same
      wl_surface again, but it is not allowed to use the wl_surface as
      a cursor (cursor is a different role than sub-surface, and role
      switching is not allowed). */
surface :: struct {}
surface_set_user_data :: proc "contextless" (surface_: ^surface, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)surface_, user_data)
}

surface_get_user_data :: proc "contextless" (surface_: ^surface) -> rawptr {
   return proxy_get_user_data(cast(^proxy)surface_)
}

/* Deletes the surface and invalidates its object ID. */
SURFACE_DESTROY :: 0
surface_destroy :: proc "contextless" (surface_: ^surface) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_DESTROY, nil, proxy_get_version(cast(^proxy)surface_), 1)
}

/* Set a buffer as the content of this surface.

	The new size of the surface is calculated based on the buffer
	size transformed by the inverse buffer_transform and the
	inverse buffer_scale. This means that at commit time the supplied
	buffer size must be an integer multiple of the buffer_scale. If
	that's not the case, an invalid_size error is sent.

	The x and y arguments specify the location of the new pending
	buffer's upper left corner, relative to the current buffer's upper
	left corner, in surface-local coordinates. In other words, the
	x and y, combined with the new surface size define in which
	directions the surface's size changes. Setting anything other than 0
	as x and y arguments is discouraged, and should instead be replaced
	with using the separate wl_surface.offset request.

	When the bound wl_surface version is 5 or higher, passing any
	non-zero x or y is a protocol violation, and will result in an
	'invalid_offset' error being raised. The x and y arguments are ignored
	and do not change the pending state. To achieve equivalent semantics,
	use wl_surface.offset.

	Surface contents are double-buffered state, see wl_surface.commit.

	The initial surface contents are void; there is no content.
	wl_surface.attach assigns the given wl_buffer as the pending
	wl_buffer. wl_surface.commit makes the pending wl_buffer the new
	surface contents, and the size of the surface becomes the size
	calculated from the wl_buffer, as described above. After commit,
	there is no pending buffer until the next attach.

	Committing a pending wl_buffer allows the compositor to read the
	pixels in the wl_buffer. The compositor may access the pixels at
	any time after the wl_surface.commit request. When the compositor
	will not access the pixels anymore, it will send the
	wl_buffer.release event. Only after receiving wl_buffer.release,
	the client may reuse the wl_buffer. A wl_buffer that has been
	attached and then replaced by another attach instead of committed
	will not receive a release event, and is not used by the
	compositor.

	If a pending wl_buffer has been committed to more than one wl_surface,
	the delivery of wl_buffer.release events becomes undefined. A well
	behaved client should not rely on wl_buffer.release events in this
	case. Alternatively, a client could create multiple wl_buffer objects
	from the same backing storage or use wp_linux_buffer_release.

	Destroying the wl_buffer after wl_buffer.release does not change
	the surface contents. Destroying the wl_buffer before wl_buffer.release
	is allowed as long as the underlying buffer storage isn't re-used (this
	can happen e.g. on client process termination). However, if the client
	destroys the wl_buffer before receiving the wl_buffer.release event and
	mutates the underlying buffer storage, the surface contents become
	undefined immediately.

	If wl_surface.attach is sent with a NULL wl_buffer, the
	following wl_surface.commit will remove the surface content.

	If a pending wl_buffer has been destroyed, the result is not specified.
	Many compositors are known to remove the surface content on the following
	wl_surface.commit, but this behaviour is not universal. Clients seeking to
	maximise compatibility should not destroy pending buffers and should
	ensure that they explicitly remove content from surfaces, even after
	destroying buffers. */
SURFACE_ATTACH :: 1
surface_attach :: proc "contextless" (surface_: ^surface, buffer_: ^buffer, x_: int, y_: int) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_ATTACH, nil, proxy_get_version(cast(^proxy)surface_), 0, buffer_, x_, y_)
}

/* This request is used to describe the regions where the pending
	buffer is different from the current surface contents, and where
	the surface therefore needs to be repainted. The compositor
	ignores the parts of the damage that fall outside of the surface.

	Damage is double-buffered state, see wl_surface.commit.

	The damage rectangle is specified in surface-local coordinates,
	where x and y specify the upper left corner of the damage rectangle.

	The initial value for pending damage is empty: no damage.
	wl_surface.damage adds pending damage: the new pending damage
	is the union of old pending damage and the given rectangle.

	wl_surface.commit assigns pending damage as the current damage,
	and clears pending damage. The server will clear the current
	damage as it repaints the surface.

	Note! New clients should not use this request. Instead damage can be
	posted with wl_surface.damage_buffer which uses buffer coordinates
	instead of surface coordinates. */
SURFACE_DAMAGE :: 2
surface_damage :: proc "contextless" (surface_: ^surface, x_: int, y_: int, width_: int, height_: int) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_DAMAGE, nil, proxy_get_version(cast(^proxy)surface_), 0, x_, y_, width_, height_)
}

/* Request a notification when it is a good time to start drawing a new
	frame, by creating a frame callback. This is useful for throttling
	redrawing operations, and driving animations.

	When a client is animating on a wl_surface, it can use the 'frame'
	request to get notified when it is a good time to draw and commit the
	next frame of animation. If the client commits an update earlier than
	that, it is likely that some updates will not make it to the display,
	and the client is wasting resources by drawing too often.

	The frame request will take effect on the next wl_surface.commit.
	The notification will only be posted for one frame unless
	requested again. For a wl_surface, the notifications are posted in
	the order the frame requests were committed.

	The server must send the notifications so that a client
	will not send excessive updates, while still allowing
	the highest possible update rate for clients that wait for the reply
	before drawing again. The server should give some time for the client
	to draw and commit after sending the frame callback events to let it
	hit the next output refresh.

	A server should avoid signaling the frame callbacks if the
	surface is not visible in any way, e.g. the surface is off-screen,
	or completely obscured by other opaque surfaces.

	The object returned by this request will be destroyed by the
	compositor after the callback is fired and as such the client must not
	attempt to use it after that point.

	The callback_data passed in the callback is the current time, in
	milliseconds, with an undefined base. */
SURFACE_FRAME :: 3
surface_frame :: proc "contextless" (surface_: ^surface) -> ^callback {
	ret := proxy_marshal_flags(cast(^proxy)surface_, SURFACE_FRAME, &callback_interface, proxy_get_version(cast(^proxy)surface_), 0, nil)
	return cast(^callback)ret
}

/* This request sets the region of the surface that contains
	opaque content.

	The opaque region is an optimization hint for the compositor
	that lets it optimize the redrawing of content behind opaque
	regions.  Setting an opaque region is not required for correct
	behaviour, but marking transparent content as opaque will result
	in repaint artifacts.

	The opaque region is specified in surface-local coordinates.

	The compositor ignores the parts of the opaque region that fall
	outside of the surface.

	Opaque region is double-buffered state, see wl_surface.commit.

	wl_surface.set_opaque_region changes the pending opaque region.
	wl_surface.commit copies the pending region to the current region.
	Otherwise, the pending and current regions are never changed.

	The initial value for an opaque region is empty. Setting the pending
	opaque region has copy semantics, and the wl_region object can be
	destroyed immediately. A NULL wl_region causes the pending opaque
	region to be set to empty. */
SURFACE_SET_OPAQUE_REGION :: 4
surface_set_opaque_region :: proc "contextless" (surface_: ^surface, region_: ^region) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_SET_OPAQUE_REGION, nil, proxy_get_version(cast(^proxy)surface_), 0, region_)
}

/* This request sets the region of the surface that can receive
	pointer and touch events.

	Input events happening outside of this region will try the next
	surface in the server surface stack. The compositor ignores the
	parts of the input region that fall outside of the surface.

	The input region is specified in surface-local coordinates.

	Input region is double-buffered state, see wl_surface.commit.

	wl_surface.set_input_region changes the pending input region.
	wl_surface.commit copies the pending region to the current region.
	Otherwise the pending and current regions are never changed,
	except cursor and icon surfaces are special cases, see
	wl_pointer.set_cursor and wl_data_device.start_drag.

	The initial value for an input region is infinite. That means the
	whole surface will accept input. Setting the pending input region
	has copy semantics, and the wl_region object can be destroyed
	immediately. A NULL wl_region causes the input region to be set
	to infinite. */
SURFACE_SET_INPUT_REGION :: 5
surface_set_input_region :: proc "contextless" (surface_: ^surface, region_: ^region) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_SET_INPUT_REGION, nil, proxy_get_version(cast(^proxy)surface_), 0, region_)
}

/* Surface state (input, opaque, and damage regions, attached buffers,
	etc.) is double-buffered. Protocol requests modify the pending state,
	as opposed to the active state in use by the compositor.

	A commit request atomically creates a content update from the pending
	state, even if the pending state has not been touched. The content
	update is placed in a queue until it becomes active. After commit, the
	new pending state is as documented for each related request.

	When the content update is applied, the wl_buffer is applied before all
	other state. This means that all coordinates in double-buffered state
	are relative to the newly attached wl_buffers, except for
	wl_surface.attach itself. If there is no newly attached wl_buffer, the
	coordinates are relative to the previous content update.

	All requests that need a commit to become effective are documented
	to affect double-buffered state.

	Other interfaces may add further double-buffered surface state. */
SURFACE_COMMIT :: 6
surface_commit :: proc "contextless" (surface_: ^surface) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_COMMIT, nil, proxy_get_version(cast(^proxy)surface_), 0)
}

/* This request sets the transformation that the client has already applied
	to the content of the buffer. The accepted values for the transform
	parameter are the values for wl_output.transform.

	The compositor applies the inverse of this transformation whenever it
	uses the buffer contents.

	Buffer transform is double-buffered state, see wl_surface.commit.

	A newly created surface has its buffer transformation set to normal.

	wl_surface.set_buffer_transform changes the pending buffer
	transformation. wl_surface.commit copies the pending buffer
	transformation to the current one. Otherwise, the pending and current
	values are never changed.

	The purpose of this request is to allow clients to render content
	according to the output transform, thus permitting the compositor to
	use certain optimizations even if the display is rotated. Using
	hardware overlays and scanning out a client buffer for fullscreen
	surfaces are examples of such optimizations. Those optimizations are
	highly dependent on the compositor implementation, so the use of this
	request should be considered on a case-by-case basis.

	Note that if the transform value includes 90 or 270 degree rotation,
	the width of the buffer will become the surface height and the height
	of the buffer will become the surface width.

	If transform is not one of the values from the
	wl_output.transform enum the invalid_transform protocol error
	is raised. */
SURFACE_SET_BUFFER_TRANSFORM :: 7
surface_set_buffer_transform :: proc "contextless" (surface_: ^surface, transform_: output_transform) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_SET_BUFFER_TRANSFORM, nil, proxy_get_version(cast(^proxy)surface_), 0, transform_)
}

/* This request sets an optional scaling factor on how the compositor
	interprets the contents of the buffer attached to the window.

	Buffer scale is double-buffered state, see wl_surface.commit.

	A newly created surface has its buffer scale set to 1.

	wl_surface.set_buffer_scale changes the pending buffer scale.
	wl_surface.commit copies the pending buffer scale to the current one.
	Otherwise, the pending and current values are never changed.

	The purpose of this request is to allow clients to supply higher
	resolution buffer data for use on high resolution outputs. It is
	intended that you pick the same buffer scale as the scale of the
	output that the surface is displayed on. This means the compositor
	can avoid scaling when rendering the surface on that output.

	Note that if the scale is larger than 1, then you have to attach
	a buffer that is larger (by a factor of scale in each dimension)
	than the desired surface size.

	If scale is not greater than 0 the invalid_scale protocol error is
	raised. */
SURFACE_SET_BUFFER_SCALE :: 8
surface_set_buffer_scale :: proc "contextless" (surface_: ^surface, scale_: int) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_SET_BUFFER_SCALE, nil, proxy_get_version(cast(^proxy)surface_), 0, scale_)
}

/* This request is used to describe the regions where the pending
	buffer is different from the current surface contents, and where
	the surface therefore needs to be repainted. The compositor
	ignores the parts of the damage that fall outside of the surface.

	Damage is double-buffered state, see wl_surface.commit.

	The damage rectangle is specified in buffer coordinates,
	where x and y specify the upper left corner of the damage rectangle.

	The initial value for pending damage is empty: no damage.
	wl_surface.damage_buffer adds pending damage: the new pending
	damage is the union of old pending damage and the given rectangle.

	wl_surface.commit assigns pending damage as the current damage,
	and clears pending damage. The server will clear the current
	damage as it repaints the surface.

	This request differs from wl_surface.damage in only one way - it
	takes damage in buffer coordinates instead of surface-local
	coordinates. While this generally is more intuitive than surface
	coordinates, it is especially desirable when using wp_viewport
	or when a drawing library (like EGL) is unaware of buffer scale
	and buffer transform.

	Note: Because buffer transformation changes and damage requests may
	be interleaved in the protocol stream, it is impossible to determine
	the actual mapping between surface and buffer damage until
	wl_surface.commit time. Therefore, compositors wishing to take both
	kinds of damage into account will have to accumulate damage from the
	two requests separately and only transform from one to the other
	after receiving the wl_surface.commit. */
SURFACE_DAMAGE_BUFFER :: 9
surface_damage_buffer :: proc "contextless" (surface_: ^surface, x_: int, y_: int, width_: int, height_: int) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_DAMAGE_BUFFER, nil, proxy_get_version(cast(^proxy)surface_), 0, x_, y_, width_, height_)
}

/* The x and y arguments specify the location of the new pending
	buffer's upper left corner, relative to the current buffer's upper
	left corner, in surface-local coordinates. In other words, the
	x and y, combined with the new surface size define in which
	directions the surface's size changes.

	The exact semantics of wl_surface.offset are role-specific. Refer to
	the documentation of specific roles for more information.

	Surface location offset is double-buffered state, see
	wl_surface.commit.

	This request is semantically equivalent to and the replaces the x and y
	arguments in the wl_surface.attach request in wl_surface versions prior
	to 5. See wl_surface.attach for details. */
SURFACE_OFFSET :: 10
surface_offset :: proc "contextless" (surface_: ^surface, x_: int, y_: int) {
	proxy_marshal_flags(cast(^proxy)surface_, SURFACE_OFFSET, nil, proxy_get_version(cast(^proxy)surface_), 0, x_, y_)
}

surface_listener :: struct {
/* This is emitted whenever a surface's creation, movement, or resizing
	results in some part of it being within the scanout region of an
	output.

	Note that a surface may be overlapping with zero or more outputs. */
	enter : proc "c" (data: rawptr, surface: ^surface, output_: ^output),

/* This is emitted whenever a surface's creation, movement, or resizing
	results in it no longer having any part of it within the scanout region
	of an output.

	Clients should not use the number of outputs the surface is on for frame
	throttling purposes. The surface might be hidden even if no leave event
	has been sent, and the compositor might expect new surface content
	updates even if no enter event has been sent. The frame event should be
	used instead. */
	leave : proc "c" (data: rawptr, surface: ^surface, output_: ^output),

/* This event indicates the preferred buffer scale for this surface. It is
	sent whenever the compositor's preference changes.

	Before receiving this event the preferred buffer scale for this surface
	is 1.

	It is intended that scaling aware clients use this event to scale their
	content and use wl_surface.set_buffer_scale to indicate the scale they
	have rendered with. This allows clients to supply a higher detail
	buffer.

	The compositor shall emit a scale value greater than 0. */
	preferred_buffer_scale : proc "c" (data: rawptr, surface: ^surface, factor_: int),

/* This event indicates the preferred buffer transform for this surface.
	It is sent whenever the compositor's preference changes.

	Before receiving this event the preferred buffer transform for this
	surface is normal.

	Applying this transformation to the surface buffer contents and using
	wl_surface.set_buffer_transform might allow the compositor to use the
	surface buffer more efficiently. */
	preferred_buffer_transform : proc "c" (data: rawptr, surface: ^surface, transform_: output_transform),

}
surface_add_listener :: proc "contextless" (surface_: ^surface, listener: ^surface_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)surface_, cast(^generic_c_call)listener,data)
}
/* These errors can be emitted in response to wl_surface requests. */
surface_error :: enum {
	invalid_scale = 0,
	invalid_transform = 1,
	invalid_size = 2,
	invalid_offset = 3,
	defunct_role_object = 4,
}
@(private)
surface_requests := []message {
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"attach", "?oii", raw_data(wayland_types)[37:]},
	{"damage", "iiii", raw_data(wayland_types)[0:]},
	{"frame", "n", raw_data(wayland_types)[40:]},
	{"set_opaque_region", "?o", raw_data(wayland_types)[41:]},
	{"set_input_region", "?o", raw_data(wayland_types)[42:]},
	{"commit", "", raw_data(wayland_types)[0:]},
	{"set_buffer_transform", "2i", raw_data(wayland_types)[0:]},
	{"set_buffer_scale", "3i", raw_data(wayland_types)[0:]},
	{"damage_buffer", "4iiii", raw_data(wayland_types)[0:]},
	{"offset", "5ii", raw_data(wayland_types)[0:]},
}

@(private)
surface_events := []message {
	{"enter", "o", raw_data(wayland_types)[43:]},
	{"leave", "o", raw_data(wayland_types)[44:]},
	{"preferred_buffer_scale", "6i", raw_data(wayland_types)[0:]},
	{"preferred_buffer_transform", "6u", raw_data(wayland_types)[0:]},
}

surface_interface : interface

/* A seat is a group of keyboards, pointer and touch devices. This
      object is published as a global during start up, or when such a
      device is hot plugged.  A seat typically has a pointer and
      maintains a keyboard focus and a pointer focus. */
seat :: struct {}
seat_set_user_data :: proc "contextless" (seat_: ^seat, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)seat_, user_data)
}

seat_get_user_data :: proc "contextless" (seat_: ^seat) -> rawptr {
   return proxy_get_user_data(cast(^proxy)seat_)
}

/* The ID provided will be initialized to the wl_pointer interface
	for this seat.

	This request only takes effect if the seat has the pointer
	capability, or has had the pointer capability in the past.
	It is a protocol violation to issue this request on a seat that has
	never had the pointer capability. The missing_capability error will
	be sent in this case. */
SEAT_GET_POINTER :: 0
seat_get_pointer :: proc "contextless" (seat_: ^seat) -> ^pointer {
	ret := proxy_marshal_flags(cast(^proxy)seat_, SEAT_GET_POINTER, &pointer_interface, proxy_get_version(cast(^proxy)seat_), 0, nil)
	return cast(^pointer)ret
}

/* The ID provided will be initialized to the wl_keyboard interface
	for this seat.

	This request only takes effect if the seat has the keyboard
	capability, or has had the keyboard capability in the past.
	It is a protocol violation to issue this request on a seat that has
	never had the keyboard capability. The missing_capability error will
	be sent in this case. */
SEAT_GET_KEYBOARD :: 1
seat_get_keyboard :: proc "contextless" (seat_: ^seat) -> ^keyboard {
	ret := proxy_marshal_flags(cast(^proxy)seat_, SEAT_GET_KEYBOARD, &keyboard_interface, proxy_get_version(cast(^proxy)seat_), 0, nil)
	return cast(^keyboard)ret
}

/* The ID provided will be initialized to the wl_touch interface
	for this seat.

	This request only takes effect if the seat has the touch
	capability, or has had the touch capability in the past.
	It is a protocol violation to issue this request on a seat that has
	never had the touch capability. The missing_capability error will
	be sent in this case. */
SEAT_GET_TOUCH :: 2
seat_get_touch :: proc "contextless" (seat_: ^seat) -> ^touch {
	ret := proxy_marshal_flags(cast(^proxy)seat_, SEAT_GET_TOUCH, &touch_interface, proxy_get_version(cast(^proxy)seat_), 0, nil)
	return cast(^touch)ret
}

/* Using this request a client can tell the server that it is not going to
	use the seat object anymore. */
SEAT_RELEASE :: 3
seat_release :: proc "contextless" (seat_: ^seat) {
	proxy_marshal_flags(cast(^proxy)seat_, SEAT_RELEASE, nil, proxy_get_version(cast(^proxy)seat_), 1)
}

seat_destroy :: proc "contextless" (seat_: ^seat) {
   proxy_destroy(cast(^proxy)seat_)
}

seat_listener :: struct {
/* This is emitted whenever a seat gains or loses the pointer,
	keyboard or touch capabilities.  The argument is a capability
	enum containing the complete set of capabilities this seat has.

	When the pointer capability is added, a client may create a
	wl_pointer object using the wl_seat.get_pointer request. This object
	will receive pointer events until the capability is removed in the
	future.

	When the pointer capability is removed, a client should destroy the
	wl_pointer objects associated with the seat where the capability was
	removed, using the wl_pointer.release request. No further pointer
	events will be received on these objects.

	In some compositors, if a seat regains the pointer capability and a
	client has a previously obtained wl_pointer object of version 4 or
	less, that object may start sending pointer events again. This
	behavior is considered a misinterpretation of the intended behavior
	and must not be relied upon by the client. wl_pointer objects of
	version 5 or later must not send events if created before the most
	recent event notifying the client of an added pointer capability.

	The above behavior also applies to wl_keyboard and wl_touch with the
	keyboard and touch capabilities, respectively. */
	capabilities : proc "c" (data: rawptr, seat: ^seat, capabilities_: seat_capability),

/* In a multi-seat configuration the seat name can be used by clients to
	help identify which physical devices the seat represents.

	The seat name is a UTF-8 string with no convention defined for its
	contents. Each name is unique among all wl_seat globals. The name is
	only guaranteed to be unique for the current compositor instance.

	The same seat names are used for all clients. Thus, the name can be
	shared across processes to refer to a specific wl_seat global.

	The name event is sent after binding to the seat global. This event is
	only sent once per seat object, and the name does not change over the
	lifetime of the wl_seat global.

	Compositors may re-use the same seat name if the wl_seat global is
	destroyed and re-created later. */
	name : proc "c" (data: rawptr, seat: ^seat, name_: cstring),

}
seat_add_listener :: proc "contextless" (seat_: ^seat, listener: ^seat_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)seat_, cast(^generic_c_call)listener,data)
}
/* This is a bitmask of capabilities this seat has; if a member is
	set, then it is present on the seat. */
seat_capability :: enum {
	pointer = 1,
	keyboard = 2,
	touch = 4,
}
/* These errors can be emitted in response to wl_seat requests. */
seat_error :: enum {
	missing_capability = 0,
}
@(private)
seat_requests := []message {
	{"get_pointer", "n", raw_data(wayland_types)[45:]},
	{"get_keyboard", "n", raw_data(wayland_types)[46:]},
	{"get_touch", "n", raw_data(wayland_types)[47:]},
	{"release", "5", raw_data(wayland_types)[0:]},
}

@(private)
seat_events := []message {
	{"capabilities", "u", raw_data(wayland_types)[0:]},
	{"name", "2s", raw_data(wayland_types)[0:]},
}

seat_interface : interface

/* The wl_pointer interface represents one or more input devices,
      such as mice, which control the pointer location and pointer_focus
      of a seat.

      The wl_pointer interface generates motion, enter and leave
      events for the surfaces that the pointer is located over,
      and button and axis events for button presses, button releases
      and scrolling. */
pointer :: struct {}
pointer_set_user_data :: proc "contextless" (pointer_: ^pointer, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)pointer_, user_data)
}

pointer_get_user_data :: proc "contextless" (pointer_: ^pointer) -> rawptr {
   return proxy_get_user_data(cast(^proxy)pointer_)
}

/* Set the pointer surface, i.e., the surface that contains the
	pointer image (cursor). This request gives the surface the role
	of a cursor. If the surface already has another role, it raises
	a protocol error.

	The cursor actually changes only if the pointer
	focus for this device is one of the requesting client's surfaces
	or the surface parameter is the current pointer surface. If
	there was a previous surface set with this request it is
	replaced. If surface is NULL, the pointer image is hidden.

	The parameters hotspot_x and hotspot_y define the position of
	the pointer surface relative to the pointer location. Its
	top-left corner is always at (x, y) - (hotspot_x, hotspot_y),
	where (x, y) are the coordinates of the pointer location, in
	surface-local coordinates.

	On wl_surface.offset requests to the pointer surface, hotspot_x
	and hotspot_y are decremented by the x and y parameters
	passed to the request. The offset must be applied by
	wl_surface.commit as usual.

	The hotspot can also be updated by passing the currently set
	pointer surface to this request with new values for hotspot_x
	and hotspot_y.

	The input region is ignored for wl_surfaces with the role of
	a cursor. When the use as a cursor ends, the wl_surface is
	unmapped.

	The serial parameter must match the latest wl_pointer.enter
	serial number sent to the client. Otherwise the request will be
	ignored. */
POINTER_SET_CURSOR :: 0
pointer_set_cursor :: proc "contextless" (pointer_: ^pointer, serial_: uint, surface_: ^surface, hotspot_x_: int, hotspot_y_: int) {
	proxy_marshal_flags(cast(^proxy)pointer_, POINTER_SET_CURSOR, nil, proxy_get_version(cast(^proxy)pointer_), 0, serial_, surface_, hotspot_x_, hotspot_y_)
}

/* Using this request a client can tell the server that it is not going to
	use the pointer object anymore.

	This request destroys the pointer proxy object, so clients must not call
	wl_pointer_destroy() after using this request. */
POINTER_RELEASE :: 1
pointer_release :: proc "contextless" (pointer_: ^pointer) {
	proxy_marshal_flags(cast(^proxy)pointer_, POINTER_RELEASE, nil, proxy_get_version(cast(^proxy)pointer_), 1)
}

pointer_destroy :: proc "contextless" (pointer_: ^pointer) {
   proxy_destroy(cast(^proxy)pointer_)
}

pointer_listener :: struct {
/* Notification that this seat's pointer is focused on a certain
	surface.

	When a seat's focus enters a surface, the pointer image
	is undefined and a client should respond to this event by setting
	an appropriate pointer image with the set_cursor request. */
	enter : proc "c" (data: rawptr, pointer: ^pointer, serial_: uint, surface_: ^surface, surface_x_: fixed_t, surface_y_: fixed_t),

/* Notification that this seat's pointer is no longer focused on
	a certain surface.

	The leave notification is sent before the enter notification
	for the new focus. */
	leave : proc "c" (data: rawptr, pointer: ^pointer, serial_: uint, surface_: ^surface),

/* Notification of pointer location change. The arguments
	surface_x and surface_y are the location relative to the
	focused surface. */
	motion : proc "c" (data: rawptr, pointer: ^pointer, time_: uint, surface_x_: fixed_t, surface_y_: fixed_t),

/* Mouse button click and release notifications.

	The location of the click is given by the last motion or
	enter event.
	The time argument is a timestamp with millisecond
	granularity, with an undefined base.

	The button is a button code as defined in the Linux kernel's
	linux/input-event-codes.h header file, e.g. BTN_LEFT.

	Any 16-bit button code value is reserved for future additions to the
	kernel's event code list. All other button codes above 0xFFFF are
	currently undefined but may be used in future versions of this
	protocol. */
	button : proc "c" (data: rawptr, pointer: ^pointer, serial_: uint, time_: uint, button_: uint, state_: pointer_button_state),

/* Scroll and other axis notifications.

	For scroll events (vertical and horizontal scroll axes), the
	value parameter is the length of a vector along the specified
	axis in a coordinate space identical to those of motion events,
	representing a relative movement along the specified axis.

	For devices that support movements non-parallel to axes multiple
	axis events will be emitted.

	When applicable, for example for touch pads, the server can
	choose to emit scroll events where the motion vector is
	equivalent to a motion event vector.

	When applicable, a client can transform its content relative to the
	scroll distance. */
	axis : proc "c" (data: rawptr, pointer: ^pointer, time_: uint, axis_: pointer_axis, value_: fixed_t),

/* Indicates the end of a set of events that logically belong together.
	A client is expected to accumulate the data in all events within the
	frame before proceeding.

	All wl_pointer events before a wl_pointer.frame event belong
	logically together. For example, in a diagonal scroll motion the
	compositor will send an optional wl_pointer.axis_source event, two
	wl_pointer.axis events (horizontal and vertical) and finally a
	wl_pointer.frame event. The client may use this information to
	calculate a diagonal vector for scrolling.

	When multiple wl_pointer.axis events occur within the same frame,
	the motion vector is the combined motion of all events.
	When a wl_pointer.axis and a wl_pointer.axis_stop event occur within
	the same frame, this indicates that axis movement in one axis has
	stopped but continues in the other axis.
	When multiple wl_pointer.axis_stop events occur within the same
	frame, this indicates that these axes stopped in the same instance.

	A wl_pointer.frame event is sent for every logical event group,
	even if the group only contains a single wl_pointer event.
	Specifically, a client may get a sequence: motion, frame, button,
	frame, axis, frame, axis_stop, frame.

	The wl_pointer.enter and wl_pointer.leave events are logical events
	generated by the compositor and not the hardware. These events are
	also grouped by a wl_pointer.frame. When a pointer moves from one
	surface to another, a compositor should group the
	wl_pointer.leave event within the same wl_pointer.frame.
	However, a client must not rely on wl_pointer.leave and
	wl_pointer.enter being in the same wl_pointer.frame.
	Compositor-specific policies may require the wl_pointer.leave and
	wl_pointer.enter event being split across multiple wl_pointer.frame
	groups. */
	frame : proc "c" (data: rawptr, pointer: ^pointer),

/* Source information for scroll and other axes.

	This event does not occur on its own. It is sent before a
	wl_pointer.frame event and carries the source information for
	all events within that frame.

	The source specifies how this event was generated. If the source is
	wl_pointer.axis_source.finger, a wl_pointer.axis_stop event will be
	sent when the user lifts the finger off the device.

	If the source is wl_pointer.axis_source.wheel,
	wl_pointer.axis_source.wheel_tilt or
	wl_pointer.axis_source.continuous, a wl_pointer.axis_stop event may
	or may not be sent. Whether a compositor sends an axis_stop event
	for these sources is hardware-specific and implementation-dependent;
	clients must not rely on receiving an axis_stop event for these
	scroll sources and should treat scroll sequences from these scroll
	sources as unterminated by default.

	This event is optional. If the source is unknown for a particular
	axis event sequence, no event is sent.
	Only one wl_pointer.axis_source event is permitted per frame.

	The order of wl_pointer.axis_discrete and wl_pointer.axis_source is
	not guaranteed. */
	axis_source : proc "c" (data: rawptr, pointer: ^pointer, axis_source_: pointer_axis_source),

/* Stop notification for scroll and other axes.

	For some wl_pointer.axis_source types, a wl_pointer.axis_stop event
	is sent to notify a client that the axis sequence has terminated.
	This enables the client to implement kinetic scrolling.
	See the wl_pointer.axis_source documentation for information on when
	this event may be generated.

	Any wl_pointer.axis events with the same axis_source after this
	event should be considered as the start of a new axis motion.

	The timestamp is to be interpreted identical to the timestamp in the
	wl_pointer.axis event. The timestamp value may be the same as a
	preceding wl_pointer.axis event. */
	axis_stop : proc "c" (data: rawptr, pointer: ^pointer, time_: uint, axis_: pointer_axis),

/* Discrete step information for scroll and other axes.

	This event carries the axis value of the wl_pointer.axis event in
	discrete steps (e.g. mouse wheel clicks).

	This event is deprecated with wl_pointer version 8 - this event is not
	sent to clients supporting version 8 or later.

	This event does not occur on its own, it is coupled with a
	wl_pointer.axis event that represents this axis value on a
	continuous scale. The protocol guarantees that each axis_discrete
	event is always followed by exactly one axis event with the same
	axis number within the same wl_pointer.frame. Note that the protocol
	allows for other events to occur between the axis_discrete and
	its coupled axis event, including other axis_discrete or axis
	events. A wl_pointer.frame must not contain more than one axis_discrete
	event per axis type.

	This event is optional; continuous scrolling devices
	like two-finger scrolling on touchpads do not have discrete
	steps and do not generate this event.

	The discrete value carries the directional information. e.g. a value
	of -2 is two steps towards the negative direction of this axis.

	The axis number is identical to the axis number in the associated
	axis event.

	The order of wl_pointer.axis_discrete and wl_pointer.axis_source is
	not guaranteed. */
	axis_discrete : proc "c" (data: rawptr, pointer: ^pointer, axis_: pointer_axis, discrete_: int),

/* Discrete high-resolution scroll information.

	This event carries high-resolution wheel scroll information,
	with each multiple of 120 representing one logical scroll step
	(a wheel detent). For example, an axis_value120 of 30 is one quarter of
	a logical scroll step in the positive direction, a value120 of
	-240 are two logical scroll steps in the negative direction within the
	same hardware event.
	Clients that rely on discrete scrolling should accumulate the
	value120 to multiples of 120 before processing the event.

	The value120 must not be zero.

	This event replaces the wl_pointer.axis_discrete event in clients
	supporting wl_pointer version 8 or later.

	Where a wl_pointer.axis_source event occurs in the same
	wl_pointer.frame, the axis source applies to this event.

	The order of wl_pointer.axis_value120 and wl_pointer.axis_source is
	not guaranteed. */
	axis_value120 : proc "c" (data: rawptr, pointer: ^pointer, axis_: pointer_axis, value120_: int),

/* Relative directional information of the entity causing the axis
	motion.

	For a wl_pointer.axis event, the wl_pointer.axis_relative_direction
	event specifies the movement direction of the entity causing the
	wl_pointer.axis event. For example:
	- if a user's fingers on a touchpad move down and this
	  causes a wl_pointer.axis vertical_scroll down event, the physical
	  direction is 'identical'
	- if a user's fingers on a touchpad move down and this causes a
	  wl_pointer.axis vertical_scroll up scroll up event ('natural
	  scrolling'), the physical direction is 'inverted'.

	A client may use this information to adjust scroll motion of
	components. Specifically, enabling natural scrolling causes the
	content to change direction compared to traditional scrolling.
	Some widgets like volume control sliders should usually match the
	physical direction regardless of whether natural scrolling is
	active. This event enables clients to match the scroll direction of
	a widget to the physical direction.

	This event does not occur on its own, it is coupled with a
	wl_pointer.axis event that represents this axis value.
	The protocol guarantees that each axis_relative_direction event is
	always followed by exactly one axis event with the same
	axis number within the same wl_pointer.frame. Note that the protocol
	allows for other events to occur between the axis_relative_direction
	and its coupled axis event.

	The axis number is identical to the axis number in the associated
	axis event.

	The order of wl_pointer.axis_relative_direction,
	wl_pointer.axis_discrete and wl_pointer.axis_source is not
	guaranteed. */
	axis_relative_direction : proc "c" (data: rawptr, pointer: ^pointer, axis_: pointer_axis, direction_: pointer_axis_relative_direction),

}
pointer_add_listener :: proc "contextless" (pointer_: ^pointer, listener: ^pointer_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)pointer_, cast(^generic_c_call)listener,data)
}
/*  */
pointer_error :: enum {
	role = 0,
}
/* Describes the physical state of a button that produced the button
	event. */
pointer_button_state :: enum {
	released = 0,
	pressed = 1,
}
/* Describes the axis types of scroll events. */
pointer_axis :: enum {
	vertical_scroll = 0,
	horizontal_scroll = 1,
}
/* Describes the source types for axis events. This indicates to the
	client how an axis event was physically generated; a client may
	adjust the user interface accordingly. For example, scroll events
	from a "finger" source may be in a smooth coordinate space with
	kinetic scrolling whereas a "wheel" source may be in discrete steps
	of a number of lines.

	The "continuous" axis source is a device generating events in a
	continuous coordinate space, but using something other than a
	finger. One example for this source is button-based scrolling where
	the vertical motion of a device is converted to scroll events while
	a button is held down.

	The "wheel tilt" axis source indicates that the actual device is a
	wheel but the scroll event is not caused by a rotation but a
	(usually sideways) tilt of the wheel. */
pointer_axis_source :: enum {
	wheel = 0,
	finger = 1,
	continuous = 2,
	wheel_tilt = 3,
}
/* This specifies the direction of the physical motion that caused a
	wl_pointer.axis event, relative to the wl_pointer.axis direction. */
pointer_axis_relative_direction :: enum {
	identical = 0,
	inverted = 1,
}
@(private)
pointer_requests := []message {
	{"set_cursor", "u?oii", raw_data(wayland_types)[48:]},
	{"release", "3", raw_data(wayland_types)[0:]},
}

@(private)
pointer_events := []message {
	{"enter", "uoff", raw_data(wayland_types)[52:]},
	{"leave", "uo", raw_data(wayland_types)[56:]},
	{"motion", "uff", raw_data(wayland_types)[0:]},
	{"button", "uuuu", raw_data(wayland_types)[0:]},
	{"axis", "uuf", raw_data(wayland_types)[0:]},
	{"frame", "5", raw_data(wayland_types)[0:]},
	{"axis_source", "5u", raw_data(wayland_types)[0:]},
	{"axis_stop", "5uu", raw_data(wayland_types)[0:]},
	{"axis_discrete", "5ui", raw_data(wayland_types)[0:]},
	{"axis_value120", "8ui", raw_data(wayland_types)[0:]},
	{"axis_relative_direction", "9uu", raw_data(wayland_types)[0:]},
}

pointer_interface : interface

/* The wl_keyboard interface represents one or more keyboards
      associated with a seat.

      Each wl_keyboard has the following logical state:

      - an active surface (possibly null),
      - the keys currently logically down,
      - the active modifiers,
      - the active group.

      By default, the active surface is null, the keys currently logically down
      are empty, the active modifiers and the active group are 0. */
keyboard :: struct {}
keyboard_set_user_data :: proc "contextless" (keyboard_: ^keyboard, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)keyboard_, user_data)
}

keyboard_get_user_data :: proc "contextless" (keyboard_: ^keyboard) -> rawptr {
   return proxy_get_user_data(cast(^proxy)keyboard_)
}

/*  */
KEYBOARD_RELEASE :: 0
keyboard_release :: proc "contextless" (keyboard_: ^keyboard) {
	proxy_marshal_flags(cast(^proxy)keyboard_, KEYBOARD_RELEASE, nil, proxy_get_version(cast(^proxy)keyboard_), 1)
}

keyboard_destroy :: proc "contextless" (keyboard_: ^keyboard) {
   proxy_destroy(cast(^proxy)keyboard_)
}

keyboard_listener :: struct {
/* This event provides a file descriptor to the client which can be
	memory-mapped in read-only mode to provide a keyboard mapping
	description.

	From version 7 onwards, the fd must be mapped with MAP_PRIVATE by
	the recipient, as MAP_SHARED may fail. */
	keymap : proc "c" (data: rawptr, keyboard: ^keyboard, format_: keyboard_keymap_format, fd_: int, size_: uint),

/* Notification that this seat's keyboard focus is on a certain
	surface.

	The compositor must send the wl_keyboard.modifiers event after this
	event.

	In the wl_keyboard logical state, this event sets the active surface to
	the surface argument and the keys currently logically down to the keys
	in the keys argument. The compositor must not send this event if the
	wl_keyboard already had an active surface immediately before this event.

	Clients should not use the list of pressed keys to emulate key-press
	events. The order of keys in the list is unspecified. */
	enter : proc "c" (data: rawptr, keyboard: ^keyboard, serial_: uint, surface_: ^surface, keys_: array),

/* Notification that this seat's keyboard focus is no longer on
	a certain surface.

	The leave notification is sent before the enter notification
	for the new focus.

	In the wl_keyboard logical state, this event resets all values to their
	defaults. The compositor must not send this event if the active surface
	of the wl_keyboard was not equal to the surface argument immediately
	before this event. */
	leave : proc "c" (data: rawptr, keyboard: ^keyboard, serial_: uint, surface_: ^surface),

/* A key was pressed or released.
	The time argument is a timestamp with millisecond
	granularity, with an undefined base.

	The key is a platform-specific key code that can be interpreted
	by feeding it to the keyboard mapping (see the keymap event).

	If this event produces a change in modifiers, then the resulting
	wl_keyboard.modifiers event must be sent after this event.

	In the wl_keyboard logical state, this event adds the key to the keys
	currently logically down (if the state argument is pressed) or removes
	the key from the keys currently logically down (if the state argument is
	released). The compositor must not send this event if the wl_keyboard
	did not have an active surface immediately before this event. The
	compositor must not send this event if state is pressed (resp. released)
	and the key was already logically down (resp. was not logically down)
	immediately before this event.

	Since version 10, compositors may send key events with the "repeated"
	key state when a wl_keyboard.repeat_info event with a rate argument of
	0 has been received. This allows the compositor to take over the
	responsibility of key repetition. */
	key : proc "c" (data: rawptr, keyboard: ^keyboard, serial_: uint, time_: uint, key_: uint, state_: keyboard_key_state),

/* Notifies clients that the modifier and/or group state has
	changed, and it should update its local state.

	The compositor may send this event without a surface of the client
	having keyboard focus, for example to tie modifier information to
	pointer focus instead. If a modifier event with pressed modifiers is sent
	without a prior enter event, the client can assume the modifier state is
	valid until it receives the next wl_keyboard.modifiers event. In order to
	reset the modifier state again, the compositor can send a
	wl_keyboard.modifiers event with no pressed modifiers.

	In the wl_keyboard logical state, this event updates the modifiers and
	group. */
	modifiers : proc "c" (data: rawptr, keyboard: ^keyboard, serial_: uint, mods_depressed_: uint, mods_latched_: uint, mods_locked_: uint, group_: uint),

/* Informs the client about the keyboard's repeat rate and delay.

	This event is sent as soon as the wl_keyboard object has been created,
	and is guaranteed to be received by the client before any key press
	event.

	Negative values for either rate or delay are illegal. A rate of zero
	will disable any repeating (regardless of the value of delay).

	This event can be sent later on as well with a new value if necessary,
	so clients should continue listening for the event past the creation
	of wl_keyboard. */
	repeat_info : proc "c" (data: rawptr, keyboard: ^keyboard, rate_: int, delay_: int),

}
keyboard_add_listener :: proc "contextless" (keyboard_: ^keyboard, listener: ^keyboard_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)keyboard_, cast(^generic_c_call)listener,data)
}
/* This specifies the format of the keymap provided to the
	client with the wl_keyboard.keymap event. */
keyboard_keymap_format :: enum {
	no_keymap = 0,
	xkb_v1 = 1,
}
/* Describes the physical state of a key that produced the key event.

	Since version 10, the key can be in a "repeated" pseudo-state which
	means the same as "pressed", but is used to signal repetition in the
	key event.

	The key may only enter the repeated state after entering the pressed
	state and before entering the released state. This event may be
	generated multiple times while the key is down. */
keyboard_key_state :: enum {
	released = 0,
	pressed = 1,
	repeated = 2,
}
@(private)
keyboard_requests := []message {
	{"release", "3", raw_data(wayland_types)[0:]},
}

@(private)
keyboard_events := []message {
	{"keymap", "uhu", raw_data(wayland_types)[0:]},
	{"enter", "uoa", raw_data(wayland_types)[58:]},
	{"leave", "uo", raw_data(wayland_types)[61:]},
	{"key", "uuuu", raw_data(wayland_types)[0:]},
	{"modifiers", "uuuuu", raw_data(wayland_types)[0:]},
	{"repeat_info", "4ii", raw_data(wayland_types)[0:]},
}

keyboard_interface : interface

/* The wl_touch interface represents a touchscreen
      associated with a seat.

      Touch interactions can consist of one or more contacts.
      For each contact, a series of events is generated, starting
      with a down event, followed by zero or more motion events,
      and ending with an up event. Events relating to the same
      contact point can be identified by the ID of the sequence. */
touch :: struct {}
touch_set_user_data :: proc "contextless" (touch_: ^touch, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)touch_, user_data)
}

touch_get_user_data :: proc "contextless" (touch_: ^touch) -> rawptr {
   return proxy_get_user_data(cast(^proxy)touch_)
}

/*  */
TOUCH_RELEASE :: 0
touch_release :: proc "contextless" (touch_: ^touch) {
	proxy_marshal_flags(cast(^proxy)touch_, TOUCH_RELEASE, nil, proxy_get_version(cast(^proxy)touch_), 1)
}

touch_destroy :: proc "contextless" (touch_: ^touch) {
   proxy_destroy(cast(^proxy)touch_)
}

touch_listener :: struct {
/* A new touch point has appeared on the surface. This touch point is
	assigned a unique ID. Future events from this touch point reference
	this ID. The ID ceases to be valid after a touch up event and may be
	reused in the future. */
	down : proc "c" (data: rawptr, touch: ^touch, serial_: uint, time_: uint, surface_: ^surface, id_: int, x_: fixed_t, y_: fixed_t),

/* The touch point has disappeared. No further events will be sent for
	this touch point and the touch point's ID is released and may be
	reused in a future touch down event. */
	up : proc "c" (data: rawptr, touch: ^touch, serial_: uint, time_: uint, id_: int),

/* A touch point has changed coordinates. */
	motion : proc "c" (data: rawptr, touch: ^touch, time_: uint, id_: int, x_: fixed_t, y_: fixed_t),

/* Indicates the end of a set of events that logically belong together.
	A client is expected to accumulate the data in all events within the
	frame before proceeding.

	A wl_touch.frame terminates at least one event but otherwise no
	guarantee is provided about the set of events within a frame. A client
	must assume that any state not updated in a frame is unchanged from the
	previously known state. */
	frame : proc "c" (data: rawptr, touch: ^touch),

/* Sent if the compositor decides the touch stream is a global
	gesture. No further events are sent to the clients from that
	particular gesture. Touch cancellation applies to all touch points
	currently active on this client's surface. The client is
	responsible for finalizing the touch points, future touch points on
	this surface may reuse the touch point ID.

	No frame event is required after the cancel event. */
	cancel : proc "c" (data: rawptr, touch: ^touch),

/* Sent when a touchpoint has changed its shape.

	This event does not occur on its own. It is sent before a
	wl_touch.frame event and carries the new shape information for
	any previously reported, or new touch points of that frame.

	Other events describing the touch point such as wl_touch.down,
	wl_touch.motion or wl_touch.orientation may be sent within the
	same wl_touch.frame. A client should treat these events as a single
	logical touch point update. The order of wl_touch.shape,
	wl_touch.orientation and wl_touch.motion is not guaranteed.
	A wl_touch.down event is guaranteed to occur before the first
	wl_touch.shape event for this touch ID but both events may occur within
	the same wl_touch.frame.

	A touchpoint shape is approximated by an ellipse through the major and
	minor axis length. The major axis length describes the longer diameter
	of the ellipse, while the minor axis length describes the shorter
	diameter. Major and minor are orthogonal and both are specified in
	surface-local coordinates. The center of the ellipse is always at the
	touchpoint location as reported by wl_touch.down or wl_touch.move.

	This event is only sent by the compositor if the touch device supports
	shape reports. The client has to make reasonable assumptions about the
	shape if it did not receive this event. */
	shape : proc "c" (data: rawptr, touch: ^touch, id_: int, major_: fixed_t, minor_: fixed_t),

/* Sent when a touchpoint has changed its orientation.

	This event does not occur on its own. It is sent before a
	wl_touch.frame event and carries the new shape information for
	any previously reported, or new touch points of that frame.

	Other events describing the touch point such as wl_touch.down,
	wl_touch.motion or wl_touch.shape may be sent within the
	same wl_touch.frame. A client should treat these events as a single
	logical touch point update. The order of wl_touch.shape,
	wl_touch.orientation and wl_touch.motion is not guaranteed.
	A wl_touch.down event is guaranteed to occur before the first
	wl_touch.orientation event for this touch ID but both events may occur
	within the same wl_touch.frame.

	The orientation describes the clockwise angle of a touchpoint's major
	axis to the positive surface y-axis and is normalized to the -180 to
	+180 degree range. The granularity of orientation depends on the touch
	device, some devices only support binary rotation values between 0 and
	90 degrees.

	This event is only sent by the compositor if the touch device supports
	orientation reports. */
	orientation : proc "c" (data: rawptr, touch: ^touch, id_: int, orientation_: fixed_t),

}
touch_add_listener :: proc "contextless" (touch_: ^touch, listener: ^touch_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)touch_, cast(^generic_c_call)listener,data)
}
@(private)
touch_requests := []message {
	{"release", "3", raw_data(wayland_types)[0:]},
}

@(private)
touch_events := []message {
	{"down", "uuoiff", raw_data(wayland_types)[63:]},
	{"up", "uui", raw_data(wayland_types)[0:]},
	{"motion", "uiff", raw_data(wayland_types)[0:]},
	{"frame", "", raw_data(wayland_types)[0:]},
	{"cancel", "", raw_data(wayland_types)[0:]},
	{"shape", "6iff", raw_data(wayland_types)[0:]},
	{"orientation", "6if", raw_data(wayland_types)[0:]},
}

touch_interface : interface

/* An output describes part of the compositor geometry.  The
      compositor works in the 'compositor coordinate system' and an
      output corresponds to a rectangular area in that space that is
      actually visible.  This typically corresponds to a monitor that
      displays part of the compositor space.  This object is published
      as global during start up, or when a monitor is hotplugged. */
output :: struct {}
output_set_user_data :: proc "contextless" (output_: ^output, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)output_, user_data)
}

output_get_user_data :: proc "contextless" (output_: ^output) -> rawptr {
   return proxy_get_user_data(cast(^proxy)output_)
}

/* Using this request a client can tell the server that it is not going to
	use the output object anymore. */
OUTPUT_RELEASE :: 0
output_release :: proc "contextless" (output_: ^output) {
	proxy_marshal_flags(cast(^proxy)output_, OUTPUT_RELEASE, nil, proxy_get_version(cast(^proxy)output_), 1)
}

output_destroy :: proc "contextless" (output_: ^output) {
   proxy_destroy(cast(^proxy)output_)
}

output_listener :: struct {
/* The geometry event describes geometric properties of the output.
	The event is sent when binding to the output object and whenever
	any of the properties change.

	The physical size can be set to zero if it doesn't make sense for this
	output (e.g. for projectors or virtual outputs).

	The geometry event will be followed by a done event (starting from
	version 2).

	Clients should use wl_surface.preferred_buffer_transform instead of the
	transform advertised by this event to find the preferred buffer
	transform to use for a surface.

	Note: wl_output only advertises partial information about the output
	position and identification. Some compositors, for instance those not
	implementing a desktop-style output layout or those exposing virtual
	outputs, might fake this information. Instead of using x and y, clients
	should use xdg_output.logical_position. Instead of using make and model,
	clients should use name and description. */
	geometry : proc "c" (data: rawptr, output: ^output, x_: int, y_: int, physical_width_: int, physical_height_: int, subpixel_: output_subpixel, make_: cstring, model_: cstring, transform_: output_transform),

/* The mode event describes an available mode for the output.

	The event is sent when binding to the output object and there
	will always be one mode, the current mode.  The event is sent
	again if an output changes mode, for the mode that is now
	current.  In other words, the current mode is always the last
	mode that was received with the current flag set.

	Non-current modes are deprecated. A compositor can decide to only
	advertise the current mode and never send other modes. Clients
	should not rely on non-current modes.

	The size of a mode is given in physical hardware units of
	the output device. This is not necessarily the same as
	the output size in the global compositor space. For instance,
	the output may be scaled, as described in wl_output.scale,
	or transformed, as described in wl_output.transform. Clients
	willing to retrieve the output size in the global compositor
	space should use xdg_output.logical_size instead.

	The vertical refresh rate can be set to zero if it doesn't make
	sense for this output (e.g. for virtual outputs).

	The mode event will be followed by a done event (starting from
	version 2).

	Clients should not use the refresh rate to schedule frames. Instead,
	they should use the wl_surface.frame event or the presentation-time
	protocol.

	Note: this information is not always meaningful for all outputs. Some
	compositors, such as those exposing virtual outputs, might fake the
	refresh rate or the size. */
	mode : proc "c" (data: rawptr, output: ^output, flags_: output_mode, width_: int, height_: int, refresh_: int),

/* This event is sent after all other properties have been
	sent after binding to the output object and after any
	other property changes done after that. This allows
	changes to the output properties to be seen as
	atomic, even if they happen via multiple events. */
	done : proc "c" (data: rawptr, output: ^output),

/* This event contains scaling geometry information
	that is not in the geometry event. It may be sent after
	binding the output object or if the output scale changes
	later. The compositor will emit a non-zero, positive
	value for scale. If it is not sent, the client should
	assume a scale of 1.

	A scale larger than 1 means that the compositor will
	automatically scale surface buffers by this amount
	when rendering. This is used for very high resolution
	displays where applications rendering at the native
	resolution would be too small to be legible.

	Clients should use wl_surface.preferred_buffer_scale
	instead of this event to find the preferred buffer
	scale to use for a surface.

	The scale event will be followed by a done event. */
	scale : proc "c" (data: rawptr, output: ^output, factor_: int),

/* Many compositors will assign user-friendly names to their outputs, show
	them to the user, allow the user to refer to an output, etc. The client
	may wish to know this name as well to offer the user similar behaviors.

	The name is a UTF-8 string with no convention defined for its contents.
	Each name is unique among all wl_output globals. The name is only
	guaranteed to be unique for the compositor instance.

	The same output name is used for all clients for a given wl_output
	global. Thus, the name can be shared across processes to refer to a
	specific wl_output global.

	The name is not guaranteed to be persistent across sessions, thus cannot
	be used to reliably identify an output in e.g. configuration files.

	Examples of names include 'HDMI-A-1', 'WL-1', 'X11-1', etc. However, do
	not assume that the name is a reflection of an underlying DRM connector,
	X11 connection, etc.

	The name event is sent after binding the output object. This event is
	only sent once per output object, and the name does not change over the
	lifetime of the wl_output global.

	Compositors may re-use the same output name if the wl_output global is
	destroyed and re-created later. Compositors should avoid re-using the
	same name if possible.

	The name event will be followed by a done event. */
	name : proc "c" (data: rawptr, output: ^output, name_: cstring),

/* Many compositors can produce human-readable descriptions of their
	outputs. The client may wish to know this description as well, e.g. for
	output selection purposes.

	The description is a UTF-8 string with no convention defined for its
	contents. The description is not guaranteed to be unique among all
	wl_output globals. Examples might include 'Foocorp 11" Display' or
	'Virtual X11 output via :1'.

	The description event is sent after binding the output object and
	whenever the description changes. The description is optional, and may
	not be sent at all.

	The description event will be followed by a done event. */
	description : proc "c" (data: rawptr, output: ^output, description_: cstring),

}
output_add_listener :: proc "contextless" (output_: ^output, listener: ^output_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)output_, cast(^generic_c_call)listener,data)
}
/* This enumeration describes how the physical
	pixels on an output are laid out. */
output_subpixel :: enum {
	unknown = 0,
	none = 1,
	horizontal_rgb = 2,
	horizontal_bgr = 3,
	vertical_rgb = 4,
	vertical_bgr = 5,
}
/* This describes transformations that clients and compositors apply to
	buffer contents.

	The flipped values correspond to an initial flip around a
	vertical axis followed by rotation.

	The purpose is mainly to allow clients to render accordingly and
	tell the compositor, so that for fullscreen surfaces, the
	compositor will still be able to scan out directly from client
	surfaces. */
output_transform :: enum {
	normal = 0,
	_90 = 1,
	_180 = 2,
	_270 = 3,
	flipped = 4,
	flipped_90 = 5,
	flipped_180 = 6,
	flipped_270 = 7,
}
/* These flags describe properties of an output mode.
	They are used in the flags bitfield of the mode event. */
output_mode :: enum {
	current = 0x1,
	preferred = 0x2,
}
@(private)
output_requests := []message {
	{"release", "3", raw_data(wayland_types)[0:]},
}

@(private)
output_events := []message {
	{"geometry", "iiiiissi", raw_data(wayland_types)[0:]},
	{"mode", "uiii", raw_data(wayland_types)[0:]},
	{"done", "2", raw_data(wayland_types)[0:]},
	{"scale", "2i", raw_data(wayland_types)[0:]},
	{"name", "4s", raw_data(wayland_types)[0:]},
	{"description", "4s", raw_data(wayland_types)[0:]},
}

output_interface : interface

/* A region object describes an area.

      Region objects are used to describe the opaque and input
      regions of a surface. */
region :: struct {}
region_set_user_data :: proc "contextless" (region_: ^region, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)region_, user_data)
}

region_get_user_data :: proc "contextless" (region_: ^region) -> rawptr {
   return proxy_get_user_data(cast(^proxy)region_)
}

/* Destroy the region.  This will invalidate the object ID. */
REGION_DESTROY :: 0
region_destroy :: proc "contextless" (region_: ^region) {
	proxy_marshal_flags(cast(^proxy)region_, REGION_DESTROY, nil, proxy_get_version(cast(^proxy)region_), 1)
}

/* Add the specified rectangle to the region. */
REGION_ADD :: 1
region_add :: proc "contextless" (region_: ^region, x_: int, y_: int, width_: int, height_: int) {
	proxy_marshal_flags(cast(^proxy)region_, REGION_ADD, nil, proxy_get_version(cast(^proxy)region_), 0, x_, y_, width_, height_)
}

/* Subtract the specified rectangle from the region. */
REGION_SUBTRACT :: 2
region_subtract :: proc "contextless" (region_: ^region, x_: int, y_: int, width_: int, height_: int) {
	proxy_marshal_flags(cast(^proxy)region_, REGION_SUBTRACT, nil, proxy_get_version(cast(^proxy)region_), 0, x_, y_, width_, height_)
}

@(private)
region_requests := []message {
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"add", "iiii", raw_data(wayland_types)[0:]},
	{"subtract", "iiii", raw_data(wayland_types)[0:]},
}

region_interface : interface

/* The global interface exposing sub-surface compositing capabilities.
      A wl_surface, that has sub-surfaces associated, is called the
      parent surface. Sub-surfaces can be arbitrarily nested and create
      a tree of sub-surfaces.

      The root surface in a tree of sub-surfaces is the main
      surface. The main surface cannot be a sub-surface, because
      sub-surfaces must always have a parent.

      A main surface with its sub-surfaces forms a (compound) window.
      For window management purposes, this set of wl_surface objects is
      to be considered as a single window, and it should also behave as
      such.

      The aim of sub-surfaces is to offload some of the compositing work
      within a window from clients to the compositor. A prime example is
      a video player with decorations and video in separate wl_surface
      objects. This should allow the compositor to pass YUV video buffer
      processing to dedicated overlay hardware when possible. */
subcompositor :: struct {}
subcompositor_set_user_data :: proc "contextless" (subcompositor_: ^subcompositor, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)subcompositor_, user_data)
}

subcompositor_get_user_data :: proc "contextless" (subcompositor_: ^subcompositor) -> rawptr {
   return proxy_get_user_data(cast(^proxy)subcompositor_)
}

/* Informs the server that the client will not be using this
	protocol object anymore. This does not affect any other
	objects, wl_subsurface objects included. */
SUBCOMPOSITOR_DESTROY :: 0
subcompositor_destroy :: proc "contextless" (subcompositor_: ^subcompositor) {
	proxy_marshal_flags(cast(^proxy)subcompositor_, SUBCOMPOSITOR_DESTROY, nil, proxy_get_version(cast(^proxy)subcompositor_), 1)
}

/* Create a sub-surface interface for the given surface, and
	associate it with the given parent surface. This turns a
	plain wl_surface into a sub-surface.

	The to-be sub-surface must not already have another role, and it
	must not have an existing wl_subsurface object. Otherwise the
	bad_surface protocol error is raised.

	Adding sub-surfaces to a parent is a double-buffered operation on the
	parent (see wl_surface.commit). The effect of adding a sub-surface
	becomes visible on the next time the state of the parent surface is
	applied.

	The parent surface must not be one of the child surface's descendants,
	and the parent must be different from the child surface, otherwise the
	bad_parent protocol error is raised.

	This request modifies the behaviour of wl_surface.commit request on
	the sub-surface, see the documentation on wl_subsurface interface. */
SUBCOMPOSITOR_GET_SUBSURFACE :: 1
subcompositor_get_subsurface :: proc "contextless" (subcompositor_: ^subcompositor, surface_: ^surface, parent_: ^surface) -> ^subsurface {
	ret := proxy_marshal_flags(cast(^proxy)subcompositor_, SUBCOMPOSITOR_GET_SUBSURFACE, &subsurface_interface, proxy_get_version(cast(^proxy)subcompositor_), 0, nil, surface_, parent_)
	return cast(^subsurface)ret
}

/*  */
subcompositor_error :: enum {
	bad_surface = 0,
	bad_parent = 1,
}
@(private)
subcompositor_requests := []message {
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"get_subsurface", "noo", raw_data(wayland_types)[69:]},
}

subcompositor_interface : interface

/* An additional interface to a wl_surface object, which has been
      made a sub-surface. A sub-surface has one parent surface. A
      sub-surface's size and position are not limited to that of the parent.
      Particularly, a sub-surface is not automatically clipped to its
      parent's area.

      A sub-surface becomes mapped, when a non-NULL wl_buffer is applied
      and the parent surface is mapped. The order of which one happens
      first is irrelevant. A sub-surface is hidden if the parent becomes
      hidden, or if a NULL wl_buffer is applied. These rules apply
      recursively through the tree of surfaces.

      The behaviour of a wl_surface.commit request on a sub-surface
      depends on the sub-surface's mode. The possible modes are
      synchronized and desynchronized, see methods
      wl_subsurface.set_sync and wl_subsurface.set_desync. Synchronized
      mode caches the wl_surface state to be applied when the parent's
      state gets applied, and desynchronized mode applies the pending
      wl_surface state directly. A sub-surface is initially in the
      synchronized mode.

      Sub-surfaces also have another kind of state, which is managed by
      wl_subsurface requests, as opposed to wl_surface requests. This
      state includes the sub-surface position relative to the parent
      surface (wl_subsurface.set_position), and the stacking order of
      the parent and its sub-surfaces (wl_subsurface.place_above and
      .place_below). This state is applied when the parent surface's
      wl_surface state is applied, regardless of the sub-surface's mode.
      As the exception, set_sync and set_desync are effective immediately.

      The main surface can be thought to be always in desynchronized mode,
      since it does not have a parent in the sub-surfaces sense.

      Even if a sub-surface is in desynchronized mode, it will behave as
      in synchronized mode, if its parent surface behaves as in
      synchronized mode. This rule is applied recursively throughout the
      tree of surfaces. This means, that one can set a sub-surface into
      synchronized mode, and then assume that all its child and grand-child
      sub-surfaces are synchronized, too, without explicitly setting them.

      Destroying a sub-surface takes effect immediately. If you need to
      synchronize the removal of a sub-surface to the parent surface update,
      unmap the sub-surface first by attaching a NULL wl_buffer, update parent,
      and then destroy the sub-surface.

      If the parent wl_surface object is destroyed, the sub-surface is
      unmapped.

      A sub-surface never has the keyboard focus of any seat.

      The wl_surface.offset request is ignored: clients must use set_position
      instead to move the sub-surface. */
subsurface :: struct {}
subsurface_set_user_data :: proc "contextless" (subsurface_: ^subsurface, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)subsurface_, user_data)
}

subsurface_get_user_data :: proc "contextless" (subsurface_: ^subsurface) -> rawptr {
   return proxy_get_user_data(cast(^proxy)subsurface_)
}

/* The sub-surface interface is removed from the wl_surface object
	that was turned into a sub-surface with a
	wl_subcompositor.get_subsurface request. The wl_surface's association
	to the parent is deleted. The wl_surface is unmapped immediately. */
SUBSURFACE_DESTROY :: 0
subsurface_destroy :: proc "contextless" (subsurface_: ^subsurface) {
	proxy_marshal_flags(cast(^proxy)subsurface_, SUBSURFACE_DESTROY, nil, proxy_get_version(cast(^proxy)subsurface_), 1)
}

/* This schedules a sub-surface position change.
	The sub-surface will be moved so that its origin (top left
	corner pixel) will be at the location x, y of the parent surface
	coordinate system. The coordinates are not restricted to the parent
	surface area. Negative values are allowed.

	The scheduled coordinates will take effect whenever the state of the
	parent surface is applied.

	If more than one set_position request is invoked by the client before
	the commit of the parent surface, the position of a new request always
	replaces the scheduled position from any previous request.

	The initial position is 0, 0. */
SUBSURFACE_SET_POSITION :: 1
subsurface_set_position :: proc "contextless" (subsurface_: ^subsurface, x_: int, y_: int) {
	proxy_marshal_flags(cast(^proxy)subsurface_, SUBSURFACE_SET_POSITION, nil, proxy_get_version(cast(^proxy)subsurface_), 0, x_, y_)
}

/* This sub-surface is taken from the stack, and put back just
	above the reference surface, changing the z-order of the sub-surfaces.
	The reference surface must be one of the sibling surfaces, or the
	parent surface. Using any other surface, including this sub-surface,
	will cause a protocol error.

	The z-order is double-buffered. Requests are handled in order and
	applied immediately to a pending state. The final pending state is
	copied to the active state the next time the state of the parent
	surface is applied.

	A new sub-surface is initially added as the top-most in the stack
	of its siblings and parent. */
SUBSURFACE_PLACE_ABOVE :: 2
subsurface_place_above :: proc "contextless" (subsurface_: ^subsurface, sibling_: ^surface) {
	proxy_marshal_flags(cast(^proxy)subsurface_, SUBSURFACE_PLACE_ABOVE, nil, proxy_get_version(cast(^proxy)subsurface_), 0, sibling_)
}

/* The sub-surface is placed just below the reference surface.
	See wl_subsurface.place_above. */
SUBSURFACE_PLACE_BELOW :: 3
subsurface_place_below :: proc "contextless" (subsurface_: ^subsurface, sibling_: ^surface) {
	proxy_marshal_flags(cast(^proxy)subsurface_, SUBSURFACE_PLACE_BELOW, nil, proxy_get_version(cast(^proxy)subsurface_), 0, sibling_)
}

/* Change the commit behaviour of the sub-surface to synchronized
	mode, also described as the parent dependent mode.

	In synchronized mode, wl_surface.commit on a sub-surface will
	accumulate the committed state in a cache, but the state will
	not be applied and hence will not change the compositor output.
	The cached state is applied to the sub-surface immediately after
	the parent surface's state is applied. This ensures atomic
	updates of the parent and all its synchronized sub-surfaces.
	Applying the cached state will invalidate the cache, so further
	parent surface commits do not (re-)apply old state.

	See wl_subsurface for the recursive effect of this mode. */
SUBSURFACE_SET_SYNC :: 4
subsurface_set_sync :: proc "contextless" (subsurface_: ^subsurface) {
	proxy_marshal_flags(cast(^proxy)subsurface_, SUBSURFACE_SET_SYNC, nil, proxy_get_version(cast(^proxy)subsurface_), 0)
}

/* Change the commit behaviour of the sub-surface to desynchronized
	mode, also described as independent or freely running mode.

	In desynchronized mode, wl_surface.commit on a sub-surface will
	apply the pending state directly, without caching, as happens
	normally with a wl_surface. Calling wl_surface.commit on the
	parent surface has no effect on the sub-surface's wl_surface
	state. This mode allows a sub-surface to be updated on its own.

	If cached state exists when wl_surface.commit is called in
	desynchronized mode, the pending state is added to the cached
	state, and applied as a whole. This invalidates the cache.

	Note: even if a sub-surface is set to desynchronized, a parent
	sub-surface may override it to behave as synchronized. For details,
	see wl_subsurface.

	If a surface's parent surface behaves as desynchronized, then
	the cached state is applied on set_desync. */
SUBSURFACE_SET_DESYNC :: 5
subsurface_set_desync :: proc "contextless" (subsurface_: ^subsurface) {
	proxy_marshal_flags(cast(^proxy)subsurface_, SUBSURFACE_SET_DESYNC, nil, proxy_get_version(cast(^proxy)subsurface_), 0)
}

/*  */
subsurface_error :: enum {
	bad_surface = 0,
}
@(private)
subsurface_requests := []message {
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"set_position", "ii", raw_data(wayland_types)[0:]},
	{"place_above", "o", raw_data(wayland_types)[72:]},
	{"place_below", "o", raw_data(wayland_types)[73:]},
	{"set_sync", "", raw_data(wayland_types)[0:]},
	{"set_desync", "", raw_data(wayland_types)[0:]},
}

subsurface_interface : interface

/* This global fixes problems with other core-protocol interfaces that
      cannot be fixed in these interfaces themselves. */
fixes :: struct {}
fixes_set_user_data :: proc "contextless" (fixes_: ^fixes, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)fixes_, user_data)
}

fixes_get_user_data :: proc "contextless" (fixes_: ^fixes) -> rawptr {
   return proxy_get_user_data(cast(^proxy)fixes_)
}

/*  */
FIXES_DESTROY :: 0
fixes_destroy :: proc "contextless" (fixes_: ^fixes) {
	proxy_marshal_flags(cast(^proxy)fixes_, FIXES_DESTROY, nil, proxy_get_version(cast(^proxy)fixes_), 1)
}

/* This request destroys a wl_registry object.

	The client should no longer use the wl_registry after making this
	request.

	The compositor will emit a wl_display.delete_id event with the object ID
	of the registry and will no longer emit any events on the registry. The
	client should re-use the object ID once it receives the
	wl_display.delete_id event. */
FIXES_DESTROY_REGISTRY :: 1
fixes_destroy_registry :: proc "contextless" (fixes_: ^fixes, registry_: ^registry) {
	proxy_marshal_flags(cast(^proxy)fixes_, FIXES_DESTROY_REGISTRY, nil, proxy_get_version(cast(^proxy)fixes_), 0, registry_)
}

@(private)
fixes_requests := []message {
	{"destroy", "", raw_data(wayland_types)[0:]},
	{"destroy_registry", "o", raw_data(wayland_types)[74:]},
}

fixes_interface : interface

@(private)
@(init)
init_interfaces_wayland :: proc "contextless" () {
	display_interface.name = "wl_display"
	display_interface.version = 1
	display_interface.method_count = 2
	display_interface.event_count = 2
	display_interface.methods = raw_data(display_requests)
	display_interface.events = raw_data(display_events)
	registry_interface.name = "wl_registry"
	registry_interface.version = 1
	registry_interface.method_count = 1
	registry_interface.event_count = 2
	registry_interface.methods = raw_data(registry_requests)
	registry_interface.events = raw_data(registry_events)
	callback_interface.name = "wl_callback"
	callback_interface.version = 1
	callback_interface.method_count = 0
	callback_interface.event_count = 1
	callback_interface.events = raw_data(callback_events)
	compositor_interface.name = "wl_compositor"
	compositor_interface.version = 6
	compositor_interface.method_count = 2
	compositor_interface.event_count = 0
	compositor_interface.methods = raw_data(compositor_requests)
	shm_pool_interface.name = "wl_shm_pool"
	shm_pool_interface.version = 2
	shm_pool_interface.method_count = 3
	shm_pool_interface.event_count = 0
	shm_pool_interface.methods = raw_data(shm_pool_requests)
	shm_interface.name = "wl_shm"
	shm_interface.version = 2
	shm_interface.method_count = 2
	shm_interface.event_count = 1
	shm_interface.methods = raw_data(shm_requests)
	shm_interface.events = raw_data(shm_events)
	buffer_interface.name = "wl_buffer"
	buffer_interface.version = 1
	buffer_interface.method_count = 1
	buffer_interface.event_count = 1
	buffer_interface.methods = raw_data(buffer_requests)
	buffer_interface.events = raw_data(buffer_events)
	data_offer_interface.name = "wl_data_offer"
	data_offer_interface.version = 3
	data_offer_interface.method_count = 5
	data_offer_interface.event_count = 3
	data_offer_interface.methods = raw_data(data_offer_requests)
	data_offer_interface.events = raw_data(data_offer_events)
	data_source_interface.name = "wl_data_source"
	data_source_interface.version = 3
	data_source_interface.method_count = 3
	data_source_interface.event_count = 6
	data_source_interface.methods = raw_data(data_source_requests)
	data_source_interface.events = raw_data(data_source_events)
	data_device_interface.name = "wl_data_device"
	data_device_interface.version = 3
	data_device_interface.method_count = 3
	data_device_interface.event_count = 6
	data_device_interface.methods = raw_data(data_device_requests)
	data_device_interface.events = raw_data(data_device_events)
	data_device_manager_interface.name = "wl_data_device_manager"
	data_device_manager_interface.version = 3
	data_device_manager_interface.method_count = 2
	data_device_manager_interface.event_count = 0
	data_device_manager_interface.methods = raw_data(data_device_manager_requests)
	surface_interface.name = "wl_surface"
	surface_interface.version = 6
	surface_interface.method_count = 11
	surface_interface.event_count = 4
	surface_interface.methods = raw_data(surface_requests)
	surface_interface.events = raw_data(surface_events)
	seat_interface.name = "wl_seat"
	seat_interface.version = 10
	seat_interface.method_count = 4
	seat_interface.event_count = 2
	seat_interface.methods = raw_data(seat_requests)
	seat_interface.events = raw_data(seat_events)
	pointer_interface.name = "wl_pointer"
	pointer_interface.version = 10
	pointer_interface.method_count = 2
	pointer_interface.event_count = 11
	pointer_interface.methods = raw_data(pointer_requests)
	pointer_interface.events = raw_data(pointer_events)
	keyboard_interface.name = "wl_keyboard"
	keyboard_interface.version = 10
	keyboard_interface.method_count = 1
	keyboard_interface.event_count = 6
	keyboard_interface.methods = raw_data(keyboard_requests)
	keyboard_interface.events = raw_data(keyboard_events)
	touch_interface.name = "wl_touch"
	touch_interface.version = 10
	touch_interface.method_count = 1
	touch_interface.event_count = 7
	touch_interface.methods = raw_data(touch_requests)
	touch_interface.events = raw_data(touch_events)
	output_interface.name = "wl_output"
	output_interface.version = 4
	output_interface.method_count = 1
	output_interface.event_count = 6
	output_interface.methods = raw_data(output_requests)
	output_interface.events = raw_data(output_events)
	region_interface.name = "wl_region"
	region_interface.version = 1
	region_interface.method_count = 3
	region_interface.event_count = 0
	region_interface.methods = raw_data(region_requests)
	subcompositor_interface.name = "wl_subcompositor"
	subcompositor_interface.version = 1
	subcompositor_interface.method_count = 2
	subcompositor_interface.event_count = 0
	subcompositor_interface.methods = raw_data(subcompositor_requests)
	subsurface_interface.name = "wl_subsurface"
	subsurface_interface.version = 1
	subsurface_interface.method_count = 6
	subsurface_interface.event_count = 0
	subsurface_interface.methods = raw_data(subsurface_requests)
	fixes_interface.name = "wl_fixes"
	fixes_interface.version = 1
	fixes_interface.method_count = 2
	fixes_interface.event_count = 0
	fixes_interface.methods = raw_data(fixes_requests)
}

// Functions from libwayland-client
import "core:c"
foreign import wl_lib "system:wayland-client"
@(default_calling_convention="c")
@(link_prefix="wl_")
foreign wl_lib {
   display_connect                           :: proc(name: cstring) -> ^display ---
   display_connect_to_fd                     :: proc(fd: int) -> ^display ---
   display_disconnect                        :: proc(display: ^display) ---
   display_get_fd                            :: proc(display: ^display) -> int ---
   display_dispatch                          :: proc(display: ^display) -> int ---
   display_dispatch_queue                    :: proc(display: ^display, queue: event_queue) -> int ---
   display_dispatch_queue_pending            :: proc(display: ^display, queue: event_queue) -> int ---
   display_dispatch_pending                  :: proc(display: ^display) -> int ---
   display_get_error                         :: proc(display: ^display) -> int ---
   display_get_protocol_error                :: proc(display: ^display, intf: ^interface, id: ^u32) -> u32 ---
   display_flush                             :: proc(display: ^display) -> int ---
   display_roundtrip_queue                   :: proc(display: ^display, queue: ^event_queue) -> int ---
   display_roundtrip                         :: proc(display: ^display) -> int ---
   display_create_queue                      :: proc(display: ^display) -> ^event_queue ---
   display_prepare_read_queue                :: proc(display: ^display, queue: ^event_queue) -> int ---
   display_prepare_read                      :: proc(display: ^display) -> int ---
   display_cancel_read                       :: proc(display: ^display) ---
   display_read_events                       :: proc(display: ^display) -> int ---
   display_set_max_buffer_size               :: proc(display: ^display, max_buffer_size: c.size_t) ---

   proxy_marshal_flags                       :: proc(p: ^proxy, opcode: uint, intf: ^interface, version: uint, flags: uint, #c_vararg args: ..any) -> ^proxy ---
   proxy_marshal                             :: proc(p: ^proxy, opcode: uint, #c_vararg args: ..any) ---
   proxy_create                              :: proc(factory: ^proxy, intf: ^interface) -> ^proxy ---
   proxy_create_wrapper                      :: proc(proxy: rawptr) -> rawptr ---
   proxy_wrapper_destroy                     :: proc(proxy_wrapper: rawptr) ---
   proxy_marshal_constructor                 :: proc(p: ^proxy, opcode: uint, intf: ^interface, #c_vararg args: ..any) -> ^proxy ---
   proxy_marshal_constructor_versioned       :: proc(p: ^proxy, opcode: uint, intf: ^interface, version: uint, #c_vararg args: ..any) -> ^proxy ---
   proxy_marshal_array_constructor           :: proc(p: ^proxy, opcode: uint, args: ^argument, intf: ^interface) -> ^proxy ---
   proxy_marshal_array_constructor_versioned :: proc(p: ^proxy, opcode: uint, args: ^argument, intf: ^interface, version: uint) -> ^proxy ---
   proxy_destroy                             :: proc(p: ^proxy) ---
   proxy_add_listener                        :: proc(p: ^proxy, impl: ^generic_c_call, data: rawptr) -> int ---
   proxy_get_listener                        :: proc(p: ^proxy) -> rawptr ---
   proxy_add_dispatcher                      :: proc(p: ^proxy, func: dispatcher_func_t, dispatcher_data: rawptr, data: rawptr) -> int ---
   proxy_set_user_data                       :: proc(p: ^proxy, user_data: rawptr) ---
   proxy_get_user_data                       :: proc(p: ^proxy) -> rawptr ---
   proxy_get_version                         :: proc(p: ^proxy) -> uint ---
   proxy_get_id                              :: proc(p: ^proxy) -> uint ---
   proxy_set_tag                             :: proc(p: ^proxy, tag: ^u8) ---
   proxy_get_tag                             :: proc(p: ^proxy) -> ^u8 ---
   proxy_get_class                           :: proc(p: ^proxy) -> ^u8 ---
   proxy_set_queue                           :: proc(p: ^proxy, queue: ^event_queue) ---
}