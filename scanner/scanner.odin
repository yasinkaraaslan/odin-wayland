package wayland_scanner
import "core:fmt"
import "core:encoding/xml"
import "core:log"
import "core:strings"
import "core:flags"
import "core:os"
import "core:path/filepath"

Procedure_Type :: enum {
   Request,
   Event,
}
Procedure :: struct {
   name: string,
   description: string,
   type: Procedure_Type,
   args: []Argument, // This does not include ret
   ret: Maybe(Argument),
   new_id: Maybe(Argument),
   is_destructor: bool,
   since: Maybe(string),
   type_index: int,
   all_null: bool
}

Enum_Entry :: struct {
   name: string,
   value: string,
}

Enumeration :: struct {
   name: string,
   description: string,
   entries: []Enum_Entry
}

Interface :: struct {
   name: string,
   unstripped_name: string,
   description: string,
   requests: []Procedure,
   events: []Procedure,
   enums: []Enumeration,
   version: string
}

Protocol :: struct {
   name: string,
   interfaces: []Interface,
   null_run_length: int,
}

Argument_Type :: enum {
   New_Id,
   Int,
   Unsigned,
   Fixed,
   String,
   Object,
   Array,
   Fd,
   Enum,
}

Argument :: struct {
   name: string,
   type: Argument_Type,
   protocol_type: Argument_Type,
   nullable: bool,
   interface_name: string,
   enum_name: string // If type is enum

   // TODO: summary
}
get_description :: proc(doc: ^xml.Document, id: u32) -> string {
   desc_id,found := find_child(doc, id, "description")
   if !found {
      return ""
   }
   values := doc.elements[desc_id].value
   if len(values) == 0 {
      return ""
   }
   return values[0].(string)
}
get_name :: proc(doc: ^xml.Document, id: u32) -> string {
   name, found := find_attr(doc,id,"name"); assert(found)
   return name
}

iterate_child :: proc(doc: ^xml.Document, parent_id: u32, ident: string) -> (id: u32, ok: bool) {
   @(static) index_map :map[u32]int
   id, ok = find_child(doc,parent_id,ident,index_map[parent_id])
   if !ok do index_map[parent_id] = 0
   else do index_map[parent_id] += 1
   return
}

get_argument_type :: proc(text: string) -> (type: Argument_Type) {
   switch text {
      case "new_id": type = .New_Id
      case "int": type = .Int
      case "uint": type = .Unsigned
      case "fixed": type = .Fixed
      case "string": type = .String
      case "object": type = .Object
      case "array": type = .Array
      case "fd": type = .Fd
   }
   return
}

find_attr :: xml.find_attribute_val_by_key
find_child :: xml.find_child_by_ident

after_underscore :: proc(s: string) -> string {
   index := strings.index_byte(s, '_')
   return s[index+1:]
}

parse_procedure :: proc(doc: ^xml.Document, id: u32, type: Procedure_Type, interface_name: string, protocol: ^Protocol) -> Procedure {
   procedure := Procedure {
      name=get_name(doc,id),
      description=get_description(doc, id),
      type=type,
      all_null=true
   }
   type_name, found := find_attr(doc, id, "type")
   if !found do procedure.is_destructor = false
   else if type_name == "destructor" do procedure.is_destructor = true
   since_name, since_found := find_attr(doc, id, "since")
   if since_found do procedure.since = since_name


   args : [dynamic]Argument
   log.debug("\t","Event:", procedure.name)
   for arg_id in iterate_child(doc, id, "arg") {
      arg := Argument {
         name = get_name(doc, arg_id),
      }
      nullable_name, nullable_found := find_attr(doc,arg_id, "allow-null")
      type_name, type_found := find_attr(doc,arg_id,"type")
      enum_name, enum_found := find_attr(doc,arg_id,"enum")
      if enum_found {
         arg.type = .Enum
         arg.protocol_type = get_argument_type(type_name)
         if strings.contains_rune(enum_name,'.') {
            // wl_output.transform -> output_transform
            enum_name, _ = strings.replace_all(after_underscore(enum_name), ".", "_")
            arg.enum_name = enum_name
         }
         else {
            arg.enum_name = fmt.aprintf("%v_%v", interface_name, enum_name)
         }
      }
      arg.nullable = nullable_found && nullable_name == "true"
      interface_name, interface_found := find_attr(doc, arg_id, "interface")
      if interface_found {
         if protocol.name != "wayland" && strings.starts_with(interface_name, "wl_"){
            raw_data(interface_name)[2] = '.'
         }
         else {
            interface_name = after_underscore(interface_name)
         }

         arg.interface_name = interface_name
      }
      if !enum_found {
         arg.type = get_argument_type(type_name)
         arg.protocol_type = arg.type
      }

      log.debug("\t\t","Argument:", arg.name)
      if (arg.type == .New_Id || arg.type == .Object) && interface_found {
         procedure.all_null = false
      }

      if arg.type == .New_Id && interface_found {
         procedure.ret = arg
      }
      else {
         if arg.type == .New_Id {
            procedure.new_id = arg
         }
         append(&args, arg)
      }
   }
   if procedure.all_null && len(args) > protocol.null_run_length do protocol.null_run_length = len(args)
   procedure.args = args[:]
   return procedure
}

