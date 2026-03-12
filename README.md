# cl-zk-witness

Pure Common Lisp library for zero-knowledge witness generation and management.

## Features

- Witness data structures (public/private/auxiliary)
- Wire assignment with labels
- Witness generator framework
- Validation utilities (range, binary, R1CS constraints)
- Binary and JSON serialization
- Zero external dependencies

## Installation

```bash
cd ~/quicklisp/local-projects/
git clone https://github.com/parkianco/cl-zk-witness.git
```

```lisp
(asdf:load-system :cl-zk-witness)
```

## Quick Start

```lisp
(use-package :cl-zk-witness)

;; Create witness with public and private inputs
(let ((w (generate-witness
          '(0 42 1 17)           ; Public: wire 0 = 42, wire 1 = 17
          '(0 secret-value))))   ; Private: wire 0 = secret
  ;; Validate
  (validate-binary w 0)          ; Wire 0 must be 0 or 1
  (validate-range w 1 0 100)     ; Wire 1 in [0, 100]

  ;; Export
  (export-witness-json w *standard-output*))
```

## Witness Generation Framework

```lisp
;; Build a witness generator
(let ((gen (make-witness-generator)))
  ;; Add input handlers
  (generator-add-input-handler gen "x"
    (lambda (w val) (assign-public w 0 val)))
  (generator-add-input-handler gen "secret"
    (lambda (w val) (assign-private w 0 val)))

  ;; Add computation step
  (generator-add-computation gen
    (lambda (w)
      (let ((x (get-wire-value w 0))
            (s (get-wire-value w 1)))
        (assign-aux w 2 (field-mul x s)))))

  ;; Generate witness
  (generator-run gen '("x" 5 "secret" 7)))
```

## API Reference

### Wire Assignment
- `assign-public`, `assign-private`, `assign-aux` - Assign values
- `get-wire-value` - Retrieve wire value
- `get-public-inputs`, `get-private-inputs` - Get input lists

### Generator
- `make-witness-generator` - Create generator
- `generator-add-input-handler` - Register input processor
- `generator-add-computation` - Add computation step
- `generator-run` - Execute generator

### Validation
- `validate-range` - Check value in range
- `validate-binary` - Check value is 0 or 1
- `validate-non-zero` - Check value is non-zero
- `validate-constraint` - Check R1CS constraint
- `witness-valid-p` - Run all validators

### Serialization
- `serialize-witness`, `deserialize-witness` - Binary format
- `witness-to-vector`, `vector-to-witness` - Vector conversion
- `export-witness-json`, `import-witness-json` - JSON format

## License

BSD-3-Clause. See [LICENSE](LICENSE).

## Author

Parkian Company LLC
