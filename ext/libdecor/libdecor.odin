package libdecor
import wl "../.."
import xdg "../../xdg"

foreign import libdecor_lib "system:decor-0"

// "struct libdecor" in libdecor.h
instance :: struct {}

frame :: struct {}
configuration :: struct {}

/** \class state
 *
 * \brief An object corresponding to a configured content state.
 */
state :: struct {}

error :: enum {
	COMPOSITOR_INCOMPATIBLE,
	INVALID_FRAME_CONFIGURATION,
}

window_state_bit :: enum  i32{
	ACTIVE = 0,
	MAXIMIZED = 1,
	FULLSCREEN = 2,
	TILED_LEFT = 3,
	TILED_RIGHT = 4,
	TILED_TOP = 5,
	TILED_BOTTOM = 6,
	SUSPENDED = 7,
	RESIZING = 8,
}
window_state :: distinct bit_set[window_state_bit]

resize_edge :: enum {
	NONE,
	TOP,
	BOTTOM,
	LEFT,
	TOP_LEFT,
	BOTTOM_LEFT,
	RIGHT,
	TOP_RIGHT,
	BOTTOM_RIGHT,
}

capabilities_bit :: enum {
	MOVE = 0,
	RESIZE = 1,
	MINIMIZE = 2,
	FULLSCREEN = 3,
	CLOSE = 4,
}
capabilities :: distinct bit_set[capabilities_bit]


wm_capabilities_bit :: enum {
	WINDOW_MENU = 0,
	MAXIMIZE = 1,
	FULLSCREEN = 2,
	MINIMIZE = 3
}
wm_capabilities :: distinct bit_set[wm_capabilities_bit]
interface :: struct {
	/**
	 * An error event
	 */
	error : proc "c" (instance: ^instance, error: error, message: cstring),
	/* Reserved */
	reserved0 : proc "c" (),
	reserved1 : proc "c" (),
	reserved2 : proc "c" (),
	reserved3 : proc "c" (),
	reserved4 : proc "c" (),
	reserved5 : proc "c" (),
	reserved6 : proc "c" (),
	reserved7 : proc "c" (),
	reserved8 : proc "c" (),
	reserved9 : proc "c" (),
}

/**
 * Interface for integrating a Wayland surface with libdecor.
 */
frame_interface :: struct {
	/**
	 * A new configuration was received. An application should respond to
	 * this by creating a suitable state, and apply it using
	 * frame_commit.
	 */
	configure : proc "c" (frame: ^frame,
			   configuration: ^configuration,
			   user_data: rawptr),

	/**
	 * The window was requested to be closed by the compositor.
	 */
	close : proc "c" (frame: ^frame,
		       user_data: rawptr),

	/**
	 * The window decoration asked to have the main surface to be
	 * committed. This is required when the decoration is implemented using
	 * synchronous subsurfaces.
	 */
	commit : proc "c" (frame: ^frame,
			user_data: rawptr),

	/**
	 * Any mapped popup that has a grab on the given seat should be
	 * dismissed.
	 */
	dismiss_popup : proc "c" (frame: ^frame,
			       seat_name: cstring,
			       user_data: rawptr),

	/**
	 * The recommended client region bounds for the window.
	 * This will be followed by a configure event.
	 */
	bounds : proc "c" (frame: ^frame,
			width: int,
			height: int,
			user_data: rawptr),

	/* Reserved */
	reserved0 : proc "c" (),
	reserved1 : proc "c" (),
	reserved2 : proc "c" (),
	reserved3 : proc "c" (),
	reserved4 : proc "c" (),
	reserved5 : proc "c" (),
	reserved6 : proc "c" (),
	reserved7 : proc "c" (),
	reserved8 : proc "c" (),
}

