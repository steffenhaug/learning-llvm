
let _ =
  let ctx = Llvm.global_context () in
  let m = Llvm.create_module ctx "hello" in

  let _: bool = Llvm_executionengine.initialize () in
  let engine = Llvm_executionengine.create m in
  Llvm_executionengine.add_module m engine;

  let u8    = Llvm.i8_type ctx in
  let void  = Llvm.void_type ctx in

  let x = Llvm.const_int u8 69 in
  let _ = Llvm.define_global "x" x m in

  let print_ty = Llvm.function_type void [| u8 |] in
  let print = Llvm.declare_function "print" print_ty m in

  let main_ty = Llvm.function_type void [| |] in
  let main = Llvm.define_function "main" main_ty m in
  let e = Llvm.entry_block main in
  let b = Llvm.builder_at_end ctx e in
  let t = Llvm.build_add x (Llvm.const_int u8 4) "t" b in
  let _ = Llvm.build_call print_ty print [| t |] "" b in
  let _ = Llvm.build_ret_void b in

  Fmt.pr "Hello, LLVM JIT!\n";
  Llvm.print_module "hello.ll" m;
  Fmt.(pr "Status: %a@." (option string) (Llvm_analysis.verify_module m));

  let main_c_ty = Ctypes.(Foreign.funptr (void @-> returning void)) in
  let main_nf = 
    (Llvm_executionengine.get_function_address
      "main"
      main_c_ty
      engine) in
  main_nf ()
  ;