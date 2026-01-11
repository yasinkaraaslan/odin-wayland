#+build linux
package wp
@(private)
linux_dmabuf_v1_types := []^interface {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	&linux_buffer_params_v1_interface,
	&linux_dmabuf_feedback_v1_interface,
	&linux_dmabuf_feedback_v1_interface,
	&wl.surface_interface,
	&wl.buffer_interface,
	nil,
	nil,
	nil,
	nil,
	&wl.buffer_interface,
}
/* This interface offers ways to create generic dmabuf-based wl_buffers.

      For more information about dmabuf, see:
      https://www.kernel.org/doc/html/next/userspace-api/dma-buf-alloc-exchange.html

      Clients can use the get_surface_feedback request to get dmabuf feedback
      for a particular surface. If the client wants to retrieve feedback not
      tied to a surface, they can use the get_default_feedback request.

      The following are required from clients:

      - Clients must ensure that either all data in the dma-buf is
        coherent for all subsequent read access or that coherency is
        correctly handled by the underlying kernel-side dma-buf
        implementation.

      - Don't make any more attachments after sending the buffer to the
        compositor. Making more attachments later increases the risk of
        the compositor not being able to use (re-import) an existing
        dmabuf-based wl_buffer.

      The underlying graphics stack must ensure the following:

      - The dmabuf file descriptors relayed to the server will stay valid
        for the whole lifetime of the wl_buffer. This means the server may
        at any time use those fds to import the dmabuf into any kernel
        sub-system that might accept it.

      However, when the underlying graphics stack fails to deliver the
      promise, because of e.g. a device hot-unplug which raises internal
      errors, after the wl_buffer has been successfully created the
      compositor must not raise protocol errors to the client when dmabuf
      import later fails.

      To create a wl_buffer from one or more dmabufs, a client creates a
      zwp_linux_dmabuf_params_v1 object with a zwp_linux_dmabuf_v1.create_params
      request. All planes required by the intended format are added with
      the 'add' request. Finally, a 'create' or 'create_immed' request is
      issued, which has the following outcome depending on the import success.

      The 'create' request,
      - on success, triggers a 'created' event which provides the final
        wl_buffer to the client.
      - on failure, triggers a 'failed' event to convey that the server
        cannot use the dmabufs received from the client.

      For the 'create_immed' request,
      - on success, the server immediately imports the added dmabufs to
        create a wl_buffer. No event is sent from the server in this case.
      - on failure, the server can choose to either:
        - terminate the client by raising a fatal error.
        - mark the wl_buffer as failed, and send a 'failed' event to the
          client. If the client uses a failed wl_buffer as an argument to any
          request, the behaviour is compositor implementation-defined.

      For all DRM formats and unless specified in another protocol extension,
      pre-multiplied alpha is used for pixel values.

      Unless specified otherwise in another protocol extension, implicit
      synchronization is used. In other words, compositors and clients must
      wait and signal fences implicitly passed via the DMA-BUF's reservation
      mechanism. */
linux_dmabuf_v1 :: struct {}
linux_dmabuf_v1_set_user_data :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)linux_dmabuf_v1_, user_data)
}

linux_dmabuf_v1_get_user_data :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1) -> rawptr {
   return proxy_get_user_data(cast(^proxy)linux_dmabuf_v1_)
}

/* Objects created through this interface, especially wl_buffers, will
        remain valid. */
LINUX_DMABUF_V1_DESTROY :: 0
linux_dmabuf_v1_destroy :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1) {
	proxy_marshal_flags(cast(^proxy)linux_dmabuf_v1_, LINUX_DMABUF_V1_DESTROY, nil, proxy_get_version(cast(^proxy)linux_dmabuf_v1_), 1)
}

/* This temporary object is used to collect multiple dmabuf handles into
        a single batch to create a wl_buffer. It can only be used once and
        should be destroyed after a 'created' or 'failed' event has been
        received. */