get_procedure_signature :: proc(procedure: Procedure) -> string {
   sb: strings.Builder
   arg_signs := #partial[Argument_Type]string {
      .New_Id = "n",
      .Int = "i",
      .Unsigned = "u",
      .Fixed = "f",
      .String = "s",
      .Object = "o",
      .Array = "a",
      .Fd = "h",
   }
   if procedure.since != nil {
      fmt.sbprint(&sb, procedure.since.?)
   }
   if procedure.ret != nil {
      fmt.sbprint(&sb, "n")
   }
   for arg in procedure.args {
      if (arg.type == .String || arg.type == .Object) && arg.nullable {
         fmt.sbprint(&sb, "?")
      }
      if arg.type == .New_Id && arg.interface_name == "" do fmt.sbprint(&sb, "su")
      fmt.sbprint(&sb, arg_signs[arg.protocol_type])
   }

   return strings.to_string(sb)
}
get_procedures_text :: proc(procedures: []Procedure, var_name: string, protocol_name: string) -> string {
   sb: strings.Builder
   fmt.sbprintln(&sb, "@(private)")
   fmt.sbprintfln(&sb, "%v := []message {{", var_name)
   for procedure in procedures {
      fmt.sbprint(&sb,"\t{")
      fmt.sbprintf(&sb, `"%v", "%v", raw_data(%v_types)[%v:]`, procedure.name, get_procedure_signature(procedure), protocol_name, procedure.type_index)
      fmt.sbprintln(&sb, "},")
   }
   fmt.sbprintln(&sb, "}")

   return strings.to_string(sb)
}
get_argument_text :: proc(arg: Argument) -> string {
   sb: strings.Builder
   forward_text: string
   ret := false
   switch arg.type {
      case .Object:
         forward_text = fmt.aprintf("^%v", arg.interface_name) if arg.interface_name != "" else "rawptr"
      case .New_Id:
         if arg.interface_name != "" {
            forward_text = fmt.aprintf("^%v", arg.interface_name)
            ret = true
         }
         else {
            forward_text = "^interface, version: uint"
         }
      case .Enum:
         forward_text = arg.enum_name
      case .Int, .Fd:
         forward_text = "int"
      case .Unsigned:
         forward_text = "uint"
      case .Fixed:
         forward_text = "fixed_t"
      case .String:
         forward_text = "cstring"
      case .Array:
         forward_text = "array"
   }
   if !ret do fmt.sbprintf(&sb, "%v_: ", arg.name)
   fmt.sbprint(&sb, forward_text)
   return strings.to_string(sb)
}

