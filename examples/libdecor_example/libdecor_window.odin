package libdecor_example
import wl "../.."
import "../../ext/libdecor"
import "core:fmt"
import "core:sys/linux"
import "core:sys/posix"
import "core:os"
import "base:runtime"
window : struct {
   display: ^wl.display,
   surface: ^wl.surface,
   compositor: ^wl.compositor,
   shm: ^wl.shm,
   buffer: ^wl.buffer,
   instance: ^libdecor.instance,
   window_state: libdecor.window_state,
   frame: ^libdecor.frame,
   width, height, floating_width, floating_height : int,
}
global_context: runtime.Context

buffer_release :: proc "c" (data: rawptr, buffer: ^wl.buffer) {
	wl.buffer_destroy(buffer)
}
create_frame_buffer :: proc() -> ^wl.buffer {
   context = global_context
   width := window.width
   height := window.height
   stride := width * 4
   size := stride * height
   name := fmt.caprintf("/wl_shm_%v", cast(uintptr)window.display) // should be random enough hopefully
   fd := posix.shm_open(name, {.RDWR, .CREAT, .EXCL}, {.IRUSR, .IWUSR})
   defer posix.close(fd)
   if fd >= 0 {
      posix.shm_unlink(name)
   }
   else {
      fmt.println("Error: couldn't create shared memory.", posix.errno())
      return nil
   }
   ret := posix.ftruncate(auto_cast fd, auto_cast size)
   if ret == .FAIL {
      fmt.println("Error: couldn't do ftruncate on shared memory descriptor")
      return nil
   }
   data_raw, err := linux.mmap(auto_cast 0, uint(size), {.READ, .WRITE}, {.SHARED}, auto_cast fd, 0)
   defer linux.munmap(data_raw, auto_cast size)
   data := cast([^]u32)data_raw
   if err != .NONE {
      fmt.println("Error: couldn't map shared memory. ", err)
      return nil
   }

   pool := wl.shm_create_pool(window.shm, auto_cast fd, size)
   defer wl.shm_pool_destroy(pool)
   buffer := wl.shm_pool_create_buffer(pool, 0, width, height, stride, .xrgb8888)

   wl.buffer_add_listener(buffer, &buffer_listener, nil)
   color1 :u32= 0xFFFF0000 if window.window_state & {.ACTIVE} != {} else 0xFF666666
   color2 :u32= 0xFFFFEEEE if window.window_state & {.ACTIVE} != {} else 0xFFEEEEEE
   /* Draw checkerboxed background */
   for y in 0..<height {
      for x in 0..<width {
         index := y*width+x
         if (x + y / 8 * 8) % 16 < 8 do data[index] = color1;
         else do data[index] = color2;
      }
   }

   return buffer
}

registry_global :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint, interface_name: cstring, version: uint) {
   context = global_context
   switch interface_name {
      case wl.compositor_interface.name:
         window.compositor = cast(^wl.compositor)wl.registry_bind(registry, name, &wl.compositor_interface, 4)
      case wl.shm_interface.name:
        window.shm = cast(^wl.shm)wl.registry_bind(registry, name, &wl.shm_interface, 1)
   }
}
registry_global_remove :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint) {

}

interface_error :: proc "c" (instance: ^libdecor.instance, error: libdecor.error, message:cstring)
{
	context = global_context
	fmt.printfln("libdecor error(%v):%v", error, message)
	os.exit(1)
}

frame_configure :: proc "c" (frame: ^libdecor.frame, configuration: ^libdecor.configuration, user_data: rawptr) {
	context = global_context
	width := 0
	height := 0
	state: ^libdecor.state
	if !libdecor.configuration_get_window_state(configuration, &window.window_state) {
		window.window_state = {}
	}
	libdecor.configuration_get_content_size(configuration, frame, &width, &height)
	changed := window.width != width || window.height != height
	width = width if width != 0 else window.width
	height = height if height != 0 else window.height
	window.width = width
	window.height = height
	state = libdecor.state_new(width, height)
	libdecor.frame_commit(frame, state, configuration)
	libdecor.state_free(state)
	if libdecor.frame_is_floating(window.frame) {
		window.floating_width = width
		window.floating_height = height
	}

	if changed do window.buffer = create_frame_buffer()
	wl.surface_attach(window.surface, window.buffer, 0,0)
	wl.surface_damage_buffer(window.surface,0,0,window.width, window.height)
	wl.surface_commit(window.surface)
}
frame_close :: proc "c" (frame: ^libdecor.frame, user_data: rawptr) {
	os.exit(0)
}
frame_commit :: proc "c" (frame: ^libdecor.frame, user_data: rawptr) {
	wl.surface_commit(window.surface)
}
frame_dismiss_popup :: proc "c" (frame: ^libdecor.frame, seat_name: cstring, user_data: rawptr) {

}

iface := libdecor.interface {
	error = interface_error
}
frame_iface := libdecor.frame_interface {
	configure = frame_configure,
	close = frame_close,
	commit = frame_commit,
	dismiss_popup = frame_dismiss_popup
}

buffer_listener := wl.buffer_listener {
   release = buffer_release
}
registry_listener := wl.registry_listener {
	global = registry_global,
	global_remove = registry_global_remove,
}
main :: proc() {
	global_context = context
	window = { width = 800, floating_width = 800, height = 600, floating_height = 600 }
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
	window.instance = libdecor.new(window.display, &iface)

	// libdecor.set_handle_application_cursor(window.instance, true)
	window.frame = libdecor.decorate(window.instance, window.surface, &frame_iface,nil)
	libdecor.frame_set_app_id(window.frame, "odin-libdecor-window")
	libdecor.frame_set_title(window.frame, "Hellope from libdecor!")

	libdecor.frame_map(window.frame)

	for libdecor.dispatch(window.instance, -1) >= 0 {
	}

}
