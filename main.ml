let ctx = Llvm.global_context ()

let u8    = Llvm.i8_type ctx
let void  = Llvm.void_type ctx

type fndecl = 
  { ty: Llvm.lltype;
    fn: Llvm.llvalue;
  }

module Module = struct
  
end

module Jit = struct
  let jit_toplevel = Llvm.create_module ctx "jit-toplevel"

  let _: bool = Llvm_executionengine.initialize ()

  let engine = Llvm_executionengine.create jit_toplevel

  let print = 
    let ty = Llvm.function_type void [| u8 |] in
    { ty; fn = Llvm.declare_function "print" ty jit_toplevel }

  let compile m = Llvm_executionengine.add_module m engine

  (* Kinda dodgy; call a void -> void function "main".*)
  let main () =
    let main_fn_ptr = 
      (Llvm_executionengine.get_function_address
        "main"
        (Foreign.funptr Ctypes.(void @-> returning void))
        engine) in
    main_fn_ptr ()
end

let _ =
  let m = Llvm.create_module ctx "hello" in
  Jit.compile m;

  (* Generate some code for the hello module *)
  let x = Llvm.const_int u8 69 in
  let _ = Llvm.define_global "x" x m in

  let main_ty = Llvm.function_type void [| |] in
  let main = Llvm.define_function "main" main_ty m in
  let e = Llvm.entry_block main in
  let b = Llvm.builder_at_end ctx e in
  let t = Llvm.build_add x (Llvm.const_int u8 4) "t" b in
  let _ = Llvm.build_call Jit.print.ty Jit.print.fn [| t |] "" b in
  let _ = Llvm.build_ret_void b in

  (* Verify the module *)
  Fmt.pr "Hello, LLVM JIT!\n";
  Llvm.print_module "hello.ll" m;
  Fmt.(pr "Status: %a@." (option string) (Llvm_analysis.verify_module m));

  (* Call the module *)
  Jit.main ();