LINUX_DMABUF_V1_CREATE_PARAMS :: 1
linux_dmabuf_v1_create_params :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1) -> ^linux_buffer_params_v1 {
	ret := proxy_marshal_flags(cast(^proxy)linux_dmabuf_v1_, LINUX_DMABUF_V1_CREATE_PARAMS, &linux_buffer_params_v1_interface, proxy_get_version(cast(^proxy)linux_dmabuf_v1_), 0, nil)
	return cast(^linux_buffer_params_v1)ret
}

/* This request creates a new wp_linux_dmabuf_feedback object not bound
        to a particular surface. This object will deliver feedback about dmabuf
        parameters to use if the client doesn't support per-surface feedback
        (see get_surface_feedback). */
LINUX_DMABUF_V1_GET_DEFAULT_FEEDBACK :: 2
linux_dmabuf_v1_get_default_feedback :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1) -> ^linux_dmabuf_feedback_v1 {
	ret := proxy_marshal_flags(cast(^proxy)linux_dmabuf_v1_, LINUX_DMABUF_V1_GET_DEFAULT_FEEDBACK, &linux_dmabuf_feedback_v1_interface, proxy_get_version(cast(^proxy)linux_dmabuf_v1_), 0, nil)
	return cast(^linux_dmabuf_feedback_v1)ret
}

/* This request creates a new wp_linux_dmabuf_feedback object for the
        specified wl_surface. This object will deliver feedback about dmabuf
        parameters to use for buffers attached to this surface.

        If the surface is destroyed before the wp_linux_dmabuf_feedback object,
        the feedback object becomes inert. */
LINUX_DMABUF_V1_GET_SURFACE_FEEDBACK :: 3
linux_dmabuf_v1_get_surface_feedback :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1, surface_: ^wl.surface) -> ^linux_dmabuf_feedback_v1 {
	ret := proxy_marshal_flags(cast(^proxy)linux_dmabuf_v1_, LINUX_DMABUF_V1_GET_SURFACE_FEEDBACK, &linux_dmabuf_feedback_v1_interface, proxy_get_version(cast(^proxy)linux_dmabuf_v1_), 0, nil, surface_)
	return cast(^linux_dmabuf_feedback_v1)ret
}

linux_dmabuf_v1_listener :: struct {
/* This event advertises one buffer format that the server supports.
        All the supported formats are advertised once when the client
        binds to this interface. A roundtrip after binding guarantees
        that the client has received all supported formats.

        For the definition of the format codes, see the
        zwp_linux_buffer_params_v1::create request.

        Starting version 4, the format event is deprecated and must not be
        sent by compositors. Instead, use get_default_feedback or
        get_surface_feedback. */
	format : proc "c" (data: rawptr, linux_dmabuf_v1: ^linux_dmabuf_v1, format_: uint),

/* This event advertises the formats that the server supports, along with
        the modifiers supported for each format. All the supported modifiers
        for all the supported formats are advertised once when the client
        binds to this interface. A roundtrip after binding guarantees that
        the client has received all supported format-modifier pairs.

        For legacy support, DRM_FORMAT_MOD_INVALID (that is, modifier_hi ==
        0x00ffffff and modifier_lo == 0xffffffff) is allowed in this event.
        It indicates that the server can support the format with an implicit
        modifier. When a plane has DRM_FORMAT_MOD_INVALID as its modifier, it
        is as if no explicit modifier is specified. The effective modifier
        will be derived from the dmabuf.

        A compositor that sends valid modifiers and DRM_FORMAT_MOD_INVALID for
        a given format supports both explicit modifiers and implicit modifiers.

        For the definition of the format and modifier codes, see the
        zwp_linux_buffer_params_v1::create and zwp_linux_buffer_params_v1::add
        requests.

        Starting version 4, the modifier event is deprecated and must not be
        sent by compositors. Instead, use get_default_feedback or
        get_surface_feedback. */
	modifier : proc "c" (data: rawptr, linux_dmabuf_v1: ^linux_dmabuf_v1, format_: uint, modifier_hi_: uint, modifier_lo_: uint),

}
linux_dmabuf_v1_add_listener :: proc "contextless" (linux_dmabuf_v1_: ^linux_dmabuf_v1, listener: ^linux_dmabuf_v1_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)linux_dmabuf_v1_, cast(^generic_c_call)listener,data)
}
@(private)
linux_dmabuf_v1_requests := []message {
	{"destroy", "", raw_data(linux_dmabuf_v1_types)[0:]},
	{"create_params", "n", raw_data(linux_dmabuf_v1_types)[6:]},
	{"get_default_feedback", "4n", raw_data(linux_dmabuf_v1_types)[7:]},
	{"get_surface_feedback", "4no", raw_data(linux_dmabuf_v1_types)[8:]},
}

