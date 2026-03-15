;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

(defpackage :cl-zk-witness
  (:use :cl)
  (:nicknames :zk-witness)
  (:export
   #:with-zk-witness-timing
   #:zk-witness-batch-process
   #:zk-witness-health-check;; Field
   #:+field-prime+
   #:field-add
   #:field-sub
   #:field-mul
   #:field-inv
   #:field-neg
   #:field-pow

   ;; Types
   #:witness
   #:make-witness
   #:witness-public
   #:witness-private
   #:witness-aux
   #:witness-metadata

   #:wire-assignment
   #:make-wire-assignment
   #:wire-assignment-index
   #:wire-assignment-value
   #:wire-assignment-label

   #:assignment-map
   #:make-assignment-map
   #:assignment-map-entries
   #:assignment-map-size

   ;; Assignment operations
   #:assign-wire
   #:assign-public
   #:assign-private
   #:assign-aux
   #:get-wire-value
   #:get-public-inputs
   #:get-private-inputs

   ;; Generator
   #:witness-generator
   #:make-witness-generator
   #:generator-add-input-handler
   #:generator-add-computation
   #:generator-run
   #:generate-witness

   ;; Validation
   #:validate-witness
   #:validate-range
   #:validate-non-zero
   #:validate-binary
   #:validate-constraint
   #:witness-valid-p
   #:validation-error
   #:validation-error-wire
   #:validation-error-reason

   ;; Serialization
   #:serialize-witness
   #:deserialize-witness
   #:witness-to-vector
   #:vector-to-witness
   #:export-witness-json
   #:import-witness-json))
