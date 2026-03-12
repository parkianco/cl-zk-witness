;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defsystem :cl-zk-witness
  :description "Zero-knowledge witness generation utilities"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
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
