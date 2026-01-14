#+build linux
package wp
@(private)
presentation_time_types := []^interface {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	&presentation_feedback_interface,
	&wl.surface_interface,
	&wl.output_interface,
}
/* The main feature of this interface is accurate presentation
      timing feedback to ensure smooth video playback while maintaining
      audio/video synchronization. Some features use the concept of a
      presentation clock, which is defined in the
      presentation.clock_id event.

      A content update for a wl_surface is submitted by a
      wl_surface.commit request. Request 'feedback' associates with
      the wl_surface.commit and provides feedback on the content
      update, particularly the final realized presentation time.

<!-- Completing presentation -->

      When the final realized presentation time is available, e.g.
      after a framebuffer flip completes, the requested
      presentation_feedback.presented events are sent. The final
      presentation time can differ from the compositor's predicted
      display update time and the update's target time, especially
      when the compositor misses its target vertical blanking period. */
presentation :: struct {}
presentation_set_user_data :: proc "contextless" (presentation_: ^presentation, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)presentation_, user_data)
}

presentation_get_user_data :: proc "contextless" (presentation_: ^presentation) -> rawptr {
   return proxy_get_user_data(cast(^proxy)presentation_)
}

/* Informs the server that the client will no longer be using
        this protocol object. Existing objects created by this object
        are not affected. */
PRESENTATION_DESTROY :: 0
presentation_destroy :: proc "contextless" (presentation_: ^presentation) {
	proxy_marshal_flags(cast(^proxy)presentation_, PRESENTATION_DESTROY, nil, proxy_get_version(cast(^proxy)presentation_), 1)
}

/* Request presentation feedback for the current content submission
        on the given surface. This creates a new presentation_feedback
        object, which will deliver the feedback information once. If
        multiple presentation_feedback objects are created for the same
        submission, they will all deliver the same information.

        For details on what information is returned, see the
        presentation_feedback interface. */
PRESENTATION_GET_FEEDBACK :: 1
presentation_get_feedback :: proc "contextless" (presentation_: ^presentation, surface_: ^wl.surface) -> ^presentation_feedback {
	ret := proxy_marshal_flags(cast(^proxy)presentation_, PRESENTATION_GET_FEEDBACK, &presentation_feedback_interface, proxy_get_version(cast(^proxy)presentation_), 0, nil, surface_)
	return cast(^presentation_feedback)ret
}

presentation_listener :: struct {
/* This event tells the client in which clock domain the
        compositor interprets the timestamps used by the presentation
        extension. This clock is called the presentation clock.

        The compositor sends this event when the client binds to the
        presentation interface. The presentation clock does not change
        during the lifetime of the client connection.

        The clock identifier is platform dependent. On POSIX platforms, the
        identifier value is one of the clockid_t values accepted by
        clock_gettime(). clock_gettime() is defined by POSIX.1-2001.

        Timestamps in this clock domain are expressed as tv_sec_hi,
        tv_sec_lo, tv_nsec triples, each component being an unsigned
        32-bit value. Whole seconds are in tv_sec which is a 64-bit
        value combined from tv_sec_hi and tv_sec_lo, and the
        additional fractional part in tv_nsec as nanoseconds. Hence,
        for valid timestamps tv_nsec must be in [0, 999999999].

        Note that clock_id applies only to the presentation clock,
        and implies nothing about e.g. the timestamps used in the
        Wayland core protocol input events.

        Compositors should prefer a clock which does not jump and is
        not slewed e.g. by NTP. The absolute value of the clock is
        irrelevant. Precision of one millisecond or better is
        recommended. Clients must be able to query the current clock
        value directly, not by asking the compositor. */
	clock_id : proc "c" (data: rawptr, presentation: ^presentation, clk_id_: uint),

}
presentation_add_listener :: proc "contextless" (presentation_: ^presentation, listener: ^presentation_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)presentation_, cast(^generic_c_call)listener,data)
}
/* These fatal protocol errors may be emitted in response to
        illegal presentation requests. */
presentation_error :: enum {
	invalid_timestamp = 0,
	invalid_flag = 1,
}
@(private)
presentation_requests := []message {
	{"destroy", "", raw_data(presentation_time_types)[0:]},
	{"get_feedback", "no", raw_data(presentation_time_types)[7:]},
}

@(private)
presentation_events := []message {
	{"clock_id", "u", raw_data(presentation_time_types)[0:]},
}

presentation_interface : interface

/* A presentation_feedback object returns an indication that a
      wl_surface content update has become visible to the user.
      One object corresponds to one content update submission
      (wl_surface.commit). There are two possible outcomes: the
      content update is presented to the user, and a presentation
      timestamp delivered; or, the user did not see the content
      update because it was superseded or its surface destroyed,
      and the content update is discarded.

      Once a presentation_feedback object has delivered a 'presented'
      or 'discarded' event it is automatically destroyed. */
presentation_feedback :: struct {}
presentation_feedback_set_user_data :: proc "contextless" (presentation_feedback_: ^presentation_feedback, user_data: rawptr) {
   proxy_set_user_data(cast(^proxy)presentation_feedback_, user_data)
}

presentation_feedback_get_user_data :: proc "contextless" (presentation_feedback_: ^presentation_feedback) -> rawptr {
   return proxy_get_user_data(cast(^proxy)presentation_feedback_)
}