@(private)
linux_dmabuf_v1_events := []message {
	{"format", "u", raw_data(linux_dmabuf_v1_types)[0:]},
	{"modifier", "3uuu", raw_data(linux_dmabuf_v1_types)[0:]},
}

linux_dmabuf_v1_interface : interface

/* This temporary object is a collection of dmabufs and other
      parameters that together form a single logical buffer. The temporary
      object may eventually create one wl_buffer unless cancelled by
      destroying it before requesting 'create'.

      Single-planar formats only require one dmabuf, however
      multi-planar formats may require more than one dmabuf. For all
      formats, an 'add' request must be called once per plane (even if the
      underlying dmabuf fd is identical).

      You must use consecutive plane indices ('plane_idx' argument for 'add')
      from zero to the number of planes used by the drm_fourcc format code.
      All planes required by the format must be given exactly once, but can
      be given in any order. Each plane index can only be set once; subsequent
      calls with a plane index which has already been set will result in a
      plane_set error being generated. */
linux_buffer_params_v1 :: struct {}
linux_buffer_params_v1_set_user_data :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)linux_buffer_params_v1_, user_data)
}

linux_buffer_params_v1_get_user_data :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1) -> rawptr {
   return proxy_get_user_data(cast(^proxy)linux_buffer_params_v1_)
}

/* Cleans up the temporary data sent to the server for dmabuf-based
        wl_buffer creation. */
LINUX_BUFFER_PARAMS_V1_DESTROY :: 0
linux_buffer_params_v1_destroy :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1) {
	proxy_marshal_flags(cast(^proxy)linux_buffer_params_v1_, LINUX_BUFFER_PARAMS_V1_DESTROY, nil, proxy_get_version(cast(^proxy)linux_buffer_params_v1_), 1)
}

/* This request adds one dmabuf to the set in this
        zwp_linux_buffer_params_v1.

        The 64-bit unsigned value combined from modifier_hi and modifier_lo
        is the dmabuf layout modifier. DRM AddFB2 ioctl calls this the
        fb modifier, which is defined in drm_mode.h of Linux UAPI.
        This is an opaque token. Drivers use this token to express tiling,
        compression, etc. driver-specific modifications to the base format
        defined by the DRM fourcc code.

        Starting from version 4, the invalid_format protocol error is sent if
        the format + modifier pair was not advertised as supported.

        Starting from version 5, the invalid_format protocol error is sent if
        all planes don't use the same modifier.

        This request raises the PLANE_IDX error if plane_idx is too large.
        The error PLANE_SET is raised if attempting to set a plane that
        was already set. */
LINUX_BUFFER_PARAMS_V1_ADD :: 1
linux_buffer_params_v1_add :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1, fd_: int, plane_idx_: uint, offset_: uint, stride_: uint, modifier_hi_: uint, modifier_lo_: uint) {
	proxy_marshal_flags(cast(^proxy)linux_buffer_params_v1_, LINUX_BUFFER_PARAMS_V1_ADD, nil, proxy_get_version(cast(^proxy)linux_buffer_params_v1_), 0, fd_, plane_idx_, offset_, stride_, modifier_hi_, modifier_lo_)
}

