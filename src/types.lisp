;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause
;;;;
;;;; Witness data types

(in-package :cl-zk-witness)

;;; ============================================================================
;;; Wire Assignment
;;; ============================================================================

(defstruct wire-assignment
  "Assignment of value to a single wire."
  (index 0 :type integer)
  (value 0 :type integer)
  (label nil :type (or null string)))

;;; ============================================================================
;;; Assignment Map
;;; ============================================================================

(defstruct assignment-map
  "Map of wire indices to values."
  (entries (make-hash-table :test 'eql) :type hash-table)
  (size 0 :type integer))

(defun assignment-map-get (map index)
  "Get value from assignment map."
  (gethash index (assignment-map-entries map)))

(defun assignment-map-set (map index value &optional label)
  "Set value in assignment map."
  (let ((entry (make-wire-assignment :index index :value value :label label)))
    (unless (gethash index (assignment-map-entries map))
      (incf (assignment-map-size map)))
    (setf (gethash index (assignment-map-entries map)) entry)
    entry))

;;; ============================================================================
;;; Witness Structure
;;; ============================================================================

(defstruct witness
  "Complete witness for a ZK proof."
  (public nil :type (or null assignment-map))    ; Public inputs
  (private nil :type (or null assignment-map))   ; Private witness values
  (aux nil :type (or null assignment-map))       ; Auxiliary computed values
  (metadata nil :type list))                     ; Additional metadata

(defun make-empty-witness ()
  "Create empty witness structure."
  (make-witness
   :public (make-assignment-map)
   :private (make-assignment-map)
   :aux (make-assignment-map)))

;;; ============================================================================
;;; Witness Info
;;; ============================================================================

(defun witness-total-size (w)
  "Total number of assigned wires."
  (+ (assignment-map-size (witness-public w))
     (assignment-map-size (witness-private w))
     (assignment-map-size (witness-aux w))))

(defun witness-info (w)
  "Return witness statistics."
  (list :public-count (assignment-map-size (witness-public w))
        :private-count (assignment-map-size (witness-private w))
        :aux-count (assignment-map-size (witness-aux w))
        :total (witness-total-size w)))
