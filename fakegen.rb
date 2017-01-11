
# fakegen.rb
# A simple code generator to create some C macros for defining test fake functions


$cpp_output = true
$MAX_ARGS = 20
$DEFAULT_ARG_HISTORY = 50
$MAX_CALL_HISTORY = 50
$WRAP_PREFIX = "__wrap"

def include_dependencies
  putd "#include <stdarg.h>"
  putd "#include <string.h> /* For memset and memcpy */"
  putd ""
end

def output_constants
  putd "#define FFF_MAX_ARGS (#{$MAX_ARGS}u)"
  putd "#ifndef FFF_ARG_HISTORY_LEN"
  putd "    #define FFF_ARG_HISTORY_LEN (#{$DEFAULT_ARG_HISTORY}u)"
  putd "#endif"
  putd "#ifndef FFF_CALL_HISTORY_LEN"
  putd "  #define FFF_CALL_HISTORY_LEN (#{$MAX_CALL_HISTORY}u)"
  putd "#endif"
end





# ------  Helper macros to use internally ------ #
def output_internal_helper_macros
  putd "/* -- INTERNAL HELPER MACROS -- */"
  
  define_return_sequence_helper
  define_custom_fake_sequence_helper
  define_reset_fake_macro
  define_reset_wrap_fake_macro
  define_declare_arg_helper
  define_declare_all_func_common_helper
  define_save_arg_helper
  define_room_for_more_history
  define_save_arg_history_helper
  define_history_dropped_helper
  define_value_function_variables_helper
  define_custom_fake_seq_variables_helper
  define_increment_call_count_helper
  define_return_fake_result_helper
  define_extern_c_helper
  define_reset_fake_helper
  define_reset_wrap_fake_helper
  
  putd "/* -- END INTERNAL HELPER MACROS -- */"
  putd ""
end

def define_return_sequence_helper
  putd "#define SET_RETURN_SEQ(FUNCNAME, ARRAY_POINTER, ARRAY_LEN) \\"
  putd "                        FUNCNAME##_fake.return_val_seq = ARRAY_POINTER; \\"
  putd "                        FUNCNAME##_fake.return_val_seq_len = ARRAY_LEN;"
end

def define_custom_fake_sequence_helper
  putd "#define SET_CUSTOM_FAKE_SEQ(FUNCNAME, ARRAY_POINTER, ARRAY_LEN) \\"
  putd "                            FUNCNAME##_fake.custom_fake_seq = ARRAY_POINTER; \\"
  putd "                            FUNCNAME##_fake.custom_fake_seq_len = ARRAY_LEN;"
end

def define_reset_wrap_fake_macro
  putd ""
  putd "/* Defining a function to reset a fake function and delegates to __real function */"
  putd "#define RESET_WRAP_FAKE(FUNCNAME) { \\"
  putd "    FUNCNAME##_wrap_reset(); \\"
  putd "} \\"
  putd ""
end

def define_reset_fake_macro
  putd ""
  putd "/* Defining a function to reset a fake function */"
  putd "#define RESET_FAKE(FUNCNAME) { \\"
  putd "    FUNCNAME##_reset(); \\"
  putd "} \\"
  putd ""
end

def define_declare_arg_helper
  putd ""
  putd "#define DECLARE_ARG(type, n, FUNCNAME) \\"
  putd "    type arg##n##_val; \\"
  putd "    type arg##n##_history[FFF_ARG_HISTORY_LEN];"
end

def define_declare_all_func_common_helper
  putd ""
  putd "#define DECLARE_ALL_FUNC_COMMON \\"
  putd "    unsigned int call_count; \\"
  putd "    unsigned int arg_history_len;\\"
  putd "    unsigned int arg_histories_dropped; \\"
end

def define_save_arg_helper
  putd ""
  putd "#define SAVE_ARG(FUNCNAME, n) \\"
  putd "    memcpy((void*)&FUNCNAME##_fake.arg##n##_val, (void*)&arg##n, sizeof(arg##n));"
