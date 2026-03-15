;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0
;;;;
;;;; Witness validation

(in-package :cl-zk-witness)

;;; ============================================================================
;;; Validation Error
;;; ============================================================================

(define-condition validation-error (error)
  ((wire :initarg :wire :reader validation-error-wire)
   (reason :initarg :reason :reader validation-error-reason))
  (:report (lambda (c s)
             (format s "Witness validation failed for wire ~a: ~a"
                     (validation-error-wire c)
                     (validation-error-reason c)))))

;;; ============================================================================
;;; Value Validators
;;; ============================================================================

(defun validate-range (witness wire-index min max)
  "Validate wire value is in range [min, max]."
  (let ((value (get-wire-value witness wire-index)))
    (unless value
      (error 'validation-error :wire wire-index :reason "Wire not assigned"))
    (unless (<= min value max)
      (error 'validation-error
             :wire wire-index
             :reason (format nil "Value ~a not in range [~a, ~a]" value min max)))
    t))

(defun validate-non-zero (witness wire-index)
  "Validate wire value is non-zero."
  (let ((value (get-wire-value witness wire-index)))
    (unless value
      (error 'validation-error :wire wire-index :reason "Wire not assigned"))
    (when (zerop value)
      (error 'validation-error :wire wire-index :reason "Value is zero"))
    t))

(defun validate-binary (witness wire-index)
  "Validate wire value is 0 or 1."
  (let ((value (get-wire-value witness wire-index)))
    (unless value
      (error 'validation-error :wire wire-index :reason "Wire not assigned"))
    (unless (or (zerop value) (= value 1))
      (error 'validation-error
             :wire wire-index
             :reason (format nil "Value ~a is not binary" value)))
    t))

;;; ============================================================================
;;; Constraint Validation
;;; ============================================================================

(defun validate-constraint (witness a-wires b-wires c-wires)
  "Validate that sum(a) * sum(b) = sum(c) for wire lists."
  (let ((a-sum (reduce #'field-add
                       (mapcar (lambda (w) (or (get-wire-value witness w) 0))
                               a-wires)
                       :initial-value 0))
        (b-sum (reduce #'field-add
                       (mapcar (lambda (w) (or (get-wire-value witness w) 0))
                               b-wires)
                       :initial-value 0))
        (c-sum (reduce #'field-add
                       (mapcar (lambda (w) (or (get-wire-value witness w) 0))
                               c-wires)
                       :initial-value 0)))
    (let ((lhs (field-mul a-sum b-sum)))
      (unless (= lhs c-sum)
        (error 'validation-error
               :wire (first c-wires)
               :reason (format nil "Constraint failed: ~a * ~a = ~a, expected ~a"
                               a-sum b-sum lhs c-sum)))
      t)))

;;; ============================================================================
;;; Complete Witness Validation
;;; ============================================================================

(defun validate-witness (witness validators)
  "Run list of validators on witness.
   VALIDATORS: list of (lambda (witness) ...) that return T or signal error."
  (dolist (validator validators)
    (funcall validator witness))
  t)

(defun witness-valid-p (witness validators)
  "Check if witness passes all validators. Returns T or NIL."
  (handler-case
      (progn (validate-witness witness validators) t)
    (validation-error () nil)))

;;; ============================================================================
;;; Common Validator Constructors
;;; ============================================================================

(defun make-range-validator (wire-index min max)
  "Create range validator for wire."
  (lambda (witness)
    (validate-range witness wire-index min max)))

(defun make-binary-validator (wire-index)
  "Create binary validator for wire."
  (lambda (witness)
    (validate-binary witness wire-index)))

(defun make-constraint-validator (a-wires b-wires c-wires)
  "Create R1CS constraint validator."
  (lambda (witness)
    (validate-constraint witness a-wires b-wires c-wires)))
