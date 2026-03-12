;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause
;;;;
;;;; Witness generation framework

(in-package :cl-zk-witness)

;;; ============================================================================
;;; Witness Generator
;;; ============================================================================

(defstruct witness-generator
  "Framework for generating witnesses from inputs."
  (input-handlers (make-hash-table :test 'equal) :type hash-table)
  (computations nil :type list)  ; Ordered list of computation functions
  (aux-generators nil :type list))

(defun generator-add-input-handler (gen name handler-fn)
  "Add handler for named input.
   HANDLER-FN: (lambda (witness value) ...) assigns value to appropriate wires."
  (setf (gethash name (witness-generator-input-handlers gen)) handler-fn)
  gen)

(defun generator-add-computation (gen compute-fn)
  "Add computation step.
   COMPUTE-FN: (lambda (witness) ...) computes derived values."
  (push compute-fn (witness-generator-computations gen))
  gen)

(defun generator-add-aux-generator (gen aux-fn)
  "Add auxiliary value generator.
   AUX-FN: (lambda (witness) ...) computes auxiliary values."
  (push aux-fn (witness-generator-aux-generators gen))
  gen)

;;; ============================================================================
;;; Witness Generation
;;; ============================================================================

(defun generator-run (gen inputs)
  "Run witness generator with given inputs.
   INPUTS: plist of input name to value."
  (let ((witness (make-empty-witness)))
    ;; Process inputs
    (loop for (name value) on inputs by #'cddr do
      (let ((handler (gethash (string name)
                              (witness-generator-input-handlers gen))))
        (when handler
          (funcall handler witness value))))
    ;; Run computations in reverse order (they were pushed)
    (dolist (compute-fn (reverse (witness-generator-computations gen)))
      (funcall compute-fn witness))
    ;; Generate auxiliary values
    (dolist (aux-fn (reverse (witness-generator-aux-generators gen)))
      (funcall aux-fn witness))
    witness))

;;; ============================================================================
;;; High-Level API
;;; ============================================================================

(defun generate-witness (public-inputs private-inputs &key computations)
  "Generate witness from public and private inputs.
   COMPUTATIONS: list of (fn witness) to compute derived values."
  (let ((witness (make-empty-witness)))
    ;; Assign public inputs
    (loop for (idx value) on public-inputs by #'cddr do
      (assign-public witness idx value))
    ;; Assign private inputs
    (loop for (idx value) on private-inputs by #'cddr do
      (assign-private witness idx value))
    ;; Run computations
    (dolist (compute-fn computations)
      (funcall compute-fn witness))
    witness))

;;; ============================================================================
;;; Common Computation Helpers
;;; ============================================================================

(defun compute-sum (witness input-indices output-index)
  "Compute sum of wires and assign to output."
  (let ((sum (reduce #'field-add
                     (mapcar (lambda (idx) (or (get-wire-value witness idx) 0))
                             input-indices)
                     :initial-value 0)))
    (assign-aux witness output-index sum)))

(defun compute-product (witness input-indices output-index)
  "Compute product of wires and assign to output."
  (let ((prod (reduce #'field-mul
                      (mapcar (lambda (idx) (or (get-wire-value witness idx) 1))
                              input-indices)
                      :initial-value 1)))
    (assign-aux witness output-index prod)))

(defun compute-inverse (witness input-index output-index)
  "Compute multiplicative inverse and assign to output."
  (let* ((value (get-wire-value witness input-index))
         (inv (if (and value (not (zerop value)))
                  (field-inv value)
                  0)))
    (assign-aux witness output-index inv)))