end

def define_room_for_more_history
  putd ""
  putd "#define ROOM_FOR_MORE_HISTORY(FUNCNAME) \\"
  putd "  FUNCNAME##_fake.call_count < FFF_ARG_HISTORY_LEN"
end

def define_save_arg_history_helper
  putd ""
  putd "#define SAVE_ARG_HISTORY(FUNCNAME, ARGN) \\"
  putd "    memcpy((void*)&FUNCNAME##_fake.arg##ARGN##_history[FUNCNAME##_fake.call_count], (void*)&arg##ARGN, sizeof(arg##ARGN));"
end

def define_history_dropped_helper
  putd ""
  putd "#define HISTORY_DROPPED(FUNCNAME) \\"
  putd "    FUNCNAME##_fake.arg_histories_dropped++"
end

def define_value_function_variables_helper
  putd ""
  putd "#define DECLARE_VALUE_FUNCTION_VARIABLES(RETURN_TYPE) \\"
  putd "    RETURN_TYPE return_val; \\" 
  putd "    int return_val_seq_len; \\" 
  putd "    int return_val_seq_idx; \\" 
  putd "    RETURN_TYPE * return_val_seq; \\"
end

def define_custom_fake_seq_variables_helper
  putd ""
  putd "#define DECLARE_CUSTOM_FAKE_SEQ_VARIABLES \\"
  putd "    int custom_fake_seq_len; \\"
  putd "    int custom_fake_seq_idx; \\"
end

def define_increment_call_count_helper
  putd ""
  putd "#define INCREMENT_CALL_COUNT(FUNCNAME) \\"
  putd "    FUNCNAME##_fake.call_count++"
end

def define_return_fake_result_helper
  putd ""
  putd "#define RETURN_FAKE_RESULT(FUNCNAME) \\"
  putd "    if (FUNCNAME##_fake.return_val_seq_len){ /* then its a sequence */ \\"
  putd "        if(FUNCNAME##_fake.return_val_seq_idx < FUNCNAME##_fake.return_val_seq_len) { \\"
  putd "            return FUNCNAME##_fake.return_val_seq[FUNCNAME##_fake.return_val_seq_idx++]; \\"
  putd "        } \\"
  putd "        return FUNCNAME##_fake.return_val_seq[FUNCNAME##_fake.return_val_seq_len-1]; /* return last element */ \\"
  putd "    } \\"
  putd "    return FUNCNAME##_fake.return_val; \\"
end

def define_extern_c_helper
  putd ""
  putd "#ifdef __cplusplus"
  putd "    #define FFF_EXTERN_C extern \"C\"{" 
  putd "    #define FFF_END_EXTERN_C } " 
  putd "#else  /* ansi c */"
  putd "    #define FFF_EXTERN_C "
  putd "    #define FFF_END_EXTERN_C "
  putd "#endif  /* cpp/ansi c */"
end

def define_reset_fake_helper
  putd ""
  putd "#define DEFINE_RESET_FUNCTION(FUNCNAME) \\"
  putd "    void FUNCNAME##_reset(){ \\"
  putd "        memset(&FUNCNAME##_fake, 0, sizeof(FUNCNAME##_fake)); \\"
  putd "        FUNCNAME##_fake.arg_history_len = FFF_ARG_HISTORY_LEN;\\"
  putd "    }"
end

def define_reset_wrap_fake_helper
  putd ""
  putd "#define DEFINE_RESET_WRAP_FUNCTION(FUNCNAME) \\"
  pushd
    putd "void FUNCNAME##_wrap_reset(){ \\"
    pushd
      putd "#{$WRAP_PREFIX}_##FUNCNAME##_reset();\\"
      putd "#{$WRAP_PREFIX}_##FUNCNAME##_fake.custom_fake = __real_##FUNCNAME ; \\"
    popd
    putd "}"
  popd
end
# ------  End Helper macros ------ #

#fakegen helpers to print at levels of indentation
$current_depth = 0
def putd(str)
  $current_depth.times {|not_used| print " "}
  puts str