/* This asks for creation of a wl_buffer from the added dmabuf
        buffers. The wl_buffer is not created immediately but returned via
        the 'created' event if the dmabuf sharing succeeds. The sharing
        may fail at runtime for reasons a client cannot predict, in
        which case the 'failed' event is triggered.

        The 'format' argument is a DRM_FORMAT code, as defined by the
        libdrm's drm_fourcc.h. The Linux kernel's DRM sub-system is the
        authoritative source on how the format codes should work.

        The 'flags' is a bitfield of the flags defined in enum "flags".
        'y_invert' means the that the image needs to be y-flipped.

        Flag 'interlaced' means that the frame in the buffer is not
        progressive as usual, but interlaced. An interlaced buffer as
        supported here must always contain both top and bottom fields.
        The top field always begins on the first pixel row. The temporal
        ordering between the two fields is top field first, unless
        'bottom_first' is specified. It is undefined whether 'bottom_first'
        is ignored if 'interlaced' is not set.

        This protocol does not convey any information about field rate,
        duration, or timing, other than the relative ordering between the
        two fields in one buffer. A compositor may have to estimate the
        intended field rate from the incoming buffer rate. It is undefined
        whether the time of receiving wl_surface.commit with a new buffer
        attached, applying the wl_surface state, wl_surface.frame callback
        trigger, presentation, or any other point in the compositor cycle
        is used to measure the frame or field times. There is no support
        for detecting missed or late frames/fields/buffers either, and
        there is no support whatsoever for cooperating with interlaced
        compositor output.

        The composited image quality resulting from the use of interlaced
        buffers is explicitly undefined. A compositor may use elaborate
        hardware features or software to deinterlace and create progressive
        output frames from a sequence of interlaced input buffers, or it
        may produce substandard image quality. However, compositors that
        cannot guarantee reasonable image quality in all cases are recommended
        to just reject all interlaced buffers.

        Any argument errors, including non-positive width or height,
        mismatch between the number of planes and the format, bad
        format, bad offset or stride, may be indicated by fatal protocol
        errors: INCOMPLETE, INVALID_FORMAT, INVALID_DIMENSIONS,
        OUT_OF_BOUNDS.

        Dmabuf import errors in the server that are not obvious client
        bugs are returned via the 'failed' event as non-fatal. This
        allows attempting dmabuf sharing and falling back in the client
        if it fails.

        This request can be sent only once in the object's lifetime, after
        which the only legal request is destroy. This object should be
        destroyed after issuing a 'create' request. Attempting to use this
        object after issuing 'create' raises ALREADY_USED protocol error.

        It is not mandatory to issue 'create'. If a client wants to
        cancel the buffer creation, it can just destroy this object. */
LINUX_BUFFER_PARAMS_V1_CREATE :: 2
linux_buffer_params_v1_create :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1, width_: int, height_: int, format_: uint, flags_: linux_buffer_params_v1_flags) {
	proxy_marshal_flags(cast(^proxy)linux_buffer_params_v1_, LINUX_BUFFER_PARAMS_V1_CREATE, nil, proxy_get_version(cast(^proxy)linux_buffer_params_v1_), 0, width_, height_, format_, flags_)
}

/* This asks for immediate creation of a wl_buffer by importing the
        added dmabufs.

        In case of import success, no event is sent from the server, and the
        wl_buffer is ready to be used by the client.

        Upon import failure, either of the following may happen, as seen fit
        by the implementation:
        - the client is terminated with one of the following fatal protocol
          errors:
          - INCOMPLETE, INVALID_FORMAT, INVALID_DIMENSIONS, OUT_OF_BOUNDS,
            in case of argument errors such as mismatch between the number
            of planes and the format, bad format, non-positive width or
            height, or bad offset or stride.
          - INVALID_WL_BUFFER, in case the cause for failure is unknown or
            platform specific.
        - the server creates an invalid wl_buffer, marks it as failed and
          sends a 'failed' event to the client. The result of using this
          invalid wl_buffer as an argument in any request by the client is
          defined by the compositor implementation.

        This takes the same arguments as a 'create' request, and obeys the
        same restrictions. */
LINUX_BUFFER_PARAMS_V1_CREATE_IMMED :: 3
linux_buffer_params_v1_create_immed :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1, width_: int, height_: int, format_: uint, flags_: linux_buffer_params_v1_flags) -> ^wl.buffer {
	ret := proxy_marshal_flags(cast(^proxy)linux_buffer_params_v1_, LINUX_BUFFER_PARAMS_V1_CREATE_IMMED, &wl.buffer_interface, proxy_get_version(cast(^proxy)linux_buffer_params_v1_), 0, nil, width_, height_, format_, flags_)
	return cast(^wl.buffer)ret
}

