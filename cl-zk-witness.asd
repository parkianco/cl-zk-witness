;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(asdf:defsystem #::cl-zk-witness
  :description "Zero-knowledge witness generation utilities"
  :author "Parkian Company LLC"
  :license "Apache-2.0"
  :version "0.1.0"
  :depends-on ()
  :serial t
  :components
  ((:file "package")
   (:module "src"
    :components
    ((:file "field")
     (:file "types")
     (:file "assignment")
     (:file "generator")
     (:file "validator")
     (:file "serialization")))))

(asdf:defsystem #:cl-zk-witness/test
  :description "Tests for cl-zk-witness"
  :depends-on (#:cl-zk-witness)
  :serial t
  :components ((:module "test"
                :components ((:file "test-zk-witness"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-zk-witness.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