end

def pushd
  $current_depth = $current_depth + 4
end

def popd
  $current_depth = $current_depth - 4
end

def output_macro(arg_count, has_varargs, is_value_function)

  vararg_name = has_varargs ? "_VARARG" : ""
  fake_macro_name = is_value_function ? "FAKE_VALUE_FUNC#{arg_count}#{vararg_name}" : "FAKE_VOID_FUNC#{arg_count}#{vararg_name}"
  wrap_fake_macro_name = "WRAP_#{fake_macro_name}"
  declare_macro_name = "DECLARE_#{fake_macro_name}"
  declare_wrap_macro_name = "DECLARE_#{wrap_fake_macro_name}"
  define_macro_name = "DEFINE_#{fake_macro_name}"
  define_wrap_macro_name = "DEFINE_#{wrap_fake_macro_name}"
  saved_arg_count = arg_count - (has_varargs ? 1 : 0)
  return_type = is_value_function ? "RETURN_TYPE" : ""

  putd ""
  output_macro_header(declare_macro_name, saved_arg_count, has_varargs, return_type)
  pushd
    extern_c {  # define argument capture variables
      output_variables(saved_arg_count, has_varargs, is_value_function)
    }
  popd

  # vararg functions are not wrappable
  if !has_varargs
    putd ""
    output_macro_header(declare_wrap_macro_name, saved_arg_count, has_varargs, return_type)
    pushd
      extern_c {
        putd real_function_signature(saved_arg_count, has_varargs, is_value_function) + ";\\"
        arg_type_list = (saved_arg_count > 0) ? ", #{arg_type_list(saved_arg_count)}" : ""
        putd "#{declare_macro_name}(#{fff_macro_parameter(saved_arg_count, is_value_function)}); \\"
        putd "void FUNCNAME##_wrap_reset(); \\"
      }
    popd
  end
  
  putd ""
  output_macro_header(define_macro_name, saved_arg_count, has_varargs, return_type)
  pushd
    extern_c {
      putd "FUNCNAME##_Fake FUNCNAME##_fake;\\"
      putd function_signature(saved_arg_count, has_varargs, is_value_function) + "{ \\"
      pushd
        output_function_body(saved_arg_count, has_varargs, is_value_function)
      popd
      putd "} \\"
      putd "DEFINE_RESET_FUNCTION(FUNCNAME) \\"
    }
  popd

  # vararg functions are not wrappable
  if !has_varargs
    putd ""
    output_macro_header(define_wrap_macro_name, saved_arg_count, has_varargs, return_type)
    pushd
      extern_c {
        arg_type_list = (saved_arg_count > 0) ? ", #{arg_type_list(saved_arg_count)}" : ""
        putd "#{define_macro_name}(#{fff_macro_parameter(saved_arg_count, is_value_function)}); \\"
        putd "DEFINE_RESET_WRAP_FUNCTION(FUNCNAME); \\"
        output_initialize_fake_struct_with_custom_fake("__real_##FUNCNAME", arg_count, is_value_function)
      }
    popd
  end

  putd ""
  
  output_macro_header(fake_macro_name, saved_arg_count, has_varargs, return_type)
  pushd
    putd macro_signature_for(declare_macro_name, saved_arg_count, has_varargs, return_type)
    putd macro_signature_for(define_macro_name, saved_arg_count, has_varargs, return_type)
    putd ""
  popd

  output_macro_header(wrap_fake_macro_name, saved_arg_count, has_varargs, return_type)
  pushd
    putd macro_signature_for(declare_wrap_macro_name, saved_arg_count, has_varargs, return_type)
    putd macro_signature_for(define_wrap_macro_name, saved_arg_count, has_varargs, return_type)
    putd ""
  popd
end

def output_macro_header(macro_name, arg_count, has_varargs, return_type)
  output_macro_name(macro_name, arg_count, has_varargs, return_type)
end

