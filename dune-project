(lang dune 3.12)

(package
 (name llvmtest)
 (depends
  dune
  fmt
  (ocaml
   (>= "5.1.0"))
  (llvm
   (>= "16.0.0"))))