@(default_calling_convention="c")
@(link_prefix="libdecor_")
foreign libdecor_lib {
	/**
	 * Remove a reference to the libdecor instance. When the reference count
	 * reaches zero, it is freed.
	 */
	unref :: proc(instance: ^instance) ---

	/**
	 * Create a new libdecor context for the given wl_display.
	 */
	new :: proc(display: ^wl.display,
		     iface: ^interface) -> ^instance ---

	/**
	 * Create a new libdecor context for the given wl_display and attach user data.
	 */
	new_with_user_data :: proc(display: ^wl.display,
		     iface: ^interface,
		     user_data: rawptr) -> ^instance ---

	/**
	 * Get the user data associated with this libdecor context.
	 */
	get_user_data :: proc(instance: ^instance) -> rawptr ---

	/**
	 * Set the user data associated with this libdecor context.
	 */
	set_user_data :: proc(instance: ^instance, user_data: rawptr) ---

	/**
	 * Get the file descriptor used by libdecor. This is similar to
	 * wl_display_get_fd(), thus should be polled, and when data is available,
	 * dispatch() should be called.
	 */
	get_fd :: proc(instance: ^instance) -> int ---

	/**
	 * Dispatch events. This function should be called when data is available on
	 * the file descriptor returned by get_fd(). If timeout is zero, this
	 * function will never block.
	 */
	dispatch :: proc(instance: ^instance,
			  timeout: int) -> int ---

	/**
	 * Decorate the given content wl_surface.
	 *
	 * This will create an xdg_surface and an xdg_toplevel, and integrate it
	 * properly with the windowing system, including creating appropriate
	 * decorations when needed, as well as handle windowing integration events such
	 * as resizing, moving, maximizing, etc.
	 *
	 * The passed wl_surface should only contain actual application content,
	 * without any window decoration.
	 */
	decorate :: proc(instance: ^instance,
			  surface: ^wl.surface,
			  iface: ^frame_interface,
			  user_data: rawptr) -> ^frame ---

	/**
	 * Add a reference to the frame object.
	 */
	frame_ref :: proc(frame: ^frame) ---

	/**
	 * Remove a reference to the frame object. When the reference count reaches
	 * zero, the frame object is destroyed.
	 */
	frame_unref :: proc(frame: ^frame) ---

	/**
	 * Get the user data associated with this libdecor frame.
	 */
	frame_get_user_data :: proc(frame: ^frame) -> rawptr ---

	/**
	 * Set the user data associated with this libdecor frame.
	 */
	frame_set_user_data :: proc(frame: ^frame, user_data: rawptr) ---

	/**
	 * Set the visibility of the frame.
	 *
	 * If an application wants to be borderless, it can set the frame visibility to
	 * false.
	 */
	frame_set_visibility :: proc(frame: ^frame,
				      visible: bool) ---

	/**
	 * Get the visibility of the frame.
	 */
	frame_is_visible :: proc(frame: ^frame) -> bool ---


	/**
	 * Set the parent of the window.
	 *
	 * This can be used to stack multiple toplevel windows above or under each
	 * other.
	 */
	frame_set_parent :: proc(frame_: ^frame,
				  parent: ^frame) ---

	/**
	 * Set the title of the window.
	 */
	frame_set_title :: proc(frame: ^frame,
				 title: cstring) ---

	/**
	 * Get the title of the window.
	 */
	frame_get_title :: proc(frame: ^frame) -> cstring ---

	/**
	 * Set the application ID of the window.
	 */
	frame_set_app_id :: proc(frame: ^frame,
				  app_id: cstring) ---

	/**
	 * Set new capabilities of the window.
	 *
	 * This determines whether e.g. a window decoration should show a maximize
	 * button, etc.
	 *
	 * Setting a capability does not implicitly unset any other.
	 */
	frame_set_capabilities :: proc(frame: ^frame,
					capabilities: capabilities) ---

	/**
	 * Unset capabilities of the window.
	 *
	 * The opposite of frame_set_capabilities.
	 */
	frame_unset_capabilities :: proc(frame: ^frame,
					  capabilities: capabilities) ---

	/**
	 * Check whether the window has any of the given capabilities.
	 */
	frame_has_capability :: proc(frame: ^frame,
				      capabality: capabilities) -> bool ---

	/**
	 * Show the window menu.
	 */
	frame_show_window_menu :: proc(frame: ^frame,
					wl_seat: wl.seat,
					serial: u32,
					x: int,
					y: int) ---

	/**
	 * Issue a popup grab on the window. Call this when a xdg_popup is mapped, so
	 * that it can be properly dismissed by the decorations.
	 */
	frame_popup_grab :: proc(frame: ^frame,
				  seat_name: cstring) ---

	/**
	 * Release the popup grab. Call this when you unmap a popup.
	 */
	frame_popup_ungrab :: proc(frame: ^frame,
				    seat_name: cstring) ---

	/**
	 * Translate content surface local coordinates to toplevel window local
	 * coordinates.
	 *
	 * This can be used to translate surface coordinates to coordinates useful for
	 * e.g. showing the window menu, or positioning a popup.
	 */
	frame_translate_coordinate :: proc(frame: ^frame,
					    surface_x: int,
					    surface_y: int,
					    frame_x: ^int,
					    frame_y: ^int) ---

	/**
	 * Set the min content size.
	 *
	 * This translates roughly to xdg_toplevel_set_min_size().
	 */
	frame_set_min_content_size :: proc(frame: ^frame,
					    content_width: int,
					    content_height: int) ---

	/**
	 * Set the max content size.
	 *
	 * This translates roughly to xdg_toplevel_set_max_size().
	 */
	frame_set_max_content_size :: proc(frame: ^frame,
					    content_width: int,
					    content_height: int) ---

	/**
	 * Get the min content size.
	 */
	frame_get_min_content_size :: proc(frame: ^frame,
					    content_width: ^int,
					    content_height: ^int) ---

	/**
	 * Get the max content size.
	 */
	frame_get_max_content_size :: proc(frame: ^frame,
					    content_width: ^int,
					    content_height: ^int) ---

	/**
	 * Initiate an interactive resize.
	 *
	 * This roughly translates to xdg_toplevel_resize().
	 */
	frame_resize :: proc(frame: ^frame,
			      wl_seat: wl.seat,
			      serial: u32,
			      edge: resize_edge) ---

	/**
	 * Initiate an interactive move.
	 *
	 * This roughly translates to xdg_toplevel_move().
	 */
	frame_move :: proc(frame: ^frame,
			    wl_seat: wl.seat,
			    serial: u32) ---

	/**
	 * Commit a new window state. This can be called on application driven resizes
	 * when the window is floating, or in response to received configurations, i.e.
	 * from e.g. interactive resizes or state changes.
	 */
	frame_commit :: proc(frame: ^frame,
			      state: ^state,
			      configuration: ^configuration) ---

	/**
	 * Minimize the window.
	 *
	 * Roughly translates to xdg_toplevel_set_minimized().
	 */
	frame_set_minimized :: proc(frame: ^frame) ---

	/**
	 * Maximize the window.
	 *
	 * Roughly translates to xdg_toplevel_set_maximized().
	 */
	frame_set_maximized :: proc(frame: ^frame) ---

	/**
	 * Unmaximize the window.
	 *
	 * Roughly translates to xdg_toplevel_unset_maximized().
	 */
	frame_unset_maximized :: proc(frame: ^frame) ---

	/**
	 * Fullscreen the window.
	 *
	 * Roughly translates to xdg_toplevel_set_fullscreen().
	 */
	frame_set_fullscreen :: proc(frame: ^frame,
				      output: ^wl.output) ---

	/**
	 * Unfullscreen the window.
	 *
	 * Roughly translates to xdg_toplevel_unset_unfullscreen().
	 */
	frame_unset_fullscreen :: proc(frame: ^frame) ---

	/**
	 * Return true if the window is floating.
	 *
	 * A window is floating when it's not maximized, tiled, fullscreen, or in any
	 * similar way with a fixed size and state.
	 * Note that this function uses the "applied" configuration. If this function
	 * is used in the 'configure' callback, the provided configuration has to be
	 * applied via 'frame_commit' first, before it will reflect the current
	 * window state from the provided configuration.
	 */
	frame_is_floating :: proc(frame: ^frame) -> bool ---

	/**
	 * Close the window.
	 *
	 * Roughly translates to xdg_toplevel_close().
	 */
	frame_close :: proc(frame: ^frame) ---

	/**
	 * Map the window.
	 *
	 * This will eventually result in the initial configure event.
	 */
	frame_map :: proc(frame: ^frame) ---

	/**
	 * Get the associated xdg_surface for content wl_surface.
	 */
	frame_get_xdg_surface :: proc(frame: ^frame) -> ^xdg.surface ---

	/**
	 * Get the associated xdg_toplevel for the content wl_surface.
	 */
	frame_get_xdg_toplevel :: proc(frame: ^frame) -> ^xdg.toplevel ---

	/**
	 * Get the supported window manager capabilities for the window.
	 */
	frame_get_wm_capabilities :: proc(frame: ^frame) -> wm_capabilities ---

	/**
	 * Tell libdecor to set the default pointer cursor when the pointer is over an
	 * application surface. The default false.
	 */
	//set_handle_application_cursor :: proc(instance: ^instance,
	//				       handle_cursor: bool) ---

	/**
	 * Create a new content surface state.
	 */
	state_new :: proc(width: int,
			   height: int) -> ^state ---

	/**
	 * Free a content surface state.
	 */
	state_free :: proc(state: ^state) ---

	/**
	 * Get the expected size of the content for this configuration.
	 *
	 * If the configuration doesn't contain a size, false is returned.
	 */
	configuration_get_content_size :: proc(configuration: ^configuration,
						frame: ^frame,
						width: ^int,
						height: ^int) -> bool ---

	/**
	 * Get the window state for this configuration.
	 *
	 * If the configuration doesn't contain any associated window state, false is
	 * returned, and the application should assume the window state remains
	 * unchanged.
	 */
	configuration_get_window_state :: proc(configuration: ^configuration,
						window_state: ^window_state) -> bool ---

}