# #define #macro_name(RETURN_TYPE, FUNCNAME, ARG0,...)
def output_macro_name(macro_name, arg_count, has_varargs, return_type)
  putd "#define " + macro_signature_for(macro_name, arg_count, has_varargs, return_type)
end

# #macro_name(RETURN_TYPE, FUNCNAME, ARG0,...)
def macro_signature_for(macro_name, arg_count, has_varargs, return_type)
  parameter_list = "#{macro_name}("
  if return_type != ""
    parameter_list += return_type
    parameter_list += ", "
  end
  parameter_list += "FUNCNAME"

  arg_count.times { |i| parameter_list += ", ARG#{i}_TYPE" }

  parameter_list += ", ..." if has_varargs

  parameter_list +=  ") \\"
  
  parameter_list
end

def output_argument_capture_variables(argN)
  putd "    DECLARE_ARG(ARG#{argN}_TYPE, #{argN}, FUNCNAME) \\"
end

# if you add or remove variables to the _fake struct, adapt output_initialize_fake_struct_with_custom_fake
def output_variables(arg_count, has_varargs, is_value_function)
  in_struct{
    arg_count.times { |argN| 
      putd "DECLARE_ARG(ARG#{argN}_TYPE, #{argN}, FUNCNAME) \\"
    }
    putd "DECLARE_ALL_FUNC_COMMON \\"
    putd "DECLARE_VALUE_FUNCTION_VARIABLES(RETURN_TYPE) \\" unless not is_value_function
    putd "DECLARE_CUSTOM_FAKE_SEQ_VARIABLES \\"
    output_custom_function_signature(arg_count, has_varargs, is_value_function)
    output_custom_function_array(arg_count, has_varargs, is_value_function)
  }
  putd "extern FUNCNAME##_Fake FUNCNAME##_fake;\\"
  putd "void FUNCNAME##_reset(); \\"
end

# arguments has to be adapted to output_variables and sub function
def output_initialize_fake_struct_with_custom_fake(custom_fake, arg_count, is_value_function)
  struct_type = "#{$WRAP_PREFIX}_##FUNCNAME##_Fake"
  struct_name = "#{$WRAP_PREFIX}_##FUNCNAME##_fake"

  struct_value = "{"
  # DECLARE_ARG
  arg_count.times {
    struct_value << "0, {0}, "
  }
  # DECLARE_ALL_FUNC_COMMON
  struct_value << "0, 0, 0, "
  # DECLARE_VALUE_FUNCTION_VARIABLES
  struct_value << "0, 0, 0, 0, " unless not is_value_function
  # DECLARE_CUSTOM_FAKE_SEQ_VARIABLES
  struct_value << "0, 0, "
  # custom_fake
  struct_value << "#{custom_fake}, "
  # custem_fake_seq
  struct_value << "0"
  struct_value << "}"

  putd "#{struct_type} #{struct_name} = #{struct_value}; \\"
end

#example: ARG0_TYPE, ARG1_TYPE
def arg_type_list(args_count)
  arguments = []
  args_count.times { |i| arguments << "ARG#{i}_TYPE" }
  arguments.join(", ")
end

#example: ARG0_TYPE arg0, ARG1_TYPE arg1
def arg_val_list(args_count)
  arguments = []
  args_count.times { |i| arguments << "ARG#{i}_TYPE arg#{i}" }
  arguments.join(", ")
end

#example: arg0, arg1
def arg_list(args_count)
  arguments = []
  args_count.times { |i| arguments << "arg#{i}" }
  arguments.join(", ")
end

# RETURN_TYPE (*custom_fake)(ARG0_TYPE arg0);\
# void (*custom_fake)(ARG0_TYPE arg0, ARG1_TYPE arg1, ARG2_TYPE arg2);\
def output_custom_function_signature(arg_count, has_varargs, is_value_function)
  return_type = is_value_function ? "RETURN_TYPE" : "void"
  ap_list = has_varargs ? ", va_list ap" : ""
  signature = "(*custom_fake)(#{arg_val_list(arg_count)}#{ap_list}); \\"
  putd return_type + signature