presentation_feedback_destroy :: proc "contextless" (presentation_feedback_: ^presentation_feedback) {
   proxy_destroy(cast(^proxy)presentation_feedback_)
}

presentation_feedback_listener :: struct {
/* As presentation can be synchronized to only one output at a
        time, this event tells which output it was. This event is only
        sent prior to the presented event.

        As clients may bind to the same global wl_output multiple
        times, this event is sent for each bound instance that matches
        the synchronized output. If a client has not bound to the
        right wl_output global at all, this event is not sent. */
	sync_output : proc "c" (data: rawptr, presentation_feedback: ^presentation_feedback, output_: ^wl.output),

/* The associated content update was displayed to the user at the
        indicated time (tv_sec_hi/lo, tv_nsec). For the interpretation of
        the timestamp, see presentation.clock_id event.

        The timestamp corresponds to the time when the content update
        turned into light the first time on the surface's main output.
        Compositors may approximate this from the framebuffer flip
        completion events from the system, and the latency of the
        physical display path if known.

        This event is preceded by all related sync_output events
        telling which output's refresh cycle the feedback corresponds
        to, i.e. the main output for the surface. Compositors are
        recommended to choose the output containing the largest part
        of the wl_surface, or keeping the output they previously
        chose. Having a stable presentation output association helps
        clients predict future output refreshes (vblank).

        The 'refresh' argument gives the compositor's prediction of how
        many nanoseconds after tv_sec, tv_nsec the very next output
        refresh may occur. This is to further aid clients in
        predicting future refreshes, i.e., estimating the timestamps
        targeting the next few vblanks. If such prediction cannot
        usefully be done, the argument is zero.

        For version 2 and later, if the output does not have a constant
        refresh rate, explicit video mode switches excluded, then the
        refresh argument must be either an appropriate rate picked by the
        compositor (e.g. fastest rate), or 0 if no such rate exists.
        For version 1, if the output does not have a constant refresh rate,
        the refresh argument must be zero.

        The 64-bit value combined from seq_hi and seq_lo is the value
        of the output's vertical retrace counter when the content
        update was first scanned out to the display. This value must
        be compatible with the definition of MSC in
        GLX_OML_sync_control specification. Note, that if the display
        path has a non-zero latency, the time instant specified by
        this counter may differ from the timestamp's.

        If the output does not have a concept of vertical retrace or a
        refresh cycle, or the output device is self-refreshing without
        a way to query the refresh count, then the arguments seq_hi
        and seq_lo must be zero. */
	presented : proc "c" (data: rawptr, presentation_feedback: ^presentation_feedback, tv_sec_hi_: uint, tv_sec_lo_: uint, tv_nsec_: uint, refresh_: uint, seq_hi_: uint, seq_lo_: uint, flags_: presentation_feedback_kind),

/* The content update was never displayed to the user. */
	discarded : proc "c" (data: rawptr, presentation_feedback: ^presentation_feedback),

}
presentation_feedback_add_listener :: proc "contextless" (presentation_feedback_: ^presentation_feedback, listener: ^presentation_feedback_listener, data: rawptr) {
	proxy_add_listener(cast(^proxy)presentation_feedback_, cast(^generic_c_call)listener,data)
}
/* These flags provide information about how the presentation of
        the related content update was done. The intent is to help
        clients assess the reliability of the feedback and the visual
        quality with respect to possible tearing and timings. */
presentation_feedback_kind :: enum {
	vsync = 0x1,
	hw_clock = 0x2,
	hw_completion = 0x4,
	zero_copy = 0x8,
}
@(private)
presentation_feedback_events := []message {
	{"sync_output", "o", raw_data(presentation_time_types)[9:]},
	{"presented", "uuuuuuu", raw_data(presentation_time_types)[0:]},
	{"discarded", "", raw_data(presentation_time_types)[0:]},
}

presentation_feedback_interface : interface

@(private)
@(init)
init_interfaces_presentation_time :: proc "contextless" () {
	presentation_interface.name = "wp_presentation"
	presentation_interface.version = 2
	presentation_interface.method_count = 2
	presentation_interface.event_count = 1
	presentation_interface.methods = raw_data(presentation_requests)
	presentation_interface.events = raw_data(presentation_events)
	presentation_feedback_interface.name = "wp_presentation_feedback"
	presentation_feedback_interface.version = 2
	presentation_feedback_interface.method_count = 0
	presentation_feedback_interface.event_count = 3
	presentation_feedback_interface.events = raw_data(presentation_feedback_events)
}

// Functions from libwayland-client
import wl ".."
fixed_t :: wl.fixed_t
proxy :: wl.proxy
message :: wl.message
interface :: wl.interface
array :: wl.array
generic_c_call :: wl.generic_c_call
proxy_add_listener :: wl.proxy_add_listener
proxy_get_listener :: wl.proxy_get_listener
proxy_get_user_data :: wl.proxy_get_user_data
proxy_set_user_data :: wl.proxy_set_user_data
proxy_get_version :: wl.proxy_get_version
proxy_marshal :: wl.proxy_marshal
proxy_marshal_flags :: wl.proxy_marshal_flags
proxy_marshal_constructor :: wl.proxy_marshal_constructor
proxy_destroy :: wl.proxy_destroy
