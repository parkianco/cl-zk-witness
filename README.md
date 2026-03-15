# cl-zk-witness

Pure Common Lisp implementation of Zk Witness

## Overview
This library provides a robust, zero-dependency implementation of Zk Witness for the Common Lisp ecosystem. It is designed to be highly portable, performant, and easy to integrate into any SBCL/CCL/ECL environment.

## Getting Started

Load the system using ASDF:

```lisp
(asdf:load-system #:cl-zk-witness)
```

## Usage Example

```lisp
;; Initialize the environment
(let ((ctx (cl-zk-witness:initialize-zk-witness :initial-id 42)))
  ;; Perform batch processing using the built-in standard toolkit
  (multiple-value-bind (results errors)
      (cl-zk-witness:zk-witness-batch-process '(1 2 3) #'identity)
    (format t "Processed ~A items with ~A errors.~%" (length results) (length errors))))
```

## License
Apache-2.0