// @Incomplete: error checking
parse_file :: proc(filename: string) -> Protocol {
   doc, err := xml.load_from_file(filename)
   if err != nil {
      fmt.println("Error reading file:", filename)
      os.exit(1)
   }
   fmt.println("Parsing:", filename)
   protocol : Protocol
   name, found := find_attr(doc,0,"name"); assert(found)
   protocol.name = name
   interfaces: [dynamic]Interface
   for interface_id in iterate_child(doc,0,"interface") {
      interface_name := get_name(doc,interface_id)
      // Deprecated interfaces
      if interface_name == "wl_shell" || interface_name == "wl_shell_surface" do continue

      interface : Interface
      interface.name = after_underscore(interface_name)
      interface.version, found = find_attr(doc, interface_id, "version"); assert(found)
      interface.unstripped_name = interface_name
      interface.description = get_description(doc, interface_id)
      requests : [dynamic]Procedure
      events : [dynamic]Procedure
      enums : [dynamic]Enumeration

      log.debug(interface.name)
      for request_id in iterate_child(doc,interface_id, "request") {
         request := parse_procedure(doc, request_id, .Request, interface.name, &protocol)
         append(&requests, request)
      }
      for event_id in iterate_child(doc,interface_id,"event") {
         event := parse_procedure(doc, event_id, .Event, interface.name , &protocol)
         append(&events, event)
      }
      for enum_id in iterate_child(doc, interface_id,"enum") {
         enumeration := Enumeration {
            name = get_name(doc, enum_id),
            description = get_description(doc, enum_id),

         }
         log.debug("\t","Enum:", enumeration.name)
         entries : [dynamic]Enum_Entry
         for entry_id in iterate_child(doc, enum_id, "entry") {
            value, found := find_attr(doc, entry_id, "value")
            if !found {
               // @Incomplete
            }
            name = get_name(doc, entry_id)
            if name[0] <= '9' && name[0] >= '0' {
               name = strings.concatenate({"_", name})
            }
            entry := Enum_Entry {
               name = name,
               value = value
            }
            append(&entries, entry)
            log.debug("\t\tEntry:", entry.name)
         }
         enumeration.entries = entries[:]
         append(&enums, enumeration)
      }

      interface.requests = requests[:]
      interface.events = events[:]
      interface.enums = enums[:]
      append(&interfaces, interface)
   }
   for interface in interfaces {
      for &request in interface.requests {
         for other in interfaces {
            if other.name == fmt.aprintf("%v_%v", interface.name, request.name)  {
               // Odin, unlike c, doesn't allow a procedure and a struct to have the same name
               request.name = fmt.aprintf("get_%v", request.name)
            }
         }
      }
   }
   protocol.interfaces = interfaces[:]
   return protocol
}