end

def output_custom_function_array(arg_count, has_varargs, is_value_function)
  return_type = is_value_function ? "RETURN_TYPE" : "void"
  ap_list = has_varargs ? ", va_list ap" : ""
  custom_array = "(**custom_fake_seq)(#{arg_val_list(arg_count)}#{ap_list}); \\"
  putd return_type + custom_array
end

# example: RETURN_TYPE FUNCNAME(ARG0_TYPE arg0, ARG1_TYPE arg1)
def function_signature(arg_count, has_varargs, is_value_function)
  return_type = is_value_function ? "RETURN_TYPE" : "void"
  varargs = has_varargs ? ", ..." : ""
  "#{return_type} FUNCNAME(#{arg_val_list(arg_count)}#{varargs})"
end

def fff_macro_parameter(arg_count, is_value_function)
  return_type = is_value_function ? "RETURN_TYPE, " : ""
  arg_type_list = arg_count > 0 ? ", #{arg_type_list(arg_count)}" : ""
  "#{return_type}#{$WRAP_PREFIX}_##FUNCNAME#{arg_type_list}"
end

# example: RETURN_TYPE __real_##FUNCNAME(ARG0_TYPE arg0)
def real_function_signature(arg_count, has_varargs, is_value_function)
  return_type = is_value_function ? "RETURN_TYPE" : "void"
  varargs = has_varargs ? ", ..." : ""
  "#{return_type} __real_##FUNCNAME(#{arg_val_list(arg_count)}#{varargs})"
end

def output_function_body(arg_count, has_varargs, is_value_function)
  arg_count.times { |i| putd "SAVE_ARG(FUNCNAME, #{i}); \\" }
  putd "if(ROOM_FOR_MORE_HISTORY(FUNCNAME)){\\"
  arg_count.times { |i| putd "    SAVE_ARG_HISTORY(FUNCNAME, #{i}); \\" }
  putd "}\\"
  putd "else{\\"
  putd "    HISTORY_DROPPED(FUNCNAME);\\"
  putd "}\\"
  putd "INCREMENT_CALL_COUNT(FUNCNAME); \\"
  putd "REGISTER_CALL(FUNCNAME); \\"

  if has_varargs
    putd "if(FUNCNAME##_fake.custom_fake){\\"
    putd "    RETURN_TYPE ret;\\" if is_value_function
    putd "    va_list ap;\\"
    putd "    va_start(ap, arg#{arg_count-1});\\"
    custom_fake_call = "FUNCNAME##_fake.custom_fake(#{arg_list(arg_count)}, ap);"
    if is_value_function
      putd "    ret = #{custom_fake_call}\\"
    else
      putd "  #{custom_fake_call}\\"
    end
    putd "    va_end(ap);\\"
    putd "    return ret;\\" if is_value_function
    putd "}\\"
  else
    return_type = is_value_function ? "return " : ""
    putd "if (FUNCNAME##_fake.custom_fake_seq_len){ /* a sequence of custom fakes */ \\"
    putd "    if (FUNCNAME##_fake.custom_fake_seq_idx < FUNCNAME##_fake.custom_fake_seq_len){ \\"
    putd "        #{return_type}FUNCNAME##_fake.custom_fake_seq[FUNCNAME##_fake.custom_fake_seq_idx++](#{arg_list(arg_count)}); \\"
    putd "    } \\"
    putd "    else{ \\"
    putd "        #{return_type}FUNCNAME##_fake.custom_fake_seq[FUNCNAME##_fake.custom_fake_seq_len-1](#{arg_list(arg_count)}); \\"
    putd "    } \\"
    putd "} \\"
    putd "if (FUNCNAME##_fake.custom_fake) #{return_type}FUNCNAME##_fake.custom_fake(#{arg_list(arg_count)}); \\"
  end

  putd "RETURN_FAKE_RESULT(FUNCNAME)  \\" if is_value_function
end

