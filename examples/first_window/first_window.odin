// Taken from wayland-book.com
package first_window
import wl "../.."
import "../../xdg"
import "core:fmt"
import "base:runtime"
import "core:sys/linux"
import "core:sys/posix"

window : struct {
   display: ^wl.display,
   surface: ^wl.surface,
   compositor: ^wl.compositor,
   shm: ^wl.shm,
   xdg_surface: ^xdg.surface,
   wm_base: ^xdg.wm_base,
   toplevel: ^xdg.toplevel,
   buffer: ^wl.buffer
}
global_context: runtime.Context

buffer_release :: proc "c" (data: rawptr, buffer: ^wl.buffer) {
	wl.buffer_destroy(buffer)
}
create_frame_buffer :: proc() -> ^wl.buffer {
   context = global_context
   width := 800
   height := 600
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
      fmt.println("Error: couldn't map shared memory")
      return nil
   }

   pool := wl.shm_create_pool(window.shm, auto_cast fd, size)
   defer wl.shm_pool_destroy(pool)
   buffer := wl.shm_pool_create_buffer(pool, 0, width, height, stride, .xrgb8888)
   /* Draw checkerboxed background */
   for y in 0..<height {
      for x in 0..<width {
         index := y*width+x
         if (x + y / 8 * 8) % 16 < 8 do data[index] = 0xFF666666;
         else do data[index] = 0xFFEEEEEE;
      }
   }

   return buffer
}

surface_configure :: proc "c" (data: rawptr, surface: ^xdg.surface, serial: uint) {
   context = global_context
   xdg.surface_ack_configure(surface, serial)
   if window.buffer == nil do window.buffer = create_frame_buffer()
   wl.surface_attach(window.surface, window.buffer, 0,0)
   wl.surface_commit(window.surface)
}

wm_base_ping :: proc "c" (data: rawptr, wm_base: ^xdg.wm_base, serial: uint) {
   xdg.wm_base_pong(wm_base, serial)
}

registry_global :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint, interface_name: cstring, version: uint) {
   context = global_context
   switch interface_name {
      case wl.compositor_interface.name:
         window.compositor = cast(^wl.compositor)wl.registry_bind(registry, name, &wl.compositor_interface, 4)
      case wl.shm_interface.name:
        window.shm = cast(^wl.shm)wl.registry_bind(registry, name, &wl.shm_interface, 1)
      case xdg.wm_base_interface.name:
         window.wm_base = cast(^xdg.wm_base)wl.registry_bind(registry,name,&xdg.wm_base_interface,1)
   }
   if interface_name == wl.compositor_interface.name {
   }
}
registry_global_remove :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint) {

}
buffer_listener := wl.buffer_listener {
	release = buffer_release
}
registry_listener := wl.registry_listener {
   global = registry_global,
   global_remove = registry_global_remove,
}
surface_listener := xdg.surface_listener {
   configure = surface_configure
}
wm_base_listener := xdg.wm_base_listener {
   ping = wm_base_ping
}
main :: proc() {
   global_context = context
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
   xdg.wm_base_add_listener(window.wm_base, &wm_base_listener, nil)
   window.xdg_surface = xdg.wm_base_get_xdg_surface(window.wm_base, window.surface)
   xdg.surface_add_listener(window.xdg_surface, &surface_listener, nil)
   window.toplevel = xdg.surface_get_toplevel(window.xdg_surface)
   xdg.toplevel_set_title(window.toplevel, "Hellope From Odin!")
   wl.surface_commit(window.surface)
   for wl.display_dispatch(window.display) != 0 {
   }
}
