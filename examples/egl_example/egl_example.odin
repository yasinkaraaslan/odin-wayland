package egl_example
import wl "../.."
import "vendor:egl"
import gl "vendor:OpenGL"
import "../../ext/libdecor"
import "base:runtime"
import "core:fmt"
import "core:os"

Size :: [2]int
global_context : runtime.Context
window : struct {
   display: ^wl.display,
   surface: ^wl.surface,
   egl_display: egl.Display,
   egl_window: ^wl.egl_window,
	egl_surface: egl.Surface,
	egl_context: egl.Context,
   compositor: ^wl.compositor,
   region: ^wl.region,
   instance: ^libdecor.instance,
   window_state: libdecor.window_state,
   maximized: bool,
   frame: ^libdecor.frame,
   size, geometry : Size
}
registry_listener := wl.registry_listener {
	global = registry_global,
	global_remove = registry_global_remove
}

iface := libdecor.interface {
	error = interface_error
}

frame_iface := libdecor.frame_interface {
	commit = frame_commit,
	close = frame_close,
	configure = frame_configure,
}
frame_close :: proc "c" (frame: ^libdecor.frame, user_data: rawptr) {
	os.exit(0)
}
frame_commit :: proc "c" (frame: ^libdecor.frame, user_data: rawptr) {
	egl.SwapBuffers(window.egl_display, window.egl_surface)
}

frame_configure :: proc "c" (frame: ^libdecor.frame, configuration: ^libdecor.configuration, user_data: rawptr) {
	context = global_context
	width, height: int
	state: ^libdecor.state

	if !libdecor.configuration_get_content_size(configuration, frame, &width, &height) {
		width = window.geometry.x
		height = window.geometry.y
	}
	if width > 0 && height > 0 {
		if !window.maximized {
			window.size = {width, height}
		}
		window.geometry = {width, height}
	}
	else if !window.maximized {
		window.geometry = window.size
	}

	wl.egl_window_resize(window.egl_window, width, height,0,0)

	state = libdecor.state_new(width, height)
	libdecor.frame_commit(frame, state, configuration)
	libdecor.state_free(state)
	window_state: libdecor.window_state
	if !libdecor.configuration_get_window_state(configuration, &window_state) do window_state = {}

	window.maximized = window_state & {.MAXIMIZED, .FULLSCREEN} != {};
}

interface_error :: proc "c" (instance: ^libdecor.instance, error: libdecor.error, message:cstring)
{
	context = global_context
	fmt.printfln("libdecor error(%v):%v", error, message)
	os.exit(1)
}

registry_global :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint, interface_name: cstring, version: uint) {
	context = global_context
	switch interface_name {
		case wl.compositor_interface.name:
			window.compositor = cast(^wl.compositor)wl.registry_bind(registry, name, &wl.compositor_interface, 4)
	}
}

registry_global_remove :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint) {
}


main :: proc() {
	global_context = context
	window = { geometry = {1280,720}, size = {1280, 720} }
	window.display = wl.display_connect(nil)
	if window.display != nil {
		fmt.println("Successfully connected to a wayland display.")
	}
	else {
		fmt.println("Failed to connect to a wayland display")
		return
	}
	registry := wl.display_get_registry(window.display)
	wl.registry_add_listener(registry, &registry_listener, nil)
	wl.display_roundtrip(window.display)
	window.surface = wl.compositor_create_surface(window.compositor)

	major, minor : i32
	egl.BindAPI(egl.OPENGL_API)
	config_attribs := []i32 {
		egl.RED_SIZE, 8,
		egl.GREEN_SIZE, 8,
		egl.BLUE_SIZE, 8,
		egl.NONE
	}

	window.egl_display = egl.GetDisplay(cast(egl.NativeDisplayType)window.display)
	if window.egl_display == nil {
		fmt.println("Failed to create egl display")
		return
	}
	egl.Initialize(window.egl_display, &major, &minor)
	fmt.printfln("EGL Major: %v, EGL Minor: %v", major, minor)

	config: egl.Config
	num_config: i32
	egl.ChooseConfig(window.egl_display, raw_data(config_attribs), &config, 1, &num_config)
	window.egl_context = egl.CreateContext(window.egl_display, config, nil, nil)
	window.egl_window = wl.egl_window_create(window.surface, window.size.x, window.size.y)
	window.egl_surface = egl.CreateWindowSurface(window.egl_display, config, cast(egl.NativeWindowType)window.egl_window, nil)
	wl.surface_commit(window.surface)
	egl.MakeCurrent(window.egl_display, window.egl_surface, window.egl_surface, window.egl_context)
	gl.load_up_to(4,6,egl.gl_set_proc_address)
	window.instance = libdecor.new(window.display, &iface)
	window.frame = libdecor.decorate(window.instance, window.surface, &frame_iface, nil)
	libdecor.frame_set_app_id(window.frame, "odin-wayland-egl")
	libdecor.frame_set_title(window.frame, "Hellope from Wayland, EGL & libdecor!")
	libdecor.frame_map(window.frame)
	wl.display_dispatch(window.display)
	// It requires calling it two times to get a configure event
	wl.display_dispatch(window.display)
	for wl.display_dispatch_pending(window.display) != -1 {
		gl.ClearColor(1.0,0.0,0.0,1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		egl.SwapBuffers(window.egl_display, window.egl_surface)
	}
}