def output_reset_function(arg_count, is_value_function)
  putd "void FUNCNAME##_reset(){ \\"
  putd "    memset(&FUNCNAME##_fake, 0, sizeof(FUNCNAME##_fake)); \\"
  putd "    FUNCNAME##_fake.arg_history_len = FFF_ARG_HISTORY_LEN;\\"
  putd "} \\"
end

def define_fff_globals
  putd "typedef struct { "
  putd "    void * call_history[FFF_CALL_HISTORY_LEN];"
  putd "    unsigned int call_history_idx;"
  putd "} fff_globals_t;"
  putd ""
  putd "FFF_EXTERN_C \\"
  putd "extern fff_globals_t fff;"
  putd "FFF_END_EXTERN_C \\"
  putd ""
  putd "#define DEFINE_FFF_GLOBALS \\"
  putd "    FFF_EXTERN_C \\"
  putd "        fff_globals_t fff; \\"
  putd "    FFF_END_EXTERN_C"
  putd ""
  putd "#define FFF_RESET_HISTORY() fff.call_history_idx = 0;"
  putd ""
  putd "#define REGISTER_CALL(function) \\"
  putd "   if(fff.call_history_idx < FFF_CALL_HISTORY_LEN) \\"
  putd "       fff.call_history[fff.call_history_idx++] = (void *)function;"
end

def extern_c
  putd "FFF_EXTERN_C \\"
  pushd 
    yield
  popd
  putd "FFF_END_EXTERN_C \\"
end

def in_struct
  putd "typedef struct FUNCNAME##_Fake { \\"
  pushd
  yield
  popd
  putd "} FUNCNAME##_Fake;\\"
end

def include_guard
  putd "#ifndef FAKE_FUNCTIONS"
  putd "#define FAKE_FUNCTIONS"
  putd ""

  yield

  putd ""
  putd "#endif /* FAKE_FUNCTIONS */"
end

def generate_arg_sequence(args, prefix, do_reverse, joinstr) 
 fmap = (0..args).flat_map {|i| [prefix + i.to_s]}
 if do_reverse then fmap.reverse.join(joinstr) else fmap.join(", ") end
end

def output_macro_counting_shortcuts
  putd <<-MACRO_COUNTING

#define PP_NARG_MINUS2(...) \
    PP_NARG_MINUS2_(__VA_ARGS__, PP_RSEQ_N_MINUS2())

#define PP_NARG_MINUS2_(...) \
    PP_ARG_MINUS2_N(__VA_ARGS__)

#define PP_ARG_MINUS2_N(returnVal, #{generate_arg_sequence($MAX_ARGS - 1, '_', false, ", ")}, N, ...)   N

#define PP_RSEQ_N_MINUS2() \
    #{generate_arg_sequence($MAX_ARGS - 1, '', true, ',')}


#define PP_NARG_MINUS1(...) \
    PP_NARG_MINUS1_(__VA_ARGS__, PP_RSEQ_N_MINUS1())

#define PP_NARG_MINUS1_(...) \
    PP_ARG_MINUS1_N(__VA_ARGS__)

#define PP_ARG_MINUS1_N(#{generate_arg_sequence($MAX_ARGS, '_', false, ", ")}, N, ...)   N

#define PP_RSEQ_N_MINUS1() \
    #{generate_arg_sequence($MAX_ARGS, '', true, ',')}



/* DECLARE AND DEFINE FAKE FUNCTIONS - PLACE IN TEST FILES */

#define FAKE_VALUE_FUNC(...) \
    FUNC_VALUE_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define FUNC_VALUE_(N,...) \
    FUNC_VALUE_N(N,__VA_ARGS__)

#define FUNC_VALUE_N(N,...) \
    FAKE_VALUE_FUNC ## N(__VA_ARGS__)


#define FAKE_VOID_FUNC(...) \
    FUNC_VOID_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define FUNC_VOID_(N,...) \
    FUNC_VOID_N(N,__VA_ARGS__)

#define FUNC_VOID_N(N,...) \
    FAKE_VOID_FUNC ## N(__VA_ARGS__)