linux_buffer_params_v1_listener :: struct {
/* This event indicates that the attempted buffer creation was
        successful. It provides the new wl_buffer referencing the dmabuf(s).

        Upon receiving this event, the client should destroy the
        zwp_linux_buffer_params_v1 object. */
	created : proc "c" (data: rawptr, linux_buffer_params_v1: ^linux_buffer_params_v1) -> ^wl.buffer,

/* This event indicates that the attempted buffer creation has
        failed. It usually means that one of the dmabuf constraints
        has not been fulfilled.

        Upon receiving this event, the client should destroy the
        zwp_linux_buffer_params_v1 object. */
	failed : proc "c" (data: rawptr, linux_buffer_params_v1: ^linux_buffer_params_v1),

}
linux_buffer_params_v1_add_listener :: proc "contextless" (linux_buffer_params_v1_: ^linux_buffer_params_v1, listener: ^linux_buffer_params_v1_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)linux_buffer_params_v1_, cast(^generic_c_call)listener,data)
}
/*  */
linux_buffer_params_v1_error :: enum {
	already_used = 0,
	plane_idx = 1,
	plane_set = 2,
	incomplete = 3,
	invalid_format = 4,
	invalid_dimensions = 5,
	out_of_bounds = 6,
	invalid_wl_buffer = 7,
}
/*  */
linux_buffer_params_v1_flags :: enum {
	y_invert = 1,
	interlaced = 2,
	bottom_first = 4,
}
@(private)
linux_buffer_params_v1_requests := []message {
	{"destroy", "", raw_data(linux_dmabuf_v1_types)[0:]},
	{"add", "huuuuu", raw_data(linux_dmabuf_v1_types)[0:]},
	{"create", "iiuu", raw_data(linux_dmabuf_v1_types)[0:]},
	{"create_immed", "2niiuu", raw_data(linux_dmabuf_v1_types)[10:]},
}

@(private)
linux_buffer_params_v1_events := []message {
	{"created", "n", raw_data(linux_dmabuf_v1_types)[15:]},
	{"failed", "", raw_data(linux_dmabuf_v1_types)[0:]},
}

linux_buffer_params_v1_interface : interface

/* This object advertises dmabuf parameters feedback. This includes the
      preferred devices and the supported formats/modifiers.

      The parameters are sent once when this object is created and whenever they
      change. The done event is always sent once after all parameters have been
      sent. When a single parameter changes, all parameters are re-sent by the
      compositor.

      Compositors can re-send the parameters when the current client buffer
      allocations are sub-optimal. Compositors should not re-send the
      parameters if re-allocating the buffers would not result in a more optimal
      configuration. In particular, compositors should avoid sending the exact
      same parameters multiple times in a row.

      The tranche_target_device and tranche_formats events are grouped by
      tranches of preference. For each tranche, a tranche_target_device, one
      tranche_flags and one or more tranche_formats events are sent, followed
      by a tranche_done event finishing the list. The tranches are sent in
      descending order of preference. All formats and modifiers in the same
      tranche have the same preference.

      To send parameters, the compositor sends one main_device event, tranches
      (each consisting of one tranche_target_device event, one tranche_flags
      event, tranche_formats events and then a tranche_done event), then one
      done event. */
linux_dmabuf_feedback_v1 :: struct {}
linux_dmabuf_feedback_v1_set_user_data :: proc "contextless" (linux_dmabuf_feedback_v1_: ^linux_dmabuf_feedback_v1, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)linux_dmabuf_feedback_v1_, user_data)
}

linux_dmabuf_feedback_v1_get_user_data :: proc "contextless" (linux_dmabuf_feedback_v1_: ^linux_dmabuf_feedback_v1) -> rawptr {
   return proxy_get_user_data(cast(^proxy)linux_dmabuf_feedback_v1_)
}

/* Using this request a client can tell the server that it is not going to
        use the wp_linux_dmabuf_feedback object anymore. */
