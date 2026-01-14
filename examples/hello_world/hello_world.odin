package hello_world
import wl "../../"
import "core:fmt"
import "base:runtime"

compositor : ^wl.compositor
global_context: runtime.Context
global_registry: ^wl.registry
registry_global :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint, interface: cstring, version: uint) {
   context = global_context

   if interface == "wl_compositor" {
      compositor = cast(^wl.compositor)wl.registry_bind(registry, name, &wl.compositor_interface, 4)
   }
}
registry_global_remove :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint) {

}
main :: proc() {
   global_context = context
   display := wl.display_connect(nil)
   if display != nil {
      fmt.println("Successfully connected to a wayland display.")
   }
   else {
      fmt.println("Failed to connect to a wayland display")
      return
   }
   registry := wl.display_get_registry(display)

   registry_listener := wl.registry_listener {
      global = registry_global,
      global_remove = registry_global_remove,
   }
   wl.registry_add_listener(registry, &registry_listener, nil)
   wl.display_roundtrip(display)
   surface := wl.compositor_create_surface(compositor)

   for wl.display_dispatch(display) != 0 {

   }
   //wl.registry_destroy(registry)
}