#define WRAP_FAKE_VALUE_FUNC(...) \
    WRAP_FUNC_VALUE_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define WRAP_FUNC_VALUE_(N,...) \
    WRAP_FUNC_VALUE_N(N,__VA_ARGS__)

#define WRAP_FUNC_VALUE_N(N,...) \
    WRAP_FAKE_VALUE_FUNC ## N(__VA_ARGS__)


#define WRAP_FAKE_VOID_FUNC(...) \
    WRAP_FUNC_VOID_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define WRAP_FUNC_VOID_(N,...) \
    WRAP_FUNC_VOID_N(N,__VA_ARGS__)

#define WRAP_FUNC_VOID_N(N,...) \
    WRAP_FAKE_VOID_FUNC ## N(__VA_ARGS__)

#define FAKE_VALUE_FUNC_VARARG(...) \
    FUNC_VALUE_VARARG_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define FUNC_VALUE_VARARG_(N,...) \
    FUNC_VALUE_VARARG_N(N,__VA_ARGS__)

#define FUNC_VALUE_VARARG_N(N,...) \
    FAKE_VALUE_FUNC ## N ## _VARARG(__VA_ARGS__)


#define FAKE_VOID_FUNC_VARARG(...) \
    FUNC_VOID_VARARG_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define FUNC_VOID_VARARG_(N,...) \
    FUNC_VOID_VARARG_N(N,__VA_ARGS__)

#define FUNC_VOID_VARARG_N(N,...) \
    FAKE_VOID_FUNC ## N ## _VARARG(__VA_ARGS__)



/* DECLARE FAKE FUNCTIONS - PLACE IN HEADER FILES */

#define DECLARE_FAKE_VALUE_FUNC(...) \
    DEC_FUNC_VALUE_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define DEC_FUNC_VALUE_(N,...)  \
    DEC_FUNC_VALUE_N(N,__VA_ARGS__)

#define DEC_FUNC_VALUE_N(N,...) \
    DECLARE_FAKE_VALUE_FUNC ## N(__VA_ARGS__)


#define DECLARE_FAKE_VOID_FUNC(...) \
    DEC_FUNC_VOID_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define DEC_FUNC_VOID_(N,...) \
    DEC_FUNC_VOID_N(N, __VA_ARGS__)

#define DEC_FUNC_VOID_N(N,...) \
    DECLARE_FAKE_VOID_FUNC ## N(__VA_ARGS__)


#define DECLARE_WRAP_FAKE_VALUE_FUNC(...) \
    DEC_WRAP_FUNC_VALUE_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define DEC_WRAP_FUNC_VALUE_(N,...)  \
    DEC_WRAP_FUNC_VALUE_N(N,__VA_ARGS__)

#define DEC_WRAP_FUNC_VALUE_N(N,...) \
    DECLARE_WRAP_FAKE_VALUE_FUNC ## N(__VA_ARGS__)


#define DECLARE_WRAP_FAKE_VOID_FUNC(...) \
    DEC_WRAP_FUNC_VOID_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define DEC_WRAP_FUNC_VOID_(N,...) \
    DEC_WRAP_FUNC_VOID_N(N, __VA_ARGS__)

#define DEC_WRAP_FUNC_VOID_N(N,...) \
    DECLARE_WRAP_FAKE_VOID_FUNC ## N(__VA_ARGS__)


#define DECLARE_FAKE_VALUE_FUNC_VARARG(...) \
    DEC_FUNC_VALUE_VARARG_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define DEC_FUNC_VALUE_VARARG_(N,...) \
    DEC_FUNC_VALUE_VARARG_N(N, __VA_ARGS__)    

#define DEC_FUNC_VALUE_VARARG_N(N,...) \
    DECLARE_FAKE_VALUE_FUNC ## N ## _VARARG(__VA_ARGS__)