generate_code :: proc(protocol: Protocol, package_name, output_path, wayland_dir: string, emit_libwayland: bool) -> string {
   sb: strings.Builder
   strings.write_string(&sb, "#+build linux\n")
   fmt.sbprintln(&sb,"package",package_name)
   fmt.sbprintln(&sb, "@(private)")
   fmt.sbprintfln(&sb, "%v_types := []^interface {{",protocol.name)
   for i in 0..<protocol.null_run_length {
      fmt.sbprintln(&sb, "\tnil,")
   }
   for interface in protocol.interfaces {
      generate_types(&sb, interface.requests, protocol)
      generate_types(&sb, interface.events, protocol)
   }
   fmt.sbprintln(&sb, "}")

   for interface in protocol.interfaces {
         fmt.sbprintln(&sb, "/*", interface.description, "*/")
         fmt.sbprintfln(&sb,"%v :: struct {{}}", interface.name)
         fmt.sbprintfln(&sb,
`%[0]v_set_user_data :: proc "contextless" (%[0]v_: ^%[0]v, user_data: rawptr) {{
   proxy_set_user_data(cast(^proxy)%[0]v_, user_data)
}}

%[0]v_get_user_data :: proc "contextless" (%[0]v_: ^%[0]v) -> rawptr {{
   return proxy_get_user_data(cast(^proxy)%[0]v_)
}}
`, interface.name)
         has_destroy := false
         opcode := 0

         for request in interface.requests {
            has_ret := request.ret != nil
            has_new_id := request.new_id != nil
            fmt.sbprintln(&sb, "/*", request.description, "*/")
            opcode_name := fmt.aprintf("%v_%v", strings.to_upper(interface.name), strings.to_upper(request.name))
            fmt.sbprintfln(&sb,"%v :: %v",opcode_name, opcode)

            fmt.sbprintf(&sb, `%[0]v_%[1]v :: proc "contextless" (%[0]v_: ^%[0]v`, interface.name, request.name)
            for arg in request.args do fmt.sbprintf(&sb, ", %v", get_argument_text(arg))
            fmt.sbprint(&sb, ") ")
            return_type := get_argument_text(request.ret.?) if has_ret else "rawptr"

            if has_ret || has_new_id do fmt.sbprintf(&sb,"-> %v ",return_type)
            fmt.sbprintln(&sb, "{")
            fmt.sbprint(&sb, "\t")
            if has_ret || has_new_id do fmt.sbprint(&sb, "ret := ")
            fmt.sbprintf(&sb, "proxy_marshal_flags(cast(^proxy)%v_, %v", interface.name, opcode_name)

            if has_ret do fmt.sbprintf(&sb, ", &%v_interface, proxy_get_version(cast(^proxy)%v_)", request.ret.?.interface_name,interface.name)
            else if has_new_id do fmt.sbprintf(&sb, ", %v_, version", request.new_id.?.name)
            else do fmt.sbprintf(&sb, ", nil, proxy_get_version(cast(^proxy)%v_)", interface.name)

            fmt.sbprint(&sb, ", 1" if request.is_destructor else ", 0")

            if has_ret do fmt.sbprint(&sb, ", nil")
            for arg in request.args {
               fmt.sbprintf(&sb, ", %v_", arg.name)
               if arg.type == .New_Id do fmt.sbprint(&sb, ".name, version")
            }
            fmt.sbprintln(&sb, ")")
            if has_ret || has_new_id {
               fmt.sbprintfln(&sb, "\treturn cast(%v)ret", return_type)
            }
            fmt.sbprintln(&sb, "}\n")
            if request.name == "destroy" do has_destroy = true
            opcode += 1
         }
         if !has_destroy && interface.name != "display" {
            fmt.sbprintfln(&sb,
`%[0]v_destroy :: proc "contextless" (%[0]v_: ^%[0]v) {{
   proxy_destroy(cast(^proxy)%[0]v_)
}}
`, interface.name)
         }
         if len(interface.events) > 0 {
            fmt.sbprintfln(&sb, "%v_listener :: struct {{",interface.name)
            for event in interface.events {
               fmt.sbprintln(&sb, "/*", event.description, "*/")

               fmt.sbprint(&sb, "\t")
               fmt.sbprintf(&sb,`%v : proc "c" (data: rawptr, %v: ^%v`, event.name, interface.name, interface.name)
               for arg, i in event.args {
                  fmt.sbprintf(&sb, ", %v",get_argument_text(arg))

               }
               if event.ret != nil do fmt.sbprintfln(&sb, ") -> %v,\n", get_argument_text(event.ret.?))
               else do fmt.sbprintln(&sb, "),\n")
            }
            fmt.sbprintln(&sb, "}")
            fmt.sbprintfln(&sb, `%v_add_listener :: proc "contextless" (%[0]v_: ^%[0]v, listener: ^%[0]v_listener, data: rawptr) {{`,interface.name)
            fmt.sbprintfln(&sb, "\tproxy_add_listener(cast(^proxy)%v_, cast(^generic_c_call)listener,data)", interface.name)
            fmt.sbprintln(&sb, "}")

         }
         for enumeration in interface.enums {
            fmt.sbprintln(&sb, "/*", enumeration.description, "*/")
            fmt.sbprintfln(&sb, "%v_%v :: enum {{", interface.name, enumeration.name)
            for entry in enumeration.entries {
               fmt.sbprintfln(&sb, "\t%v = %v,", entry.name, entry.value)
            }
            fmt.sbprintln(&sb, "}")
         }

         if len(interface.requests) > 0 {
            requests_name := fmt.aprintf("%v_requests", interface.name)
            fmt.sbprintln(&sb, get_procedures_text(interface.requests, requests_name, protocol.name))
         }

         if len(interface.events) > 0 {
            events_name := fmt.aprintf("%v_events", interface.name)
            fmt.sbprintln(&sb, get_procedures_text(interface.events, events_name, protocol.name))
         }

         fmt.sbprintfln(&sb,"%v_interface : interface\n", interface.name)
   }

   fmt.sbprintln(&sb, "@(private)")
   fmt.sbprintln(&sb, "@(init)")
   fmt.sbprintfln(&sb, "init_interfaces_%v :: proc \"contextless\" () {{", protocol.name)
   for interface in protocol.interfaces {
      request_count := len(interface.requests)
      event_count := len(interface.events)
      fmt.sbprint(&sb, "\t")
      fmt.sbprintfln(&sb, `%v_interface.name = "%v"`, interface.name, interface.unstripped_name)
      fmt.sbprintfln(&sb, "\t%v_interface.version = %v", interface.name, interface.version)
      fmt.sbprintfln(&sb, "\t%v_interface.method_count = %v", interface.name, request_count)
      fmt.sbprintfln(&sb, "\t%v_interface.event_count = %v", interface.name, event_count)
      if request_count > 0 {
         fmt.sbprintfln(&sb, "\t%v_interface.methods = raw_data(%[0]v_requests)", interface.name)
      }
      if event_count > 0 {
         fmt.sbprintfln(&sb, "\t%v_interface.events = raw_data(%[0]v_events)", interface.name)
      }
   }
   fmt.sbprintln(&sb, "}")
   if protocol.name == "wayland" {
      fmt.sbprintln(&sb, "\n// Functions from libwayland-client")
      fmt.sbprintln(&sb, `import "core:c"`)
      fmt.sbprintln(&sb,`foreign import wl_lib "system:wayland-client"`)

      strings.write_string(&sb,
`@(default_calling_convention="c")
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
}`)
   }
   else {
      fmt.sbprintln(&sb, "\n// Functions from libwayland-client")
      // resolve relative import to wayland base types
      if wayland_dir == "" {
         fmt.sbprintln(&sb, `import wl ".."`) // default
      } else {
         output_dir := filepath.abs(output_path) or_else output_path
         wayland_abs := filepath.abs(wayland_dir) or_else wayland_dir
         rel_import := filepath.rel(output_dir, wayland_abs) or_else ".."
         fmt.sbprintfln(&sb, `import wl "%s"`, rel_import)
      }

      if emit_libwayland {
         add_wl_name(&sb, "fixed_t")
         add_wl_name(&sb, "proxy")
         add_wl_name(&sb, "message")
         add_wl_name(&sb, "interface")
         add_wl_name(&sb, "array")
         add_wl_name(&sb, "generic_c_call")
         add_wl_name(&sb, "proxy_add_listener")
         add_wl_name(&sb, "proxy_get_listener")
         add_wl_name(&sb, "proxy_get_user_data")
         add_wl_name(&sb, "proxy_set_user_data")
         add_wl_name(&sb, "proxy_get_version")
         add_wl_name(&sb, "proxy_marshal")
         add_wl_name(&sb, "proxy_marshal_flags")
         add_wl_name(&sb, "proxy_marshal_constructor")
         add_wl_name(&sb, "proxy_destroy")
      }
   }
   return strings.to_string(sb)
}
type_index := 0
generate_types :: proc(sb: ^strings.Builder, procedures: []Procedure, protocol: Protocol) {
   for &procedure in procedures {
      if procedure.all_null {
         procedure.type_index = 0
         continue
      }
      procedure.type_index = protocol.null_run_length + type_index

      arg_length := len(procedure.args) if procedure.ret == nil else len(procedure.args) + 1
      type_index += arg_length

      if procedure.ret != nil {
         fmt.sbprintfln(sb, "\t&%v_interface,", procedure.ret.?.interface_name)
      }
      for arg in procedure.args {
         if (arg.type == .New_Id || arg.type == .Object) && arg.interface_name != "" {
            fmt.sbprintfln(sb, "\t&%v_interface,", arg.interface_name)
         }
         else {
            fmt.sbprintln(sb, "\tnil,")
         }
      }
   }
}
add_wl_name :: proc(sb: ^strings.Builder, func_name: string) {
   fmt.sbprintfln(sb, "%v :: wl.%[0]v", func_name)
}
main :: proc() {
   options : struct {
      input: string `args:"pos=0,required" usage:"Wayland xml protocol path."`,
      output: string `args:"pos=1" usage:"Odin output path."`,
      package_name: string `args:"pos=2" usage:"Package name for output code"`,
		verbose: bool `args:"pos=3" usage:"Show verbose output."`,
      dont_emit_libwayland: bool `args:"pos=4" usage:"Do not include libwayland procedures in the output code."`,
      wayland_dir: string `args:"pos=5" usage:"Relative path from output file to directory which contains wayland base type definitions (default: parent dir).
      Only used when the protocol name is not wayland itself."`,
   }
   style := flags.Parsing_Style.Odin
   flags.parse_or_exit(&options, os.args, style)

   context.logger = log.create_console_logger(opt={}) if options.verbose else log.Logger{}
   protocol := parse_file(options.input)
   output_filename : string
   if options.output != "" {
      output_filename = options.output
   }
   else {
      output_filename = strings.concatenate({filepath.stem(options.input), ".odin"})
   }

   fmt.println("Outputting to:", output_filename)

   package_name := options.package_name if options.package_name != "" else protocol.name
   code := generate_code(protocol, package_name, options.output, options.wayland_dir, !options.dont_emit_libwayland)
   if !os.write_entire_file(output_filename, transmute([]u8)code) {
      fmt.println("There was an error outputting to the file:", os.get_last_error())
      return
   }

   fmt.println("Done")
}