LINUX_DMABUF_FEEDBACK_V1_DESTROY :: 0
linux_dmabuf_feedback_v1_destroy :: proc "contextless" (linux_dmabuf_feedback_v1_: ^linux_dmabuf_feedback_v1) {
	proxy_marshal_flags(cast(^proxy)linux_dmabuf_feedback_v1_, LINUX_DMABUF_FEEDBACK_V1_DESTROY, nil, proxy_get_version(cast(^proxy)linux_dmabuf_feedback_v1_), 1)
}

linux_dmabuf_feedback_v1_listener :: struct {
/* This event is sent after all parameters of a wp_linux_dmabuf_feedback
        object have been sent.

        This allows changes to the wp_linux_dmabuf_feedback parameters to be
        seen as atomic, even if they happen via multiple events. */
	done : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1),

/* This event provides a file descriptor which can be memory-mapped to
        access the format and modifier table.

        The table contains a tightly packed array of consecutive format +
        modifier pairs. Each pair is 16 bytes wide. It contains a format as a
        32-bit unsigned integer, followed by 4 bytes of unused padding, and a
        modifier as a 64-bit unsigned integer. The native endianness is used.

        The client must map the file descriptor in read-only private mode.

        Compositors are not allowed to mutate the table file contents once this
        event has been sent. Instead, compositors must create a new, separate
        table file and re-send feedback parameters. Compositors are allowed to
        store duplicate format + modifier pairs in the table. */
	format_table : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1, fd_: int, size_: uint),

/* This event advertises the main device that the server prefers to use
        when direct scan-out to the target device isn't possible. The
        advertised main device may be different for each
        wp_linux_dmabuf_feedback object, and may change over time.

        There is exactly one main device. The compositor must send at least
        one preference tranche with tranche_target_device equal to main_device.

        Clients need to create buffers that the main device can import and
        read from, otherwise creating the dmabuf wl_buffer will fail (see the
        wp_linux_buffer_params.create and create_immed requests for details).
        The main device will also likely be kept active by the compositor,
        so clients can use it instead of waking up another device for power
        savings.

        In general the device is a DRM node. The DRM node type (primary vs.
        render) is unspecified. Clients must not rely on the compositor sending
        a particular node type. Clients cannot check two devices for equality
        by comparing the dev_t value.

        If explicit modifiers are not supported and the client performs buffer
        allocations on a different device than the main device, then the client
        must force the buffer to have a linear layout. */
	main_device : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1, device_: array),

/* This event splits tranche_target_device and tranche_formats events in
        preference tranches. It is sent after a set of tranche_target_device
        and tranche_formats events; it represents the end of a tranche. The
        next tranche will have a lower preference. */
	tranche_done : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1),

/* This event advertises the target device that the server prefers to use
        for a buffer created given this tranche. The advertised target device
        may be different for each preference tranche, and may change over time.

        There is exactly one target device per tranche.

        The target device may be a scan-out device, for example if the
        compositor prefers to directly scan-out a buffer created given this
        tranche. The target device may be a rendering device, for example if
        the compositor prefers to texture from said buffer.

        The client can use this hint to allocate the buffer in a way that makes
        it accessible from the target device, ideally directly. The buffer must
        still be accessible from the main device, either through direct import
        or through a potentially more expensive fallback path. If the buffer
        can't be directly imported from the main device then clients must be
        prepared for the compositor changing the tranche priority or making
        wl_buffer creation fail (see the wp_linux_buffer_params.create and
        create_immed requests for details).

        If the device is a DRM node, the DRM node type (primary vs. render) is
        unspecified. Clients must not rely on the compositor sending a
        particular node type. Clients cannot check two devices for equality by
        comparing the dev_t value.

        This event is tied to a preference tranche, see the tranche_done event. */
	tranche_target_device : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1, device_: array),