#define DECLARE_FAKE_VOID_FUNC_VARARG(...) \
    DEC_FUNC_VOID_VARARG_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define DEC_FUNC_VOID_VARARG_(N,...) \
    DEC_FUNC_VOID_VARARG_N(N, __VA_ARGS__)    

#define DEC_FUNC_VOID_VARARG_N(N,...) \
    DECLARE_FAKE_VOID_FUNC ## N ## _VARARG(__VA_ARGS__)



/* DEFINE FAKE FUNCTIONS - PLACE IN SOURCE FILES */

#define DEFINE_FAKE_VALUE_FUNC(...) \
    DEF_FUNC_VALUE_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define DEF_FUNC_VALUE_(N,...)  \
    DEF_FUNC_VALUE_N(N,__VA_ARGS__)

#define DEF_FUNC_VALUE_N(N,...) \
    DEFINE_FAKE_VALUE_FUNC ## N(__VA_ARGS__)


#define DEFINE_FAKE_VOID_FUNC(...) \
    DEF_FUNC_VOID_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define DEF_FUNC_VOID_(N,...) \
    DEF_FUNC_VOID_N(N,__VA_ARGS__)

#define DEF_FUNC_VOID_N(N,...) \
    DEFINE_FAKE_VOID_FUNC ## N(__VA_ARGS__)


#define DEFINE_WRAP_FAKE_VALUE_FUNC(...) \
    DEF_WRAP_FUNC_VALUE_(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define DEF_WRAP_FUNC_VALUE_(N,...)  \
    DEF_WRAP_FUNC_VALUE_N(N,__VA_ARGS__)

#define DEF_WRAP_FUNC_VALUE_N(N,...) \
    DEFINE_WRAP_FAKE_VALUE_FUNC ## N(__VA_ARGS__)


#define DEFINE_WRAP_FAKE_VOID_FUNC(...) \
    DEF_WRAP_FUNC_VOID_(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define DEF_WRAP_FUNC_VOID_(N,...) \
    DEF_WRAP_FUNC_VOID_N(N,__VA_ARGS__)

#define DEF_WRAP_FUNC_VOID_N(N,...) \
    DEFINE_WRAP_FAKE_VOID_FUNC ## N(__VA_ARGS__)


#define DEFINE_FAKE_VALUE_FUNC_VARARG(...) \
    DEF_FUNC_VALUE_VARARG(PP_NARG_MINUS2(__VA_ARGS__), __VA_ARGS__)

#define DEF_FUNC_VALUE_VARARG(N,...) \
    DEF_FUNC_VALUE_VARARG_N(N,__VA_ARGS__) 

#define DEF_FUNC_VALUE_VARARG_N(N,...) \
    DEFINE_FAKE_VALUE_FUNC ## N ## _VARARG(__VA_ARGS__) 


#define DEFINE_FAKE_VOID_FUNC_VARARG(...) \
    DEF_FUNC_VOID_VARARG(PP_NARG_MINUS1(__VA_ARGS__), __VA_ARGS__)

#define DEF_FUNC_VOID_VARARG(N,...) \
    DEF_FUNC_VOID_VARARG_N(N,__VA_ARGS__) 

#define DEF_FUNC_VOID_VARARG_N(N,...) \
    DEFINE_FAKE_VOID_FUNC ## N ## _VARARG(__VA_ARGS__) 

  MACRO_COUNTING
end

def output_c_and_cpp

  include_guard {
    include_dependencies
    output_constants
    output_internal_helper_macros
    yield
    output_macro_counting_shortcuts
  }
end

# lets generate!!
output_c_and_cpp{
  define_fff_globals
  # Create fake generators for 0..MAX_ARGS
  num_fake_generators = $MAX_ARGS + 1
  num_fake_generators.times {|arg_count| output_macro(arg_count, false, false)}
  num_fake_generators.times {|arg_count| output_macro(arg_count, false, true)}
  # generate the varargs variants
  (2..$MAX_ARGS).each {|arg_count| output_macro(arg_count, true, false)}
  (2..$MAX_ARGS).each {|arg_count| output_macro(arg_count, true, true)}
}