/* This event advertises the format + modifier combinations that the
        compositor supports.

        It carries an array of indices, each referring to a format + modifier
        pair in the last received format table (see the format_table event).
        Each index is a 16-bit unsigned integer in native endianness.

        For legacy support, DRM_FORMAT_MOD_INVALID is an allowed modifier.
        It indicates that the server can support the format with an implicit
        modifier. When a buffer has DRM_FORMAT_MOD_INVALID as its modifier, it
        is as if no explicit modifier is specified. The effective modifier
        will be derived from the dmabuf.

        A compositor that sends valid modifiers and DRM_FORMAT_MOD_INVALID for
        a given format supports both explicit modifiers and implicit modifiers.

        Compositors must not send duplicate format + modifier pairs within the
        same tranche or across two different tranches with the same target
        device and flags.

        This event is tied to a preference tranche, see the tranche_done event.

        For the definition of the format and modifier codes, see the
        wp_linux_buffer_params.create request. */
	tranche_formats : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1, indices_: array),

/* This event sets tranche-specific flags.

        The scanout flag is a hint that direct scan-out may be attempted by the
        compositor on the target device if the client appropriately allocates a
        buffer. How to allocate a buffer that can be scanned out on the target
        device is implementation-defined.

        This event is tied to a preference tranche, see the tranche_done event. */
	tranche_flags : proc "c" (data: rawptr, linux_dmabuf_feedback_v1: ^linux_dmabuf_feedback_v1, flags_: linux_dmabuf_feedback_v1_tranche_flags),

}
linux_dmabuf_feedback_v1_add_listener :: proc "contextless" (linux_dmabuf_feedback_v1_: ^linux_dmabuf_feedback_v1, listener: ^linux_dmabuf_feedback_v1_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)linux_dmabuf_feedback_v1_, cast(^generic_c_call)listener,data)
}
/*  */
linux_dmabuf_feedback_v1_tranche_flags :: enum {
	scanout = 1,
}
@(private)
linux_dmabuf_feedback_v1_requests := []message {
	{"destroy", "", raw_data(linux_dmabuf_v1_types)[0:]},
}

@(private)
linux_dmabuf_feedback_v1_events := []message {
	{"done", "", raw_data(linux_dmabuf_v1_types)[0:]},
	{"format_table", "hu", raw_data(linux_dmabuf_v1_types)[0:]},
	{"main_device", "a", raw_data(linux_dmabuf_v1_types)[0:]},
	{"tranche_done", "", raw_data(linux_dmabuf_v1_types)[0:]},
	{"tranche_target_device", "a", raw_data(linux_dmabuf_v1_types)[0:]},
	{"tranche_formats", "a", raw_data(linux_dmabuf_v1_types)[0:]},
	{"tranche_flags", "u", raw_data(linux_dmabuf_v1_types)[0:]},
}

linux_dmabuf_feedback_v1_interface : interface

@(private)
@(init)
init_interfaces_linux_dmabuf_v1 :: proc "contextless" () {
	linux_dmabuf_v1_interface.name = "zwp_linux_dmabuf_v1"
	linux_dmabuf_v1_interface.version = 5
	linux_dmabuf_v1_interface.method_count = 4
	linux_dmabuf_v1_interface.event_count = 2
	linux_dmabuf_v1_interface.methods = raw_data(linux_dmabuf_v1_requests)
	linux_dmabuf_v1_interface.events = raw_data(linux_dmabuf_v1_events)
	linux_buffer_params_v1_interface.name = "zwp_linux_buffer_params_v1"
	linux_buffer_params_v1_interface.version = 5
	linux_buffer_params_v1_interface.method_count = 4
	linux_buffer_params_v1_interface.event_count = 2
	linux_buffer_params_v1_interface.methods = raw_data(linux_buffer_params_v1_requests)
	linux_buffer_params_v1_interface.events = raw_data(linux_buffer_params_v1_events)
	linux_dmabuf_feedback_v1_interface.name = "zwp_linux_dmabuf_feedback_v1"
	linux_dmabuf_feedback_v1_interface.version = 5
	linux_dmabuf_feedback_v1_interface.method_count = 1
	linux_dmabuf_feedback_v1_interface.event_count = 7
	linux_dmabuf_feedback_v1_interface.methods = raw_data(linux_dmabuf_feedback_v1_requests)
	linux_dmabuf_feedback_v1_interface.events = raw_data(linux_dmabuf_feedback_v1_events)
}

// Functions from libwayland-client
import wl "shared:wayland"
